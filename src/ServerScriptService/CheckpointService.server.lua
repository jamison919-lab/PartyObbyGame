--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Modules.GameConfig)
local CheckpointConfig = require(ReplicatedStorage.Modules.CheckpointConfig)
local Race = require(script.Parent.Services.RaceService)
local remotes = require(script.Parent.Services.RemoteService).Ensure()
local ItemService = require(script.Parent.Services.ItemService)

local map = workspace:WaitForChild("PartyObbyMap")
local checkpoints = map:WaitForChild("Checkpoints")
local connected: {[BasePart]: boolean} = {}
local respawnCooldown: {[Player]: boolean} = {}

local function playerFromHit(hit: BasePart): Player?
	local current: Instance? = hit
	while current and current ~= workspace do
		if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
			return Players:GetPlayerFromCharacter(current)
		end
		current = current.Parent
	end
	return nil
end

local function restore(player: Player)
	local data = Race.Get(player)
	if not data or not data.IsRacing or respawnCooldown[player] then return end
	respawnCooldown[player] = true
	ItemService.ClearEffects(player)
	if data.LastValidCFrame then Race.Teleport(player, data.LastValidCFrame) end
	local character = player.Character
	if character then
		local forceField = Instance.new("ForceField"); forceField.Visible = false; forceField.Parent = character
		task.delay(Config.RespawnProtectionTime, function() if forceField.Parent then forceField:Destroy() end end)
	end
	task.delay(Config.RespawnProtectionTime, function() respawnCooldown[player] = nil end)
end

local function connectCheckpoint(instance: Instance)
	if not instance:IsA("BasePart") or connected[instance] then return end
	local index = instance:GetAttribute("CheckpointIndex")
	if typeof(index) ~= "number" then
		local expectedNameIndex = table.find(CheckpointConfig.Names, instance.Name)
		if expectedNameIndex then instance:SetAttribute("CheckpointIndex", expectedNameIndex); index = expectedNameIndex end
	end
	if typeof(index) ~= "number" or index < 1 or index > Config.CheckpointCount then
		warn(string.format("[Checkpoint] ignored invalid part %s", instance:GetFullName())); return
	end
	local expectedName = CheckpointConfig.Names[index]
	if instance.Name ~= expectedName then warn(string.format("[Checkpoint] index %d should be named %s, got %s", index, expectedName, instance.Name)) end
	-- Repair the first bootstrap version, whose flat trigger sat flush with the road.
	if instance.Size.Y < 6 then
		local bottomY = instance.Position.Y - instance.Size.Y / 2
		instance.Size = Vector3.new(instance.Size.X, 10, math.max(instance.Size.Z, 3))
		instance.Position = Vector3.new(instance.Position.X, bottomY + 5, instance.Position.Z)
	end
	connected[instance] = true; instance.CanTouch = true
	instance.Touched:Connect(function(hit)
		local player = playerFromHit(hit); if not player then return end
		local data = Race.Get(player)
		if Race.State ~= "Racing" or not data or not data.IsRacing or data.IsFinished then return end
		local expected = data.CurrentCheckpoint + 1
		if index ~= expected then
			if index > expected then print(string.format("[Checkpoint] ignored %s: expected %d, touched %d", player.Name, expected, index)) end
			return
		end
		data.CurrentCheckpoint = index; data.SegmentProgress = 0; data.ProgressReachedAt = os.clock()
		data.LastValidCFrame = instance.CFrame * CFrame.new(0, 0, 4)
		print(string.format("[Checkpoint] %s reached checkpoint %d", player.Name, index))
		remotes.PlayerProgressUpdated:FireClient(player, {checkpoint=index})
		Race.ProgressChanged:Fire(player)
	end)
end

for _, child in checkpoints:GetChildren() do connectCheckpoint(child) end
checkpoints.ChildAdded:Connect(connectCheckpoint)

local killFloor = map:WaitForChild("KillFloor") :: BasePart
killFloor.Touched:Connect(function(hit) local player = playerFromHit(hit); if player then restore(player) end end)
local function watchPlayer(player: Player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid", 5)
		if humanoid and humanoid:IsA("Humanoid") then humanoid.Died:Connect(function() task.delay(Players.RespawnTime + .15, restore, player) end) end
	end)
end
Players.PlayerAdded:Connect(watchPlayer); for _, player in Players:GetPlayers() do watchPlayer(player) end
task.spawn(function()
	while task.wait(.25) do
		for player, data in Race.All() do
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if data.IsRacing and root and root:IsA("BasePart") and root.Position.Y < Config.FallHeight then restore(player) end
		end
	end
end)
