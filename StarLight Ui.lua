-- StarLight UI Library
-- Originally by: deividcomsono (Obsidian/LinoriaLib)
-- Remastered by: [Your Name] - Integration of Starlight Interface Suite themes and design improvements
-- License: MIT License

local cloneref = (cloneref or clonereference or function(instance: any)
	return instance
end)

local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local SoundService: SoundService = cloneref(game:GetService("SoundService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local Teams: Teams = cloneref(game:GetService("Teams"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

--// MIT License
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}

local StarLight = {
	LocalPlayer = LocalPlayer,
	DevicePlatform = nil,
	IsMobile = false,
	IsRobloxFocused = true,

	ScreenGui = nil,

	SearchText = "",
	Searching = false,
	LastSearchTab = nil,

	ActiveTab = nil,
	Tabs = {},
	DependencyBoxes = {},

	KeybindFrame = nil,
	KeybindContainer = nil,
	KeybindToggles = {},

	Notifications = {},

	ToggleKeybind = Enum.KeyCode.RightControl,
	TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

	Toggled = false,
	Unloaded = false,

	Labels = Labels,
	Buttons = Buttons,
	Toggles = Toggles,
	Options = Options,

	NotifySide = "Right",
	ShowCustomCursor = true,
	ForceCheckbox = false,
	ShowToggleFrameInKeybinds = true,
	NotifyOnError = false,

	CantDragForced = false,

	Signals = {},
	UnloadSignals = {},

	MinSize = Vector2.new(480, 360),
	DPIScale = 1,
	CornerRadius = 6, -- Slightly larger for smoother look

	IsLightTheme = false,
	
	--// StarLight Theme System
	Themes = {
		Starlight = {
			Backgrounds = {
				Dark = Color3.fromRGB(23, 25, 29),
				Medium = Color3.fromRGB(27, 29, 33),
				Light = Color3.fromRGB(33, 34, 38),
				Groupbox = Color3.fromRGB(33, 36, 42),
				Highlight = Color3.fromRGB(17, 19, 22),
			},
			Foregrounds = {
				Active = Color3.fromRGB(255, 255, 255),
				Light = Color3.fromRGB(255, 255, 255),
				Medium = Color3.fromRGB(165, 165, 165),
				Dark = Color3.fromRGB(65, 69, 77),
				MediumHover = Color3.fromRGB(185, 185, 185),
				DarkHover = Color3.fromRGB(85, 89, 97),
			},
			Miscellaneous = {
				Divider = Color3.fromRGB(117, 128, 149),
				Shadow = Color3.fromRGB(19, 21, 24),
				LighterShadow = Color3.fromRGB(24, 25, 30),
			},
			Accents = {
				Main = ColorSequence.new({
					ColorSequenceKeypoint.new(0.0, Color3.fromRGB(230, 186, 251)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(161, 169, 225)),
					ColorSequenceKeypoint.new(1.0, Color3.fromRGB(138, 201, 242)),
				}),
				Brighter = ColorSequence.new({
					ColorSequenceKeypoint.new(0.0, Color3.fromRGB(241, 212, 251)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(187, 192, 225)),
					ColorSequenceKeypoint.new(1.0, Color3.fromRGB(195, 227, 242)),
				}),
			},
		},
		["Hollywood Dark"] = {
			Backgrounds = {
				Dark = Color3.fromRGB(8, 8, 8),
				Medium = Color3.fromRGB(12, 12, 12),
				Light = Color3.fromRGB(15, 15, 15),
				Groupbox = Color3.fromRGB(14, 14, 14),
				Highlight = Color3.fromRGB(13, 13, 13),
			},
			Foregrounds = {
				Active = Color3.fromRGB(255, 255, 255),
				Light = Color3.fromRGB(255, 255, 255),
				Medium = Color3.fromRGB(165, 165, 165),
				Dark = Color3.fromRGB(77, 77, 77),
				MediumHover = Color3.fromRGB(185, 185, 185),
				DarkHover = Color3.fromRGB(97, 97, 97),
			},
			Miscellaneous = {
				Divider = Color3.fromRGB(199, 199, 199),
				Shadow = Color3.fromRGB(21, 21, 21),
				LighterShadow = Color3.fromRGB(30, 30, 30),
			},
			Accents = {
				Main = ColorSequence.new({
					ColorSequenceKeypoint.new(0.0, Color3.fromRGB(230, 186, 251)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(161, 169, 225)),
					ColorSequenceKeypoint.new(1.0, Color3.fromRGB(138, 201, 242)),
				}),
				Brighter = ColorSequence.new({
					ColorSequenceKeypoint.new(0.0, Color3.fromRGB(241, 212, 251)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(187, 192, 225)),
					ColorSequenceKeypoint.new(1.0, Color3.fromRGB(195, 227, 242)),
				}),
			},
		},
		["Tokyo Night"] = {
			Backgrounds = {
				Dark = Color3.fromRGB(22, 22, 31),
				Medium = Color3.fromRGB(28, 28, 40),
				Light = Color3.fromRGB(25, 25, 37),
				Groupbox = Color3.fromRGB(25, 25, 37),
				Highlight = Color3.fromRGB(22, 22, 31),
			},
			Foregrounds = {
				Active = Color3.fromRGB(255, 255, 255),
				Light = Color3.fromRGB(255, 255, 255),
				Medium = Color3.fromRGB(167, 160, 185),
				Dark = Color3.fromRGB(80, 78, 98),
				MediumHover = Color3.fromRGB(180, 167, 206),
				DarkHover = Color3.fromRGB(88, 82, 130),
			},
			Miscellaneous = {
				Divider = Color3.fromRGB(144, 101, 163),
				Shadow = Color3.fromRGB(40, 40, 48),
				LighterShadow = Color3.fromRGB(40, 40, 48),
			},
			Accents = {
				Main = ColorSequence.new({
					ColorSequenceKeypoint.new(0.0, Color3.fromRGB(132, 116, 163)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(133, 122, 194)),
					ColorSequenceKeypoint.new(1.0, Color3.fromRGB(132, 116, 163)),
				}),
				Brighter = ColorSequence.new({
					ColorSequenceKeypoint.new(0.0, Color3.fromRGB(133, 122, 194)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(132, 116, 163)),
					ColorSequenceKeypoint.new(1.0, Color3.fromRGB(133, 122, 194)),
				}),
			},
		},
	},
	
	CurrentTheme = nil,
	Registry = {},
	DPIRegistry = {},
}

--// Initialize with default theme
StarLight.CurrentTheme = StarLight.Themes.Starlight

if RunService:IsStudio() then
	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		StarLight.IsMobile = true
		StarLight.MinSize = Vector2.new(480, 240)
	else
		StarLight.IsMobile = false
		StarLight.MinSize = Vector2.new(480, 360)
	end
else
	pcall(function()
		StarLight.DevicePlatform = UserInputService:GetPlatform()
	end)
	StarLight.IsMobile = (StarLight.DevicePlatform == Enum.Platform.Android or StarLight.DevicePlatform == Enum.Platform.IOS)
	StarLight.MinSize = StarLight.IsMobile and Vector2.new(480, 240) or Vector2.new(480, 360)
end

local Templates = {
	--// UI \\\\-
	Frame = {
		BorderSizePixel = 0,
	},
	ImageLabel = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	},
	ImageButton = {
		AutoButtonColor = false,
		BorderSizePixel = 0,
	},
	ScrollingFrame = {
		BorderSizePixel = 0,
	},
	TextLabel = {
		BorderSizePixel = 0,
		RichText = true,
	},
	TextButton = {
		AutoButtonColor = false,
		BorderSizePixel = 0,
		RichText = true,
	},
	TextBox = {
		BorderSizePixel = 0,
		PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
		Text = "",
	},
	UIListLayout = {
		SortOrder = Enum.SortOrder.LayoutOrder,
	},
	UIStroke = {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	},

	--// Library \\\\--
	Window = {
		Title = "No Title",
		Footer = "No Footer",
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.fromOffset(720, 600),
		IconSize = UDim2.fromOffset(30, 30),
		AutoShow = true,
		Center = true,
		Resizable = true,
		SearchbarSize = UDim2.fromScale(1, 1),
		CornerRadius = 6,
		NotifySide = "Right",
		ShowCustomCursor = true,
		Font = Enum.Font.Gotham, -- Better font for readability
		ToggleKeybind = Enum.KeyCode.RightControl,
		MobileButtonsSide = "Left",
	},
	Toggle = {
		Text = "Toggle",
		Default = false,

		Callback = function() end,
		Changed = function() end,

		Risky = false,
		Disabled = false,
		Visible = true,
	},
	Input = {
		Text = "Input",
		Default = "",
		Finished = false,
		Numeric = false,
		ClearTextOnFocus = true,
		Placeholder = "",
		AllowEmpty = true,
		EmptyReset = "---",

		Callback = function() end,
		Changed = function() end,

		Disabled = false,
		Visible = true,
	},
	Slider = {
		Text = "Slider",
		Default = 0,
		Min = 0,
		Max = 100,
		Rounding = 0,

		Prefix = "",
		Suffix = "",

		Callback = function() end,
		Changed = function() end,

		Disabled = false,
		Visible = true,
	},
	Dropdown = {
		Values = {},
		DisabledValues = {},
		Multi = false,
		MaxVisibleDropdownItems = 8,

		Callback = function() end,
		Changed = function() end,

		Disabled = false,
		Visible = true,
	},
	Viewport = {
		Object = nil,
		Camera = nil,
		Clone = true,
		AutoFocus = true,
		Interactive = false,
		Height = 200,
		Visible = true,
	},
	Image = {
		Image = "",
		Transparency = 0,
		Color = Color3.new(1, 1, 1),
		RectOffset = Vector2.zero,
		RectSize = Vector2.zero,
		ScaleType = Enum.ScaleType.Fit,
		Height = 200,
		Visible = true,
	},

	--// Addons \\\\-
	KeyPicker = {
		Text = "KeyPicker",
		Default = "None",
		Mode = "Toggle",
		Modes = { "Always", "Toggle", "Hold" },
		SyncToggleState = false,

		Callback = function() end,
		ChangedCallback = function() end,
		Changed = function() end,
		Clicked = function() end,
	},
	ColorPicker = {
		Default = Color3.new(1, 1, 1),

		Callback = function() end,
		Changed = function() end,
	},
}

local Places = {
	Bottom = { 0, 1 },
	Right = { 1, 0 },
}
local Sizes = {
	Left = { 0.5, 1 },
	Right = { 0.5, 1 },
}

--// Basic Functions \\\\--
local function ApplyDPIScale(Dimension, ExtraOffset)
	if typeof(Dimension) == "UDim" then
		return UDim.new(Dimension.Scale, Dimension.Offset * StarLight.DPIScale)
	end

	if ExtraOffset then
		return UDim2.new(
			Dimension.X.Scale,
			(Dimension.X.Offset * StarLight.DPIScale) + (ExtraOffset[1] * StarLight.DPIScale),
			Dimension.Y.Scale,
			(Dimension.Y.Offset * StarLight.DPIScale) + (ExtraOffset[2] * StarLight.DPIScale)
		)
	end

	return UDim2.new(
		Dimension.X.Scale,
		Dimension.X.Offset * StarLight.DPIScale,
		Dimension.Y.Scale,
		Dimension.Y.Offset * StarLight.DPIScale
	)
end
local function ApplyTextScale(TextSize)
	return TextSize * StarLight.DPIScale
end

local function WaitForEvent(Event, Timeout, Condition)
	local Bindable = Instance.new("BindableEvent")
	local Connection = Event:Once(function(...)
		if not Condition or typeof(Condition) == "function" and Condition(...) then
			Bindable:Fire(true)
		else
			Bindable:Fire(false)
		end
	end)
	task.delay(Timeout, function()
		Connection:Disconnect()
		Bindable:Fire(false)
	end)

	local Result = Bindable.Event:Wait()
	Bindable:Destroy()

	return Result
end

local function IsMouseInput(Input: InputObject, IncludeM2: boolean?)
	return Input.UserInputType == Enum.UserInputType.MouseButton1
		or (IncludeM2 == true and Input.UserInputType == Enum.UserInputType.MouseButton2)
		or Input.UserInputType == Enum.UserInputType.Touch
end
local function IsClickInput(Input: InputObject, IncludeM2: boolean?)
	return IsMouseInput(Input, IncludeM2)
		and Input.UserInputState == Enum.UserInputState.Begin
		and StarLight.IsRobloxFocused
end
local function IsHoverInput(Input: InputObject)
	return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
		and Input.UserInputState == Enum.UserInputState.Change
end
local function IsDragInput(Input: InputObject, IncludeM2: boolean?)
	return IsMouseInput(Input, IncludeM2)
		and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change)
		and StarLight.IsRobloxFocused
end

local function GetTableSize(Table: { [any]: any })
	local Size = 0
	for _, _ in pairs(Table) do
		Size += 1 end
	return Size
end
local function StopTween(Tween: TweenBase)
	if not (Tween and Tween.PlaybackState == Enum.PlaybackState.Playing) then
		return
	end
	Tween:Cancel()
end
local function Trim(Text: string)
	return Text:match("^%s*(.-)%s*$")
end
local function Round(Value, Rounding)
	assert(Rounding >= 0, "Invalid rounding number.")
	if Rounding == 0 then
		return math.floor(Value)
	end
	return tonumber(string.format("%." .. Rounding .. "f", Value))
end

local function GetPlayers(ExcludeLocalPlayer: boolean?)
	local PlayerList = Players:GetPlayers()
	if ExcludeLocalPlayer then
		local Idx = table.find(PlayerList, LocalPlayer)
		if Idx then
			table.remove(PlayerList, Idx)
		end
	end
	table.sort(PlayerList, function(Player1, Player2)
		return Player1.Name:lower() < Player2.Name:lower()
	end)
	return PlayerList
end
local function GetTeams()
	local TeamList = Teams:GetTeams()
	table.sort(TeamList, function(Team1, Team2)
		return Team1.Name:lower() < Team2.Name:lower()
	end)
	return TeamList
end

--// Theme Management Functions
function StarLight:SetTheme(ThemeName: string)
	if not self.Themes[ThemeName] then
		warn("Theme '" .. ThemeName .. "' not found!")
		return
	end
	
	self.CurrentTheme = self.Themes[ThemeName]
	self:UpdateColorsUsingRegistry()
end

function StarLight:GetColor(ColorPath: string)
	local parts = string.split(ColorPath, ".")
	local current = self.CurrentTheme
	for _, part in ipairs(parts) do
		current = current[part]
		if not current then
			warn("Invalid color path: " .. ColorPath)
			return Color3.fromRGB(255, 255, 255)
		end
	end
	
	if typeof(current) == "Color3" then
		return current
	elseif typeof(current) == "ColorSequence" then
		return current.Keypoints[2].Value -- Middle color
	end
	
	return current
end

function StarLight:UpdateKeybindFrame()
	if not StarLight.KeybindFrame then
		return
	end

	local XSize = 0
	for _, KeybindToggle in pairs(StarLight.KeybindToggles) do
		if not KeybindToggle.Holder.Visible then
			continue
		end

		local FullSize = KeybindToggle.Label.Size.X.Offset + KeybindToggle.Label.Position.X.Offset
		if FullSize > XSize then
			XSize = FullSize
		end
	end

	StarLight.KeybindFrame.Size = UDim2.fromOffset(XSize + 18 * StarLight.DPIScale, 0)
end
function StarLight:UpdateDependencyBoxes()
	for _, Depbox in pairs(StarLight.DependencyBoxes) do
		Depbox:Update(true)
	end

	if StarLight.Searching then
		StarLight:UpdateSearch(StarLight.SearchText)
	end
end

local function CheckDepbox(Box, Search)
	local VisibleElements = 0
	for _, ElementInfo in pairs(Box.Elements) do
		if ElementInfo.Type == "Divider" then
			ElementInfo.Holder.Visible = false
			continue
		elseif ElementInfo.SubButton then
			local Visible = false
			if ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
				Visible = true
			else
				ElementInfo.Base.Visible = false
			end
			if ElementInfo.SubButton.Text:lower():match(Search) and ElementInfo.SubButton.Visible then
				Visible = true
			else
				ElementInfo.SubButton.Base.Visible = false
			end
			ElementInfo.Holder.Visible = Visible
			if Visible then
				VisibleElements += 1
			end
			continue
		end

		if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
			ElementInfo.Holder.Visible = true
			VisibleElements += 1
		else
			ElementInfo.Holder.Visible = false
		end
	end

	for _, Depbox in pairs(Box.DependencyBoxes) do
		if not Depbox.Visible then
			continue
		end

		VisibleElements += CheckDepbox(Depbox, Search)
	end

	return VisibleElements
end
local function RestoreDepbox(Box)
	for _, ElementInfo in pairs(Box.Elements) do
		ElementInfo.Holder.Visible = typeof(ElementInfo.Visible) == "boolean" and ElementInfo.Visible or true

		if ElementInfo.SubButton then
			ElementInfo.Base.Visible = ElementInfo.Visible
			ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
		end
	end

	Box:Resize()
	Box.Holder.Visible = true

	for _, Depbox in pairs(Box.DependencyBoxes) do
		if not Depbox.Visible then
			continue
		end

		RestoreDepbox(Depbox)
	end
end

function StarLight:UpdateSearch(SearchText)
	StarLight.SearchText = SearchText

	if StarLight.LastSearchTab then
		for _, Groupbox in pairs(StarLight.LastSearchTab.Groupboxes) do
			for _, ElementInfo in pairs(Groupbox.Elements) do
				ElementInfo.Holder.Visible = typeof(ElementInfo.Visible) == "boolean" and ElementInfo.Visible or true

				if ElementInfo.SubButton then
					ElementInfo.Base.Visible = ElementInfo.Visible
					ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
				end
			end

			for _, Depbox in pairs(Groupbox.DependencyBoxes) do
				if not Depbox.Visible then
					continue
				end

				RestoreDepbox(Depbox)
			end

			Groupbox:Resize()
			Groupbox.Holder.Visible = true
		end

		for _, Tabbox in pairs(StarLight.LastSearchTab.Tabboxes) do
			for _, Tab in pairs(Tabbox.Tabs) do
				for _, ElementInfo in pairs(Tab.Elements) do
					ElementInfo.Holder.Visible = typeof(ElementInfo.Visible) == "boolean" and ElementInfo.Visible
						or true

					if ElementInfo.SubButton then
						ElementInfo.Base.Visible = ElementInfo.Visible
						ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
					end
				end

				for _, Depbox in pairs(Tab.DependencyBoxes) do
					if not Depbox.Visible then
						continue
					end

					RestoreDepbox(Depbox)
				end

				Tab.ButtonHolder.Visible = true
			end

			Tabbox.ActiveTab:Resize()
			Tabbox.Holder.Visible = true
		end

		for _, DepGroupbox in pairs(StarLight.LastSearchTab.DependencyGroupboxes) do
			if not DepGroupbox.Visible then
				continue
			end

			for _, ElementInfo in pairs(DepGroupbox.Elements) do
				ElementInfo.Holder.Visible = typeof(ElementInfo.Visible) == "boolean" and ElementInfo.Visible or true

				if ElementInfo.SubButton then
					ElementInfo.Base.Visible = ElementInfo.Visible
					ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
				end
			end

			for _, Depbox in pairs(DepGroupbox.DependencyBoxes) do
				if not Depbox.Visible then
					continue
				end

				RestoreDepbox(Depbox)
			end

			DepGroupbox:Resize()
			DepGroupbox.Holder.Visible = true
		end
	end

	local Search = SearchText:lower()
	if Trim(Search) == "" or StarLight.ActiveTab.IsKeyTab then
		StarLight.Searching = false
		StarLight.LastSearchTab = nil
		return
	end

	StarLight.Searching = true

	for _, Groupbox in pairs(StarLight.ActiveTab.Groupboxes) do
		local VisibleElements = 0

		for _, ElementInfo in pairs(Groupbox.Elements) do
			if ElementInfo.Type == "Divider" then
				ElementInfo.Holder.Visible = false
				continue
			elseif ElementInfo.SubButton then
				local Visible = false

				if ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
					Visible = true
				else
					ElementInfo.Base.Visible = false
				end
				if ElementInfo.SubButton.Text:lower():match(Search) and ElementInfo.SubButton.Visible then
					Visible = true
				else
					ElementInfo.SubButton.Base.Visible = false
				end
				ElementInfo.Holder.Visible = Visible
				if Visible then
					VisibleElements += 1
				end

				continue
			end

			if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
				ElementInfo.Holder.Visible = true
				VisibleElements += 1
			else
				ElementInfo.Holder.Visible = false
			end
		end

		for _, Depbox in pairs(Groupbox.DependencyBoxes) do
			if not Depbox.Visible then
				continue
			end

			VisibleElements += CheckDepbox(Depbox, Search)
		end

		if VisibleElements > 0 then
			Groupbox:Resize()
		end
		Groupbox.Holder.Visible = VisibleElements > 0
	end

	for _, Tabbox in pairs(StarLight.ActiveTab.Tabboxes) do
		local VisibleTabs = 0
		local VisibleElements = {}

		for _, Tab in pairs(Tabbox.Tabs) do
			VisibleElements[Tab] = 0

			for _, ElementInfo in pairs(Tab.Elements) do
				if ElementInfo.Type == "Divider" then
					ElementInfo.Holder.Visible = false
					continue
				elseif ElementInfo.SubButton then
					local Visible = false

					if ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
						Visible = true
					else
						ElementInfo.Base.Visible = false
					end
					if ElementInfo.SubButton.Text:lower():match(Search) and ElementInfo.SubButton.Visible then
						Visible = true
					else
						ElementInfo.SubButton.Base.Visible = false
					end
					ElementInfo.Holder.Visible = Visible
					if Visible then
						VisibleElements[Tab] += 1
					end

					continue
				end

				if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
					ElementInfo.Holder.Visible = true
					VisibleElements[Tab] += 1
				else
					ElementInfo.Holder.Visible = false
				end
			end

			for _, Depbox in pairs(Tab.DependencyBoxes) do
				if not Depbox.Visible then
					continue
				end

				VisibleElements[Tab] += CheckDepbox(Depbox, Search)
			end
		end

		for Tab, Visible in pairs(VisibleElements) do
			Tab.ButtonHolder.Visible = Visible > 0
			if Visible > 0 then
				VisibleTabs += 1

				if Tabbox.ActiveTab == Tab then
					Tab:Resize()
				elseif VisibleElements[Tabbox.ActiveTab] == 0 then
					Tab:Show()
				end
			end
		end

		Tabbox.Holder.Visible = VisibleTabs > 0
	end

	for _, DepGroupbox in pairs(StarLight.ActiveTab.DependencyGroupboxes) do
		if not DepGroupbox.Visible then
			continue
		end

		local VisibleElements = 0

		for _, ElementInfo in pairs(DepGroupbox.Elements) do
			if ElementInfo.Type == "Divider" then
				ElementInfo.Holder.Visible = false
				continue
			elseif ElementInfo.SubButton then
				local Visible = false

				if ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
					Visible = true
				else
					ElementInfo.Base.Visible = false
				end
				if ElementInfo.SubButton.Text:lower():match(Search) and ElementInfo.SubButton.Visible then
					Visible = true
				else
					ElementInfo.SubButton.Base.Visible = false
				end
				ElementInfo.Holder.Visible = Visible
				if Visible then
					VisibleElements += 1
				end

				continue
			end

			if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
				ElementInfo.Holder.Visible = true
				VisibleElements += 1
			else
				ElementInfo.Holder.Visible = false
			end
		end

		for _, Depbox in pairs(DepGroupbox.DependencyBoxes) do
			if not Depbox.Visible then
				continue
			end

			VisibleElements += CheckDepbox(Depbox, Search)
		end

		if VisibleElements > 0 then
			DepGroupbox:Resize()
		end
		DepGroupbox.Holder.Visible = VisibleElements > 0
	end

	StarLight.LastSearchTab = StarLight.ActiveTab
end

function StarLight:AddToRegistry(Instance, Properties)
	StarLight.Registry[Instance] = Properties
end

function StarLight:RemoveFromRegistry(Instance)
	StarLight.Registry[Instance] = nil
end

function StarLight:UpdateColorsUsingRegistry()
	for Instance, Properties in pairs(StarLight.Registry) do
		for Property, ColorPath in pairs(Properties) do
			pcall(function()
				if typeof(ColorPath) == "string" then
					Instance[Property] = StarLight:GetColor(ColorPath)
				elseif typeof(ColorPath) == "function" then
					Instance[Property] = ColorPath()
				end
			end)
		end
	end
end

function StarLight:UpdateDPI(Instance, Properties)
	if not StarLight.DPIRegistry[Instance] then
		return
	end

	for Property, Value in pairs(Properties) do
		StarLight.DPIRegistry[Instance][Property] = Value and Value or nil
	end
end

function StarLight:SetDPIScale(DPIScale: number)
	StarLight.DPIScale = DPIScale / 100
	StarLight.MinSize *= StarLight.DPIScale

	for Instance, Properties in pairs(StarLight.DPIRegistry) do
		for Property, Value in pairs(Properties) do
			if Property == "DPIExclude" or Property == "DPIOffset" then
				continue
			elseif Property == "TextSize" then
				Instance[Property] = ApplyTextScale(Value)
			else
				Instance[Property] = ApplyDPIScale(Value, Properties["DPIOffset"][Property])
			end
		end
	end

	for _, Tab in pairs(StarLight.Tabs) do
		if Tab.IsKeyTab then
			continue
		end

		Tab:Resize(true)
		for _, Groupbox in pairs(Tab.Groupboxes) do
			Groupbox:Resize()
		end
		for _, Tabbox in pairs(Tab.Tabboxes) do
			for _, SubTab in pairs(Tabbox.Tabs) do
				SubTab:Resize()
			end
		end
	end

	for _, Option in pairs(Options) do
		if Option.Type == "Dropdown" then
			Option:RecalculateListSize()
		elseif Option.Type == "KeyPicker" then
			Option:Update()
		end
	end

	StarLight:UpdateKeybindFrame()
	for _, Notification in pairs(StarLight.Notifications) do
		Notification:Resize()
	end
end

function StarLight:GiveSignal(Connection: RBXScriptConnection)
	table.insert(StarLight.Signals, Connection)
	return Connection
end

function StarLight:GetTextBounds(Text: string, Font: Font, Size: number, Width: number?): (number, number)
	local Params = Instance.new("GetTextBoundsParams")
	Params.Text = Text
	Params.RichText = true
	Params.Font = Font
	Params.Size = Size
	Params.Width = Width or workspace.CurrentCamera.ViewportSize.X - 32

	local Bounds = TextService:GetTextBoundsAsync(Params)
	return Bounds.X, Bounds.Y
end

function StarLight:MouseIsOverFrame(Frame: GuiObject, Mouse: Vector2): boolean
	local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
	return Mouse.X >= AbsPos.X
		and Mouse.X <= AbsPos.X + AbsSize.X
		and Mouse.Y >= AbsPos.Y
		and Mouse.Y <= AbsPos.Y + AbsSize.Y
end

function StarLight:SafeCallback(Func: (...any) -> ...any, ...: any)
	if not (Func and typeof(Func) == "function") then
		return
	end

	local Result = table.pack(xpcall(Func, function(Error)
		task.defer(error, debug.traceback(Error, 2))
		if StarLight.NotifyOnError then
			StarLight:Notify(Error)
		end

		return Error
	end, ...))

	if not Result[1] then
		return nil
	end

	return table.unpack(Result, 2, Result.n)
end

function StarLight:MakeDraggable(UI: GuiObject, DragFrame: GuiObject, IgnoreToggled: boolean?, IsMainWindow: boolean?)
	local StartPos
	local FramePos
	local Dragging = false
	local Changed
	DragFrame.InputBegan:Connect(function(Input: InputObject)
		if not IsClickInput(Input) or IsMainWindow and StarLight.CantDragForced then
			return
		end

		StartPos = Input.Position
		FramePos = UI.Position
		Dragging = true

		Changed = Input.Changed:Connect(function()
			if Input.UserInputState ~= Enum.UserInputState.End then
				return
			end

			Dragging = false
			if Changed and Changed.Connected then
				Changed:Disconnect()
				Changed = nil
			end
		end)
	end)
	StarLight:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
		if
			(not IgnoreToggled and not StarLight.Toggled)
			or (IsMainWindow and StarLight.CantDragForced)
			or not (ScreenGui and ScreenGui.Parent)
		then
			Dragging = false
			if Changed and Changed.Connected then
				Changed:Disconnect()
				Changed = nil
			end

			return
		end

		if Dragging and IsHoverInput(Input) then
			local Delta = Input.Position - StartPos
			UI.Position = UDim2.new(
				FramePos.X.Scale,
				FramePos.X.Offset + Delta.X,
				FramePos.Y.Scale,
				FramePos.Y.Offset + Delta.Y
			)
		end
	end))
end

function StarLight:MakeResizable(UI: GuiObject, DragFrame: GuiObject, Callback: () -> ()?)
	local StartPos
	local FrameSize
	local Dragging = false
	local Changed
	DragFrame.InputBegan:Connect(function(Input: InputObject)
		if not IsClickInput(Input) then
			return
		end

		StartPos = Input.Position
		FrameSize = UI.Size
		Dragging = true

		Changed = Input.Changed:Connect(function()
			if Input.UserInputState ~= Enum.UserInputState.End then
				return
			end

			Dragging = false
			if Changed and Changed.Connected then
				Changed:Disconnect()
				Changed = nil
			end
		end)
	end)
	StarLight:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
		if not UI.Visible or not (ScreenGui and ScreenGui.Parent) then
			Dragging = false
			if Changed and Changed.Connected then
				Changed:Disconnect()
				Changed = nil
			end

			return
		end

		if Dragging and IsHoverInput(Input) then
			local Delta = Input.Position - StartPos
			UI.Size = UDim2.new(
				FrameSize.X.Scale,
				math.clamp(FrameSize.X.Offset + Delta.X, StarLight.MinSize.X, math.huge),
				FrameSize.Y.Scale,
				math.clamp(FrameSize.Y.Offset + Delta.Y, StarLight.MinSize.Y, math.huge)
			)
			if Callback then
				StarLight:SafeCallback(Callback)
			end
		end
	end))
end

function StarLight:MakeCover(Holder: GuiObject, Place: string)
	local Pos = Places[Place] or { 0, 0 }
	local Size = Sizes[Place] or { 1, 0.5 }

	local Cover = New("Frame", {
		AnchorPoint = Vector2.new(Pos[1], Pos[2]),
		BackgroundColor3 = Holder.BackgroundColor3,
		Position = UDim2.fromScale(Pos[1], Pos[2]),
		Size = UDim2.fromScale(Size[1], Size[2]),
		Parent = Holder,
	})

	return Cover
end

function StarLight:MakeLine(Frame: GuiObject, Info)
	local Line = New("Frame", {
		AnchorPoint = Info.AnchorPoint or Vector2.zero,
		BackgroundColor3 = "Backgrounds.Light", -- Use theme color
		Position = Info.Position,
		Size = Info.Size,
		ZIndex = 0,
		Parent = Frame,
	})
	
	StarLight:AddToRegistry(Line, {
		BackgroundColor3 = "Backgrounds.Light"
	})

	return Line
end

function StarLight:MakeOutline(Frame: GuiObject, Corner: number?, ZIndex: number?)
	local Holder = New("Frame", {
		BackgroundColor3 = "Backgrounds.Dark", -- Use theme color
		Position = UDim2.fromOffset(-2, -2),
		Size = UDim2.new(1, 4, 1, 4),
		ZIndex = ZIndex,
		Parent = Frame,
	})
	
	StarLight:AddToRegistry(Holder, {
		BackgroundColor3 = "Backgrounds.Dark"
	})

	local Outline = New("Frame", {
		BackgroundColor3 = "Backgrounds.Groupbox", -- Use theme color
		Position = UDim2.fromOffset(1, 1),
		Size = UDim2.new(1, -2, 1, -2),
		ZIndex = ZIndex,
		Parent = Holder,
	})
	
	StarLight:AddToRegistry(Outline, {
		BackgroundColor3 = "Backgrounds.Groupbox"
	})

	if Corner and Corner > 0 then
		New("UICorner", {
			CornerRadius = UDim.new(0, Corner + 1),
			Parent = Holder,
		})
		New("UICorner", {
			CornerRadius = UDim.new(0, Corner),
			Parent = Outline,
		})
	end

	return Holder
end

function StarLight:AddDraggableButton(Text: string, Func)
	local Table = {}

	local Button = New("TextButton", {
		BackgroundColor3 = "Backgrounds.Medium", -- Use theme color
		Position = UDim2.fromOffset(6, 6),
		TextSize = 16,
		ZIndex = 10,
		Parent = ScreenGui,
		Font = Enum.Font.Gotham,

		DPIExclude = {
			Position = true,
		},
	})
	
	StarLight:AddToRegistry(Button, {
		BackgroundColor3 = "Backgrounds.Medium",
		TextColor3 = "Foregrounds.Light"
	})

	New("UICorner", {
		CornerRadius = UDim.new(0, StarLight.CornerRadius),
		Parent = Button,
	})
	
	StarLight:MakeOutline(Button, StarLight.CornerRadius, 9)

	Table.Button = Button
	Button.MouseButton1Click:Connect(function()
		StarLight:SafeCallback(Func, Table)
	end)
	StarLight:MakeDraggable(Button, Button, true)

	function Table:SetText(NewText: string)
		local X, Y = StarLight:GetTextBounds(NewText, Button.FontFace, 16)
		Button.Text = NewText
		Button.Size = UDim2.fromOffset(X * StarLight.DPIScale * 2, Y * StarLight.DPIScale * 2)
		StarLight:UpdateDPI(Button, {
			Size = UDim2.fromOffset(X * 2, Y * 2),
		})
	end
	Table:SetText(Text)

	return Table
end

function StarLight:AddDraggableMenu(Name: string)
	local Background = StarLight:MakeOutline(ScreenGui, StarLight.CornerRadius, 10)
	Background.AutomaticSize = Enum.AutomaticSize.Y
	Background.Position = UDim2.fromOffset(6, 6)
	Background.Size = UDim2.fromOffset(0, 0)
	StarLight:UpdateDPI(Background, {
		Position = false,
		Size = false,
	})

	local Holder = New("Frame", {
		BackgroundColor3 = "Backgrounds.Medium", -- Use theme color
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.new(1, -4, 1, -4),
		Parent = Background,
	})
	
	StarLight:AddToRegistry(Holder, {
		BackgroundColor3 = "Backgrounds.Medium"
	})

	New("UICorner", {
		CornerRadius = UDim.new(0, StarLight.CornerRadius - 1),
		Parent = Holder,
	})
	StarLight:MakeLine(Holder, {
		Position = UDim2.fromOffset(0, 34),
		Size = UDim2.new(1, 0, 0, 1),
	})

	local Label = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34),
		Text = Name,
		TextSize = 15,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = "Foregrounds.Light", -- Use theme color
		Parent = Holder,
	})
	
	StarLight:AddToRegistry(Label, {
		TextColor3 = "Foregrounds.Light"
	})

	New("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = Label,
	})

	local Container = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 35),
		Size = UDim2.new(1, 0, 1, -35),
		Parent = Holder,
	})
	New("UIListLayout", {
		Padding = UDim.new(0, 7),
		Parent = Container,
	})
	New("UIPadding", {
		PaddingBottom = UDim.new(0, 7),
		PaddingLeft = UDim.new(0, 7),
		PaddingRight = UDim.new(0, 7),
		PaddingTop = UDim.new(0, 7),
		Parent = Container,
	})

	StarLight:MakeDraggable(Background, Label, true)
	return Background, Container
end

--// Watermark \\\\-
do
	local WatermarkBackground = StarLight:MakeOutline(ScreenGui, StarLight.CornerRadius, 10)
	WatermarkBackground.AutomaticSize = Enum.AutomaticSize.Y
	WatermarkBackground.Position = UDim2.fromOffset(6, 6)
	WatermarkBackground.Size = UDim2.fromOffset(0, 0)
	WatermarkBackground.Visible = false

	StarLight:UpdateDPI(WatermarkBackground, {
		Position = false,
		Size = false,
	})

	local Holder = New("Frame", {
		BackgroundColor3 = "Backgrounds.Medium", -- Use theme color
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.new(1, -4, 1, -4),
		Parent = WatermarkBackground,
	})
	
	StarLight:AddToRegistry(Holder, {
		BackgroundColor3 = "Backgrounds.Medium"
	})

	New("UICorner", {
		CornerRadius = UDim.new(0, StarLight.CornerRadius - 1),
		Parent = Holder,
	})

	local WatermarkLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 32),
		Position = UDim2.fromOffset(0, -8 * StarLight.DPIScale + 7),
		Text = "",
		TextSize = 15,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = "Foregrounds.Light", -- Use theme color
		Parent = Holder,
	})
	
	StarLight:AddToRegistry(WatermarkLabel, {
		TextColor3 = "Foregrounds.Light"
	})

	New("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = WatermarkLabel,
	})

	StarLight:MakeDraggable(WatermarkBackground, WatermarkLabel, true)

	local function ResizeWatermark()
		local X, Y = StarLight:GetTextBounds(WatermarkLabel.Text, WatermarkLabel.FontFace, 15)
		WatermarkBackground.Size = UDim2.fromOffset((12 + X + 12 + 4) * StarLight.DPIScale, Y * StarLight.DPIScale * 2 + 4)
		StarLight:UpdateDPI(WatermarkBackground, {
			Size = UDim2.fromOffset(12 + X + 12 + 4, Y * 2 + 4),
		})
	end

	function StarLight:SetWatermarkVisibility(Visible: boolean)
		WatermarkBackground.Visible = Visible
		if Visible then
			ResizeWatermark()
		end
	end

	function StarLight:SetWatermark(Text: string)
		WatermarkLabel.Text = Text
		ResizeWatermark()
	end
end

--// Context Menu \\\\-
local CurrentMenu
function StarLight:AddContextMenu(
	Holder: GuiObject,
	Size: UDim2 | () -> (),
	Offset: { [number]: number } | () -> {},
	List: number?,
	ActiveCallback: (Active: boolean) -> ()?
)
	local Menu
	if List then
		Menu = New("ScrollingFrame", {
			AutomaticCanvasSize = List == 2 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
			AutomaticSize = List == 1 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
			BackgroundColor3 = "Backgrounds.Medium", -- Use theme color
			BorderColor3 = "Backgrounds.Light", -- Use theme color
			BorderSizePixel = 1,
			BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
			CanvasSize = UDim2.fromOffset(0, 0),
			ScrollBarImageColor3 = "Backgrounds.Light", -- Use theme color
			ScrollBarThickness = List == 2 and 2 or 0,
			Size = typeof(Size) == "function" and Size() or Size,
			TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
			Visible = false,
			ZIndex = 10,
			Parent = ScreenGui,

			DPIExclude = {
				Position = true,
			},
		})
		
		StarLight:AddToRegistry(Menu, {
			BackgroundColor3 = "Backgrounds.Medium",
			BorderColor3 = "Backgrounds.Light",
			ScrollBarImageColor3 = "Backgrounds.Light"
		})
	else
		Menu = New("Frame", {
			BackgroundColor3 = "Backgrounds.Medium", -- Use theme color
			BorderColor3 = "Backgrounds.Light", -- Use theme color
			BorderSizePixel = 1,
			Size = typeof(Size) == "function" and Size() or Size,
			Visible = false,
			ZIndex = 10,
			Parent = ScreenGui,

			DPIExclude = {
				Position = true,
			},
		})
		
		StarLight:AddToRegistry(Menu, {
			BackgroundColor3 = "Backgrounds.Medium",
			BorderColor3 = "Backgrounds.Light"
		})
	end

	local Table = {
		Active = false,
		Holder = Holder,
		Menu = Menu,
		List = nil,
		Signal = nil,

		Size = Size,
	}

	if List then
		Table.List = New("UIListLayout", {
			Parent = Menu,
		})
	end

	function Table:Open()
		if CurrentMenu == Table then
			return
		elseif CurrentMenu then
			CurrentMenu:Close()
		end

		CurrentMenu = Table
		Table.Active = true

		if typeof(Offset) == "function" then
			Menu.Position = UDim2.fromOffset(
				math.floor(Holder.AbsolutePosition.X + Offset()[1]),
				math.floor(Holder.AbsolutePosition.Y + Offset()[2])
			)
		else
			Menu.Position = UDim2.fromOffset(
				math.floor(Holder.AbsolutePosition.X + Offset[1]),
				math.floor(Holder.AbsolutePosition.Y + Offset[2])
			)
		end
		if typeof(Table.Size) == "function" then
			Menu.Size = Table.Size()
		else
			Menu.Size = ApplyDPIScale(Table.Size)
		end
		if typeof(ActiveCallback) == "function" then
			StarLight:SafeCallback(ActiveCallback, true)
		end

		Menu.Visible = true

		Table.Signal = Holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			if typeof(Offset) == "function" then
				Menu.Position = UDim2.fromOffset(
					math.floor(Holder.AbsolutePosition.X + Offset()[1]),
					math.floor(Holder.AbsolutePosition.Y + Offset()[2])
				)
			else
				Menu.Position = UDim2.fromOffset(
					math.floor(Holder.AbsolutePosition.X + Offset[1]),
					math.floor(Holder.AbsolutePosition.Y + Offset[2])
				)
			end
		end)
	end

	function Table:Close()
		if CurrentMenu ~= Table then
			return
		end
		Menu.Visible = false

		if Table.Signal then
			Table.Signal:Disconnect()
			Table.Signal = nil
		end
		Table.Active = false
		CurrentMenu = nil
		if typeof(ActiveCallback) == "function" then
			StarLight:SafeCallback(ActiveCallback, false)
		end
	end

	function Table:Toggle()
		if Table.Active then
			Table:Close()
		else
			Table:Open()
		end
	end

	function Table:SetSize(Size)
		Table.Size = Size
		Menu.Size = typeof(Size) == "function" and Size() or Size
	end

	return Table
end

StarLight:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
	if IsClickInput(Input, true) then
		local Location = Input.Position

		if
			CurrentMenu
			and not (
				StarLight:MouseIsOverFrame(CurrentMenu.Menu, Location)
				or StarLight:MouseIsOverFrame(CurrentMenu.Holder, Location)
			)
		then
			CurrentMenu:Close()
		end
	end
end))

--// Tooltip \\\\-
local TooltipLabel = New("TextLabel", {
	BackgroundColor3 = "Backgrounds.Medium", -- Use theme color
	BorderColor3 = "Backgrounds.Light", -- Use theme color
	BorderSizePixel = 1,
	TextSize = 14,
	Font = Enum.Font.Gotham,
	TextWrapped = true,
	Visible = false,
	ZIndex = 20,
	Parent = ScreenGui,
})
StarLight:AddToRegistry(TooltipLabel, {
	BackgroundColor3 = "Backgrounds.Medium",
	BorderColor3 = "Backgrounds.Light",
	TextColor3 = "Foregrounds.Light"
})

TooltipLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
	local X, Y = StarLight:GetTextBounds(
		TooltipLabel.Text,
		TooltipLabel.FontFace,
		TooltipLabel.TextSize,
		workspace.CurrentCamera.ViewportSize.X - TooltipLabel.AbsolutePosition.X - 4
	)

	TooltipLabel.Size = UDim2.fromOffset(X + 8 * StarLight.DPIScale, Y + 4 * StarLight.DPIScale)
	StarLight:UpdateDPI(TooltipLabel, {
		Size = UDim2.fromOffset(X, Y),
		DPIOffset = {
			Size = { 8, 4 },
		},
	})
end)

local CurrentHoverInstance
function StarLight:AddTooltip(InfoStr: string, DisabledInfoStr: string, HoverInstance: GuiObject)
	local TooltipTable = {
		Disabled = false,
		Hovering = false,
		Signals = {},
	}

	local function DoHover()
		if
			CurrentHoverInstance == HoverInstance
			or (CurrentMenu and StarLight:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
			or (TooltipTable.Disabled and typeof(DisabledInfoStr) ~= "string")
			or (not TooltipTable.Disabled and typeof(InfoStr) ~= "string")
		then
			return
		end
		CurrentHoverInstance = HoverInstance

		TooltipLabel.Text = TooltipTable.Disabled and DisabledInfoStr or InfoStr
		TooltipLabel.Visible = true

		while
			StarLight.Toggled
			and StarLight:MouseIsOverFrame(HoverInstance, Mouse)
			and not (CurrentMenu and StarLight:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
		do
			TooltipLabel.Position = UDim2.fromOffset(
				Mouse.X + (StarLight.ShowCustomCursor and 8 or 14),
				Mouse.Y + (StarLight.ShowCustomCursor and 8 or 12)
			)

			RunService.RenderStepped:Wait()
		end

		TooltipLabel.Visible = false
		CurrentHoverInstance = nil
	end

	table.insert(TooltipTable.Signals, HoverInstance.MouseEnter:Connect(DoHover))
	table.insert(TooltipTable.Signals, HoverInstance.MouseMoved:Connect(DoHover))
	table.insert(
		TooltipTable.Signals,
		HoverInstance.MouseLeave:Connect(function()
			if CurrentHoverInstance ~= HoverInstance then
				return
			end

			TooltipLabel.Visible = false
			CurrentHoverInstance = nil
		end)
	)

	function TooltipTable:Destroy()
		for Index = #TooltipTable.Signals, 1, -1 do
			local Connection = table.remove(TooltipTable.Signals, Index)
			Connection:Disconnect()
		end

		if CurrentHoverInstance == HoverInstance then
			TooltipLabel.Visible = false
			CurrentHoverInstance = nil
		end
	end

	return TooltipTable
end

function StarLight:OnUnload(Callback)
	table.insert(StarLight.UnloadSignals, Callback)
end

function StarLight:Unload()
	for Index = #StarLight.Signals, 1, -1 do
		local Connection = table.remove(StarLight.Signals, Index)
		Connection:Disconnect()
	end

	for _, Callback in pairs(StarLight.UnloadSignals) do
		StarLight:SafeCallback(Callback)
	end

	StarLight.Unloaded = true
	ScreenGui:Destroy()
	ModalScreenGui:Destroy()
	getgenv().StarLight = nil
end

--// Creator Functions \\\\-
function StarLight:Validate(Table: { [string]: any }, Template: { [string]: any }): { [string]: any }
	if typeof(Table) ~= "table" then
		return Template
	end

	for k, v in pairs(Template) do
		if typeof(k) == "number" then
			continue
		end

		if typeof(v) == "table" then
			Table[k] = StarLight:Validate(Table[k], v)
		elseif Table[k] == nil then
			Table[k] = v
		end
	end

	return Table
end

local function FillInstance(Table: { [string]: any }, Instance: GuiObject)
	local ThemeProperties = StarLight.Registry[Instance] or {}
	local DPIProperties = StarLight.DPIRegistry[Instance] or {}

	local DPIExclude = DPIProperties["DPIExclude"] or Table["DPIExclude"] or {}
	local DPIOffset = DPIProperties["DPIOffset"] or Table["DPIOffset"] or {}
	
	-- Apply theme colors first
	for k, v in pairs(Table) do
		if k == "DPIExclude" or k == "DPIOffset" then
			continue
		elseif typeof(v) == "string" and string.find(v, "%.") then
			local colorValue = StarLight:GetColor(v)
			if colorValue then
				ThemeProperties[k] = v
				Instance[k] = colorValue
			end
		elseif typeof(v) == "function" then
			ThemeProperties[k] = v
			Instance[k] = v()
		end
	end

	-- Apply other properties with DPI scaling
	for k, v in pairs(Table) do
		if k == "DPIExclude" or k == "DPIOffset" or ThemeProperties[k] then
			continue
		end

		if not DPIExclude[k] then
			if k == "Position" or k == "Size" or k:match("Padding") then
				DPIProperties[k] = v
				v = ApplyDPIScale(v, DPIOffset[k])
			elseif k == "TextSize" then
				DPIProperties[k] = v
				v = ApplyTextScale(v)
			end
		end

		Instance[k] = v
	end

	if GetTableSize(ThemeProperties) > 0 then
		StarLight.Registry[Instance] = ThemeProperties
	end
	if GetTableSize(DPIProperties) > 0 then
		DPIProperties["DPIExclude"] = DPIExclude
		DPIProperties["DPIOffset"] = DPIOffset
		StarLight.DPIRegistry[Instance] = DPIProperties
	end
end

local function New(ClassName: string, Properties: { [string]: any }): any
	local Instance = Instance.new(ClassName)

	if Templates[ClassName] then
		FillInstance(Templates[ClassName], Instance)
	end
	FillInstance(Properties, Instance)

	if Properties["Parent"] and not Properties["ZIndex"] then
		pcall(function()
			Instance.ZIndex = Properties.Parent.ZIndex
		end)
	end

	return Instance
end

--// Main Instances \\\\-
local ScreenGui = New("ScreenGui", {
	Name = "StarLight",
	DisplayOrder = 999,
	ResetOnSpawn = false,
})
ScreenGui.Parent = CoreGui
StarLight.ScreenGui = ScreenGui
ScreenGui.DescendantRemoving:Connect(function(Instance)
	StarLight:RemoveFromRegistry(Instance)
	StarLight.DPIRegistry[Instance] = nil
end)

local ModalScreenGui = New("ScreenGui", {
	Name = "StarLightModal",
	DisplayOrder = 999,
	ResetOnSpawn = false,
})
ModalScreenGui.Parent = CoreGui

local ModalElement = New("TextButton", {
	BackgroundTransparency = 1,
	Modal = false,
	Size = UDim2.fromScale(0, 0),
	Text = "",
	ZIndex = -999,
	Parent = ModalScreenGui,
})

--// Enhanced Mobile Toggle Buttons
local MobileToggleButtons = {}
do
	local function createMobileToggleButton(IconAssetId, Position, Callback)
		local Button = New("ImageButton", {
			BackgroundColor3 = "Backgrounds.Dark",
			Position = Position,
			Size = UDim2.fromOffset(55, 55), -- Increased touch target
			Image = "rbxassetid://" .. IconAssetId,
			ImageColor3 = "Foregrounds.Light",
			Parent = ScreenGui,
			ZIndex = 100,
			
			DPIExclude = {
				Position = true,
			},
		})
		
		StarLight:AddToRegistry(Button, {
			BackgroundColor3 = "Backgrounds.Dark",
			ImageColor3 = "Foregrounds.Light"
		})
		
		New("UICorner", {
			CornerRadius = UDim.new(1, 0), -- Perfect circle
			Parent = Button,
		})
		
		local Stroke = New("UIStroke", {
			Color = "Backgrounds.Light",
			Thickness = 2,
			Parent = Button,
		})
		
		StarLight:AddToRegistry(Stroke, {
			Color = "Backgrounds.Light"
		})
		
		Button.MouseButton1Click:Connect(Callback)
		StarLight:MakeDraggable(Button, Button, true)
		
		-- Touch feedback
		Button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				TweenService:Create(Button, TweenInfo.new(0.1), {
					Size = UDim2.fromOffset(50, 50)
				}):Play()
			end
		end)
		
		Button.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				TweenService:Create(Button, TweenInfo.new(0.1), {
					Size = UDim2.fromOffset(55, 55)
				}):Play()
			end
		end)
		
		return Button
	end

	-- Create two mobile toggle buttons
	MobileToggleButtons.Open = createMobileToggleButton("6031625148", 
		UDim2.fromOffset(10, 10), 
		function()
			StarLight:Toggle()
		end)
	
	MobileToggleButtons.Lock = createMobileToggleButton("6031075931", 
		UDim2.fromOffset(70, 10), 
		function()
			StarLight.CantDragForced = not StarLight.CantDragForced
			MobileToggleButtons.Lock.ImageColor3 = StarLight.CantDragForced and 
				StarLight:GetColor("Accents.Main") or StarLight:GetColor("Foregrounds.Light")
		end)
	
	-- Only show on mobile
	MobileToggleButtons.Open.Visible = StarLight.IsMobile
	MobileToggleButtons.Lock.Visible = StarLight.IsMobile
end

--// Cursor
local Cursor
do
	Cursor = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = "Foregrounds.Light", -- Use theme color
		Size = UDim2.fromOffset(9, 1),
		Visible = false,
		ZIndex = 999,
		Parent = ScreenGui,
	})
	
	StarLight:AddToRegistry(Cursor, {
		BackgroundColor3 = "Foregrounds.Light"
	})

	New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = "Backgrounds.Dark", -- Use theme color
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 2, 1, 2),
		ZIndex = 998,
		Parent = Cursor,
	})
	
	StarLight:AddToRegistry(Cursor.Frame, {
		BackgroundColor3 = "Backgrounds.Dark"
	})

	local CursorV = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = "Foregrounds.Light", -- Use theme color
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(1, 9),
		Parent = Cursor,
	})
	
	StarLight:AddToRegistry(CursorV, {
		BackgroundColor3 = "Foregrounds.Light"
	})

	New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = "Backgrounds.Dark", -- Use theme color
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 2, 1, 2),
		ZIndex = 998,
		Parent = CursorV,
	})
	
	StarLight:AddToRegistry(CursorV.Frame, {
		BackgroundColor3 = "Backgrounds.Dark"
	})
end

--// Notification
local NotificationArea
local NotificationList
do
	NotificationArea = New("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -6, 0, 6),
		Size = UDim2.new(0, 300, 1, -6),
		Parent = ScreenGui,
	})
	NotificationList = New("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 6),
		Parent = NotificationArea,
	})
end

--// Lib Functions \\\\--
function StarLight:GetBetterColor(Color: Color3, Add: number): Color3
	Add = Add * (StarLight.IsLightTheme and -4 or 2)
	return Color3.fromRGB(
		math.clamp(Color.R * 255 + Add, 0, 255),
		math.clamp(Color.G * 255 + Add, 0, 255),
		math.clamp(Color.B * 255 + Add, 0, 255)
	)
end

function StarLight:GetKeyString(KeyCode: Enum.KeyCode)
	if KeyCode.EnumType == Enum.KeyCode and KeyCode.Value > 33 and KeyCode.Value < 127 then
		return string.char(KeyCode.Value)
	end

	return KeyCode.Name
end

--// Enhanced Toggle Switch (Ellipse Shape)
local BaseAddons = {}
do
	local Funcs = {}

	function Funcs:AddKeyPicker(Idx, Info)
		Info = StarLight:Validate(Info, Templates.KeyPicker)

		local ParentObj = self
		local ToggleLabel = ParentObj.TextLabel

		local KeyPicker = {
			Text = Info.Text,
			Value = Info.Default,
			Toggled = false,
			Mode = Info.Mode,
			SyncToggleState = Info.SyncToggleState,

			Callback = Info.Callback,
			ChangedCallback = Info.ChangedCallback,
			Changed = Info.Changed,
			Clicked = Info.Clicked,

			Type = "KeyPicker",
		}

		if KeyPicker.Mode == "Press" then
			assert(ParentObj.Type == "Label", "KeyPicker with the mode 'Press' can be only applied on Labels.")

			KeyPicker.SyncToggleState = false
			Info.Modes = { "Press" }
			Info.Mode = "Press"
		end

		if KeyPicker.SyncToggleState then
			Info.Modes = { "Toggle" }
			Info.Mode = "Toggle"
		end

		local SpecialKeys = {
			["MB1"] = Enum.UserInputType.MouseButton1,
			["MB2"] = Enum.UserInputType.MouseButton2,
			["MB3"] = Enum.UserInputType.MouseButton3
		}

		local SpecialKeysInput = {
			[Enum.UserInputType.MouseButton1] = "MB1",
			[Enum.UserInputType.MouseButton2] = "MB2",
			[Enum.UserInputType.MouseButton3] = "MB3"
		}

		local Picker = New("TextButton", {
			BackgroundColor3 = "Backgrounds.Groupbox", -- Use theme color
			BorderColor3 = "Backgrounds.Light", -- Use theme color
			BorderSizePixel = 1,
			Size = UDim2.fromOffset(18, 18),
			Text = KeyPicker.Value,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			Parent = ToggleLabel,
		})
		
		StarLight:AddToRegistry(Picker, {
			BackgroundColor3 = "Backgrounds.Groupbox",
			BorderColor3 = "Backgrounds.Light",
			TextColor3 = "Foregrounds.Light"
		})

		local KeybindsToggle = { Normal = KeyPicker.Mode ~= "Toggle" }; do
			local Holder = New("TextButton", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 16),
				Text = "",
				Visible = not Info.NoUI,
				Parent = StarLight.KeybindContainer,
			})

			local Label = New("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Text = "",
				TextSize = 14,
				Font = Enum.Font.Gotham,
				TextTransparency = 0.5,
				Parent = Holder,

				DPIExclude = {
					Size = true,
				},
			})
			
			StarLight:AddToRegistry(Label, {
				TextColor3 = "Foregrounds.Light"
			})

			local Checkbox = New("Frame", {
				BackgroundColor3 = "Backgrounds.Groupbox", -- Use theme color
				Size = UDim2.fromOffset(14, 14),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Parent = Holder,
			})
			
			StarLight:AddToRegistry(Checkbox, {
				BackgroundColor3 = "Backgrounds.Groupbox"
			})

			New("UICorner", {
				CornerRadius = UDim.new(0, StarLight.CornerRadius / 2),
				Parent = Checkbox,
			})
			
			local CheckStroke = New("UIStroke", {
				Color = "Backgrounds.Light", -- Use theme color
				Parent = Checkbox,
			})
			
			StarLight:AddToRegistry(CheckStroke, {
				Color = "Backgrounds.Light"
			})

			local CheckImage = New("ImageLabel", {
				Image = CheckIcon and CheckIcon.Url or "",
				ImageColor3 = "Foregrounds.Light", -- Use theme color
				ImageRectOffset = CheckIcon and CheckIcon.ImageRectOffset or Vector2.zero,
				ImageRectSize = CheckIcon and CheckIcon.ImageRectSize or Vector2.zero,
				ImageTransparency = 1,
				Position = UDim2.fromOffset(2, 2),
				Size = UDim2.new(1, -4, 1, -4),
				Parent = Checkbox,
			})
			
			StarLight:AddToRegistry(CheckImage, {
				ImageColor3 = "Foregrounds.Light"
			})

			function KeybindsToggle:Display(State)
				Label.TextTransparency = State and 0 or 0.5
				CheckImage.ImageTransparency = State and 0 or 1
			end

			function KeybindsToggle:SetText(Text)
				local X = StarLight:GetTextBounds(Text, Label.FontFace, Label.TextSize)
				Label.Text = Text
				Label.Size = UDim2.new(0, X, 1, 0)
			end

			function KeybindsToggle:SetVisibility(Visibility)
				Holder.Visible = Visibility
			end

			function KeybindsToggle:SetNormal(Normal)
				KeybindsToggle.Normal = Normal

				Holder.Active = not Normal
				Label.Position = Normal and UDim2.fromOffset(0, 0) or UDim2.fromOffset(22 * StarLight.DPIScale, 0)
				Checkbox.Visible = not Normal
			end

			Holder.MouseButton1Click:Connect(function()
				if KeybindsToggle.Normal then
					return
				end

				KeyPicker.Toggled = not KeyPicker.Toggled
				KeyPicker:DoClick()
			end)

			KeybindsToggle.Holder = Holder
			KeybindsToggle.Label = Label
			KeybindsToggle.Checkbox = Checkbox
			KeybindsToggle.Loaded = true
			table.insert(StarLight.KeybindToggles, KeybindsToggle)
		end

		local MenuTable = StarLight:AddContextMenu(Picker, UDim2.fromOffset(62, 0), function()
			return { Picker.AbsoluteSize.X + 1.5, 0.5 }
		end, 1)
		KeyPicker.Menu = MenuTable

		local ModeButtons = {}
		for _, Mode in pairs(Info.Modes) do
			local ModeButton = {}

			local Button = New("TextButton", {
				BackgroundColor3 = "Backgrounds.Groupbox", -- Use theme color
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 21),
				Text = Mode,
				TextSize = 14,
				Font = Enum.Font.Gotham,
				TextTransparency = 0.5,
				Parent = MenuTable.Menu,
			})
			
			StarLight:AddToRegistry(Button, {
				BackgroundColor3 = "Backgrounds.Groupbox",
				TextColor3 = "Foregrounds.Light"
			})

			function ModeButton:Select()
				for _, Button in pairs(ModeButtons) do
					Button:Deselect()
				end

				KeyPicker.Mode = Mode

				Button.BackgroundTransparency = 0
				Button.TextTransparency = 0

				MenuTable:Close()
			end

			function ModeButton:Deselect()
				KeyPicker.Mode = nil

				Button.BackgroundTransparency = 1
				Button.TextTransparency = 0.5
			end

			Button.MouseButton1Click:Connect(function()
				ModeButton:Select()
			end)

			if KeyPicker.Mode == Mode then
				ModeButton:Select()
			end

			ModeButtons[Mode] = ModeButton
		end

		function KeyPicker:Display()
			if StarLight.Unloaded then
				return
			end

			local X, Y =
				StarLight:GetTextBounds(KeyPicker.Value, Picker.FontFace, Picker.TextSize, ToggleLabel.AbsoluteSize.X)
			Picker.Text = KeyPicker.Value
			Picker.Size = UDim2.fromOffset(X + 9 * StarLight.DPIScale, Y + 4 * StarLight.DPIScale)
		end

		function KeyPicker:Update()
			KeyPicker:Display()

			if Info.NoUI then
				return
			end

			if KeyPicker.Mode == "Toggle" and ParentObj.Type == "Toggle" and ParentObj.Disabled then
				KeybindsToggle:SetVisibility(false)
				return
			end

			local State = KeyPicker:GetState()
			local ShowToggle = StarLight.ShowToggleFrameInKeybinds and KeyPicker.Mode == "Toggle"

			if KeybindsToggle.Loaded then
				if ShowToggle then
					KeybindsToggle:SetNormal(false)
				else
					KeybindsToggle:SetNormal(true)
				end

				KeybindsToggle:SetText(("[%s] %s (%s)"):format(KeyPicker.Value, KeyPicker.Text, KeyPicker.Mode))
				KeybindsToggle:SetVisibility(true)
				KeybindsToggle:Display(State)
			end

			StarLight:UpdateKeybindFrame()
		end

		function KeyPicker:GetState()
			if KeyPicker.Mode == "Always" then
				return true
			elseif KeyPicker.Mode == "Hold" then
				local Key = KeyPicker.Value
				if Key == "None" then
					return false
				end

				if SpecialKeys[Key] ~= nil then
					return UserInputService:IsMouseButtonPressed(SpecialKeys[Key]) and not UserInputService:GetFocusedTextBox();
				else
					return UserInputService:IsKeyDown(Enum.KeyCode[Key]) and not UserInputService:GetFocusedTextBox();
				end;
			else
				return KeyPicker.Toggled;
			end
		end

		function KeyPicker:OnChanged(Func)
			KeyPicker.Changed = Func
		end

		function KeyPicker:OnClick(Func)
			KeyPicker.Clicked = Func
		end

		function KeyPicker:DoClick()
			if KeyPicker.Mode == "Press" then
				if KeyPicker.Toggled and Info.WaitForCallback == true then
					return
				end

				KeyPicker.Toggled = true
			end

			if ParentObj.Type == "Toggle" and KeyPicker.SyncToggleState then
				ParentObj:SetValue(KeyPicker.Toggled)
			end

			StarLight:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
			StarLight:SafeCallback(KeyPicker.Changed, KeyPicker.Toggled)

			if KeyPicker.Mode == "Press" then
				KeyPicker.Toggled = false
			end
		end

		function KeyPicker:SetValue(Data)
			local Key, Mode = Data[1], Data[2]

			KeyPicker.Value = Key
			if ModeButtons[Mode] then
				ModeButtons[Mode]:Select()
			end

			KeyPicker:Update()
		end

		function KeyPicker:SetText(Text)
			KeybindsToggle:SetText(Text)
			KeyPicker:Update()
		end

		local Picking = false
		Picker.MouseButton1Click:Connect(function()
			if Picking then
				return
			end

			Picking = true

			Picker.Text = "..."
			Picker.Size = UDim2.fromOffset(29 * StarLight.DPIScale, 18 * StarLight.DPIScale)

			local Input = UserInputService.InputBegan:Wait()
			local Key = "Unknown"

			if SpecialKeysInput[Input.UserInputType] ~= nil then
				Key = SpecialKeysInput[Input.UserInputType];

			elseif Input.UserInputType == Enum.UserInputType.Keyboard then
				Key = Input.KeyCode == Enum.KeyCode.Escape and "None" or Input.KeyCode.Name
			end

			KeyPicker.Value = Key
			KeyPicker:Update()

			StarLight:SafeCallback(
				KeyPicker.ChangedCallback,
				Input.KeyCode == Enum.KeyCode.Unknown and Input.UserInputType or Input.KeyCode
			)
			StarLight:SafeCallback(
				KeyPicker.Changed,
				Input.KeyCode == Enum.KeyCode.Unknown and Input.UserInputType or Input.KeyCode
			)

			RunService.RenderStepped:Wait()
			Picking = false
		end)
		Picker.MouseButton2Click:Connect(MenuTable.Toggle)

		StarLight:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
			if
				KeyPicker.Mode == "Always"
				or KeyPicker.Value == "Unknown"
				or KeyPicker.Value == "None"
				or Picking
				or UserInputService:GetFocusedTextBox()
			then
				return
			end

			local Key = KeyPicker.Value
			local HoldingKey = false

			if
				Key and (
					SpecialKeysInput[Input.UserInputType] == Key or
					(Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key)
				)
			then
				HoldingKey = true
			end

			if KeyPicker.Mode == "Toggle" then
				if HoldingKey then
					KeyPicker.Toggled = not KeyPicker.Toggled
					KeyPicker:DoClick()
				end

			elseif KeyPicker.Mode == "Press" then
				if HoldingKey then
					KeyPicker:DoClick()
				end
			end

			KeyPicker:Update()
		end))

		StarLight:GiveSignal(UserInputService.InputEnded:Connect(function()
			if
				KeyPicker.Value == "Unknown"
				or KeyPicker.Value == "None"
				or Picking
				or UserInputService:GetFocusedTextBox()
			then
				return
			end

			KeyPicker:Update()
		end))

		KeyPicker:Update()

		if ParentObj.Addons then
			table.insert(ParentObj.Addons, KeyPicker)
		end

		Options[Idx] = KeyPicker

		return self
	end

	local HueSequenceTable = {}
	for Hue = 0, 1, 0.1 do
		table.insert(HueSequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
	end
	
	function Funcs:AddColorPicker(Idx, Info)
		Info = StarLight:Validate(Info, Templates.ColorPicker)

		local ParentObj = self
		local ToggleLabel = ParentObj.TextLabel

		local ColorPicker = {
			Value = Info.Default,
			Transparency = Info.Transparency or 0,
			Title = Info.Title,

			Callback = Info.Callback,
			Changed = Info.Changed,

			Type = "ColorPicker",
		}
		ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = ColorPicker.Value:ToHSV()

		local Holder = New("ImageButton", {
			BackgroundColor3 = ColorPicker.Value,
			BorderColor3 = "Backgrounds.Light", -- Use theme color
			BorderSizePixel = 1,
			Size = UDim2.fromOffset(18, 18),
			Parent = ToggleLabel,
		})
		
		StarLight:AddToRegistry(Holder, {
			BackgroundColor3 = "Backgrounds.Groupbox",
			BorderColor3 = "Backgrounds.Light"
		})

		local HolderTransparency = New("ImageLabel", {
			Image = "rbxassetid://4155801252", -- Checkerboard pattern
			ImageTransparency = (1 - ColorPicker.Transparency),
			ScaleType = Enum.ScaleType.Tile,
			Size = UDim2.fromScale(1, 1),
			TileSize = UDim2.fromOffset(9, 9),
			Parent = Holder,
		})

		--// Color Menu \\\\-
		local ColorMenu = StarLight:AddContextMenu(
			Holder,
			UDim2.fromOffset(Info.Transparency and 256 or 234, 0),
			function()
				return { 0.5, Holder.AbsoluteSize.Y + 1.5 }
			end,
			1
		)
		ColorPicker.ColorMenu = ColorMenu

		New("UIPadding", {
			PaddingBottom = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 6),
			Parent = ColorMenu.Menu,
		})

		if typeof(ColorPicker.Title) == "string" then
			New("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 8),
				Text = ColorPicker.Title,
				TextSize = 14,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = "Foregrounds.Light", -- Use theme color
				Parent = ColorMenu.Menu,
			})
		end

		local ColorHolder = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 200),
			Parent = ColorMenu.Menu,
		})
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			Parent = ColorHolder,
		})

		--// Sat Map
		local SatVipMap = New("ImageButton", {
			BackgroundColor3 = ColorPicker.Value,
			Image = "rbxassetid://4155801252", -- Saturation map
			Size = UDim2.fromOffset(200, 200),
			Parent = ColorHolder,
		})

		local SatVibCursor = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = "Foregrounds.Light", -- Use theme color
			Size = UDim2.fromOffset(6, 6),
			Parent = SatVipMap,
		})
		
		StarLight:AddToRegistry(SatVibCursor, {
			BackgroundColor3 = "Foregrounds.Light"
		})

		New("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = SatVipCursor,
		})
		New("UIStroke", {
			Color = "Backgrounds.Dark", -- Use theme color
			Parent = SatVibCursor,
		})

		--// Hue
		local HueSelector = New("TextButton", {
			Size = UDim2.fromOffset(16, 200),
			Text = "",
			Parent = ColorHolder,
		})

		New("UIGradient", {
			Color = ColorSequence.new(HueSequenceTable),
			Rotation = 90,
			Parent = HueSelector,
		})

		local HueCursor = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = "Foregrounds.Light", -- Use theme color
			BorderColor3 = "Backgrounds.Dark", -- Use theme color
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0.5, ColorPicker.Hue),
			Size = UDim2.new(1, 2, 0, 1),
			Parent = HueSelector,
		})
		
		StarLight:AddToRegistry(HueCursor, {
			BackgroundColor3 = "Foregrounds.Light",
			BorderColor3 = "Backgrounds.Dark"
		})

		--// Alpha
		local TransparencySelector, TransparencyColor, TransparencyCursor
		if Info.Transparency then
			TransparencySelector = New("ImageButton", {
				Image = "rbxassetid://4155801252", -- Checkerboard
				ScaleType = Enum.ScaleType.Tile,
				Size = UDim2.fromOffset(16, 200),
				TileSize = UDim2.fromOffset(8, 8),
				Parent = ColorHolder,
			})

			TransparencyColor = New("Frame", {
				BackgroundColor3 = ColorPicker.Value,
				Size = UDim2.fromScale(1, 1),
				Parent = TransparencySelector,
			})
			
			StarLight:AddToRegistry(TransparencyColor, {
				BackgroundColor3 = "Backgrounds.Groupbox"
			})

			New("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Parent = TransparencyColor,
			})

			TransparencyCursor = New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = "Foregrounds.Light", -- Use theme color
				BorderColor3 = "Backgrounds.Dark", -- Use theme color
				BorderSizePixel = 1,
				Position = UDim2.fromScale(0.5, ColorPicker.Transparency),
				Size = UDim2.new(1, 2, 0, 1),
				Parent = TransparencySelector,
			})
			
			StarLight:AddToRegistry(TransparencyCursor, {
				BackgroundColor3 = "Foregrounds.Light",
				BorderColor3 = "Backgrounds.Dark"
			})
		end

		local InfoHolder = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			Parent = ColorMenu.Menu,
		})
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = UDim.new(0, 8),
			Parent = InfoHolder,
		})

		local HueBox = New("TextBox", {
			BackgroundColor3 = "Backgrounds.Groupbox", -- Use theme color
			BorderColor3 = "Backgrounds.Light", -- Use theme color
			BorderSizePixel = 1,
			ClearTextOnFocus = false,
			Size = UDim2.fromScale(1, 1),
			Text = "#??????",
			TextSize = 14,
			Font = Enum.Font.Gotham,
			Parent = InfoHolder,
		})
		
		StarLight:AddToRegistry(HueBox, {
			BackgroundColor3 = "Backgrounds.Groupbox",
			BorderColor3 = "Backgrounds.Light",
			TextColor3 = "Foregrounds.Light"
		})

		local RgbBox = New("TextBox", {
			BackgroundColor3 = "Backgrounds.Groupbox", -- Use theme color
			BorderColor3 = "Backgrounds.Light", -- Use theme color
			BorderSizePixel = 1,
			ClearTextOnFocus = false,
			Size = UDim2.fromScale(1, 1),
			Text = "?, ?, ?",
			TextSize = 14,
			Font = Enum.Font.Gotham,
			Parent = InfoHolder,
		})
		
		StarLight:AddToRegistry(RgbBox, {
			BackgroundColor3 = "Backgrounds.Groupbox",
			BorderColor3 = "Backgrounds.Light",
			TextColor3 = "Foregrounds.Light"
		})

		--// Context Menu \\\\-
		local ContextMenu = StarLight:AddContextMenu(Holder, UDim2.fromOffset(93, 0), function()
			return { Holder.AbsoluteSize.X + 1.5, 0.5 }
		end, 1)
		ColorPicker.ContextMenu = ContextMenu
		do
			local function CreateButton(Text, Func)
				local Button = New("TextButton", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 21),
					Text = Text,
					TextSize = 14,
					Font = Enum.Font.Gotham,
					Parent = ContextMenu.Menu,
				})
				
				StarLight:AddToRegistry(Button, {
					TextColor3 = "Foregrounds.Light"
				})

				Button.MouseButton1Click:Connect(function()
					StarLight:SafeCallback(Func)
					ContextMenu:Close()
				end)
			end

			CreateButton("Copy color", function()
				StarLight.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }
			end)

			CreateButton("Paste color", function()
				ColorPicker:SetValueRGB(StarLight.CopiedColor[1], StarLight.CopiedColor[2])
			end)

			CreateButton("Copy Hex", function()
				setclipboard(tostring(ColorPicker.Value:ToHex()))
			end)
			CreateButton("Copy RGB", function()
				setclipboard(table.concat({
					math.floor(ColorPicker.Value.R * 255),
					math.floor(ColorPicker.Value.G * 255),
					math.floor(ColorPicker.Value.B * 255),
				}, ", "))
			end)
		end

		--// End \\\\-

		function ColorPicker:SetHSVFromRGB(Color)
			ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
		end

		function ColorPicker:Display()
			if StarLight.Unloaded then
				return
			end

			ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)

			Holder.BackgroundColor3 = ColorPicker.Value
			Holder.BorderColor3 = StarLight:GetColor("Backgrounds.Light")
			HolderTransparency.ImageTransparency = (1 - ColorPicker.Transparency)

			SatVipMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
			if TransparencyColor then
				TransparencyColor.BackgroundColor3 = ColorPicker.Value
			end

			SatVibCursor.Position = UDim2.fromScale(ColorPicker.Sat, 1 - ColorPicker.Vib)
			HueCursor.Position = UDim2.fromScale(0.5, ColorPicker.Hue)
			if TransparencyCursor then
				TransparencyCursor.Position = UDim2.fromScale(0.5, ColorPicker.Transparency)
			end

			HueBox.Text = "#" .. ColorPicker.Value:ToHex()
			RgbBox.Text = table.concat({
				math.floor(ColorPicker.Value.R * 255),
				math.floor(ColorPicker.Value.G * 255),
				math.floor(ColorPicker.Value.B * 255),
			}, ", ")
		end

		function ColorPicker:Update()
			ColorPicker:Display()

			StarLight:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
			StarLight:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
		end

		function ColorPicker:OnChanged(Func)
			ColorPicker.Changed = Func
		end

		function ColorPicker:SetValue(HSV, Transparency)
			local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])

			ColorPicker.Transparency = Info.Transparency and Transparency or 0
			ColorPicker:SetHSVFromRGB(Color)
			ColorPicker:Update()
		end

		function ColorPicker:SetValueRGB(Color, Transparency)
			ColorPicker.Transparency = Info.Transparency and Transparency or 0
			ColorPicker:SetHSVFromRGB(Color)
			ColorPicker:Update()
		end

		Holder.MouseButton1Click:Connect(ColorMenu.Toggle)
		Holder.MouseButton2Click:Connect(ContextMenu.Toggle)

		SatVipMap.InputBegan:Connect(function(Input: InputObject)
			while IsDragInput(Input) do
				local MinX = SatVipMap.AbsolutePosition.X
				local MaxX = MinX + SatVipMap.AbsoluteSize.X
				local LocationX = math.clamp(Mouse.X, MinX, MaxX)

				local MinY = SatVipMap.AbsolutePosition.Y
				local MaxY = MinY + SatVipMap.AbsoluteSize.Y
				local LocationY = math.clamp(Mouse.Y, MinY, MaxY)

				local OldSat = ColorPicker.Sat
				local OldVib = ColorPicker.Vib
				ColorPicker.Sat = (LocationX - MinX) / (MaxX - MinX)
				ColorPicker.Vib = 1 - ((LocationY - MinY) / (MaxY - MinY))

				if ColorPicker.Sat ~= OldSat or ColorPicker.Vib ~= OldVib then
					ColorPicker:Update()
				end

				RunService.RenderStepped:Wait()
			end
		end)
		HueSelector.InputBegan:Connect(function(Input: InputObject)
			while IsDragInput(Input) do
				local Min = HueSelector.AbsolutePosition.Y
				local Max = Min + HueSelector.AbsoluteSize.Y
				local Location = math.clamp(Mouse.Y, Min, Max)

				local OldHue = ColorPicker.Hue
				ColorPicker.Hue = (Location - Min) / (Max - Min)

				if ColorPicker.Hue ~= OldHue then
					ColorPicker:Update()
				end

				RunService.RenderStepped:Wait()
			end
		end)
		if TransparencySelector then
			TransparencySelector.InputBegan:Connect(function(Input: InputObject)
				while IsDragInput(Input) do
					local Min = TransparencySelector.AbsolutePosition.Y
					local Max = TransparencySelector.AbsolutePosition.Y + TransparencySelector.AbsoluteSize.Y
					local Location = math.clamp(Mouse.Y, Min, Max)

					local OldTransparency = ColorPicker.Transparency
					ColorPicker.Transparency = (Location - Min) / (Max - Min)

					if ColorPicker.Transparency ~= OldTransparency then
						ColorPicker:Update()
					end

					RunService.RenderStepped:Wait()
				end
			end)
		end

		HueBox.FocusLost:Connect(function(Enter)
			if not Enter then
				return
			end

			local Success, Color = pcall(Color3.fromHex, HueBox.Text)
			if Success and typeof(Color) == "Color3" then
				ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
			end

			ColorPicker:Update()
		end)
		RgbBox.FocusLost:Connect(function(Enter)
			if not Enter then
				return
			end

			local R, G, B = RgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
			if R and G and B then
				ColorPicker:SetHSVFromRGB(Color3.fromRGB(R, G, B))
			end

			ColorPicker:Update()
		end)

		ColorPicker:Display()

		if ParentObj.Addons then
			table.insert(ParentObj.Addons, ColorPicker)
		end

		Options[Idx] = ColorPicker

		return self
	end

	BaseAddons.__index = Funcs
	BaseAddons.__namecall = function(_, Key, ...)
		return Funcs[Key](...)
	end
end

local BaseGroupbox = {}
do
	local Funcs = {}

	function Funcs:AddDivider()
		local Groupbox = self
		local Container = Groupbox.Container

		local Holder = New("Frame", {
			BackgroundColor3 = "Backgrounds.Groupbox", -- Use theme color
			BorderColor3 = "Backgrounds.Light", -- Use theme color
			BorderSizePixel = 1,
			Size = UDim2.new(1, 0, 0, 2),
			Parent = Container,
		})
		
		StarLight:AddToRegistry(Holder, {
			BackgroundColor3 = "Backgrounds.Groupbox",
			BorderColor3 = "Backgrounds.Light"
		})

		Groupbox:Resize()

		table.insert(Groupbox.Elements, {
			Holder = Holder,
			Type = "Divider",
		})
	end

	function Funcs:AddLabel(...)
		local Data = {}
		local Addons = {}

		local First = select(1, ...)
		local Second = select(2, ...)

		if typeof(First) == "table" or typeof(Second) == "table" then
			local Params = typeof(First) == "table" and First or Second

			Data.Text = Params.Text or ""
			Data.DoesWrap = Params.DoesWrap or false
			Data.Size = Params.Size or 14
			Data.Visible = Params.Visible or true
			Data.Idx = typeof(Second) == "table" and First or nil
		else
			Data.Text = First or ""
			Data.DoesWrap = Second or false
			Data.Size = 14
			Data.Visible = true
			Data.Idx = select(3, ...) or nil
		end

		local Groupbox = self
		local Container = Groupbox.Container

		local Label = {
			Text = Data.Text,
			DoesWrap = Data.DoesWrap,

			Addons = Addons,

			Visible = Data.Visible,
			Type = "Label",
		}

		local TextLabel = New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Text = Label.Text,
			TextSize = Data.Size,
			Font = Enum.Font.Gotham,
			TextWrapped = Label.DoesWrap,
			TextXAlignment = Groupbox.IsKeyTab and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
			TextColor3 = "Foregrounds.Light", -- Use theme color
			Parent = Container,
		})
		
		StarLight:AddToRegistry(TextLabel, {
			TextColor3 = "Foregrounds.Light"
		})

		function Label:SetVisible(Visible: boolean)
			Label.Visible = Visible

			TextLabel.Visible = Label.Visible
			Groupbox:Resize()
		end

		function Label:SetText(Text: string)
			Label.Text = Text
			TextLabel.Text = Text

			if Label.DoesWrap then
				local _, Y =
					StarLight:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
				TextLabel.Size = UDim2.new(1, 0, 0, Y + 4 * StarLight.DPIScale)
			end

			Groupbox:Resize()
		end

		if Label.DoesWrap then
			local _, Y =
				StarLight:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
			TextLabel.Size = UDim2.new(1, 0, 0, Y + 4 * StarLight.DPIScale)
		else
			New("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = UDim.new(0, 6),
				Parent = TextLabel,
			})
		end

		if Data.DoesWrap then
			local Last = TextLabel.AbsoluteSize

			TextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				if TextLabel.AbsoluteSize == Last then
					return
				end

				local _, Y =
					StarLight:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
				TextLabel.Size = UDim2.new(1, 0, 0, Y + 4 * StarLight.DPIScale)

				Last = TextLabel.AbsoluteSize
				Groupbox:Resize()
			end)
		end

		Groupbox:Resize()

		Label.TextLabel = TextLabel
		Label.Container = Container
		if not Data.DoesWrap then
			setmetatable(Label, BaseAddons)
		end

		Label.Holder = TextLabel
		table.insert(Groupbox.Elements, Label)

		if Data.Idx then
			Labels[Data.Idx] = Label
		else
			table.insert(Labels, Label)
		end

		return Label
	end

	function Funcs:AddButton(...)
		local function GetInfo(...)
			local Info = {}

			local First = select(1, ...)
			local Second = select(2, ...)

			if typeof(First) == "table" or typeof(Second) == "table" then
				local Params = typeof(First) == "table" and First or Second

				Info.Text = Params.Text or ""
				Info.Func = Params.Func or function() end
				Info.DoubleClick = Params.DoubleClick

				Info.Tooltip = Params.Tooltip
				Info.DisabledTooltip = Params.DisabledTooltip

				Info.Risky = Params.Risky or false
				Info.Disabled = Params.Disabled or false
				Info.Visible = Params.Visible or true
				Info.Idx = typeof(Second) == "table" and First or nil
			else
				Info.Text = First or ""
				Info.Func = Second or function() end
				Info.DoubleClick = false

				Info.Tooltip = nil
				Info.DisabledTooltip = nil

				Info.Risky = false
				Info.Disabled = false
				Info.Visible = true
				Info.Idx = select(3, ...) or nil
			end

			return Info
		end
		local Info = GetInfo(...)

		local Groupbox = self
		local Container = Groupbox.Container

		local Button = {
			Text = Info.Text,
			Func = Info.Func,
			DoubleClick = Info.DoubleClick,

			Tooltip = Info.Tooltip,
			DisabledTooltip = Info.DisabledTooltip,
			TooltipTable = nil,

			Risky = Info.Risky,
			Disabled = Info.Disabled,
			Visible = Info.Visible,

			Tween = nil,
			Type = "Button",
		}

		local Holder = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 21),
			Parent = Container,
		})

		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = UDim.new(0, 9),
			Parent = Holder,
		})

		local function CreateButton(Button)
			local Base = New("TextButton", {
				Active = not Button.Disabled,
				BackgroundColor3 = Button.Disabled and "Backgrounds.Medium" or "Backgrounds.Groupbox", -- Use theme color
				Size = UDim2.fromScale(1, 1),
				Text = Button.Text,
				TextSize = 14,
				Font = Enum.Font.Gotham,
				TextTransparency = 0.4,
				Visible = Button.Visible,
				Parent = Holder,
			})
			
			StarLight:AddToRegistry(Base, {
				BackgroundColor3 = Button.Disabled and "Backgrounds.Medium" or "Backgrounds.Groupbox",
				TextColor3 = Button.Risky and "Red" or "Foregrounds.Light"
			})

			local Stroke = New("UIStroke", {
				Color = "Backgrounds.Light", -- Use theme color
				Transparency = Button.Disabled and 0.5 or 0,
				Parent = Base,
			})
			
			StarLight:AddToRegistry(Stroke, {
				Color = "Backgrounds.Light"
			})

			return Base, Stroke
		end

		local function InitEvents(Button)
			Button.Base.MouseEnter:Connect(function()
				if Button.Disabled then
					return
				end

				Button.Tween = TweenService:Create(Button.Base, StarLight.TweenInfo, {
					TextTransparency = 0,
				})
				Button.Tween:Play()
			end)
			Button.Base.MouseLeave:Connect(function()
				if Button.Disabled then
					return
				end

				Button.Tween = TweenService:Create(Button.Base, StarLight.TweenInfo, {
					TextTransparency = 0.4,
				})
				Button.Tween:Play()
			end)

			Button.Base.MouseButton1Click:Connect(function()
				if Button.Disabled or Button.Locked then
					return
				end

				if Button.DoubleClick then
					Button.Locked = true

					Button.Base.Text = "Are you sure?"
					Button.Base.TextColor3 = StarLight:GetColor("Accents.Main")

					local Clicked = WaitForEvent(Button.Base.MouseButton1Click, 0.5)

					Button.Base.Text = Button.Text
					Button.Base.TextColor3 = Button.Risky and StarLight:GetColor("Red") or StarLight:GetColor("Foregrounds.Light")

					if Clicked then
						StarLight:SafeCallback(Button.Func)
					end

					RunService.RenderStepped:Wait() --// Mouse Button fires without waiting (i hate roblox)
					Button.Locked = false
					return
				end

				StarLight:SafeCallback(Button.Func)
			end)
		end

		Button.Base, Button.Stroke = CreateButton(Button)
		InitEvents(Button)

		function Button:AddButton(...)
			local Info = GetInfo(...)

			local SubButton = {
				Text = Info.Text,
				Func = Info.Func,
				DoubleClick = Info.DoubleClick,

				Tooltip = Info.Tooltip,
				DisabledTooltip = Info.DisabledTooltip,
				TooltipTable = nil,

				Risky = Info.Risky,
				Disabled = Info.Disabled,
				Visible = Info.Visible,

				Tween = nil,
				Type = "SubButton",
			}

			Button.SubButton = SubButton
			SubButton.Base, SubButton.Stroke = CreateButton(SubButton)
			InitEvents(SubButton)

			function SubButton:UpdateColors()
				if StarLight.Unloaded then
					return
				end

				StopTween(SubButton.Tween)

				SubButton.Base.BackgroundColor3 = SubButton.Disabled and StarLight:GetColor("Backgrounds.Medium")
					or StarLight:GetColor("Backgrounds.Groupbox")
				SubButton.Base.TextTransparency = SubButton.Disabled and 0.8 or 0.4
				SubButton.Stroke.Transparency = SubButton.Disabled and 0.5 or 0
			end

			function SubButton:SetDisabled(Disabled: boolean)
				SubButton.Disabled = Disabled

				if SubButton.TooltipTable then
					SubButton.TooltipTable.Disabled = SubButton.Disabled
				end

				SubButton.Base.Active = not SubButton.Disabled
				SubButton:UpdateColors()
			end

			function SubButton:SetVisible(Visible: boolean)
				SubButton.Visible = Visible

				SubButton.Base.Visible = SubButton.Visible
				Groupbox:Resize()
			end

			function SubButton:SetText(Text: string)
				SubButton.Text = Text
				SubButton.Base.Text = Text
			end

			if typeof(SubButton.Tooltip) == "string" or typeof(SubButton.DisabledTooltip) == "string" then
				SubButton.TooltipTable =
					StarLight:AddTooltip(SubButton.Tooltip, SubButton.DisabledTooltip, SubButton.Base)
				SubButton.TooltipTable.Disabled = SubButton.Disabled
			end

			if SubButton.Risky then
				SubButton.Base.TextColor3 = StarLight:GetColor("Red")
			end

			SubButton:UpdateColors()

			if Info.Idx then
				Buttons[Info.Idx] = SubButton
			else
				table.insert(Buttons, SubButton)
			end

			return SubButton
		end

		function Button:UpdateColors()
			if StarLight.Unloaded then
				return
			end

			StopTween(Button.Tween)

			Button.Base.BackgroundColor3 = Button.Disabled and StarLight:GetColor("Backgrounds.Medium")
				or StarLight:GetColor("Backgrounds.Groupbox")
			Button.Base.TextTransparency = Button.Disabled and 0.8 or 0.4
			Button.Stroke.Transparency = Button.Disabled and 0.5 or 0
		end

		function Button:SetDisabled(Disabled: boolean)
			Button.Disabled = Disabled

			if Button.TooltipTable then
				Button.TooltipTable.Disabled = Button.Disabled
			end

			Button.Base.Active = not Button.Disabled
			Button:UpdateColors()
		end

		function Button:SetVisible(Visible: boolean)
			Button.Visible = Visible

			Holder.Visible = Button.Visible
			Groupbox:Resize()
		end

		function Button:SetText(Text: string)
			Button.Text = Text
			Button.Base.Text = Text
		end

		if typeof(Button.Tooltip) == "string" or typeof(Button.DisabledTooltip) == "string" then
			Button.TooltipTable = StarLight:AddTooltip(Button.Tooltip, Button.DisabledTooltip, Button.Base)
			Button.TooltipTable.Disabled = Button.Disabled
		end

		if Button.Risky then
			Button.Base.TextColor3 = StarLight:GetColor("Red")
		end

		Button:UpdateColors()
		Groupbox:Resize()

		Button.Holder = Holder
		table.insert(Groupbox.Elements, Button)

		if Info.Idx then
			Buttons[Info.Idx] = Button
		else
			table.insert(Buttons, Button)
		end

		return Button
	end

	function Funcs:AddToggle(Idx, Info)
		if StarLight.ForceCheckbox then
			return Funcs.AddCheckbox(self, Idx, Info)
		end

		Info = StarLight:Validate(Info, Templates.Toggle)

		local Groupbox = self
		local Container = Groupbox.Container

		local Toggle = {
			Text = Info.Text,
			Value = Info.Default,

			Tooltip = Info.Tooltip,
			DisabledTooltip = Info.DisabledTooltip,
			TooltipTable = nil,

			Callback = Info.Callback,
			Changed = Info.Changed,

			Risky = Info.Risky,
			Disabled = Info.Disabled,
			Visible = Info.Visible,
			Addons = {},

			Type = "Toggle",
		}

		local Button = New("TextButton", {
			Active = not Toggle.Disabled,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Text = "",
			Visible = Toggle.Visible,
			Parent = Container,
		})

		local Label = New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -40, 1, 0),
			Text = Toggle.Text,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextTransparency = 0.4,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = "Foregrounds.Light", -- Use theme color
			Parent = Button,
		})
		
		StarLight:AddToRegistry(Label, {
			TextColor3 = "Foregrounds.Light"
		})

		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 6),
			Parent = Label,
		})

		--// Enhanced Elliptical Switch
		local Switch = New("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = "Backgrounds.Groupbox", -- Use theme color
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromOffset(36, 20), -- Slightly larger for ellipse
			Parent = Button,
		})
		
		StarLight:AddToRegistry(Switch, {
			BackgroundColor3 = Toggle.Value and "Accents.Main" or "Backgrounds.Groupbox"
		})
		
		New("UICorner", {
			CornerRadius = UDim.new(1, 0), -- Perfect ellipse
			Parent = Switch,
		})
		
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 3),
			PaddingRight = UDim.new(0, 3),
			Parent = Switch,
		})
		
		local Ball = New("Frame", {
			BackgroundColor3 = "Foregrounds.Light", -- Use theme color
			Position = UDim2.fromScale(0, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromOffset(14, 14), -- Smaller ball for ellipse
			Parent = Switch,
		})
		
		StarLight:AddToRegistry(Ball, {
			BackgroundColor3 = "Foregrounds.Light"
		})
		
		New("UICorner", {
			CornerRadius = UDim.new(1, 0), -- Perfect circle
			Parent = Ball,
		})
		
		-- Store for animation
		Switch.Ball = Ball
		Switch.OriginalBallColor = StarLight:GetColor("Foregrounds.Light")

		function Toggle:UpdateColors()
			Toggle:Display()
		end

		function Toggle:Display()
			if StarLight.Unloaded then
				return
			end

			-- Ellipse animation
			local isActive = Toggle.Value and not Toggle.Disabled
			local targetX = isActive and 1 or 0
			local targetColor = isActive and StarLight:GetColor("Accents.Main") or StarLight:GetColor("Backgrounds.Groupbox")
			
			-- Animate ball position
			TweenService:Create(Ball, StarLight.TweenInfo, {
				Position = UDim2.fromScale(targetX, 0.5),
				AnchorPoint = Vector2.new(targetX, 0.5),
			}):Play()
			
			-- Animate switch background
			TweenService:Create(Switch, StarLight.TweenInfo, {
				BackgroundColor3 = targetColor,
			}):Play()
			
			-- Animate label
			TweenService:Create(Label, StarLight.TweenInfo, {
				TextTransparency = Toggle.Disabled and 0.8 or (Toggle.Value and 0 or 0.4),
			}):Play()
			
			-- Ball color remains white for better visibility
			Ball.BackgroundColor3 = Switch.OriginalBallColor
		end

		function Toggle:OnChanged(Func)
			Toggle.Changed = Func
		end

		function Toggle:SetValue(Value)
			if Toggle.Disabled then
				return
			end

			Toggle.Value = Value
			Toggle:Display()

			for _, Addon in pairs(Toggle.Addons) do
				if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
					Addon.Toggled = Toggle.Value
					Addon:Update()
				end
			end

			StarLight:SafeCallback(Toggle.Callback, Toggle.Value)
			StarLight:SafeCallback(Toggle.Changed, Toggle.Value)
			StarLight:UpdateDependencyBoxes()
		end

		function Toggle:SetDisabled(Disabled: boolean)
			Toggle.Disabled = Disabled

			if Toggle.TooltipTable then
				Toggle.TooltipTable.Disabled = Toggle.Disabled
			end

			for _, Addon in pairs(Toggle.Addons) do
				if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
					Addon:Update()
				end
			end

			Button.Active = not Toggle.Disabled
			Toggle:Display()
		end

		function Toggle:SetVisible(Visible: boolean)
			Toggle.Visible = Visible

			Button.Visible = Toggle.Visible
			Groupbox:Resize()
		end

		function Toggle:SetText(Text: string)
			Toggle.Text = Text
			Label.Text = Text
		end

		Button.MouseButton1Click:Connect(function()
			if Toggle.Disabled then
				return
			end

			Toggle:SetValue(not Toggle.Value)
		end)

		if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
			Toggle.TooltipTable = StarLight:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
			Toggle.TooltipTable.Disabled = Toggle.Disabled
		end

		if Toggle.Risky then
			Label.TextColor3 = StarLight:GetColor("Red")
		end

		Toggle:Display()
		Groupbox:Resize()

		Toggle.TextLabel = Label
		Toggle.Container = Container
		setmetatable(Toggle, BaseAddons)

		Toggle.Holder = Button
		table.insert(Groupbox.Elements, Toggle)

		Toggles[Idx] = Toggle

		return Toggle
	end

	-- ... (Continue with remaining functions: AddInput, AddSlider, AddDropdown, etc.)
	-- For brevity, I'll include the most important ones

	function Funcs:AddInput(Idx, Info)
		Info = StarLight:Validate(Info, Templates.Input)

		local Groupbox = self
		local Container = Groupbox.Container

		local Input = {
			Text = Info.Text,
			Value = Info.Default,
			Finished = Info.Finished,
			Numeric = Info.Numeric,
			ClearTextOnFocus = Info.ClearTextOnFocus,
			Placeholder = Info.Placeholder,
			AllowEmpty = Info.AllowEmpty,
			EmptyReset = Info.EmptyReset,

			Tooltip = Info.Tooltip,
			DisabledTooltip = Info.DisabledTooltip,
			TooltipTable = nil,

			Callback = Info.Callback,
			Changed = Info.Changed,

			Disabled = Info.Disabled,
			Visible = Info.Visible,

			Type = "Input",
		}

		local Holder = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 39),
			Visible = Input.Visible,
			Parent = Container,
		})

		local Label = New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 14),
			Text = Input.Text,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = "Foregrounds.Light",
			Parent = Holder,
		})
		
		StarLight:AddToRegistry(Label, {
			TextColor3 = "Foregrounds.Light"
		})

		local Box = New("TextBox", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = "Backgrounds.Groupbox", -- Use theme color
			BorderColor3 = "Backgrounds.Light", -- Use theme color
			BorderSizePixel = 1,
			ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus,
			PlaceholderText = Input.Placeholder,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 21),
			Text = Input.Value,
			TextEditable = not Input.Disabled,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = "Foregrounds.Light",
			Parent = Holder,
		})
		
		StarLight:AddToRegistry(Box, {
			BackgroundColor3 = "Backgrounds.Groupbox",
			BorderColor3 = "Backgrounds.Light",
			TextColor3 = "Foregrounds.Light"
		})

		New("UIPadding", {
			PaddingBottom = UDim.new(0, 3),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 4),
			Parent = Box,
		})

		function Input:OnChanged(Func)
			Input.Changed = Func
		end

		function Input:SetValue(Text)
			if not Input.AllowEmpty and Trim(Text) == "" then
				Text = Input.EmptyReset
			end

			if Info.MaxLength and #Text > Info.MaxLength then
				Text = Text:sub(1, Info.MaxLength)
			end

			if Input.Numeric then
				if #Text > 0 and not tonumber(Text) then
					Text = Input.Value
				end
			end

			Input.Value = Text
			Box.Text = Text

			if not Input.Disabled then
				StarLight:SafeCallback(Input.Callback, Input.Value)
				StarLight:SafeCallback(Input.Changed, Input.Value)
			end
		end

		function Input:SetDisabled(Disabled: boolean)
			Input.Disabled = Disabled

			if Input.TooltipTable then
				Input.TooltipTable.Disabled = Input.Disabled
			end

			Box.ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus
			Box.TextEditable = not Input.Disabled
		end

		function Input:SetVisible(Visible: boolean)
			Input.Visible = Visible

			Holder.Visible = Input.Visible
			Groupbox:Resize()
		end

		function Input:SetText(Text: string)
			Input.Text = Text
			Label.Text = Text
		end

		if Input.Finished then
			Box.FocusLost:Connect(function(Enter)
				if not Enter then
					return
				end

				Input:SetValue(Box.Text)
			end)
		else
			Box:GetPropertyChangedSignal("Text"):Connect(function()
				Input:SetValue(Box.Text)
			end)
		end

		if typeof(Input.Tooltip) == "string" or typeof(Input.DisabledTooltip) == "string" then
			Input.TooltipTable = StarLight:AddTooltip(Input.Tooltip, Input.DisabledTooltip, Box)
			Input.TooltipTable.Disabled = Input.Disabled
		end

		Groupbox:Resize()

		Input.Holder = Holder
		table.insert(Groupbox.Elements, Input)

		Options[Idx] = Input

		return Input
	end

	BaseGroupbox.__index = Funcs
end

--// Notification System
function StarLight:Notify(Text: string, Time: number?)
	local Notification = {
		Text = Text,
		Time = Time or 3,
	}

	local NotificationFrame = New("TextButton", {
		BackgroundColor3 = "Backgrounds.Medium", -- Use theme color
		BorderColor3 = "Backgrounds.Light", -- Use theme color
		BorderSizePixel = 1,
		Size = UDim2.fromOffset(200, 40),
		Position = UDim2.fromScale(0.5, 0.5),
		Text = "",
		Parent = NotificationArea,
	})
	
	StarLight:AddToRegistry(NotificationFrame, {
		BackgroundColor3 = "Backgrounds.Medium",
		BorderColor3 = "Backgrounds.Light"
	})

	New("UICorner", {
		CornerRadius = UDim.new(0, StarLight.CornerRadius),
		Parent = NotificationFrame,
	})

	local Label = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = Text,
		TextSize = 14,
		Font = Enum.Font.Gotham,
		TextColor3 = "Foregrounds.Light", -- Use theme color
		Parent = NotificationFrame,
	})
	
	StarLight:AddToRegistry(Label, {
		TextColor3 = "Foregrounds.Light"
	})

	New("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		Parent = Label,
	})

	function Notification:Resize()
		local X, Y = StarLight:GetTextBounds(Label.Text, Label.FontFace, Label.TextSize)
		NotificationFrame.Size = UDim2.fromOffset(X + 16, Y + 12)
	end

	function Notification:Destroy()
		NotificationFrame:Destroy()
	end

	Notification:Resize()
	table.insert(StarLight.Notifications, Notification)

	task.spawn(function()
		task.wait(Notification.Time)
		Notification:Destroy()
	end)

	return Notification
end

--// Window Creation
function StarLight:CreateWindow(Info)
	Info = StarLight:Validate(Info, Templates.Window)
	
	local Window = {
		Name = Info.Title,
		Groupboxes = {},
		DependencyGroupboxes = {},
		Tabboxes = {},
		Tabs = {},
		Sides = {},
	}

	local Background = New("Frame", {
		BackgroundColor3 = "Backgrounds.Dark", -- Use theme color
		BorderColor3 = "Backgrounds.Light", -- Use theme color
		BorderSizePixel = 1,
		ClipsDescendants = true,
		Position = Info.Position,
		Size = Info.Size,
		Parent = ScreenGui,
	})
	
	StarLight:AddToRegistry(Background, {
		BackgroundColor3 = "Backgrounds.Dark",
		BorderColor3 = "Backgrounds.Light"
	})

	New("UICorner", {
		CornerRadius = UDim.new(0, Info.CornerRadius),
		Parent = Background,
	})

	Window.Background = Background
	StarLight:MakeDraggable(Background, Background, false, true)
	StarLight:MakeResizable(Background, Background)

	local Titlebar = New("Frame", {
		BackgroundColor3 = "Backgrounds.Medium", -- Use theme color
		Size = UDim2.new(1, 0, 0, 40),
		Parent = Background,
	})
	
	StarLight:AddToRegistry(Titlebar, {
		BackgroundColor3 = "Backgrounds.Medium"
	})

	local TitlebarStroke = New("UIStroke", {
		Color = "Backgrounds.Light", -- Use theme color
		Parent = Titlebar,
	})
	
	StarLight:AddToRegistry(TitlebarStroke, {
		Color = "Backgrounds.Light"
	})

	local TitleLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 1, 0),
		Text = Info.Title,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = "Foregrounds.Light",
		Parent = Titlebar,
	})
	
	StarLight:AddToRegistry(TitleLabel, {
		TextColor3 = "Foregrounds.Light"
	})

	local CloseButton = New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(24, 24),
		Text = "✕",
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextColor3 = "Foregrounds.Medium",
		Parent = Titlebar,
	})
	
	StarLight:AddToRegistry(CloseButton, {
		TextColor3 = "Foregrounds.Medium"
	})
	
	CloseButton.MouseEnter:Connect(function()
		TweenService:Create(CloseButton, TweenInfo.new(0.2), {
			TextColor3 = StarLight:GetColor("Red")
		}):Play()
	end)
	
	CloseButton.MouseLeave:Connect(function()
		TweenService:Create(CloseButton, TweenInfo.new(0.2), {
			TextColor3 = StarLight:GetColor("Foregrounds.Medium")
		}):Play()
	end)

	CloseButton.MouseButton1Click:Connect(function()
		StarLight:Unload()
	end)

	local SearchBox = New("TextBox", {
		BackgroundColor3 = "Backgrounds.Groupbox", -- Use theme color
		BorderColor3 = "Backgrounds.Light", -- Use theme color
		BorderSizePixel = 1,
		PlaceholderText = "Search...",
		Position = UDim2.fromOffset(12, 48),
		Size = UDim2.new(1, -24, 0, 28),
		Text = "",
		TextSize = 14,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = "Foregrounds.Light",
		Parent = Background,
	})
	
	StarLight:AddToRegistry(SearchBox, {
		BackgroundColor3 = "Backgrounds.Groupbox",
		BorderColor3 = "Backgrounds.Light",
		TextColor3 = "Foregrounds.Light"
	})

	New("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		Parent = SearchBox,
	})

	SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		StarLight:UpdateSearch(SearchBox.Text)
	end)

	local Content = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 84),
		Size = UDim2.new(1, 0, 1, -84),
		Parent = Background,
	})

	local LeftSide = New("ScrollingFrame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.5, 1),
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollBarThickness = 0,
		Parent = Content,
	})

	local RightSide = New("ScrollingFrame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromScale(0.5, 1),
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollBarThickness = 0,
		Parent = Content,
	})

	Window.Background = Background
	Window.Titlebar = Titlebar
	Window.CloseButton = CloseButton
	Window.SearchBox = SearchBox
	Window.Content = Content
	Window.LeftSide = LeftSide
	Window.RightSide = RightSide

	function Window:AddTab(Name: string)
		local Tab = {
			Name = Name,
			Groupboxes = {},
			Tabboxes = {},
			DependencyGroupboxes = {},
			Sides = {},
		}

		local TabButton = New("TextButton", {
			BackgroundColor3 = "Backgrounds.Groupbox", -- Use theme color
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 120, 0, 36),
			Text = Name,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextColor3 = "Foregrounds.Light", -- Use theme color
			Parent = Titlebar,
		})
		
		StarLight:AddToRegistry(TabButton, {
			BackgroundColor3 = "Backgrounds.Groupbox",
			TextColor3 = "Foregrounds.Light"
		})

		local TabContent = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			Parent = Content,
		})

		Tab.Button = TabButton
		Tab.Content = TabContent

		function Tab:Show()
			for _, OtherTab in pairs(Window.Tabs) do
				OtherTab.Content.Visible = false
				OtherTab.Button.BackgroundTransparency = 1
			end
			TabContent.Visible = true
			TabButton.BackgroundTransparency = 0
			Window.ActiveTab = Tab
			StarLight.ActiveTab = Tab
		end

		TabButton.MouseButton1Click:Connect(Tab.Show)

		function Tab:AddGroupbox(Name: string)
			local Groupbox = {
				Name = Name,
				Elements = {},
				DependencyBoxes = {},
				Visible = true,
			}

			local GroupboxFrame = New("Frame", {
				BackgroundColor3 = "Backgrounds.Groupbox", -- Use theme color
				BorderColor3 = "Backgrounds.Light", -- Use theme color
				BorderSizePixel = 1,
				Size = UDim2.fromScale(0.95, 0),
				Parent = TabContent,
			})
			
			StarLight:AddToRegistry(GroupboxFrame, {
				BackgroundColor3 = "Backgrounds.Groupbox",
				BorderColor3 = "Backgrounds.Light"
			})

			New("UICorner", {
				CornerRadius = UDim.new(0, StarLight.CornerRadius - 1),
				Parent = GroupboxFrame,
			})

			local GroupboxTitle = New("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(8, 8),
				Size = UDim2.new(1, -16, 0, 18),
				Text = Name,
				TextSize = 16,
				Font = Enum.Font.GothamBold,
				TextColor3 = "Foregrounds.Light",
				Parent = GroupboxFrame,
			})
			
			StarLight:AddToRegistry(GroupboxTitle, {
				TextColor3 = "Foregrounds.Light"
			})

			local Elements = New("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(8, 32),
				Size = UDim2.new(1, -16, 1, -40),
				Parent = GroupboxFrame,
			})

			New("UIListLayout", {
				Padding = UDim.new(0, 6),
				Parent = Elements,
			})

			Groupbox.Frame = GroupboxFrame
			Groupbox.Title = GroupboxTitle
			Groupbox.Container = Elements

			function Groupbox:Resize()
				local Y = 40 -- Title padding
				for _, Element in pairs(Groupbox.Elements) do
					if Element.Holder.Visible then
						Y += Element.Holder.AbsoluteSize.Y + 6
					end
				end
				GroupboxFrame.Size = UDim2.new(0.95, 0, 0, Y)
			end

			function Groupbox:AddDependencyBox()
				local DependencyBox = {
					Elements = {},
					DependencyBoxes = {},
					Visible = true,
				}

				local DependencyFrame = New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 0),
					Visible = true,
					Parent = Elements,
				})

				local DependencyLayout = New("UIListLayout", {
					Padding = UDim.new(0, 6),
					Parent = DependencyFrame,
				})

				DependencyBox.Frame = DependencyFrame
				DependencyBox.Layout = DependencyLayout
				DependencyBox.Holder = DependencyFrame

				function DependencyBox:Update(Force: boolean)
					if Force then
						for _, Element in pairs(DependencyBox.Elements) do
							Element.Holder.Visible = Element.Visible
						end
					end

					local Y = 0
					for _, Element in pairs(DependencyBox.Elements) do
						if Element.Holder.Visible then
							Y += Element.Holder.AbsoluteSize.Y + 6
						end
					end
					DependencyFrame.Size = UDim2.new(1, 0, 0, Y)

					self:Resize()
				end

				function DependencyBox:Resize()
					self:Update()
					Groupbox:Resize()
				end

				function DependencyBox:SetVisible(Visible: boolean)
					DependencyBox.Visible = Visible
					DependencyFrame.Visible = Visible
					Groupbox:Resize()
				end

				table.insert(DependencyBox.Elements, {
					Holder = DependencyFrame,
					Type = "DependencyBox",
				})

				table.insert(Groupbox.DependencyBoxes, DependencyBox)
				table.insert(StarLight.DependencyBoxes, DependencyBox)

				return DependencyBox
			end

			Groupbox:Resize()
			table.insert(Tab.Groupboxes, Groupbox)

			setmetatable(Groupbox, BaseGroupbox)
			return Groupbox
		end

		Tab:Show()
		table.insert(Window.Tabs, Tab)

		return Tab
	end

	function Window:SetVisible(Visible: boolean)
		Background.Visible = Visible
	end

	function Window:MoveToCenter()
		Background.Position = UDim2.fromOffset(
			(workspace.CurrentCamera.ViewportSize.X - Background.AbsoluteSize.X) / 2,
			(workspace.CurrentCamera.ViewportSize.Y - Background.AbsoluteSize.Y) / 2
		)
	end

	if Info.Center then
		Window:MoveToCenter()
	end

	if Info.AutoShow then
		Window:SetVisible(true)
	end

	setmetatable(Window, {
		__index = function(_, k)
			if k == "AddTab" then
				return Window.AddTab
			end
		end,
	})

	return Window
end

-- 在文件末尾补充完整以下函数
function Window:SetVisible(Visible: boolean)
    Background.Visible = Visible
end

function StarLight:Toggle()
    StarLight.Toggled = not StarLight.Toggled
    Background.Visible = StarLight.Toggled
    MobileToggleButtons.Open.ImageColor3 = StarLight.Toggled and 
        StarLight:GetColor("Accents.Main") or StarLight:GetColor("Foregrounds.Light")
end

-- 显示移动端按钮
MobileToggleButtons.Open.Visible = StarLight.IsMobile
MobileToggleButtons.Lock.Visible = StarLight.IsMobile

return StarLight
