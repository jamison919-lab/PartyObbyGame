--!strict
local items = {
	BananaPeel={Id="BananaPeel",DisplayName="香蕉皮",Category="Trap",IconText="BANANA",Duration=1.2,Cooldown=.6,Weight=10,MinRank=1,MaxRank=8,TargetMode="Ground",EffectStrength=.55,CanAffectSelf=false,CanAffectFinishedPlayer=false},
	CrazyChicken={Id="CrazyChicken",DisplayName="爆笑雞",Category="Homing",IconText="CHICKEN",Duration=6,Cooldown=.8,Weight=7,MinRank=2,MaxRank=8,TargetMode="Ahead",EffectStrength=.75,CanAffectSelf=false,CanAffectFinishedPlayer=false},
	StinkyTofuBomb={Id="StinkyTofuBomb",DisplayName="臭豆腐炸彈",Category="Area",IconText="TOFU",Duration=4,Cooldown=.8,Weight=9,MinRank=1,MaxRank=8,TargetMode="ForwardArea",EffectStrength=.7,CanAffectSelf=false,CanAffectFinishedPlayer=false},
	ChiliBoost={Id="ChiliBoost",DisplayName="辣椒衝刺",Category="Boost",IconText="BOOST",Duration=3,Cooldown=.5,Weight=10,MinRank=1,MaxRank=8,TargetMode="Self",EffectStrength=1.45,CanAffectSelf=true,CanAffectFinishedPlayer=false},
	SpringShoes={Id="SpringShoes",DisplayName="彈簧鞋",Category="Movement",IconText="SPRING",Duration=8,Cooldown=.5,Weight=9,MinRank=1,MaxRank=8,TargetMode="Self",EffectStrength=1.65,CanAffectSelf=true,CanAffectFinishedPlayer=false},
	UmbrellaShield={Id="UmbrellaShield",DisplayName="雨傘盾牌",Category="Defense",IconText="SHIELD",Duration=6,Cooldown=.5,Weight=8,MinRank=1,MaxRank=8,TargetMode="Self",EffectStrength=1,CanAffectSelf=true,CanAffectFinishedPlayer=false},
}
return table.freeze(items)
