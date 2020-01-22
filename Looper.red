Red[
    Title: "Loop-thru - a logic game"
    Author: "Galen Ivanov"
    Date: 13-01-2020
    needs: View
]

random/seed now

buffer: make block! 5000
board: make block! 10000
b1: make block! 10000
free-cells-left: make block! 10000
free-cells-right: make block! 10000
solution: make block! 1000
border-loop: make block! 1000
segments: make block! 1000
segs: make block! 1000
seg-coords: make block! 100

seg-zones: make block! 100

;test-loop: make block! 1000

AW: 800    ; size of the active area
W: 220     ; size of the grid in pixels
size: 7    ; size of the grid - rows and columns - boxes, not points!
rx: ry: 0
dx: 0 
z: AW - W / 2       ; ofsset from the topleft corner of the active area to the dots area
adj: 0x0

start-border: 0

iter-n: make reactor! [idx: 0]

directions: [L: -1x0 U: 0x-1 R: 1x0 D: 0x1]
seg-coords: copy [5x5 280x5 560x5 5x280 560x280 5x560 280x560 560x560]

solved: false

drag-seg: ""
drag-start: 0x0
drag: 0x0

draw-board: has [ a b r c offsx offsy ][
       
    num-font: make object! [
        name: "Verdana"
        size: 18
        style: "bold"
        angle: 0
        color: white ; reblue - 10.20.30
        anti-alias?: true
        shadow: none
        state: none
        parent: none
    ]
    num-font/size: to 1 dx / 2.5
    offsy: dx - num-font/size / 3
    
    clear buffer
 
    collect/into [
        ; the island itself
        ;if solved [ 
        {
        keep [ pen teal fill-pen teal ]
            repeat r size [
                repeat c size [
                    if board/:r/:c = 1 [keep compose [ box (as-pair c - 1 * dx + z r - 1 * dx + z)
                                                           (as-pair c * dx + z r * dx + z)]]
                ]
            ]
        }    
        ;]
        ; dots
        keep [ pen white fill-pen white ]
        repeat r size [
            repeat c size [
                keep compose [ box (as-pair c - 1 * dx - 3 + z  r - 1 * dx - 3 + z)
                                   (as-pair c - 1 * dx + 3 + z  r - 1 * dx + 3 + z)
                               box (as-pair c     * dx - 3 + z  r - 1 * dx - 3 + z)
                                   (as-pair c     * dx + 3 + z  r - 1 * dx + 3 + z)
                               box (as-pair c - 1 * dx - 3 + z  r     * dx - 3 + z)
                                   (as-pair c - 1 * dx + 3 + z  r     * dx + 3 + z)
                               box (as-pair c     * dx - 3 + z  r     * dx - 3 + z)
                                   (as-pair c     * dx + 3 + z  r     * dx + 3 + z)                                      
                ]
            ]
        ]
        ; starting dot
        ;keep compose [ fill-pen black pen black box (as-pair rx - 3 ry - 3)
        ;                                   (as-pair rx + 3 ry + 3)]
        
        ; labels
        {
        keep [font num-font]
        foreach [x y n] labels [
            n: to string! n
            offsx: dx - ( num-font/size * length? n ) / 2
            keep compose [text (as-pair x - 1 * dx + offsx + z y - 1 * dx + offsy  + z) (n)] 
        ]
        }

        ;keep test-loop  ; the entire loop
        keep [line-cap round line-join round ]
        keep segs   ; the cut segments
    ] buffer
]

get-the-loop: has [ x y border a b c d x1 y1 x2 y2][
    collect/into [
        repeat y size [
            repeat x size [
                if board/:y/:x = 1 [
                    line-block: copy [ line ]
                    foreach border difference "LURD" get-neighbours board x y 1 [
                        set [a b c d] select [ #"U" [0 0 1 0] 
                                               #"R" [1 0 1 1]
                                               #"L" [0 0 0 1] 
                                               #"D" [0 1 1 1] ] border
                        x1: x + a - 1 * dx 
                        y1: y + b - 1 * dx 
                        x2: x + c - 1 * dx 
                        y2: y + d - 1 * dx 
                         
                        ; reverse down and left edges, so that the edges can form a loop 
                        if border = #"D" [t: x1 x1: x2 x2: t]  
                        if border = #"L" [t: y1 y1: y2 y2: t]

                        keep as-pair x1 + z y1 + z keep as-pair x2 + z y2 + z
                        keep border                        
                        ;]
                    ]
                ]
            ]
        ]
    ] solution
    
    build-loop solution
        
]

cut-segments: func [
    seg
    /local ang angs n x y minx maxx miny maxy ofs start p1 p2
][

    clear segs
    clear seg-zones
    ofs: clear []
    
    collect/into [
        keep [line-width 9 pen white]
        repeat n size + 1 [
            ang: 0
            x: y: 0
            minx: miny: maxx: maxy: 0
            
            angs: take/part seg size + 1  
            keep compose[(to set-word! rejoin["seg" n]) line] 
            keep as-pair x y
            
            forall angs [
                ang: ang + angs/1
                x: x + (dx * cosine ang)
                minx: min minx x
                maxx: max maxx x
                
                y: y - (dx * sine ang) 
                miny: min miny y
                maxy: max maxy y
               
                keep as-pair x y
            ] 
            append ofs as-pair (size + 1) / 2.0 - (absolute (maxx - minx) / 2.0) - minx
                               (size + 1) / 2.0 - (absolute (maxy - miny) / 2.0) - miny          
                               
            
        ]
    ] segs
    
    repeat n size + 1 [
        seg-coords/:n: size + 2 / 2.0 * dx + seg-coords/:n + ofs/:n
    ]
    
    start: next find/tail segs 'seg1
    repeat n size + 1 [                     ; segments
        loop size + 2 [                 ; lines in the segment  
            start/1: start/1 + seg-coords/:n
            start: next start
        ]
        start: skip start 2
    ] 
    
    start: next find/tail segs 'seg1
    repeat n size + 1 [                     ; segments
        append/only seg-zones collect [     ; for detection of the segment zones by the mouse events
            n-rects: size + 1
            loop size + 2 [                 ; lines in the segment  
                if n-rects > 0 [
                    p1: start/1
                    p2: start/2
                    if (p1/x > p2/x) or (p1/y > p2/y) [
                        p1: start/2
                        p2: start/1
                    ]
                    keep p1 - 3x3
                    keep p2 + 3x3
                    n-rects: n-rects - 1
                ]
                start: next start
            ]
            start: skip start 2
        ]
    ] 
]

get-dirs: func[borders /local ang ang-inc x y][

;    clear test-loop
;    append test-loop  [line-width 5 pen snow line]
;    append test-loop as-pair rx ry   ; starting point
    
    ang: pick [90 0 -90 180] index? find "LURD" start-border
    x: rx
    y: ry
    
    clear segments
    
    collect/into [
        repeat n (length? borders) - 1 [
            ang-inc: switch rejoin[borders/:n borders/(n + 1)] [
                "LL" [  0]
                "LU" [-90]
                "LD" [ 90] 
                "UU" [  0]
                "UR" [-90]
                "UL" [ 90]
                "RR" [  0]
                "RD" [-90]
                "RU" [ 90]
                "DD" [  0]
                "DL" [-90]
                "DR" [ 90]
            ]
            keep ang-inc
            ang: ang + ang-inc
            x: x + (dx * cosine ang)
            y: y - (dx * sine ang) 
            ;append test-loop as-pair x y
        ] 
    ] segments
    
    cut-segments segments
]

build-loop: func[sol /local s p1 p2][
    s: (random ((length? solution) - 1)) / 3
    s: s * 3 + 1
    
    ; for visualization of the starting point
    rx: solution/:s/1 
    ry: solution/:s/2
    
    rd: solution/(s + 2)  ; starting edge
    start-border: rd
    
    clear border-loop    ; borders of the cell -> will be used to get directions
    
    append border-loop rd
        
    p1: solution/:s
    collect/into [
        until [
            p2: take/part find/skip solution p1 3 3
            keep take/last p2
            p1: p2/2
            empty? solution 
        ] 
    ] border-loop
       
    get-dirs border-loop
]

get-neighbours: function [ brd x y state ][
    rejoin collect [
        case/all [
            all [x > 1 attempt [brd/:y/(x - 1) = state]]  [ keep "L" ]
            all [y > 1 attempt [brd/(y - 1)/:x = state]]  [ keep "U" ]
            all [x < size attempt [brd/:y/(x + 1) = state]] [ keep "R" ]
            all [y < size attempt [brd/(y + 1)/:x = state]] [ keep "D" ]
        ]
    ]
]

split-island: function [ x y ] [
    b1/:y/:x: 0    ; mark as visited    
    foreach dr get-neighbours board x y 0 [
        dirs: select directions to-get-word dr
        append free-cells-left as-pair x + dirs/x y + dirs/y 
    ] 
    foreach dr get-neighbours b1 x y 1 [
        dirs: select directions to-get-word dr
        split-island x + dirs/x y + dirs/y
    ] 
]

count-cells: func [ x y dx dy /local n ][
    n: 0
    while [ attempt [board/:y/:x = 1]][
       x: x + dx 
       y: y + dy
       n: n + 1
    ]
    n
]

shuffle-board: has [ x-one y-one x-two y-two neighbours ] [
    
    until [
        rx: random size
        ry: random size
        neighbours: get-neighbours board rx ry 1
        all [ board/:ry/:rx = 1 any [ neighbours = "LR" neighbours = "UD" ] ]
    ]

    board/:ry/:rx: 0  ; remove the selected box
    
    x-one: rx - 1 
    y-one: ry
    x-two: rx + 1
    y-two: ry
    
    if neighbours = "UD" [
        x-one: rx 
        y-one: ry - 1
        x-two: rx
        y-two: ry + 1
    ]
    
    clear head free-cells-left
    b1: copy/deep board
    split-island x-one y-one
    free-cells-right: copy free-cells-left
    clear head free-cells-left
    split-island x-two y-two
    
    new-pos: random/only next intersect free-cells-left free-cells-right
    
    board/(new-pos/2)/(new-pos/1): 1  ; update the board with the new selected cell
]

init-board: func [ x /local iter n t][

    solved: false

    size: -1 + to integer! x
    dx: W / size
    adj: z % dx
    
    iter-n/idx: 0.0

    seg-coords: copy [5x5 255x5 505x5 5x250 505x255 5x505 255x505 505x505]
    forall seg-coords [seg-coords/1: (round/to seg-coords/1 dx) + adj ]
    
    canvas/parent/color: beige - 0.10.20
    canvas/parent/text: append copy "Loop-it " to pair! x

    random/seed either empty? t: seed-field/text[now][to integer! t]
   
   
    clear head board
    clear head solution
    
    collect/into [
        repeat r size [
            keep/only collect [ 
                repeat c size [ keep 1 ]
            ]
        ]
    ] board
    
    repeat r size / 2 [
        repeat c size - 1 [
            board/(r * 2)/(c + 1): 0
        ]
    ]
    
    iter: r * c
    n: 0.0
    loop iter [ 
        shuffle-board
        n: n + 1
        iter-n/idx: n / iter
    ]

    get-the-loop
]

locate-seg: func [ofs /local n segn][
    n: 1
    foreach segment seg-zones [
         foreach [a b] segment[
            if all [ a/x <= ofs/x b/x >= ofs/x a/y <= ofs/y b/y >= ofs/y ] [
                segn: rejoin ["seg" n]
                drag: ofs
                drag-seg: segn
                drag-start: copy/part at get to word! drag-seg 2 size + 2
                forall drag-start [drag-start/1: drag-start/1 - ofs]
                return drag-seg
            ]
        ]
        n: n + 1
    ]

]

move-seg: func [ofs seg /local n p][
    if seg <> "" [
        st: to word! seg
        repeat n size + 2 [
            poke get st n + 1 drag-start/:n + ofs
        ]
    ]
]

update-seg: func[ofs seg /local p st outl bord] [
    if seg <> "" [
        p: -48 + to integer! last seg
        zones: seg-zones/:p
        
        outl: copy [-3x-3 3x3]
        bord: append/dup copy [] outl size + 1 * 2
        p: 1
        forall zones [
            zones/1: (round/to zones/1 - bord/:p + ofs - drag dx) + bord/:p + adj
            p: p + 1
        ]
        
        st: to word! seg
        repeat n size + 2 [
            p: poke get st n + 1 (round/to pick get st n + 1 dx) + adj
        ]
        drag-seg: ""
    ]    
]

view compose [
    title (append "Looper" " 8x8")

    on-create [ 
        init-board 8
        append clear canvas/draw draw-board
    ]
    
    seed-field: field 90x30 font-size 12 hint "#"
    
    style btn: base 90x30 beige font-size 12
    below across
    
    small: btn 90x30 beige font-size 12 "New" [
        init-board 8
        append clear canvas/draw draw-board
    ] on-over [small/color: small/color xor 10.10.10]
  
    info: btn "About" [
        view [
            title "About Loope"
            text {The objective is to arrange the lines in a closed loop
that covers all the dots. ^/^/Galen Ivanov, 2019
}
            button "Close" [ unview ]
        ]
    ] on-over [info/color: info/color xor 10.10.10]
    
    return below
    prog: progress 200x5 0% react [ prog/data: iter-n/idx ] 
        
    canvas: base (as-pair AW + 4 AW + 4) (beige - 0.10.20) draw [] all-over
            on-down [locate-seg event/offset]
            on-over [move-seg event/offset drag-seg]
            on-up   [update-seg event/offset drag-seg]
    

    across    
    inf: base 140x30 (beige - 0.10.20) (beige - 0.10.20) font-size 12 "Galen Ivanov 2020"
    on-over [inf/color: inf/color xor 32.24.16]
] 
