--[[
	This script demonstrates simple pathfinding.
	https://developer.roblox.com/articles/Pathfinding
--]]

local PathfindingService = game:GetService("PathfindingService")
 
local humanoid = game.Workspace.Dummy.Humanoid
local Dummy = game.Workspace.Dummy
 --Variables to store waypoints table and zombie's current waypoint
local waypoints = nil
local currentWaypointIndex = nil
local BenchmarkModule = require(script.Parent.A_Star.benchmark_module)
local numb_of_waypoints = 0
local function followPath(destinationObject)
	if destinationObject == nil then return end -- base case, thanks Dr. Burks for CSC 212!
	numb_of_waypoints = numb_of_waypoints +1
	--Create the path object
	local path = PathfindingService:CreatePath()
	--Compute and check the path
	path:ComputeAsync(Dummy.HumanoidRootPart.Position, destinationObject.Position)
	--Empty waypoints table after each new path computation
	waypoints = {}
	--recursive function
	local function onPathBlocked(blockedWaypointIndex, point)
		--Check if the obstacle is further down the path
		if blockedWaypointIndex > currentWaypointIndex then
			-- Call function to re-compute the path
			followPath(point)
		end
	end
	local function onWaypointReached(reached)
		if reached and currentWaypointIndex < #waypoints then
			currentWaypointIndex = currentWaypointIndex + 1
			humanoid:MoveTo(waypoints[currentWaypointIndex].Position)
		end
	end
	--Connect 'Blocked' event to the 'onPathBlocked' function
	path.Blocked:Connect(onPathBlocked)
	--Connect 'MoveToFinished' event to the 'onWaypointReached' function
	humanoid.MoveToFinished:Connect(onWaypointReached)
	
	if path.Status == Enum.PathStatus.Success then
		--Get the path waypoints and start zombie walking
		waypoints = path:GetWaypoints()
		numb_of_waypoints = numb_of_waypoints + #waypoints
		for _, waypoint in pairs(waypoints) do
			local part = Instance.new("Part")
			part.Shape = "Ball"
			part.Material = "Neon"
			part.Size = Vector3.new(0.6, 0.6, 0.6)
			part.Position = waypoint.Position
			part.Anchored = true
			part.CanCollide = false
			part.Parent = game.Workspace.NodeFolder
		end
		--Move to first waypoint
		currentWaypointIndex = 1
		humanoid:MoveTo(waypoints[currentWaypointIndex].Position)
	else
		--Error (path not found); stop humanoid
		humanoid:MoveTo(Dummy.HumanoidRootPart.Position)
	end
	return true
end
	
game.ReplicatedStorage.RemoteEvent:FireAllClients()
followPath(game.Workspace.Destination)
print("Number of waypoints was.."..tostring(numb_of_waypoints))
