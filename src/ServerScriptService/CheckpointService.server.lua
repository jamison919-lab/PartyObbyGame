--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage.Modules.GameConfig)
local Race=require(script.Parent.Services.RaceService)
local map=workspace:WaitForChild("PartyObbyMap")
local checkpoints=map:WaitForChild("Checkpoints")
local cooldown: {[Player]: boolean}={}
local function restore(player: Player)
	local d=Race.Get(player); if not d or not d.IsRacing or cooldown[player] then return end
	cooldown[player]=true; local cf=d.LastValidCFrame; if cf then Race.Teleport(player,cf) end
	local char=player.Character; if char then local ff=Instance.new("ForceField"); ff.Visible=false; ff.Parent=char; task.delay(Config.RespawnProtectionTime,function() if ff.Parent then ff:Destroy() end end) end
	task.delay(Config.RespawnProtectionTime,function() cooldown[player]=nil end)
end
for _,cp in checkpoints:GetChildren() do if cp:IsA("BasePart") then cp.Touched:Connect(function(hit)
	local p=Players:GetPlayerFromCharacter(hit.Parent); local d=p and Race.Get(p); local idx=cp:GetAttribute("CheckpointIndex")
	if p and d and d.IsRacing and typeof(idx)=="number" and idx==d.CurrentCheckpoint+1 then d.CurrentCheckpoint=idx; d.SegmentProgress=0; d.ProgressReachedAt=os.clock(); d.LastValidCFrame=cp.CFrame end
end) end end
local kill=map:WaitForChild("KillFloor") :: BasePart
kill.Touched:Connect(function(hit) local p=Players:GetPlayerFromCharacter(hit.Parent); if p then restore(p) end end)
local function watchPlayer(p: Player)
	p.CharacterAdded:Connect(function(c) local h=c:WaitForChild("Humanoid",5); if h then h.Died:Connect(function() task.delay(Players.RespawnTime+.15,function() restore(p) end) end) end end)
	if p.Character then local h=p.Character:FindFirstChildOfClass("Humanoid"); if h then h.Died:Connect(function() task.delay(Players.RespawnTime+.15,function() restore(p) end) end) end end
end
Players.PlayerAdded:Connect(watchPlayer); for _,p in Players:GetPlayers() do watchPlayer(p) end
task.spawn(function() while task.wait(.25) do for p,d in Race.All() do local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if d.IsRacing and root and root:IsA("BasePart") and root.Position.Y<Config.FallHeight then restore(p) end end end end)
