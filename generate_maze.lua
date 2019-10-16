--[[
Fungalmungal's Maze Generator

This generator uses a depth-first search algorithm to randomly generate a maze. 
All parts of any maze generated with this script will be accessible, and it will always be possible to reach
any position in the maze from any other position (of course, it won't necessarily be easy).

The function for generating the maze, which I have named "Build" accepts seven arguments, in the following order:

1. Complexity along the X-axis (must be a positive integer): The higher this number, the thinner the passageways of the maze will be along the 
X-axis. This means that there will be more such passageways, making for a more complex maze.

2. Complexity along the Z-axis (must be a positive integer).

3. Position: This Vector3 value determines the position that the maze will be centered at.

4. Size: This Vector3 value determines the overall size of the maze.

5. Thickness: This number determines the thickness of the maze's walls and, if present, floor and ceiling.

6. Floor and ceiling: This number determines whether the maze will have a floor or ceiling. A value of 0 results
in the maze having neither a floor nor a ceiling. 1 results in the maze having only a floor. 2 results in the maze having
both a floor and a ceiling.

7. Openings: This determines if the maze will have an entrance and exit. If it is a value other than false, the maze will have
an entrance and exit, at opposite ends of the maze, in the middle of the x-axis-aligned walls. If a value is not provided, or it is false
or nil, no entrance and exit will be provided. As all parts of the maze are accessible, however, deleting any portion of the maze's external
wall will form a valid entrance or exit. Given any two openings you make in the maze, it will always be possible to reach one
from the other.

Generating a maze will take some time, depending on the maze's complexity. Do not move or otherwise disturb the maze
while it is being built, or the end result will not be correct.

Feel free to examine and tinker with the code. Please, however, give credit if you modify or use this script in your place.
]]
function Gen(Size, Yes)
local S1 = Size[1]
local S2 = Size[2]
local Map = {}
local Count = 1
local Stack = {}
local Nav = {{1,0},{0,-1},{-1,0},{0,1}}
	for i = 1, S1 do
	Map[i] = {}
		for j = 1, S2 do
		Map[i][j] = {true,true,true,true,false}
		end
	end
	if Yes then
	Map[1][math.floor(S2/2)][3] = false
	Map[S1][math.ceil(S2/2)][1] = false
	end
local Current = {math.random(1, S1), math.random(1, S2)}
Stack[1] = Current
	repeat
	local C1 = Current[1]
	local C2 = Current[2]
	local Cell = Map[C1][C2]
	local Next = {}
	Cell[5] = true
		for i, v in pairs(Nav) do
		local N1 = C1 + Nav[i][1]
		local N2 = C2 + Nav[i][2]
		local Nt = Map[N1]
			if Nt then
			local Nc = Nt[N2]
				if Nc and not Nc[5] then 
				table.insert(Next, {N1, N2, i})
					if Cell[i] then
					local Num = (i + 2) % 4
					Map[N1][N2][Num] = false
					end
				end
			end
		end
		if #Next > 0 then
		Count = Count + 1
		table.insert(Stack, Current)
		local Select = Next[math.random(1, #Next)]
		local Num = (Select[3] + 2) % 4
			if Num == 0 then
			Num = 4
			end
		Cell[Select[3]] = false
		local Ncell = Map[Select[1]][Select[2]]
		Current = {Select[1], Select[2]}
		Ncell[Num] = false
		else
		table.remove(Stack, #Stack)
		Current = Stack[#Stack]
		end
	until Count >= S1 * S2
return Map
end
function Build(X,Z, Pos, Size, Thickness, Floor,Exit)
local Size = Size - Vector3.new(Thickness, Thickness, Thickness)
local Mo = Instance.new("Model")
Mo.Name = "Maze"
Mo.Parent = workspace
local M = Gen({Z,X},Exit)
	for i, v in pairs(M) do
		for j, w in pairs(v) do
			for k = 1, 4 do		
				if w[k] then
				local Dist
				local S
					if k % 2 == 0 then
					S = Size.z/Z + Thickness
					Dist = Size.x/X/2
					else
					S = Size.x/X + Thickness
					Dist = Size.z/Z/2
					end
				local P = Instance.new("Part")
				P.FormFactor = 0
				P.Size = Vector3.new(S, Size.y, Thickness)
				P.CFrame = CFrame.new(Pos + Vector3.new(Size.x/X * (j - X/2 - .5),0,Size.z/Z * (i - Z/2 - .5))) * (CFrame.Angles(0, -(k-1 )* math.pi/2,0) * CFrame.new(0,0,Dist ))
				P.Anchored = true
				P.TopSurface = 0
				P.BottomSurface = 0
				P.Parent = Mo
				wait()
				end
			end
			for l = 1, Floor do
			local P = Instance.new("Part")
			P.FormFactor = 0
			P.Size = Vector3.new(Size.x/X + Thickness, Thickness, Size.z/Z + Thickness)
			P.CFrame = CFrame.new(Pos + Vector3.new(Size.x/X * (j - X/2 - .5),0,Size.z/Z * (i - Z/2 - .5))) + Vector3.new(0, (Size.y)/2 * (-1) ^ l,0)
			P.TopSurface = 0
			P.BottomSurface = 0
			P.Anchored = true
			P.Parent = Mo
			end
		end
	end
end 

Build(5,5,Vector3.new(0,10,0), Vector3.new(100,15,100),2,1,true)
