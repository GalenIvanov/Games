;http://alienryderflex.com/polygon/

Red[
   Title: "Interactive Tangram puzzle"
   Author: "Galen Ivanoov"
   Needs: 'view
]

point-in-poly?: func[
	p [pair!]  "The point to be tested"
	poly [block!] "A block of pairs, describing the polygon"
	/local
	poly2 i y x y2 x2 cross
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
		    y < p/y
 			p/y < y2
			t1 < t2
		][cross: not cross ]
	]
    cross
]

tri: [0x0 70x30 30x40]
tri2: [100x100 150x100 125x150]
quad: [80x10 120x10 120x40 80x40]
para1: [200x200 225x225 225x275 200x250]
p: 20x15
p2: 100x20
p3: 30x30
p4: 101x101
p5: 212x240
p6: 201x201 - 3

print point-in-poly? 10x10 tri
print point-in-poly? p2 tri
print point-in-poly? p3 tri
print point-in-poly? p2 quad
print point-in-poly? p4 tri2
print point-in-poly? p5 para1
print point-in-poly? p5 + 14x0 para1
print point-in-poly? p6 para1


view [
    base 300x300 snow draw compose [
	    fill-pen beige
		polygon (tri)
		polygon (tri2)
		polygon (quad)
		polygon (para1)
				
		pen red
		circle (p) 3
		circle (p2) 3
		circle (p3) 3
		circle (p4) 3
		circle (p5) 3
		circle (p5 + 14x0) 3
		circle (p6) 3
	]
]



