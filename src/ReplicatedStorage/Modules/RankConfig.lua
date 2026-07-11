--!strict
local names={"木桶村民","青銅村民","白銀村民","黃金村民","翡翠勇者","鑽石村長","大師逃亡者","傳奇村霸王"}
local tiers={}; for i,name in names do for divisionIndex,division in {"III","II","I"} do table.insert(tiers,{Id="Rank"..i..division,Name=name,Division=division,MinimumPoints=(#tiers)*100}) end end; table.insert(tiers,{Id="Supreme",Name="爆笑至尊",Division="",MinimumPoints=2400})
return table.freeze({Tiers=tiers,PointsByPlayers={ [2]={20,5},[3]={24,15,6},[4]={24,15,6,0},[5]={27,18,10,3,-3},[6]={28,20,12,5,0,-6},[7]={30,21,14,7,2,-5,-10},[8]={30,22,15,8,2,-5,-10,-15}},AbandonPenalty=-10,WinStreakBonus=3})
