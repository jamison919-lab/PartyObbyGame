--!strict
local Reward=require(script.Parent.Services.RewardService);local Profiles=require(script.Parent.Services.PlayerProfileService);local remotes=require(script.Parent.Services.RemoteService).Ensure();local rate:{[Player]:number}={}
remotes.ClaimDailyReward.OnServerEvent:Connect(function(p)if os.clock()-(rate[p] or 0)<1 then return end;rate[p]=os.clock();local ok,amount=Reward.ClaimDaily(p);remotes.PurchaseResult:FireClient(p,{success=ok,message=ok and ("每日獎勵 +"..amount.." Coins") or "今天已領取",profile=Profiles.GetPublicProfileSnapshot(p)})end)
