--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Catalog=require(ReplicatedStorage.Modules.MapCatalog)
local TowerConfig=require(ReplicatedStorage.Modules.TowerConfig)
local Builder=require(script.Parent.MapRuntimeService)
local Service={Loaded=Instance.new("BindableEvent")};local loaded:{[string]:Folder}={}
local function root():Folder local world=workspace:WaitForChild("PartyObbyWorld");return world:WaitForChild("Runtime"):WaitForChild("ActiveMatches")::Folder end
function Service.GetMapDefinition(id:string):any return Catalog[id]end
function Service.GetEligibleMaps(modeId:string):{any}local out={};for _,d in Catalog do if d.Mode=="Race"and d.IsEnabled and (modeId=="CasualRace"and d.SupportsMapVote or modeId=="RankedRace"and d.SupportsRanked)then table.insert(out,d)end end;return out end
local function validateRace(id:string,definition:any):(boolean,{string})
	local errors={};local test=Builder.Build(id);local starts=test:FindFirstChild("RaceStartSpawns");local checkpoints=test:FindFirstChild("Checkpoints")
	if not starts or #starts:GetChildren()<definition.MaximumPlayers then table.insert(errors,"insufficient StartSpawn")end;if not test:FindFirstChild("StartDirection")then table.insert(errors,"StartDirection missing")end
	if not checkpoints or #checkpoints:GetChildren()~=definition.CheckpointCount then table.insert(errors,"checkpoint count mismatch")end
	for i=1,definition.CheckpointCount do local cp=checkpoints and checkpoints:FindFirstChild(string.format("Checkpoint%02d",i));if not cp or cp:GetAttribute("CheckpointIndex")~=i then table.insert(errors,"CheckpointIndex gap at "..i)end end
	for _,name in {"FinishLine","KillFloor","TrackSurfaces","OffTrackZones","ItemBoxes"}do if not test:FindFirstChild(name)then table.insert(errors,name.." missing")end end;if not test:FindFirstChild("ItemBoxes")or #test.ItemBoxes:GetChildren()==0 then table.insert(errors,"reachable ItemBoxes missing")end;if test:GetAttribute("RuntimeCleanupReady")~=true then table.insert(errors,"runtime cleanup hook missing")end
	local zones=test:FindFirstChild("OffTrackZones");if zones then for _,zone in zones:GetChildren()do if not zone:IsA("BasePart")or zone:GetAttribute("OffTrackZone")~=true or type(zone:GetAttribute("PenaltyDurationMin"))~="number"then table.insert(errors,"invalid OffTrackZone: "..zone.Name)end end end
	test:Destroy();return #errors==0,errors
end
function Service.ValidateTower(id:string):(boolean,{string})
	local errors={};local definition=TowerConfig[id];if not definition then return false,{"tower config missing"}end
	local world=workspace:WaitForChild("PartyObbyWorld",10);local maps=world and world:WaitForChild("TowerMaps",10);local tower=maps and maps:WaitForChild(id,10);if not tower then return false,{"tower map missing"}end;tower:WaitForChild("ReturnToLobby",10)
	local deadline=os.clock()+5;while not tower:GetAttribute("PathValidationReady")and os.clock()<deadline do task.wait()end;if not tower:GetAttribute("PathValidationReady")then return false,{"tower path bootstrap not ready"}end
	local floors=tower:FindFirstChild("Floors");if not tower:FindFirstChild("TowerStart")then table.insert(errors,"TowerStart missing")end;if not floors or #floors:GetChildren()~=definition.FloorCount then table.insert(errors,"floor count mismatch")end
	for i=1,definition.FloorCount do local floor=floors and floors:FindFirstChild(string.format("Floor%02d",i));if not floor or floor:GetAttribute("FloorIndex")~=i or floor:GetAttribute("FloorCheckpoint")~=true then table.insert(errors,"FloorIndex gap at "..i)end end
	for _,name in {"FinishPlatform","TowerFinish","FinishDecoration","KillFloor","ReturnToLobby"}do if not tower:FindFirstChild(name)then table.insert(errors,name.." missing")end end
	local finishPlatform=tower:FindFirstChild("FinishPlatform");if not finishPlatform or not finishPlatform:IsA("BasePart")or not finishPlatform.CanCollide or finishPlatform.Size.X<10 or finishPlatform.Size.Z<10 or finishPlatform:GetAttribute("PlatformType")~="Finish"then table.insert(errors,"FinishPlatform invalid")end
	local finishTrigger=tower:FindFirstChild("TowerFinish");if not finishTrigger or not finishTrigger:IsA("BasePart")or finishTrigger.CanCollide or not finishTrigger.CanTouch or finishTrigger:GetAttribute("IgnoreTowerPathValidation")~=true then table.insert(errors,"TowerFinish trigger invalid")end
	local pathValidator=require(script.Parent.TowerPathValidator);for _,result in pathValidator.Validate(tower)do if result.Level=="FAIL"then table.insert(errors,result.Message)end end
	local spawnValidator=require(script.Parent.TowerSpawnService);local spawnOk,spawnErrors=spawnValidator.ValidateTowerSpawn(tower);if not spawnOk then for _,spawnError in spawnErrors do table.insert(errors,spawnError)end end
	return #errors==0,errors
end
function Service.ValidateMap(id:string):(boolean,{string})local definition=Catalog[id];if not definition then return false,{"catalog missing"}end;if definition.Mode=="Tower"then return Service.ValidateTower(id)end;return validateRace(id,definition)end
function Service.LoadMap(matchId:string,mapId:string):Folder?local ok,errors=Service.ValidateMap(mapId);if not ok then warn("[MapService] invalid "..mapId..": "..table.concat(errors,", "));return nil end;Service.UnloadMap(matchId);local map=Builder.Build(mapId);map.Name=matchId;map:SetAttribute("MapId",mapId);map.Parent=root();loaded[matchId]=map;Service.Loaded:Fire(matchId,map);return map end
function Service.GetLoadedMap(matchId:string):Folder?return loaded[matchId]end
function Service.GetMapSpawnPoints(matchId:string):Instance?local m=loaded[matchId];return m and m:FindFirstChild("RaceStartSpawns")end
function Service.GetCheckpoints(matchId:string):Instance?local m=loaded[matchId];return m and m:FindFirstChild("Checkpoints")end
function Service.GetFinishLine(matchId:string):BasePart?local m=loaded[matchId];local x=m and m:FindFirstChild("FinishLine");return if x and x:IsA("BasePart")then x else nil end
function Service.UnloadMap(matchId:string)local registry=require(script.Parent.ConnectionRegistry);registry.DisconnectOwner("Map:"..matchId);local m=loaded[matchId];loaded[matchId]=nil;if m then m:Destroy()end end
return Service
