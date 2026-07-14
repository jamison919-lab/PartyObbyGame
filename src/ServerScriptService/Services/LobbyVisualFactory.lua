--!strict
local Factory = {}

local VERSION = 1
local PORTALS = {
	CasualRacePortal = {portalId = "CasualRace", modeId = "CasualRace", title = "休閒競速\n2～8 人", style = "Casual"},
	RankedRacePortal = {portalId = "RankedRace", modeId = "RankedRace", title = "排位競速\n逃亡積分", style = "Ranked"},
	Tower01Portal = {portalId = "Tower01", modeId = "SoloTower", towerId = "Tower01", title = "村莊瞭望塔\n10 層", style = "Tower01"},
	Tower02Portal = {portalId = "Tower02", modeId = "SoloTower02", towerId = "Tower02", title = "村長機關高塔\n12 層", style = "Tower02"},
}

local function part(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material, collide: boolean?, shape: Enum.PartType?): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = cframe
	item.Color = color
	item.Material = material
	item.Anchored = true
	item.CanCollide = collide == true
	item.CanTouch = false
	item.CanQuery = collide == true
	item.CastShadow = true
	if shape then item.Shape = shape end
	item:SetAttribute("DecorativeObject", true)
	item.Parent = parent
	return item
end

local function wedge(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material): WedgePart
	local item = Instance.new("WedgePart")
	item.Name = name
	item.Size = size
	item.CFrame = cframe
	item.Color = color
	item.Material = material
	item.Anchored = true
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item:SetAttribute("DecorativeObject", true)
	item.Parent = parent
	return item
end

local function model(parent: Instance, name: string): Model
	local item = Instance.new("Model")
	item.Name = name
	item:SetAttribute("DecorativeObject", true)
	item.Parent = parent
	return item
end

local function folder(parent: Instance, name: string): Folder
	local item = Instance.new("Folder")
	item.Name = name
	item.Parent = parent
	return item
end

local function billboard(parent: BasePart, text: string, color: Color3, size: UDim2?)
	local gui = Instance.new("BillboardGui")
	gui.Name = "LobbyLabel"
	gui.Size = size or UDim2.fromOffset(260, 90)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 85
	gui.LightInfluence = 0
	gui.Parent = parent
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(35, 28, 22)
	label.BackgroundTransparency = 0.18
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.35
	label.TextScaled = true
	label.TextWrapped = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = label
end

local function groundFrame(mainLobby: Instance, spawn: BasePart, facing: BasePart): CFrame
	local plaza = mainLobby:FindFirstChild("Plaza")
	local groundY = if plaza and plaza:IsA("BasePart") then plaza.Position.Y + plaza.Size.Y * 0.5 else spawn.Position.Y - spawn.Size.Y * 0.5
	return CFrame.new(facing.Position.X, groundY, facing.Position.Z) * facing.CFrame.Rotation
end

local function createRoad(parent: Instance, name: string, startPosition: Vector3, endPosition: Vector3)
	local delta = Vector3.new(endPosition.X - startPosition.X, 0, endPosition.Z - startPosition.Z)
	if delta.Magnitude < 1 then return end
	local direction = delta.Unit
	local from = startPosition + direction * 9
	local to = endPosition - direction * 1.5
	local midpoint = (from + to) * 0.5
	local road = part(parent, name, Vector3.new(16, 0.18, (to - from).Magnitude), CFrame.lookAt(midpoint, to), Color3.fromRGB(170, 145, 105), Enum.Material.Cobblestone, false)
	road:SetAttribute("RoadToPortal", name:gsub("Road$", ""))
end

local function createBench(parent: Instance, origin: CFrame, offset: Vector3, yaw: number, index: number)
	local base = origin * CFrame.new(offset) * CFrame.Angles(0, math.rad(yaw), 0)
	part(parent, "BenchSeat" .. index, Vector3.new(7, 0.7, 2), base * CFrame.new(0, 1.8, 0), Color3.fromRGB(132, 82, 43), Enum.Material.WoodPlanks, true)
	part(parent, "BenchBack" .. index, Vector3.new(7, 2.4, 0.55), base * CFrame.new(0, 3, 0.75) * CFrame.Angles(math.rad(-8), 0, 0), Color3.fromRGB(148, 92, 48), Enum.Material.WoodPlanks, false)
	for _, x in {-2.5, 2.5} do part(parent, "BenchLeg", Vector3.new(0.55, 1.5, 0.55), base * CFrame.new(x, 0.75, 0), Color3.fromRGB(90, 60, 38), Enum.Material.Wood, false) end
end

local function createPlanter(parent: Instance, origin: CFrame, offset: Vector3, index: number)
	local base = origin * CFrame.new(offset)
	part(parent, "Planter" .. index, Vector3.new(2.2, 3.2, 3.2), base * CFrame.new(0, 1.1, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(125, 72, 38), Enum.Material.WoodPlanks, false, Enum.PartType.Cylinder)
	part(parent, "Flower" .. index .. "A", Vector3.new(1.1, 1.1, 1.1), base * CFrame.new(-0.55, 2.4, 0), Color3.fromRGB(255, 105, 95), Enum.Material.SmoothPlastic, false, Enum.PartType.Ball)
	part(parent, "Flower" .. index .. "B", Vector3.new(1, 1, 1), base * CFrame.new(0.5, 2.55, 0.3), Color3.fromRGB(255, 215, 70), Enum.Material.SmoothPlastic, false, Enum.PartType.Ball)
end

local function createChickenMayor(parent: Instance, origin: CFrame)
	local statue = model(parent, "ChickenMayorStatue")
	local stone = Color3.fromRGB(220, 198, 150)
	part(statue, "Body", Vector3.new(4.4, 5.2, 3.8), origin * CFrame.new(0, 5.1, 0), stone, Enum.Material.SmoothPlastic, false, Enum.PartType.Ball)
	part(statue, "Head", Vector3.new(3.5, 3.5, 3.5), origin * CFrame.new(0, 8.4, -0.25), Color3.fromRGB(245, 222, 170), Enum.Material.SmoothPlastic, false, Enum.PartType.Ball)
	part(statue, "CombA", Vector3.new(0.9, 1.5, 0.9), origin * CFrame.new(-0.7, 10.3, -0.25), Color3.fromRGB(215, 65, 55), Enum.Material.SmoothPlastic, false, Enum.PartType.Ball)
	part(statue, "CombB", Vector3.new(0.9, 1.7, 0.9), origin * CFrame.new(0.25, 10.45, -0.25), Color3.fromRGB(225, 70, 55), Enum.Material.SmoothPlastic, false, Enum.PartType.Ball)
	wedge(statue, "Beak", Vector3.new(1.4, 1.1, 1.6), origin * CFrame.new(0, 8.35, -2.1) * CFrame.Angles(0, math.rad(180), 0), Color3.fromRGB(245, 160, 45), Enum.Material.SmoothPlastic)
	for _, x in {-2.15, 2.15} do wedge(statue, "Wing", Vector3.new(1.2, 3.2, 2.7), origin * CFrame.new(x, 5.6, 0) * CFrame.Angles(0, 0, math.rad(if x < 0 then -18 else 198)), stone, Enum.Material.SmoothPlastic) end
	for _, x in {-0.9, 0.9} do part(statue, "Leg", Vector3.new(0.45, 2, 0.45), origin * CFrame.new(x, 2.2, 0), Color3.fromRGB(205, 130, 38), Enum.Material.SmoothPlastic, false) end
	part(statue, "MayorHatBrim", Vector3.new(4.4, 0.45, 3.5), origin * CFrame.new(0, 10.75, -0.15), Color3.fromRGB(105, 58, 35), Enum.Material.Fabric, false)
	part(statue, "MayorHat", Vector3.new(2.8, 1.5, 2.6), origin * CFrame.new(0, 11.65, -0.15), Color3.fromRGB(125, 72, 40), Enum.Material.Fabric, false)
end

local function createCentralPlaza(decorations: Folder, origin: CFrame)
	local plaza = model(decorations, "CentralPlazaVisual")
	part(plaza, "StonePlaza", Vector3.new(0.22, 38, 38), origin * CFrame.new(0, 0.12, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(194, 177, 145), Enum.Material.Cobblestone, false, Enum.PartType.Cylinder)
	part(plaza, "MayorPedestal", Vector3.new(2.2, 15, 15), origin * CFrame.new(0, 1.1, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(154, 146, 130), Enum.Material.Slate, true, Enum.PartType.Cylinder)
	createChickenMayor(plaza, origin * CFrame.new(0, 2.2, 0))
	for index, offset in {Vector3.new(-12, 0, -9), Vector3.new(12, 0, -9), Vector3.new(-12, 0, 9), Vector3.new(12, 0, 9)} do createPlanter(plaza, origin, offset, index) end
	createBench(plaza, origin, Vector3.new(-17, 0, 0), 90, 1)
	createBench(plaza, origin, Vector3.new(17, 0, 0), -90, 2)
	for index, x in {-20, 20} do
		local pole = part(plaza, "FlagPole" .. index, Vector3.new(0.45, 10, 0.45), origin * CFrame.new(x, 5, -16), Color3.fromRGB(110, 78, 50), Enum.Material.Wood, false)
		wedge(plaza, "PartyFlag" .. index, Vector3.new(0.3, 3.2, 4), pole.CFrame * CFrame.new(0, 3.1, -2), if index == 1 then Color3.fromRGB(245, 145, 45) else Color3.fromRGB(90, 190, 100), Enum.Material.Fabric)
	end
end

local function portalLocal(portal: BasePart, groundY: number, x: number, y: number, z: number): CFrame
	return portal.CFrame * CFrame.new(x, groundY + y - portal.Position.Y, z)
end

local function addArch(parent: Model, portal: BasePart, title: string, columnColor: Color3, beamColor: Color3, material: Enum.Material)
	local groundY = portal.Position.Y - portal.Size.Y * 0.5
	local side = portal.Size.X * 0.5 + 2.5
	part(parent, "LeftColumn", Vector3.new(3, 13, 3), portalLocal(portal, groundY, -side, 6.5, 0), columnColor, material, true)
	part(parent, "RightColumn", Vector3.new(3, 13, 3), portalLocal(portal, groundY, side, 6.5, 0), columnColor, material, true)
	part(parent, "TopBeam", Vector3.new(portal.Size.X + 8, 2, 3), portalLocal(portal, groundY, 0, 15, 0), beamColor, material, false)
	local sign = part(parent, "PortalSign", Vector3.new(8, 3, 0.5), portalLocal(portal, groundY, 0, 17.5, -0.2), beamColor, material, false)
	billboard(sign, title, Color3.new(1, 1, 1))
	return groundY, side
end

local function decoratePortal(parent: Folder, portal: BasePart, definition: any)
	local visual = model(parent, portal.Name .. "Visual")
	visual:SetAttribute("PortalVisualFor", definition.portalId)
	if definition.style == "Casual" then
		local groundY, side = addArch(visual, portal, definition.title, Color3.fromRGB(145, 88, 45), Color3.fromRGB(175, 105, 48), Enum.Material.WoodPlanks)
		for index, x in {-side + 1, side - 1} do wedge(visual, "Flag" .. index, Vector3.new(0.3, 2.5, 3.3), portalLocal(portal, groundY, x, 13, -1.8), if index == 1 then Color3.fromRGB(245, 135, 40) else Color3.fromRGB(85, 185, 90), Enum.Material.Fabric) end
		part(visual, "HayBale", Vector3.new(4, 2.8, 3), portalLocal(portal, groundY, -side - 3, 1.4, 2.5), Color3.fromRGB(225, 180, 65), Enum.Material.Fabric, false)
		part(visual, "Barrel", Vector3.new(3.2, 3, 3), portalLocal(portal, groundY, side + 3, 1.6, 2.5) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(115, 68, 38), Enum.Material.WoodPlanks, false, Enum.PartType.Cylinder)
	elseif definition.style == "Ranked" then
		local groundY, side = addArch(visual, portal, definition.title, Color3.fromRGB(105, 110, 130), Color3.fromRGB(55, 45, 115), Enum.Material.Slate)
		part(visual, "GoldTrim", Vector3.new(portal.Size.X + 9, 0.45, 3.3), portalLocal(portal, groundY, 0, 16.15, 0), Color3.fromRGB(235, 190, 55), Enum.Material.Metal, false)
		local shield = part(visual, "RankShield", Vector3.new(4.2, 4.5, 0.6), portalLocal(portal, groundY, 0, 19.8, 0), Color3.fromRGB(80, 65, 155), Enum.Material.Metal, false)
		wedge(visual, "ShieldPoint", Vector3.new(4.2, 2.2, 0.6), shield.CFrame * CFrame.new(0, -3.2, 0) * CFrame.Angles(0, 0, math.rad(180)), Color3.fromRGB(235, 190, 55), Enum.Material.Metal)
		for index, x in {-side - 2.5, side + 2.5} do part(visual, "GoldMarker" .. index, Vector3.new(1, 5, 1), portalLocal(portal, groundY, x, 2.5, 2), Color3.fromRGB(235, 190, 55), Enum.Material.Metal, false) end
	elseif definition.style == "Tower01" then
		local groundY, side = addArch(visual, portal, definition.title, Color3.fromRGB(125, 78, 44), Color3.fromRGB(95, 60, 38), Enum.Material.WoodPlanks)
		for index, x in {-side, side} do part(visual, "StoneFoot" .. index, Vector3.new(4, 2, 4), portalLocal(portal, groundY, x, 1, 0), Color3.fromRGB(130, 125, 118), Enum.Material.Cobblestone, true) end
		part(visual, "CrateA", Vector3.new(3, 3, 3), portalLocal(portal, groundY, -side - 3.5, 1.5, 2.5), Color3.fromRGB(145, 92, 48), Enum.Material.WoodPlanks, false)
		part(visual, "CrateB", Vector3.new(2.3, 2.3, 2.3), portalLocal(portal, groundY, side + 3, 1.15, 2.5), Color3.fromRGB(165, 110, 60), Enum.Material.WoodPlanks, false)
	elseif definition.style == "Tower02" then
		local groundY, side = addArch(visual, portal, definition.title, Color3.fromRGB(95, 85, 72), Color3.fromRGB(78, 105, 105), Enum.Material.Metal)
		part(visual, "OrangeGuide", Vector3.new(0.65, 11, 0.65), portalLocal(portal, groundY, -side - 1.8, 6, -1.7), Color3.fromRGB(245, 135, 45), Enum.Material.Neon, false)
		part(visual, "TealGuide", Vector3.new(0.65, 11, 0.65), portalLocal(portal, groundY, side + 1.8, 6, -1.7), Color3.fromRGB(55, 205, 185), Enum.Material.Neon, false)
		local gearCenter = portalLocal(portal, groundY, side + 4.8, 7, 1.8)
		part(visual, "GearHub", Vector3.new(1.2, 5.5, 5.5), gearCenter * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(105, 110, 112), Enum.Material.Metal, false, Enum.PartType.Cylinder)
		for index = 1, 6 do local angle = math.rad((index - 1) * 60);part(visual, "GearTooth" .. index, Vector3.new(1.4, 1.3, 2), gearCenter * CFrame.new(math.cos(angle) * 3.3, math.sin(angle) * 3.3, 0) * CFrame.Angles(0, 0, angle), Color3.fromRGB(125, 125, 120), Enum.Material.Metal, false) end
	end
end

local function createSign(parent: Instance, origin: CFrame, offset: Vector3, yaw: number, text: string, index: number)
	local base = origin * CFrame.new(offset) * CFrame.Angles(0, math.rad(yaw), 0)
	part(parent, "SignPost" .. index, Vector3.new(0.7, 5, 0.7), base * CFrame.new(0, 2.5, 0), Color3.fromRGB(105, 65, 38), Enum.Material.Wood, false)
	local board = part(parent, "SignBoard" .. index, Vector3.new(7.5, 3, 0.6), base * CFrame.new(0, 5.2, 0), Color3.fromRGB(142, 88, 45), Enum.Material.WoodPlanks, false)
	billboard(board, text, Color3.fromRGB(255, 236, 185), UDim2.fromOffset(230, 75))
end

local function createTree(parent: Instance, origin: CFrame, offset: Vector3, index: number)
	local base = origin * CFrame.new(offset)
	part(parent, "TreeTrunk" .. index, Vector3.new(2.2, 8, 2.2), base * CFrame.new(0, 4, 0), Color3.fromRGB(105, 68, 38), Enum.Material.Wood, false)
	part(parent, "TreeCrown" .. index, Vector3.new(8, 8, 8), base * CFrame.new(0, 10, 0), Color3.fromRGB(80, 155, 70), Enum.Material.Grass, false, Enum.PartType.Ball)
end

local function createFarmhouse(parent: Instance, origin: CFrame, offset: Vector3, yaw: number, index: number)
	local base = origin * CFrame.new(offset) * CFrame.Angles(0, math.rad(yaw), 0)
	part(parent, "Farmhouse" .. index, Vector3.new(18, 10, 14), base * CFrame.new(0, 5, 0), Color3.fromRGB(205, 155, 88), Enum.Material.WoodPlanks, false)
	wedge(parent, "FarmRoof" .. index .. "A", Vector3.new(18.5, 5, 9), base * CFrame.new(0, 12.5, -3.5) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(135, 65, 48), Enum.Material.Brick)
	wedge(parent, "FarmRoof" .. index .. "B", Vector3.new(18.5, 5, 9), base * CFrame.new(0, 12.5, 3.5) * CFrame.Angles(0, math.rad(-90), math.rad(180)), Color3.fromRGB(135, 65, 48), Enum.Material.Brick)
end

local function createBoundary(decorations: Folder, origin: CFrame)
	local boundary = model(decorations, "LobbyBoundaryVisual")
	part(boundary, "OuterGrass", Vector3.new(142, 0.25, 126), origin * CFrame.new(0, -0.1, 0), Color3.fromRGB(105, 174, 78), Enum.Material.Grass, false)
	for index, data in {{Vector3.new(-61, 0, 0), Vector3.new(1.2, 1.2, 116)}, {Vector3.new(61, 0, 0), Vector3.new(1.2, 1.2, 116)}, {Vector3.new(0, 0, -57), Vector3.new(122, 1.2, 1.2)}, {Vector3.new(0, 0, 57), Vector3.new(122, 1.2, 1.2)}} do
		for rail = 1, 3 do part(boundary, "BoundaryFence" .. index .. "Rail" .. rail, data[2], origin * CFrame.new(data[1] + Vector3.new(0, rail * 2, 0)), Color3.fromRGB(105, 70, 42), Enum.Material.Wood, true) end
	end
	for index, offset in {Vector3.new(-50, 0, -43), Vector3.new(50, 0, -42), Vector3.new(-52, 0, 38), Vector3.new(52, 0, 39), Vector3.new(-28, 0, 49), Vector3.new(30, 0, 49)} do createTree(boundary, origin, offset, index) end
	createFarmhouse(boundary, origin, Vector3.new(-49, 0, -35), 20, 1)
	createFarmhouse(boundary, origin, Vector3.new(49, 0, -34), -20, 2)
	local wind = origin * CFrame.new(0, 0, 49)
	part(boundary, "WindmillTower", Vector3.new(7, 18, 7), wind * CFrame.new(0, 9, 0), Color3.fromRGB(190, 150, 92), Enum.Material.WoodPlanks, false)
	local hub = part(boundary, "WindmillHub", Vector3.new(2, 3, 3), wind * CFrame.new(0, 15, -4), Color3.fromRGB(105, 85, 65), Enum.Material.Metal, false, Enum.PartType.Cylinder)
	for index, angle in {0, 90, 180, 270} do part(boundary, "WindmillBlade" .. index, Vector3.new(1.1, 9, 0.6), hub.CFrame * CFrame.Angles(math.rad(angle), 0, 0) * CFrame.new(0, 5, 0), Color3.fromRGB(225, 205, 155), Enum.Material.Wood, false) end
	for index, offset in {Vector3.new(-70, 8, 20), Vector3.new(70, 9, 15), Vector3.new(-65, 7, -25), Vector3.new(65, 8, -20)} do part(boundary, "DistantHill" .. index, Vector3.new(28, 16, 24), origin * CFrame.new(offset), Color3.fromRGB(91, 145, 78), Enum.Material.Grass, false, Enum.PartType.Ball) end
end

function Factory.Clear(mainLobby: Instance)
	for _, child in mainLobby:GetChildren() do if child.Name == "Decorations" then child:Destroy() end end
end

function Factory.Apply(mainLobby: Instance): (boolean, string?)
	local spawn = mainLobby:FindFirstChild("LobbySpawn")
	local facing = mainLobby:FindFirstChild("LobbyFacingTarget")
	local portals = mainLobby:FindFirstChild("Portals")
	if not spawn or not spawn:IsA("BasePart") then return false, "LobbySpawn missing" end
	if not facing or not facing:IsA("BasePart") then return false, "LobbyFacingTarget missing" end
	if not portals then return false, "Portals missing" end
	for portalName in PORTALS do local portal = portals:FindFirstChild(portalName);if not portal or not portal:IsA("BasePart") then return false, portalName .. " missing" end end

	Factory.Clear(mainLobby)
	local decorations = folder(mainLobby, "Decorations")
	decorations:SetAttribute("LobbyVisualFactoryVersion", VERSION)
	local origin = groundFrame(mainLobby, spawn, facing)
	createCentralPlaza(decorations, origin)

	local roads = folder(decorations, "PortalRoads")
	local visualPortals = folder(decorations, "PortalVisuals")
	createRoad(roads, "LobbySpawnApproach", Vector3.new(spawn.Position.X, origin.Position.Y + 0.12, spawn.Position.Z), origin.Position + Vector3.new(0, 0.12, 0))
	for portalName, definition in PORTALS do
		local portal = portals:FindFirstChild(portalName) :: BasePart
		createRoad(roads, portalName .. "Road", origin.Position + Vector3.new(0, 0.12, 0), Vector3.new(portal.Position.X, origin.Position.Y + 0.12, portal.Position.Z))
		decoratePortal(visualPortals, portal, definition)
	end

	local signs = folder(decorations, "VillageSigns")
	createSign(signs, origin, Vector3.new(-24, 0, -20), 15, "先選模式，再開始逃命", 1)
	createSign(signs, origin, Vector3.new(27, 0, -17), -18, "村長不負責跌倒", 2)
	createSign(signs, origin, Vector3.new(-43, 0, 13), 25, "雞的速度可能比你快", 3)
	createSign(signs, origin, Vector3.new(42, 0, 10), -25, "排位輸了不能怪泥巴", 4)
	createSign(signs, origin, Vector3.new(0, 0, 45), 180, "爬塔請勿撞頭", 5)
	createBoundary(decorations, origin)
	print(string.format("[LobbyVisual] applied foundation v%d (%d descendants)", VERSION, #decorations:GetDescendants()))
	return true, nil
end

local function overlapsDecorations(decorations: Instance, cframe: CFrame, size: Vector3): BasePart?
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {decorations}
	for _, candidate in workspace:GetPartBoundsInBox(cframe, size, params) do if candidate.CanCollide then return candidate end end
	return nil
end

function Factory.Validate(mainLobby: Instance): (boolean, {string})
	local errors = {}
	local decorationsList = {}
	for _, child in mainLobby:GetChildren() do if child.Name == "Decorations" then table.insert(decorationsList, child) end end
	local decorations = decorationsList[1]
	if #decorationsList ~= 1 or not decorations or not decorations:IsA("Folder") then table.insert(errors, "MainLobby.Decorations must exist exactly once");return false, errors end
	if decorations:GetAttribute("LobbyVisualFactoryVersion") ~= VERSION then table.insert(errors, "Lobby visual version mismatch") end
	local spawn = mainLobby:FindFirstChild("LobbySpawn")
	local facing = mainLobby:FindFirstChild("LobbyFacingTarget")
	local portals = mainLobby:FindFirstChild("Portals")
	if not spawn or not spawn:IsA("BasePart") then table.insert(errors, "LobbySpawn missing") else
		local blocker = overlapsDecorations(decorations, CFrame.new(spawn.Position + Vector3.new(0, spawn.Size.Y * 0.5 + 5, 0)), Vector3.new(8, 10, 8))
		if blocker then table.insert(errors, "LobbySpawn clearance blocked by " .. blocker:GetFullName()) end
	end
	if not facing or not facing:IsA("BasePart") or facing.CanCollide or facing.CanTouch then table.insert(errors, "LobbyFacingTarget invalid") end
	if not portals then table.insert(errors, "Portals missing");return false, errors end
	local visualRoot = decorations:FindFirstChild("PortalVisuals")
	for portalName, definition in PORTALS do
		local portal = portals:FindFirstChild(portalName)
		if not portal or not portal:IsA("BasePart") then table.insert(errors, portalName .. " missing");continue end
		if portal:GetAttribute("PortalId") ~= definition.portalId or portal:GetAttribute("ModeId") ~= definition.modeId or portal:GetAttribute("TowerId") ~= definition.towerId then table.insert(errors, portalName .. " attributes changed") end
		if not portal:FindFirstChildOfClass("ProximityPrompt") then table.insert(errors, portalName .. " ProximityPrompt missing") end
		if not visualRoot or not visualRoot:FindFirstChild(portalName .. "Visual") then table.insert(errors, portalName .. " visual missing") end
		local groundY = portal.Position.Y - portal.Size.Y * 0.5
		local triggerBlocker = overlapsDecorations(decorations, portal.CFrame, portal.Size)
		if triggerBlocker then table.insert(errors, portalName .. " trigger intruded by " .. triggerBlocker:GetFullName()) end
		local front = portal.CFrame * CFrame.new(0, groundY + 6 - portal.Position.Y, -6)
		local frontBlocker = overlapsDecorations(decorations, front, Vector3.new(math.max(12, portal.Size.X - 2), 12, 8))
		if frontBlocker then table.insert(errors, portalName .. " approach blocked by " .. frontBlocker:GetFullName()) end
	end
	return #errors == 0, errors
end

return Factory
