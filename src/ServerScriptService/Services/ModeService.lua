--!strict
local Players=game:GetService("Players")
export type State={CurrentMode:string?,CurrentQueue:string?,IsQueued:boolean,IsInMatch:boolean,IsInLobby:boolean,IsInTower:boolean,CurrentMapId:string?,CurrentMatchId:string?,JoinedQueueAt:number,ReturnedToLobbyAt:number,IsTransitioning:boolean}
local states:{[Player]:State}={}; local Service={}
function Service.Get(p:Player):State local s=states[p]; if not s then s={CurrentMode=nil,CurrentQueue=nil,IsQueued=false,IsInMatch=false,IsInLobby=true,IsInTower=false,CurrentMapId=nil,CurrentMatchId=nil,JoinedQueueAt=0,ReturnedToLobbyAt=0,IsTransitioning=false}; states[p]=s end; return s end
function Service.ResetToLobby(p:Player) local s=Service.Get(p); s.CurrentMode=nil;s.CurrentQueue=nil;s.IsQueued=false;s.IsInMatch=false;s.IsInLobby=true;s.IsInTower=false;s.CurrentMapId=nil;s.CurrentMatchId=nil;s.ReturnedToLobbyAt=os.clock();s.IsTransitioning=false end
function Service.Payload(p:Player,roundState:string?):any local s=Service.Get(p);return{modeId=s.CurrentMode,mode=s.CurrentMode,isInLobby=s.IsInLobby,inLobby=s.IsInLobby,isQueued=s.IsQueued,inQueue=s.IsQueued,isInMatch=s.IsInMatch,inMatch=s.IsInMatch,isInTower=s.IsInTower,inTower=s.IsInTower,roundState=roundState or(if s.IsInLobby then"Lobby"elseif s.IsInTower then"Tower"elseif s.IsQueued then"Queue"else"Race"),mapId=s.CurrentMapId,matchId=s.CurrentMatchId}end
Players.PlayerRemoving:Connect(function(p) states[p]=nil end); return Service
