--!strict
local TweenService = game:GetService("TweenService")
local existingMap=workspace:FindFirstChild("PartyObbyMap")
if existingMap then
	local existingStarts=existingMap:FindFirstChild("RaceStartSpawns")
	local existingDirection=existingMap:FindFirstChild("StartDirection")
	if not existingDirection then
		local target=Instance.new("Part"); target.Name="StartDirection"; target.Size=Vector3.new(1,1,1); target.Position=Vector3.new(0,7,8); target.Anchored=true; target.CanCollide=false; target.CanTouch=false; target.Transparency=1; target.Parent=existingMap; existingDirection=target
	end
	if existingStarts and existingDirection:IsA("BasePart") then
		for _,spawn in existingStarts:GetChildren() do if spawn:IsA("BasePart") then local position=spawn.Position; spawn.CFrame=CFrame.lookAt(position,Vector3.new(existingDirection.Position.X,position.Y,existingDirection.Position.Z)) end end
	end
	return
end

local map = Instance.new("Folder"); map.Name = "PartyObbyMap"; map.Parent = workspace
local function part(name: string, size: Vector3, cf: CFrame, color: Color3, parent: Instance?, collide: boolean?): Part
	local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color; p.Anchored=true
	p.CanCollide=if collide==nil then true else collide; p.Material=Enum.Material.SmoothPlastic; p.Parent=parent or map; return p
end
local function label(p: BasePart, text: string)
	local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromScale(5,1); gui.StudsOffset=Vector3.new(0,4,0); gui.AlwaysOnTop=true; gui.Parent=p
	local t=Instance.new("TextLabel"); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Text=text; t.TextScaled=true; t.TextColor3=Color3.new(1,1,1); t.TextStrokeTransparency=.2; t.Font=Enum.Font.GothamBold; t.Parent=gui
end
local lobbyPosition=Vector3.new(0,5,-45); local lobby=part("LobbySpawn",Vector3.new(36,1,28),CFrame.lookAt(lobbyPosition,Vector3.new(0,5,-10)),Color3.fromRGB(75,190,110)); label(lobby,"爆笑村民大逃亡 / LOBBY")
local surfaces=Instance.new("Folder"); surfaces.Name="TrackSurfaces"; surfaces.Parent=map
local road=part("VillageRoad",Vector3.new(26,1,260),CFrame.new(0,4,100),Color3.fromRGB(196,160,105),surfaces); road.Material=Enum.Material.Cobblestone; road:SetAttribute("RaceTrackSurface",true)
local offTrack=Instance.new("Folder"); offTrack.Name="OffTrackZones"; offTrack.Parent=map
for i,x in ipairs({-28,28}) do local grass=part("OffTrackGrass"..i,Vector3.new(30,1,270),CFrame.new(x,3.8,100),Color3.fromRGB(92,175,75),offTrack); grass.Material=Enum.Material.Grass; grass:SetAttribute("OffTrackZone",true); grass:SetAttribute("PenaltyDurationMin",3); grass:SetAttribute("PenaltyDurationMax",5); grass:SetAttribute("SpeedMultiplier",.6) end
local starts=Instance.new("Folder"); starts.Name="RaceStartSpawns"; starts.Parent=map
local direction=part("StartDirection",Vector3.new(1,1,1),CFrame.new(0,7,8),Color3.new(1,1,1),map,false); direction.Transparency=1; direction.CanTouch=false
for i=1,8 do local col=(i-1)%4; local row=math.floor((i-1)/4); local position=Vector3.new(-9+col*6,5,-22+row*7); local p=part(string.format("StartSpawn%02d",i),Vector3.new(5,1,5),CFrame.lookAt(position,Vector3.new(direction.Position.X,position.Y,direction.Position.Z)),Color3.fromRGB(70,170,255),starts); p.Transparency=.25; local front=part("FrontArrow"..i,Vector3.new(1.2,.2,2.5),p.CFrame*CFrame.new(0,.7,-1),Color3.fromRGB(255,240,70),map,false); front:SetAttribute("DecorativeObject",true) end
local barrier=part("StartBarrier",Vector3.new(27,10,1),CFrame.new(0,9,-8),Color3.fromRGB(255,205,60)); barrier.Transparency=.25; label(barrier,"START")
local checkpoints=Instance.new("Folder"); checkpoints.Name="Checkpoints"; checkpoints.Parent=map
for i,z in ipairs({45,110,170}) do
	-- Tall trigger gates reliably touch every avatar body instead of sitting flush with the road.
	local cpPosition=Vector3.new(0,9,z); local cp=part(string.format("Checkpoint%02d",i),Vector3.new(26,10,3),CFrame.lookAt(cpPosition,cpPosition+Vector3.new(0,0,20)),Color3.fromRGB(70,235,190),checkpoints,false)
	cp.CanTouch=true; cp.Transparency=.65; cp:SetAttribute("CheckpointIndex",i); label(cp,"CHECKPOINT "..i)
end
for i,z in ipairs({20,75,140}) do part("JumpPlatform"..i,Vector3.new(9,2,7),CFrame.new((i%2==0 and 6 or -6),7,z),Color3.fromRGB(245,145,70)) end
local mud=part("MudZone",Vector3.new(25,.4,20),CFrame.new(0,4.8,82),Color3.fromRGB(105,72,48)); mud.Material=Enum.Material.Mud; mud:SetAttribute("MudZone",true); mud:SetAttribute("SpeedMultiplier",.65)
local movers=Instance.new("Folder"); movers.Name="MovingObstacles"; movers.Parent=map
for i,z in ipairs({62,128}) do local box=part("MovingBox"..i,Vector3.new(6,6,6),CFrame.new(-8,8,z),Color3.fromRGB(230,85,90),movers); TweenService:Create(box,TweenInfo.new(3,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Position=Vector3.new(8,8,z)}):Play() end
local spinner=part("RotatingBar",Vector3.new(24,1,2),CFrame.new(0,7,151),Color3.fromRGB(180,90,240),movers)
task.spawn(function() while spinner.Parent do spinner.CFrame *= CFrame.Angles(0,math.rad(2),0); task.wait(1/30) end end)
local finish=part("FinishLine",Vector3.new(26,1,6),CFrame.new(0,5,218),Color3.fromRGB(255,220,60),map,false); label(finish,"FINISH")
local safe=part("FinishWaitingArea",Vector3.new(26,1,18),CFrame.new(0,5,232),Color3.fromRGB(90,210,120)); safe:SetAttribute("SafeZone",true)
local kill=part("KillFloor",Vector3.new(180,1,360),CFrame.new(0,-18,100),Color3.fromRGB(210,55,55)); kill.Transparency=.35
local itemBoxes=Instance.new("Folder"); itemBoxes.Name="ItemBoxes"; itemBoxes.Parent=map
for i,z in ipairs({8,38,68,102,132,162,194}) do local box=part("MysteryBox"..i,Vector3.new(4,4,4),CFrame.new((i%2==0 and 7 or -7),8,z),Color3.fromHSV(i/7,.75,1),itemBoxes,false); box.Material=Enum.Material.Neon; box.Transparency=.2; box.CanTouch=true; box:SetAttribute("ItemBox",true); label(box,"?"); TweenService:Create(box,TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Position=box.Position+Vector3.new(0,1.5,0)}):Play() end
local decor=Instance.new("Folder"); decor.Name="VillageDecor"; decor.Parent=map
for i,z in ipairs({0,32,58,92,122,156,188,215}) do local post=part("FencePost"..i,Vector3.new(1,5,1),CFrame.new(i%2==0 and -15 or 15,6,z),Color3.fromRGB(115,72,38),decor,false); post.Material=Enum.Material.Wood; local bale=part("HayBale"..i,Vector3.new(4,3,4),CFrame.new(i%2==0 and 19 or -19,5,z+8),Color3.fromRGB(235,190,65),decor,false); bale.Material=Enum.Material.WoodPlanks end
for i,z in ipairs({25,95,165,205}) do local sign=part("FunnySign"..i,Vector3.new(7,4,.5),CFrame.new(-17,7,z),Color3.fromRGB(130,82,42),decor,false); label(sign,({"不要踩泥巴！","雞比你跑得快","掉出去會腿軟","終點就在前面，大概吧"})[i]) end
-- Lightweight village silhouettes and farm props keep the map readable and inexpensive.
for i,z in ipairs({12,52,118,178}) do local pumpkin=part("Pumpkin"..i,Vector3.new(3,3,3),CFrame.new(18,5,z),Color3.fromRGB(245,115,35),decor,false); pumpkin.Shape=Enum.PartType.Ball; local barrel=part("Barrel"..i,Vector3.new(3,4,3),CFrame.new(-19,5.5,z+6)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(125,75,40),decor,false); barrel.Shape=Enum.PartType.Cylinder end
local farm=part("Farmhouse",Vector3.new(24,14,18),CFrame.new(35,10,95),Color3.fromRGB(225,135,80),decor,false); label(farm,"村長的家")
for i,x in ipairs({-50,50}) do local hill=part("CartoonHill"..i,Vector3.new(35,22,35),CFrame.new(x,0,145),Color3.fromRGB(75,145,70),decor,false); hill.Shape=Enum.PartType.Ball end
for i,z in ipairs({-5,45,110,170,220}) do local pole=part("FlagPole"..i,Vector3.new(.5,10,.5),CFrame.new(i%2==0 and -15 or 15,9,z),Color3.fromRGB(245,235,205),decor,false); local flag=part("VillageFlag"..i,Vector3.new(4,2,.3),pole.CFrame*CFrame.new(2,3,0),i%2==0 and Color3.fromRGB(255,90,70) or Color3.fromRGB(70,160,255),decor,false); flag:SetAttribute("DecorativeObject",true) end
local windPole=part("WindmillTower",Vector3.new(5,15,5),CFrame.new(29,11,145),Color3.fromRGB(185,125,70),decor,false)
for i=1,4 do part("WindmillBlade"..i,Vector3.new(1,14,2),windPole.CFrame*CFrame.new(0,5,-3)*CFrame.Angles(0,0,math.rad((i-1)*45)),Color3.fromRGB(245,220,165),decor,false) end
