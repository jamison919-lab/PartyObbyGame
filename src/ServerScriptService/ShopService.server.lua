--!strict
local Players=game:GetService("Players");local Shop=require(script.Parent.Services.ShopService);local Profiles=require(script.Parent.Services.PlayerProfileService);local remotes=require(script.Parent.Services.RemoteService).Ensure();local last:{[Player]:{[string]:number}}={}
local function allowed(p:Player,key:string,delay:number):boolean local t=last[p] or {};last[p]=t;local now=os.clock();if now-(t[key] or 0)<delay then return false end;t[key]=now;return true end
remotes.RequestShopCatalog.OnServerEvent:Connect(function(p)if allowed(p,"catalog",.5) then remotes.ShopCatalogUpdated:FireClient(p,Shop.Catalog()) end end)
remotes.PurchaseWithCoins.OnServerEvent:Connect(function(p,id)if typeof(id)~="string" or not allowed(p,"buy",1) then return end;local ok,message=Shop.Purchase(p,id);remotes.PurchaseResult:FireClient(p,{success=ok,message=message,itemId=id,profile=Profiles.GetPublicProfileSnapshot(p)})end)
Players.PlayerRemoving:Connect(function(p)last[p]=nil end)
