Red [
    Title: "Izzi puzzle in Red"
    Author: "Galen Ivanov"
]

tiles: make block! 64
tiles-block: make block! 64
tiles-coords: make block! 64
grid-offs: 20x20
scheme: [sky yello]

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

arrange-tiles: has [
    n row col offs bit clr tri   
][
    n: 1
    repeat row 8 [
        repeat col 8 [
            offs: as-pair col - 1 * 40 + grid-offs/x
                          row - 1 * 40 + grid-offs/y
            bit: 1
            foreach t triangles [
                clr: pick scheme -47 + tiles/:n/:bit
                append tiles-block compose [
                    (to set-word! rejoin ["tile" n])
                    pen 255.240.120.255 fill-pen (clr)
                    polygon (t/1 + offs) (t/2 + offs) (t/3 + offs)
                    pen (sky + 10) fill-pen (sky - 10) box (offs + 360x0) (offs + 400x40)
                ]
                bit: bit + 1
            ]
            append tiles-coords offs
            n: n + 1
        ]
    ]
]

gen-tiles
arrange-tiles

view compose [
    Title "Izzi puzzle"
    base (sky - 15) 760x360 draw tiles-block
]

