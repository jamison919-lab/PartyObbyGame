--!strict
local Players=game:GetService("Players")
local function setup(p: Player) local f=Instance.new("Folder"); f.Name="leaderstats"; f.Parent=p; for _,name in {"Wins","RoundsPlayed"} do local v=Instance.new("IntValue"); v.Name=name; v.Parent=f end; local b=Instance.new("NumberValue"); b.Name="BestTime"; b.Parent=f end
Players.PlayerAdded:Connect(setup); for _,p in Players:GetPlayers() do setup(p) end
