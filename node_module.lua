local node_module = {}
node_module.OpenSet = {start_node=nil, exit_node=nil}
node_module.ClosedSet = {}
local MinimumNodeDistance = 20
local ray_caster = require(script.Parent.ray_module)
local Front_Vector = game.Workspace.Dummy.HumanoidRootPart.CFrame.LookVector
function node_module.new()
	local node = {
		front=nil,
		back=nil, 
		left=nil, 
		right=nil,
		best_node=nil,
		g_cost=nil,
		h_cost=nil,
		f_cost=nil, 
		part=game.Workspace.NodePart:Clone()
	}
	function node:EnableBolts()
		node.part.EffectAttachment.Bolts.Enabled = true
	end
	function node:DisableBolts()
		node.part.EffectAttachment.Bolts.Enabled = false
	end
	function node:RemoveFromOpenSet()
		print("Removing node "..tostring(node).." from open set")
		node_module.OpenSet[node] = nil
	end	
	function node:IsInOpenSet()
		if node_module.OpenSet[node] then 
			return true
		else
			return false
		end
	end
	function node:GetNeighborsInOpenSet()
		local neighbors = nil
		if node.left and node.left:IsInOpenSet() then
			if not neighbors then neighbors = {} end
			neighbors.left = node.left
		end
		if node.right and node.right:IsInOpenSet() then
			if not neighbors then neighbors = {} end
			neighbors.right = node.right
		end
		if node.front and node.front:IsInOpenSet() then
			if not neighbors then neighbors = {} end
			neighbors.front = node.front
		end
		if node.back and node.back:IsInOpenSet() then
			if not neighbors then neighbors = {} end
			neighbors.back = node.back
		end
		local count = 0
		if neighbors then
			for k,v in pairs(neighbors) do
				count = count+1
			end
		end
		print(count .. " neighboring nodes in open set")
		return neighbors
	end
	-- if there are twins then an error will occur
	function node:FindBestNeighbor() 
		local neighbors = node:GetNeighborsInOpenSet()
		local count = 0
		node.best_node = nil
		if neighbors then
			for k, neighbor in pairs(neighbors) do
				if not node.best_node then node.best_node = neighbor end
				if not node.best_node:IsInOpenSet() then node.best_node = neighbor end
				if neighbor.f_cost <= node.best_node.f_cost then
					node.best_node = neighbor
				end
				count = count + 1
			end	
		end
		print("Best node was " .. tostring(node.best_node).." out of "..tostring(count).." nodes")	
		return node.best_node
	end
	function  CalcDistance(A, B)
		local dist = math.abs(A.Position.X - B.Position.X) + math.abs(A.Position.Z - B.Position.Z)
	return dist
	end
	function  node:CalcG(start_node, node)
		return CalcDistance(start_node.part, node.part)
	end
	function node:CalcH()
		return CalcDistance(node.part, node_module.OpenSet.exit_node.part)
	end
	function node:CalculateNodeCosts()
		node.g_cost = node:CalcG(node_module.OpenSet.start_node, node)
		node.h_cost = node:CalcH()
		node.f_cost = node.g_cost + node.h_cost
		node.part:FindFirstChild("BillboardGui").g_frame.g_cost.Text = "g cost: "..tostring(node.g_cost)
		node.part:FindFirstChild("BillboardGui").h_frame.h_cost.Text = "h cost: "..tostring(node.h_cost)
	end
	function TooClose(partA, partB)
		local distance = CalcDistance(partA, partB)
		if distance > MinimumNodeDistance then 
			return false 
		else
			return true
		end
	end
	function node:AppendToOpenSet()
		node_module.OpenSet[node] = node
	end
	function node:PropagateNodes()
		if node_module.OpenSet.exit_node then return end
		wait(0.1)
		local hit_parts = ray_caster.RayHitPart(node, Front_Vector)
		if hit_parts.front_hit_part  and not node.front then --front part exists
			if not hit_parts.front_hit_part.Name == "Part" then hit_parts.front_hit_part = nil end -- if true then the part is not a maze wall
			if hit_parts.front_hit_part and not TooClose(hit_parts.front_hit_part, node.part) then
				local newNode = node_module.new()
				newNode.part.Position = Vector3.new(
					node.part.Position.X,
					node.part.Position.Y,
					node.part.Position.Z+(MinimumNodeDistance))
				node.front = newNode -- for when we go through the node tree
				newNode.back = node -- for preventing double nodes
				newNode:AppendToOpenSet()
				newNode:PropagateNodes()
			end	
		elseif not hit_parts.front_hit_part and not node.front then --front part does not exist
			if hit_parts.down_hit_part then
				local newNode = node_module.new()
				newNode.part.Position = Vector3.new(
					node.part.Position.X,
					node.part.Position.Y,
					node.part.Position.Z+(MinimumNodeDistance))
				node.front = newNode -- for when we go through the node tree
				newNode.back = node -- for preventing double nodes
				newNode:AppendToOpenSet()
				newNode:PropagateNodes(newNode)
			else --this is the last node
				node_module.OpenSet.exit_node = node
			end
		end
		if hit_parts.back_hit_part then --back part exists
			if not hit_parts.back_hit_part.Name == "Part" then hit_parts.back_hit_part = nil end -- if true then the part is not a maze wall
			if hit_parts.back_hit_part and not TooClose(hit_parts.back_hit_part, node.part) and not node.back then
				local newNode = node_module.new()
				newNode.part.Position = Vector3.new(
					node.part.Position.X,
					node.part.Position.Y,
					node.part.Position.Z-(MinimumNodeDistance))
				node.back = newNode -- for when we go through the node tree
				newNode.front = node -- for preventing double nodes
				newNode:AppendToOpenSet()
				newNode:PropagateNodes(newNode)
			end
		end		
		if hit_parts.left_hit_part then --left part exists
			if not hit_parts.left_hit_part.Name == "Part" then hit_parts.left_hit_part = nil end -- if true then the part is not a maze wall
			if hit_parts.left_hit_part and not TooClose(hit_parts.left_hit_part, node.part) and not node.left then
				local newNode = node_module.new()
				newNode.part.Position = Vector3.new(
					node.part.Position.X+(MinimumNodeDistance),
					node.part.Position.Y,
					node.part.Position.Z)
				node.left = newNode -- for when we go through the node tree
				newNode.right = node -- for preventing double nodes
				newNode:AppendToOpenSet()
				newNode:PropagateNodes(newNode)
			end
		end	
		if hit_parts.right_hit_part then --left part exists
			if not hit_parts.right_hit_part.Name == "Part" then hit_parts.right_hit_part = nil end -- if true then the part is not a maze wall
			if hit_parts.right_hit_part and not TooClose(hit_parts.right_hit_part, node.part) and not node.right then
				local newNode = node_module.new()
				newNode.part.Position = Vector3.new(
					node.part.Position.X-(MinimumNodeDistance),
					node.part.Position.Y,
					node.part.Position.Z)
				node.right = newNode -- for when we go through the node tree
				newNode.left = node -- for preventing double nodes
				newNode:AppendToOpenSet()
				newNode:PropagateNodes(newNode)
			end
		end		
	end
	node.part.Parent = game.Workspace.NodeFolder
	return node
end
function node_module:PrintNodesInOpenSet()
	for key, node in pairs(node_module.OpenSet) do
		print(node)
	end
end	
function node_module:GetOpenSet()
	return node_module.OpenSet
end
return node_module
