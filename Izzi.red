Red [
    Title: "Izzi puzzle in Red"
    Author: "Galen Ivanov"
]

tiles: make block! 64
tiles-block: make block! 64
tiles-coords: make block! 64
grid-offs: 40x40
scheme: [sky beige]

selected: 0

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
     foreach t triangles [
      clr: pick scheme -47 + tiles/:n/:bit
      keep compose [
       (to set-word! rejoin ["tile" n])
       pen 255.240.120.255 fill-pen (clr)
       polygon (t/1 + offs) (t/2 + offs) (t/3 + offs)
       pen (sky + 10) fill-pen (sky - 10) box (offs + 360x0) (offs + 400x40)
      ]
      bit: bit + 1
  ]
 ] make block! 8
]

arrange-tiles: has [
    n row col offs   
][
    n: 1
    repeat row 8 [
        repeat col 8 [
            offs: as-pair col - 1 * 40 + grid-offs/x
                          row - 1 * 40 + grid-offs/y
   append tiles-block make-tile n offs
            append tiles-coords offs
            n: n + 1
        ]
    ]
]

get-tile: function [ offs ] [
    if p: find tiles-coords round/to offs - 20 40 [
     poke marker 8 p/1
     poke marker 9 p/1 + 40
  selected: index? p
 ]
]

gen-tiles
arrange-tiles

append tiles-block [marker: line-width 2 pen orange fill-pen transparent box 0x0 0x0 ]

view compose [
    Title "Izzi puzzle"
    base (sky - 15) 800x400 draw tiles-block
 all-over
 on-over [ get-tile event/offset]
]

