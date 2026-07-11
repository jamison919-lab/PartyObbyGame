--!strict
local Players=game:GetService("Players");local Race=require(script.Parent.Services.RaceService);local remotes=require(script.Parent.Services.RemoteService).Ensure()
Players.PlayerRemoving:Connect(function(p) Race.Remove(p) end)
remotes.ClientReady.OnServerEvent:Connect(function(player) remotes.RoundStateChanged:FireClient(player,Race.StatePayload());local data=Race.Get(player);remotes.PlayerProgressUpdated:FireClient(player,{checkpoint=if data then data.CurrentCheckpoint else 0});print(string.format("[Round] sent current state to %s",player.Name)) end)
