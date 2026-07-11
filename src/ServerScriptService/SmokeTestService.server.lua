--!strict
local RunService=game:GetService("RunService");local ReplicatedStorage=game:GetService("ReplicatedStorage");local HttpService=game:GetService("HttpService");local Config=require(ReplicatedStorage.Modules.DevelopmentConfig)
if not RunService:IsStudio()or not Config.EnableSmokeTests then return end
local function test(name:string,fn:()->boolean)local ok,result=pcall(fn);if ok and result then print("[SmokeTest] PASS "..name)else warn("[SmokeTest] FAIL "..name..": "..tostring(result))end end
task.defer(function()
	local Maps=require(script.Parent.Services.MapService);local Catalog=require(ReplicatedStorage.Modules.MapCatalog)
	test("Remotes",function()return ReplicatedStorage:FindFirstChild("Remotes")~=nil end)
	test("LobbySpawn",function()local w=workspace:WaitForChild("PartyObbyWorld",10);return w.MainLobby:FindFirstChild("LobbySpawn")~=nil end)
	for id,d in Catalog do if d.IsEnabled then test("Map "..id,function()if d.Mode=="Race"then local ok=Maps.ValidateMap(id);return ok end;return true end)end end
	test("DataTemplate serializable",function()HttpService:JSONEncode(require(ReplicatedStorage.Modules.PlayerDataTemplate));return true end)
	test("Rank thresholds",function()local last=-1;for _,t in require(ReplicatedStorage.Modules.RankConfig).Tiers do if t.MinimumPoints<=last then return false end;last=t.MinimumPoints end;return true end)
	test("Audio zero safe",function()return require(ReplicatedStorage.Modules.AudioConfig).Sounds.Checkpoint==0 end)
end)
