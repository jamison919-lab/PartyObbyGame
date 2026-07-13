--!strict
local world=workspace:WaitForChild("PartyObbyWorld")
local towerMaps=world:WaitForChild("TowerMaps")

local PLATFORM_HEIGHT=4
local FLOOR_RISE=12
local ANGLE_STEP=math.rad(45)
local obstacleTypes={Tower01={"BlockSteps","MovingBlocks","Spinner","Disappear","WindBridge","PushBox","SequenceButtons","MovingWallMaze","Elevator","FinalCombo"},Tower02={"TutorialSteps","AlternatingBlocks","MovingPlatform","RotatingBlades","Disappear","ColorSequence","PushBox","Maze","Elevator","SafeLightWall","Pendulum","FinalSpiral"}}

local function resizeAt(platform:BasePart,size:Vector3,position:Vector3,platformType:string,floorIndex:number)
	platform.Size=size;platform.Position=position;platform.Material=if platformType=="Checkpoint"then Enum.Material.Cobblestone else Enum.Material.WoodPlanks
	platform:SetAttribute("IsTowerPlatform",true);platform:SetAttribute("PlatformType",platformType);platform:SetAttribute("FloorIndex",floorIndex);platform:SetAttribute("RequiredPath",true)
end

local function addNode(folder:Folder,order:number,target:BasePart)
	local node=Instance.new("Part");node.Name=string.format("JumpNode%02d",order);node.Size=Vector3.new(1,1,1);node.Position=target.Position+Vector3.new(0,target.Size.Y/2+.5,0);node.Anchored=true;node.CanCollide=false;node.CanQuery=false;node.CanTouch=false;node.Transparency=1;node:SetAttribute("JumpOrder",order);node:SetAttribute("RequiredPath",true);node:SetAttribute("IsTowerPlatform",false);node:SetAttribute("DecorativeObject",true);node.Parent=folder
	local value=Instance.new("ObjectValue");value.Name="TargetPlatform";value.Value=target;value.Parent=node
end

local function point(base:Vector3,radius:number,angle:number,y:number):Vector3
	return Vector3.new(base.X+math.cos(angle)*radius,y,base.Z+math.sin(angle)*radius)
end

local function rebuild(tower:Folder,floorCount:number,radius:number,prefix:string)
	local start=tower:WaitForChild("TowerStart")::BasePart;local base=Vector3.new(start.Position.X,start.Position.Y,start.Position.Z);resizeAt(start,Vector3.new(18,PLATFORM_HEIGHT,18),base,"Checkpoint",0)
	local floors=tower:WaitForChild("Floors");local previousPosition=base
	for floorIndex=1,floorCount do
		local angle=(floorIndex-1)*ANGLE_STEP;local target=point(base,radius,angle,base.Y+floorIndex*FLOOR_RISE);local floor=floors:WaitForChild(string.format("Floor%02d",floorIndex))::BasePart
		local floorWidth=if floorIndex==1 then 10 else if floorIndex==2 then 14 else 12;resizeAt(floor,Vector3.new(floorWidth,PLATFORM_HEIGHT,floorWidth),target,"Checkpoint",floorIndex)
		floor:SetAttribute("FloorCheckpoint",true);floor:SetAttribute("ObstacleType",obstacleTypes[tower.Name][floorIndex]);floor:SetAttribute("DifficultyStep",floorIndex)
		local nodes=floor:FindFirstChild("JumpNodes");if nodes then nodes:Destroy()end;nodes=Instance.new("Folder");nodes.Name="JumpNodes";nodes.Parent=floor
		for step=1,2 do
			local platform=tower:WaitForChild(string.format(prefix,floorIndex,step))::BasePart;local alpha=step/3;local position=previousPosition:Lerp(target,alpha)
			if floorIndex==1 then local firstRadius=if tower.Name=="Tower02"then 17 else 16;local secondRadius=if tower.Name=="Tower02"then 31 else 27;position=point(base,if step==1 then firstRadius else secondRadius,0,base.Y+step*(FLOOR_RISE/3))end
			resizeAt(platform,Vector3.new(if tower.Name=="Tower02"then 9 else 8,PLATFORM_HEIGHT,if tower.Name=="Tower02"then 9 else 8),position,"Normal",floorIndex);addNode(nodes::Folder,step,platform)
		end
		addNode(nodes::Folder,3,floor);previousPosition=target
	end
	local finishPlatform=tower:WaitForChild("FinishPlatform")::BasePart;local radial=Vector3.new(previousPosition.X-base.X,0,previousPosition.Z-base.Z);local outward=if math.abs(radial.X)>=math.abs(radial.Z)then Vector3.new(if radial.X>=0 then 1 else-1,0,0)else Vector3.new(0,0,if radial.Z>=0 then 1 else-1);local finishPosition=previousPosition+outward*17;resizeAt(finishPlatform,Vector3.new(16,PLATFORM_HEIGHT,16),finishPosition,"Finish",floorCount+1);finishPlatform.Color=Color3.fromRGB(255,220,60);finishPlatform.CanCollide=true;finishPlatform.CanTouch=true
	local finish=tower:WaitForChild("TowerFinish")::BasePart;finish.Size=Vector3.new(14,8,14);finish.Position=finishPosition+Vector3.new(0,6,0);finish.Anchored=true;finish.CanCollide=false;finish.CanTouch=true;finish.CanQuery=false;finish.Transparency=1;finish:SetAttribute("IsTowerPlatform",false);finish:SetAttribute("RequiredPath",false);finish:SetAttribute("IgnoreTowerPathValidation",true);finish:SetAttribute("TriggerType","TowerFinish")
	local decoration=tower:WaitForChild("FinishDecoration")::BasePart;decoration.Position=finishPosition+outward*10+Vector3.new(0,6,0);decoration.CanCollide=false;decoration.CanTouch=false;decoration.CanQuery=false;decoration:SetAttribute("DecorativeObject",true);decoration:SetAttribute("IgnoreTowerPathValidation",true)
	local column=tower:FindFirstChild("CentralTowerColumn")or Instance.new("Part");local columnBottom=base.Y+20;local columnHeight=(floorCount+1)*FLOOR_RISE-20;column.Name="CentralTowerColumn";column.Size=Vector3.new(12,columnHeight,12);column.Position=Vector3.new(base.X,columnBottom+columnHeight/2,base.Z);column.Anchored=true;column.CanCollide=true;column.Material=Enum.Material.Brick;column.Color=Color3.fromRGB(190,125,75);column:SetAttribute("IsTowerPlatform",false);column:SetAttribute("DecorativeObject",false);column:SetAttribute("IgnoreTowerPathValidation",false);column.Parent=tower
	tower:SetAttribute("GeometryStyle","BlockSpiral");tower:SetAttribute("PathValidationReady",true)
end

rebuild(towerMaps:WaitForChild("Tower01")::Folder,10,38,"Step%02d_%d")
rebuild(towerMaps:WaitForChild("Tower02")::Folder,12,45,"Tower02Step%02d_%d")
