--!strict
local DataStoreService=game:GetService("DataStoreService");local RunService=game:GetService("RunService");local ReplicatedStorage=game:GetService("ReplicatedStorage");local Config=require(ReplicatedStorage.Modules.DataConfig)
local Wrapper={};local memory:{[string]:any}={};local memoryMode=RunService:IsStudio() and Config.ForceMemoryModeInStudio and Config.StudioMemoryFallback;local warned=false;local store:GlobalDataStore?=nil
local function clone(value:any):any if type(value)~="table" then return value end;local result={};for k,v in value do result[k]=clone(v) end;return result end
local function announce()if memoryMode and not warned then warned=true;print("[Data] Studio memory mode enabled")end end
function Wrapper.IsMemoryMode():boolean return memoryMode end
function Wrapper.CanUsePersistentDataStores():boolean return not memoryMode end
function Wrapper.CanUseOrderedDataStores():boolean return Config.EnableOrderedDataStores and not memoryMode and (not RunService:IsStudio() or Config.EnableOrderedDataStoresInStudio) end
local function persistentStore():GlobalDataStore if not store then store=DataStoreService:GetDataStore(Config.DataStoreName) end;return store end
function Wrapper.Load(key:string,template:any):(any,boolean,string?)
	if memoryMode then announce();local created=memory[key]==nil;local value=memory[key] or clone(template);memory[key]=value;return clone(value),true,created and "created" or nil end
	local realStore=persistentStore();local acquired=false;local locked=false;local loaded:any=nil;local ok=false;local err:any=nil
	for attempt=1,Config.SaveRetryCount do acquired=false;locked=false;ok,err=pcall(function()realStore:UpdateAsync(key,function(old)local data=if type(old)=="table" then old else clone(template);local session=data.Session;local now=os.time();if type(session)=="table" and session.JobId~="" and session.JobId~=game.JobId and now-(session.LockedAt or 0)<Config.SessionLockTimeout then locked=true;return nil end;data.Session={JobId=game.JobId,PlaceId=game.PlaceId,LockedAt=now};loaded=clone(data);acquired=true;return data end)end);if ok and acquired then return loaded,false,nil end;if locked then break end;task.wait(Config.RetryBaseDelay*attempt)end
	return nil,false,locked and "profile locked by another server" or tostring(err)
end
function Wrapper.Save(key:string,data:any,release:boolean,memoryProfile:boolean):(boolean,string?)
	local copy=clone(data)
	if memoryMode or memoryProfile then announce();copy.Session={JobId="",PlaceId=0,LockedAt=0};memory[key]=copy;return true,nil end
	copy.Session=if release then {JobId="",PlaceId=0,LockedAt=0} else {JobId=game.JobId,PlaceId=game.PlaceId,LockedAt=os.time()};local realStore=persistentStore();local ok,err=pcall(function()realStore:UpdateAsync(key,function(old)if type(old)=="table" and type(old.Session)=="table" and old.Session.JobId~="" and old.Session.JobId~=game.JobId then return nil end;return copy end)end);return ok,if ok then nil else tostring(err)
end
function Wrapper.Ordered(name:string):OrderedDataStore? if not Wrapper.CanUseOrderedDataStores() then return nil end;return DataStoreService:GetOrderedDataStore(name) end
return Wrapper
