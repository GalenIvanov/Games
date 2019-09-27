# Games

Hex-Pave
-
Hex-pave is a puzzle invented by Carl Hoff. The goal is to arrange all of the tiles flat in the hexagonal tray.

My implementation is a WIP. It need the following improvements:
  - Currently there's no collision detection and tiles can go on top of / beneath each other
  - The tiles are rendered in the order of their creation. This means that the tiles that are created earlier may stay behind the ones created later.
  - No solution detection. The player should check the solution for himself/herself. 
  
Island Alleys 
-
I logic puzzle invented by me. Connect the dots so that the resulting line goes through all the dots and forms a closed loop that do not touch/cross itself (Technically speaking this is a Hamiltonian cycle on a grid) The closed loop outlines an "island" with branching alleys and the width of the alleys is always 1 square.
The numbers are placed in the island where 2 (just a right turn), 3 (T-junction) or 4 alleys (crossroad) intersect. Furthermore, the numbers indicate the total distance to the shore in the West/North/East/South directions.

