Red[
    Title: "Looper - a logic game"
    Author: "Galen Ivanov"
    Date: 13-01-2020
    needs: View
]

random/seed now

buffer: make block! 5000
board: make block! 5000
b1: make block! 0000
free-cells-left: make block! 5000
free-cells-right: make block! 5000
solution: make block! 1000
border-loop: make block! 1000
segments: make block! 1000
seg-coords: make block! 8
segs: make block! 1000
centers-ofs: make block! [0 0 0 0 0 0 0 0 ]
seg-zones: make block! 64
init-angles: copy [0 0 0 0 0 0 0 0]

occupied-dots: copy #()

AW: 800    ; size of the active area
W: 220     ; size of the grid in pixels
size: 7    ; size of the grid - rows and columns - boxes, not points!
rx: ry: 0
dx: 0 
z: AW - W / 2       ; ofsset from the topleft corner of the active area to the dots area
adj: 0x0

;start-border: 0

directions: [L: -1x0 U: 0x-1 R: 1x0 D: 0x1]

solved: false
rotated: 0
flipped: 0
about-open: 1

drag-seg: ""
drag-start: 0x0
drag: 0x0

draw-board: has [ a b r c offsx offsy ][
       
    num-font: make object! [
        name: "Wingdings 3"
        size: 50
        style: "bold"
        angle: 0
        color: beige + 10.10.10 
        anti-alias?: true
        shadow: none
        state: none
        parent: none
    ]

    offsy: dx - num-font/size / 3
    
    clear buffer
 
    collect/into [
        ; the island itself
        ;if solved [ 
        keep [ pen beige fill-pen beige ]
            repeat r size [
                repeat c size [
                    if board/:r/:c = 1 [keep compose [ box (as-pair c - 1 * dx + z r - 1 * dx + z)
                                                           (as-pair c * dx + z r * dx + z)]]
                ]
            ]
        ;]
    
       ; flip / rotate buttons
        keep [font num-font]
        keep [flip-btn: text 260x720 "2"]
        keep [rot-btn: text 510x720 "Q"]
        
        keep [pen white fill-pen white]
        
        ; dots       
        repeat r size [
            repeat c size [
                keep compose [
                    circle (as-pair c - 1 * dx + z  r - 1 * dx + z) 4
                    circle (as-pair c     * dx + z  r - 1 * dx + z) 4
                    circle (as-pair c - 1 * dx + z  r     * dx + z) 4
                    circle (as-pair c     * dx + z  r     * dx + z) 4
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
        keep [line-cap round line-join round ]
        keep segs   ; the cut segments
        
        
    ] buffer
    
    
]

check-dots: func [
    /local
    x y coord dot
][
    repeat y 8 [
        repeat x 8 [
            coord: as-pair x - 1 * 31 + 290 y - 1 * 31 + 290
            dot: select occupied-dots coord
            if (dot = none) or (dot <> 1) [
                return false
            ]
        ]
    ]
    true
]

write-to-dot-map: func[
    segn
    
    /local
    dot-key
    dot-weights
    st
    n
][
    dot-weights: copy [0.5 1 1 1 1 1 1 1 0.5]
    st: to word! segn

    repeat n size + 2 [
            dot-key: pick get st n + 1
            either select occupied-dots dot-key [
                put occupied-dots dot-key (select occupied-dots dot-key) + dot-weights/:n
            ][
                put occupied-dots dot-key dot-weights/:n
            ]
            
        ]
        
]

make-zones: func[
    n seg
    
    /local
    n-rects
    p1 p2    
    start
][
    start: seg
    change/only at seg-zones n collect [     ; for detection of the segment zones by the mouse events
        n-rects: size + 1
        loop size + 2 [                
            if n-rects > 0 [
                p1: start/1
                p2: start/2
                if (p1/x > p2/x) or (p1/y > p2/y) [
                    p1: start/2
                    p2: start/1
                ]
                keep p1 - 6 ;3x3
                keep p2 + 6 ;3x3
                n-rects: n-rects - 1
            ]
            start: next start
        ]
    ]
]

dir-to-rel-coords: func [
    n
    init 
    
    /local
    ang
    x y
    minx miny maxx maxy
    n-rects p1 p2
    segs
    ofs
][
    segs: copy []
    collect/into [
        ang: init-angles/:n   ; should be loaded from the list of starting angles
        x: y: 0
        minx: miny: maxx: maxy: 0
        
        angs: copy/part at segments size + 1 * (n - 1) + 1 size + 1
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
    ] segs
        
    centers-ofs/:n: as-pair (size + 1) / 2.0 - (absolute (maxx - minx) / 2.0) - minx
                           (size + 1) / 2.0 - (absolute (maxy - miny) / 2.0) - miny
                                     
    seg-coords/:n: (round/to size + 2 / 2.0 * dx + seg-coords/:n + centers-ofs/:n dx) + adj
    
  
    if init = 1 [           ; arrange the segments in their starting positions
        start: at segs 3
        loop size + 2 [
            start/1: start/1 + seg-coords/:n
            start: next start
        ]
        make-zones n at segs 3   
    ] 
    
    segs
]

reverse-seg: func[
    n
    /local
    angs
][
    angs: copy/part at segments size + 1 * (n - 1) + 1 size + 1
    forall angs [angs/1: -1 * angs/1]  ; 0 -> 0; -90 -> 90; 90 -> -90
    change/part at segments size + 1 * (n - 1) + 1 angs size + 1
]

cut-segments: func [
    seg
    /local
    n 
][
    clear segs
    seg-zones: copy [0 0 0 0 0 0 0 0]
    
    repeat n size + 1 [
        if 50 < random 100 [ reverse-seg n ]
    ]
    
    collect/into [                            
        keep [line-width 9 line-color: pen white]
        repeat n size + 1 [ keep dir-to-rel-coords n 1 ]  
    ] segs
    
]

get-dirs: func[borders /local ang ang-inc x y][
    clear segments
    insert borders last borders    
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
        ] 
    ] segments
    
    cut-segments segments
]

build-loop: func[solution /local s p1 p2][
    s: (random ((length? solution) - 1)) / 3
    s: s * 3 + 1
    
    ; for visualization of the starting point
    rx: solution/:s/1 
    ry: solution/:s/2
   
    clear border-loop  
        
    p1: solution/:s
    collect/into [
        until [
            p2: take/part find/skip solution p1 3 3
            keep last p2
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
                    ]
                ]
            ]
        ]
    ] solution
    
    build-loop solution
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

init-board: func [ x /local n t][

    solved: false

    size: -1 + to integer! x
    dx: W / size
    adj: z % dx
    
    seg-coords: random copy [5x5 255x5 505x5 5x250 505x255 5x505 255x505 505x505]

    canvas/parent/color: beige - 0.10.20
    canvas/parent/text: append copy "Looper " to pair! x

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
    loop iter [ 
        shuffle-board
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

move-seg: func [ofs seg /local st n p rot][
    if seg <> "" [
    
        ofs/x: max 20 ofs/x
        ofs/x: min AW - 20 ofs/x
        ofs/y: max 20 ofs/y
        ofs/y: min AW - 20 ofs/y
        
        st: to word! seg
        p: -48 + to integer! last seg
        
        ; rotate 
        if all [rotated = 0 ofs/x >= 500 ofs/x <= 570 ofs/y > 720 ofs/y < 790] [        
            init-angles/:p: init-angles/:p + 90 % 360
            drag-start: at dir-to-rel-coords p 0 3
            rotated: 1
            rot-btn/3: ""
        ] 
        
        ; deactivate the rotation button
        if any [ofs/x < 500 ofs/x > 570 ofs/y < 720 ofs/y > 790] [        
            rot-btn/3: "Q"
            rotated: 0
        ]
        
        ; flip
        if all[flipped = 0 ofs/x >= 260 ofs/x <= 330 ofs/y > 720 ofs/y < 790] [        
            reverse-seg p 0
            drag-start: at dir-to-rel-coords p 0 3
            flipped: 1
            flip-btn/3: ""
            
            ;line-color/2: yello
        ]   

        if any [ofs/x < 260 ofs/x > 330 ofs/y < 720 ofs/y > 790] [        
            flip-btn/3: "2"
            flipped: 0
        ]        
            
        repeat n size + 2 [
            poke get st n + 1 drag-start/:n + ofs
        ]
    ]
]

update-seg: func[ofs seg /local p st n] [
    if seg <> "" [
        p: -48 + to integer! last seg
        
        st: to word! seg
        repeat n size + 2 [
            poke get st n + 1 (round/to (pick get st n + 1) - (dx / 2.0) dx) + adj
            ;print [n "->" pick get st n + 1]
        ]
        
        write-to-dot-map seg
        
        drag-seg: ""
        make-zones p copy/part at get st 2 size + 2
        
        if check-dots [line-color/2: yello]
    ]
    rotated: 0
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
  
    info: btn "About" on-up [ 
        if about-open = 1 [
            about-open: 0
            view [
                title "About Looper"
                text {The objective is to arrange the lines in a simple loop
that covers all the dots. ^/^/Galen Ivanov, 2020
}
                button "Close" [ about-open: 1 unview ]
            ]
        ]    
    ] on-over [info/color: info/color xor 10.10.10]
    
    return below
        
    canvas: base (as-pair AW + 4 AW + 4) (beige - 0.10.20) draw [] all-over
            on-down [locate-seg event/offset]
            on-over [move-seg event/offset drag-seg]
            on-up   [update-seg event/offset drag-seg]
] 
