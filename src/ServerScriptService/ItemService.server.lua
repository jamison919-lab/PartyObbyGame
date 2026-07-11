--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local remotes=require(script.Parent.Services.RemoteService).Ensure()
local Items=require(script.Parent.Services.ItemService)
local requests:{[Player]:number}={}
remotes.UseItem.OnServerEvent:Connect(function(player)
	local now=os.clock(); if now-(requests[player] or 0)<.2 then return end; requests[player]=now; Items.Use(player)
end)
game:GetService("Players").PlayerRemoving:Connect(function(p) requests[p]=nil end)
