-- Plik: workspace/Vanguard/Effects.lua

local Effects = {}

function Effects.Init(S, Util)
	local TS = game:GetService("TweenService")
	local Debris = game:GetService("Debris")
	local Players = game:GetService("Players")
	local LP = Players.LocalPlayer
	local Cam = workspace.CurrentCamera

	local FX_FOLDER = workspace:FindFirstChild("VG_FXRoot")
	if not FX_FOLDER then
		FX_FOLDER = Instance.new("Folder")
		FX_FOLDER.Name = "VG_FXRoot"
		FX_FOLDER.Parent = workspace
	end

	local accent = function()
		return S.V or Color3.fromRGB(0, 255, 150)
	end

	local function isEnemyChar(char)
		if not char or not char:IsA("Model") or char == LP.Character then
			return false
		end
		if Players:GetPlayerFromCharacter(char) == LP then
			return false
		end
		return char:FindFirstChildOfClass("Humanoid") ~= nil
	end

	local function getRoot(char)
		if not char then
			return nil
		end
		return Util and Util.resolveBodyPart(char, "HumanoidRootPart")
			or char:FindFirstChild("HumanoidRootPart")
	end

	local function resolveVictimChar(hum)
		if hum and hum.Parent and isEnemyChar(hum.Parent) then
			return hum.Parent
		end
		if S.LastShotHum and S.LastShotHum.Parent and isEnemyChar(S.LastShotHum.Parent) then
			return S.LastShotHum.Parent
		end
		if S.LastShotChar and isEnemyChar(S.LastShotChar) then
			return S.LastShotChar
		end
		return nil
	end

	local function getCrosshairVictim()
		if not Cam then
			return nil
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = LP.Character and { LP.Character } or {}
		local ray = Cam:ViewportPointToRay(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
		local hit = workspace:Raycast(ray.Origin, ray.Direction * 900, params)
		if hit and hit.Instance then
			local model = hit.Instance:FindFirstAncestorOfClass("Model")
			if isEnemyChar(model) then
				return model
			end
		end
		local best, bestD = nil, math.huge
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP and plr.Character and isEnemyChar(plr.Character) then
				local root = getRoot(plr.Character)
				if root then
					local d = (Cam.CFrame.Position - root.Position).Magnitude
					if d < bestD then
						bestD = d
						best = plr.Character
					end
				end
			end
		end
		return best
	end

	local function addHighlight(char, col, life)
		local hl = Instance.new("Highlight")
		hl.Name = "VG_FX"
		hl.Adornee = char
		hl.FillColor = col
		hl.OutlineColor = Color3.new(1, 1, 1)
		hl.FillTransparency = 0.15
		hl.OutlineTransparency = 0.05
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent = FX_FOLDER
		TS:Create(hl, TweenInfo.new(life or 0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			FillTransparency = 1,
			OutlineTransparency = 1,
		}):Play()
		Debris:AddItem(hl, (life or 0.85) + 0.15)
		return hl
	end

	local function spawnAnchor(pos, lifetime)
		local p = Instance.new("Part")
		p.Name = "VG_FX"
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Transparency = 1
		p.Size = Vector3.new(0.2, 0.2, 0.2)
		p.CFrame = CFrame.new(pos)
		p.Parent = FX_FOLDER
		Debris:AddItem(p, lifetime or 2)
		return p
	end

	local function makeBurst(pos, col, count, speed)
		local anchor = spawnAnchor(pos, 2.5)
		local em = Instance.new("ParticleEmitter")
		em.Color = ColorSequence.new(col, Color3.new(1, 1, 1))
		em.LightEmission = 1
		em.Rate = 0
		em.Speed = NumberRange.new(speed or 10, (speed or 10) + 12)
		em.Lifetime = NumberRange.new(0.35, 0.85)
		em.SpreadAngle = Vector2.new(360, 360)
		em.Drag = 2
		em.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.55),
			NumberSequenceKeypoint.new(1, 0),
		})
		em.Parent = anchor
		em:Emit(count or 45)
	end

	local function trackPosition(char, seconds, stepFn)
		task.spawn(function()
			local t0 = tick()
			while tick() - t0 < seconds do
				if not char or not char.Parent then
					break
				end
				local root = getRoot(char)
				if not root then
					break
				end
				stepFn(root.Position, tick() - t0)
				task.wait(0.03)
			end
		end)
	end

	local function tryGhostFade(char, col)
		if not char.Archivable then
			return false
		end
		local ok, ghost = pcall(function()
			return char:Clone()
		end)
		if not ok or not ghost then
			return false
		end
		ghost.Name = "VG_Ghost"
		for _, inst in ipairs(ghost:GetDescendants()) do
			if inst:IsA("Script") or inst:IsA("LocalScript") or inst:IsA("Sound") then
				inst:Destroy()
			elseif inst:IsA("BasePart") then
				inst.Anchored = true
				inst.CanCollide = false
				inst.CanQuery = false
				inst.CanTouch = false
				inst.Material = Enum.Material.Neon
				inst.Color = col
				inst.Transparency = 0
			end
		end
		ghost.Parent = FX_FOLDER
		for _, inst in ipairs(ghost:GetDescendants()) do
			if inst:IsA("BasePart") then
				TS:Create(inst, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1,
				}):Play()
			end
		end
		Debris:AddItem(ghost, 1.1)
		return true
	end

	local function effectNeonDissolve(char)
		local col = accent()
		addHighlight(char, col, 0.95)
		tryGhostFade(char, col)
		local root = getRoot(char)
		if root then
			makeBurst(root.Position + Vector3.new(0, 1.5, 0), col, 35, 9)
		end
	end

	local function effectParticleBurst(char)
		local root = getRoot(char)
		if not root then
			return
		end
		local col = accent()
		makeBurst(root.Position, col, 55, 14)
		makeBurst(root.Position + Vector3.new(0, 2, 0), Color3.fromRGB(30, 30, 35), 25, 6)
		addHighlight(char, col, 0.35)
	end

	local function effectAscension(char)
		local col = accent()
		addHighlight(char, col, 1.4)
		trackPosition(char, 1.5, function(pos, elapsed)
			makeBurst(pos + Vector3.new(0, elapsed * 6, 0), col, 4, 3)
		end)
		local root = getRoot(char)
		if root then
			makeBurst(root.Position, col, 20, 5)
		end
	end

	local function effectShockRing(char)
		local root = getRoot(char)
		if not root then
			return
		end
		local ring = Instance.new("Part")
		ring.Name = "VG_FX"
		ring.Shape = Enum.PartType.Cylinder
		ring.Anchored = true
		ring.CanCollide = false
		ring.CanQuery = false
		ring.CanTouch = false
		ring.Material = Enum.Material.Neon
		ring.Color = accent()
		ring.Transparency = 0.35
		ring.Size = Vector3.new(0.15, 1, 1)
		ring.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, 0, math.rad(90))
		ring.Parent = FX_FOLDER
		TS:Create(ring, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.08, 14, 14),
			Transparency = 1,
		}):Play()
		Debris:AddItem(ring, 0.7)
	end

	local function effectLightningHit(char)
		local head = Util and Util.resolveBodyPart(char, "Head") or char:FindFirstChild("Head")
		local root = getRoot(char)
		local target = head or root
		if not target then
			return
		end
		local col = accent()
		local top = spawnAnchor(target.Position + Vector3.new(0, 12, 0), 0.35)
		local bot = spawnAnchor(target.Position, 0.35)
		local beam = Instance.new("Beam")
		beam.Attachment0 = Instance.new("Attachment", top)
		beam.Attachment1 = Instance.new("Attachment", bot)
		beam.Color = ColorSequence.new(col, Color3.new(1, 1, 1))
		beam.LightEmission = 1
		beam.Width0 = 0.8
		beam.Width1 = 0.15
		beam.FaceCamera = true
		beam.Parent = top
		makeBurst(target.Position, col, 18, 10)
		addHighlight(char, col, 0.25)
	end

	local function effectSparkHit(char)
		local root = getRoot(char)
		if not root then
			return
		end
		makeBurst(root.Position + Vector3.new(0, 1.2, 0), accent(), 22, 8)
	end

	local function effectSelfAura()
		local char = LP.Character
		if not char then
			return
		end
		local root = getRoot(char)
		if not root then
			return
		end
		makeBurst(root.Position, accent(), 35, 12)
		addHighlight(char, accent(), 0.5)
	end

	local KILL_FX = {
		Neon = effectNeonDissolve,
		Burst = effectParticleBurst,
		Ascension = effectAscension,
		Shock = effectShockRing,
	}

	local HIT_FX = {
		Lightning = effectLightningHit,
		Sparks = effectSparkHit,
	}

	local function pickKillFx()
		local style = S.KillEffectStyle or "Neon"
		if style == "Random" then
			local keys = { "Neon", "Burst", "Ascension", "Shock" }
			style = keys[math.random(1, #keys)]
		end
		return KILL_FX[style] or effectNeonDissolve
	end

	local function pickHitFx()
		return HIT_FX[S.HitEffectStyle or "Lightning"] or effectLightningHit
	end

	local function recentKill()
		local t = tonumber(S.LastShotAt)
		return t and (tick() - t) <= 2.5
	end

	local function recentHit()
		local t = tonumber(S.LastShotAt)
		return t and (tick() - t) <= 1.5
	end

	local function isOurVictim(hum)
		if not hum or not hum.Parent or not isEnemyChar(hum.Parent) then
			return false
		end
		if S.LastShotHum and hum ~= S.LastShotHum then
			return false
		end
		return true
	end

	local function runOnVictim(hum, fn)
		local char = resolveVictimChar(hum)
		if not char then
			return
		end
		pcall(function()
			fn(char)
		end)
	end

	function S.OnLocalHit(hum, dmg)
		if not S.HitEffects then
			return
		end
		if not recentHit() or not isOurVictim(hum) then
			return
		end
		runOnVictim(hum, pickHitFx())
	end

	function S.OnLocalKill(hum, plrName)
		if not S.KillEffects then
			if S.SelfKillFX and recentKill() and isOurVictim(hum) then
				pcall(effectSelfAura)
			end
			return
		end
		if not recentKill() or not isOurVictim(hum) then
			return
		end
		runOnVictim(hum, pickKillFx())
		if S.SelfKillFX then
			pcall(effectSelfAura)
		end
	end

	function S.TestKillEffect()
		local char = getCrosshairVictim()
		if not char then
			return false, "Celuj w wroga (crosshair)"
		end
		pcall(function()
			pickKillFx()(char)
		end)
		return true
	end

	function S.TestHitEffect()
		local char = getCrosshairVictim()
		if not char then
			return false, "Celuj w wroga (crosshair)"
		end
		pcall(function()
			pickHitFx()(char)
		end)
		return true
	end
end

return Effects
