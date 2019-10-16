local module = {}
local resetting = false
local Debris = game:GetService("Debris")
function module:reset()
	if resetting then return end
	resetting = true
	local dummy = game.Workspace.Dummy
	local starting_platform = game.Workspace.StartingPlatform
	local node_folder = game.Workspace.NodeFolder
	local maze = game.Workspace:FindFirstChild("Maze")
	local destination = game.Workspace:FindFirstChild("Destination")
	if maze then
		Debris:AddItem(maze)
	end
	if node_folder then
		node_folder:ClearAllChildren()
	end
	if destination then
		destination:Destroy()
	end
	resetting = false
end
function module:generate_maze()
	game.ServerScriptService.GenerateMaze.Disabled = false
	game.ServerScriptService.GenerateMaze.Disabled = true
end
function module:generate_destination(position)
	local part = Instance.new("Part", game.Workspace)
	part.Name = "Destination"
	part.Position = Vector3.new(-0.8, 2.5, 54.9)
end
return module
