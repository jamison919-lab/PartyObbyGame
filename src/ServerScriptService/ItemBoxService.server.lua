--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Race=require(script.Parent.Services.RaceService)
local ItemService=require(script.Parent.Services.ItemService)
local ItemUtils=require(ReplicatedStorage.Modules.ItemUtils)
local map=workspace:WaitForChild("PartyObbyMap",10); if not map then error("[ItemBox] PartyObbyMap missing") end
local folder=map:WaitForChild("ItemBoxes",10); if not folder then error("[ItemBox] ItemBoxes missing") end
local connected:{[BasePart]:boolean}={}; local debounce:{[BasePart]:{[Player]:number}}={}
local function playerFromHit(hit:BasePart):Player? local node:Instance?=hit; while node and node~=workspace do if node:IsA("Model") and node:FindFirstChildOfClass("Humanoid") then return Players:GetPlayerFromCharacter(node) end; node=node.Parent end; return nil end
local function connect(box:Instance)
	if not box:IsA("BasePart") or connected[box] then return end; connected[box]=true; debounce[box]={}
	box.Touched:Connect(function(hit)
		local p=playerFromHit(hit); if not p then return end; local d=Race.Get(p); if Race.State~="Racing" or not d or not d.IsRacing or d.IsFinished or d.HeldItemId then return end
		local now=os.clock(); if (debounce[box][p] or 0)>now or box.Transparency>=1 then return end; debounce[box][p]=now+1
		local ranked=Race.Ranked(); local rank=1; for i,data in ranked do if data.Player==p then rank=i; break end end
		local id=ItemUtils.choose(rank,#ranked,d.LastItemId); if ItemService.Grant(p,id) then print(string.format("[ItemBox] %s received %s",p.Name,id)); box.Transparency=1; box.CanTouch=false; for _,v in box:GetDescendants() do if v:IsA("GuiObject") then v.Visible=false end end; task.delay(math.random(30,50)/10,function() if box.Parent then box.Transparency=.2; box.CanTouch=true; for _,v in box:GetDescendants() do if v:IsA("GuiObject") then v.Visible=true end end end end) end
	end)
end
for _,box in folder:GetChildren() do connect(box) end; folder.ChildAdded:Connect(connect)
