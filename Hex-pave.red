Red [
    Title: "Hex-pave - a simulation of a puzzle by Carl Hoff"
    Author: "Galen Ivanov"
    Date:   19-Mar-2019
    needs: 'View
]

STEP: 29
DIST: to-integer 0.866 * STEP
H: 600

hexagon-tray: does [
    angle: 0
    collect [
        keep compose [fill-pen (aqua + 32.32.32) pen aqua polygon]
        loop 6 [
            keep as-pair H / 2 + ((8 * STEP - 1) * cosine angle) 
                         H / 2 - ((8 * STEP - 1) * sine angle)
            angle: angle + 60
        ]
        keep compose [line-width 1 pen aqua ] 
        loop 3 [
            keep compose [rotate 60 (as-pair H / 2 H / 2)]
            repeat n H / DIST [
                keep compose [line (as-pair 0 n * DIST ) (as-pair H N * DIST)]        
            ]
        ]
    ]
]

make-hexagon: function[spec][
    lengths: copy spec/1
    x: STEP * 2
    y: 0
    angle: 0

    move/part lengths tail lengths spec/3
        
    collect/into [
        keep compose[fill-pen (do spec/2) line-width 1 pen aqua polygon (as-pair x y)]
        foreach c lengths [
            loop do form c [
                x: (cosine angle) * STEP + x
                y: 0 - ((sine angle) * STEP) + y
                keep as-pair x y
            ]
            angle: angle - 60
        ] 
    ] make block! 100
]

snap: function [pos s][
    pos/y: DIST / 2 + pos/y / DIST * DIST + (s - DIST * 2) + 1
    offs: either 9 = (pos/y % (2 * DIST))[s - DIST * 2 + 2][2 - s + DIST * 2]
    pos/x: s / 2 + pos/x / s * s - offs + 1
    if pos/x < 0 [ pos/x: 0]
    if pos/y < 0 [ pos/y: 10]
    if pos/x > 550 [ pos/x: 550]
    if pos/y > 550 [ pos/y: 550]
    as-pair pos/x pos/y
]

set-pos: function [n][
    pick [237x34  368x209  63x334  92x184 136x109
          353x384  63x234 281x409 281x209 223x109
          281x109 252x309 368x259 150x234 136x359] n
]

rotate-hex: function [hex][hex: hex + 1 % 6]

hex1:  make-hexagon hx1:  ["111111" [papaya] 0]
hex2:  make-hexagon hx2:  ["211211" [sky]    0]
hex3:  make-hexagon hx3:  ["121212" [yello]  1]
hex4:  make-hexagon hx4:  ["311311" [sky]  0]
hex5:  make-hexagon hx5:  ["212212" [mint]  0]
hex6:  make-hexagon hx6:  ["221312" [tanned] 1]
hex7:  make-hexagon hx7:  ["321321" [pink]   1]
hex8:  make-hexagon hx8:  ["131313" [yello]   0]
hex9:  make-hexagon hx9:  ["222222" [papaya] 0] 
hex10: make-hexagon hx10: ["132223" [tanned] 0]
hex11: make-hexagon hx11: ["331331" [mint]   0]
hex12: make-hexagon hx12: ["322322" [sky] 0]
hex13: make-hexagon hx13: ["232323" [yello]  1]
hex14: make-hexagon hx14: ["323323" [mint]    0]
hex15: make-hexagon hx15: ["333333" [papaya]  1]

view-block: [ 
    title "Hex Pave"
    base 600x600 aqua draw hexagon-tray
    style b: base 600x20 transparent linen font-size 11 
    at 10x530 b aqua "Rearrange the tiles so that all of them lie in the hexagonal tray without overlapping"
    at 10x550 b aqua "Use the right mouse button to rotate a tile; click the middle one to flip it"
    at 10x570 b water "A puzzle by Carl Hoff. Programmed in Red by Galen Ivanov"
]

append view-block collect[
    keep 'below
    repeat n 15 [
        p: rejoin ["r" n]
        t: compose[(to word! p) offset]
        rn: to path! compose [(to word! p) parent pane]
        n-draw: to path! compose [(to word! p) draw]
        hx: rejoin ["hx" n]
        hxn1: reduce [to word! hx 1]
        hxn3: reduce [to word! hx 3]
        
        keep 'at keep set-pos n        
        keep compose/deep [
            (r: to-set-word p) base 190x151 transparent loose 
            draw (to-get-word rejoin ["hex" n])
            on-down [move find (rn) (to word! p) tail (rn)]
            on-up [(to-set-path t) snap (to-get-path t) STEP]
            on-alt-up [(to-set-path hxn3) rotate-hex (to-get-path hxn3)
                       move find (rn) (to word! p) tail (rn)
                       clear (n-draw) append (n-draw) make-hexagon (to word! hx)
            ]
            on-mid-up [reverse (to-get-path hxn1)
                       move find (rn) (to word! p) tail (rn)
                       clear (n-draw) append (n-draw) make-hexagon (to word! hx)
                       
            ]            
       ]
    ]
    
]

view view-block
