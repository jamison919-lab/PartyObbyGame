--!strict
local Service = {}

local function nextTarget(tower: Instance, support: BasePart): BasePart?
	local floors = tower:FindFirstChild("Floors")
	local floorIndex = support:GetAttribute("FloorIndex")
	local nextFloor = floors and floors:FindFirstChild(string.format("Floor%02d", if typeof(floorIndex) == "number" then floorIndex + 1 else 1))
	local nodes = nextFloor and nextFloor:FindFirstChild("JumpNodes")
	local node = nodes and nodes:FindFirstChild("JumpNode01")
	local value = node and node:FindFirstChild("TargetPlatform")
	return if value and value:IsA("ObjectValue") and value.Value and value.Value:IsA("BasePart") then value.Value else nil
end

local function spawnPosition(support: BasePart, humanoid: Humanoid, root: BasePart): Vector3
	local y = support.Position.Y + support.Size.Y / 2 + humanoid.HipHeight + root.Size.Y / 2 + 0.5
	return Vector3.new(support.Position.X, y, support.Position.Z)
end

local function occupied(character: Model, support: BasePart, position: Vector3, root: BasePart, humanoid: Humanoid): (boolean, BasePart?)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character, support}
	local height = math.max(6, humanoid.HipHeight + root.Size.Y + 3)
	for _, candidate in workspace:GetPartBoundsInBox(CFrame.new(position + Vector3.new(0, 1, 0)), Vector3.new(4, height, 4), params) do
		if candidate.CanCollide then return true, candidate end
	end
	return false, nil
end

function Service.FindSafeCFrame(player: Player, tower: Instance, support: BasePart): (CFrame?, number, BasePart?)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not character or not humanoid or not root or not root:IsA("BasePart") then return nil, 0, nil end
	local base = spawnPosition(support, humanoid, root)
	local blocker: BasePart? = nil
	for _, offset in {Vector3.zero, Vector3.new(0,1,0), Vector3.new(0,2,0), Vector3.new(0,3,0), Vector3.new(0,4,0), Vector3.new(0,5,0), Vector3.new(0,6,0), Vector3.new(0,7,0), Vector3.new(0,8,0), Vector3.new(0,9,0), Vector3.new(0,10,0), Vector3.new(2,0,0), Vector3.new(-2,0,0), Vector3.new(0,0,2), Vector3.new(0,0,-2), Vector3.new(4,0,0), Vector3.new(-4,0,0), Vector3.new(0,0,4), Vector3.new(0,0,-4)} do
		local candidate = base + offset
		local blocked, part = occupied(character, support, candidate, root, humanoid)
		blocker = part or blocker
		if not blocked then
			local target = nextTarget(tower, support)
			local look = if target then Vector3.new(target.Position.X, candidate.Y, target.Position.Z) else candidate + support.CFrame.LookVector * 20
			if (look - candidate).Magnitude < 0.1 then look = candidate + Vector3.new(0, 0, -20) end
			return CFrame.lookAt(candidate, look), math.floor(offset.Y), nil
		end
	end
	return nil, 0, blocker
end

function Service.Teleport(player: Player, tower: Instance, support: BasePart): boolean
	local deadline=os.clock()+8;local character=player.Character
	while character and (not character:FindFirstChild("HumanoidRootPart")or not character:FindFirstChildOfClass("Humanoid"))and os.clock()<deadline do task.wait(.1);character=player.Character end
	local cf, moved, blocker = Service.FindSafeCFrame(player, tower, support)
	if not cf then warn(string.format("[Tower] failed to find safe %s spawn for %s%s", tower.Name, player.Name, if blocker then "; blocked by "..blocker:GetFullName() else ""));return false end
	if moved > 0 then print(string.format("[Tower] moved spawn upward by %d studs", moved)) end
	local character = player.Character;local root = character and character:FindFirstChild("HumanoidRootPart")
	if not character or not root or not root:IsA("BasePart") then return false end
	character:PivotTo(cf);root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero;local force=character:FindFirstChildOfClass("ForceField")or Instance.new("ForceField");force.Visible=false;force.Parent=character;task.delay(1.5,function()if force.Parent==character then force:Destroy()end end)
	return true
end

function Service.ValidateTowerSpawn(tower: Instance): (boolean, {string})
	local errors = {};local start=tower:FindFirstChild("TowerStart");local floors=tower:FindFirstChild("Floors")
	if not start or not start:IsA("BasePart") then return false,{"TowerStart missing"} end
	local floor1=floors and floors:FindFirstChild("Floor01");local nodes=floor1 and floor1:FindFirstChild("JumpNodes");local node=nodes and nodes:FindFirstChild("JumpNode01");local value=node and node:FindFirstChild("TargetPlatform");local first=if value and value:IsA("ObjectValue")then value.Value else nil
	if not first or not first:IsA("BasePart")then table.insert(errors,"first platform missing")else
		local horizontal=Vector2.new(first.Position.X-start.Position.X,first.Position.Z-start.Position.Z);local direction=horizontal.Magnitude>0 and horizontal.Unit or Vector2.zero
		local startRadius=math.abs(direction.X)*start.Size.X/2+math.abs(direction.Y)*start.Size.Z/2;local firstRadius=math.abs(direction.X)*first.Size.X/2+math.abs(direction.Y)*first.Size.Z/2;local gap=horizontal.Magnitude-startRadius-firstRadius
		if gap<3 or gap>5 then table.insert(errors,string.format("first platform edge gap %.1f outside 3-5",gap))end
		if first.Position.Y-first.Size.Y/2 < start.Position.Y+start.Size.Y/2 then table.insert(errors,"first platform below start top")end
	end
	local clearanceBox=CFrame.new(start.Position+Vector3.new(0,start.Size.Y/2+5,0));local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={start}
	for _,part in workspace:GetPartBoundsInBox(clearanceBox,Vector3.new(8,9,8),params)do if part.CanCollide then table.insert(errors,"spawn overlaps "..part.Name);break end end
	return #errors==0,errors
end

return Service
