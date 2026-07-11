--!strict
local Players=game:GetService("Players")
local TrackConfig=require(game:GetService("ReplicatedStorage").Modules.TrackConfig)
type State={baseSpeed:number,baseJumpPower:number,baseJumpHeight:number,modifiers:{[string]:number},tokens:{[string]:number}}
local states:{[Player]:State}={}
local Service={}
local function get(player:Player):State
	local state=states[player]; if state then return state end
	state={baseSpeed=16,baseJumpPower=50,baseJumpHeight=7.2,modifiers={},tokens={}}; states[player]=state; return state
end
function Service.Capture(player:Player)
	local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if not h then return end
	local s=get(player); if next(s.modifiers)==nil then s.baseSpeed=h.WalkSpeed; s.baseJumpPower=h.JumpPower; s.baseJumpHeight=h.JumpHeight end
end
function Service.RecalculateMovement(player:Player)
	local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if not h then return end
	local s=get(player); if s.modifiers.StartLock==0 then h.WalkSpeed=0; h.JumpPower=0; h.JumpHeight=0; return end
	local slow=1; local boost=1
	for _,multiplier in s.modifiers do if multiplier<1 then slow=math.min(slow,multiplier) else boost=math.max(boost,multiplier) end end
	h.WalkSpeed=math.clamp(s.baseSpeed*slow*boost,TrackConfig.MinWalkSpeed,TrackConfig.MaxWalkSpeed); h.JumpPower=s.baseJumpPower; h.JumpHeight=s.baseJumpHeight
end
function Service.AddModifier(player:Player,key:string,multiplier:number,duration:number?)
	local s=get(player); Service.Capture(player); s.modifiers[key]=multiplier; s.tokens[key]=(s.tokens[key] or 0)+1; local token=s.tokens[key]; Service.RecalculateMovement(player)
	if duration then task.delay(duration,function() if states[player] and s.tokens[key]==token then Service.RemoveModifier(player,key) end end) end
end
function Service.RemoveModifier(player:Player,key:string) local s=states[player]; if not s then return end; s.modifiers[key]=nil; s.tokens[key]=(s.tokens[key] or 0)+1; Service.RecalculateMovement(player) end
function Service.ClearTemporaryModifiers(player:Player) local s=states[player]; if not s then return end; table.clear(s.modifiers); table.clear(s.tokens); Service.RecalculateMovement(player) end
function Service.SetSpringJump(player:Player,multiplier:number,enabled:boolean) local s=get(player); local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if not h then return end; if enabled then h.JumpPower=s.baseJumpPower*multiplier; h.JumpHeight=s.baseJumpHeight*multiplier else h.JumpPower=s.baseJumpPower; h.JumpHeight=s.baseJumpHeight end end
Players.PlayerRemoving:Connect(function(p) states[p]=nil end)
local function watch(p:Player) p.CharacterAdded:Connect(function() task.wait(.15); Service.RecalculateMovement(p) end) end
Players.PlayerAdded:Connect(watch); for _,p in Players:GetPlayers() do watch(p) end
return Service
