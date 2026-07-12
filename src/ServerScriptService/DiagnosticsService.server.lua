--!strict
local RunService=game:GetService("RunService")
local ServerScriptService=game:GetService("ServerScriptService")
local Config=require(game:GetService("ReplicatedStorage").Modules.DevelopmentConfig)
if not RunService:IsStudio()or not Config.EnableDiagnostics then return end
if ServerScriptService:GetAttribute("PartyObbyDiagnosticsStarted")then warn("[Diagnostics] duplicate initializer ignored");return end
ServerScriptService:SetAttribute("PartyObbyDiagnosticsStarted",true)
local Profiles=require(script.Parent.Services.PlayerProfileService);local Queue=require(script.Parent.Services.QueueService);local Tower=require(script.Parent.Services.TowerService);local Registry=require(script.Parent.Services.ConnectionRegistry);local remotes=require(script.Parent.Services.RemoteService).Ensure()
local elapsed=0;local sequence=0
Registry.Register(RunService.Heartbeat:Connect(function(delta)
	elapsed+=delta;if elapsed<Config.DiagnosticsInterval then return end;elapsed=0;sequence+=1
	local world=workspace:FindFirstChild("PartyObbyWorld");local runtime=world and world:FindFirstChild("Runtime");local matches=runtime and runtime:FindFirstChild("ActiveMatches");local items=workspace:FindFirstChild("TemporaryPartyItems")
	local payload={ActiveRuntimeMaps=matches and #matches:GetChildren()or 0,ActiveTemporaryItems=items and #items:GetChildren()or 0,LoadedProfiles=Profiles.CountLoaded(),QueuedPlayers=Queue.Count("CasualRace")+Queue.Count("RankedRace"),TowerRuns=Tower.Count(),RegisteredConnections=Registry.GetActiveCount(),ConnectionsByCategory=Registry.GetCountsByCategory(),ConnectionsByOwner=Registry.GetCountsByOwner(),Sequence=sequence}
	print(string.format("[Diagnostics] Sample=%d Maps=%d Items=%d Profiles=%d Queue=%d Towers=%d Connections=%d",sequence,payload.ActiveRuntimeMaps,payload.ActiveTemporaryItems,payload.LoadedProfiles,payload.QueuedPlayers,payload.TowerRuns,payload.RegisteredConnections));remotes.DiagnosticsUpdated:FireAllClients(payload)
end),"DiagnosticsService","Heartbeat")
