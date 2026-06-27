-- Plik: workspace/Vanguard/UI.lua

local UI = {}

function UI.Init(S, ParentGUI)
	local UIS, TS = game:GetService("UserInputService"), game:GetService("TweenService")
	local function C(c, p) local i = Instance.new(c); for k, v in pairs(p) do i[k] = v end; return i end

	local Menu = C("Frame", {Size=UDim2.new(0,560,0,320), Position=UDim2.new(0.5,-280,0.5,-160), BackgroundColor3=Color3.fromRGB(15,15,18), Parent=ParentGUI, Active=true})
	C("UICorner", {CornerRadius=UDim.new(0,8), Parent=Menu}); C("UIStroke", {Color=Color3.fromRGB(45,45,50), Thickness=1, Parent=Menu})

	local Top = C("Frame", {Size=UDim2.new(1,0,0,35), BackgroundColor3=Color3.fromRGB(20,20,24), Parent=Menu})
	C("UICorner", {CornerRadius=UDim.new(0,8), Parent=Top})
	C("TextLabel", {Size=UDim2.new(1,-15,1,0), Position=UDim2.new(0,15,0,0), Text="VANGUARD | PRO ESP STUDIO", TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamBold, TextSize=12, BackgroundTransparency=1, TextXAlignment=0, Parent=Top})

	local Side = C("Frame", {Size=UDim2.new(0,130,1,-35), Position=UDim2.new(0,0,0,35), BackgroundTransparency=1, Parent=Menu})
	C("UIListLayout", {Padding=UDim.new(0,2), Parent=Side})

	local Pages = C("Frame", {Size=UDim2.new(0,220,1,-45), Position=UDim2.new(0,135,0,40), BackgroundTransparency=1, Parent=Menu})
	local Pgs = {}

	local PrvP = C("Frame", {Size=UDim2.new(0,185,1,-55), Position=UDim2.new(1,-195,0,45), BackgroundColor3=Color3.fromRGB(10,10,12), Parent=Menu})
	C("UICorner", {CornerRadius=UDim.new(0,6), Parent=PrvP}); C("UIStroke", {Color=Color3.fromRGB(30,30,35), Parent=PrvP})
	C("TextLabel", {Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0,5), Text="LIVE PREVIEW", TextColor3=Color3.fromRGB(150,150,150), Font=Enum.Font.GothamBold, TextSize=10, BackgroundTransparency=1, Parent=PrvP})

	local M_Box = C("Frame", {Size=UDim2.new(0,80,0,130), Position=UDim2.new(0.5,-40,0.5,-55), BackgroundTransparency=1, Parent=PrvP})
	C("UIStroke", {Thickness=S.Th, Color=S.V, Parent=M_Box})
	local M_Nm = C("TextLabel", {Size=UDim2.new(1,0,0,15), Position=UDim2.new(0,0,0,-20), Text="Enemy [15m]", TextColor3=S.V, Font=Enum.Font.GothamBold, TextSize=11, BackgroundTransparency=1, Parent=M_Box})
	local M_Tr = C("Frame", {Size=UDim2.new(0,S.Th,0,60), Position=UDim2.new(0.5,0,1,0), BackgroundColor3=S.V, BorderSizePixel=0, Parent=M_Box})

	local M_HB = C("Frame", {Size=UDim2.new(0,3,1,0), Position=UDim2.new(0,-7,0,0), BackgroundColor3=Color3.fromRGB(30,30,30), BorderSizePixel=0, Parent=M_Box})
	C("UIStroke", {Thickness=1, Color=Color3.new(0,0,0), Parent=M_HB})
	local M_HF = C("Frame", {Size=UDim2.new(1,0,0.75,0), Position=UDim2.new(0,0,0.25,0), BackgroundColor3=Color3.new(0.5,1,0), BorderSizePixel=0, Parent=M_HB})

	local function UpdPreview()
		M_Box.Visible = S.Box; M_Nm.Visible = S.Name; M_Tr.Visible = S.Trace; M_HB.Visible = S.Health
	end; UpdPreview()

	local function MakeTab(n, d)
		local B = C("TextButton", {Size=UDim2.new(1,0,0,30), Text="   "..n, TextXAlignment=0, TextColor3=d and Color3.new(1,1,1) or Color3.new(0.5,0.5,0.5), BackgroundTransparency=1, Font=Enum.Font.GothamSemibold, TextSize=12, Parent=Side})
		local P = C("ScrollingFrame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ScrollBarThickness=0, Visible=d, Parent=Pages})
		C("UIListLayout", {Padding=UDim.new(0,6), Parent=P})
		B.MouseButton1Click:Connect(function()
			for b, p in pairs(Pgs) do b.TextColor3 = Color3.new(0.5,0.5,0.5); p.Visible = false end
			B.TextColor3 = Color3.new(1,1,1); P.Visible = true
		end)
		Pgs[B] = P; return P
	end

	local function MakeTog(p, t, k)
		local B = C("TextButton", {Size=UDim2.new(1,0,0,30), BackgroundColor3=Color3.fromRGB(22,22,26), Text="   "..t, TextColor3=Color3.new(0.8,0.8,0.8), TextXAlignment=0, Font=Enum.Font.Gotham, TextSize=12, Parent=p})
		C("UICorner", {CornerRadius=UDim.new(0,4), Parent=B})
		local Bg = C("Frame", {Size=UDim2.new(0,34,0,18), Position=UDim2.new(1,-44,0.5,-9), BackgroundColor3=S[k] and S.V or Color3.fromRGB(40,40,45), Parent=B})
		C("UICorner", {CornerRadius=UDim.new(1,0), Parent=Bg})
		local Dot = C("Frame", {Size=UDim2.new(0,14,0,14), Position=S[k] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7), BackgroundColor3=Color3.new(1,1,1), Parent=Bg})
		C("UICorner", {CornerRadius=UDim.new(1,0), Parent=Dot})
		
		B.MouseButton1Click:Connect(function()
			S[k] = not S[k] -- <--- TUTAJ KLIKNIĘCIE ZMIENIA USTAWIENIA!
			TS:Create(Bg, TweenInfo.new(0.25), {BackgroundColor3=S[k] and S.V or Color3.fromRGB(40,40,45)}):Play()
			TS:Create(Dot, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position=S[k] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
			UpdPreview()
		end)
	end

	local T1, T2 = MakeTab("Visuals", true), MakeTab("Settings", false)
	MakeTog(T1, "Master ESP", "ESP"); MakeTog(T1, "Show Boxes", "Box"); MakeTog(T1, "Show Names", "Name")
	MakeTog(T1, "Show Health Bars", "Health"); MakeTog(T1, "Show Skeletons", "Skel")
	MakeTog(T1, "Show Tracers", "Trace"); MakeTog(T1, "Show Chams (Fill)", "Chams")
	MakeTog(T2, "Use Team Colors", "RealTeamColor"); MakeTog(T2, "Hide Teammates", "Team")
	MakeTog(T2, "Line of Sight Color", "LoS")

	local drg, st, pos
	Top.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drg=true st=i.Position pos=Menu.Position end end)
	UIS.InputChanged:Connect(function(i) if drg and i.UserInputType == Enum.UserInputType.MouseMovement then Menu.Position = UDim2.new(pos.X.Scale, pos.X.Offset+(i.Position.X-st.X), pos.Y.Scale, pos.Y.Offset+(i.Position.Y-st.Y)) end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drg=false end end)
	UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.RightShift then Menu.Visible = not Menu.Visible end end)
end

return UI