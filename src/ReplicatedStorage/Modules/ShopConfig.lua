--!strict
local cosmetics={
	StrawHat={Id="StrawHat",DisplayName="稻草村民帽",Description="農場風格稻草帽",Category="CoinCosmetics",Slot="HeadAccessory",CurrencyType="Coins",Price=300,ProductId=0,GamePassId=0,Rarity="Common",IsEnabled=true,IsFeatured=true,SortOrder=1,PreviewType="Part",RankedAllowed=true,GrantType="Cosmetic"},
	ChickenBackpack={Id="ChickenBackpack",DisplayName="爆笑雞背包",Description="背著一隻安靜不了的雞",Category="CoinCosmetics",Slot="BackAccessory",CurrencyType="Coins",Price=600,ProductId=0,GamePassId=0,Rarity="Rare",IsEnabled=true,IsFeatured=true,SortOrder=2,PreviewType="Part",RankedAllowed=true,GrantType="Cosmetic"},
	MudTrail={Id="MudTrail",DisplayName="泥巴腳印",Description="移動時留下泥巴色軌跡",Category="CoinCosmetics",Slot="Trail",CurrencyType="Coins",Price=800,ProductId=0,GamePassId=0,Rarity="Rare",IsEnabled=true,IsFeatured=false,SortOrder=3,PreviewType="Trail",RankedAllowed=true,GrantType="Cosmetic"},
	GoldenFinish={Id="GoldenFinish",DisplayName="黃金終點煙火",Description="完成時顯示金色效果",Category="CoinCosmetics",Slot="FinishEffect",CurrencyType="Coins",Price=1200,ProductId=0,GamePassId=0,Rarity="Epic",IsEnabled=true,IsFeatured=true,SortOrder=4,PreviewType="Effect",RankedAllowed=true,GrantType="Cosmetic"},
	BananaSkin={Id="BananaSkin",DisplayName="金色香蕉皮",Description="只改變香蕉皮外觀",Category="CoinCosmetics",Slot="ItemSkin",CurrencyType="Coins",Price=900,ProductId=0,GamePassId=0,Rarity="Epic",IsEnabled=true,IsFeatured=false,SortOrder=5,PreviewType="Effect",RankedAllowed=true,GrantType="Cosmetic"},
	VillageChampionTitle={Id="VillageChampionTitle",DisplayName="村莊逃亡王",Description="顯示專屬稱號",Category="CoinCosmetics",Slot="Title",CurrencyType="Coins",Price=1500,ProductId=0,GamePassId=0,Rarity="Legendary",IsEnabled=true,IsFeatured=true,SortOrder=6,PreviewType="Text",RankedAllowed=true,GrantType="Cosmetic"},
}
return table.freeze({Categories={"Featured","CoinCosmetics","GamePasses","DeveloperProducts","Consumables","Owned"},Cosmetics=cosmetics})
