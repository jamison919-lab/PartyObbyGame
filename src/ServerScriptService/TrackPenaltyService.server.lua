--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage.Modules.TrackConfig)
local Race=require(script.Parent.Services.RaceService)
local Movement=require(script.Parent.Services.MovementModifierService)
local remotes=require(script.Parent.Services.RemoteService).Ensure()
local map=workspace:WaitForChild("PartyObbyMap",10); if not map then error("[Track] map missing") end
local offTrack=map:WaitForChild("OffTrackZones",10); if not offTrack then error("[Track] OffTrackZones missing") end
local lastTrigger:{[Player]:number}={}; local penaltyToken:{[Player]:number}={}; local connected:{[BasePart]:boolean}={}
local function playerFromHit(hit:BasePart):Player? local node:Instance?=hit; while node and node~=workspace do if node:IsA("Model") and node:FindFirstChildOfClass("Humanoid") then return Players:GetPlayerFromCharacter(node) end; node=node.Parent end; return nil end
local function connect(zone:Instance)
	if not zone:IsA("BasePart") or connected[zone] then return end; connected[zone]=true
	zone.Touched:Connect(function(hit)
		local p=playerFromHit(hit); if not p then return end; local d=Race.Get(p); local now=os.clock(); if Race.State~="Racing" or not d or not d.IsRacing or d.IsFinished or now-(lastTrigger[p] or 0)<Config.TriggerCooldown then return end
		lastTrigger[p]=now; local min=zone:GetAttribute("PenaltyDurationMin") or Config.OffTrackMin; local max=zone:GetAttribute("PenaltyDurationMax") or Config.OffTrackMax; local multiplier=zone:GetAttribute("SpeedMultiplier") or Config.OffTrackMultiplier; local duration=(min+(max-min)*math.random())
		penaltyToken[p]=(penaltyToken[p] or 0)+1; local token=penaltyToken[p]; Movement.AddModifier(p,"OffTrackPenalty",multiplier,duration); remotes.TrackPenaltyUpdated:FireClient(p,{active=true,duration=duration,expiresAt=workspace:GetServerTimeNow()+duration}); print(string.format("[Track] %s entered off-track zone",p.Name)); print(string.format("[Track] %s slowed for %.1f seconds",p.Name,duration))
		task.delay(duration,function() if penaltyToken[p]==token then remotes.TrackPenaltyUpdated:FireClient(p,{active=false}); print(string.format("[Track] %s speed restored",p.Name)) end end)
	end)
end
for _,zone in offTrack:GetChildren() do connect(zone) end; offTrack.ChildAdded:Connect(connect)
local mud=map:FindFirstChild("MudZone"); if mud and mud:IsA("BasePart") then mud.Touched:Connect(function(hit) local p=playerFromHit(hit); local d=p and Race.Get(p); if p and d and d.IsRacing then Movement.AddModifier(p,"MudSlow",mud:GetAttribute("SpeedMultiplier") or .65,.8) end end) end
Players.PlayerRemoving:Connect(function(p) lastTrigger[p]=nil; penaltyToken[p]=nil end)
