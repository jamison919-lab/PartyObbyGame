--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local TweenService=game:GetService("TweenService")
local Config=require(ReplicatedStorage.Modules.AudioConfig)
local remotes=ReplicatedStorage:WaitForChild("Remotes",10)
if not remotes then warn("[Audio] Remotes unavailable");return end

local folder=SoundService:FindFirstChild("GameAudio") or Instance.new("Folder")
folder.Name="GameAudio";folder.Parent=SoundService
local music=folder:FindFirstChild("Music") :: Sound?
if not music then music=Instance.new("Sound");music.Name="Music";music.Looped=true;music.Volume=0;music.Parent=folder end
local musicEnabled=true;local soundEnabled=true;local switchToken=0
local function soundId(id:number):string return "rbxassetid://"..tostring(id) end
local function playTrack(key:string)
	switchToken+=1;local token=switchToken;local id=Config.Tracks[key] or 0
	local fadeOut=TweenService:Create(music,TweenInfo.new(Config.FadeDuration),{Volume=0});fadeOut:Play()
	task.delay(Config.FadeDuration,function()
		if token~=switchToken then return end
		music:Stop()
		if id<=0 or not musicEnabled then music.SoundId="";return end
		music.SoundId=soundId(id);music:Play();TweenService:Create(music,TweenInfo.new(Config.FadeDuration),{Volume=Config.MusicVolume}):Play()
	end)
end
local function playSfx(key:string)
	local id=Config.Sounds[key] or 0;if not soundEnabled or id<=0 then return end
	local sound=Instance.new("Sound");sound.Name=key;sound.SoundId=soundId(id);sound.Volume=Config.SoundVolume;sound.Parent=folder;sound.Ended:Once(function()sound:Destroy()end);sound:Play()
end
local stateRemote=remotes:WaitForChild("RoundStateChanged",10);local modeRemote=remotes:WaitForChild("ModeStateChanged",10);local settingsRemote=remotes:WaitForChild("SettingsUpdated",10)
if stateRemote and stateRemote:IsA("RemoteEvent")then stateRemote.OnClientEvent:Connect(function(payload)if type(payload)~="table"then return end;if payload.state=="Results"then playTrack("ResultsMusic")elseif payload.state=="Racing"then playTrack("RaceMusic")end end)end
if modeRemote and modeRemote:IsA("RemoteEvent")then modeRemote.OnClientEvent:Connect(function(payload)if type(payload)~="table"then return end;if payload.inLobby then playTrack("LobbyMusic")elseif tostring(payload.mode):find("Tower")then playTrack("TowerMusic")else playTrack("RaceMusic")end end)end
if settingsRemote and settingsRemote:IsA("RemoteEvent")then settingsRemote.OnClientEvent:Connect(function(settings)if type(settings)~="table"then return end;musicEnabled=settings.MusicEnabled~=false;soundEnabled=settings.SoundEnabled~=false;if not musicEnabled then switchToken+=1;music:Stop();music.SoundId="" elseif music.SoundId=="" then playTrack("LobbyMusic")end end)end
local countdown=remotes:FindFirstChild("CountdownUpdated");if countdown and countdown:IsA("RemoteEvent")then countdown.OnClientEvent:Connect(function(value)playSfx(if value=="GO"then "Go"else "Countdown")end)end
playTrack("LobbyMusic")
