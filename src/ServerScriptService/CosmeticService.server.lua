--!strict
local Cosmetic=require(script.Parent.Services.CosmeticService);local remotes=require(script.Parent.Services.RemoteService).Ensure();local rate:{[Player]:number}={}
remotes.EquipCosmetic.OnServerEvent:Connect(function(p,id)if typeof(id)~="string" or os.clock()-(rate[p] or 0)<.4 then return end;rate[p]=os.clock();local ok,msg=Cosmetic.Equip(p,id);remotes.PurchaseResult:FireClient(p,{success=ok,message=msg})end)
remotes.UnequipCosmetic.OnServerEvent:Connect(function(p,slot)if typeof(slot)~="string" or os.clock()-(rate[p] or 0)<.4 then return end;rate[p]=os.clock();local ok,msg=Cosmetic.Unequip(p,slot);remotes.PurchaseResult:FireClient(p,{success=ok,message=msg})end)
