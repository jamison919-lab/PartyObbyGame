--!strict
local Catalog=require(game:GetService("ReplicatedStorage").Modules.MapCatalog);local Service=require(script.Parent.Services.MapService)
for id,d in Catalog do if d.IsEnabled then local ok,errors=Service.ValidateMap(id);if ok then print("[MapValidation] PASS "..id)else warn("[MapValidation] FAIL "..id..": "..table.concat(errors,", "))end end end
