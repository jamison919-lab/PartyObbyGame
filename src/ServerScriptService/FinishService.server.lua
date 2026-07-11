--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage.Modules.GameConfig)
local Race=require(script.Parent.Services.RaceService)
local remotes=ReplicatedStorage:WaitForChild("Remotes")
local finish=workspace:WaitForChild("PartyObbyMap"):WaitForChild("FinishLine") :: BasePart
finish.Touched:Connect(function(hit)
	local p=Players:GetPlayerFromCharacter(hit.Parent); local d=p and Race.Get(p)
	if not p or not d or Race.State~="Racing" or not d.IsRacing or d.IsFinished or d.CurrentCheckpoint<Config.CheckpointCount then return end
	Race.FinishCount+=1; d.IsFinished=true; d.HasFinished=true; d.IsRacing=false; d.FinishPlace=Race.FinishCount; d.FinishTime=os.clock()-d.StartTime
	remotes.PlayerFinished:FireAllClients({userId=p.UserId,displayName=p.DisplayName,finishPlace=d.FinishPlace,finishTime=d.FinishTime})
	local area=workspace.PartyObbyMap:FindFirstChild("FinishWaitingArea"); if area and area:IsA("BasePart") then Race.Teleport(p,area.CFrame) end
end)
