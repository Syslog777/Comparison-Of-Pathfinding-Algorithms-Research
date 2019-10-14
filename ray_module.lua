local ray_module = {}
local Debris = game:GetService("Debris")
local wait_time = script.wait_time.Value
local RunService = game:GetService("RunService")
local function MakeBeamFromPosition(node, position)
	local beam = Instance.new("Part", workspace)
	beam.Name = "beam"
	beam.BrickColor = BrickColor.new("Bright red")
	beam.FormFactor = "Custom"
	beam.Material = "Neon"
	beam.Transparency = 0.25
	beam.Anchored = true
	beam.Locked = true
	beam.CanCollide = false
	local distance = (node.part.CFrame.p - position).magnitude
	beam.Size = Vector3.new(0.3, 0.3, distance)
	beam.CFrame = CFrame.new(node.part.CFrame.p, position) * CFrame.new(0, 0, -distance / 2)
	local count = 0
	RunService.Heartbeat:Wait()
	Debris:AddItem(beam, 0.1)
end
function ray_module.RayHitPart(node, front_vector) --[[https://developer.roblox.com/articles/Making-a-ray-casting-laser-gun-in-Roblox]]--
	local rays = {}
	local multiplier = 200
	local back_vector =  Vector3.new(front_vector.X, front_vector.Y, -1)
	local left_vector = Vector3.new(1, front_vector.Y, 0)
	local right_vector = Vector3.new(-1, front_vector.Y, 0)
	local down_vector = Vector3.new(0,-1,0)
	rays.left_ray = Ray.new(node.part.Position, left_vector*multiplier)
	rays.back_ray = Ray.new(node.part.Position, back_vector*multiplier)
	rays.right_ray = Ray.new(node.part.Position, right_vector*multiplier)
	rays.front_ray = Ray.new(node.part.Position, front_vector*multiplier)
	rays.down_ray = Ray.new(node.part.Position, down_vector*multiplier)
	local front_hit_part = nil
	local back_hit_part = nil
	local left_hit_part = nil
	local right_hit_part = nil
	local down_hit_part = nil
	if rays.front_ray then
		local position = nil
		front_hit_part, position = workspace:FindPartOnRay(rays.front_ray, node.part, false, true) -- if nil then thats the exit
		MakeBeamFromPosition(node,position)
		if front_hit_part then front_hit_part.Material = Enum.Material.Grass end
	end
	if rays.back_ray then
		local position = nil
		back_hit_part, position = workspace:FindPartOnRay(rays.back_ray, node.part, false, true) -- if nil then thats the start
		MakeBeamFromPosition(node,position)
		if back_hit_part then back_hit_part.Material = Enum.Material.Grass end
	end
	if rays.left_ray then
		local position = nil
		left_hit_part, position = workspace:FindPartOnRay(rays.left_ray, node.part, false, true)
		MakeBeamFromPosition(node,position)
		if left_hit_part then left_hit_part.Material = Enum.Material.Grass end
	end
	if rays.right_ray then
		local position = nil
		right_hit_part, position = workspace:FindPartOnRay(rays.right_ray, node.part, false, true)
		MakeBeamFromPosition(node,position)
		if right_hit_part then right_hit_part.Material = Enum.Material.Grass end
	end
	if rays.down_ray then
		local position = nil
		down_hit_part, position = workspace:FindPartOnRay(rays.down_ray, node.part, false, true)
		MakeBeamFromPosition(node, position)
		if down_hit_part then down_hit_part.Material = Enum.Material.Grass end
	end
	return {
		front_hit_part=front_hit_part,
		back_hit_part=back_hit_part,
		left_hit_part=left_hit_part,
		right_hit_part=right_hit_part,
		down_hit_part=down_hit_part
		}
end
return ray_module
