--!strict
local remotes=require(script.Parent.Services.RemoteService).Ensure();local Service=require(script.Parent.Services.MapVoteService);local rate:{[Player]:number}={}
remotes.SubmitMapVote.OnServerEvent:Connect(function(p,id)if typeof(id)~="string"or os.clock()-(rate[p]or 0)<.2 then return end;rate[p]=os.clock();Service.Submit(p,id)end)
