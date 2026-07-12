--!strict
local Service={}
local function part(parent:Instance,name:string,size:Vector3,cf:CFrame,color:Color3,collide:boolean?):Part local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Anchored=true;p.CanCollide=collide~=false;p.Parent=parent;return p end
local function folder(parent:Instance,name:string):Folder local f=Instance.new("Folder");f.Name=name;f.Parent=parent;return f end
local function base(id:string,count:number):Folder
	local map=Instance.new("Folder");map.Name=id;map:SetAttribute("MapId",id);map:SetAttribute("Mode","Race");map:SetAttribute("MapVersion",1);map:SetAttribute("CheckpointCount",count)
	local starts=folder(map,"RaceStartSpawns");local direction=part(map,"StartDirection",Vector3.one,CFrame.new(0,5,18),Color3.new(1,1,1),false);direction.Transparency=1;direction.CanTouch=false
	for i=1,8 do local pos=Vector3.new(-9+((i-1)%4)*6,3,math.floor((i-1)/4)*6);part(starts,string.format("StartSpawn%02d",i),Vector3.new(5,1,5),CFrame.lookAt(pos,Vector3.new(0,pos.Y,20)),Color3.fromRGB(70,170,245))end
	folder(map,"Checkpoints");folder(map,"TrackSurfaces");folder(map,"OffTrackZones");folder(map,"ItemBoxes");folder(map,"MovingObstacles");folder(map,"Puzzles")
	return map
end
local function checkpoint(map:Folder,index:number,position:Vector3)local cp=part(map.Checkpoints,string.format("Checkpoint%02d",index),Vector3.new(28,10,3),CFrame.lookAt(position,position+Vector3.new(0,0,10)),Color3.fromRGB(70,230,180),false);cp.Transparency=.65;cp.CanTouch=true;cp:SetAttribute("CheckpointIndex",index)end
local function finishMap(map:Folder,position:Vector3)local f=part(map,"FinishLine",Vector3.new(28,1,8),CFrame.new(position),Color3.fromRGB(255,220,60),false);f.CanTouch=true;part(map,"FinishWaitingArea",Vector3.new(28,1,18),CFrame.new(position+Vector3.new(0,0,14)),Color3.fromRGB(70,200,110));local kill=part(map,"KillFloor",Vector3.new(180,1,420),CFrame.new(0,-22,170),Color3.fromRGB(220,55,55));kill.Transparency=.45;kill:SetAttribute("KillFloor",true)end
local function addZones(map:Folder,length:number)
	for _,x in {-25,25}do local zone=part(map.OffTrackZones,"OffTrack"..x,Vector3.new(22,1,length),CFrame.new(x,1,length/2-10),Color3.fromRGB(80,155,70));zone.Material=Enum.Material.Grass;zone:SetAttribute("OffTrackZone",true);zone:SetAttribute("PenaltyDurationMin",3);zone:SetAttribute("PenaltyDurationMax",5);zone:SetAttribute("SpeedMultiplier",.6)end
end
local function addBoxes(map:Folder,positions:{Vector3})for i,pos in positions do local b=part(map.ItemBoxes,"MysteryBox"..i,Vector3.new(4,4,4),CFrame.new(pos),Color3.fromHSV(i/#positions,.8,1),false);b.Material=Enum.Material.Neon;b.Transparency=.2;b.CanTouch=true end end
local function clocktower():Folder
	local map=base("ClocktowerEscape02",4);local last=Vector3.zero
	-- Short 10-stud platforms and 3-stud rises remain forgiving for default/mobile movement.
	for i=0,28 do local position=Vector3.new((i%2==0 and -5 or 5),2+math.floor(i/4)*3,i*10);last=position;local p=part(map.TrackSurfaces,"ClockPath"..i,Vector3.new(15,1,12),CFrame.new(position),Color3.fromRGB(105,115,145));p:SetAttribute("RaceTrackSurface",true);if i%7==0 and i>0 then checkpoint(map,i/7,position+Vector3.new(0,5,0))end end
	for i=1,4 do local obstacle=part(map.MovingObstacles,"ClockHand"..i,Vector3.new(14,.7,2),CFrame.new(0,5+i*5,55+i*50),Color3.fromRGB(190,135,65));obstacle:SetAttribute("MovingObstacle",true);obstacle:SetAttribute("AngularSpeed",12)end
	addZones(map,310);addBoxes(map,{Vector3.new(-4,7,45),Vector3.new(4,13,115),Vector3.new(-4,18,185),Vector3.new(4,24,250)});finishMap(map,last+Vector3.new(0,0,18));return map
end
local function workshop():Folder
	local map=base("VillageWorkshop03",3)
	for i=0,18 do local p=part(map.TrackSurfaces,"WorkshopRoad"..i,Vector3.new(26,1,17),CFrame.new(0,3,i*16),Color3.fromRGB(175,130,85));p:SetAttribute("RaceTrackSurface",true)end
	checkpoint(map,1,Vector3.new(0,8,48));checkpoint(map,2,Vector3.new(0,8,160));checkpoint(map,3,Vector3.new(0,8,240));local puzzles=map.Puzzles
	for i,color in ipairs({Color3.fromRGB(230,70,70),Color3.fromRGB(70,210,90),Color3.fromRGB(70,120,240)})do local b=part(puzzles,"ColorButton"..i,Vector3.new(5,.5,5),CFrame.new(-7+i*7,4,75),color);b:SetAttribute("PuzzleId","ColorDoor");b:SetAttribute("Step",i)end
	local colorDoor=part(puzzles,"ColorDoor",Vector3.new(26,12,2),CFrame.new(0,9,95),Color3.fromRGB(110,75,45));colorDoor:SetAttribute("PuzzleId","ColorDoor")
	local box=part(puzzles,"PushBox",Vector3.new(4,4,4),CFrame.new(-7,6,130),Color3.fromRGB(125,80,45));box.Anchored=false;box:SetAttribute("PuzzleId","PushBox");local plate=part(puzzles,"PressurePlate",Vector3.new(6,.5,6),CFrame.new(7,4,130),Color3.fromRGB(80,220,100));plate:SetAttribute("PuzzleId","PushBox");local reset=part(puzzles,"ResetPushBox",Vector3.new(3,3,2),CFrame.new(-12,5,130),Color3.fromRGB(220,75,70));local prompt=Instance.new("ProximityPrompt");prompt.ActionText="重置木箱";prompt.Parent=reset
	part(puzzles,"PushDoor",Vector3.new(26,12,2),CFrame.new(0,9,150),Color3.fromRGB(115,75,50))
	local walls=folder(puzzles,"MovingWalls");for i=1,3 do local wall=part(walls,"Wall"..i,Vector3.new(3,8,13),CFrame.new(-8+i*8,7,195+i*10),Color3.fromRGB(95,105,125));wall:SetAttribute("MoveOffset",i%2==0 and 6 or -6)end
	for i=1,2 do local lever=part(puzzles,"FinalLever"..i,Vector3.new(3,5,3),CFrame.new(i==1 and -8 or 8,6,260),Color3.fromRGB(230,170,60));lever:SetAttribute("PuzzleId","FinalLevers");lever:SetAttribute("LeverIndex",i);local pp=Instance.new("ProximityPrompt");pp.ActionText="啟動拉桿";pp.Parent=lever end
	part(puzzles,"FinalDoor",Vector3.new(26,12,2),CFrame.new(0,9,275),Color3.fromRGB(130,65,55));addZones(map,310);addBoxes(map,{Vector3.new(-6,7,35),Vector3.new(6,7,145),Vector3.new(-6,7,235)});finishMap(map,Vector3.new(0,4,300));return map
end
function Service.Build(id:string):Folder
	if id=="VillageRace01"then local source=workspace:FindFirstChild("PartyObbyMap");if source and source:IsA("Folder")then local copy=source:Clone();copy.Name=id;copy:SetAttribute("MapId",id);copy:SetAttribute("Mode","Race");copy:SetAttribute("MapVersion",2);return copy end end
	if id=="ClocktowerEscape02"then return clocktower()end
	return workshop()
end
return Service
