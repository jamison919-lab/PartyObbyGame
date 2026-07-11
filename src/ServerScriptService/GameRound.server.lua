--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(ReplicatedStorage.Modules.GameConfig)
local States = require(ReplicatedStorage.Modules.RoundConfig)
local RankingUtils = require(ReplicatedStorage.Modules.RankingUtils)
local Race = require(script.Parent.Services.RaceService)
local RemoteService = require(script.Parent.Services.RemoteService)

local timeout = Config.ObjectWaitTimeout
print("[Round] GameRound started")
local remoteMap = RemoteService.Ensure()
local roundRemote = remoteMap.RoundStateChanged
local countdownRemote = remoteMap.CountdownUpdated
local rankingRemote = remoteMap.RankingUpdated
local resultsRemote = remoteMap.ResultsUpdated
print("[Round] remotes ready")

local map: Instance? = nil
local starts: Instance? = nil
local checkpoints: Instance? = nil
local roundShouldEnd = false
local lastWaitingCount = -1
local soloEligibleAt: number? = nil

local function resolveMap(): boolean
	map = workspace:FindFirstChild("PartyObbyMap") or workspace:WaitForChild("PartyObbyMap", timeout)
	if not map then warn("[Round] cannot start: PartyObbyMap missing"); return false end
	if not map:FindFirstChild("LobbySpawn") then warn("[Round] cannot start: LobbySpawn missing"); return false end
	starts = map:FindFirstChild("RaceStartSpawns") or map:WaitForChild("RaceStartSpawns", timeout)
	if not starts then warn("[Round] cannot start: RaceStartSpawns missing"); return false end
	checkpoints = map:FindFirstChild("Checkpoints") or map:WaitForChild("Checkpoints", timeout)
	if not checkpoints then warn("[Round] cannot start: Checkpoints missing"); return false end
	return true
end

local function announce(state: string, message: string, timeRemaining: number)
	local changed = Race.State ~= state
	Race.SetState(state, message, timeRemaining)
	roundRemote:FireAllClients(Race.StatePayload())
	if changed then print(string.format("[Round] state changed: %s", state)) end
end
local function timer(state: string, message: string, seconds: number): boolean
	for remaining=seconds,1,-1 do
		announce(state,message,remaining); countdownRemote:FireAllClients(remaining,state); task.wait(1)
		if state==States.Intermission and #Players:GetPlayers()<Config.MinPlayers and not (RunService:IsStudio() and Config.AllowSoloStudio and #Players:GetPlayers()==1) then return false end
	end
	return true
end
local function requiredPlayers(): number
	local count = #Players:GetPlayers()
	if count ~= 1 then soloEligibleAt = nil; return Config.MinPlayers end
	if RunService:IsStudio() and Config.AllowSoloStudio then
		soloEligibleAt = soloEligibleAt or (os.clock() + Config.StudioSoloGraceTime)
		if os.clock() >= soloEligibleAt then return 1 end
	end
	return Config.MinPlayers
end
local function enoughPlayers(): boolean return #Players:GetPlayers() >= requiredPlayers() end

local function rankingPayload()
	if not map or not starts or not checkpoints then return end
	local payload={}; local points={}
	for i=1,Config.CheckpointCount do local cp=checkpoints:FindFirstChild(string.format("Checkpoint%02d",i)); if cp and cp:IsA("BasePart") then points[i]=cp.Position end end
	local finish=map:FindFirstChild("FinishLine")
	if not finish or not finish:IsA("BasePart") then return end
	for _,data in Race.Ranked() do
		if not data.IsFinished then
			local root=data.Player.Character and data.Player.Character:FindFirstChild("HumanoidRootPart")
			local spawn=starts:FindFirstChild(string.format("StartSpawn%02d",data.SpawnIndex))
			local from=if data.CurrentCheckpoint==0 and spawn and spawn:IsA("BasePart") then spawn.Position else points[data.CurrentCheckpoint]
			local target=if data.CurrentCheckpoint<Config.CheckpointCount then points[data.CurrentCheckpoint+1] else finish.Position
			if root and root:IsA("BasePart") and from and target then data.SegmentProgress=RankingUtils.segmentProgress(root.Position,from,target) end
		end
	end
	for rank,data in Race.Ranked() do table.insert(payload,{userId=data.UserId,displayName=data.Player.DisplayName,rank=rank,checkpoint=data.CurrentCheckpoint,segmentProgress=data.SegmentProgress,isFinished=data.IsFinished,finishPlace=data.FinishPlace,finishTime=data.FinishTime}) end
	rankingRemote:FireAllClients(payload)
end
Race.ProgressChanged.Event:Connect(rankingPayload)
Race.AllRacersFinished.Event:Connect(function() if Race.State==States.Racing then roundShouldEnd=true end end)

local function selectRacers(): {Player}
	if not starts then return {} end
	local selected={}
	for _,player in Players:GetPlayers() do
		if #selected>=Config.MaxPlayers then break end
		local character=player.Character; local humanoid=character and character:FindFirstChildOfClass("Humanoid"); local root=character and character:FindFirstChild("HumanoidRootPart")
		local spawn=starts:FindFirstChild(string.format("StartSpawn%02d",#selected+1))
		if character and humanoid and root and spawn and spawn:IsA("BasePart") then
			table.insert(selected,player); Race.Add(player,#selected,spawn.CFrame)
			if not Race.Teleport(player,spawn.CFrame,Config.CharacterWaitTimeout) then warn(string.format("[Round] cannot start: no valid character for %s",player.Name)); Race.Remove(player); table.remove(selected) else Race.Lock(player,true) end
		else warn(string.format("[Round] cannot start: no valid character for %s",player.Name)) end
	end
	local names={}; for _,p in selected do table.insert(names,p.Name) end; print("[Round] selected racers: "..table.concat(names,", "))
	return selected
end
local function sendLobby(player: Player) if map then local spawn=map:FindFirstChild("LobbySpawn"); if spawn and spawn:IsA("BasePart") then Race.Teleport(player,spawn.CFrame,Config.CharacterWaitTimeout) end end end

while true do
	if not resolveMap() then announce(States.WaitingForPlayers,"等待地圖建立",0); task.wait(2); continue end
	while not enoughPlayers() do
		local count=#Players:GetPlayers(); local needed=requiredPlayers()
		announce(States.WaitingForPlayers,"等待玩家",0)
		if count~=lastWaitingCount then print(string.format("[Round] waiting, valid players: %d/%d",count,needed)); lastWaitingCount=count end
		task.wait(1)
	end
	print(string.format("[Round] valid players: %d/%d, starting intermission",#Players:GetPlayers(),requiredPlayers())); lastWaitingCount=-1
	if not timer(States.Intermission,"下一局即將開始",Config.LobbyWaitTime) then continue end
	Race.RoundNumber+=1; Race.Clear(); local selected=selectRacers()
	if #selected<requiredPlayers() then warn("[Round] cannot start: not enough valid characters"); Race.Clear(); task.wait(1); continue end
	timer(States.Preparing,"準備起跑",Config.PrepareTime)
	local barrier=map and map:FindFirstChild("StartBarrier"); if barrier and barrier:IsA("BasePart") then barrier.CanCollide=true; barrier.Transparency=.25 end
	timer(States.Countdown,"倒數",Config.CountdownTime)
	if barrier and barrier:IsA("BasePart") then barrier.CanCollide=false; barrier.Transparency=.8 end
	local started=os.clock(); for player,data in Race.All() do data.StartTime=started; data.IsRacing=true; Race.Lock(player,false) end
	roundShouldEnd=false; announce(States.Racing,"GO!",Config.RoundTime); countdownRemote:FireAllClients("GO",States.Racing)
	local deadline=os.clock()+Config.RoundTime; local lastSecond=-1
	while os.clock()<deadline and Race.ValidCount()>0 and not roundShouldEnd and not Race.AllFinished() do
		local remaining=math.max(0,math.ceil(deadline-os.clock())); if remaining~=lastSecond then Race.SetState(States.Racing,"比賽中",remaining); roundRemote:FireAllClients(Race.StatePayload()); lastSecond=remaining end
		rankingPayload(); task.wait(Config.RankingUpdateInterval)
	end
	rankingPayload(); local results={}; local winner: Player?=nil
	for place,data in Race.Ranked() do
		data.IsRacing=false; data.IsEliminated=not data.IsFinished; table.insert(results,{rank=place,displayName=data.Player.DisplayName,finishTime=data.FinishTime,isFinished=data.IsFinished,checkpoint=data.CurrentCheckpoint,dnf=not data.IsFinished})
		local stats=data.Player:FindFirstChild("leaderstats"); if stats then local rounds=stats:FindFirstChild("RoundsPlayed") :: IntValue?; if rounds then rounds.Value+=1 end; if data.IsFinished and data.FinishPlace==1 then winner=data.Player end; local best=stats:FindFirstChild("BestTime") :: NumberValue?; if best and data.FinishTime and (best.Value==0 or data.FinishTime<best.Value) then best.Value=data.FinishTime end end
	end
	if winner then local stats=winner:FindFirstChild("leaderstats"); local wins=stats and stats:FindFirstChild("Wins") :: IntValue?; if wins then wins.Value+=1 end end
	announce(States.Results,"本局結果",Config.ResultsTime); resultsRemote:FireAllClients(results); task.wait(Config.ResultsTime)
	announce(States.Resetting,"返回大廳",Config.BetweenRoundsTime); for _,player in Players:GetPlayers() do sendLobby(player) end; Race.Clear(); if barrier and barrier:IsA("BasePart") then barrier.CanCollide=true; barrier.Transparency=.25 end; task.wait(Config.BetweenRoundsTime)
end
