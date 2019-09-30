Red[
    Title: "Island Alleys - a logic game"
    Author: "Galen Ivanov"
    Date: 30-Sep-2019
    needs: 'View
]

random/seed now

buffer: make block! 5000
board: make block! 10000
b1: make block! 10000
free-cells-left: make block! 10000
free-cells-right: make block! 10000
edges: make block! 1000
edges-str: make block! 1000
labels: make block! 1000
solution: make block! 1000

W: 500
size: 7
rx: ry: 0
dx: W / 8
z: 2 ; ofsset from the topleft corner

iter-n: make reactor! [idx: 0]

directions: [L: -1x0 U: 0x-1 R: 1x0 D: 0x1]

solved: false

draw-board: has [ a b r c offsx offsy ][
       
    num-font: make object! [
        name: "Verdana"
        size: 18
        style: "bold"
        angle: 0
        color: black
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
        if solved [ 
        keep [ pen beige fill-pen beige ]
            repeat r size [
                repeat c size [
                    if board/:r/:c = 1 [keep compose [ box (as-pair c - 1 * dx + z r - 1 * dx + z)
                                                           (as-pair c * dx + z r * dx + z)]]
                ]
            ]
        ]
        ; dots
        keep [ pen black fill-pen black ]
        repeat r size [
            repeat c size [
                keep compose [ box (as-pair c - 1 * dx - 2 + z  r - 1 * dx - 2 + z)
                                   (as-pair c - 1 * dx + 2 + z  r - 1 * dx + 2 + z)
                               box (as-pair c     * dx - 2 + z  r - 1 * dx - 2 + z)
                                   (as-pair c     * dx + 2 + z  r - 1 * dx + 2 + z)
                               box (as-pair c - 1 * dx - 2 + z  r     * dx - 2 + z)
                                   (as-pair c - 1 * dx + 2 + z  r     * dx + 2 + z)
                               box (as-pair c     * dx - 2 + z  r     * dx - 2 + z)
                                   (as-pair c     * dx + 2 + z  r     * dx + 2 + z)                                      
                ]
            ]
        ]
        ; labels
        keep [font num-font]
        foreach [x y n] labels [
            n: to string! n
            offsx: dx - ( num-font/size * length? n ) / 2
            keep compose [text (as-pair x - 1 * dx + offsx + z y - 1 * dx + offsy  + z) (n)] 
        ]
        keep [ line-width 3 ] ; for the edges
    ] buffer
]

get-the-loop: has [ x y border a b c d x1 y1 x2 y2 ][
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
                        keep form compose [ 
                            line (as-pair x1 + z y1 + z) (as-pair x2 + z y2 + z)
                        ]
                    ]
                ]
            ]
        ]
    ] solution
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

calc-dist: func [][
    collect/into [
        repeat r size [
            repeat c size [
                dist: 0
                if board/:r/:c = 1 [
                    LURD: get-neighbours board c r 1
                    if (LURD <> "LR") and (LURD <> "UD") and (1 < length? LURD)[  ; there is a turn
                        foreach dd LURD [
                            dirs: select directions to-get-word dd
                            dist: dist + count-cells c r dirs/x dirs/y
                        ] 
                        keep reduce [c r dist - length? LURD]  ;;;;
                    ]
                ]
            ]
        ]    
    ] labels
]

draw-edge: func [ 
    offset 
    /local x y x1 y1 x2 y2 a b c d
    line-block
] [
    cell-coords: offset / (W / size)
    in-cell-offs: (absolute offset) % (W / size)
    x: in-cell-offs/x
    y: in-cell-offs/y
    
    line-block: copy [ line ]
    
    edge: (pick [1 2] x > y) * (pick [3 4] x + y < dx)
    set [a b c d] select [ 3 [0 0 1 0]
                           4 [1 0 1 1]
                           6 [0 0 0 1] 
                           8 [0 1 1 1] ] edge
    x1: cell-coords/x + a * dx  + z
    y1: cell-coords/y + b * dx  + z
    x2: cell-coords/x + c * dx  + z
    y2: cell-coords/y + d * dx  + z
       
    append line-block reduce [ as-pair x1 y1 as-pair x2 y2 ]
    alter edges reduce [ line-block ]
    alter edges-str form reduce [ line-block ]
    append clear canvas/draw append draw-board edges
    
    if empty? difference solution edges-str [
        solved: true
        append clear canvas/draw append draw-board edges  ; to see the island 
    ]
]

init-board: func [ x /local iter n ][
    
    canvas/parent/text: append copy "Island Alleys " to string! to pair! x
   
    solved: false

    size: -1 + to integer! x
    dx: W / size
    
    iter-n/idx: 0.0
    
    clear head board
    clear head solution
    clear head edges
    clear head edges-str
    
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
    
    clear head labels
    calc-dist
    clear head edges
    get-the-loop
]

view compose [
    title (append "Island Alleys" " 8x8")
    
    on-create [ 
        init-board 8
        append clear canvas/draw draw-board
    ]
    
    style btn: button 115x45 font-size 12
    below across
    
    small: btn "8x8" [
        init-board 8
        append clear canvas/draw draw-board
    ]
    medium: btn"12x12" [
        init-board 12
        append clear canvas/draw draw-board
    ] 
    large: btn "16x16" [
        init-board 16
        append clear canvas/draw draw-board
    ]
    info: btn "About" [
        view [
            title "About Island Alleys"
            text {The objective is to connect horizontally and vertically adjacent dots
by clicking between them so that the lines form a simple loop - 
with no loose ends - that goes through all the dots (technically speaking
the line forms a Hamiltonian cycle on a grid).
The lines of the loop enclose an island. The island is exactly one square
wide at all places, that’s why and I call the paths “alleys”. Where two
or more alleys meet at a right angle, there is always a number indicating
the total distance from that square to the shores in all directions: 
East, West, North and South. Use these numbers to reconstruct the shape
of the entire island. No guessing is needed, only logic.^/^/Galen Ivanov, 2019
}
            button "Close" [ unview ]
        ]
    ]
    return below
    prog: progress 500x5 0% react [ prog/data: iter-n/idx ] 
    pad 0x10   
    canvas: base (as-pair W + 6 W + 6) snow draw [] all-over
    on-up [ if not solved [draw-edge event/offset] ]
] 
