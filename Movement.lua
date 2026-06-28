-- Plik: workspace/Vanguard/Movement.lua

local Movement = {}

function Movement.Init(S)
	local RS = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")
	local LP = game:GetService("Players").LocalPlayer

	local strafeDir = 1

	local function isAirborne(hum)
		local state = hum:GetState()
		return state == Enum.HumanoidStateType.Freefall
			or state == Enum.HumanoidStateType.Jumping
			or state == Enum.HumanoidStateType.Flying
	end

	RS.RenderStepped:Connect(function()
		if not S.BHop and not S.AutoStrafe then
			return
		end

		local char = LP.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp or hum.Health <= 0 then
			return
		end

		if S.BHop and hum.MoveDirection.Magnitude >= 0.08 then
			local state = hum:GetState()
			if state == Enum.HumanoidStateType.Running
				or state == Enum.HumanoidStateType.RunningNoPhysics
				or state == Enum.HumanoidStateType.Landed then
				hum.Jump = true
			end
		end

		if S.AutoStrafe and isAirborne(hum) then
			local mouseDelta = UIS:GetMouseDelta()
			if math.abs(mouseDelta.X) > 0.04 then
				strafeDir = mouseDelta.X > 0 and 1 or -1
			end

			local vel = hrp.AssemblyLinearVelocity
			local flatSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
			if flatSpeed > 3 or hum.MoveDirection.Magnitude > 0.08 then
				hum:Move(Vector3.new(strafeDir, 0, -1), true)
			end
		end
	end)
end

return Movement
