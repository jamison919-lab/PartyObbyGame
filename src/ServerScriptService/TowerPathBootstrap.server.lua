--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Modules.TowerJumpConfig)

local world = workspace:WaitForChild("PartyObbyWorld")
local towerMaps = world:WaitForChild("TowerMaps")
local tower1 = towerMaps:WaitForChild("Tower01")
local tower = towerMaps:WaitForChild("Tower02")
local floors = tower:WaitForChild("Floors")

local start = tower:WaitForChild("TowerStart") :: BasePart
local function resizePlatformKeepingEdge(platform: BasePart, newSize: Vector3, fixedEdgeDirection: Vector3)
	local direction = fixedEdgeDirection.Magnitude > 0 and fixedEdgeDirection.Unit or Vector3.xAxis
	local oldExtent = math.abs(direction.X) * platform.Size.X / 2 + math.abs(direction.Z) * platform.Size.Z / 2
	local newExtent = math.abs(direction.X) * newSize.X / 2 + math.abs(direction.Z) * newSize.Z / 2
	platform.Position -= direction * (newExtent - oldExtent)
	platform.Size = newSize
end

resizePlatformKeepingEdge(start, Vector3.new(18, start.Size.Y, 18), Vector3.xAxis)
start.Position = Vector3.new(450, 5, 0)
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
	if floorIndex <= 2 then resizePlatformKeepingEdge(floor, Vector3.new(14, floor.Size.Y, 14), Vector3.xAxis) end
	if floorIndex == 1 then floor.Position = Vector3.new(412, 14, 0) elseif floorIndex == 2 then floor.Position = Vector3.new(430, 23, 0) end
	floor:SetAttribute("IsTowerPlatform", true)
	local nodes = floor:FindFirstChild("JumpNodes")
	if nodes then nodes:Destroy() end
	nodes = Instance.new("Folder")
	nodes.Name = "JumpNodes"
	nodes.Parent = floor
	for step = 1, 2 do
		local platform = tower:WaitForChild(string.format("Tower02Step%02d_%d", floorIndex, step)) :: BasePart
		resizePlatformKeepingEdge(platform, Vector3.new(math.max(8, Config.MinimumPlatformWidth), platform.Size.Y, math.max(8, Config.MinimumPlatformDepth)), Vector3.xAxis)
		if floorIndex == 1 then platform.Position = Vector3.new(if step == 1 then 433 else 422.5, 5 + step * 3, 0)
		elseif floorIndex == 2 then platform.Position = Vector3.new(412 + step * 6, 14 + step * 3, 0)
		elseif floorIndex == 3 then platform.Position = Vector3.new(430 + step * (11 / 3), 23 + step * 3, 0) end
		platform:SetAttribute("IsTowerPlatform", true)
		addNode(nodes :: Folder, step, platform)
	end
	addNode(nodes :: Folder, 3, floor)
end
tower:SetAttribute("PathValidationReady", true)

local start1=tower1:WaitForChild("TowerStart")::BasePart;start1:SetAttribute("IsTowerPlatform",true)
local floors1=tower1:WaitForChild("Floors");local floor1=floors1:WaitForChild("Floor01")::BasePart;local floor2=floors1:WaitForChild("Floor02")::BasePart
floor1.Position=Vector3.new(264,15,0);floor2.Position=Vector3.new(282,25,0)
for step=1,2 do local p=tower1:WaitForChild(string.format("Step01_%d",step))::BasePart;p.Position=Vector3.new(if step==1 then 284 else 274,5+step*(10/3),0) end
for step=1,2 do local p=tower1:WaitForChild(string.format("Step02_%d",step))::BasePart;p.Position=Vector3.new(264+step*6,15+step*(10/3),0) end
for step=1,2 do local p=tower1:WaitForChild(string.format("Step03_%d",step))::BasePart;p.Position=Vector3.new(282+step*(10/3),25+step*(10/3),0) end
tower1:SetAttribute("PathValidationReady",true)
