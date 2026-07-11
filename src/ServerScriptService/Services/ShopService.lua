--!strict
local Config=require(game:GetService("ReplicatedStorage").Modules.ShopConfig);local Profiles=require(script.Parent.PlayerProfileService);local Service={}
function Service.Catalog():any return Config end
function Service.Purchase(p:Player,id:string):(boolean,string) local item=Config.Cosmetics[id];if not Profiles.IsProfileLoaded(p) then return false,"資料尚未載入" end;if not item or not item.IsEnabled or item.CurrencyType~="Coins" then return false,"商品不可購買" end;if Profiles.OwnsCosmetic(p,id) then return false,"已經擁有" end;if not Profiles.PurchaseCosmetic(p,id,item.Price) then return false,"金幣不足" end;return true,"購買成功" end
return Service
