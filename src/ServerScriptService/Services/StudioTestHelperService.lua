--!strict
local RunService=game:GetService("RunService")
local Config=require(game:GetService("ReplicatedStorage").Modules.DevelopmentConfig)
local Service={}
local enabled=RunService:IsStudio() and Config.EnableStudioTestHelpers
local function allowed():boolean if not enabled then warn("[StudioHelper] unavailable outside Studio");return false end;return true end
function Service.JoinCasual(player:Player):boolean if not allowed()then return false end;return require(script.Parent.QueueService).Join(player,"CasualRace")end
function Service.ForceNextMap(mapId:string)if not allowed()then return end;require(script.Parent.MapVoteService).SetForcedMap(mapId);print("[StudioHelper] next race map: "..mapId)end
function Service.TeleportToCheckpoint(player:Player,index:number):boolean if not allowed()then return false end;local mode=require(script.Parent.ModeService).Get(player);local map=mode.CurrentMatchId and require(script.Parent.MapService).GetLoadedMap(mode.CurrentMatchId);local cp=map and map:FindFirstChild("Checkpoints") and map.Checkpoints:FindFirstChild(string.format("Checkpoint%02d",index));local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");if cp and cp:IsA("BasePart")and root and root:IsA("BasePart")then root.CFrame=cp.CFrame+Vector3.new(0,4,0);return true end;return false end
function Service.TeleportToTowerFloor(player:Player,index:number):boolean if not allowed()then return false end;local session=require(script.Parent.TowerService).Get(player);local world=workspace:FindFirstChild("PartyObbyWorld");local map=session and world and world:FindFirstChild("TowerMaps") and world.TowerMaps:FindFirstChild(session.mapId);local floor=map and map:FindFirstChild(string.format("Floor%02d",index));local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");if floor and floor:IsA("BasePart")and root and root:IsA("BasePart")then root.CFrame=floor.CFrame+Vector3.new(0,4,0);return true end;return false end
function Service.ShowState(player:Player)local mode=require(script.Parent.ModeService).Get(player);local Registry=require(script.Parent.ConnectionRegistry);print(string.format("[StudioHelper] %s mode=%s match=%s map=%s connections=%d",player.Name,tostring(mode.CurrentMode),tostring(mode.CurrentMatchId),tostring(mode.CurrentMapId),Registry.GetActiveCount()))end
function Service.ReturnToLobby(player:Player)if allowed()then require(script.Parent.LobbyService).Return(player)end end
return Service
