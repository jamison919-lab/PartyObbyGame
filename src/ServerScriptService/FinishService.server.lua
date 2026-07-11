--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Modules.GameConfig)
local Race = require(script.Parent.Services.RaceService)
local remotes = require(script.Parent.Services.RemoteService).Ensure()
local finish = workspace:WaitForChild("PartyObbyMap"):WaitForChild("FinishLine") :: BasePart
local promptCooldown: {[Player]: boolean} = {}

local function playerFromHit(hit: BasePart): Player?
	local current: Instance? = hit
	while current and current ~= workspace do
		if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then return Players:GetPlayerFromCharacter(current) end
		current = current.Parent
	end
	return nil
end

finish.CanTouch = true
finish.Touched:Connect(function(hit)
	local player = playerFromHit(hit); if not player then return end
	local data = Race.Get(player)
	if Race.State ~= "Racing" or not data or not data.IsRacing or data.IsFinished then return end
	if data.CurrentCheckpoint < Config.CheckpointCount then
		if not promptCooldown[player] then
			promptCooldown[player] = true; remotes.PlayerFinished:FireClient(player, {blocked=true, message="請先通過所有檢查點"})
			task.delay(2, function() promptCooldown[player] = nil end)
		end
		return
	end
	Race.FinishCount += 1; data.IsFinished = true; data.HasFinished = true; data.IsRacing = false
	data.FinishPlace = Race.FinishCount; data.FinishTime = os.clock() - data.StartTime
	print(string.format("[Finish] %s finished place %d", player.Name, data.FinishPlace))
	remotes.PlayerFinished:FireAllClients({userId=player.UserId, displayName=player.DisplayName, finishPlace=data.FinishPlace, finishTime=data.FinishTime})
	Race.ProgressChanged:Fire(player)
	if Race.AllFinished() then print("[Round] all racers finished, ending round"); Race.AllRacersFinished:Fire() end
	local area = workspace.PartyObbyMap:FindFirstChild("FinishWaitingArea"); if area and area:IsA("BasePart") then Race.Teleport(player, area.CFrame) end
end)
