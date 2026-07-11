--!strict
local Race=require(script.Parent.RaceService);local Mode=require(script.Parent.ModeService);local Queue=require(script.Parent.QueueService);local Items=require(script.Parent.ItemService);local Movement=require(script.Parent.MovementModifierService);local Tower=require(script.Parent.TowerService);local remotes=require(script.Parent.RemoteService).Ensure()
local Service={}
function Service.Return(p:Player)
	Queue.Leave(p);Tower.Leave(p);Race.Remove(p);Items.ClearPlayer(p);Movement.ClearTemporaryModifiers(p);Mode.ResetToLobby(p)
	local world=workspace:FindFirstChild("PartyObbyWorld") or workspace:WaitForChild("PartyObbyWorld",10);local lobby=world and (world:FindFirstChild("MainLobby") or world:WaitForChild("MainLobby",5));local spawn=lobby and lobby:FindFirstChild("LobbySpawn");local fountain=lobby and lobby:FindFirstChild("VillageFountain")
	if spawn and spawn:IsA("BasePart") then Race.TeleportFacing(p,spawn,if fountain and fountain:IsA("BasePart") then fountain else nil,8) end
	remotes.ModeStateChanged:FireClient(p,{inLobby=true,inMatch=false,inTower=false});remotes.PlayerProgressUpdated:FireClient(p,{checkpoint=0})
	print(string.format("[Lobby] %s returned to main lobby",p.Name))
end
return Service
