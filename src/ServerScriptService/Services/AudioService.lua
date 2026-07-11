--!strict
local Config=require(game:GetService("ReplicatedStorage").Modules.AudioConfig);local Service={}
function Service.IsConfigured(category:string,id:string):boolean local group=(Config::any)[category];return type(group)=="table"and type(group[id])=="number"and group[id]>0 end
return Service
