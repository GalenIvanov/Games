;http://alienryderflex.com/polygon/

Red[
   Title: "Interactive Tangram puzzle"
   Author: "Galen Ivanoov"
   Needs: 'view
]

selected-poly: none
poly-n: 0
drag: off
drag-coords: []
start-drag: 0


; polygons with relative coords 1..100 - to be scaled according to the resolution
polygons: [
    [1x1 50x50 1x100]
    [1x1 100x1 50x50]
	[100x1 100x50 75x75 75x25]
	[100x50 100x100 50x100]
	[1x100 25x75 50x100]
	[50x50 75x75 50x100 25x75]
	[50x50 75x25 75x75]
]

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
			drag-coords: copy polygons/:i
			break
		]
	]	
	
	msg/text: form selected-poly
]

hilight-poly: func[
    offs
	/local i p v poly-word temp-coords collision
][
    repeat i length? polygons [
		poly-word: to word! rejoin ["poly" i]
	    change at get poly-word 2 either point-in-poly? offs polygons/:i [
			green
		][
		    beige
		]
	]
	
	collision: false
	
	if drag [
	    temp-coords: copy drag-coords
	    repeat i length? drag-coords [
		    temp-coords/:i: drag-coords/:i - start-drag + offs
			; check if each point of the current poly lies in any of the polygons
			foreach p polygons [
			    if point-in-poly? temp-coords/:i p [
				    collision: true
                    break  					
				]
			]
			if collision [break]
		]
		
		if not collision [
		    ; check if each vertex of each poly lies within the current poly
		    foreach p polygons [
			    foreach v p [
				    if point-in-poly? v temp-coords [
					    collision: true
						break
					]
				]
			]			
		
		    if not collision [
           		p: at get selected-poly 4
           		repeat i length? drag-coords [
           		    p/:i: drag-coords/:i - start-drag + offs
           		]
			]
		]	
	]
]

update-polys: func[
    offs
	/local i p
][
    if drag[
	    i: 1
		p: at get selected-poly 4 
	    forall drag-coords[
		    drag-coords/1: drag-coords/1 - start-drag + offs
			p/:i: drag-coords/1
			i: i + 1
		]
		change/only at polygons poly-n drag-coords
	    drag: off
	]
]


polys: collect[
    repeat i length? polygons [
	    keep to set-word! rejoin ["poly" i]
		keep 'fill-pen keep 'beige
	    keep 'polygon
		keep polygons/:i
    ]
]

view [title "Tangram"
    below
    base 300x300 snow draw compose [(polys)]
	all-over
	on-over [hilight-poly event/offset]
	on-down [get-poly event/offset]
    on-up [update-polys event/offset]	 
	msg: text "none"
]
