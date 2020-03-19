;http://alienryderflex.com/polygon/

Red[
   Title: "Interactive Tangram puzzle"
   Author: "Galen Ivanoov"
   Needs: 'view
]

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
	
	    if y > y2 [    ; swap the points if the first point is "higher" then the second one
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

select-poly: func[
    offs
	/local i poly-word
][
    repeat i length? polygons [
		poly-word: to word! rejoin ["poly" i]
	    change at get poly-word 2 either point-in-poly? offs polygons/:i [
			red
		][
		    beige
		]
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
    base 300x300 snow draw compose [(polys)]
	all-over
	on-over [select-poly event/offset]
]
