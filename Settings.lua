-- Plik: workspace/Vanguard/Settings.lua

local Settings = {
	-- ESP
	ESP = false,
	Box = false,
	BoxType = "Full",
	Name = false,
	DistView = true,
	Health = false,
	HealthText = false,
	Weapon = false,
	Skel = false,
	Trace = false,
	Chams = false,
	ChamsRainbow = false,
	Team = false,
	RealTeamColor = true,
	LoS = false,
	MaxDist = 500,
	Th = 1.5,
	V = Color3.fromRGB(0, 255, 150),
	O = Color3.fromRGB(255, 50, 50),

	-- AIM
	Aimbot = false,
	Silent = false,
	Trigger = false,
	Backtrack = false,
	BacktrackMs = 200,
	VisibleCheck = true,
	ShowFOV = true,
	FOV = 80,
	Smooth = 0.4,
	AimCurve = true,
	TargetMode = "FOV",
	AimPart = "Head",
}

return Settings
