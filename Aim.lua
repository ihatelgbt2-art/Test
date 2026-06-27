-- Plik: workspace/Vanguard/Aim.lua

local Aim = {}

function Aim.Init(S, ParentGUI)
	local Players = game:GetService("Players")
	local RS = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")
	local VIM = game:GetService("VirtualInputManager")

	local LP = Players.LocalPlayer
	local Cam = workspace.CurrentCamera
	local Mouse = LP:GetMouse()

	local history = {}
	local silentPos = nil
	local jitterSeed = math.random() * 100
	local lastTrigger = 0

	local function C(class, props)
		local i = Instance.new(class)
		for k, v in pairs(props) do
			i[k] = v
		end
		return i
	end

	-- FOV ring
	local FOVC = C("Frame", {
		Name = "FOVCircle",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, S.FOV * 2, 0, S.FOV * 2),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 1,
		Parent = ParentGUI,
	})
	C("UICorner", { CornerRadius = UDim.new(1, 0), Parent = FOVC })
	C("UIStroke", {
		Color = S.V,
		Thickness = 1,
		Transparency = 0.3,
		Parent = FOVC,
	})

	local function updFOV()
		local d = S.FOV * 2
		FOVC.Size = UDim2.new(0, d, 0, d)
		FOVC.Visible = S.ShowFOV and (S.Aimbot or S.Silent or S.Trigger)
	end

	-- Backtrack history
	local function pushHistory(plr, hrp)
		if not history[plr] then
			history[plr] = {}
		end
		local h = history[plr]
		table.insert(h, { t = tick(), pos = hrp.Position, cf = hrp.CFrame })
		while #h > 60 do
			table.remove(h, 1)
		end
	end

	local function backtrackPos(plr)
		if not S.Backtrack then
			return nil
		end
		local h = history[plr]
		if not h or #h == 0 then
			return nil
		end
		local targetT = tick() - S.BacktrackMs / 1000
		local best = h[1]
		for _, entry in ipairs(h) do
			if entry.t <= targetT then
				best = entry
			else
				break
			end
		end
		return best.pos
	end

	local function getPart(char)
		return char:FindFirstChild(S.AimPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
	end

	local function isEnemy(plr)
		if plr == LP then
			return false
		end
		local char = plr.Character
		local hum = char and char:FindFirstChild("Humanoid")
		if not char or not hum or hum.Health <= 0 then
			return false
		end
		if S.Team and plr.Team and LP.Team and plr.Team == LP.Team then
			return false
		end
		return true
	end

	local function screenDist(part)
		local pos, onScreen = Cam:WorldToViewportPoint(part.Position)
		if not onScreen then
			return math.huge, nil
		end
		local center = Cam.ViewportSize / 2
		return (Vector2.new(pos.X, pos.Y) - Vector2.new(center.X, center.Y)).Magnitude, pos
	end

	local function isVisible(part, char)
		if not S.VisibleCheck then
			return true
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = LP.Character and { LP.Character } or {}
		local dir = part.Position - Cam.CFrame.Position
		local hit = workspace:Raycast(Cam.CFrame.Position, dir, params)
		return hit and hit.Instance:IsDescendantOf(char)
	end

	local function getTargetPos(plr, part)
		local bt = backtrackPos(plr)
		local hrp = part.Parent and part.Parent:FindFirstChild("HumanoidRootPart")
		if bt and hrp then
			return bt + (part.Position - hrp.Position)
		end
		return part.Position
	end

	local function getBestTarget()
		local best, bestScore = nil, math.huge
		local center = Cam.ViewportSize / 2

		for _, plr in ipairs(Players:GetPlayers()) do
			if not isEnemy(plr) then
				continue
			end
			local char = plr.Character
			local part = getPart(char)
			if not part then
				continue
			end

			local dist2d, _ = screenDist(part)
			if dist2d > S.FOV then
				continue
			end
			if not isVisible(part, char) then
				continue
			end

			local dist3d = (Cam.CFrame.Position - part.Position).Magnitude
			if dist3d > S.MaxDist then
				continue
			end

			local score
			if S.TargetMode == "Distance" then
				score = dist3d
			elseif S.TargetMode == "Health" then
				score = char.Humanoid.Health
			else
				score = dist2d
			end

			if score < bestScore then
				bestScore = score
				best = { plr = plr, part = part, char = char }
			end
		end
		return best
	end

	local function aimCamera(targetPos)
		local goal = CFrame.new(Cam.CFrame.Position, targetPos)
		local alpha = math.clamp((1 - S.Smooth) * 0.22, 0.012, 0.45)
		if S.AimCurve then
			local j = (math.noise(tick() * 2.5, jitterSeed) - 0.5) * 0.35
			alpha = math.clamp(alpha * (1 + j * S.Smooth), 0.008, 0.5)
		end
		Cam.CFrame = Cam.CFrame:Lerp(goal, alpha)
	end

	local function rayEnemy()
		local mpos = UIS:GetMouseLocation()
		local ray = Cam:ViewportPointToRay(mpos.X, mpos.Y)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = LP.Character and { LP.Character } or {}
		local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
		if not hit then
			return nil
		end
		local model = hit.Instance:FindFirstAncestorOfClass("Model")
		if not model then
			return nil
		end
		local hum = model:FindFirstChild("Humanoid")
		if not hum or hum.Health <= 0 then
			return nil
		end
		local plr = Players:GetPlayerFromCharacter(model)
		if not plr or plr == LP then
			return nil
		end
		if S.Team and plr.Team and LP.Team and plr.Team == LP.Team then
			return nil
		end
		if S.VisibleCheck and not isVisible(hit.Instance, model) then
			return nil
		end
		return model
	end

	local function fireClick()
		local loc = UIS:GetMouseLocation()
		VIM:SendMouseButtonEvent(loc.X, loc.Y, 0, true, game, 0)
		task.defer(function()
			VIM:SendMouseButtonEvent(loc.X, loc.Y, 0, false, game, 0)
		end)
	end

	-- Silent aim hook (executors with hookmetamethod)
	local silentHooked = false
	local function setupSilent()
		if silentHooked then
			return
		end
		if not hookmetamethod then
			return
		end
		silentHooked = true
		local old
		old = hookmetamethod(game, "__index", function(self, key)
			local callerOk = not checkcaller or not checkcaller()
			if S.Silent and silentPos and callerOk then
				if self == Mouse and (key == "Hit" or key == "Target") then
					return CFrame.new(silentPos)
				end
			end
			return old(self, key)
		end)
	end
	setupSilent()

	RS.RenderStepped:Connect(function()
		updFOV()

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP and plr.Character then
				local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					pushHistory(plr, hrp)
				end
			end
		end

		silentPos = nil
		local tgt = getBestTarget()

		if tgt and (S.Aimbot or S.Silent) then
			local pos = getTargetPos(tgt.plr, tgt.part)
			if S.Silent then
				silentPos = pos
			end
			if S.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				aimCamera(pos)
			end
		end
	end)

	RS.Heartbeat:Connect(function()
		if not S.Trigger then
			return
		end
		if tick() - lastTrigger < 0.1 then
			return
		end
		if rayEnemy() then
			lastTrigger = tick()
			fireClick()
		end
	end)

	Players.PlayerRemoving:Connect(function(plr)
		history[plr] = nil
	end)
end

return Aim
