--!strict
local ContextActionService=game:GetService("ContextActionService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local function sink() return Enum.ContextActionResult.Sink end
ReplicatedStorage.Remotes.RoundStateChanged.OnClientEvent:Connect(function(data)
	local locked=data.state=="Preparing" or data.state=="Countdown"
	if locked then ContextActionService:BindAction("RaceJumpLock",sink,false,Enum.PlayerActions.CharacterJump) else ContextActionService:UnbindAction("RaceJumpLock") end
end)
