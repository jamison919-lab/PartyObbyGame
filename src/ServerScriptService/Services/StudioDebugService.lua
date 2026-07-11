--!strict
local RunService=game:GetService("RunService");local Profiles=require(script.Parent.PlayerProfileService);local Monetization=require(script.Parent.MonetizationService);local Service={}
local function studio():boolean return RunService:IsStudio() end
function Service.AddCoins(p:Player,amount:number?):boolean if not studio()then return false end;Profiles.IncrementValue(p,"Economy.Coins",amount or 5000);print("[DEBUG Data] added coins to "..p.Name);return true end
function Service.UnlockCosmetic(p:Player,id:string):boolean if not studio()then return false end;return Profiles.AddOwnedCosmetic(p,id)end
function Service.SimulateGamePass(p:Player,id:string):boolean if not studio()then return false end;local profile=Profiles.GetProfile(p);if not profile then return false end;profile.Monetization.OwnedGamePasses[id]=true;Profiles.MarkDirty(p);return true end
function Service.GrantProduct(p:Player,id:string):boolean return studio()and Monetization.DebugGrantProduct(p,id)end
function Service.SetRankPoints(p:Player,points:number):boolean if not studio()then return false end;return Profiles.UpdateValue(p,"RankedRace.RankPoints",math.max(0,points))end
function Service.ClearEquipment(p:Player):boolean if not studio()then return false end;local profile=Profiles.GetProfile(p);if not profile then return false end;for slot in profile.Inventory.EquippedCosmetics do profile.Inventory.EquippedCosmetics[slot]="" end;Profiles.MarkDirty(p);return true end
return Service
