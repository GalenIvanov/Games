# Games

Hex-Pave
-
<img src="Hex-Pave.png">
Hex-pave is a puzzle invented by Carl Hoff. The goal is to arrange all of the tiles flat in the hexagonal tray.

My implementation is a WIP. It need the following improvements:
  - Currently there's no collision detection and tiles can go on top of / beneath each other
  - The tiles are rendered in the order of their creation. This means that the tiles that are created earlier may stay behind the ones created later.
  - No solution detection. The player should check the solution for himself/herself. 
  
Island Alleys 
-
<img src="Island_allleys_12x12.jpg">

A logic puzzle invented by me. The objective is to connect horizontally and vertically adjacent dots by clicking between them so that the lines form a simple loop with no loose ends that goes through all the dots (so the line forms a Hamiltonian cycle on a grid).
The lines of the loop enclose an island. The island is exactly one square wide at all places, that’s why and I call the paths “alleys”. Where 2 or more alleys meet at a right angle, there is always a number indicating the total distance from that square to the shores in all directions – East, West, North and South.
[Detailed solving isntructions](https://github.com/GalenIvanov/Games/blob/master/Island%20Alleys%20-%20solving%20instructions.pdf)

