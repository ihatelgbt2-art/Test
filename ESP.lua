-- Plik: workspace/Vanguard/ESP.lua

local ESP = {}

function ESP.Init(S, ParentGUI)
	local P, RS = game:GetService("Players"), game:GetService("RunService")
	local LP, Cam = P.LocalPlayer, workspace.CurrentCamera
	
	-- Lokalna funkcja do szybkiego tworzenia obiektów
	local function C(c, p) local i = Instance.new(c); for k, v in pairs(p) do i[k] = v end; return i end

	local ESP_C = C("Frame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Parent=ParentGUI})
	local Cache, Bones = {}, {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}

	local function Ln() return C("Frame", {AnchorPoint=Vector2.new(0.5,0.5), BorderSizePixel=0, Visible=false, Parent=ESP_C}) end
	local function UpdLn(f, p1, p2, c)
		local d = p2-p1; f.Size, f.Position, f.Rotation, f.BackgroundColor3, f.Visible = UDim2.new(0,d.Magnitude,0,S.Th), UDim2.new(0,(p1.X+p2.X)/2,0,(p1.Y+p2.Y)/2), math.deg(math.atan2(d.Y,d.X)), c, true
	end

	RS.RenderStepped:Connect(function()
		ESP_C.Visible = S.ESP; if not S.ESP then return end

		for _, p in pairs(P:GetPlayers()) do
			if p == LP then continue end
			local c = p.Character
			local h, hrp = c and c:FindFirstChild("Humanoid"), c and c:FindFirstChild("HumanoidRootPart")
			
			if not Cache[p] then
				Cache[p] = {
					B=C("Frame",{BackgroundTransparency=1,Parent=ESP_C}), 
					BO=C("UIStroke",{Thickness=S.Th}), 
					T=C("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=11,TextStrokeTransparency=0,Parent=ESP_C}), 
					HB=C("Frame",{BackgroundColor3=Color3.fromRGB(30,30,30),BorderSizePixel=0,Parent=ESP_C}),
					CHM=C("Highlight",{FillTransparency=0.6,OutlineTransparency=0.2,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,Parent=ParentGUI}),
					Tr=Ln(), Sk={}
				}
				Cache[p].BO.Parent = Cache[p].B
				C("UIStroke",{Thickness=1,Color=Color3.new(0,0,0),Parent=Cache[p].HB})
				Cache[p].HF = C("Frame",{BackgroundColor3=Color3.new(0,1,0),BorderSizePixel=0,Parent=Cache[p].HB})
				for _=1, #Bones do table.insert(Cache[p].Sk, Ln()) end
			end
			
			local ch = Cache[p]
			local val = c and h and hrp and h.Health>0 and (not S.Team or p.Team~=LP.Team)
			
			if val then
				local cf, sz = c:GetBoundingBox()
				local ray = S.LoS and workspace:Raycast(Cam.CFrame.Position, hrp.Position-Cam.CFrame.Position, RaycastParams.new())
				local clr = S.V
				if S.RealTeamColor and p.Team then clr = p.Team.TeamColor.Color
				elseif S.LoS and ray and ray.Instance and not ray.Instance:IsDescendantOf(c) then clr = S.O end
				
				if S.Chams then ch.CHM.Adornee = c; ch.CHM.FillColor = clr; ch.CHM.OutlineColor = clr; ch.CHM.Enabled = true else ch.CHM.Enabled = false end

				local rp, os = Cam:WorldToViewportPoint(cf.Position)
				if os then
					local t2 = Cam:WorldToViewportPoint(cf.Position + Vector3.new(0, sz.Y/2, 0))
					local b2 = Cam:WorldToViewportPoint(cf.Position - Vector3.new(0, sz.Y/2, 0))
					local h2, w2 = math.abs(t2.Y-b2.Y), math.abs(t2.Y-b2.Y)*(sz.X/sz.Y)
					
					if S.Box then ch.B.Size, ch.B.Position, ch.BO.Color, ch.B.Visible = UDim2.new(0,w2,0,h2), UDim2.new(0,rp.X-w2/2,0,t2.Y), clr, true else ch.B.Visible = false end
					if S.Name then ch.T.Text, ch.T.Size, ch.T.Position, ch.T.TextColor3, ch.T.Visible = p.Name.." ["..math.floor((Cam.CFrame.Position-cf.Position).Magnitude).."m]", UDim2.new(0,w2,0,15), UDim2.new(0,rp.X-w2/2,0,t2.Y-18), clr, true else ch.T.Visible = false end
					
					if S.Health then
						local hpRatio = math.clamp(h.Health / h.MaxHealth, 0, 1)
						local hpClr = Color3.new(1,0,0):Lerp(Color3.new(0,1,0), hpRatio)
						ch.HB.Size = UDim2.new(0, 3, 0, h2)
						ch.HB.Position = UDim2.new(0, rp.X - w2/2 - 7, 0, t2.Y)
						ch.HF.Size = UDim2.new(1, 0, hpRatio, 0)
						ch.HF.Position = UDim2.new(0, 0, 1 - hpRatio, 0)
						ch.HF.BackgroundColor3 = hpClr
						ch.HB.Visible = true
					else ch.HB.Visible = false end
					
					if S.Trace then
						local o2 = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y)
						if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then local mpos,mos = Cam:WorldToViewportPoint(LP.Character.HumanoidRootPart.Position) if mos then o2 = Vector2.new(mpos.X, mpos.Y) end end
						UpdLn(ch.Tr, o2, Vector2.new(rp.X, b2.Y), clr)
					else ch.Tr.Visible = false end
					
					if S.Skel then
						for i, bn in ipairs(Bones) do
							local p1, p2 = c:FindFirstChild(bn[1]), c:FindFirstChild(bn[2])
							if p1 and p2 then
								local p1_2, o1 = Cam:WorldToViewportPoint(p1.Position)
								local p2_2, o2 = Cam:WorldToViewportPoint(p2.Position)
								if o1 and o2 then UpdLn(ch.Sk[i], Vector2.new(p1_2.X,p1_2.Y), Vector2.new(p2_2.X,p2_2.Y), clr) else ch.Sk[i].Visible = false end
							else ch.Sk[i].Visible = false end
						end
					else for _, bn in pairs(ch.Sk) do bn.Visible = false end end
				else
					ch.B.Visible, ch.T.Visible, ch.Tr.Visible, ch.HB.Visible = false, false, false, false; for _, bn in pairs(ch.Sk) do bn.Visible = false end
				end
			else
				ch.B.Visible, ch.T.Visible, ch.Tr.Visible, ch.HB.Visible, ch.CHM.Enabled = false, false, false, false, false; for _, bn in pairs(ch.Sk) do bn.Visible = false end
			end
		end
	end)

	P.PlayerRemoving:Connect(function(p) if Cache[p] then Cache[p].B:Destroy() Cache[p].T:Destroy() Cache[p].HB:Destroy() Cache[p].CHM:Destroy() Cache[p].Tr:Destroy() for _, bn in pairs(Cache[p].Sk) do bn:Destroy() end Cache[p]=nil end end)
end

return ESP