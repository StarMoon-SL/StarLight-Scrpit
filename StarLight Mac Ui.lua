local MacLib = {
	Options = {},
	Folder = "Maclib",
	GetService = function(s) return cloneref and cloneref(game:GetService(s)) or game:GetService(s) end
}
local TweenService, RunService, HttpService = MacLib.GetService("TweenService"), MacLib.GetService("RunService"), MacLib.GetService("HttpService")
local UserInputService, Lighting, Players = MacLib.GetService("UserInputService"), MacLib.GetService("Lighting"), MacLib.GetService("Players")
MacLib.DevicePlatform = pcall(function() return UserInputService:GetPlatform()) and UserInputService:GetPlatform() or Enum.Platform.None
MacLib.IsStudio = RunService:IsStudio()
MacLib.IsMobile = (MacLib.DevicePlatform == Enum.Platform.Android or MacLib.DevicePlatform == Enum.Platform.IOS)
MacLib.IsDesktop = not MacLib.IsMobile and not MacLib.IsStudio
local hasGlobalSetting, acrylicBlur, unloaded = false, true, false
local tabIndex = 0
local UIOpen = true
local UILocked = false
local assets = {
	interFont = "rbxassetid://12187365364", userInfoBlurred = "rbxassetid://18824089198", toggleBackground = "rbxassetid://18772190202",
	togglerHead = "rbxassetid://18772309008", buttonImage = "rbxassetid://10709791437", searchIcon = "rbxassetid://86737463322606",
	colorWheel = "rbxassetid://2849458409", colorTarget = "rbxassetid://73265255323268", grid = "rbxassetid://121484455191370",
	globe = "rbxassetid://108952102602834", transform = "rbxassetid://90336395745819", dropdown = "rbxassetid://18865373378",
	sliderbar = "rbxassetid://18772615246", sliderhead = "rbxassetid://18772834246",
}
local function GetGui()
	local gui = Instance.new("ScreenGui")
	gui.ScreenInsets, gui.ResetOnSpawn, gui.ZIndexBehavior, gui.DisplayOrder = Enum.ScreenInsets.None, false, Enum.ZIndexBehavior.Sibling, 2147483647
	local parent = MacLib.IsStudio and Players.LocalPlayer:FindFirstChild("PlayerGui") or (gethui and gethui()) or (cloneref and cloneref(MacLib.GetService("CoreGui")) or MacLib.GetService("CoreGui"))
	gui.Parent = parent
	return gui
end
local function CreateInstance(class, props, parent)
	local inst = Instance.new(class)
	for prop, val in pairs(props or {}) do
		if type(val) ~= "table" then
			inst[prop] = val
		elseif prop == "Events" then
			for event, func in pairs(val) do inst[event]:Connect(func) end
		end
	end
	if parent then inst.Parent = parent end
	return inst
end
local function QuickTween(obj, duration, props, style, dir)
	return TweenService:Create(obj, TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end
local function ConnectHover(btn, enterFunc, leaveFunc)
	btn.MouseEnter:Connect(enterFunc)
	btn.MouseLeave:Connect(leaveFunc or enterFunc)
end
local KeybindSystem = {
	Keybinds = {},
	ActiveKeybinds = {},
	MainKeybind = nil,
	MouseButtons = {
		[Enum.UserInputType.MouseButton1] = "MB1",
		[Enum.UserInputType.MouseButton2] = "MB2",
		[Enum.UserInputType.MouseButton3] = "MB3"
	}
}
function KeybindSystem:Init(mainGui, baseFrame)
	self.MainGui = mainGui
	self.BaseFrame = baseFrame
	self.KeybindContainer = CreateInstance("Frame", {
		Name = "KeybindContainer",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(15,15,15),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(10, 0.5),
		Size = UDim2.fromOffset(210, 20),
		Visible = false,
		ZIndex = 100
	}, mainGui)
	CreateInstance("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1,1,1), Transparency = 0.9}, self.KeybindContainer)
	CreateInstance("UICorner", {CornerRadius = UDim.new(0,6)}, self.KeybindContainer)
	local inner = CreateInstance("Frame", {
		Name = "Inner",
		BackgroundColor3 = Color3.fromRGB(20,20,20),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(1,1),
		Size = UDim2.new(1,-2,1,-2)
	}, self.KeybindContainer)
	CreateInstance("UICorner", {CornerRadius = UDim.new(0,5)}, inner)
	local colorBar = CreateInstance("Frame", {
		Name = "ColorBar",
		BackgroundColor3 = Color3.new(1,1,1),
		BorderSizePixel = 0,
		Size = UDim2.new(1,0,0,1),
		ZIndex = 101
	}, inner)
	local titleLabel = CreateInstance("TextLabel", {
		Name = "TitleLabel",
		FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium),
		Text = "Keybinds",
		TextColor3 = Color3.new(1,1,1),
		TextSize = 14,
		TextTransparency = 0.1,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(5, 2),
		Size = UDim2.fromOffset(60, 18)
	}, inner)
	local listContainer = CreateInstance("Frame", {
		Name = "ListContainer",
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,1,-20),
		Position = UDim2.fromOffset(0,20)
	}, inner)
	CreateInstance("UIListLayout", {
		Padding = UDim.new(0,2),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, listContainer)
	self.ListContainer = listContainer
	local function updatePosition()
		local ySize = 0
		local xSize = 210
		for _, frame in ipairs(listContainer:GetChildren()) do
			if frame:IsA("Frame") then
				ySize = ySize + 18
				local label = frame:FindFirstChild("TextLabel", true)
				if label and label.AbsoluteSize.X > xSize then
					xSize = label.AbsoluteSize.X + 20
				end
			end
		end
		local viewport = workspace.CurrentCamera.ViewportSize
		self.KeybindContainer.Position = UDim2.fromOffset(10, viewport.Y - ySize - 30)
		self.KeybindContainer.Size = UDim2.fromOffset(xSize, ySize + 25)
	end
	listContainer.ChildAdded:Connect(updatePosition)
	listContainer.ChildRemoved:Connect(updatePosition)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		local keyName = KeybindSystem.MouseButtons[input.UserInputType] or (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name)
		if not keyName then return end
		for idx, keybind in pairs(KeybindSystem.Keybinds) do
			if keybind.Value == keyName and keybind.Mode ~= "Always" then
				if keybind.Mode == "Toggle" then
					keybind.Toggled = not keybind.Toggled
					if keybind.Callback then
						task.spawn(keybind.Callback, keybind.Toggled)
					end
					KeybindSystem:UpdateKeybindDisplay(idx)
				elseif keybind.Mode == "Hold" then
					keybind.Holding = true
					if keybind.Callback then
						task.spawn(keybind.Callback, true)
					end
				end
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		local keyName = KeybindSystem.MouseButtons[input.UserInputType] or (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name)
		if not keyName then return end
		for idx, keybind in pairs(KeybindSystem.Keybinds) do
			if keybind.Value == keyName and keybind.Mode == "Hold" then
				keybind.Holding = false
				if keybind.Callback then
					task.spawn(keybind.Callback, false)
				end
			end
		end
	end)
	CreateInstance("ImageButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1,1),
		Events = {
			InputBegan = function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					dragStart = input.Position
					startPos = self.KeybindContainer.Position
				end
			end,
			InputChanged = function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					dragInput = input
				end
			end,
			InputEnded = function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end
		},
		Parent = self.KeybindContainer
	})
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			KeybindSystem.KeybindContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	return self.KeybindContainer
end
function KeybindSystem:AddKeybind(Idx, Info, parent)
	Info.Mode = Info.Mode or "Toggle"
	Info.Text = Info.Text or "Keybind"
	Info.Default = Info.Default or "None"
	local keybind = {
		Value = Info.Default,
		Mode = Info.Mode,
		Callback = Info.Callback,
		Toggled = false,
		Holding = false,
		Type = "KeyPicker"
	}
	local container = CreateInstance("Frame", {
		Name = "KeybindFrame",
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,18),
		Visible = true,
		ZIndex = 101,
		Parent = self.ListContainer
	}, self.ListContainer)
	local outer = CreateInstance("Frame", {
		Name = "KeybindOuter",
		BackgroundColor3 = Color3.new(0,0,0),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(13,13),
		Position = UDim2.fromOffset(0, 3)
	}, container)
	CreateInstance("UICorner", {CornerRadius = UDim.new(0,3)}, outer)
	local inner = CreateInstance("Frame", {
		Name = "KeybindInner",
		BackgroundColor3 = Color3.fromRGB(25,25,25),
		BorderSizePixel = 0,
		Size = UDim2.new(1,0,1,0),
		Parent = outer
	})
	local check = CreateInstance("TextLabel", {
		Name = "Checkmark",
		FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium),
		Text = "✓",
		TextColor3 = Color3.new(1,1,1),
		TextSize = 11,
		TextTransparency = 1,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(-10,0),
		Parent = inner
	})
	local label = CreateInstance("TextLabel", {
		Name = "KeybindLabel",
		FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium),
		Text = string.format("[%s] %s (%s)", keybind.Value, Info.Text, keybind.Mode),
		TextColor3 = Color3.new(1,1,1),
		TextSize = 13,
		TextTransparency = 0.3,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, -1),
		Size = UDim2.new(1,-18,1,0)
	}, container)
	CreateInstance("UIListLayout", {
		Padding = UDim.new(0,4),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = label
	})
	local toggleRegion = CreateInstance("Frame", {
		Name = "ToggleRegion",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(170, 18),
		ZIndex = 103,
		Parent = outer
	})
	function keybind:UpdateDisplay()
		if keybind.Mode == "Toggle" then
			check.TextTransparency = keybind.Toggled and 0 or 1
			QuickTween(check, 0.2, {Size = UDim2.fromOffset(keybind.Toggled and 8 or -10, check.AbsoluteSize.Y)}):Play()
			label.TextTransparency = keybind.Toggled and 0.1 or 0.3
			inner.BackgroundColor3 = keybind.Toggled and Color3.new(1,1,1) or Color3.fromRGB(25,25,25)
		end
		label.Text = string.format("[%s] %s (%s)", keybind.Value, Info.Text, keybind.Mode)
	end
	toggleRegion.InputBegan:Connect(function(input)
		if not UILocked and ((input.UserInputType == Enum.UserInputType.MouseButton1 and not KeybindSystem:MouseIsOverOpenedFrame()) or input.UserInputType == Enum.UserInputType.Touch) then
			if keybind.Mode == "Toggle" then
				keybind.Toggled = not keybind.Toggled
				if keybind.Callback then
					task.spawn(keybind.Callback, keybind.Toggled)
				end
			end
		end
	end)
	if Info.Default ~= "None" then
		keybind:UpdateDisplay()
	end
	self.Keybinds[Idx] = keybind
	self:UpdateKeybindDisplay(Idx)
	return keybind
end
function KeybindSystem:UpdateKeybindDisplay(idx)
	local keybind = self.Keybinds[idx]
	if keybind and keybind.UpdateDisplay then
		keybind:UpdateDisplay()
	end
end
function KeybindSystem:ToggleUI()
	UIOpen = not UIOpen
	self.BaseFrame.Visible = UIOpen
	self.KeybindContainer.Visible = false
end
function KeybindSystem:ToggleKeybindDisplay()
	self.KeybindContainer.Visible = not self.KeybindContainer.Visible
end
function KeybindSystem:MouseIsOverOpenedFrame()
	for frame, _ in pairs(self.MainGui.OpenedFrames or {}) do
		if frame.Visible then
			local absPos, absSize = frame.AbsolutePosition, frame.AbsoluteSize
			local mousePos = UserInputService:GetMouseLocation()
			if mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y then
				return true
			end
		end
	end
	return false
end
function MacLib:Window(Settings)
	local WindowFuncs = {Settings = Settings}
	acrylicBlur = Settings.AcrylicBlur ~= false
	if MacLib.IsMobile then
		Settings.Size = Settings.Size or UDim2.fromOffset(550, math.min(400, workspace.CurrentCamera.ViewportSize.Y - 100))
	else
		Settings.Size = Settings.Size or UDim2.fromOffset(868,650)
	end
	local macLib = GetGui()
	self.MainGui = macLib
	local notifications = CreateInstance("Frame", {Name = "Notifications", BackgroundTransparency = 1, Size = UDim2.fromScale(1,1)}, macLib)
	local notifList = CreateInstance("UIListLayout", {Padding = UDim.new(0,10), HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom}, notifications)
	CreateInstance("UIPadding", {PaddingBottom = UDim.new(0,10), PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10), PaddingTop = UDim.new(0,10)}, notifications)
	local base = CreateInstance("Frame", {
		Name = "Base", AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = Color3.fromRGB(15,15,15),
		BackgroundTransparency = acrylicBlur and 0.05 or 0, BorderSizePixel = 0,
		Position = Settings.Position or UDim2.fromScale(0.5,0.5), Size = Settings.Size
	}, macLib)
	KeybindSystem:Init(macLib, base)
	local baseScale = CreateInstance("UIScale", {}, base)
	CreateInstance("UICorner", {CornerRadius = UDim.new(0,10)}, base)
	CreateInstance("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1,1,1), Transparency = 0.9}, base)
	local sidebar = CreateInstance("Frame", {Name = "Sidebar", BackgroundTransparency = 1, Size = UDim2.fromScale(0.325,1)}, base)
	local divider = CreateInstance("Frame", {Name = "Divider", AnchorPoint = Vector2.new(1,0), BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.9, Position = UDim2.fromScale(1,0), Size = UDim2.new(0,1,1,0)}, sidebar)
	local dividerInteract = CreateInstance("TextButton", {Name = "DividerInteract", AnchorPoint = Vector2.new(0.5,0), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5,0), Size = UDim2.new(1,6,1,0), Text = ""}, divider)
	ConnectHover(dividerInteract, 
		function() QuickTween(divider, 0.2, {BackgroundTransparency = 0.85}, Enum.EasingStyle.Sine):Play() end,
		function() QuickTween(divider, 0.2, {BackgroundTransparency = 0.9}, Enum.EasingStyle.Sine):Play() end
	)
	local windowControls = CreateInstance("Frame", {Name = "WindowControls", BackgroundTransparency = 1, Size = UDim2.new(1,0,0,31)}, sidebar)
	local controls = CreateInstance("Frame", {Name = "Controls", BackgroundTransparency = 1, Size = UDim2.fromScale(1,1)}, windowControls)
	CreateInstance("UIListLayout", {Padding = UDim.new(0,5), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}, controls)
	CreateInstance("UIPadding", {PaddingLeft = UDim.new(0,11), PaddingRight = UDim.new(0,5)}, controls)
	CreateInstance("Frame", {Name = "Divider", AnchorPoint = Vector2.new(0,1), BackgroundTransparency = 0.9, Position = UDim2.fromScale(0,1), Size = UDim2.new(1,0,0,1)}, windowControls)
	local function CreateControlButton(name, color, layout, tooltip, callback)
		local btn = CreateInstance("TextButton", {
			Name = name, AutoButtonColor = false, BackgroundColor3 = color, BorderSizePixel = 0, LayoutOrder = layout or 0,
			Text = "", Events = {MouseButton1Click = callback}
		}, controls)
		CreateInstance("UICorner", {CornerRadius = UDim.new(1,0)}, btn)
		if tooltip and MacLib.IsDesktop then
			ConnectHover(btn,
				function()
					QuickTween(btn, 0.2, {BackgroundTransparency = 0.5, Size = UDim2.fromOffset(12,12)}, Enum.EasingStyle.Sine):Play()
				end,
				function()
					QuickTween(btn, 0.2, {BackgroundTransparency = 0, Size = UDim2.fromOffset(14,14)}, Enum.EasingStyle.Sine):Play()
				end
			)
		else
			ConnectHover(btn,
				function() QuickTween(btn, 0.2, {BackgroundTransparency = 0.5, Size = UDim2.fromOffset(12,12)}, Enum.EasingStyle.Sine):Play() end,
				function() QuickTween(btn, 0.2, {BackgroundTransparency = 0, Size = UDim2.fromOffset(14,14)}, Enum.EasingStyle.Sine):Play() end
			)
		end
		return btn
	end
	CreateControlButton("Exit", Color3.fromRGB(250,93,86), 0, "关闭UI", function() macLib:Destroy() end)
	local hideBtn = CreateControlButton("ToggleUI", Color3.fromRGB(252,190,57), 1, "显示/隐藏UI (Ctrl+\\)", function()
		KeybindSystem:ToggleUI()
	end)
	local lockBtn = CreateControlButton("LockUI", Color3.fromRGB(119,174,94), 2, "锁定/解锁UI (Ctrl+L)", function()
		UILocked = not UILocked
		base.Active = not UILocked
		local lockIcon = lockBtn:FindFirstChild("LockIcon") or CreateInstance("TextLabel", {
			Name = "LockIcon",
			FontFace = Font.new(assets.interFont, Enum.FontWeight.Bold),
			Text = UILocked and "🔒" or "🔓",
			TextColor3 = Color3.new(1,1,1),
			TextSize = 8,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1,1),
			Parent = lockBtn
		}, lockBtn)
		lockIcon.Text = UILocked and "🔒" or "🔓"
	end)
	CreateControlButton("Maximize", Color3.fromRGB(119,174,94), 3, "最大化", function()
		base.Size = UDim2.fromScale(0.9,0.9)
		base.Position = UDim2.fromScale(0.5,0.5)
	end)
	local info = CreateInstance("Frame", {Name = "Information", BackgroundTransparency = 1, Position = UDim2.fromOffset(0,31), Size = UDim2.new(1,0,0,60)}, sidebar)
	CreateInstance("Frame", {Name = "Divider", AnchorPoint = Vector2.new(0,1), BackgroundTransparency = 0.9, Position = UDim2.fromScale(0,1), Size = UDim2.new(1,0,0,1)}, info)
	local infoHolder = CreateInstance("Frame", {Name = "InformationHolder", BackgroundTransparency = 1, Size = UDim2.fromScale(1,1)}, info)
	CreateInstance("UIPadding", {PaddingBottom = UDim.new(0,10), PaddingLeft = UDim.new(0,23), PaddingRight = UDim.new(0,22), PaddingTop = UDim.new(0,10)}, infoHolder)
	local globalBtn = CreateInstance("ImageButton", {
		Name = "GlobalSettingsButton", Image = assets.globe, ImageTransparency = 0.5,
		AnchorPoint = Vector2.new(1,0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(1,0.5), Size = UDim2.fromOffset(16,16)
	}, infoHolder)
	ConnectHover(globalBtn,
		function() QuickTween(globalBtn, 0.2, {ImageTransparency = 0.3}, Enum.EasingStyle.Sine):Play() end,
		function() QuickTween(globalBtn, 0.2, {ImageTransparency = 0.5}, Enum.EasingStyle.Sine):Play() end
	)
	local titleFrame = CreateInstance("Frame", {Name = "TitleFrame", BackgroundTransparency = 1, Size = UDim2.fromScale(1,1)}, infoHolder)
	CreateInstance("UIListLayout", {Padding = UDim.new(0,3), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}, titleFrame)
	local title = CreateInstance("TextLabel", {
		Name = "Title", FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold), Text = Settings.Title,
		TextColor3 = Color3.new(1,1,1), TextSize = 18, TextTransparency = 0.1, TextTruncate = Enum.TextTruncate.SplitWord,
		TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1,-20,0,0)
	}, titleFrame)
	local subtitle = CreateInstance("TextLabel", {
		Name = "Subtitle", FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium), Text = Settings.Subtitle,
		TextColor3 = Color3.new(1,1,1), TextSize = 12, TextTransparency = 0.7, TextTruncate = Enum.TextTruncate.SplitWord,
		TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.new(1,-20,0,0)
	}, titleFrame)
	local sidebarGroup = CreateInstance("Frame", {Name = "SidebarGroup", BackgroundTransparency = 1, Position = UDim2.fromOffset(0,91), Size = UDim2.new(1,0,1,-91)}, sidebar)
	CreateInstance("UIPadding", {PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10), PaddingTop = UDim.new(0,31)}, sidebarGroup)
	local userInfo = CreateInstance("Frame", {Name = "UserInfo", AnchorPoint = Vector2.new(0,1), BackgroundTransparency = 1, Position = UDim2.fromScale(0,1), Size = UDim2.new(1,0,0,107)}, sidebarGroup)
	CreateInstance("UIPadding", {PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10)}, userInfo)
	local infoGroup = CreateInstance("Frame", {Name = "InformationGroup", BackgroundTransparency = 1, Size = UDim2.fromScale(1,1)}, userInfo)
	CreateInstance("UIPadding", {PaddingBottom = UDim.new(0,17), PaddingLeft = UDim.new(0,25)}, infoGroup)
	CreateInstance("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}, infoGroup)
	local userId, headshotImage = Players.LocalPlayer.UserId, Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size48x48)
	local headshot = CreateInstance("ImageLabel", {
		Name = "Headshot", BackgroundTransparency = 1, Size = UDim2.fromOffset(32,32), Image = headshotImage
	}, infoGroup)
	CreateInstance("UICorner", {CornerRadius = UDim.new(1,0)}, headshot)
	CreateInstance("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1,1,1), Transparency = 0.9}, headshot)
	local userFrame = CreateInstance("Frame", {Name = "UserAndDisplayFrame", BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.new(1,-42,0,32)}, infoGroup)
	CreateInstance("UIPadding", {PaddingLeft = UDim.new(0,8), PaddingTop = UDim.new(0,3)}, userFrame)
	CreateInstance("UIListLayout", {Padding = UDim.new(0,1), SortOrder = Enum.SortOrder.LayoutOrder}, userFrame)
	CreateInstance("TextLabel", {
		Name = "DisplayName", FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold), Text = Players.LocalPlayer.DisplayName,
		TextColor3 = Color3.new(1,1,1), TextSize = 13, TextTransparency = 0.1, TextTruncate = Enum.TextTruncate.SplitWord,
		TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Size = UDim2.fromScale(1,0)
	}, userFrame)
	CreateInstance("TextLabel", {
		Name = "Username", FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold), Text = "@"..Players.LocalPlayer.Name,
		TextColor3 = Color3.new(1,1,1), TextSize = 12, TextTransparency = 0.7, TextTruncate = Enum.TextTruncate.SplitWord,
		TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.fromScale(1,0)
	}, userFrame)
	local tabSwitchers = CreateInstance("Frame", {Name = "TabSwitchers", BackgroundTransparency = 1, Size = UDim2.new(1,0,1,-107)}, sidebarGroup)
	local tabScroll = CreateInstance("ScrollingFrame", {
		Name = "TabSwitchersScrollingFrame", AutomaticCanvasSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		ScrollBarImageTransparency = 0.8, ScrollBarThickness = 1, Size = UDim2.fromScale(1,1)
	}, tabSwitchers)
	CreateInstance("UIListLayout", {Padding = UDim.new(0,17), SortOrder = Enum.SortOrder.LayoutOrder}, tabScroll)
	CreateInstance("UIPadding", {PaddingTop = UDim.new(0,2)}, tabScroll)
	local content = CreateInstance("Frame", {
		Name = "Content", AnchorPoint = Vector2.new(1,0), BackgroundTransparency = 1,
		Position = UDim2.fromScale(1,0), Size = UDim2.new(0, base.AbsoluteSize.X - sidebar.AbsoluteSize.X, 1, 0)
	}, base)
	local topbar = CreateInstance("Frame", {Name = "Topbar", BackgroundTransparency = 1, Size = UDim2.new(1,0,0,63)}, content)
	CreateInstance("Frame", {Name = "Divider", AnchorPoint = Vector2.new(0,1), BackgroundTransparency = 0.9, Position = UDim2.fromScale(0,1), Size = UDim2.new(1,0,0,1)}, topbar)
	local topElements = CreateInstance("Frame", {Name = "Elements", BackgroundTransparency = 1, Size = UDim2.fromScale(1,1)}, topbar)
	CreateInstance("UIPadding", {PaddingLeft = UDim.new(0,20), PaddingRight = UDim.new(0,20)}, topElements)
	local dragging, dragInput, dragStart, startPos
	local dragStyle = Settings.DragStyle or 1
	local dragTarget = dragStyle == 1 and topElements or base
	CreateInstance("ImageButton", {
		Name = "MoveIcon", Image = assets.transform, ImageTransparency = 0.7, AnchorPoint = Vector2.new(1,0.5),
		BackgroundTransparency = 1, Position = UDim2.fromScale(1,0.5), Size = UDim2.fromOffset(15,15),
		Visible = dragStyle == 1 and not MacLib.IsMobile,
		Events = {
			InputBegan = function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if not UILocked then
						dragging = true
						dragStart = input.Position
						startPos = base.Position
					end
				end
			end,
			InputChanged = function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					dragInput = input
				end
			end,
			InputEnded = function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end
		}
	}, topElements)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput and not UILocked then
			local delta = input.Position - dragStart
			base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	CreateInstance("TextLabel", {
		Name = "CurrentTab", FontFace = Font.new(assets.interFont), Text = "",
		TextTransparency = 0.5, TextXAlignment = Enum.TextXAlignment.Left, Anchor
_Point = Vector2.new(0,0.5), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Position = UDim2.fromScale(0,0.5), Size = UDim2.new(0.9,0,0,0)
	}, topElements)
	local resizing, initMouseX, initSidebarWidth, defaultWidth = false, 0, 0, sidebar.AbsoluteSize.X
	local minWidth, maxWidth = 107, base.AbsoluteSize.X - 107
	ConnectHover(dividerInteract, 
		nil,
		function() QuickTween(divider, 0.2, {BackgroundTransparency = 0.9}, Enum.EasingStyle.Sine):Play() end
	)
	dividerInteract.MouseButton1Down:Connect(function()
		if not UILocked then
			resizing, initMouseX, initSidebarWidth = true, UserInputService:GetMouseLocation().X, sidebar.AbsoluteSize.X
		end
	end)
	UserInputService.InputEnded:Connect(function(input) 
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = false 
		end 
	end)
	UserInputService.InputChanged:Connect(function(input)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = UserInputService:GetMouseLocation().X - initMouseX
			local newWidth = initSidebarWidth + delta
			if math.abs(newWidth - defaultWidth) < 20 then newWidth = defaultWidth end
			newWidth = math.clamp(newWidth, minWidth, maxWidth)
			sidebar.Size = UDim2.new(0, newWidth, 1, 0)
			content.Size = UDim2.new(0, base.AbsoluteSize.X - newWidth, 1, 0)
		end
	end)
	local globalSettings = CreateInstance("Frame", {
		Name = "GlobalSettings", AutomaticSize = Enum.AutomaticSize.XY, BackgroundColor3 = Color3.fromRGB(15,15,15),
		BorderSizePixel = 0, Position = UDim2.fromScale(0.298,0.104), Visible = false
	}, base)
	CreateInstance("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1,1,1), Transparency = 0.9}, globalSettings)
	CreateInstance("UICorner", {CornerRadius = UDim.new(0,10)}, globalSettings)
	CreateInstance("UIPadding", {PaddingBottom = UDim.new(0,10), PaddingTop = UDim.new(0,10)}, globalSettings)
	CreateInstance("UIListLayout", {Padding = UDim.new(0,5), SortOrder = Enum.SortOrder.LayoutOrder}, globalSettings)
	local gScale = CreateInstance("UIScale", {Scale = 1e-07}, globalSettings)
	local gToggled = false
	globalBtn.MouseButton1Click:Connect(function()
		if not hasGlobalSetting then return end
		gToggled = not gToggled
		QuickTween(gScale, 0.2, {Scale = gToggled and 1 or 0}, Enum.EasingStyle.Exponential):Play()
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 and gToggled and not globalSettings.MouseEnter then
			gToggled = false
			QuickTween(gScale, 0.2, {Scale = 0}, Enum.EasingStyle.Exponential):Play()
		end
	end)
	if acrylicBlur then
		local camera, HS = workspace.CurrentCamera, HttpService
		local wedgeGuid = HS:GenerateGUID(true)
		local depthField = Lighting:FindFirstChildOfClass("DepthOfFieldEffect") or Instance.new("DepthOfFieldEffect")
		depthField.FarIntensity, depthField.FocusDistance, depthField.InFocusRadius, depthField.NearIntensity = 0, 51.6, 50, 1
		depthField.Name, depthField.Parent = HS:GenerateGUID(true), Lighting
		local glassFrame = CreateInstance("Frame", {Name = HS:GenerateGUID(true), Size = UDim2.new(0.97,0,0.97,0), Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1}, base)
		local function IsNotNaN(x) return x == x end
		repeat task.wait() until IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
		local parts = {}
		local function UpdateOrientation()
			local visible, parent = true, glassFrame
			while parent do
				if parent:IsA("GuiObject") and not parent.Visible then visible = false; break
				elseif parent:IsA("ScreenGui") and not parent.Enabled then visible = false; break end
				parent = parent.Parent
			end
			if not visible or not acrylicBlur or unloaded then
				for _, p in pairs(parts) do p.Parent = nil end
				depthField.Enabled = false; return
			end
			depthField.Enabled, depthField.Parent = true, Lighting
			for _, p in pairs(parts) do p:Destroy() end
			parts = {}
			local tl, br = glassFrame.AbsolutePosition, glassFrame.AbsolutePosition + glassFrame.AbsoluteSize
			local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
			for _, pt in pairs({camera:ScreenPointToRay(tl.x, tl.y).Origin, camera:ScreenPointToRay(tr.x, tr.y).Origin, camera:ScreenPointToRay(bl.x, bl.y).Origin, camera:ScreenPointToRay(br.x, br.y).Origin}) do
				local part = Instance.new("Part")
				part.Anchored, part.CanCollide, part.CastShadow = true, false, false
				part.Material, part.Size = Enum.Material.Glass, Vector3.new(0.2,0.2,0.2)
				part.Transparency, part.BrickColor = 0.98, BrickColor.new("Institutional white")
				part.Name = HS:GenerateGUID(true)
				part.Parent = camera
				table.insert(parts, part)
			end
		end
		RunService.RenderStepped:Connect(UpdateOrientation)
	end
	function WindowFuncs:GlobalSetting(SettingData)
		hasGlobalSetting = true
		local GFuncs = {}
		local gBtn = CreateInstance("TextButton", {
			Name = "GlobalSetting", BackgroundTransparency = 1, Size = UDim2.fromOffset(200,30), Text = "",
			Events = {MouseButton1Click = function()
				SettingData.Callback = SettingData.Callback or function() end
				toggled = not toggled
				QuickTween(check, 0.2, {Size = UDim2.new(check.Size.X.Scale, toggled and 12 or -10, check.Size.Y.Scale, check.Size.Y.Offset)}):Play()
				QuickTween(label, 0.2, {TextTransparency = toggled and 0.2 or 0.5}):Play()
				check.TextTransparency = toggled and 0 or 1
				task.spawn(SettingData.Callback, toggled)
			end}
		}, globalSettings)
		CreateInstance("UIPadding", {PaddingLeft = UDim.new(0,15)}, gBtn)
		CreateInstance("UIListLayout", {Padding = UDim.new(0,10), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}, gBtn)
		local label = CreateInstance("TextLabel", {
			Name = "SettingName", FontFace = Font.new(assets.interFont), Text = SettingData.Name,
			TextColor3 = Color3.new(1,1,1), TextSize = 13, TextTransparency = 0.5, TextTruncate = Enum.TextTruncate.SplitWord,
			TextXAlignment = Enum.TextXAlignment.Left, AnchorPoint = Vector2.new(0,0.5), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1, Position = UDim2.fromScale(0,0.5), Size = UDim2.new(1,-40,0,0)
		}, gBtn)
		local check = CreateInstance("TextLabel", {
			Name = "Checkmark", FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium), Text = "✓", LayoutOrder = -1,
			TextColor3 = Color3.new(1,1,1), TextSize = 13, TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
			AnchorPoint = Vector2.new(0,0.5), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			Position = UDim2.fromScale(0,0.5), Size = UDim2.fromOffset(-10,0)
		}, gBtn)
		local toggled = SettingData.Default
		if toggled then
			check.Size = UDim2.new(check.Size.X.Scale, 12, check.Size.Y.Scale, check.Size.Y.Offset)
			check.TextTransparency, label.TextTransparency = 0, 0.2
		end
		function GFuncs:UpdateName(name) label.Text = name end
		function GFuncs:UpdateState(state) toggled = not state; gBtn:MouseButton1Click() end
		return GFuncs
	end
	function WindowFuncs:TabGroup()
		local SectionFuncs = {}
		local group = CreateInstance("Frame", {Name = "Section", AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.fromScale(1,0)}, tabScroll)
		CreateInstance("Frame", {Name = "Divider", AnchorPoint = Vector2.new(0.5,1), BackgroundTransparency = 0.9, Position = UDim2.fromScale(0.5,1), Size = UDim2.new(1,-21,0,1)}, group)
		local switchers = CreateInstance("Frame", {Name = "SectionTabSwitchers", BackgroundTransparency = 1, Size = UDim2.fromScale(1,1)}, group)
		CreateInstance("UIListLayout", {Padding = UDim.new(0,15), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder}, switchers)
		CreateInstance("UIPadding", {PaddingBottom = UDim.new(0,15)}, switchers)
		function SectionFuncs:Tab(TabData)
			local TabFuncs = {}
			tabIndex = tabIndex + 1
			local tabBtn = CreateInstance("TextButton", {
				Name = "TabSwitcher", AutoButtonColor = false, AnchorPoint = Vector2.new(0.5,0), BackgroundTransparency = 1,
				LayoutOrder = tabIndex, Position = UDim2.fromScale(0.5,0), Size = UDim2.new(1,-21,0,40), Text = "",
				Events = {MouseButton1Click = function() currentTab.Text = TabData.Name end}
			}, switchers)
			CreateInstance("UICorner", {}, tabBtn)
			CreateInstance("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1,1,1), Transparency = 1}, tabBtn)
			CreateInstance("UIListLayout", {Padding = UDim.new(0,9), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}, tabBtn)
			CreateInstance("UIPadding", {PaddingLeft = UDim.new(0,24), PaddingRight = UDim.new(0,35), PaddingTop = UDim.new(0,1)}, tabBtn)
			if TabData.Image then
				CreateInstance("ImageLabel", {Name = "TabImage", Image = TabData.Image, ImageTransparency = 0.5, BackgroundTransparency = 1, Size = UDim2.fromOffset(18,18)}, tabBtn)
			end
			local tabName = CreateInstance("TextLabel", {
				Name = "TabSwitcherName", FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium), Text = TabData.Name,
				TextColor3 = Color3.new(1,1,1), TextSize = 16, TextTransparency = 0.5, TextTruncate = Enum.TextTruncate.SplitWord,
				TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.fromScale(1,0)
			}, tabBtn)
			local elements = CreateInstance("Frame", {Name = "Elements", BackgroundTransparency = 1, Position = UDim2.fromOffset(0,63), Size = UDim2.new(1,0,1,-63), ClipsDescendants = true}, content)
			CreateInstance("UIPadding", {PaddingRight = UDim.new(0,5), PaddingTop = UDim.new(0,10), PaddingBottom = UDim.new(0,10)}, elements)
			local scroll = CreateInstance("ScrollingFrame", {
				Name = "ElementsScrolling", AutomaticCanvasSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
				ScrollBarImageTransparency = 0.5, ScrollBarThickness = 1, Size = UDim2.fromScale(1,1), ClipsDescendants = false
			}, elements)
			CreateInstance("UIPadding", {PaddingBottom = UDim.new(0,5), PaddingLeft = UDim.new(0,11), PaddingRight = UDim.new(0,3), PaddingTop = UDim.new(0,5)}, scroll)
			CreateInstance("UIListLayout", {Padding = UDim.new(0,15), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder}, scroll)
			local left = CreateInstance("Frame", {Name = "Left", AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Position = UDim2.fromScale(0.512,0), Size = UDim2.new(0.5,-10,0,0)}, scroll)
			CreateInstance("UIListLayout", {Padding = UDim.new(0,15), SortOrder = Enum.SortOrder.LayoutOrder}, left)
			local right = CreateInstance("Frame", {Name = "Right", AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Position = UDim2.fromScale(0.512,0), Size = UDim2.new(0.5,-10,0,0)}, scroll)
			CreateInstance("UIListLayout", {Padding = UDim.new(0,15), SortOrder = Enum.SortOrder.LayoutOrder}, right)
			function TabFuncs:Section(SectionData)
				local SecFuncs = {}
				local section = CreateInstance("Frame", {
					Name = "Section", AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.98,
					BorderSizePixel = 0, Position = UDim2.fromScale(0,6.78e-08), Size = UDim2.fromScale(1,0), ClipsDescendants = true, Parent = SectionData.Side == "Left" and left or right
				})
				CreateInstance("UICorner", {}, section)
				CreateInstance("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1,1,1), Transparency = 0.95}, section)
				CreateInstance("UIListLayout", {Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder}, section)
				CreateInstance("UIPadding", {PaddingBottom = UDim.new(0,20), PaddingLeft = UDim.new(0,20), PaddingRight = UDim.new(0,18), PaddingTop = UDim.new(0,22)}, section)
				local function buildComponent(name, size, layout)
					local frame = CreateInstance("Frame", {
						Name = name, AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0,
						Size = UDim2.new(1,0,0,size), Parent = section
					}, section)
					if layout then CreateInstance("UIListLayout", layout, frame) end
					return frame
				end
				function SecFuncs:Button(ButtonData, Flag)
					local BtnFuncs = {Settings = ButtonData}
					local btn = buildComponent("Button", 38)
					local interact = CreateInstance("TextButton", {
						Name = "ButtonInteract", FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium),
						Text = ButtonData.Name, TextColor3 = Color3.new(1,1,1), TextSize = 13, TextTransparency = 0.5,
						TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), Text = "",
						Events = {
							MouseEnter = function() QuickTween(btn, 0.2, {TextTransparency = 0.3, ImageTransparency = 0.3}, Enum.EasingStyle.Sine):Play() end,
							MouseLeave = function() QuickTween(btn, 0.2, {TextTransparency = 0.5, ImageTransparency = 0.5}, Enum.EasingStyle.Sine):Play() end,
							MouseButton1Click = function() if ButtonData.Callback then ButtonData.Callback() end end
						}
					}, btn)
					local img = CreateInstance("ImageLabel", {
						Name = "ButtonImage", Image = assets.buttonImage, ImageTransparency = 0.5,
						AnchorPoint = Vector2.new(1,0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(1,0.5), Size = UDim2.fromOffset(15,15)
					}, btn)
					function BtnFuncs:UpdateName(name) interact.Text = name end
					function BtnFuncs:SetVisibility(state) btn.Visible = state end
					if Flag then MacLib.Options[Flag] = BtnFuncs end
					return BtnFuncs
				end
				function SecFuncs:Toggle(ToggleData, Flag)
					local TogFuncs = {Settings = ToggleData, State = ToggleData.Default}
					local toggle = buildComponent("Toggle", 38)
					local label = CreateInstance("TextLabel", {
						Name = "ToggleName", FontFace = Font.new(assets.interFont), Text = ToggleData.Name,
						TextColor3 = Color3.new(1,1,1), TextSize = 13, TextTransparency = 0.5,
						TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left,
						AnchorPoint = Vector2.new(0,0.5), AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1, Position = UDim2.fromScale(0,0.5), Size = UDim2.new(1,-50,0,0)
					}, toggle)
					local toggleBtn = CreateInstance("ImageButton", {
						Name = "Toggle", Image = assets.toggleBackground, ImageColor3 = Color3.fromRGB(87,86,86), ImageTransparency = 0.5,
						AnchorPoint = Vector2.new(1,0.5), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromScale(1,0.5), Size = UDim2.fromOffset(41,21),
						Events = {
							MouseButton1Click = function()
								TogFuncs.State = not TogFuncs.State
								QuickTween(toggleBtn, 0.15, {ImageTransparency = TogFuncs.State and 0 or 0.5}, Enum.EasingStyle.Quad):Play()
								QuickTween(toggler, 0.15, {ImageTransparency = TogFuncs.State and 0 or 0.85, Position = TogFuncs.State and UDim2.new(1,0,0.5,0) or UDim2.new(0.5,0,0.5,0)}, Enum.EasingStyle.Quad):Play()
								if ToggleData.Callback then ToggleData.Callback(TogFuncs.State) end
							end
						}
					}, toggle)
					CreateInstance("UIPadding", {PaddingBottom = UDim.new(0,1), PaddingLeft = UDim.new(0,-2), PaddingRight = UDim.new(0,3), PaddingTop = UDim.new(0,1)}, toggleBtn)
					local toggler = CreateInstance("ImageLabel", {
						Name = "TogglerHead", Image = assets.togglerHead, ImageColor3 = Color3.new(1,1,1), ImageTransparency = 0.85,
						AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, Position = ToggleData.Default and UDim2.new(1,0,0.5,0) or UDim2.new(0.5,0,0.5,0), Size = UDim2.fromOffset(15,15), ZIndex = 2
					}, toggleBtn)
					if ToggleData.Default then
						toggleBtn.ImageTransparency = 0
						toggler.ImageTransparency = 0
					end
					function TogFuncs:Toggle() toggleBtn:MouseButton1Click() end
					function TogFuncs:UpdateState(state) if state ~= TogFuncs.State then toggleBtn:MouseButton1Click() end end
					function TogFuncs:GetState() return TogFuncs.State end
					function TogFuncs:UpdateName(name) label.Text = name end
					function TogFuncs:SetVisibility(state) toggle.Visible = state end
					if Flag then MacLib.Options[Flag] = TogFuncs end
					return TogFuncs
				end
				function SecFuncs:Slider(SliderData, Flag)
					local SliFuncs = {Settings = SliderData, Value = SliderData.Default}
					local slider = buildComponent("Slider", 38)
					local label = CreateInstance("TextLabel", {
						Name = "SliderName", FontFace = Font.new(assets.interFont), Text = SliderData.Name,
						TextColor3 = Color3.new(1,1,1), TextSize = 13, TextTransparency = 0.5,
						TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left,
						AnchorPoint = Vector2.new(0,0.5), AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1, Position = UDim2.fromScale(0,0.5)
					}, slider)
					local elements = CreateInstance("Frame", {
						Name = "SliderElements", AnchorPoint = Vector2.new(1,0), BackgroundTransparency = 1,
						Position = UDim2.fromScale(1,0), Size = UDim2.fromScale(1,1)
					}, slider)
					CreateInstance("UIListLayout", {Padding = UDim.new(0,20), FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}, elements)
					CreateInstance("UIPadding", {PaddingTop = UDim.new(0,3)}, elements)
					local valueBox = CreateInstance("TextBox", {
						Name = "SliderValue", FontFace = Font.new(assets.interFont), PlaceholderText = tostring(SliderData.Default),
						Text = tostring(SliderData.Default), TextColor3 = Color3.new(1,1,1), TextSize = 12, TextTransparency = 0.1,
						AnchorPoint = Vector2.new(1,0), BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.95,
						BorderSizePixel = 0, LayoutOrder = 1, Position = UDim2.fromScale(-0.0789,0.171), Size = UDim2.fromOffset(41,21), ClipsDescendants = true
					}, elements)
					CreateInstance("UICorner", {CornerRadius = UDim.new(0,4)}, valueBox)
					CreateInstance("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1,1,1), Transparency = 0.9}, valueBox)
					CreateInstance("UIPadding", {PaddingLeft = UDim.new(0,2), PaddingRight = UDim.new(0,2)}, valueBox)
					local bar = CreateInstance("ImageLabel", {
						Name = "SliderBar", Image = assets.sliderbar, ImageColor3 = Color3.fromRGB(87,86,86),
						BackgroundTransparency = 1, Position = UDim2.fromScale(0.219,0.457), Size = UDim2.fromOffset(123,3)
					}, elements)
					local head = CreateInstance("ImageButton", {
						Name = "SliderHead", Image = assets.sliderhead, AnchorPoint = Vector2.new(0.5,0.5),
						BackgroundTransparency = 1, Size = UDim2.fromOffset(12,12), Parent = bar
					})
					local DisplayMethods = {
						Value = function(v, p) return p and string.format("%."..p.."f", v) or tostring(v) end,
						Degrees = function(v, p) return (p and string.format("%."..p.."f", v) or tostring(v)).."°" end,
						Percent = function(v, p) local pct = (v - SliderData.Minimum) / (SliderData.Maximum - SliderData.Minimum) * 100 return (p and string.format("%."..p.."f", pct) or tostring(math.round(pct))).."%" end
					}
					local method = DisplayMethods[SliderData.DisplayMethod] or DisplayMethods.Value
					local dragging, finalValue = false, SliderData.Default
					local function SetValue(val)
						if type(val) == "number" then
							val = math.clamp(val, SliderData.Minimum, SliderData.Maximum)
							finalValue = val
							local posX = (val - SliderData.Minimum) / (SliderData.Maximum - SliderData.Minimum)
							head.Position = UDim2.new(posX, 0, 0.5, 0)
							valueBox.Text = (SliderData.Prefix or "")..method(val, SliderData.Precision)..(SliderData.Suffix or "")
						else
							local posX = math.clamp((val.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
							head.Position = UDim2.new(posX, 0, 0.5, 0)
							finalValue = posX * (SliderData.Maximum - SliderData.Minimum) + SliderData.Minimum
							valueBox.Text = (SliderData.Prefix or "")..method(finalValue, SliderData.Precision)..(SliderData.Suffix or "")
						end
						SliFuncs.Value = finalValue
						if SliderData.Callback then SliderData.Callback(finalValue) end
					end
					SetValue(SliderData.Default)
					head.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = true; SetValue(inp) end end)
					head.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false; if SliderData.onInputComplete then SliderData.onInputComplete(finalValue) end end end)
					UserInputService.InputChanged:Connect(function(inp) if dragging then SetValue(inp) end end)
					valueBox.FocusLost:Connect(function()
						local num = tonumber(valueBox.Text:match("%d+%.?%d*"))
						if num then SetValue(num) else valueBox.Text = tostring(finalValue) end
						if SliderData.onInputComplete then SliderData.onInputComplete(finalValue) end
					end)
					function SliFuncs:UpdateName(name) label.Text = name end
					function SliFuncs:SetVisibility(state) slider.Visible = state end
					function SliFuncs:UpdateValue(val) SetValue(val) end
					function SliFuncs:GetValue() return finalValue end
					if Flag then MacLib.Options[Flag] = SliFuncs end
					return SliFuncs
				end
				function SecFuncs:Input(InputData, Flag)
					local InpFuncs = {Settings = InputData}
					local input = buildComponent("Input", 38)
					local nameLabel = CreateInstance("TextLabel", {
						Name = "InputName", FontFace = Font.new(assets.interFont), Text = InputData.Name,
						TextColor3 = Color3.new(1,1,1), TextSize = 13, TextTransparency = 0.5,
						TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left,
						AnchorPoint = Vector2.new(0,0.5), AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1, Position = UDim2.fromScale(0,0.5)
					}, input)
					local box = CreateInstance("TextBox", {
						Name = "InputBox", FontFace = Font.new(assets.interFont), Text = InputData.Default or "",
						TextColor3 = Color3.new(1,1,1), TextSize = 12, TextTransparency = 0.1, PlaceholderText = InputData.Placeholder or "",
						AnchorPoint = Vector2.new(1,0.5), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.95,
						BorderSizePixel = 0, ClipsDescendants = true, LayoutOrder = 1, Position = UDim2.fromScale(1,0.5), Size = UDim2.fromOffset(21,21), TextXAlignment = Enum.TextXAlignment.Right
					}, input)
					CreateInstance("UICorner", {CornerRadius = UDim.new(0,4)}, box)
					CreateInstance("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1,1,1), Transparency = 0.9}, box)
					CreateInstance("UIPadding", {PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,5)}, box)
					local constraint = CreateInstance("UISizeConstraint", {}, box)
					local filters = {
						All = function(v) return InputData.CharacterLimit and v:sub(1, InputData.CharacterLimit) or v end,
						Numeric = function(v) return v:match("^%-?%d*$") and v or v:gsub("[^%d-]", ""):gsub("(%-)", function(m, p) return p == 1 and m or "" end) end,
						AlphaNumeric = function(v) return v:gsub("[^%w]", "") end
					}
					local filter = type(InputData.AcceptedCharacters) == "function" and InputData.AcceptedCharacters or filters[InputData.AcceptedCharacters] or filters.All
					local function updateSize()
						constraint.MaxSize = Vector2.new((input.AbsoluteSize.X - nameLabel.AbsoluteSize.X - 20) / baseScale.Scale, 9e9)
					end
					updateSize()
					nameLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
					box:GetPropertyChangedSignal("Text"):Connect(function()
						box.Text = filter(box.Text)
						InpFuncs.Text = box.Text
						if InputData.onChanged then InputData.onChanged(box.Text) end
					end)
					box.FocusLost:Connect(function()
						if InputData.Callback then InputData.Callback(box.Text) end
					end)
					function InpFuncs:UpdateName(name) nameLabel.Text = name end
					function InpFuncs:SetVisibility(state) input.Visible = state end
					function InpFuncs:GetText() return box.Text end
					function InpFuncs:UpdatePlaceholder(text) box.PlaceholderText = text end
					function InpFuncs:UpdateText(text) box.Text = filter(text) end
					if Flag then MacLib.Options[Flag] = InpFuncs end
					return InpFuncs
				end
				function SecFuncs:Keybind(KeybindData, Flag)
					local KeyFuncs = {Settings = KeybindData}
					local bind = buildComponent("Keybind", 38)
					local nameLabel = CreateInstance("TextLabel", {
						Name = "KeybindName", FontFace = Font.new(assets.interFont), Text = KeybindData.Name,
						TextColor3 = Color3.new(1,1,1), TextSize = 13, TextTransparency = 0.5,
						TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left,
						AnchorPoint = Vector2.new(0,0.5), AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1, Position = UDim2.fromScale(0,0.5)
					}, bind)
					local box = CreateInstance("TextBox", {
						Name = "BinderBox", CursorPosition = -1, FontFace = Font.new(assets.interFont), PlaceholderText = "...",
						Text = KeybindData.Default and KeybindData.Default.Name or "", TextColor3 = Color3.new(1,1,1), TextSize = 12, TextTransparency = 0.1,
						AnchorPoint = Vector2.new(1,0.5), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.95,
						BorderSizePixel = 0, ClipsDescendants = true, LayoutOrder = 1, Position = UDim2.fromScale(1,0.5), Size = UDim2.fromOffset(21,21)
					}, bind)
					CreateInstance("UICorner", {CornerRadius = UDim.new(0,4)}, box)
					CreateInstance("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1,1,1), Transparency = 0.9}, box)
					CreateInstance("UIPadding", {PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,5)}, box)
					CreateInstance("UISizeConstraint", {}, box)
					local focused, binding, binded, reset = false, false, KeybindData.Default, false
					box.Focused:Connect(function() focused = true end)
					box.FocusLost:Connect(function() focused = false end)
					UserInputService.InputBegan:Connect(function(inp)
						if focused and not binding then
							binding = true
							local event
							event = UserInputService.InputBegan:Connect(function(input)
								if KeybindData.Blacklist and (table.find(KeybindData.Blacklist, input.KeyCode) or table.find(KeybindData.Blacklist, input.UserInputType)) then
									box:ReleaseFocus(); binding = false; event:Disconnect(); return
								end
								binded = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
								box.Text = binded.Name
								if KeybindData.onBinded then KeybindData.onBinded(binded) end
								reset = true; binding = false; event:Disconnect()
							end)
						else
							if not reset and (inp.KeyCode == binded or inp.UserInputType == binded) then
								if KeybindData.Callback then KeybindData.Callback(binded) end
								if KeybindData.onBindHeld then KeybindData.onBindHeld(true, binded) end
							else
								reset = false
							end
						end
					end)
					UserInputService.InputEnded:Connect(function(inp)
						if not focused and not binding and (inp.KeyCode == binded or inp.UserInputType == binded) and KeybindData.onBindHeld then
							KeybindData.onBindHeld(false, binded)
						end
					end)
					function KeyFuncs:Bind(key) binded = key; box.Text = key.Name end
					function KeyFuncs:Unbind() binded = nil; box.Text = "" end
					function KeyFuncs:GetBind() return binded end
					function KeyFuncs:SetVisibility(state) bind.Visible = state end
					if Flag then MacLib.Options[Flag] = KeyFuncs end
					return KeyFuncs
				end
				function SecFuncs:Dropdown(DropData, Flag)
					local DropFuncs = {Settings = DropData, Value = DropData.Multi and {} or nil}
					local selected, optionObjs = {}, {}
					local dropdown = CreateInstance("Frame", {
						Name = "Dropdown", BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.985,
						BorderSizePixel = 0, Size = UDim2.new(1,0,0,38), ClipsDescendants = true, Parent = section
					})
					CreateInstance("UIPadding", {PaddingLeft = UDim.new(0,15), PaddingRight = UDim.new(0,15)}, dropdown)
					local interact = CreateInstance("TextButton", {
						Name = "Interact", BackgroundTransparency = 1, Size = UDim2.new(1,0,0,38), Text = "",
						Events = {MouseButton1Click = function() toggleDropdown() end}
					}, dropdown)
					local nameLabel = CreateInstance("TextLabel", {
						Name = "DropdownName", FontFace = Font.new(assets.interFont), Text = DropData.Name.."...",
						TextColor3 = Color3.new(1,1,1), TextSize = 13, TextTransparency = 0.5,
						TextTruncate = Enum.TextTruncate.SplitWord, TextXAlignment = Enum.TextXAlignment.Left,
						AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1,-20,0,38)
					}, dropdown)
					CreateInstance("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1,1,1), Transparency = 0.95}, dropdown)
					CreateInstance("UICorner", {CornerRadius = UDim.new(0,6)}, dropdown)
					local arrow = CreateInstance("ImageLabel", {
						Name = "DropdownImage", Image = assets.dropdown, ImageTransparency = 0.5,
						AnchorPoint = Vector2.new(1,0), BackgroundTransparency = 1, Position = UDim2.new(1,0,0,12), Size = UDim2.fromOffset(14,14)
					}, dropdown)
					local frame = CreateInstance("Frame", {
						Name = "DropdownFrame", BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), Visible = false, AutomaticSize = Enum.AutomaticSize.Y, Parent = dropdown
					})
					CreateInstance("UIPadding", {PaddingTop = UDim.new(0,38), PaddingBottom = UDim.new(0,10)}, frame)
					CreateInstance("UIListLayout", {Padding = UDim.new(0,5), SortOrder = Enum.SortOrder.LayoutOrder}, frame)
					local search
					if DropData.Search then
						search = CreateInstance("Frame", {
							Name = "Search", BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.95,
							BorderSizePixel = 0, LayoutOrder = -1, Size = UDim2.new(1,0,0,30), Visible = DropData.Search, Parent = frame
						})
						CreateInstance("UICorner", {}, search)
						CreateInstance("ImageLabel", {Name = "SearchIcon", Image = assets.searchIcon, ImageColor3 = Color3.fromRGB(180,180,180), AnchorPoint = Vector2.new(0,0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0,0.5), Size = UDim2.fromOffset(12,12)}, search)
						CreateInstance("UIPadding", {PaddingLeft = UDim.new(0,15)}, search)
						local searchBox = CreateInstance("TextBox", {
							Name = "SearchBox", FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium), PlaceholderText = "Search...",
							Text = "", TextColor3 = Color3.fromRGB(200,200,200), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
							BackgroundTransparency = 1, Size = UDim2.fromScale(1,1)
						}, search)
						CreateInstance("UIPadding", {PaddingLeft = UDim.new(0,23)}, searchBox)
						searchBox:GetPropertyChangedSignal("Text"):Connect(function()
							local term = searchBox.Text:lower()
							for optName, obj in pairs(optionObjs) do
								obj.Visible = string.find(optName:lower(), term) ~= nil
							end
						end)
					end
					local dropped, db = false, false
					local function toggleDropdown()
						if db then return end
						db = true
						dropped = not dropped
						local targetSize = dropped and UDim2.new(1,0,0,38 + frame.AbsoluteSize.Y) or UDim2.new(1,0,0,38)
						QuickTween(dropdown, 0.2, {Size = targetSize}, Enum.EasingStyle.Exponential):Play()
						QuickTween(arrow, 0.2, {Rotation = dropped and -90 or 0}, Enum.EasingStyle.Quad):Play()
						frame.Visible = dropped
						task.wait(0.2)
						db = false
					end
					local function updateSelection()
						if #selected > 0 then
							nameLabel.Text = DropData.Name.." • "..table.concat(selected, ", ")
							DropFuncs.Value = DropData.Multi and selected or selected[1]
						else
							nameLabel.Text = DropData.Name.."..."
							DropFuncs.Value = DropData.Multi and {} or nil
						end
					end
					for i, opt in ipairs(DropData.Options) do
						local option = CreateInstance("TextButton", {
							Name = "Option", BackgroundTransparency = 1, Size = UDim2.new(1,0,0,30), Text = "",
							Parent = frame
						})
						CreateInstance("UIPadding", {PaddingLeft = UDim.new(0,15)}, option)
						local optName = CreateInstance("TextLabel", {
							Name = "OptionName", FontFace = Font.new(assets.interFont), Text = opt,
							TextColor3 = Color3.new(1,1,1), TextSize = 13, TextTransparency = 0.5,
							TextTruncate = Enum.TextTruncate.SplitWord, TextXAlignment = Enum.TextXAlignment.Left,
							AnchorPoint = Vector2.new(0,0.5), AutomaticSize = Enum.AutomaticSize.XY,
							BackgroundTransparency = 1, Position = UDim2.fromScale(0,0.5)
						}, option)
						CreateInstance("UIListLayout", {Padding = UDim.new(0,10), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}, option)
						local check = CreateInstance("TextLabel", {
							Name = "Checkmark", FontFace = Font.new(assets.interFont), Text = "✓",
							TextColor3 = Color3.new(1,1,1), TextSize = 13, TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
							AnchorPoint = Vector2.new(0,0.5), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
							Position = UDim2.fromScale(0,0.5), Size = UDim2.fromOffset(-10,0)
						}, option)
						optionObjs[opt] = option
						option.MouseButton1Click:Connect(function()
							local isSelected = table.find(selected, opt) ~= nil
							if DropData.Multi then
								if isSelected then
									table.remove(selected, table.find(selected, opt))
									check.TextTransparency = 1
									QuickTween(check, 0.2, {Size = UDim2.new(check.Size.X.Scale, -10, check.Size.Y.Scale, check.Size.Y.Offset)}):Play()
									QuickTween(optName, 0.2, {TextTransparency = 0.5}):Play()
								else
									table.insert(selected, opt)
									check.TextTransparency = 0
									QuickTween(check, 0.2, {Size = UDim2.new(check.Size.X.Scale, 12, check.Size.Y.Scale, check.Size.Y.Offset)}):Play()
									QuickTween(optName, 0.2, {TextTransparency = 0.2}):Play()
								end
							else
								for name, obj in pairs(optionObjs) do
									if name ~= opt then
										obj.Checkmark.TextTransparency = 1
										QuickTween(obj.Checkmark, 0.2, {Size = UDim2.new(obj.Checkmark.Size.X.Scale, -10, obj.Checkmark.Size.Y.Scale, obj.Checkmark.Size.Y.Offset)}):Play()
										QuickTween(obj.OptionName, 0.2, {TextTransparency = 0.5}):Play()
									end
								end
								selected = isSelected and {} or {opt}
								check.TextTransparency = isSelected and 1 or 0
								QuickTween(check, 0.2, {Size = UDim2.new(check.Size.X.Scale, isSelected and -10 or 12, check.Size.Y.Scale, check.Size.Y.Offset)}):Play()
								QuickTween(optName, 0.2, {TextTransparency = isSelected and 0.5 or 0.2}):Play()
							end
							updateSelection()
							if DropData.Callback then DropData.Callback(DropFuncs.Value) end
						end)
						if DropData.Default then
							if DropData.Multi then
								if table.find(DropData.Default, opt) then option:MouseButton1Click() end
							elseif DropData.Default == i then
								option:MouseButton1Click()
							end
						end
					end
					updateSelection()
					function DropFuncs:UpdateName(name) DropData.Name = name; updateSelection() end
					function DropFuncs:SetVisibility(state) dropdown.Visible = state end
					function DropFuncs:GetValue() return DropFuncs.Value end
					function DropFuncs:UpdateValue(val)
						for opt, obj in pairs(optionObjs) do
							obj.Checkmark.TextTransparency = 1
							QuickTween(obj.Checkmark, 0.2, {Size = UDim2.new(obj.Checkmark.Size.X.Scale, -10, obj.Checkmark.Size.Y.Scale, obj.Checkmark.Size.Y.Offset)}):Play()
							QuickTween(obj.OptionName, 0.2, {TextTransparency = 0.5}):Play()
						end
						selected = {}
						if DropData.Multi and type(val) == "table" then
							for _, opt in ipairs(val) do if optionObjs[opt] then optionObjs[opt]:MouseButton1Click() end end
						elseif optionObjs[val] then
							optionObjs[val]:MouseButton1Click()
						end
					end
					if Flag then MacLib.Options[Flag] = DropFuncs end
					return DropFuncs
				end
				return SecFuncs
			end
			return TabFuncs
		end
		return SectionFuncs
	end
	function WindowFuncs:UpdateTitle(t) title.Text = t end
	function WindowFuncs:UpdateSubtitle(s) subtitle.Text = s end
	return WindowFuncs
end
return MacLib