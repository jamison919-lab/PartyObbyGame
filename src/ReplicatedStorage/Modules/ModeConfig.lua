--!strict
return table.freeze({
	CasualRace={Id="CasualRace",DisplayName="多人休閒競速",Description="2～8 人派對競速，不影響牌位",MinimumPlayers=1,RecommendedPlayers=2,MaximumPlayers=8,IsRanked=false,IsSolo=false,QueueDuration=10,MatchDuration=180,MapPool={"VillageRace01"},RewardsEnabled=true,RankPointsEnabled=false,ItemsEnabled=true,AllowLateJoin=false,ReturnToLobbyAfterFinish=true},
	RankedRace={Id="RankedRace",DisplayName="多人排位競速",Description="名次影響逃亡積分",MinimumPlayers=2,RecommendedPlayers=2,MaximumPlayers=8,IsRanked=true,IsSolo=false,QueueDuration=10,MatchDuration=180,MapPool={"VillageRace01"},RewardsEnabled=true,RankPointsEnabled=true,ItemsEnabled=true,AllowLateJoin=false,ReturnToLobbyAfterFinish=true},
	SoloTower={Id="SoloTower",DisplayName="單人爬塔",Description="挑戰失控村莊瞭望塔",MinimumPlayers=1,RecommendedPlayers=1,MaximumPlayers=1,IsRanked=false,IsSolo=true,QueueDuration=0,MatchDuration=300,MapPool={"Tower01"},RewardsEnabled=true,RankPointsEnabled=false,ItemsEnabled=false,AllowLateJoin=false,ReturnToLobbyAfterFinish=true},
})
