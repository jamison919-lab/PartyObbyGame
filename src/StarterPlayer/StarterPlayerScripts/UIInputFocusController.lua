--!strict
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local Controller = {}
local activeMenu: ScreenGui? = nil
local preferredSelection: GuiButton? = nil
local currentMode = "Lobby"
local lastInputType = UserInputService:GetLastInputType()

local function isGamepad(inputType: Enum.UserInputType): boolean
	return inputType == Enum.UserInputType.Gamepad1
		or inputType == Enum.UserInputType.Gamepad2
		or inputType == Enum.UserInputType.Gamepad3
		or inputType == Enum.UserInputType.Gamepad4
		or inputType == Enum.UserInputType.Gamepad5
		or inputType == Enum.UserInputType.Gamepad6
		or inputType == Enum.UserInputType.Gamepad7
		or inputType == Enum.UserInputType.Gamepad8
end

local function releaseTextFocus()
	local focused = UserInputService:GetFocusedTextBox()
	if focused then focused:ReleaseFocus() end
end

function Controller.ClearSelection()
	GuiService.SelectedObject = nil
	releaseTextFocus()
end

function Controller.EnterGameplayMode(mode: string?)
	if mode then currentMode = mode end
	activeMenu = nil
	preferredSelection = nil
	Controller.ClearSelection()
end

function Controller.OpenMenu(rootGui: ScreenGui, preferredButton: GuiButton?)
	activeMenu = rootGui
	preferredSelection = preferredButton
	releaseTextFocus()
	GuiService.SelectedObject = if isGamepad(lastInputType) and preferredButton and preferredButton.Selectable then preferredButton else nil
end

function Controller.CloseMenu(rootGui: ScreenGui?)
	if rootGui == nil or activeMenu == rootGui then activeMenu = nil;preferredSelection = nil end
	Controller.ClearSelection()
end

function Controller.IsMenuOpen(): boolean
	return activeMenu ~= nil and activeMenu.Enabled
end

function Controller.GetActiveMenu(): ScreenGui?
	return if Controller.IsMenuOpen() then activeMenu else nil
end

function Controller.SetMode(mode: string)
	currentMode = mode
end

function Controller.PrintInputFocusState()
	if not RunService:IsStudio() then return end
	local selected = GuiService.SelectedObject
	local focused = UserInputService:GetFocusedTextBox()
	local modalButton: GuiButton? = nil
	for _, descendant in playerGui:GetDescendants() do
		if descendant:IsA("GuiButton") and descendant.Modal then modalButton = descendant;break end
	end
	print(string.format(
		"[InputFocus] Mode=%s ActiveMenu=%s SelectedObject=%s FocusedTextBox=%s LastInputType=%s Modal=%s Actions=none GameplayEnabled=%s",
		currentMode,
		activeMenu and activeMenu.Name or "nil",
		selected and selected:GetFullName() or "nil",
		focused and focused:GetFullName() or "nil",
		lastInputType.Name,
		modalButton and modalButton:GetFullName() or "nil",
		tostring(not Controller.IsMenuOpen())
	))
end

UserInputService.LastInputTypeChanged:Connect(function(inputType)
	lastInputType = inputType
	if Controller.IsMenuOpen() then
		GuiService.SelectedObject = if isGamepad(inputType) and preferredSelection and preferredSelection.Selectable then preferredSelection else nil
	end
end)

return Controller
