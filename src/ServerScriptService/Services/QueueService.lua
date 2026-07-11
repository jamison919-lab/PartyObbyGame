--!strict
local Modes=require(game:GetService("ReplicatedStorage").Modules.ModeConfig); local Mode=require(script.Parent.ModeService);local Profiles=require(script.Parent.PlayerProfileService)
local queues:{[string]:{Player}}={CasualRace={},RankedRace={}}; local pending:any=nil; local countdowns:{[string]:boolean}={}; local Service={}
local function removeFrom(list:{Player},p:Player) local i=table.find(list,p); if i then table.remove(list,i) end end
function Service.Leave(p:Player) local s=Mode.Get(p); if s.CurrentQueue and queues[s.CurrentQueue] then removeFrom(queues[s.CurrentQueue],p) end; s.CurrentQueue=nil;s.IsQueued=false end
function Service.Join(p:Player,id:string):boolean local config=Modes[id]; local s=Mode.Get(p); if not Profiles.IsProfileLoaded(p) or not config or config.IsSolo or s.IsInMatch or s.IsInTower or s.IsQueued or #queues[id]>=config.MaximumPlayers then return false end; table.insert(queues[id],p);s.CurrentMode=id;s.CurrentQueue=id;s.IsQueued=true;s.IsInLobby=true;s.JoinedQueueAt=os.clock();return true end
function Service.List(id:string):{Player} return table.clone(queues[id] or {}) end
function Service.StartCountdown(id:string,callback:()->()) if countdowns[id] then return end; countdowns[id]=true; task.spawn(function() task.wait(Modes[id].QueueDuration); countdowns[id]=nil; callback() end) end
function Service.LockMatch(id:string):any if pending then return nil end; local list=queues[id]; if not list or #list<Modes[id].MinimumPlayers then return nil end; local players=table.clone(list); table.clear(list); local matchId=id.."-"..tostring(math.floor(os.clock()*1000)); for _,p in players do local s=Mode.Get(p);s.IsQueued=false;s.CurrentQueue=nil;s.IsInLobby=false;s.IsInMatch=true;s.CurrentMode=id;s.CurrentMatchId=matchId;s.CurrentMapId="VillageRace01" end; pending={ModeId=id,MatchId=matchId,Players=players};return pending end
function Service.TakePending():any local value=pending;pending=nil;return value end
function Service.Count(id:string):number return #(queues[id] or {}) end
return Service
