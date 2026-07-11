--!strict
local Players=game:GetService("Players")
local Debris=game:GetService("Debris")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Items=require(ReplicatedStorage.Modules.ItemConfig)
local Race=require(script.Parent.RaceService)
local Movement=require(script.Parent.MovementModifierService)
local remotes=require(script.Parent.RemoteService).Ensure()
local Events=require(script.Parent.GameplayEventService);local Service={}; local temporary=Instance.new("Folder"); temporary.Name="TemporaryPartyItems"; temporary.Parent=workspace
local function message(p:Player,text:string) remotes.ItemMessage:FireClient(p,text) end
local function validTarget(p:Player):boolean local d=Race.Get(p); local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid"); return Race.State=="Racing" and d~=nil and d.IsRacing and not d.IsFinished and h~=nil and h.Health>0 end
local function blocked(p:Player,itemId:string):boolean local d=Race.Get(p); if not d then return true end; if d.ShieldActive and (itemId=="BananaPeel" or itemId=="CrazyChicken" or itemId=="StinkyTofuBomb") then d.ShieldActive=false; d.ShieldExpiresAt=0; local shield=p.Character and p.Character:FindFirstChild("UmbrellaShieldVisual"); if shield then shield:Destroy() end; message(p,"雨傘盾牌擋住攻擊！"); print(string.format("[Item] %s blocked %s with shield",p.Name,itemId)); return true end; return os.clock()<d.ControlImmuneUntil end
local function hit(p:Player,itemId:string,multiplier:number,duration:number)
	local d=Race.Get(p); if not d or not validTarget(p) or blocked(p,itemId) then return end
	d.ControlImmuneUntil=os.clock()+1.5; Movement.AddModifier(p,itemId.."Slow",multiplier,duration); message(p,itemId=="BananaPeel" and "踩到香蕉皮！" or "被道具撞到了！")
	local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid"); if itemId=="BananaPeel" and h then h:ChangeState(Enum.HumanoidStateType.FallingDown); task.delay(1.2,function() if h.Parent then h:ChangeState(Enum.HumanoidStateType.GettingUp) end end) end
	if itemId=="CrazyChicken" then local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if root and root:IsA("BasePart") then root.AssemblyLinearVelocity=Vector3.new(math.clamp(root.AssemblyLinearVelocity.X,-18,18),math.min(root.AssemblyLinearVelocity.Y+5,18),math.clamp(root.AssemblyLinearVelocity.Z,-18,18)) end end
	print(string.format("[Item] %s hit by %s",p.Name,itemId))
end
function Service.Grant(p:Player,itemId:string):boolean local d=Race.Get(p); local item=Items[itemId]; if not d or not item or not validTarget(p) or d.HeldItemId then return false end; d.HeldItemId=itemId; d.LastItemId=itemId; d.ItemGrantedAt=os.clock(); remotes.ItemGranted:FireClient(p,{id=itemId,name=item.DisplayName,icon=item.IconText}); return true end
local function banana(p:Player,root:BasePart)
	local peel=Instance.new("Part"); peel.Name="BananaPeel"; peel.Size=Vector3.new(2,.3,2); peel.Color=Color3.fromRGB(255,225,35); peel.Material=Enum.Material.Neon; peel.Anchored=true; peel.CanCollide=false; peel.CFrame=root.CFrame*CFrame.new(0,-2.7,3); peel.Parent=temporary; Debris:AddItem(peel,15)
	local used:{[Player]:boolean}={}; peel.Touched:Connect(function(part) local target=Players:GetPlayerFromCharacter(part.Parent); if target and target~=p and not used[target] then used[target]=true; hit(target,"BananaPeel",.55,1.2) end end); print(string.format("[Item] %s dropped BananaPeel",p.Name))
end
local function chicken(p:Player,root:BasePart)
	local bird=Instance.new("Part"); bird.Name="CrazyChicken"; bird.Shape=Enum.PartType.Ball; bird.Size=Vector3.new(2.5,2.5,2.5); bird.Color=Color3.new(1,1,1); bird.Anchored=true; bird.CanCollide=false; bird.CFrame=root.CFrame*CFrame.new(0,0,-5); bird.Parent=temporary; Debris:AddItem(bird,6.5)
	task.spawn(function() local untilTime=os.clock()+6; while bird.Parent and os.clock()<untilTime do local target:Player?=nil; local best=80; for other in Race.All() do if other~=p and validTarget(other) then local r=other.Character and other.Character:FindFirstChild("HumanoidRootPart"); if r and r:IsA("BasePart") then local dist=(r.Position-bird.Position).Magnitude; if dist<best then best=dist; target=other end end end end; if target then local r=target.Character and target.Character:FindFirstChild("HumanoidRootPart"); if r and r:IsA("BasePart") then local delta=r.Position-bird.Position; bird.Position+=delta.Unit*math.min(3,delta.Magnitude); if delta.Magnitude<3 then hit(target,"CrazyChicken",.75,2); bird:Destroy(); break end end else bird.CFrame*=CFrame.new(0,0,-2) end; task.wait(.15) end end)
end
local function tofu(p:Player,root:BasePart)
	local zone=Instance.new("Part"); zone.Name="StinkyTofuCloud"; zone.Shape=Enum.PartType.Ball; zone.Size=Vector3.new(14,6,14); zone.Color=Color3.fromRGB(90,210,80); zone.Transparency=.55; zone.Material=Enum.Material.Neon; zone.Anchored=true; zone.CanCollide=false; zone.CFrame=root.CFrame*CFrame.new(0,-1,-10); zone.Parent=temporary; Debris:AddItem(zone,4)
	local debounce:{[Player]:number}={}; zone.Touched:Connect(function(part) local target=Players:GetPlayerFromCharacter(part.Parent); if target and target~=p and (debounce[target] or 0)<os.clock() then debounce[target]=os.clock()+.5; if not blocked(target,"StinkyTofuBomb") then Movement.AddModifier(target,"StinkyTofuSlow",.7,1); message(target,"臭豆腐太臭了！") end end end)
end
function Service.Use(p:Player):boolean
	local d=Race.Get(p); if not d or not validTarget(p) or not d.HeldItemId or os.clock()<d.ItemCooldownUntil or os.clock()-d.LastItemUseAt<.25 then return false end
	local id=d.HeldItemId; local item=Items[id]; local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if not root or not root:IsA("BasePart") then return false end
	d.HeldItemId=nil; d.LastItemUseAt=os.clock(); d.ItemCooldownUntil=os.clock()+item.Cooldown; remotes.ItemUsed:FireClient(p,{id=id,name=item.DisplayName});Events.Event:Fire(p,"ItemUsed",1); print(string.format("[Item] %s used %s",p.Name,id))
	if id=="BananaPeel" then banana(p,root) elseif id=="CrazyChicken" then chicken(p,root) elseif id=="StinkyTofuBomb" then tofu(p,root)
	elseif id=="ChiliBoost" then d.BoostExpiresAt=os.clock()+item.Duration; Movement.AddModifier(p,"ChiliBoost",item.EffectStrength,item.Duration); local glow=Instance.new("Highlight"); glow.Name="ChiliBoostVisual"; glow.FillColor=Color3.fromRGB(255,65,25); glow.FillTransparency=.35; glow.OutlineTransparency=1; glow.Parent=p.Character; Debris:AddItem(glow,item.Duration)
	elseif id=="SpringShoes" then d.SpringJumpActive=true; Movement.SetSpringJump(p,item.EffectStrength,true); local marker=Instance.new("BillboardGui"); marker.Name="SpringShoesVisual"; marker.Size=UDim2.fromScale(4,1); marker.StudsOffset=Vector3.new(0,-2,0); marker.Adornee=root; marker.Parent=p.Character; local text=Instance.new("TextLabel"); text.Size=UDim2.fromScale(1,1); text.BackgroundTransparency=1; text.Text="SPRING!"; text.TextScaled=true; text.TextColor3=Color3.fromRGB(90,255,120); text.Parent=marker; Debris:AddItem(marker,item.Duration); local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid"); if h then local connection:RBXScriptConnection?; connection=h.Jumping:Connect(function(active) if active and d.SpringJumpActive then d.SpringJumpActive=false; Movement.SetSpringJump(p,item.EffectStrength,false); marker:Destroy(); if connection then connection:Disconnect() end end end); task.delay(item.Duration,function() if d.SpringJumpActive then d.SpringJumpActive=false; Movement.SetSpringJump(p,item.EffectStrength,false) end; if connection then connection:Disconnect() end end) end
	elseif id=="UmbrellaShield" then d.ShieldActive=true; d.ShieldExpiresAt=os.clock()+item.Duration; local visual=Instance.new("Part"); visual.Name="UmbrellaShieldVisual"; visual.Shape=Enum.PartType.Ball; visual.Size=Vector3.new(7,7,7); visual.Transparency=.72; visual.Color=Color3.fromRGB(90,190,255); visual.Material=Enum.Material.ForceField; visual.CanCollide=false; visual.Massless=true; visual.Parent=p.Character; visual.CFrame=root.CFrame; local weld=Instance.new("WeldConstraint"); weld.Part0=visual; weld.Part1=root; weld.Parent=visual; Debris:AddItem(visual,item.Duration); task.delay(item.Duration,function() if d.ShieldExpiresAt<=os.clock() then d.ShieldActive=false end end) end
	return true
end
function Service.ClearPlayer(p:Player) local d=Race.Get(p); if d then d.HeldItemId=nil; d.ShieldActive=false; d.SpringJumpActive=false; table.clear(d.ActiveEffects) end; Movement.ClearTemporaryModifiers(p); remotes.ItemUsed:FireClient(p,{cleared=true}) end
function Service.ClearEffects(p:Player) local d=Race.Get(p); if d then d.ShieldActive=false; d.SpringJumpActive=false; d.ControlImmuneUntil=os.clock()+2 end; Movement.ClearTemporaryModifiers(p); remotes.TrackPenaltyUpdated:FireClient(p,{active=false}); local shield=p.Character and p.Character:FindFirstChild("UmbrellaShieldVisual"); if shield then shield:Destroy() end end
function Service.ClearAll()
	for p in Race.All() do Service.ClearPlayer(p) end; temporary:ClearAllChildren()
	local map=workspace:FindFirstChild("PartyObbyMap"); local boxes=map and map:FindFirstChild("ItemBoxes")
	if boxes then for _,box in boxes:GetChildren() do if box:IsA("BasePart") then box.Transparency=.2; box.CanTouch=true; for _,v in box:GetDescendants() do if v:IsA("GuiObject") then v.Visible=true end end end end end
	print("[Round] cleared temporary items and effects")
end
function Service.AbsorbAttack(p:Player,itemId:string):boolean return blocked(p,itemId) end
return Service
