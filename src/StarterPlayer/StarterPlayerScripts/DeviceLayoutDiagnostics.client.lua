--!strict
local RunService=game:GetService("RunService");if not RunService:IsStudio()then return end
local Players=game:GetService("Players");local GuiService=game:GetService("GuiService")
local function isTopLevel(object:GuiObject):boolean local parent=object.Parent;while parent and not parent:IsA("ScreenGui")do if parent:IsA("GuiObject")then return false end;parent=parent.Parent end;return parent~=nil end
task.delay(3,function()
	local camera=workspace.CurrentCamera;if not camera then return end;local size=camera.ViewportSize;local topLeft,bottomRight=GuiService:GetGuiInset();local warnings=0
	for _,object in Players.LocalPlayer.PlayerGui:GetDescendants()do
		if object:IsA("GuiObject")and object.Visible and isTopLevel(object)and object.AbsoluteSize.X>0 and object.AbsoluteSize.Y>0 then local p=object.AbsolutePosition;local s=object.AbsoluteSize;if p.X<0 or p.Y<topLeft.Y-2 or p.X+s.X>size.X-bottomRight.X+2 or p.Y+s.Y>size.Y-bottomRight.Y+2 then warnings+=1;warn("[DeviceLayout] top-level container outside safe area: "..object:GetFullName())end end
	end
	print(string.format("[DeviceLayout] checked %dx%d, warnings=%d",size.X,size.Y,warnings))
end)
