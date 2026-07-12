--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Modules.GameConfig)
local States = require(ReplicatedStorage.Modules.RoundConfig)
local RankingUtils = require(ReplicatedStorage.Modules.RankingUtils)
local Race = require(script.Parent.Services.RaceService)
local RemoteService = require(script.Parent.Services.RemoteService)
local ItemService = require(script.Parent.Services.ItemService)
local QueueService = require(script.Parent.Services.QueueService)
local LobbyService = require(script.Parent.Services.LobbyService)
local ModeService = require(script.Parent.Services.ModeService)
local RankService = require(script.Parent.Services.RankService)
local Profiles = require(script.Parent.Services.PlayerProfileService)
local Rewards = require(script.Parent.Services.RewardService)
local Leaderboards = require(script.Parent.Services.GlobalLeaderboardService)
local MapService = require(script.Parent.Services.MapService)
local MapVoteService = require(script.Parent.Services.MapVoteService)
local PuzzleService = require(script.Parent.Services.PuzzleService)
local MapVoteConfig = require(ReplicatedStorage.Modules.MapVoteConfig)
local GameplayEvents = require(script.Parent.Services.GameplayEventService)

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
local activeRoster:{Player}={}
local activeMatch:any=nil
local worstRanks:{[Player]:number}={}

local function resolveMap(runtimeMap:Instance): boolean
	map = runtimeMap
	starts = map:FindFirstChild("RaceStartSpawns") or map:WaitForChild("RaceStartSpawns", timeout)
	if not starts then warn("[Round] cannot start: RaceStartSpawns missing"); return false end
	checkpoints = map:FindFirstChild("Checkpoints") or map:WaitForChild("Checkpoints", timeout)
	if not checkpoints then warn("[Round] cannot start: Checkpoints missing"); return false end
	return true
end

local function announce(state: string, message: string, timeRemaining: number)
	local changed = Race.State ~= state
	Race.SetState(state, message, timeRemaining)
	for _,player in activeRoster do if player.Parent==Players then roundRemote:FireClient(player,Race.StatePayload()) end end
	if changed then print(string.format("[Round] state changed: %s", state)) end
end
local function timer(state: string, message: string, seconds: number): boolean
	for remaining=seconds,1,-1 do
		announce(state,message,remaining); for _,player in activeRoster do countdownRemote:FireClient(player,remaining,state) end; task.wait(1)
	end
	return true
end

local function rankingPayload()
	if not map or not starts or not checkpoints then return end
	local payload={}; local points={}
	local checkpointCount=#checkpoints:GetChildren()
	for i=1,checkpointCount do local cp=checkpoints:FindFirstChild(string.format("Checkpoint%02d",i)); if cp and cp:IsA("BasePart") then points[i]=cp.Position end end
	local finish=map:FindFirstChild("FinishLine")
	if not finish or not finish:IsA("BasePart") then return end
	for _,data in Race.Ranked() do
		if not data.IsFinished then
			local root=data.Player.Character and data.Player.Character:FindFirstChild("HumanoidRootPart")
			local spawn=starts:FindFirstChild(string.format("StartSpawn%02d",data.SpawnIndex))
			local from=if data.CurrentCheckpoint==0 and spawn and spawn:IsA("BasePart") then spawn.Position else points[data.CurrentCheckpoint]
			local target=if data.CurrentCheckpoint<checkpointCount then points[data.CurrentCheckpoint+1] else finish.Position
			if root and root:IsA("BasePart") and from and target then data.SegmentProgress=RankingUtils.segmentProgress(root.Position,from,target) end
		end
	end
	for rank,data in Race.Ranked() do worstRanks[data.Player]=math.max(worstRanks[data.Player]or rank,rank);table.insert(payload,{userId=data.UserId,displayName=data.Player.DisplayName,rank=rank,checkpoint=data.CurrentCheckpoint,totalCheckpoints=checkpointCount,segmentProgress=data.SegmentProgress,isFinished=data.IsFinished,finishPlace=data.FinishPlace,finishTime=data.FinishTime}) end
	for _,player in activeRoster do if player.Parent==Players then rankingRemote:FireClient(player,payload) end end
end
Race.ProgressChanged.Event:Connect(rankingPayload)
Race.AllRacersFinished.Event:Connect(function() if Race.State==States.Racing then roundShouldEnd=true end end)

local function selectRacers(candidates:{Player}): {Player}
	if not starts then return {} end
	local direction=map and map:FindFirstChild("StartDirection"); if not direction and checkpoints then direction=checkpoints:FindFirstChild("Checkpoint01") end
	local facingTarget=if direction and direction:IsA("BasePart") then direction else nil
	local selected={}
	for _,player in candidates do
		if #selected>=Config.MaxPlayers then break end
		local character=player.Character; local humanoid=character and character:FindFirstChildOfClass("Humanoid"); local root=character and character:FindFirstChild("HumanoidRootPart")
		local spawn=starts:FindFirstChild(string.format("StartSpawn%02d",#selected+1))
		if character and humanoid and root and spawn and spawn:IsA("BasePart") then
			table.insert(selected,player); Race.Add(player,#selected,spawn.CFrame)
			if not Race.TeleportFacing(player,spawn,facingTarget,Config.CharacterWaitTimeout) then warn(string.format("[Round] cannot start: no valid character for %s",player.Name)); Race.Remove(player); table.remove(selected) else Race.Lock(player,true); print(string.format("[Round] teleported %s to %s facing track",player.Name,spawn.Name)) end
		else warn(string.format("[Round] cannot start: no valid character for %s",player.Name)) end
	end
	local names={}; for _,p in selected do table.insert(names,p.Name) end; print("[Round] selected racers: "..table.concat(names,", "))
	return selected
end
while true do
	activeMatch=QueueService.TakePending()
	while not activeMatch do Race.SetState(States.WaitingForPlayers,"在大廳選擇遊戲模式",0);task.wait(.25);activeMatch=QueueService.TakePending() end
	local mapId=MapVoteService.Select(activeMatch.ModeId,activeMatch.Players);if not mapId then warn("[Round] no eligible map");activeMatch=nil;continue end;activeMatch.MapId=mapId
	local runtimeMap=MapService.LoadMap(activeMatch.MatchId,mapId);if not runtimeMap or not resolveMap(runtimeMap)then warn("[Round] map load failed: "..mapId);activeMatch=nil;continue end
	PuzzleService.Bind(activeMatch.MatchId,runtimeMap);for _,player in activeMatch.Players do ModeService.Get(player).CurrentMapId=mapId end
	activeRoster=activeMatch.Players;for _,player in activeRoster do remoteMap.ModeStateChanged:FireClient(player,{mode=activeMatch.ModeId,inMatch=true,inLobby=false}) end;announce(States.Intermission,"排隊完成",0)
	local definition=MapService.GetMapDefinition(mapId);for _,player in activeRoster do remoteMap.MapIntro:FireClient(player,definition)end;task.wait(MapVoteConfig.IntroDuration)
	announce(States.Preparing,"準備起跑",0); print("[Round] preparing racers")
	ItemService.ClearAll(); Race.RoundNumber+=1; Race.Clear(); local selected=selectRacers(activeRoster);activeRoster=selected
	if #selected==0 then warn("[Round] cannot start: no valid queued characters"); Race.Clear();activeMatch=nil;task.wait(1);continue end
	task.wait(Config.PreparingDuration)
	local barrier=map and map:FindFirstChild("StartBarrier"); if barrier and barrier:IsA("BasePart") then barrier.CanCollide=true; barrier.Transparency=.25 end
	print("[Round] countdown started"); timer(States.Countdown,"倒數",Config.CountdownDuration)
	if barrier and barrier:IsA("BasePart") then barrier.CanCollide=false; barrier.Transparency=.8 end
	worstRanks={};local started=os.clock(); for _,data in Race.All() do data.StartTime=started; data.IsRacing=true end
	local timeLimit=definition.TimeLimit or Config.RoundTime;roundShouldEnd=false; announce(States.Racing,"GO!",timeLimit); for player in Race.All() do Race.Lock(player,false) end;for _,player in activeRoster do countdownRemote:FireClient(player,"GO",States.Racing) end; print("[Round] GO - racing started")
	local deadline=os.clock()+timeLimit; local lastSecond=-1
	while os.clock()<deadline and Race.ValidCount()>0 and not roundShouldEnd and not Race.AllFinished() do
		local remaining=math.max(0,math.ceil(deadline-os.clock())); if remaining~=lastSecond then Race.SetState(States.Racing,"比賽中",remaining);for _,player in activeRoster do roundRemote:FireClient(player,Race.StatePayload()) end;lastSecond=remaining end
		rankingPayload(); task.wait(Config.RankingUpdateInterval)
	end
	rankingPayload(); local results={}; local winner: Player?=nil
	for place,data in Race.Ranked() do
		data.IsRacing=false; data.IsEliminated=not data.IsFinished;local result={rank=place,displayName=data.Player.DisplayName,finishTime=data.FinishTime,isFinished=data.IsFinished,checkpoint=data.CurrentCheckpoint,dnf=not data.IsFinished};if activeMatch.ModeId=="RankedRace" then local rank=RankService.Apply(data.Player,place,#activeRoster,data.IsFinished);result.rankChange=rank;remoteMap.RankUpdated:FireClient(data.Player,rank);print(string.format("[Rank] %s gained %d points",data.Player.Name,rank.delta)) end;table.insert(results,result)
		Profiles.IncrementValue(data.Player,"General.RoundsPlayed",1);if activeMatch.ModeId=="CasualRace" then Profiles.IncrementValue(data.Player,"CasualRace.Matches",1) end;if data.FinishPlace==1 then Profiles.IncrementValue(data.Player,"General.Wins",1);if activeMatch.ModeId=="CasualRace" then Profiles.IncrementValue(data.Player,"CasualRace.Wins",1) end end;if data.FinishTime then local ms=math.floor(data.FinishTime*1000);local profile=Profiles.GetProfile(data.Player);if profile and (profile.CasualRace.BestTimeMilliseconds==0 or ms<profile.CasualRace.BestTimeMilliseconds) then Profiles.UpdateValue(data.Player,"CasualRace.BestTimeMilliseconds",ms) end end;result.coinsEarned=Rewards.Race(data.Player,activeMatch.MatchId,activeMatch.ModeId,place,data.IsFinished);local profile=Profiles.GetProfile(data.Player);if profile then Leaderboards.Update(data.Player,"Wins",profile.General.Wins);if activeMatch.ModeId=="RankedRace" then Leaderboards.Update(data.Player,"Rank",profile.RankedRace.RankPoints) end end
		if data.IsFinished then
			GameplayEvents.Event:Fire(data.Player,"RaceComplete",1);if activeMatch.ModeId=="CasualRace"then GameplayEvents.Event:Fire(data.Player,"CasualComplete",1)end;if place<=3 then GameplayEvents.Event:Fire(data.Player,"TopThree",1)end
			if data.ActiveEffects.WasOffTrack then GameplayEvents.Event:Fire(data.Player,"OffTrackFinish",1)end
			if activeMatch.MapId=="ClocktowerEscape02"then GameplayEvents.Event:Fire(data.Player,"ClocktowerComplete",1)elseif activeMatch.MapId=="VillageWorkshop03"then GameplayEvents.Event:Fire(data.Player,"PuzzleMapComplete",1)end
			local completedProfile=Profiles.GetProfile(data.Player);if completedProfile then completedProfile.CasualRace.CompletedMaps[activeMatch.MapId]=true;Profiles.MarkDirty(data.Player);local all=true;for _,mapDefinition in require(ReplicatedStorage.Modules.MapCatalog)do if mapDefinition.IsEnabled and mapDefinition.Mode=="Race"and not completedProfile.CasualRace.CompletedMaps[mapDefinition.Id]then all=false;break end end;if all then GameplayEvents.Event:Fire(data.Player,"AllRaceMaps",1)end end
			if place==1 then GameplayEvents.Event:Fire(data.Player,"RaceWin",1);if worstRanks[data.Player]==#activeRoster and #activeRoster>=2 then GameplayEvents.Event:Fire(data.Player,"ComebackWin",1)end;if activeMatch.ModeId=="RankedRace"then GameplayEvents.Event:Fire(data.Player,"RankedWin",1);local rankedProfile=Profiles.GetProfile(data.Player);if rankedProfile and rankedProfile.RankedRace.WinStreak>=3 then GameplayEvents.Event:Fire(data.Player,"RankedStreak3",1)end end end
		end
		local stats=data.Player:FindFirstChild("leaderstats"); if stats then local rounds=stats:FindFirstChild("RoundsPlayed") :: IntValue?; if rounds then rounds.Value+=1 end; if data.IsFinished and data.FinishPlace==1 then winner=data.Player end; local best=stats:FindFirstChild("BestTime") :: NumberValue?; if best and data.FinishTime and (best.Value==0 or data.FinishTime<best.Value) then best.Value=data.FinishTime end end
	end
	if winner then local stats=winner:FindFirstChild("leaderstats"); local wins=stats and stats:FindFirstChild("Wins") :: IntValue?; if wins then wins.Value+=1 end end
	announce(States.Results,"本局結果",Config.ResultsDuration);for _,player in activeRoster do resultsRemote:FireClient(player,results) end;task.wait(Config.ResultsDuration)
	announce(States.Resetting,"返回大廳",Config.ResetDuration);ItemService.ClearAll();for _,player in activeRoster do if player.Parent==Players then LobbyService.Return(player) end end;Race.Clear();PuzzleService.Clear(activeMatch.MatchId);MapService.UnloadMap(activeMatch.MatchId);activeRoster={};activeMatch=nil;if barrier and barrier:IsA("BasePart") then barrier.CanCollide=true;barrier.Transparency=.25 end;task.wait(Config.ResetDuration)
end
