--!strict
local Profiles=require(script.Parent.PlayerProfileService);local Config=require(game:GetService("ReplicatedStorage").Modules.TutorialConfig);local remotes=require(script.Parent.RemoteService).Ensure();local Service={}
function Service.Send(p:Player)local profile=Profiles.GetProfile(p);if profile then remotes.TutorialState:FireClient(p,{completed=profile.Tutorial.Completed,lastStep=profile.Tutorial.LastStep,steps=Config.Steps})end end
function Service.Complete(p:Player)local profile=Profiles.GetProfile(p);if not profile then return end;profile.Tutorial.Completed=true;profile.Tutorial.LastStep=#Config.Steps;Profiles.MarkDirty(p);Service.Send(p)end
function Service.Restart(p:Player)local profile=Profiles.GetProfile(p);if not profile then return end;profile.Tutorial.Completed=false;profile.Tutorial.LastStep=0;Profiles.MarkDirty(p);Service.Send(p)end
return Service
