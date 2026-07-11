--!strict
local RankingUtils = {}

function RankingUtils.segmentProgress(position: Vector3, fromPosition: Vector3, toPosition: Vector3): number
	local segment = toPosition - fromPosition
	local lengthSquared = segment:Dot(segment)
	if lengthSquared < 0.001 then return 0 end
	return math.clamp((position - fromPosition):Dot(segment) / lengthSquared, 0, 1)
end

function RankingUtils.sort(entries: {any}): {any}
	table.sort(entries, function(a, b)
		if a.IsFinished ~= b.IsFinished then return a.IsFinished end
		if a.IsFinished then return (a.FinishPlace or math.huge) < (b.FinishPlace or math.huge) end
		if a.CurrentCheckpoint ~= b.CurrentCheckpoint then return a.CurrentCheckpoint > b.CurrentCheckpoint end
		if a.SegmentProgress ~= b.SegmentProgress then return a.SegmentProgress > b.SegmentProgress end
		return (a.ProgressReachedAt or math.huge) < (b.ProgressReachedAt or math.huge)
	end)
	return entries
end

return RankingUtils
