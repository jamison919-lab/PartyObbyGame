--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage");local Config=require(ReplicatedStorage.Modules.AudioConfig);local folder=Instance.new("Folder");folder.Name="GameAudio";folder.Parent=game:GetService("SoundService");local function configured(id:number):boolean return id>0 end
-- All current IDs are zero, so no Sound instances are created and no warnings are emitted.
if configured(Config.Tracks.LobbyMusic)then local sound=Instance.new("Sound");sound.SoundId="rbxassetid://"..Config.Tracks.LobbyMusic;sound.Parent=folder end
