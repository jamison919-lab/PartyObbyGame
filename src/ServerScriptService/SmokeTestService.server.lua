--!strict
local RunService=game:GetService("RunService");local ReplicatedStorage=game:GetService("ReplicatedStorage");local Config=require(ReplicatedStorage.Modules.DevelopmentConfig)
if not RunService:IsStudio()or not Config.EnableSmokeTests then return end
local counts={PASS=0,WARN=0,FAIL=0}
local function report(level:string,name:string,detail:any?)counts[level]+=1;local message=string.format("[SmokeTest] %s %s%s",level,name,if detail then ": "..tostring(detail)else "");if level=="FAIL"then warn(message)else print(message)end end
local function test(name:string,fn:()->(boolean,any?))local ok,result,detail=pcall(fn);if not ok then report("FAIL",name,result)elseif result then report("PASS",name)else report("FAIL",name,detail or "check returned false")end end
local function uniqueIds(module:any):(boolean,string?)local seen={};for key,value in module do local id=if type(value)=="table"then value.Id else key;if type(id)~="string"then return false,"missing Id at "..tostring(key)end;if seen[id]then return false,"duplicate "..id end;seen[id]=true end;return true,nil end
task.defer(function()
	local Maps=require(script.Parent.Services.MapService);local Catalog=require(ReplicatedStorage.Modules.MapCatalog);local TowerConfig=require(ReplicatedStorage.Modules.TowerConfig);local world=workspace:WaitForChild("PartyObbyWorld",10)
	test("MainLobby",function()return world~=nil and world:FindFirstChild("MainLobby")~=nil,"PartyObbyWorld/MainLobby missing"end)
	test("LobbySpawn",function()local lobby=world and world:FindFirstChild("MainLobby");return lobby~=nil and lobby:FindFirstChild("LobbySpawn")~=nil,"LobbySpawn missing"end)
	test("Portals",function()local portals=world and world:FindFirstChild("Portals");return portals~=nil and #portals:GetChildren()>=4,"expected Casual, Ranked, Tower01 and Tower02"end)
	local remotes=ReplicatedStorage:FindFirstChild("Remotes");for _,name in {"RoundStateChanged","CountdownUpdated","RankingUpdated","PlayerFinished","ResultsUpdated","ModeStateChanged","SettingsUpdated","TrackPenaltyUpdated"}do test("Remote "..name,function()return remotes~=nil and remotes:FindFirstChild(name)~=nil,name.." missing"end)end
	local raceMaps=0;for id,definition in Catalog do if definition.IsEnabled and definition.Mode=="Race"then raceMaps+=1;test("MapValidation "..id,function()local ok,errors=Maps.ValidateMap(id);return ok,table.concat(errors,", ")end)end end
	test("Three race maps",function()return raceMaps>=3,"found "..raceMaps end)
	local towers=world and world:FindFirstChild("TowerMaps");for id,definition in TowerConfig do test(id.." floors",function()local map=towers and towers:FindFirstChild(id);if not map then return false,id.." missing"end;local floors=map:FindFirstChild("Floors")or map;for i=1,definition.FloorCount do local floor=floors:FindFirstChild(string.format("Floor%02d",i));if not floor or (floor:GetAttribute("FloorIndex")or floor:GetAttribute("TowerFloor"))~=i then return false,"floor gap at "..i end end;return true end)end
	for name,module in {QuestConfig=require(ReplicatedStorage.Modules.QuestConfig),AchievementConfig=require(ReplicatedStorage.Modules.AchievementConfig),ShopConfig=require(ReplicatedStorage.Modules.ShopConfig)}do test(name.." unique ids",function()return uniqueIds(module)end)end
	test("Rank thresholds",function()local last=-1;for _,tier in require(ReplicatedStorage.Modules.RankConfig).Tiers do if tier.MinimumPoints<=last then return false,"threshold order"end;last=tier.MinimumPoints end;return true end)
	test("AudioId zero safe",function()local audio=require(ReplicatedStorage.Modules.AudioConfig);for _,id in audio.Tracks do if type(id)~="number"or id<0 then return false,"invalid track id"end end;return true end)
	test("Studio memory data",function()return require(script.Parent.Services.DataStoreServiceWrapper).IsMemoryMode(),"DataStore wrapper is not in memory mode"end)
	print(string.format("[SmokeTest] PASS: %d",counts.PASS));print(string.format("[SmokeTest] WARN: %d",counts.WARN));print(string.format("[SmokeTest] FAIL: %d",counts.FAIL))
end)
