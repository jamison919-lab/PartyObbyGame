--!strict
local Config=require(script.Parent.ItemConfig)
local Utils={}
function Utils.choose(rank:number,total:number,lastId:string?): string
	local weighted={}; local sum=0
	for id,item in Config do
		if id~=lastId and rank>=item.MinRank and rank<=item.MaxRank then
			local weight=item.Weight
			if rank==1 and (id=="BananaPeel" or id=="UmbrellaShield" or id=="SpringShoes") then weight*=1.6 end
			if rank==total and (id=="ChiliBoost" or id=="CrazyChicken") then weight*=2 end
			if rank>1 and rank<total and (id=="StinkyTofuBomb" or id=="ChiliBoost") then weight*=1.4 end
			sum+=weight; table.insert(weighted,{id=id,limit=sum})
		end
	end
	local roll=math.random()*sum; for _,entry in weighted do if roll<=entry.limit then return entry.id end end
	return "BananaPeel"
end
return Utils
