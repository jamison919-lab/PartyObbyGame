--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteService = {}
local names = {
	"RoundStateChanged", "CountdownUpdated", "RankingUpdated",
	"PlayerFinished", "ResultsUpdated", "ClientReady", "PlayerProgressUpdated",
	"ItemGranted", "ItemUsed", "ItemEffect", "UseItem", "TrackPenaltyUpdated", "ItemMessage",
}

function RemoteService.Ensure(): {[string]: RemoteEvent}
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then folder = Instance.new("Folder"); folder.Name = "Remotes"; folder.Parent = ReplicatedStorage end
	local result: {[string]: RemoteEvent} = {}
	for _, name in names do
		local existing = folder:FindFirstChild(name)
		if existing and not existing:IsA("RemoteEvent") then error(string.format("[Remotes] %s exists but is not a RemoteEvent", existing:GetFullName())) end
		local remote = existing :: RemoteEvent?
		if not remote then remote = Instance.new("RemoteEvent"); remote.Name = name; remote.Parent = folder end
		result[name] = remote
	end
	return result
end

return RemoteService
