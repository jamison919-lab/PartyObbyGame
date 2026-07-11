--!strict
local Players=game:GetService("Players");local ReplicatedStorage=game:GetService("ReplicatedStorage");local Modes=require(ReplicatedStorage.Modules.ModeConfig);local Queue=require(script.Parent.Services.QueueService);local Mode=require(script.Parent.Services.ModeService);local Tower=require(script.Parent.Services.TowerService);local remotes=require(script.Parent.Services.RemoteService).Ensure()
local rate:{[Player]:number}={}
local function broadcast(id:string,remaining:number?) local list=Queue.List(id);local names={};for _,p in list do table.insert(names,p.DisplayName) end;remotes.QueueUpdated:FireAllClients({mode=id,count=#list,max=Modes[id].MaximumPlayers,remaining=remaining,players=names}) end
local function beginCountdown(id:string)
	Queue.StartCountdown(id,function()
		if Queue.Count(id)<Modes[id].MinimumPlayers then broadcast(id,nil);return end
		local match=Queue.LockMatch(id);if match then print(string.format("[Match] selected racers: %s",table.concat((function() local n={};for _,p in match.Players do table.insert(n,p.Name) end;return n end)(),", "))) else task.delay(1,beginCountdown,id) end
	end)
	task.spawn(function() print(string.format("[Match] %s countdown started",id));for t=Modes[id].QueueDuration,1,-1 do if Queue.Count(id)<Modes[id].MinimumPlayers then break end;broadcast(id,t);task.wait(1) end end)
end
local function select(p:Player,id:string)
	if os.clock()-(rate[p] or 0)<.5 then return end;rate[p]=os.clock();local config=Modes[id];if not config then return end;print(string.format("[Mode] %s selected %s",p.Name,id))
	if id=="SoloTower" then Queue.Leave(p);Tower.Start(p);return end
	if Queue.Join(p,id) then print(string.format("[Queue] %s joined %s %d/%d",p.Name,id,Queue.Count(id),config.MaximumPlayers));broadcast(id,nil);if Queue.Count(id)>=config.MinimumPlayers then beginCountdown(id) end end
end
remotes.SelectMode.OnServerEvent:Connect(select);remotes.LeaveQueue.OnServerEvent:Connect(function(p) Queue.Leave(p);remotes.ModeStateChanged:FireClient(p,{inLobby=true}) end)
task.spawn(function() local world=workspace:WaitForChild("PartyObbyWorld",10);local lobby=world and world:FindFirstChild("MainLobby");if lobby then for _,x in lobby:GetChildren() do local prompt=x:FindFirstChildOfClass("ProximityPrompt");local id=x:GetAttribute("ModeId");if prompt and typeof(id)=="string" then prompt.Triggered:Connect(function(p) remotes.OpenMenu:FireClient(p,{confirmMode=id}) end) end end end end)
Players.PlayerRemoving:Connect(function(p) Queue.Leave(p);rate[p]=nil end)
