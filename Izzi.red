Red [
    Title: "Izzi puzzle in Red"
    Author: "Galen Ivanov"
    More-info: https://www.thinkfun.com/products/izzi/
    Jaaps-puzzle-page: https://www.jaapsch.net/puzzles/izzi.htm
]

random/seed now
tiles: make block! 64
tiles-block: make block! 64
tiles-coords: make map! 64
conditions: make map! 64
coord: 0x0
delta-offs: 0x0
start-offs: 0
drag: off
selected: none
start-drag: 0 ; 0 if dragging started outside grid; 1 - inside grid
end-drag: 0   ; 0 if dragging ended outside grid; 1 - inside grid
prog: 0
;scheme: [164.200.250.255 ivory]
scheme: [aqua ivory]

triangles: [
    [0x0 20x0 20x20]
    [20x0 40x0 20x20]
    [40x0 40x20 20x20]
    [40x20 40x40 20x20]
    [40x40 20x40 20x20]
    [20x40 0x40 20x20]
    [0x40 0x20 20x20]
    [0x20 0x0 20x20]
]
; conditions
RD: [2 3 6 7] ; right diagonal
LD: [1 8 4 5] ; left diagonal
H:  [3 4 7 8] ; horizontal
V:  [1 2 5 6] ; vertical
BR: [3 4 5 6] ; bottom-right corner
BL: [5 6 7 8] ; bottom-left corner
TL: [1 2 7 8] ; top-left corner
TR: [1 2 3 4] ; top-right corner

my-font: make font! [name: "Verdana" size: 30 color: snow]
about-font: make font! [name: "Verdana"  size: 10 style: 'bold]
    
set-conditions: func [
    mode
    /local n
][
    clear conditions
    switch mode [
        "Basic" []
        "Diagonal" [
            repeat n 8 [
                put conditions as-pair n * 40 + 360 8 - n * 40 + 40 RD
            ]
            append tiles-block compose [
                line-width 2 pen (khaki + 10)
                line 400x360 720x40
            ]
        ]
        "Diamond" [
            repeat n 4 [
                put conditions as-pair n * 40 + 360 4 - n * 40 + 40 RD
                put conditions as-pair n * 40 + 520 8 - n * 40 + 40 RD
                put conditions as-pair n * 40 + 360 n * 40 + 160 LD
                put conditions as-pair n * 40 + 520 n * 40 LD
            ]
            append tiles-block compose [
                line-width 2 pen (khaki + 10) fill-pen transparent
                polygon 400x200 560x40 720x200 560x360
            ]
        ]
        "X" [
            repeat n 8 [
                put conditions as-pair n * 40 + 360 8 - n * 40 + 40 RD
                put conditions as-pair n * 40 + 360 n * 40 LD
            ]
            append tiles-block compose [
                line-width 2 pen (khaki + 10)
                line 400x360 720x40
                line 400x40 720x360
            ]
        ]
        "Border" [
            put conditions 400x40 BR
            put conditions 680x40 BL
            put conditions 400x320 TR
            put conditions 680x320 TL
            repeat n 6 [
                put conditions as-pair n * 40 + 400 40 H
                put conditions as-pair n * 40 + 400 320 H
                put conditions as-pair 400 n * 40 + 40 V
                put conditions as-pair 680 n * 40 + 40 V
            ]
            append tiles-block compose [
                line-width 2 pen (khaki + 10) fill-pen transparent
                polygon 420x60 700x60 700x340 420x340
            ]
        ]
    ]
]

gen-tiles: has [
    n bin symmetrical
][
    symmetrical: make block! 300
    repeat n 256 [
        bin: take/last/part enbase/base to-binary n - 1 2 8
        unless find symmetrical bin [
            unless find [0 51 85 102 170 204 255] n - 1 [
                append tiles copy bin
            ]
            loop 4 [
               append symmetrical copy bin
               move/part bin tail bin 2
            ]
        ]
    ]
]

make-tile: function [
    n offs
][
    bit: 1
    collect/into [
        keep (to set-word! rejoin ["tile" n])
        foreach t triangles [
            clr: pick scheme -47 + tiles/:n/:bit
            keep compose [
                pen transparent fill-pen (clr)
                polygon (t/1 + offs) (t/2 + offs) (t/3 + offs)
            ]
            bit: bit + 1
        ]
    ] make block! 8
]

arrange-tiles: has [
    n row col offs
][
    append tiles-block compose [
        line-width 3
        pen (khaki + 20) fill-pen (khaki - 10)
        box 400x40 720x360
        line-width 1
    ]
    repeat n 9 [
        row: as-pair 400 40 * n
        col: as-pair 40 * n + 360 40
        append tiles-block compose [
            line (row) (row + 320x0)
            line (col) (col + 0x320)
        ]
    ]
   
    n: 1
    repeat row 8 [
        repeat col 8 [
            offs: as-pair col * 40 row * 40
            append tiles-block make-tile n offs
            put tiles-coords offs n
            n: n + 1
        ]
    ]
    
    append tiles-block [
        solved-frame: pen green
        fill-pen transparent
        box 0x0 0x0
        marker: line-width 4
        pen orange fill-pen transparent
        box 0x0 0x0
    ]
]

outside-grid?: func [offs][
    any [             ; is the tile outside the grid?
        offs/x < 400
        offs/x >= 720
        offs/y <  40
        offs/y >= 360
    ]
]

edge=: func [
    coord s1 d1 s2 d2
    /local t
][
    either all [
        not outside-grid? coord
        t: select tiles-coords coord
        t <> selected
        (tiles/:selected/:s1 <> tiles/:t/:d1)
        or (tiles/:selected/:s2 <> tiles/:t/:d2)
    ][false][true]
]

edges-match?: func [
    offs
][
    either outside-grid? offs [
        true  ; ; if yes - don't bother to match the adjacent edges
    ][
        none <> all [
            edge= offs - 0x40 1 6 2 5    ;   1 2
            edge= offs + 40x0 3 8 4 7    ;  8   3
            edge= offs + 0x40 5 2 6 1    ;  7   4
            edge= offs - 40x0 8 3 7 4    ;   6 5
        ]
    ]
]

update-coords: func [
    offs
    /local t-id start row col
][
    t-id: to word! rejoin ["tile" selected]
    start: find/tail get t-id 'polygon
    repeat row 8 [
        repeat col 3 [
            start/1: triangles/:row/:col + offs
            start: next start
        ]
        start: find/tail start 'polygon
    ]
]

move-tile: func [offs][
    ; restrain the cursor within our window
    offs: max 0x0 min 720x360 offs
    either drag [
        update-coords offs - delta-offs
    ][
        coord: round/to offs - 20 40
        unless p: select tiles-coords coord [
            coord: -40x-40
        ]
        poke marker 8 coord
        poke marker 9 coord + 40
    ]
]

start-move: func [
    offs
    /local p t-id
][
    if p: select tiles-coords coord [
        selected: p
        
        t-id: to word! rejoin ["tile" selected]
        move/part back get t-id find tiles-block solved-frame 65
        
        dragged: coord
        start-offs: round/to offs - 20 40
        start-drag: either outside-grid? start-offs [0][1]
        delta-offs: offs - start-offs
        drag: on
        poke marker 8 0x0
        poke marker 9 0x0
    ]
]

check-cond: func [
    offs
    /local n conds a b c d
][
    either conds: select conditions offs [
        set [a b c d] conds
        n: selected
        (tiles/:n/:a <> tiles/:n/:b) and (tiles/:n/:c <> tiles/:n/:d)
    ][
        true
    ]
]

update-tile: func [
    offs
    /local stop-offs tmp-offs
][
    stop-offs: start-offs
    if selected [
        tmp-offs: round/to offs - 20 40
        if  all [
            not select tiles-coords tmp-offs
            edges-match? tmp-offs
            check-cond tmp-offs
        ][
            stop-offs: tmp-offs
            ; restrain the tile within our window
            stop-offs: max 0x0 min 720x360 stop-offs
            remove/key tiles-coords dragged
            put tiles-coords stop-offs selected
        ]
        update-coords stop-offs
        drag: off
        selected: none
        end-drag: either outside-grid? stop-offs [0][1]
        prog: prog + end-drag - start-drag
        if prog = 64 [
            poke solved-frame 6 400x40
            poke solved-frame 7 720x360
        ]
    ]
]

rotate-tile: func [
   offs  dr
   /local n coord tile orig-tile
][
    coord: round/to offs - 20 40
    if n: select tiles-coords coord [
        selected: n
        tile: tiles/:n
        orig-tile: copy tile
        either dr = -1 [
            move/part at tile 7 tile 2
        ][
            move/part tile tail tile 2
        ]
        tiles/:n: tile
        either (edges-match? coord) and (check-cond coord) [
            tile: make-tile n coord
            t-id: get take tile
            change/part t-id tile length? tile
        ][
            tiles/:n: orig-tile
        ]
    ]
]

init: func [mode][
   delta-offs: 0x0
   start-offs: 0
   coord: 0x0
   drag: off
   selected: none
   start-drag: 0
   end-drag: 0
   prog: 0
   
   clear tiles
   clear head tiles-block
   clear tiles-coords
   
   gen-tiles
   random tiles
   arrange-tiles
   set-conditions mode
]
 
over-menu: func [face][
    face/color: face/color xor 127.0.63
]

confirm: func [
    caller
    /local ans
][
    caller/enabled?: false
    ans: false
    view/flags [
        Title "Attention!"
        below
        text "The current progress wiil be lost!^/Do you want to start a new game?"
        across
        button "OK" [ans: true unview]
        button "Cancel" [ans: false unview]
    ][modal no-min no-max]
    
    caller/enabled?: true
    ans
] 

info-dlg: does [
    info/enabled?: false
    view/flags [
        Title "About Izzi"
        below
        text font about-font {Izzi puzzle is designed by Frank Nichols and made in 1992
by Binary Arts (now called ThinkFun).

Put the tiles in the 8x8 grid so that the edges of each touching
tile match: white touches white and blue touches blue. Drag the tiles
with the left mouse button, rotate them using the mouse wheel. Please
note that each move whitin the grid is checked for correctness.

In addition to the basic version of the puzzle, you can try to
solve it using the extra conditions - there must be a "terminator"
(an edge between a white and a blue triangle) at all places where
there is a white line.

Galen Ivanov, 2020
}
        button "Close" [unview]
    ][modal no-max no-min]
    
    info/enabled?: true
]

init "Basic"

view compose [
    Title "Izzi puzzle"
    across
    base (khaki) 760x400 draw tiles-block
    all-over
    on-over  [move-tile event/offset]
    on-down  [start-move event/offset]
    on-up    [update-tile event/offset]
    on-wheel [rotate-tile event/offset event/picked]
    focus
    
    below
    basic: base aqua 58x58
    on-over[over-menu basic]
    on-up [if confirm basic [init "Basic"]]
    
    diag: base aqua 58x58
    draw [line-width 2 pen snow line 0x57 57x0]
    on-over[over-menu diag]
    on-up [if confirm diag [init "Diagonal"]]
    
    diam: base aqua 58x58
    draw [line-width 2 pen snow fill-pen transparent polygon 0x29 29x0 58x29 29x58]
    on-over[over-menu diam]
    on-up [if confirm diam [init "Diamond"]]
    
    cross: base aqua 58x58
    draw [line-width 2 pen snow line 0x0 57x57 0x57 57x0]
    on-over[over-menu cross]
    on-up [if confirm cross [init "x"]]
    
    frame: base aqua 58x58
    draw [line-width 2 pen snow fill-pen transparent polygon 5x5 52x5 52x52 5x52]
    on-over[over-menu frame]
    on-up [if confirm frame [init "Border"]]
    
    info: base khaki 58x60  ;219.200.128
    draw [font my-font text 18x5 "?"]
    on-over [over-menu info]
    on-up [info-dlg]
]
