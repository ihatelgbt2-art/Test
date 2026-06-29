-- Plik: workspace/Vanguard/Animations.lua

local Animations = {}

Animations.LIST = {
	{ label = "Twerk", procedural = "twerk", chat = "dance3", ids = { 179224234, 1071434050, 182436935 } },
	{ label = "Floss", procedural = "floss", ids = { 1071434727, 182436842, 5917570207 } },
	{ label = "Griddy", procedural = "griddy" },
	{ label = "Spin", procedural = "spin" },
	{ label = "Thunder", procedural = "thunder" },
	{ label = "Matrix", procedural = "matrix" },
	{ label = "Disco", procedural = "disco" },
	{ label = "Levitate", procedural = "levitate" },
	{ label = "Dance", chat = "dance", folders = { "dance", "dance2", "dance3" }, ids = { 507771019, 507776879, 507777623, 507771955, 507772104 } },
	{ label = "Dance 2", chat = "dance2", folders = { "dance2" }, ids = { 507776879, 507776043, 507776720 } },
	{ label = "Dance 3", chat = "dance3", folders = { "dance3" }, ids = { 507777623, 507777268, 507777451 } },
	{ label = "Wave", chat = "wave", folders = { "wave" }, ids = { 507770239 } },
	{ label = "Point", chat = "point", folders = { "point" }, ids = { 507770453 } },
	{ label = "Laugh", chat = "laugh", folders = { "laugh" }, ids = { 507770818 } },
	{ label = "Cheer", chat = "cheer", folders = { "cheer" }, ids = { 507770677 } },
	{ label = "Sit", chat = "sit", folders = { "sit" }, ids = { 2506281703, 507767968 } },
}

function Animations.Init(S)
	local Players = game:GetService("Players")
	local RS = game:GetService("RunService")
	local CP = game:GetService("ContentProvider")
	local TS = game:GetService("TweenService")
	local Debris = game:GetService("Debris")
	local Lighting = game:GetService("Lighting")
	local LP = Players.LocalPlayer

	local currentTrack = nil
	local currentAnim = nil
	local proceduralConn = nil
	local proceduralStop = false
	local fxHighlight = nil
	local fxBloom = nil
	local fxCC = nil
	local trailAnchor = nil

	local accent = function()
		return S.V or Color3.fromRGB(0, 255, 150)
	end

	local function clearFx()
		if fxHighlight then
			pcall(function() fxHighlight:Destroy() end)
			fxHighlight = nil
		end
		if fxBloom then
			pcall(function() fxBloom:Destroy() end)
			fxBloom = nil
		end
		if fxCC then
			pcall(function() fxCC:Destroy() end)
			fxCC = nil
		end
		if trailAnchor then
			pcall(function() trailAnchor:Destroy() end)
			trailAnchor = nil
		end
	end

	local function startEmoteFx(char)
		clearFx()
		if not char then
			return
		end
		local col = accent()
		fxHighlight = Instance.new("Highlight")
		fxHighlight.Name = "VG_AnimFX"
		fxHighlight.Adornee = char
		fxHighlight.FillColor = col
		fxHighlight.OutlineColor = Color3.new(1, 1, 1)
		fxHighlight.FillTransparency = 0.55
		fxHighlight.OutlineTransparency = 0.2
		fxHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		fxHighlight.Parent = Lighting

		fxBloom = Instance.new("BloomEffect")
		fxBloom.Name = "VG_AnimBloom"
		fxBloom.Intensity = 0.8
		fxBloom.Size = 20
		fxBloom.Threshold = 0.85
		fxBloom.Parent = Lighting

		fxCC = Instance.new("ColorCorrectionEffect")
		fxCC.Name = "VG_AnimCC"
		fxCC.Saturation = 0.25
		fxCC.TintColor = col
		fxCC.Parent = Lighting

		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			trailAnchor = Instance.new("Part")
			trailAnchor.Name = "VG_AnimTrail"
			trailAnchor.Anchored = true
			trailAnchor.CanCollide = false
			trailAnchor.CanQuery = false
			trailAnchor.CanTouch = false
			trailAnchor.Transparency = 1
			trailAnchor.Size = Vector3.new(0.2, 0.2, 0.2)
			trailAnchor.CFrame = root.CFrame
			trailAnchor.Parent = workspace
			local em = Instance.new("ParticleEmitter")
			em.Texture = "rbxassetid://243660064"
			em.Color = ColorSequence.new(col, Color3.new(1, 1, 1))
			em.LightEmission = 1
			em.Rate = 35
			em.Lifetime = NumberRange.new(0.3, 0.7)
			em.Speed = NumberRange.new(1, 4)
			em.SpreadAngle = Vector2.new(30, 30)
			em.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.8),
				NumberSequenceKeypoint.new(1, 0),
			})
			em.Parent = trailAnchor
		end
	end

	local function pulseHighlight()
		if not fxHighlight then
			return
		end
		local t = tick()
		fxHighlight.FillTransparency = 0.45 + math.sin(t * 8) * 0.15
		if fxCC then
			fxCC.Brightness = math.sin(t * 6) * 0.08
		end
		if fxBloom then
			fxBloom.Intensity = 0.7 + math.sin(t * 5) * 0.25
		end
	end

	local function stopCurrent()
		proceduralStop = true
		if proceduralConn then
			proceduralConn:Disconnect()
			proceduralConn = nil
		end
		if currentTrack then
			pcall(function()
				currentTrack:Stop(0.15)
			end)
			currentTrack = nil
		end
		if currentAnim then
			pcall(function()
				currentAnim:Destroy()
			end)
			currentAnim = nil
		end
		clearFx()
	end

	local function ensureAnimator(hum)
		local animator = hum:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = hum
		end
		return animator
	end

	local function collectAnimateRoots()
		local roots = {}
		local char = LP.Character
		if char then
			local a = char:FindFirstChild("Animate")
			if a then
				table.insert(roots, a)
			end
		end
		local sp = game:GetService("StarterPlayer")
		local sc = sp:FindFirstChild("StarterCharacterScripts")
		if sc then
			local a = sc:FindFirstChild("Animate")
			if a then
				table.insert(roots, a)
			end
		end
		local rep = game:GetService("ReplicatedStorage")
		for _, name in ipairs({ "Animate", "Animations", "Emotes" }) do
			local f = rep:FindFirstChild(name, true)
			if f then
				table.insert(roots, f)
			end
		end
		return roots
	end

	local function findGameAnimation(entry)
		local names = entry.folders or {}
		for _, root in ipairs(collectAnimateRoots()) do
			for _, folderName in ipairs(names) do
				local folder = root:FindFirstChild(folderName, true)
				if folder then
					local anim = folder:FindFirstChildWhichIsA("Animation", true)
					if anim and anim.AnimationId ~= "" then
						return anim:Clone()
					end
				end
			end
		end
		return nil
	end

	local function tryGetObjects(id)
		local getter = game.GetObjects or (typeof(getobjects) == "function" and getobjects) or nil
		if not getter then
			return nil
		end
		local ok, objs = pcall(function()
			return getter("rbxassetid://" .. tostring(id))
		end)
		if not ok or not objs or not objs[1] then
			return nil
		end
		local root = objs[1]
		if root:IsA("Animation") then
			return root:Clone()
		end
		local anim = root:FindFirstChildWhichIsA("Animation", true)
		if anim then
			return anim:Clone()
		end
		return nil
	end

	local function makeAnimation(id)
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. tostring(id)
		return anim
	end

	local function tryLoadTrack(animator, anim)
		local track
		pcall(function()
			CP:PreloadAsync({ anim })
		end)
		local ok, result = pcall(function()
			return animator:LoadAnimation(anim)
		end)
		if ok then
			track = result
		end
		return track
	end

	local function tryChatEmote(entry)
		if not entry.chat then
			return false
		end
		return pcall(function()
			local msg = "/e " .. entry.chat
			if LP.Chat then
				LP:Chat(msg)
			else
				local ev = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
				local say = ev and ev:FindFirstChild("SayMessageRequest")
				if say then
					say:FireServer(msg, "All")
				end
			end
		end)
	end

	local function playTrack(track, entry)
		currentTrack = track
		currentTrack.Priority = Enum.AnimationPriority.Action
		local once = entry.chat == "point" or entry.chat == "wave" or entry.chat == "laugh"
		currentTrack.Looped = not once and entry.procedural == nil
		currentTrack:Play(0.15, 1, 1)
		S.LastAnim = entry.label
		startEmoteFx(LP.Character)
	end

	local function getRigParts(char)
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local lower = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
		local upper = char:FindFirstChild("UpperTorso") or lower
		return hrp, lower, upper
	end

	local function spawnProceduralBurst(hrp, col)
		if not hrp then
			return
		end
		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Transparency = 1
		p.Size = Vector3.new(0.2, 0.2, 0.2)
		p.CFrame = hrp.CFrame
		p.Parent = workspace
		local em = Instance.new("ParticleEmitter")
		em.Texture = "rbxassetid://243660064"
		em.Color = ColorSequence.new(col)
		em.LightEmission = 1
		em.Rate = 0
		em.Lifetime = NumberRange.new(0.3, 0.6)
		em.Speed = NumberRange.new(6, 14)
		em.SpreadAngle = Vector2.new(360, 360)
		em.Parent = p
		em:Emit(12)
		Debris:AddItem(p, 1)
	end

	local function playProcedural(kind, entry)
		local char = LP.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then
			return false, "Brak postaci"
		end
		local hrp, lower, upper = getRigParts(char)
		if not hrp then
			return false, "Brak HRP"
		end

		proceduralStop = false
		local baseCF = hrp.CFrame
		local tStart = tick()
		local savedAuto = hum.AutoRotate
		hum.AutoRotate = false
		startEmoteFx(char)
		local col = accent()
		local burstTick = 0

		proceduralConn = RS.RenderStepped:Connect(function()
			if proceduralStop or not char.Parent or hum.Health <= 0 then
				return
			end
			local t = tick()
			if trailAnchor and hrp.Parent then
				trailAnchor.CFrame = hrp.CFrame * CFrame.new(0, -2.5, 0)
			end
			pulseHighlight()

			if t - burstTick > 0.35 then
				burstTick = t
				if kind == "thunder" or kind == "disco" or kind == "spin" then
					spawnProceduralBurst(hrp, col)
				end
			end

			if kind == "twerk" then
				local w = math.sin(t * 18)
				local pitch = w * 0.42
				local roll = w * 0.35
				hrp.CFrame = baseCF * CFrame.new(0, math.abs(w) * 0.12, 0) * CFrame.Angles(pitch, 0, roll)
			elseif kind == "floss" then
				local w = math.sin(t * 12)
				hrp.CFrame = baseCF * CFrame.Angles(0, w * 0.95, w * 0.28)
			elseif kind == "griddy" then
				local w = math.sin(t * 14)
				hrp.CFrame = baseCF
					* CFrame.new(w * 0.22, math.abs(math.sin(t * 10)) * 0.14, 0)
					* CFrame.Angles(0, w * 0.35, w * 0.12)
			elseif kind == "spin" then
				hrp.CFrame = baseCF * CFrame.Angles(math.sin(t * 4) * 0.15, (t - tStart) * 9, math.cos(t * 4) * 0.12)
			elseif kind == "thunder" then
				local shake = math.sin(t * 28) * 0.08
				hrp.CFrame = baseCF
					* CFrame.new(shake, math.abs(math.sin(t * 20)) * 0.1, shake * 0.5)
					* CFrame.Angles(shake * 2, (t - tStart) * 2.5, shake)
			elseif kind == "matrix" then
				local hover = math.sin(t * 3) * 0.15
				hrp.CFrame = baseCF
					* CFrame.new(0, hover + 0.4, 0)
					* CFrame.Angles(math.rad(90), (t - tStart) * 1.2, 0)
			elseif kind == "disco" then
				local w = math.sin(t * 16)
				hrp.CFrame = baseCF
					* CFrame.new(0, math.abs(w) * 0.1, 0)
					* CFrame.Angles(0, (t - tStart) * 12, w * 0.4)
				if fxHighlight then
					local hue = (t * 0.8) % 1
					fxHighlight.FillColor = Color3.fromHSV(hue, 0.9, 1)
				end
			elseif kind == "levitate" then
				local bob = math.sin(t * 2.5) * 0.25
				hrp.CFrame = baseCF * CFrame.new(0, 1.2 + bob, 0) * CFrame.Angles(0, (t - tStart) * 1.5, 0)
			end
		end)

		S.LastAnim = entry.label .. " (procedural)"
		Animations._stopProcedural = function()
			proceduralStop = true
			if proceduralConn then
				proceduralConn:Disconnect()
				proceduralConn = nil
			end
			hum.AutoRotate = savedAuto
			if hrp and hrp.Parent then
				hrp.CFrame = baseCF
			end
			clearFx()
		end
		return true
	end

	function Animations.Play(entry)
		if not entry then
			return false, "Brak animacji"
		end
		local char = LP.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum then
			return false, "Brak postaci"
		end

		stopCurrent()
		if Animations._stopProcedural then
			pcall(Animations._stopProcedural)
			Animations._stopProcedural = nil
		end

		if entry.procedural then
			local ok, err = playProcedural(entry.procedural, entry)
			if ok then
				return true
			end
		end

		local animator = ensureAnimator(hum)

		local gameAnim = findGameAnimation(entry)
		if gameAnim then
			local ok, track = pcall(function()
				return tryLoadTrack(animator, gameAnim)
			end)
			if ok and track then
				currentAnim = gameAnim
				playTrack(track, entry)
				return true
			end
			pcall(function() gameAnim:Destroy() end)
		end

		for _, id in ipairs(entry.ids or {}) do
			local fromObjects = tryGetObjects(id)
			if fromObjects then
				local ok, track = pcall(function()
					return tryLoadTrack(animator, fromObjects)
				end)
				if ok and track then
					currentAnim = fromObjects
					playTrack(track, entry)
					return true
				end
				pcall(function() fromObjects:Destroy() end)
			end

			local anim = makeAnimation(id)
			local ok, track = pcall(function()
				return tryLoadTrack(animator, anim)
			end)
			if ok and track then
				currentAnim = anim
				playTrack(track, entry)
				return true
			end
			pcall(function() anim:Destroy() end)
		end

		if tryChatEmote(entry) then
			S.LastAnim = entry.label .. " (chat)"
			startEmoteFx(char)
			return true
		end

		if entry.procedural then
			return playProcedural(entry.procedural, entry)
		end

		return false, "Gra blokuje animacje — spróbuj Twerk/Griddy (procedural)"
	end

	function Animations.Stop()
		stopCurrent()
		if Animations._stopProcedural then
			pcall(Animations._stopProcedural)
			Animations._stopProcedural = nil
		end
		S.LastAnim = nil
		return true
	end

	LP.CharacterAdded:Connect(function()
		task.defer(function()
			Animations.Stop()
		end)
	end)

	if _G.VANGUARD then
		_G.VANGUARD.registerCleanup(function()
			Animations.Stop()
		end)
	end
end

return Animations
