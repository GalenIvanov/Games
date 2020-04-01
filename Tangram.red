;http://alienryderflex.com/polygon/

Red[
   Title: "Interactive Tangram puzzle"
   Author: "Galen Ivanov"
   Needs: 'view
]

random/seed now

selected-poly: none
poly-n: 0
drag: off
drag-coords: []
start-drag: 0
temp-coords: []

; polygons with relative coords 1..200 - to be scaled according to the resolution
polygons: [
    [0 0 100 100 0 200]
    [0 0 200 0 100 100]
    [200 0 200 100 150 150 150 50]
    [200 100 200 200 100 200]
    [0 200 50 150 100 200]
    [100 100 150 150 100 200 50 150]
    [100 100 150 50 150 150]
]


point-in-poly?: func[
    p [pair!]  "The point to be tested"
    poly [block!] "A block of coords, describing the polygon"
    /local poly2 i y x y2 x2 cross
][
    cross: off
    poly2: copy poly
    move/part poly2 tail poly2 2
    
    repeat i (length? poly) / 2 [
        x: poly/(2 * i - 1)
        y: poly/(2 * i)
        x2: poly2/(2 * i - 1)
        y2: poly2/(2 * i)
        ; swap the points if the first point is "higher" then the second one
        if y > y2 [ 
           set [x y x2 y2] reduce[x2 y2 x y]
        ]
        
        t1: x2 - x / to float! (y2 - y)
        t2: p/x - x / to float! (p/y - y)
        
        if all [
            y <= p/y
            p/y < y2
            t1 < t2
        ][
           cross: not cross 
        ]
    ]
    cross
]

collision?: has [
    p vx vy 
][
    ; check if each point of the current poly lies in any of the polygons
    foreach [vx vy] temp-coords [
        foreach p polygons [
            if all [p <> drag-coords point-in-poly? as-pair vx vy p][
                return true
            ]
        ]
    ]
    ; check if each vertex of each poly lies within the current poly
    foreach p polygons [
        if p <> drag-coords [
            foreach [vx vy] p [
                if point-in-poly? as-pair vx vy temp-coords [
                    return true
                ]
            ]
        ]
    ]
    false    
]

snap-to-vertex: has[
     d dx dy p vx vy cx cy delta offs
][
    delta: 25
    offs: 0x0
    foreach [vx vy] drag-coords [
        foreach p polygons [
            if p <> drag-coords [
                foreach [cx cy] p [
                    dx: vx - cx
                    dy: vy - cy
                    d: sqrt dx * dx + (dy * dy)
                    if d < delta [ 
                        delta: d
                        offs: as-pair cx - vx cy - vy
                    ]
                ]
            ]
        ]
    ]
    offs
]

snap-to-edge: has [
][
 
]

get-poly: func[
    offs
    /local i poly-word
][
    selected-poly: none
    repeat i length? polygons[
        poly-word: to word! rejoin ["poly" i]
        if point-in-poly? offs polygons/:i[
            selected-poly: poly-word
            poly-n: i
            drag: on
            start-drag: offs
            drag-coords: polygons/:i
            break
        ]
    ]    
    msg/text: form selected-poly
]

move-poly: func[
    offs
    /local i p v poly-word
][
    if drag [
        temp-coords: copy drag-coords
        repeat i (length? drag-coords) / 2 [
            temp-coords/(2 * i - 1): drag-coords/(2 * i - 1) - start-drag/x + offs/x
			temp-coords/(2 * i): drag-coords/(2 * i) - start-drag/y + offs/y
        ]
        if not collision? [
            p: at get selected-poly 4
            repeat i (length? drag-coords) / 2 [
                p/:i: as-pair temp-coords/(2 * i - 1) temp-coords/(2 * i)
            ]
        ]
    ]
]

fine-average: func[
    points
    /local sum-x sum-y size
][
    sum-x: sum-y: 0
    size: to float! (length? points) / 2
    foreach [x y] points [
        sum-x: sum-x + x
        sum-y: sum-y + y
    ]
    reduce [ sum-x / size sum-y / size ]
]

rotate-poly: func[
    offs direction
    /local center-x center-y dx dy angle radius x y p
][
    start-drag: offs 
    get-poly offs
	drag: off
    
    if selected-poly [
		temp-coords: copy drag-coords
		set[center-x center-y] fine-average temp-coords
        repeat i (length? drag-coords) / 2 [
            dx: temp-coords/(2 * i - 1) - center-x
            dy: temp-coords/(2 * i) - center-y
            angle: 15 * direction - arctangent2 dy dx
            radius: sqrt dx * dx + (dy * dy)
            x: center-x + (radius * cosine angle)
            y: center-y - (radius * sine angle)
			temp-coords/(2 * i - 1): x
			temp-coords/(2 * i): y
        ]
		
		if not collision? [
			drag: on
		    update-polys offs
		]
    ]
]

update-polys: func[
    offs
    /local i p snap
][
    if drag[
        p: at get selected-poly 4
	
        repeat i (length? drag-coords) / 2 [
		    drag-coords/(2 * i - 1): temp-coords/(2 * i - 1)
			drag-coords/(2 * i): temp-coords/(2 * i)
        ]
        snap: snap-to-vertex
        repeat i (length? drag-coords) / 2 [
            drag-coords/(2 * i - 1): drag-coords/(2 * i - 1) + snap/x
			drag-coords/(2 * i): drag-coords/(2 * i) + snap/y
            p/:i: as-pair drag-coords/(2 * i - 1) drag-coords/(2 * i)
        ]
		
        change/only at polygons poly-n drag-coords
        drag: off
    ]
]

polys: collect[
    keep [line-width 4 pen white line-join round]
    repeat i length? polygons [
        keep to set-word! rejoin ["poly" i]
        keep compose [fill-pen (255.228.196 - random 25.25.25) polygon]
		repeat j (length? polygons/:i) / 2[
		    keep as-pair polygons/:i/(2 * j - 1) polygons/:i/(2 * j)
		]
    ]
]

view [title "Tangram"
    below
    base 600x500 snow draw compose [(polys)]
    all-over
    on-over [move-poly event/offset]
    on-down [get-poly event/offset]
    on-up [update-polys event/offset]
    on-wheel [rotate-poly event/offset event/picked]
    msg: text "none"
]
