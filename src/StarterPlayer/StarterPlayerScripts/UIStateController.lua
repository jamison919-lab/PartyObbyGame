--!strict
local Players=game:GetService("Players");local GuiService=game:GetService("GuiService");local ReplicatedStorage=game:GetService("ReplicatedStorage");local playerGui=Players.LocalPlayer:WaitForChild("PlayerGui");local remotes=ReplicatedStorage:WaitForChild("Remotes")
local Controller={};Controller.RequiredStates=require(ReplicatedStorage.Modules.UIStateConfig).States
local state="Lobby";local heldItem=false;local large={"ModeSelectionGui","ShopGui","InventoryGui","RankGui","QuestGui","SettingsGui","TutorialGui"};local enforcing=false
local function screen(name:string):ScreenGui?local item=playerGui:FindFirstChild(name);return if item and item:IsA("ScreenGui")then item else nil end
local function enabled(name:string,value:boolean)local gui=screen(name);if gui then gui.Enabled=value end end
local function apply()
	local lobby=state=="Lobby";local race=state=="RacePreparing"or state=="RaceCountdown"or state=="Racing"or state=="RaceResults";local tower=state=="TowerPreparing"or state=="TowerCountdown"or state=="TowerRunning"or state=="TowerResults"
	enabled("LobbyGui",lobby);enabled("QueueGui",state=="Queue");enabled("MapVoteGui",state=="MapVote");enabled("RaceGui",race);enabled("TowerGui",tower);enabled("ItemGui",state=="Racing"and heldItem);enabled("PuzzleGui",tower);enabled("ProfileGui",true)
	local quest=screen("QuestGui");if quest and not lobby then quest.Enabled=false end;local daily=screen("DailyRewardGui");if daily then daily.Enabled=lobby end
	if not lobby then for _,name in large do enabled(name,false)end;GuiService.SelectedObject=nil end
end
function Controller.SetState(value:string)if not table.find(Controller.RequiredStates,value)then warn("[UIState] unknown state: "..value);return end;state=value;apply()end
function Controller.GetState():string return state end
function Controller.Update(data:any)if type(data)~="table"then return end;if type(data.uiState)=="string"then Controller.SetState(data.uiState);return end;if data.inLobby==true then Controller.SetState("Lobby")elseif data.isQueued==true then Controller.SetState("Queue")elseif data.inTower==true then Controller.SetState("TowerPreparing")elseif data.inMatch==true then Controller.SetState("RacePreparing")end end
function Controller.SetHeldItem(value:boolean)heldItem=value;apply()end
function Controller.OpenExclusive(name:string)if state~="Lobby"or enforcing then return end;enforcing=true;local selected:GuiObject?=nil;for _,guiName in large do local gui=screen(guiName);if gui then gui.Enabled=guiName==name;if guiName==name then selected=gui:FindFirstChildWhichIsA("GuiButton",true)end end end;GuiService.SelectedObject=selected;enforcing=false end
function Controller.Apply()apply()end
(remotes:WaitForChild("ModeStateChanged")::RemoteEvent).OnClientEvent:Connect(Controller.Update)
(remotes:WaitForChild("MapVoteStarted")::RemoteEvent).OnClientEvent:Connect(function()Controller.SetState("MapVote")end)
(remotes:WaitForChild("MapSelected")::RemoteEvent).OnClientEvent:Connect(function()Controller.SetState("RacePreparing")end)
(remotes:WaitForChild("RoundStateChanged")::RemoteEvent).OnClientEvent:Connect(function(data)if type(data)~="table"then return end;local map={Preparing="RacePreparing",Countdown="RaceCountdown",Racing="Racing",Results="RaceResults",Resetting="Lobby"};if map[data.state]then Controller.SetState(map[data.state])end end)
local function watch(child:Instance)if not child:IsA("ScreenGui")then return end;if table.find(large,child.Name)then child:GetPropertyChangedSignal("Enabled"):Connect(function()if child.Enabled then Controller.OpenExclusive(child.Name)end end)end;task.defer(apply)end
playerGui.ChildAdded:Connect(watch);for _,child in playerGui:GetChildren()do watch(child)end
task.defer(function()apply();local request=remotes:FindFirstChild("RequestModeState");if request and request:IsA("RemoteEvent")then request:FireServer()end end)
return Controller
