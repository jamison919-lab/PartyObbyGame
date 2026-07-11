--!strict
local Events=require(script.Parent.Services.GameplayEventService);local Achievements=require(script.Parent.Services.AchievementService);Events.Event.Event:Connect(function(p,event,amount)local ok,err=pcall(Achievements.Progress,p,event,amount);if not ok then warn("[Achievement] update failed: "..tostring(err))end end)
