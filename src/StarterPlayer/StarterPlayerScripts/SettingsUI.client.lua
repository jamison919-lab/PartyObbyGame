--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local GuiService=game:GetService("GuiService")
print("[SettingsUI] client started")

local remotes=ReplicatedStorage:WaitForChild("Remotes",10)
if not remotes then warn("[SettingsUI] Remotes unavailable");return end
local update=remotes:WaitForChild("UpdateSettings",10)
local request=remotes:WaitForChild("RequestSettings",10)
local updated=remotes:WaitForChild("SettingsUpdated",10)
if not update or not update:IsA("RemoteEvent")then warn("[SettingsUI] UpdateSettings unavailable");return end

local defaults={MusicEnabled=true,SoundEnabled=true,ReducedEffects=false,ShowTutorialHints=true,ShowRankAbovePlayers=true,AutoOpenResults=true,UIScale="Normal"}
local values=table.clone(defaults)
local gui=Instance.new("ScreenGui");gui.Name="SettingsGui";gui.ResetOnSpawn=false;gui.Enabled=false;gui.IgnoreGuiInset=false;gui.Parent=Players.LocalPlayer.PlayerGui
local frame=Instance.new("Frame");frame.AnchorPoint=Vector2.new(.5,.5);frame.Position=UDim2.fromScale(.5,.5);frame.Size=UDim2.fromScale(.48,.8);frame.BackgroundColor3=Color3.fromRGB(30,38,55);frame.Parent=gui
local constraint=Instance.new("UISizeConstraint");constraint.MinSize=Vector2.new(300,300);constraint.MaxSize=Vector2.new(620,500);constraint.Parent=frame
local padding=Instance.new("UIPadding");padding.PaddingTop=UDim.new(0,12);padding.PaddingBottom=UDim.new(0,12);padding.PaddingLeft=UDim.new(0,12);padding.PaddingRight=UDim.new(0,12);padding.Parent=frame
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,4);layout.Parent=frame
local menuScale=Instance.new("UIScale");menuScale.Name="MenuScale";menuScale.Parent=frame
local buttons:{[string]:TextButton}={}
local function refresh(key:string) local button=buttons[key];if not button then return end;button.Text=key..(values[key]and ": ON"or ": OFF")end
for _,key in {"MusicEnabled","SoundEnabled","ReducedEffects","ShowTutorialHints","ShowRankAbovePlayers","AutoOpenResults"}do local button=Instance.new("TextButton");button.Name=key;button.Size=UDim2.new(1,0,0,34);button.Selectable=true;button.Parent=frame;buttons[key]=button;refresh(key);button.Activated:Connect(function()values[key]=not values[key];refresh(key);update:FireServer(key,values[key])end)end
local uiScale=Instance.new("TextButton");uiScale.Name="UIScale";uiScale.Size=UDim2.new(1,0,0,44);uiScale.Text="UI Scale: Normal";uiScale.Selectable=true;uiScale.Parent=frame;buttons.UIScale=uiScale
local options={"Small","Normal","Large"};uiScale.Activated:Connect(function()local index=table.find(options,values.UIScale)or 2;values.UIScale=options[index%#options+1];uiScale.Text="UI Scale: "..values.UIScale;menuScale.Scale=if values.UIScale=="Small"then .85 elseif values.UIScale=="Large"then 1.15 else 1;update:FireServer("UIScale",values.UIScale)end)
local close=Instance.new("TextButton");close.Name="Close";close.Size=UDim2.new(1,0,0,44);close.Text="關閉";close.Selectable=true;close.Parent=frame;close.Activated:Connect(function()gui.Enabled=false;GuiService.SelectedObject=nil end)
if updated and updated:IsA("RemoteEvent")then updated.OnClientEvent:Connect(function(data)if type(data)~="table"then return end;if data.key and defaults[data.key]~=nil then values[data.key]=data.value;if data.key=="UIScale"then uiScale.Text="UI Scale: "..tostring(data.value)else refresh(data.key)end else for key,default in defaults do local value=data[key];values[key]=if value==nil then default else value;if key~="UIScale"then refresh(key)end end end end)end
gui:GetPropertyChangedSignal("Enabled"):Connect(function()if gui.Enabled then GuiService.SelectedObject=buttons.MusicEnabled;if request and request:IsA("RemoteEvent")then request:FireServer()end end end)
if request and request:IsA("RemoteEvent")then request:FireServer()end
print("[SettingsUI] settings loaded")
