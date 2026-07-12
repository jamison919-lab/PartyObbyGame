--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Modules.TowerJumpConfig)

local world = workspace:WaitForChild("PartyObbyWorld")
local towerMaps = world:WaitForChild("TowerMaps")
local tower = towerMaps:WaitForChild("Tower02")
local floors = tower:WaitForChild("Floors")

local start = tower:WaitForChild("TowerStart") :: BasePart
start.Size = Vector3.new(18, start.Size.Y, 18)
start:SetAttribute("IsTowerPlatform", true)
tower:SetAttribute("MapVersion", 2)

local function addNode(folder: Folder, order: number, target: BasePart)
	local node = Instance.new("Part")
	node.Name = string.format("JumpNode%02d", order)
	node.Size = Vector3.new(1, 1, 1)
	node.Position = target.Position + Vector3.new(0, target.Size.Y * 0.5 + 0.5, 0)
	node.Anchored = true
	node.CanCollide = false
	node.CanQuery = false
	node.CanTouch = false
	node.Transparency = 1
	node:SetAttribute("JumpOrder", order)
	node:SetAttribute("RequiredPath", true)
	node.Parent = folder
	local targetValue = Instance.new("ObjectValue")
	targetValue.Name = "TargetPlatform"
	targetValue.Value = target
	targetValue.Parent = node
end

for floorIndex = 1, 12 do
	local floor = floors:WaitForChild(string.format("Floor%02d", floorIndex)) :: BasePart
	if floorIndex <= 2 then floor.Size = Vector3.new(14, floor.Size.Y, 14) end
	floor:SetAttribute("IsTowerPlatform", true)
	local nodes = floor:FindFirstChild("JumpNodes")
	if nodes then nodes:Destroy() end
	nodes = Instance.new("Folder")
	nodes.Name = "JumpNodes"
	nodes.Parent = floor
	for step = 1, 2 do
		local platform = tower:WaitForChild(string.format("Tower02Step%02d_%d", floorIndex, step)) :: BasePart
		platform.Size = Vector3.new(math.max(8, Config.MinimumPlatformWidth), platform.Size.Y, math.max(8, Config.MinimumPlatformDepth))
		platform:SetAttribute("IsTowerPlatform", true)
		addNode(nodes :: Folder, step, platform)
	end
	addNode(nodes :: Folder, 3, floor)
end
tower:SetAttribute("PathValidationReady", true)
