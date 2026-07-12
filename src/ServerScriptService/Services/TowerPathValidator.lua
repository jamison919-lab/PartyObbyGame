--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Modules.TowerJumpConfig)

local Service = {}

export type Result = {Level: "PASS" | "WARN" | "FAIL", Message: string}

local function horizontalGap(fromPart: BasePart, toPart: BasePart): number
	local delta = toPart.Position - fromPart.Position
	local horizontalDistance = Vector2.new(delta.X, delta.Z).Magnitude
	local fromRadius = math.min(fromPart.Size.X, fromPart.Size.Z) * 0.5
	local toRadius = math.min(toPart.Size.X, toPart.Size.Z) * 0.5
	return math.max(0, horizontalDistance - fromRadius - toRadius)
end

local function validateJump(towerId: string, floorName: string, order: number, fromPart: BasePart, toPart: BasePart): Result
	local gap = horizontalGap(fromPart, toPart)
	local rise = (toPart.Position.Y - toPart.Size.Y * 0.5) - (fromPart.Position.Y + fromPart.Size.Y * 0.5)
	local maxGap = if rise > 0.25 then Config.MaximumRisingJumpGap else if rise < -0.25 then Config.MaximumDownwardGap else Config.MaximumFlatJumpGap
	local prefix = string.format("%s %s jump %d", towerId, floorName, order)
	if toPart.Size.X < Config.MinimumPlatformWidth or toPart.Size.Z < Config.MinimumPlatformDepth then
		return {Level = "FAIL", Message = string.format("%s target %s is %.1fx%.1f; minimum is %dx%d", prefix, toPart.Name, toPart.Size.X, toPart.Size.Z, Config.MinimumPlatformWidth, Config.MinimumPlatformDepth)}
	end
	if rise > Config.MaximumVerticalRise then
		return {Level = "FAIL", Message = string.format("%s rise %.1f exceeds %.1f", prefix, rise, Config.MaximumVerticalRise)}
	end
	if gap > maxGap then
		return {Level = "FAIL", Message = string.format("%s gap %.1f exceeds %.1f", prefix, gap, maxGap)}
	end
	if gap > maxGap * Config.MobileSafetyMultiplier or rise > Config.MaximumVerticalRise * Config.MobileSafetyMultiplier then
		return {Level = "WARN", Message = string.format("%s near limit (gap %.1f, rise %.1f)", prefix, gap, rise)}
	end
	return {Level = "PASS", Message = prefix}
end

function Service.Validate(tower: Instance): {Result}
	local results: {Result} = {}
	local floors = tower:FindFirstChild("Floors")
	local start = tower:FindFirstChild("TowerStart")
	if not floors or not start or not start:IsA("BasePart") then
		return {{Level = "FAIL", Message = tower.Name .. " missing Floors or TowerStart"}}
	end
	local previous: BasePart = start
	local floorList = floors:GetChildren()
	table.sort(floorList, function(a, b) return (a:GetAttribute("FloorIndex") or 0) < (b:GetAttribute("FloorIndex") or 0) end)
	for _, floor in floorList do
		if not floor:IsA("BasePart") then continue end
		local nodesFolder = floor:FindFirstChild("JumpNodes")
		if not nodesFolder then
			table.insert(results, {Level = "FAIL", Message = string.format("%s %s missing JumpNodes", tower.Name, floor.Name)})
			continue
		end
		local nodes = nodesFolder:GetChildren()
		table.sort(nodes, function(a, b) return (a:GetAttribute("JumpOrder") or 0) < (b:GetAttribute("JumpOrder") or 0) end)
		for order, node in ipairs(nodes) do
			local expectedOrder = node:GetAttribute("JumpOrder")
			local targetValue = node:FindFirstChild("TargetPlatform")
			local target = if targetValue and targetValue:IsA("ObjectValue") then targetValue.Value else nil
			if expectedOrder ~= order or not node:IsA("BasePart") or not target or not target:IsA("BasePart") then
				table.insert(results, {Level = "FAIL", Message = string.format("%s %s JumpNode%02d invalid", tower.Name, floor.Name, order)})
				continue
			end
			table.insert(results, validateJump(tower.Name, floor.Name, order, previous, target))
			previous = target
		end
		if previous ~= floor then
			table.insert(results, {Level = "FAIL", Message = string.format("%s %s route does not end on floor", tower.Name, floor.Name)})
			previous = floor
		end
	end
	return results
end

function Service.HasFailures(results: {Result}): boolean
	for _, result in results do if result.Level == "FAIL" then return true end end
	return false
end

function Service.Print(results: {Result})
	for _, result in results do
		local message = string.format("[TowerValidation] %s %s", result.Level, result.Message)
		if result.Level == "FAIL" then warn(message) else print(message) end
	end
end

return Service
