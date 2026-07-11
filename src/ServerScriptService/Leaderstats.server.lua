--!strict
local Players=game:GetService("Players");local Profiles=require(script.Parent.Services.PlayerProfileService)
local function sync(p:Player) local profile=Profiles.GetProfile(p);local stats=p:FindFirstChild("leaderstats");if not profile or not stats then return end;(stats.Coins::IntValue).Value=profile.Economy.Coins;(stats.Wins::IntValue).Value=profile.General.Wins;(stats.RankPoints::IntValue).Value=profile.RankedRace.RankPoints end
local function setup(p:Player) local deadline=os.clock()+20;while not Profiles.IsProfileLoaded(p) and os.clock()<deadline do task.wait(.1) end;if not Profiles.IsProfileLoaded(p) then return end;local f=Instance.new("Folder");f.Name="leaderstats";f.Parent=p;for _,name in {"Coins","Wins","RankPoints"} do local v=Instance.new("IntValue");v.Name=name;v.Parent=f end;sync(p) end
Players.PlayerAdded:Connect(function(p)task.spawn(setup,p)end);for _,p in Players:GetPlayers() do task.spawn(setup,p) end;Profiles.Changed.Event:Connect(sync)
