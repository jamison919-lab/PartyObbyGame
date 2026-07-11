--!strict
local Players=game:GetService("Players")
local Race=require(script.Parent.Services.RaceService)
local function lobby(player: Player, character: Model)
	if Race.Get(player) then return end
	local map=workspace:WaitForChild("PartyObbyMap",10); local spawn=map and map:FindFirstChild("LobbySpawn")
	if spawn and spawn:IsA("BasePart") then character:PivotTo(spawn.CFrame+Vector3.new(0,3,0)) end
end
local function added(player: Player) player.CharacterAdded:Connect(function(c) task.wait(.15); lobby(player,c) end); if player.Character then task.defer(lobby,player,player.Character) end end
Players.PlayerAdded:Connect(added); Players.PlayerRemoving:Connect(function(p) Race.Remove(p) end)
for _,p in Players:GetPlayers() do added(p) end
