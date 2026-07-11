--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage");local Config=require(ReplicatedStorage.Modules.LeaderboardConfig);local Service=require(script.Parent.Services.GlobalLeaderboardService);local remotes=require(script.Parent.Services.RemoteService).Ensure()
task.spawn(function()while true do local payload={rank=Service.Refresh("Rank",false,Config.EntryCount),wins=Service.Refresh("Wins",false,Config.EntryCount),tower=Service.Refresh("Tower",true,Config.EntryCount)};remotes.LeaderboardUpdated:FireAllClients(payload);task.wait(Config.RefreshInterval) end end)
