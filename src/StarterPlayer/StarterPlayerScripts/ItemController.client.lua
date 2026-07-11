--!strict
local Players=game:GetService("Players"); local ReplicatedStorage=game:GetService("ReplicatedStorage"); local ContextActionService=game:GetService("ContextActionService")
local folder=ReplicatedStorage:WaitForChild("Remotes",10); if not folder then return end; local use=folder:WaitForChild("UseItem",10); if not use or not use:IsA("RemoteEvent") then return end
local function request(_,state) if state==Enum.UserInputState.Begin then use:FireServer() end; return Enum.ContextActionResult.Sink end
ContextActionService:BindAction("UsePartyItem",request,false,Enum.KeyCode.Q,Enum.KeyCode.ButtonX)
task.spawn(function() local gui=Players.LocalPlayer.PlayerGui:WaitForChild("ItemGui",10); local slot=gui and gui:FindFirstChild("ItemSlot"); local button=slot and slot:FindFirstChild("UseItemButton"); if button and button:IsA("TextButton") then button.Activated:Connect(function() use:FireServer() end) end end)
