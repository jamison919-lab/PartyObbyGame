--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Modules.TowerJumpConfig)

local Service = {}
local HEADROOM=10
local ARC_HEIGHT=5

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

local function blockingPart(cf:CFrame,size:Vector3,excluded:{Instance}):BasePart?
	local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances=excluded
	for _,part in workspace:GetPartBoundsInBox(cf,size,params)do if part.CanCollide then return part end end
	return nil
end

local function validateClearance(tower:Instance,floorName:string,order:number,source:BasePart,target:BasePart):Result?
	local sourceTop=source.Position+Vector3.new(0,source.Size.Y/2,0);local targetTop=target.Position+Vector3.new(0,target.Size.Y/2,0);local prefix=string.format("%s %s jump %d",tower.Name,floorName,order)
	local overhead=blockingPart(CFrame.new(sourceTop+Vector3.new(0,HEADROOM/2,0)),Vector3.new(4,HEADROOM,4),{source,target})
	if overhead then local bottom=overhead.Position.Y-overhead.Size.Y/2;return{Level="FAIL",Message=string.format("%s headroom %.1f, requires %d; blocked by %s",prefix,bottom-sourceTop.Y,HEADROOM,overhead.Name)}end
	for sample=1,7 do local alpha=sample/8;local position=sourceTop:Lerp(targetTop,alpha)+Vector3.new(0,4*ARC_HEIGHT*alpha*(1-alpha)+2.5,0);local blocker=blockingPart(CFrame.new(position),Vector3.new(3,5,3),{source,target});if blocker then return{Level="FAIL",Message=string.format("%s blocked by %s at arc sample %d",prefix,blocker.Name,sample)}end end
	return nil
end

local function overlaps(a:BasePart,b:BasePart):boolean
	local delta=a.Position-b.Position;return math.abs(delta.X)<(a.Size.X+b.Size.X)/2-.05 and math.abs(delta.Y)<(a.Size.Y+b.Size.Y)/2-.05 and math.abs(delta.Z)<(a.Size.Z+b.Size.Z)/2-.05
end

function Service.Validate(tower: Instance): {Result}
	local results: {Result} = {}
	local floors = tower:FindFirstChild("Floors")
	local start = tower:FindFirstChild("TowerStart")
	if not floors or not start or not start:IsA("BasePart") then
		return {{Level = "FAIL", Message = tower.Name .. " missing Floors or TowerStart"}}
	end
	local previous: BasePart = start
	local platforms:{BasePart}={start};local clearanceFailed=false
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
			local clearance=validateClearance(tower,floor.Name,order,previous,target);if clearance then clearanceFailed=true;table.insert(results,clearance)end
			table.insert(platforms,target)
			previous = target
		end
		if previous ~= floor then
			table.insert(results, {Level = "FAIL", Message = string.format("%s %s route does not end on floor", tower.Name, floor.Name)})
			previous = floor
		end
	end
	if not clearanceFailed then table.insert(results,{Level="PASS",Message=tower.Name.." jump clearance"})end
	local overlapFailed=false;for i=1,#platforms do for j=i+1,#platforms do if platforms[i]~=platforms[j]and overlaps(platforms[i],platforms[j])then overlapFailed=true;table.insert(results,{Level="FAIL",Message=string.format("%s platform overlap %s / %s",tower.Name,platforms[i].Name,platforms[j].Name)})end end end
	if not overlapFailed then table.insert(results,{Level="PASS",Message=tower.Name.." no platform overlap"})end
	return results
end

function Service.ShowClearanceBoxes(tower:Instance,visible:boolean):boolean
	local old=tower:FindFirstChild("ClearanceDiagnostics");if old then old:Destroy()end;if not visible then return true end
	local folder=Instance.new("Folder");folder.Name="ClearanceDiagnostics";folder.Parent=tower;local floors=tower:FindFirstChild("Floors");local previous=tower:FindFirstChild("TowerStart");if not floors or not previous or not previous:IsA("BasePart")then return false end
	local floorList=floors:GetChildren();table.sort(floorList,function(a,b)return(a:GetAttribute("FloorIndex")or 0)<(b:GetAttribute("FloorIndex")or 0)end)
	for _,floor in floorList do local nodes=floor:FindFirstChild("JumpNodes");if not nodes then continue end;local list=nodes:GetChildren();table.sort(list,function(a,b)return(a:GetAttribute("JumpOrder")or 0)<(b:GetAttribute("JumpOrder")or 0)end);for _,node in list do local value=node:FindFirstChild("TargetPlatform");local target=if value and value:IsA("ObjectValue")then value.Value else nil;if target and target:IsA("BasePart")then local blocked=validateClearance(tower,floor.Name,node:GetAttribute("JumpOrder")or 0,previous,target)~=nil;local nearLimit=horizontalGap(previous,target)>Config.MaximumFlatJumpGap*Config.MobileSafetyMultiplier;for sample=1,7 do local alpha=sample/8;local from=previous.Position+Vector3.new(0,previous.Size.Y/2,0);local to=target.Position+Vector3.new(0,target.Size.Y/2,0);local marker=Instance.new("Part");marker.Name="ClearanceSample";marker.Size=Vector3.new(3,5,3);marker.Position=from:Lerp(to,alpha)+Vector3.new(0,4*ARC_HEIGHT*alpha*(1-alpha)+2.5,0);marker.Anchored=true;marker.CanCollide=false;marker.CanQuery=false;marker.CanTouch=false;marker.Transparency=.65;marker.Color=if blocked then Color3.fromRGB(255,70,70)else if nearLimit then Color3.fromRGB(255,215,70)else Color3.fromRGB(70,230,110);marker:SetAttribute("DecorativeObject",true);marker.Parent=folder end;previous=target end end end;return true
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
