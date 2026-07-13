--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ContextActionService=game:GetService("ContextActionService")
local RunService=game:GetService("RunService")
local Controller=require(script.Parent.UIStateController)
local InputFocus=require(script.Parent.UIInputFocusController)
local player=Players.LocalPlayer
print("[TowerUI] client started")
local folder=ReplicatedStorage:WaitForChild("Remotes",10)
if not folder then warn("[TowerUI] Remotes missing");return end
local progress=folder:WaitForChild("TowerProgressUpdated")::RemoteEvent
local back=folder:WaitForChild("ReturnToLobby")::RemoteEvent
local achievementRemote=folder:WaitForChild("AchievementUnlocked")::RemoteEvent
local questRemote=folder:WaitForChild("QuestUpdated")::RemoteEvent
print("[TowerUI] remotes found")

local old=player.PlayerGui:FindFirstChild("TowerGui")
if old then old:Destroy()end
local gui=Instance.new("ScreenGui");gui.Name="TowerGui";gui.ResetOnSpawn=false;gui.Enabled=false;gui.IgnoreGuiInset=false;gui.Parent=player.PlayerGui
local frame=Instance.new("Frame");frame.Position=UDim2.fromScale(.025,.035);frame.Size=UDim2.fromScale(.26,.3);frame.BackgroundColor3=Color3.fromRGB(35,30,55);frame.BackgroundTransparency=.12;frame.Parent=gui
local constraint=Instance.new("UISizeConstraint");constraint.MinSize=Vector2.new(260,190);constraint.MaxSize=Vector2.new(390,220);constraint.Parent=frame
local padding=Instance.new("UIPadding");padding.PaddingTop=UDim.new(0,8);padding.PaddingLeft=UDim.new(0,8);padding.PaddingRight=UDim.new(0,8);padding.PaddingBottom=UDim.new(0,8);padding.Parent=frame
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,3);layout.Parent=frame
local function makeLabel(name:string,height:number):TextLabel local item=Instance.new("TextLabel");item.Name=name;item.Size=UDim2.new(1,0,0,height);item.BackgroundTransparency=1;item.TextColor3=Color3.new(1,1,1);item.TextScaled=true;item.TextXAlignment=Enum.TextXAlignment.Left;item.Parent=frame;return item end
local floorText=makeLabel("Floor",30);local elapsedText=makeLabel("Elapsed",27);local bestText=makeLabel("Best",27);local message=makeLabel("Message",48);message.TextWrapped=true;message.TextColor3=Color3.fromRGB(255,225,80)
local button=Instance.new("TextButton");button.Name="ReturnToLobby";button.Size=UDim2.new(1,0,0,34);button.Text="返回大廳";button.TextScaled=true;button.Selectable=true;button.Parent=frame;button.Activated:Connect(function()back:FireServer()end)
local serverStart=0;local running=false;local best=0;local lastUpdate=0
local function formatTime(seconds:number):string local minutes=math.floor(seconds/60);return string.format("%02d:%04.1f",minutes,seconds-minutes*60)end
RunService.RenderStepped:Connect(function()if not running then return end;local now=os.clock();if now-lastUpdate<.1 then return end;lastUpdate=now;elapsedText.Text="經過時間 "..formatTime(math.max(0,workspace:GetServerTimeNow()-serverStart))end)
progress.OnClientEvent:Connect(function(data)
	if data.state=="Countdown"or type(data.countdown)=="number"then Controller.SetState("TowerCountdown")elseif data.state=="Running"then Controller.SetState("TowerRunning")elseif data.completed then Controller.SetState("TowerResults")end
	best=data.best or best;bestText.Text="最佳時間 "..(best>0 and formatTime(best)or"--");floorText.Text=string.format("樓層 %d/%d",data.floor or 0,data.total or 0)
	if type(data.countdown)=="number"then message.Text=tostring(data.countdown)elseif data.countdown=="GO"then serverStart=data.serverStartTime or workspace:GetServerTimeNow();running=true;message.Text="GO!";task.delay(.85,function()if message.Text=="GO!"then message.Text=""end end)elseif data.completed then running=false;elapsedText.Text="完成時間 "..formatTime(data.time or 0);message.Text=(data.newBest and"新最佳紀錄！　"or"")..string.format("+%d Coins",data.coinsEarned or 0);if data.returnIn then button.Text=string.format("返回大廳（%d 秒）",data.returnIn)end elseif data.serverStartTime then serverStart=data.serverStartTime;running=true;if(data.floorCoins or 0)>0 then message.Text="樓層獎勵 +"..data.floorCoins.." Coins";task.delay(1.2,function()if message.Text:find("樓層獎勵",1,true)then message.Text=""end end)end end
end)
achievementRemote.OnClientEvent:Connect(function(data)if Controller.GetState()=="TowerResults"then message.Text=message.Text.."\n新成就："..tostring(data.name or data.id)end end)
questRemote.OnClientEvent:Connect(function(data)if Controller.GetState()~="TowerResults"or type(data)~="table"then return end;for _,quest in data.quests or{}do if quest.progress>=quest.target and not quest.claimed then message.Text=message.Text.."\n任務完成："..quest.name;break end end end)
local function towerReturn(_,inputState)if inputState==Enum.UserInputState.Begin and gui.Enabled then back:FireServer();return Enum.ContextActionResult.Sink end;return Enum.ContextActionResult.Pass end
gui:GetPropertyChangedSignal("Enabled"):Connect(function()InputFocus.ClearSelection();if gui.Enabled then ContextActionService:BindAction("TowerReturn",towerReturn,false,Enum.KeyCode.ButtonB)else running=false;ContextActionService:UnbindAction("TowerReturn")end end)
print("[TowerUI] state initialized")
