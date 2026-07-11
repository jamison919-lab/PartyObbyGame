--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Race=require(script.Parent.Services.RaceService)
local RemoteService=require(script.Parent.Services.RemoteService)
local remotes=RemoteService.Ensure()
local function lobby(player: Player, character: Model)
	if Race.Get(player) then return end
	local map=workspace:WaitForChild("PartyObbyMap",10); local spawn=map and map:FindFirstChild("LobbySpawn")
	if spawn and spawn:IsA("BasePart") then character:PivotTo(spawn.CFrame+Vector3.new(0,3,0)) end
end
local function added(player: Player)
	player.CharacterAdded:Connect(function(c) task.wait(.15); lobby(player,c) end)
	if player.Character then task.defer(lobby,player,player.Character) end
	-- A late-joining client receives the authoritative current state immediately.
end
Players.PlayerAdded:Connect(added); Players.PlayerRemoving:Connect(function(p) Race.Remove(p) end)
for _,p in Players:GetPlayers() do added(p) end
remotes.ClientReady.OnServerEvent:Connect(function(player)
	remotes.RoundStateChanged:FireClient(player,Race.StatePayload())
	local data=Race.Get(player); remotes.PlayerProgressUpdated:FireClient(player,{checkpoint=if data then data.CurrentCheckpoint else 0})
	print(string.format("[Round] sent current state to %s",player.Name))
end)
