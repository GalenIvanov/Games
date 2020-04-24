Red [
    Title: "Izzi puzzle in Red"
    Author: "Galen Ivanov"
]

tiles: make block! 64
tiles-block: make block! 64
tiles-coords: make map! 64
grid-offs: 40x40

start-offs: 0
drag: off

scheme: [164.200.250.255 beige]

selected: none

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
    n
    offs
][
    bit: 1
    collect/into [
        keep (to set-word! rejoin ["tile" n])    
        foreach t triangles [
            clr: pick scheme -47 + tiles/:n/:bit
            keep compose [
                pen 255.240.120.230 fill-pen (clr)
                polygon (t/1 + offs) (t/2 + offs) (t/3 + offs)
            ]
            bit: bit + 1
        ]
    ] make block! 8
]

arrange-tiles: has [
    n row col offs   
][
    ; grid
    repeat row 8 [
        repeat col 8 [
            offs: as-pair col - 1 * 40 + grid-offs/x
                          row - 1 * 40 + grid-offs/y
            append tiles-block compose [
                pen (sky + 10)
                fill-pen (sky - 10)
                box (offs + 360x0) (offs + 400x40)
            ]    
        ]    
    ]
    ; tiles
    n: 1    
    repeat row 8 [
        repeat col 8 [
            offs: as-pair col - 1 * 40 + grid-offs/x
                          row - 1 * 40 + grid-offs/y
            append tiles-block make-tile n offs
            put tiles-coords offs n
            n: n + 1
        ]
    ]
]

move-tile: func [ offs ] [
    ; restrain the cursor within our window
    offs/x: max offs/x 0
    offs/x: min offs/x 760
    offs/y: max offs/y 0
    offs/y: min offs/y 360
    
    either drag [
        ; to be moved in a function
        t-id: to word! rejoin ["tile" selected]
        start: find/tail get t-id 'polygon
        repeat row 8 [
            repeat col 3 [
                start/1: triangles/:row/:col + offs
                start: next start
            ]
            start: find/tail start 'polygon
        ]
    ][
        coord: round/to offs - 20 40 
        unless p: select tiles-coords coord [
            coord: -40x-40
        ]    
         poke marker 8 coord
         poke marker 9 coord + 40
    ]
]

start-move: func [ offs ][
    if p: select tiles-coords coord [
        dragged: coord
        selected: p
        start-offs: round/to offs - 20 40
        drag: on
    ]
]

update-tile: func [ 
    offs
    /local stop-offs tmp-offs t-id start row col
][
    stop-offs: start-offs
    if selected [
        tmp-offs: round/to offs - 20 40
        if not select tiles-coords tmp-offs [
            stop-offs: tmp-offs
            ; restrain the tile within our window
            stop-offs/x: max stop-offs/x 0
            stop-offs/x: min stop-offs/x 760
            stop-offs/y: max stop-offs/y 0
            stop-offs/y: min stop-offs/y 360
            remove/key tiles-coords dragged
            put tiles-coords stop-offs selected
        ]
        
        ; to be moved in a function !
        t-id: to word! rejoin ["tile" selected]
        start: find/tail get t-id 'polygon
        repeat row 8 [
            repeat col 3 [
                start/1: triangles/:row/:col + stop-offs
                start: next start
            ]
            start: find/tail start 'polygon
        ]
        
        drag: off
        selected: none
    ]    
]

rotate-tile: func [
   offs  dr
   /local n coord tile t-id
][
    coord: round/to offs - 20 40
    if n: select tiles-coords coord [
        tile: tiles/:n
        either dr = -1 [
            move/part at tile 7 tile 2
        ][
            move/part tile tail tile 2
        ]
        tiles/:n: tile
        tile: make-tile n round/to offs - 20 40
        t-id: get take tile
        change/part t-id tile length? tile
    ]
]

gen-tiles
arrange-tiles
append tiles-block [ marker: line-width 3
    pen orange fill-pen transparent
    box 0x0 0x0
]

view compose [
    Title "Izzi puzzle"
    base (sky - 15) 800x400 draw tiles-block
    all-over
    on-over [move-tile event/offset]
    on-down [start-move event/offset]
    on-up [update-tile event/offset]
    on-wheel [rotate-tile event/offset event/picked]
    focus
]
