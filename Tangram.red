;http://alienryderflex.com/polygon/

Red[
   Title: "Interactive Tangram puzzle"
   Author: "Galen Ivanov"
   Needs: 'view
]

selected-poly: none
poly-n: 0
drag: off
drag-coords: []
start-drag: 0
temp-coords: []

; polygons with relative coords 1..200 - to be scaled according to the resolution
polygons: [
    [0x0 100x100 0x200]
    [0x0 200x0 100x100]
    [200x0 200x100 150x150 150x50]
    [200x100 200x200 100x200]
    [0x200 50x150 100x200]
    [100x100 150x150 100x200 50x150]
    [100x100 150x50 150x150]
]

angles: [0 0 0 0 0 0 0]

point-in-poly?: func[
    p [pair!]  "The point to be tested"
    poly [block!] "A block of pairs, describing the polygon"
    /local poly2 i y x y2 x2 cross
][
    cross: off
    poly2: copy poly
    move poly2 tail poly2
    
    repeat i length? poly [
        x: poly/:i/x
        y: poly/:i/y
        x2: poly2/:i/x
        y2: poly2/:i/y
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
    p v 
][
    ; check if each point of the current poly lies in any of the polygons
    foreach v temp-coords [
        foreach p polygons [
            if all [p <> drag-coords point-in-poly? v p][
                return true
            ]
        ]
    ]
    ; check if each vertex of each poly lies within the current poly
    foreach p polygons [
        if p <> drag-coords [
            foreach v p [
                if point-in-poly? v temp-coords [
                    return true
                ]
            ]
        ]
    ]
    false    
]

snap-to-vertex: has[
     d dx dy p v c delta offs
][
    delta: 25
    offs: 0
    foreach v drag-coords [
        foreach p polygons [
            if p <> drag-coords [
                foreach c p [
                    dx: v/x - c/x
                    dy: v/y - c/y
                    d: sqrt dx * dx + (dy * dy)
                    if d < delta [ 
                        delta: d
                        offs:  c - v
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
    repeat i length? polygons [
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
    ;msg/text: form selected-poly
]

move-poly: func[
    offs
    /local i p v poly-word
][
    if drag [
        temp-coords: copy drag-coords
        repeat i length? drag-coords [
            temp-coords/:i: drag-coords/:i - start-drag + offs
        ]
        if not collision? [
               p: at get selected-poly 4
               repeat i length? drag-coords [
                p/:i: temp-coords/:i
            ]
        ]
    ]
]

fine-average: func[
    points
    /local sum-x sum-y size
][
    sum-x: sum-y: 0
    size: to float! length? points
    foreach p points [
        sum-x: sum-x + p/x
        sum-y: sum-y + p/y
    ]
    reduce [ sum-x / size sum-y / size ]
]

; rounding erors!!!
; I need to keep the original coords and separately the angles of rotation
; and rotate the polys starting from the original coods 
; and update the angles respectively 
rotate-poly: func[
    offs direction
    /local i p center-x center-y dx dy angle radius x y 
][
    drag: off
    start-drag: offs 
    get-poly offs
    
    if selected-poly [
        set[center-x center-y] fine-average drag-coords
        forall drag-coords [
            dx: drag-coords/1/x - center-x
            dy: drag-coords/1/y - center-y
            angle: 45 * direction - arctangent2 dy dx
            radius: sqrt dx * dx + (dy * dy)
            x: round/down center-x + (radius * cosine angle) + 0.49
            y: round/down center-y - (radius * sine angle) + 0.49
            drag-coords/1: as-pair x y
        ]
        update-polys offs
    ]
]

update-polys: func[
    offs
    /local i p snap
][
    if drag[
        p: at get selected-poly 4

        forall drag-coords[
            ;drag-coords/1: round/down/to drag-coords/1 - start-drag + offs + 12.5 25
            drag-coords/1: drag-coords/1 - start-drag + offs
             ;p/:i: drag-coords/1
            ;i: i + 1
        ]
        
        snap: snap-to-vertex 
        
        i: 1
        forall drag-coords[
            drag-coords/1: drag-coords/1 + snap
             p/:i: drag-coords/1 
            i: i + 1
        ]
                
        change/only at polygons poly-n drag-coords
        drag: off
    ]
]

polys: collect[
    keep [line-width 3 line-join round]
    repeat i length? polygons [
        keep to set-word! rejoin ["poly" i]
        keep compose [fill-pen beige polygon (polygons/:i)]
    ]
]

view [title "Tangram"
    below
    base 500x500 snow draw compose [(polys)]
    all-over
    on-over [move-poly event/offset]
    on-down [get-poly event/offset]
    on-up [update-polys event/offset]
    on-wheel [rotate-poly event/offset event/picked]
    msg: text "none"
]
