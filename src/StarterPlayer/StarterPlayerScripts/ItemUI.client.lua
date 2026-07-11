--!strict
local Players=game:GetService("Players"); local ReplicatedStorage=game:GetService("ReplicatedStorage"); local player=Players.LocalPlayer
local folder=ReplicatedStorage:WaitForChild("Remotes",10); if not folder then warn("[ItemUI] Remotes missing"); return end
local granted=folder:WaitForChild("ItemGranted",10) :: RemoteEvent; local used=folder:WaitForChild("ItemUsed",10) :: RemoteEvent; local message=folder:WaitForChild("ItemMessage",10) :: RemoteEvent
local gui=Instance.new("ScreenGui"); gui.Name="ItemGui"; gui.ResetOnSpawn=false; gui.Parent=player.PlayerGui
local frame=Instance.new("Frame"); frame.Name="ItemSlot"; frame.Position=UDim2.fromScale(.39,.82); frame.Size=UDim2.fromScale(.22,.12); frame.BackgroundColor3=Color3.fromRGB(28,32,48); frame.BackgroundTransparency=.15; frame.Parent=gui; Instance.new("UICorner",frame).CornerRadius=UDim.new(.15,0)
local label=Instance.new("TextLabel"); label.Name="ItemLabel"; label.Size=UDim2.fromScale(1,.58); label.BackgroundTransparency=1; label.Text="沒有道具"; label.TextColor3=Color3.new(1,1,1); label.TextScaled=true; label.Font=Enum.Font.GothamBold; label.Parent=frame
local button=Instance.new("TextButton"); button.Name="UseItemButton"; button.Position=UDim2.fromScale(.08,.6); button.Size=UDim2.fromScale(.84,.32); button.Text="使用道具  [Q / X]"; button.TextScaled=true; button.BackgroundColor3=Color3.fromRGB(255,145,55); button.BackgroundTransparency=.65; button.Active=false; button.Parent=frame; Instance.new("UICorner",button).CornerRadius=UDim.new(.2,0)
local notice=Instance.new("TextLabel"); notice.Position=UDim2.fromScale(.28,.7); notice.Size=UDim2.fromScale(.44,.08); notice.BackgroundTransparency=1; notice.Text=""; notice.TextScaled=true; notice.TextColor3=Color3.fromRGB(255,235,100); notice.Font=Enum.Font.GothamBold; notice.Parent=gui
local function flash(text:string) notice.Text=text; task.delay(2,function() if notice.Text==text then notice.Text="" end end) end
granted.OnClientEvent:Connect(function(data) label.Text=string.format("%s  %s",data.icon,data.name); button.Active=true; button.BackgroundTransparency=.05; flash("獲得："..data.name); frame.Size=UDim2.fromScale(.24,.13); task.delay(.2,function() frame.Size=UDim2.fromScale(.22,.12) end) end)
used.OnClientEvent:Connect(function(data) label.Text="沒有道具"; button.Active=false; button.BackgroundTransparency=.65; if not data.cleared then flash("已使用："..tostring(data.name)) end end)
message.OnClientEvent:Connect(flash)
