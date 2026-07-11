--!strict
local ContextActionService=game:GetService("ContextActionService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local function sink() return Enum.ContextActionResult.Sink end
local folder=ReplicatedStorage:WaitForChild("Remotes",10)
if not folder then warn("[RaceMovement] Remotes missing"); return end
local roundStateChanged=folder:WaitForChild("RoundStateChanged",10)
if not roundStateChanged or not roundStateChanged:IsA("RemoteEvent") then warn("[RaceMovement] RoundStateChanged missing"); return end
roundStateChanged.OnClientEvent:Connect(function(data)
	local locked=data.state=="Preparing" or data.state=="Countdown"
	if locked then ContextActionService:BindAction("RaceJumpLock",sink,false,Enum.PlayerActions.CharacterJump) else ContextActionService:UnbindAction("RaceJumpLock") end
end)
