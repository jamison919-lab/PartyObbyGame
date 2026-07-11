--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RankingUtils = require(ReplicatedStorage.Modules.RankingUtils)

export type RaceData = {
	UserId: number, Player: Player, IsRacing: boolean, IsFinished: boolean,
	CurrentCheckpoint: number, SegmentProgress: number, FinishPlace: number?,
	FinishTime: number?, StartTime: number, LastValidCFrame: CFrame?, HasFinished: boolean,
	IsEliminated: boolean, SpawnIndex: number, ProgressReachedAt: number,
	OriginalWalkSpeed: number?, OriginalJumpPower: number?, OriginalJumpHeight: number?,
}

local Service = { State = "WaitingForPlayers", RoundNumber = 0, FinishCount = 0 }
local records: {[Player]: RaceData} = {}

function Service.Get(player: Player): RaceData? return records[player] end
function Service.All(): {[Player]: RaceData} return records end
function Service.Clear() table.clear(records); Service.FinishCount = 0 end
function Service.Remove(player: Player) records[player] = nil end
function Service.Add(player: Player, spawnIndex: number, spawnCFrame: CFrame)
	records[player] = { UserId=player.UserId, Player=player, IsRacing=false, IsFinished=false,
		CurrentCheckpoint=0, SegmentProgress=0, FinishPlace=nil, FinishTime=nil, StartTime=0,
		LastValidCFrame=spawnCFrame, HasFinished=false, IsEliminated=false, SpawnIndex=spawnIndex,
		ProgressReachedAt=os.clock(), OriginalWalkSpeed=nil, OriginalJumpPower=nil, OriginalJumpHeight=nil }
end
function Service.Lock(player: Player, locked: boolean)
	local data = records[player]; local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not data or not humanoid then return end
	if locked then
		data.OriginalWalkSpeed = humanoid.WalkSpeed; data.OriginalJumpPower = humanoid.JumpPower; data.OriginalJumpHeight = humanoid.JumpHeight
		humanoid.WalkSpeed = 0; humanoid.JumpPower = 0; humanoid.JumpHeight = 0
	else
		humanoid.WalkSpeed = data.OriginalWalkSpeed or 16; humanoid.JumpPower = data.OriginalJumpPower or 50; humanoid.JumpHeight = data.OriginalJumpHeight or 7.2
	end
end
function Service.Teleport(player: Player, cf: CFrame)
	local character = player.Character or player.CharacterAdded:Wait()
	character:PivotTo(cf + Vector3.new(0, 3, 0))
end
function Service.ValidCount(): number
	local n=0; for player in records do if player.Parent == Players then n += 1 end end; return n
end
function Service.AllFinished(): boolean
	local any=false; for player,data in records do if player.Parent==Players then any=true; if not data.IsFinished then return false end end end; return any
end
function Service.Ranked(): {RaceData}
	local list = {}; for player,data in records do if player.Parent==Players then table.insert(list,data) end end
	return RankingUtils.sort(list)
end
return Service
