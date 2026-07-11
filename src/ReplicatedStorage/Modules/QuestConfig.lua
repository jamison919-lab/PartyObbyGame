--!strict
return table.freeze({
	Casual2={Id="Casual2",DisplayName="休閒逃亡者",Description="完成 2 場休閒競速",Target=2,RewardCoins=150,AllowedModes={"CasualRace"},ProgressEvent="CasualComplete",IsEnabled=true},
	TopThree1={Id="TopThree1",DisplayName="擠進前三",Description="取得 1 次前三名",Target=1,RewardCoins=120,AllowedModes={"CasualRace","RankedRace"},ProgressEvent="TopThree",IsEnabled=true},
	Items3={Id="Items3",DisplayName="道具派對",Description="使用 3 次派對道具",Target=3,RewardCoins=100,AllowedModes={"CasualRace","RankedRace"},ProgressEvent="ItemUsed",IsEnabled=true},
	Checkpoints10={Id="Checkpoints10",DisplayName="檢查點巡禮",Description="通過 10 個 Race Checkpoint",Target=10,RewardCoins=130,AllowedModes={"CasualRace","RankedRace"},ProgressEvent="Checkpoint",IsEnabled=true},
	Tower1={Id="Tower1",DisplayName="塔頂見",Description="完成一次 Tower",Target=1,RewardCoins=180,AllowedModes={"SoloTower"},ProgressEvent="TowerComplete",IsEnabled=true},
	Vote1={Id="Vote1",DisplayName="我來選地圖",Description="投票選擇一張地圖",Target=1,RewardCoins=80,AllowedModes={"CasualRace"},ProgressEvent="MapVote",IsEnabled=true},
})
