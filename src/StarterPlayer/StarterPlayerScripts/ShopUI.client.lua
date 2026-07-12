--!strict
local Players=game:GetService("Players");local ReplicatedStorage=game:GetService("ReplicatedStorage");local GuiService=game:GetService("GuiService");local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("Remotes",10);if not remotes then return end
local catalogRemote=remotes:WaitForChild("ShopCatalogUpdated")::RemoteEvent;local request=remotes:WaitForChild("RequestShopCatalog")::RemoteEvent;local buy=remotes:WaitForChild("PurchaseWithCoins")::RemoteEvent;local equip=remotes:WaitForChild("EquipCosmetic")::RemoteEvent;local requestProduct=remotes:WaitForChild("RequestProductPurchase")::RemoteEvent;local requestPass=remotes:WaitForChild("RequestGamePassPurchase")::RemoteEvent;local monetization=require(ReplicatedStorage.Modules.MonetizationConfig)
local gui=Instance.new("ScreenGui");gui.Name="ShopGui";gui.ResetOnSpawn=false;gui.Enabled=false;gui.IgnoreGuiInset=false;gui.Parent=player.PlayerGui
local frame=Instance.new("Frame");frame.AnchorPoint=Vector2.new(.5,.5);frame.Position=UDim2.fromScale(.5,.5);frame.Size=UDim2.fromScale(.7,.78);frame.BackgroundColor3=Color3.fromRGB(28,34,50);frame.Parent=gui
local constraint=Instance.new("UISizeConstraint");constraint.MinSize=Vector2.new(340,360);constraint.MaxSize=Vector2.new(900,620);constraint.Parent=frame
local title=Instance.new("TextLabel");title.Size=UDim2.fromScale(.8,.1);title.BackgroundTransparency=1;title.Text="爆笑村民商店";title.TextScaled=true;title.TextColor3=Color3.new(1,1,1);title.Parent=frame
local close=Instance.new("TextButton");close.Position=UDim2.fromScale(.88,.02);close.Size=UDim2.fromScale(.09,.07);close.Text="X";close.Selectable=true;close.Parent=frame;close.Activated:Connect(function()gui.Enabled=false;GuiService.SelectedObject=nil end)
local scroll=Instance.new("ScrollingFrame");scroll.Position=UDim2.fromScale(.04,.12);scroll.Size=UDim2.fromScale(.92,.82);scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.BackgroundTransparency=1;scroll.Parent=frame;local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,6);layout.Parent=scroll
local firstButton:TextButton?=nil
local function row(text:string,color:Color3,callback:()->())local holder=Instance.new("Frame");holder.Size=UDim2.new(1,-8,0,60);holder.BackgroundColor3=color;holder.Parent=scroll;local button=Instance.new("TextButton");button.Size=UDim2.fromScale(1,1);button.Text=text;button.TextWrapped=true;button.TextScaled=true;button.Selectable=true;button.Parent=holder;if not firstButton then firstButton=button end;button.Activated:Connect(callback)end
catalogRemote.OnClientEvent:Connect(function(catalog)
	for _,child in scroll:GetChildren()do if child:IsA("Frame")then child:Destroy()end end;firstButton=nil;local items=catalog.Items or catalog.Cosmetics or {};local list={};for _,item in items do table.insert(list,item)end;table.sort(list,function(a,b)return(a.SortOrder or 0)<(b.SortOrder or 0)end)
	for _,item in list do row(string.format("%s　%d Coins　[%s]\n%s",item.DisplayName,item.Price,item.Rarity,item.Description),Color3.fromRGB(50,62,85),function()buy:FireServer(item.Id);task.delay(.3,function()equip:FireServer(item.Id)end)end)end
	for id,product in monetization.Products do row(product.DisplayName..(product.ProductId==0 and "　[尚未設定]"or ""),Color3.fromRGB(65,48,85),function()requestProduct:FireServer(id)end)end
	for id,pass in monetization.GamePasses do row(pass.DisplayName..(pass.GamePassId==0 and "　[尚未設定]"or ""),Color3.fromRGB(85,65,35),function()requestPass:FireServer(id)end)end
	GuiService.SelectedObject=firstButton or close
end)
gui:GetPropertyChangedSignal("Enabled"):Connect(function()if gui.Enabled then request:FireServer();GuiService.SelectedObject=close end end)
