-- Plik: workspace/Vanguard/Animations.lua

local Animations = {}

Animations.LIST = {
	{ label = "Dance", id = 507771019 },
	{ label = "Wave", id = 507770239 },
	{ label = "Point", id = 507770453 },
	{ label = "Laugh", id = 507770818 },
	{ label = "Cheer", id = 507770677 },
	{ label = "Sit", id = 507767968 },
	{ label = "Twerk", id = 1071434050 },
	{ label = "Floss", id = 1071434727 },
	{ label = "Hype", id = 1071434050 },
	{ label = "Robot", id = 1071436019 },
}

function Animations.Init(S)
	local Players = game:GetService("Players")
	local LP = Players.LocalPlayer

	local currentTrack = nil
	local currentAnim = nil

	local function stopCurrent()
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
	end

	local function getAnimator()
		local char = LP.Character
		if not char then
			return nil
		end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then
			return nil
		end
		return hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 2)
	end

	function Animations.Play(entry)
		if not entry or not entry.id then
			return false, "Brak animacji"
		end
		local animator = getAnimator()
		if not animator then
			return false, "Brak postaci / Animator"
		end

		stopCurrent()

		local ok, err = pcall(function()
			local anim = Instance.new("Animation")
			anim.AnimationId = "rbxassetid://" .. tostring(entry.id)
			local track = animator:LoadAnimation(anim)
			currentAnim = anim
			currentTrack = track
			currentTrack.Priority = Enum.AnimationPriority.Action
			currentTrack.Looped = true
			currentTrack:Play(0.15, 1, 1)
		end)
		if not ok then
			return false, "Nie udało się załadować"
		end
		S.LastAnim = entry.label
		return true
	end

	function Animations.Stop()
		stopCurrent()
		S.LastAnim = nil
		return true
	end

	LP.CharacterAdded:Connect(function()
		task.defer(stopCurrent)
	end)
end

return Animations
