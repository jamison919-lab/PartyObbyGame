--!strict
local Players=game:GetService("Players")
local GuiService=game:GetService("GuiService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("Remotes")
local Controller={}
local current:any={modeId=nil,isInLobby=true,isQueued=false,isInMatch=false,isInTower=false,roundState="Lobby"}
local heldItem=false
local large={"ModeSelectionGui","ShopGui","InventoryGui","RankGui","QuestGui","SettingsGui","TutorialGui"}
local enforcing=false
local function screen(name:string):ScreenGui?local item=playerGui:FindFirstChild(name);return if item and item:IsA("ScreenGui")then item else nil end
local function apply()
	local raceMode=current.modeId=="CasualRace"or current.modeId=="RankedRace"or current.mode=="CasualRace"or current.mode=="RankedRace";local lobby=(current.isInLobby==true or current.inLobby==true)and current.isQueued~=true;local tower=current.isInTower==true or current.inTower==true;local results=current.roundState=="Results"
	local lobbyGui=screen("LobbyGui");if lobbyGui then lobbyGui.Enabled=lobby end;local raceGui=screen("RaceGui");if raceGui then raceGui.Enabled=(raceMode or current.isInMatch==true or current.inMatch==true)and not tower end;local itemGui=screen("ItemGui");if itemGui then itemGui.Enabled=raceMode and not lobby and not tower and not results and heldItem end;local towerGui=screen("TowerGui");if towerGui then towerGui.Enabled=tower end;local queueGui=screen("QueueGui");if queueGui then queueGui.Enabled=current.isQueued==true end;local puzzleGui=screen("PuzzleGui");if puzzleGui then puzzleGui.Enabled=tower end
	if not lobby then for _,name in large do local gui=screen(name);if gui then gui.Enabled=false end end;GuiService.SelectedObject=nil end
end
function Controller.Update(data:any)if type(data)~="table"then return end;for key,value in data do current[key]=value end;if data.modeId~=nil then current.mode=data.modeId elseif data.mode~=nil then current.modeId=data.mode end;if data.inLobby~=nil then current.isInLobby=data.inLobby end;if data.inMatch~=nil then current.isInMatch=data.inMatch end;if data.inTower~=nil then current.isInTower=data.inTower end;if data.inTower==true or data.isInTower==true then current.isInLobby=false;current.isInMatch=false elseif data.inMatch==true or data.isInMatch==true then current.isInLobby=false;current.isInTower=false elseif data.inLobby==true or data.isInLobby==true then current.isInMatch=false;current.isInTower=false;current.isQueued=false end;if current.isInLobby then heldItem=false end;apply()end
function Controller.SetHeldItem(value:boolean)heldItem=value;apply()end
function Controller.OpenExclusive(name:string)if not current.isInLobby or enforcing then return end;enforcing=true;local selected:GuiObject?=nil;for _,guiName in large do local gui=screen(guiName);if gui then gui.Enabled=guiName==name;if guiName==name then selected=gui:FindFirstChildWhichIsA("GuiButton",true)end end end;GuiService.SelectedObject=selected;enforcing=false end
function Controller.Apply()apply()end
(remotes:WaitForChild("ModeStateChanged")::RemoteEvent).OnClientEvent:Connect(Controller.Update)
(remotes:WaitForChild("RoundStateChanged")::RemoteEvent).OnClientEvent:Connect(function(data)if type(data)=="table"then Controller.Update({roundState=data.state})end end)
local function watch(child:Instance)if not child:IsA("ScreenGui")then return end;if table.find(large,child.Name)then child:GetPropertyChangedSignal("Enabled"):Connect(function()if child.Enabled then Controller.OpenExclusive(child.Name)end end)end;task.defer(apply)end
playerGui.ChildAdded:Connect(watch);for _,child in playerGui:GetChildren()do watch(child)end
task.defer(function()apply();local request=remotes:FindFirstChild("RequestModeState");if request and request:IsA("RemoteEvent")then request:FireServer()end end)
return Controller
