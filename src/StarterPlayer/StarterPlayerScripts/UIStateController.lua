--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local playerGui=Players.LocalPlayer:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("Remotes")
local InputFocus=require(script.Parent.UIInputFocusController)
local Controller={RequiredStates=require(ReplicatedStorage.Modules.UIStateConfig).States}
print("[UIStateController] module loaded")
local state="Lobby";local heldItem=false;local large={"ModeSelectionGui","ShopGui","InventoryGui","RankGui","QuestGui","SettingsGui","TutorialGui"};local enforcing=false
local function screen(name:string):ScreenGui?local item=playerGui:FindFirstChild(name);return if item and item:IsA("ScreenGui")then item else nil end
local function enabled(name:string,value:boolean)local gui=screen(name);if gui then gui.Enabled=value end end
local function apply()
	local lobby=state=="Lobby";local race=state=="RacePreparing"or state=="RaceCountdown"or state=="Racing"or state=="RaceResults";local tower=state=="TowerPreparing"or state=="TowerCountdown"or state=="TowerRunning"or state=="TowerResults"
	enabled("LobbyGui",lobby);enabled("QueueGui",state=="Queue");enabled("MapVoteGui",state=="MapVote");enabled("RaceGui",race);enabled("TowerGui",tower);enabled("ItemGui",state=="Racing"and heldItem);enabled("PuzzleGui",tower);enabled("ProfileGui",true)
	local quest=screen("QuestGui");if quest and not lobby then quest.Enabled=false end;local daily=screen("DailyRewardGui");if daily then daily.Enabled=lobby end
	if not lobby then for _,name in large do enabled(name,false)end;InputFocus.EnterGameplayMode(state)end
end
function Controller.SetState(value:string)if not table.find(Controller.RequiredStates,value)then warn("[UIState] unknown state: "..value);return end;state=value;InputFocus.SetMode(value);apply();if value=="Lobby"then InputFocus.EnterGameplayMode(value);task.defer(InputFocus.PrintInputFocusState)end end
function Controller.GetState():string return state end
function Controller.Update(data:any)if type(data)~="table"then return end;if type(data.uiState)=="string"then Controller.SetState(data.uiState);return end;if data.inLobby==true then Controller.SetState("Lobby")elseif data.isQueued==true then Controller.SetState("Queue")elseif data.inTower==true then Controller.SetState("TowerPreparing")elseif data.inMatch==true then Controller.SetState("RacePreparing")end end
function Controller.SetHeldItem(value:boolean)heldItem=value;apply()end
function Controller.OpenExclusive(name:string)if state~="Lobby"or enforcing then return end;enforcing=true;local selected:GuiButton?=nil;local opened:ScreenGui?=nil;for _,guiName in large do local gui=screen(guiName);if gui then gui.Enabled=guiName==name;if guiName==name then opened=gui;selected=gui:FindFirstChildWhichIsA("GuiButton",true)end end end;if opened then InputFocus.OpenMenu(opened,selected)end;enforcing=false end
function Controller.Apply()apply()end
local modeStateRemote=remotes:WaitForChild("ModeStateChanged")::RemoteEvent
local mapVoteStartedRemote=remotes:WaitForChild("MapVoteStarted")::RemoteEvent
local mapSelectedRemote=remotes:WaitForChild("MapSelected")::RemoteEvent
local roundStateRemote=remotes:WaitForChild("RoundStateChanged")::RemoteEvent
modeStateRemote.OnClientEvent:Connect(Controller.Update)
mapVoteStartedRemote.OnClientEvent:Connect(function()Controller.SetState("MapVote")end)
mapSelectedRemote.OnClientEvent:Connect(function()Controller.SetState("RacePreparing")end)
roundStateRemote.OnClientEvent:Connect(function(data)if type(data)~="table"then return end;local map={Preparing="RacePreparing",Countdown="RaceCountdown",Racing="Racing",Results="RaceResults",Resetting="Lobby"};if map[data.state]then Controller.SetState(map[data.state])end end)
local function watch(child:Instance)if not child:IsA("ScreenGui")then return end;if table.find(large,child.Name)then child:GetPropertyChangedSignal("Enabled"):Connect(function()if child.Enabled then Controller.OpenExclusive(child.Name)else InputFocus.CloseMenu(child)end end)end;task.defer(apply)end
playerGui.ChildAdded:Connect(watch);for _,child in playerGui:GetChildren()do watch(child)end
Players.LocalPlayer.CharacterAdded:Connect(function()task.defer(function()if state=="Lobby"then InputFocus.EnterGameplayMode(state)end end)end)
task.defer(function()apply();InputFocus.EnterGameplayMode(state);local request=remotes:FindFirstChild("RequestModeState");if request and request:IsA("RemoteEvent")then request:FireServer()end;task.defer(InputFocus.PrintInputFocusState)end)
print("[UIStateController] initial mode: Lobby")
return Controller
