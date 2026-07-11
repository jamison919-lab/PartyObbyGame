--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
print("[RaceUI] client started")
local old=player.PlayerGui:FindFirstChild("RaceGui"); if old then old:Destroy() end
local gui=Instance.new("ScreenGui"); gui.Name="RaceGui"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.Parent=player.PlayerGui
gui.Enabled=false
local function panel(name:string,pos:UDim2,size:UDim2): Frame local f=Instance.new("Frame"); f.Name=name; f.Position=pos; f.Size=size; f.BackgroundColor3=Color3.fromRGB(18,24,38); f.BackgroundTransparency=.18; f.Parent=gui; local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(.08,0); c.Parent=f; local s=Instance.new("UIStroke"); s.Color=Color3.fromRGB(98,210,255); s.Transparency=.35; s.Parent=f; return f end
local function text(parent:Instance,name:string,value:string,pos:UDim2,size:UDim2,scaled:boolean?):TextLabel local t=Instance.new("TextLabel"); t.Name=name;t.Text=value;t.Position=pos;t.Size=size;t.BackgroundTransparency=1;t.TextColor3=Color3.new(1,1,1);t.Font=Enum.Font.GothamBold;t.TextScaled=scaled~=false;t.TextXAlignment=Enum.TextXAlignment.Left;t.Parent=parent;return t end
local status=panel("Status",UDim2.fromScale(.025,.04),UDim2.fromScale(.28,.12)); local stateText=text(status,"State","正在連線伺服器…",UDim2.fromScale(.05,.08),UDim2.fromScale(.9,.42)); local timeText=text(status,"Time","",UDim2.fromScale(.05,.54),UDim2.fromScale(.9,.3))
local info=panel("RaceInfo",UDim2.fromScale(.72,.04),UDim2.fromScale(.255,.13)); local rankText=text(info,"Rank","名次 -- / --",UDim2.fromScale(.05,.08),UDim2.fromScale(.9,.35)); local cpText=text(info,"Checkpoint","檢查點 0 / 3",UDim2.fromScale(.05,.55),UDim2.fromScale(.9,.3))
local board=panel("Ranking",UDim2.fromScale(.72,.19),UDim2.fromScale(.255,.46)); text(board,"Title","即時排名",UDim2.fromScale(.06,.02),UDim2.fromScale(.88,.1)); local list=text(board,"List","",UDim2.fromScale(.06,.14),UDim2.fromScale(.88,.82),false); list.TextSize=16; list.TextYAlignment=Enum.TextYAlignment.Top
local countdown=text(gui,"Countdown","",UDim2.fromScale(.35,.27),UDim2.fromScale(.3,.25)); countdown.TextXAlignment=Enum.TextXAlignment.Center; countdown.TextColor3=Color3.fromRGB(255,225,75); countdown.TextStrokeTransparency=.2
local results=panel("Results",UDim2.fromScale(.2,.18),UDim2.fromScale(.6,.62)); results.Visible=false; local resultText=text(results,"Text","",UDim2.fromScale(.06,.05),UDim2.fromScale(.88,.9),false); resultText.TextSize=20; resultText.TextYAlignment=Enum.TextYAlignment.Top
local folder=ReplicatedStorage:WaitForChild("Remotes",10)
if not folder then stateText.Text="連線失敗：找不到 Remotes"; error("[RaceUI] ReplicatedStorage.Remotes not found after 10 seconds") end
local function remote(name:string): RemoteEvent
	local item=folder:WaitForChild(name,10)
	if not item or not item:IsA("RemoteEvent") then stateText.Text="連線失敗：缺少 "..name; error("[RaceUI] missing RemoteEvent: "..name) end
	return item
end
local roundStateChanged=remote("RoundStateChanged")
local countdownUpdated=remote("CountdownUpdated")
local rankingUpdated=remote("RankingUpdated")
local playerFinished=remote("PlayerFinished")
local resultsUpdated=remote("ResultsUpdated")
local clientReady=remote("ClientReady")
local playerProgressUpdated=remote("PlayerProgressUpdated")
print("[RaceUI] remotes found")
local modeState=remote("ModeStateChanged")
modeState.OnClientEvent:Connect(function(data) gui.Enabled=data.inMatch==true or data.mode=="CasualRace" or data.mode=="RankedRace" end)
local lastState=""
roundStateChanged.OnClientEvent:Connect(function(d)
	stateText.Text=d.message or d.state; timeText.Text=(d.timeRemaining and d.timeRemaining>0) and ("剩餘 "..d.timeRemaining.." 秒") or ""
	if d.state~="Results" then results.Visible=false end
	if d.state~=lastState then lastState=d.state; print("[RaceUI] received state: "..tostring(d.state)) end
end)
countdownUpdated.OnClientEvent:Connect(function(v) countdown.Text=tostring(v); task.delay(.85,function() if countdown.Text==tostring(v) then countdown.Text="" end end) end)
playerFinished.OnClientEvent:Connect(function(data)
	if data.blocked then
		countdown.Text=data.message or "請先通過所有檢查點"
		task.delay(2,function() if countdown.Text==data.message then countdown.Text="" end end)
	end
end)
playerProgressUpdated.OnClientEvent:Connect(function(data) cpText.Text=string.format("檢查點 %d / 3",data.checkpoint or 0) end)
rankingUpdated.OnClientEvent:Connect(function(rows) local lines={}; for _,r in rows do local me=r.userId==player.UserId; table.insert(lines,string.format("%s%d. %s  CP %d%s",me and "▶ " or "",r.rank,r.displayName,r.checkpoint,r.isFinished and " ✓" or "")); if me then rankText.Text=string.format("名次 %d / %d",r.rank,#rows); cpText.Text=string.format("檢查點 %d / %d",r.checkpoint,r.totalCheckpoints or 3) end end; list.Text=table.concat(lines,"\n") end)
resultsUpdated.OnClientEvent:Connect(function(rows) local lines={"本局排名",""}; for _,r in rows do table.insert(lines,string.format("%d. %s — %s",r.rank,r.displayName,r.isFinished and string.format("%.2f 秒",r.finishTime) or "DNF")) end; resultText.Text=table.concat(lines,"\n"); results.Visible=true end)
clientReady:FireServer()
print("[RaceUI] requested current round state")
