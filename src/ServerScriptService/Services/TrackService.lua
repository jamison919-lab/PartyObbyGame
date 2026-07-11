--!strict
local Service={}
function Service.IsRacingSurface(part:Instance):boolean return part:IsA("BasePart") and part:GetAttribute("RaceTrackSurface")==true end
function Service.IsOffTrack(part:Instance):boolean return part:IsA("BasePart") and part:GetAttribute("OffTrackZone")==true end
return Service
