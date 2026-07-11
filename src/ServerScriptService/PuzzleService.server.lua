--!strict
local Maps=require(script.Parent.Services.MapService);local Puzzles=require(script.Parent.Services.PuzzleService);Maps.Loaded.Event:Connect(function(matchId,map)Puzzles.Bind(matchId,map)end)
