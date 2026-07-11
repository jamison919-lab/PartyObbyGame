--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage.Modules.GameConfig)
local States=require(ReplicatedStorage.Modules.RoundConfig)
local RankingUtils=require(ReplicatedStorage.Modules.RankingUtils)
local Race=require(script.Parent.Services.RaceService)
local remotes=ReplicatedStorage:WaitForChild("Remotes")
local map=workspace:WaitForChild("PartyObbyMap")
local starts=map:WaitForChild("RaceStartSpawns")
local checkpoints=map:WaitForChild("Checkpoints")

local function announce(state: string,message: string,time: number)
	Race.State=state; remotes.RoundStateChanged:FireAllClients({state=state,message=message,timeRemaining=time,roundNumber=Race.RoundNumber})
end
local function timer(state: string,message: string,seconds: number)
	for t=seconds,1,-1 do announce(state,message,t); remotes.CountdownUpdated:FireAllClients(t,state); task.wait(1) end
end
local function lobby(p: Player) local x=map:FindFirstChild("LobbySpawn"); if x and x:IsA("BasePart") then Race.Teleport(p,x.CFrame) end end
local function rankingPayload()
	local payload={}; local points={}
	for i=1,Config.CheckpointCount do local cp=checkpoints:FindFirstChild(string.format("Checkpoint%02d",i)); if cp and cp:IsA("BasePart") then points[i]=cp.Position end end
	local finish=map:FindFirstChild("FinishLine") :: BasePart
	for _,d in Race.Ranked() do
		if not d.IsFinished then local root=d.Player.Character and d.Player.Character:FindFirstChild("HumanoidRootPart"); local from=if d.CurrentCheckpoint==0 then (starts:FindFirstChild(string.format("StartSpawn%02d",d.SpawnIndex)) :: BasePart).Position else points[d.CurrentCheckpoint]; local to=if d.CurrentCheckpoint<Config.CheckpointCount then points[d.CurrentCheckpoint+1] else finish.Position; if root and root:IsA("BasePart") and from and to then d.SegmentProgress=RankingUtils.segmentProgress(root.Position,from,to) end end
	end
	for rank,d in Race.Ranked() do table.insert(payload,{userId=d.UserId,displayName=d.Player.DisplayName,rank=rank,checkpoint=d.CurrentCheckpoint,segmentProgress=d.SegmentProgress,isFinished=d.IsFinished,finishPlace=d.FinishPlace,finishTime=d.FinishTime}) end
	remotes.RankingUpdated:FireAllClients(payload)
end
local function enough(): boolean return #Players:GetPlayers()>=Config.MinPlayers end

while true do
	while not enough() do announce(States.WaitingForPlayers,"等待玩家",0); task.wait(1) end
	timer(States.Intermission,"下一局即將開始",Config.LobbyWaitTime)
	if not enough() then continue end
	Race.RoundNumber+=1; Race.Clear()
	local selected=Players:GetPlayers(); while #selected>Config.MaxPlayers do table.remove(selected) end
	for i,p in selected do local s=starts:FindFirstChild(string.format("StartSpawn%02d",i)); if s and s:IsA("BasePart") then Race.Add(p,i,s.CFrame); Race.Teleport(p,s.CFrame); Race.Lock(p,true) end end
	timer(States.Preparing,"準備起跑",Config.PrepareTime)
	local barrier=map:FindFirstChild("StartBarrier"); if barrier and barrier:IsA("BasePart") then barrier.CanCollide=true; barrier.Transparency=.25 end
	timer(States.Countdown,"倒數",Config.CountdownTime)
	if barrier and barrier:IsA("BasePart") then barrier.CanCollide=false; barrier.Transparency=.8 end
	local startTime=os.clock(); for p,d in Race.All() do d.StartTime=startTime; d.IsRacing=true; Race.Lock(p,false) end
	announce(States.Racing,"GO!",Config.RoundTime); remotes.CountdownUpdated:FireAllClients("GO",States.Racing)
	local deadline=os.clock()+Config.RoundTime; local lastSecond=-1
	while os.clock()<deadline and Race.ValidCount()>0 and not Race.AllFinished() do
		local remaining=math.max(0,math.ceil(deadline-os.clock())); if remaining~=lastSecond then announce(States.Racing,"比賽中",remaining); lastSecond=remaining end
		rankingPayload(); task.wait(Config.RankingUpdateInterval)
	end
	rankingPayload(); local results={}; local winner: Player?=nil
	for place,d in Race.Ranked() do d.IsRacing=false; d.IsEliminated=not d.IsFinished; table.insert(results,{rank=place,displayName=d.Player.DisplayName,finishTime=d.FinishTime,isFinished=d.IsFinished,checkpoint=d.CurrentCheckpoint,dnf=not d.IsFinished}); local stats=d.Player:FindFirstChild("leaderstats"); if stats then local rounds=stats:FindFirstChild("RoundsPlayed") :: IntValue?; if rounds then rounds.Value+=1 end; if d.IsFinished and d.FinishPlace==1 then winner=d.Player end; local best=stats:FindFirstChild("BestTime") :: NumberValue?; if best and d.FinishTime and (best.Value==0 or d.FinishTime<best.Value) then best.Value=d.FinishTime end end end
	if winner then local stats=winner:FindFirstChild("leaderstats"); local wins=stats and stats:FindFirstChild("Wins") :: IntValue?; if wins then wins.Value+=1 end end
	announce(States.Results,"本局結果",Config.ResultsTime); remotes.ResultsUpdated:FireAllClients(results); task.wait(Config.ResultsTime)
	announce(States.Resetting,"返回大廳",Config.BetweenRoundsTime); for _,p in Players:GetPlayers() do lobby(p) end; Race.Clear(); if barrier and barrier:IsA("BasePart") then barrier.CanCollide=true; barrier.Transparency=.25 end; task.wait(Config.BetweenRoundsTime)
end
