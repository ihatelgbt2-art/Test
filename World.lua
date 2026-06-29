-- Plik: workspace/Vanguard/World.lua

local World = {}

function World.Init(S)
	local Lighting = game:GetService("Lighting")
	local RS = game:GetService("RunService")

	local saved = nil
	local menuBlur = nil

	local function ensureBlur()
		if menuBlur and menuBlur.Parent then
			return menuBlur
		end
		menuBlur = Lighting:FindFirstChild("VanguardMenuBlur")
		if not menuBlur then
			menuBlur = Instance.new("BlurEffect")
			menuBlur.Name = "VanguardMenuBlur"
			menuBlur.Size = 0
			menuBlur.Enabled = true
			menuBlur.Parent = Lighting
		end
		return menuBlur
	end

	local function captureDefaults()
		if saved then
			return
		end
		saved = {
			Brightness = Lighting.Brightness,
			GlobalShadows = Lighting.GlobalShadows,
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
			FogEnd = Lighting.FogEnd,
			FogStart = Lighting.FogStart,
			ClockTime = Lighting.ClockTime,
			ColorShift_Top = Lighting.ColorShift_Top,
			ColorShift_Bottom = Lighting.ColorShift_Bottom,
			Atmosphere = {},
		}
		for _, inst in ipairs(Lighting:GetChildren()) do
			if inst:IsA("Atmosphere") then
				saved.Atmosphere[inst] = {
					Density = inst.Density,
					Offset = inst.Offset,
					Haze = inst.Haze,
					Glare = inst.Glare,
				}
			end
		end
	end

	local function restoreDefaults()
		if not saved then
			return
		end
		Lighting.Brightness = saved.Brightness
		Lighting.GlobalShadows = saved.GlobalShadows
		Lighting.Ambient = saved.Ambient
		Lighting.OutdoorAmbient = saved.OutdoorAmbient
		Lighting.FogEnd = saved.FogEnd
		Lighting.FogStart = saved.FogStart
		Lighting.ClockTime = saved.ClockTime
		Lighting.ColorShift_Top = saved.ColorShift_Top
		Lighting.ColorShift_Bottom = saved.ColorShift_Bottom
		for inst, props in pairs(saved.Atmosphere) do
			if inst.Parent then
				for k, v in pairs(props) do
					inst[k] = v
				end
			end
		end
	end

	local function applyFullBright(on)
		if on then
			Lighting.GlobalShadows = false
			Lighting.Brightness = 2
			Lighting.Ambient = Color3.fromRGB(255, 255, 255)
			Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
		elseif saved then
			Lighting.GlobalShadows = saved.GlobalShadows
			Lighting.Brightness = saved.Brightness
			Lighting.Ambient = saved.Ambient
			Lighting.OutdoorAmbient = saved.OutdoorAmbient
		end
	end

	local function applyNoFog(on)
		if on then
			Lighting.FogEnd = 100000
			Lighting.FogStart = 100000
			for _, inst in ipairs(Lighting:GetChildren()) do
				if inst:IsA("Atmosphere") then
					inst.Density = 0
					inst.Haze = 0
					inst.Glare = 0
				end
			end
		elseif saved then
			Lighting.FogEnd = saved.FogEnd
			Lighting.FogStart = saved.FogStart
			for inst, props in pairs(saved.Atmosphere) do
				if inst.Parent then
					inst.Density = props.Density
					inst.Haze = props.Haze or inst.Haze
					inst.Glare = props.Glare or inst.Glare
				end
			end
		end
	end

	local function applyCustomTint()
		if not S.WorldCustomLight then
			if saved then
				Lighting.ColorShift_Top = saved.ColorShift_Top
				Lighting.ColorShift_Bottom = saved.ColorShift_Bottom
			end
			return
		end
		local hue = math.clamp(S.WorldColorHue or 0.55, 0, 1)
		local sat = math.clamp(S.WorldColorSat or 0.35, 0, 1)
		local tint = Color3.fromHSV(hue, sat, 1)
		Lighting.ColorShift_Top = tint
		Lighting.ColorShift_Bottom = tint:Lerp(Color3.new(1, 1, 1), 0.35)
	end

	local function applyTime()
		if S.WorldTimeLock then
			Lighting.ClockTime = math.clamp(S.WorldTime or 14, 0, 24)
		elseif saved then
			Lighting.ClockTime = saved.ClockTime
		end
	end

	local function applyMenuBlur()
		local blur = ensureBlur()
		if S.MenuBlur and S.MenuOpen then
			blur.Size = math.clamp(S.MenuBlurSize or 18, 4, 48)
		else
			blur.Size = 0
		end
	end

	local function applyAll()
		captureDefaults()
		applyFullBright(S.FullBright == true)
		applyNoFog(S.NoFog == true)
		applyCustomTint()
		applyTime()
		applyMenuBlur()
	end

	RS.RenderStepped:Connect(function()
		if S.WorldTimeLock then
			Lighting.ClockTime = math.clamp(S.WorldTime or 14, 0, 24)
		end
		applyMenuBlur()
	end)

	RS.Heartbeat:Connect(function()
		captureDefaults()
		applyFullBright(S.FullBright == true)
		applyNoFog(S.NoFog == true)
		applyCustomTint()
	end)

	function World.Refresh()
		applyAll()
	end

	function World.OnSettingChanged()
		applyAll()
	end

	World.Refresh()

	if _G.VANGUARD then
		_G.VANGUARD.registerCleanup(function()
			restoreDefaults()
			if menuBlur and menuBlur.Parent then
				menuBlur:Destroy()
			end
		end)
	end
end

return World
