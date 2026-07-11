--!strict
local Players=game:GetService("Players");local ReplicatedStorage=game:GetService("ReplicatedStorage");local DataConfig=require(ReplicatedStorage.Modules.DataConfig);local Wrapper=require(script.Parent.DataStoreServiceWrapper)
local Service={Cache={Rank={},Wins={},Tower={}}};local memory:{[string]:{[number]:any}}={Rank={},Wins={},Tower={}};local stores:{[string]:OrderedDataStore?}={}
if Wrapper.CanUseOrderedDataStores() then stores.Rank=Wrapper.Ordered(DataConfig.OrderedRankStoreName);stores.Wins=Wrapper.Ordered(DataConfig.OrderedWinsStoreName);stores.Tower=Wrapper.Ordered(DataConfig.OrderedTowerStoreName)else print("[Leaderboard] using Studio memory leaderboard")end
function Service.Update(p:Player,kind:string,value:number)
	if kind=="Tower" and value<=0 then return end
	if not Wrapper.CanUseOrderedDataStores() then memory[kind][p.UserId]={name=p.DisplayName,value=math.floor(value)};return end
	local store=stores[kind];if store then task.spawn(function()local ok,err=pcall(store.SetAsync,store,tostring(p.UserId),math.floor(value));if not ok then warn("[Leaderboard] update failed: "..tostring(err))end end)end
end
function Service.Refresh(kind:string,ascending:boolean,count:number):{any}
	if not Wrapper.CanUseOrderedDataStores() then local values={};for userId,entry in memory[kind] do table.insert(values,{userId=userId,name=entry.name,value=entry.value})end;table.sort(values,function(a,b)return ascending and a.value<b.value or a.value>b.value end);local result={};for rank=1,math.min(count,#values)do local entry=values[rank];entry.rank=rank;table.insert(result,entry)end;Service.Cache[kind]=result;return result end
	local store=stores[kind];if not store then return Service.Cache[kind]end;local ok,pages=pcall(store.GetSortedAsync,store,ascending,count);if not ok then return Service.Cache[kind]end;local result={};for rank,entry in pages:GetCurrentPage()do local userId=tonumber(entry.key)or 0;local name="Player "..entry.key;local success,value=pcall(Players.GetNameFromUserIdAsync,Players,userId);if success then name=value end;table.insert(result,{rank=rank,userId=userId,name=name,value=entry.value})end;Service.Cache[kind]=result;return result
end
return Service
