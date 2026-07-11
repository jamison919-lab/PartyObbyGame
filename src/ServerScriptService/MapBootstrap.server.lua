--!strict
local TweenService = game:GetService("TweenService")
if workspace:FindFirstChild("PartyObbyMap") then return end

local map = Instance.new("Folder"); map.Name = "PartyObbyMap"; map.Parent = workspace
local function part(name: string, size: Vector3, cf: CFrame, color: Color3, parent: Instance?, collide: boolean?): Part
	local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color; p.Anchored=true
	p.CanCollide=if collide==nil then true else collide; p.Material=Enum.Material.SmoothPlastic; p.Parent=parent or map; return p
end
local function label(p: BasePart, text: string)
	local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromScale(5,1); gui.StudsOffset=Vector3.new(0,4,0); gui.AlwaysOnTop=true; gui.Parent=p
	local t=Instance.new("TextLabel"); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Text=text; t.TextScaled=true; t.TextColor3=Color3.new(1,1,1); t.TextStrokeTransparency=.2; t.Font=Enum.Font.GothamBold; t.Parent=gui
end
local lobby=part("LobbySpawn",Vector3.new(36,1,28),CFrame.new(0,5,-45),Color3.fromRGB(75,190,110)); label(lobby,"爆笑村民大逃亡 / LOBBY")
part("Road",Vector3.new(26,1,260),CFrame.new(0,4,100),Color3.fromRGB(92,101,120))
local starts=Instance.new("Folder"); starts.Name="RaceStartSpawns"; starts.Parent=map
for i=1,8 do local col=(i-1)%4; local row=math.floor((i-1)/4); local p=part(string.format("StartSpawn%02d",i),Vector3.new(5,1,5),CFrame.new(-9+col*6,5,-22+row*7),Color3.fromRGB(70,170,255),starts); p.Transparency=.25 end
local barrier=part("StartBarrier",Vector3.new(27,10,1),CFrame.new(0,9,-8),Color3.fromRGB(255,205,60)); barrier.Transparency=.25; label(barrier,"START")
local checkpoints=Instance.new("Folder"); checkpoints.Name="Checkpoints"; checkpoints.Parent=map
for i,z in ipairs({45,110,170}) do
	-- Tall trigger gates reliably touch every avatar body instead of sitting flush with the road.
	local cp=part(string.format("Checkpoint%02d",i),Vector3.new(26,10,3),CFrame.new(0,9,z),Color3.fromRGB(70,235,190),checkpoints,false)
	cp.CanTouch=true; cp.Transparency=.65; cp:SetAttribute("CheckpointIndex",i); label(cp,"CHECKPOINT "..i)
end
for i,z in ipairs({20,75,140}) do part("JumpPlatform"..i,Vector3.new(9,2,7),CFrame.new((i%2==0 and 6 or -6),7,z),Color3.fromRGB(245,145,70)) end
local mud=part("MudZone",Vector3.new(25,.4,20),CFrame.new(0,4.8,82),Color3.fromRGB(105,72,48)); mud.Material=Enum.Material.Mud; mud:SetAttribute("SlowMultiplier",.45)
local movers=Instance.new("Folder"); movers.Name="MovingObstacles"; movers.Parent=map
for i,z in ipairs({62,128}) do local box=part("MovingBox"..i,Vector3.new(6,6,6),CFrame.new(-8,8,z),Color3.fromRGB(230,85,90),movers); TweenService:Create(box,TweenInfo.new(3,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Position=Vector3.new(8,8,z)}):Play() end
local spinner=part("RotatingBar",Vector3.new(24,1,2),CFrame.new(0,7,151),Color3.fromRGB(180,90,240),movers)
task.spawn(function() while spinner.Parent do spinner.CFrame *= CFrame.Angles(0,math.rad(2),0); task.wait(1/30) end end)
local finish=part("FinishLine",Vector3.new(26,1,6),CFrame.new(0,5,218),Color3.fromRGB(255,220,60),map,false); label(finish,"FINISH")
local safe=part("FinishWaitingArea",Vector3.new(26,1,18),CFrame.new(0,5,232),Color3.fromRGB(90,210,120)); safe:SetAttribute("SafeZone",true)
local kill=part("KillFloor",Vector3.new(180,1,360),CFrame.new(0,-18,100),Color3.fromRGB(210,55,55)); kill.Transparency=.35

local mudTouches: {[Humanoid]: {[BasePart]: boolean}} = {}
mud.Touched:Connect(function(hit)
	local h=hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid"); if not h then return end
	local touches=mudTouches[h]; if not touches then touches={}; mudTouches[h]=touches; h:SetAttribute("MudOriginalSpeed",h.WalkSpeed); h.WalkSpeed*=.45 end
	touches[hit]=true
end)
mud.TouchEnded:Connect(function(hit)
	local h=hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid"); local touches=h and mudTouches[h]; if not h or not touches then return end
	touches[hit]=nil; if next(touches) then return end; mudTouches[h]=nil
	local old=h:GetAttribute("MudOriginalSpeed"); if typeof(old)=="number" then h.WalkSpeed=old; h:SetAttribute("MudOriginalSpeed",nil) end
end)
