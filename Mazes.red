Red [
    Title: "Mazes"
    Author: "Galen Ivanov"
    Needs 'View
]

make-grid: function [
    rows [ integer! ]
    columns [ integer! ]
] [
    cell: make object! [
        visited?: off
        left: top: right: bottom: on
    ]

    collect/into [
        repeat r rows [
            keep/only collect [ 
                repeat c columns [ keep copy cell ]
            ]
        ]
    ] make block! rows * columns
]

draw-grid: function [
    grid [ block! ]
    x [ integer! ]
    y [ integer! ]
    size [ integer! ]
] [
    h: length? grid
    w: length? grid/1
    
   draw-block: [ pen white line-width 8 line-cap round ]
    
    collect/into [
        id-y: 0
        foreach row grid [
            id-x: 0
            foreach cell row [
                case/all [
                    cell/left   [ keep compose [ line ( as-pair id-x * size + x id-y * size + y )
                                                      ( as-pair id-x * size + x id-y + 1 * size + y ) ] ]
                    cell/top    [ keep compose [ line ( as-pair id-x * size + x id-y * size + y )
                                                      ( as-pair id-x + 1 * size + x id-y * size + y ) ] ]                     
                    cell/right  [ keep compose [ line ( as-pair id-x + 1 * size + x id-y * size + y ) 
                                                      ( as-pair id-x + 1 * size + x id-y + 1 * size + y ) ] ]
                    cell/bottom [ keep compose [ line ( as-pair id-x * size + x id-y + 1 * size + y )
                                                      ( as-pair id-x + 1 * size + x id-y + 1 * size + y ) ] ]
                ]
                id-x: id-x + 1                
            ]
            id-y: id-y + 1
        ]
    ] draw-block; line p1 p2 -> 3
]

make-maze: function [
    x [ integer! ]   
    y [ integer! ]
] [
    grid: make-grid x y
    
    grid/1/1/left: off      ; should it be dinamyc?
    grid/:y/:x/right: off   ; -||-
    
    visited: make block! x * y
    nv: 0
    px: random x
    py: random y
    
    until [
        switch random 4 [
            1 [ either all [ px > 1 not grid/:py/(px - 1)/visited? ]
                           [ nv: nv + 1 
                           grid/:py/:px/left: off
                           px: px - 1
                           grid/:py/:px/right: off
                           grid/:py/:px/visited?: on
                           append/only visited reduce [px py] ]
                           [ set [ px py ] random/only visited ] ] ; left
            2 [ either all [ py > 1 not grid/(py - 1)/:px/visited? ]
                           [ nv: nv + 1
                           grid/:py/:px/top: off
                           py: py - 1
                           grid/:py/:px/bottom: off
                           grid/:py/:px/visited?: on
                           append/only visited reduce [px py] ]
                           [ set [ px py ] random/only visited ] ]  ; up
            3 [ either all [ px < x not grid/:py/(px + 1)/visited? ]
                           [ nv: nv + 1
                           grid/:py/:px/right: off                            
                           px: px + 1
                           grid/:py/:px/left: off
                           grid/:py/:px/visited?: on
                           append/only visited reduce [px py] ]
                           [ set [ px py ] random/only visited ] ] ; right 
            4 [ either all [ py < y not grid/(py + 1)/:px/visited? ]
                           [ nv: nv + 1
                           grid/:py/:px/bottom: off
                           py: py + 1
                           grid/:py/:px/top: off
                           grid/:py/:px/visited?: on
                           append/only visited reduce [px py] ]
                           [ set [ px py ] random/only visited ] ]  ; down
        ]
        nv = (x * y)
    ]
    grid
]

random/seed now
grid: make-maze 30 30
draw-block: draw-grid grid 45 45 27 
append draw-block [ pen red box 55x55 60x60]

x: y: 1

move-square: func [ key ] [
    switch key [
        left [ if all [ x > 1 not grid/:y/:x/left ] [ x: x - 1 ] ]
        up [ if all [ y > 1 not grid/:y/:x/top ] [ y: y - 1 ] ]
        right [ if all [ x < 30 not grid/:y/:x/right ] [ x: x + 1 ] ]
        down [ if all [ y < 30 not grid/:y/:x/bottom ] [ y: y + 1 ] ]
    ]
    take/part/last draw-block 5
    append draw-block compose [ pen red box (as-pair 27 * (x - 1) + 55 27 * ( y - 1 )  + 55)
                              (as-pair 27 * (x - 1) + 61 27 * (y - 1) + 61)]
] 

view [
    title "Mazes : : Galen Ivanov "
    on-key [ clear canvas/draw move-square event/key append canvas/draw draw-block ]
    canvas: base water 900x900 draw append [] draw-block 
]


