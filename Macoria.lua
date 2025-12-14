local MacoriaLib = {
    Options = {},
    Folder = "MacoriaLib",
    GetService = function(service)
        return cloneref and cloneref(game:GetService(service)) or game:GetService(service)
    end
}

local TweenService = MacoriaLib:GetService("TweenService")
local RunService = MacoriaLib:GetService("RunService")
local HttpService = MacoriaLib:GetService("HttpService")
local ContentProvider = MacoriaLib:GetService("ContentProvider")
local UserInputService = MacoriaLib:GetService("UserInputService")
local Lighting = MacoriaLib:GetService("Lighting")
local Players = MacoriaLib:GetService("Players")
local TextService = MacoriaLib:GetService("TextService")
local CoreGui = MacoriaLib:GetService("CoreGui")

local isStudio = RunService:IsStudio()
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

MacoriaLib.DevicePlatform = nil
MacoriaLib.IsMobile = false
MacoriaLib.IsRobloxFocused = true
MacoriaLib.LastSearchTab = nil
MacoriaLib.SearchText = ""
MacoriaLib.Searching = false
MacoriaLib.ActiveTab = nil
MacoriaLib.Tabs = {}
MacoriaLib.DependencyBoxes = {}
MacoriaLib.KeybindToggles = {}
MacoriaLib.Notifications = {}
MacoriaLib.Registry = {}
MacoriaLib.DPIRegistry = {}
MacoriaLib.UnloadSignals = {}
MacoriaLib.Signals = {}

MacoriaLib.Toggled = false
MacoriaLib.Unloaded = false
MacoriaLib.DPIScale = 1
MacoriaLib.CornerRadius = 10
MacoriaLib.MinSize = Vector2.new(480, 360)
MacoriaLib.NotifySide = "Right"
MacoriaLib.ShowCustomCursor = false
MacoriaLib.ForceCheckbox = false
MacoriaLib.ShowToggleFrameInKeybinds = true
MacoriaLib.NotifyOnError = false
MacoriaLib.CantDragForced = false
MacoriaLib.ToggleKeybind = Enum.KeyCode.RightControl

MacoriaLib.TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
MacoriaLib.NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

MacoriaLib.Scheme = {
    BackgroundColor = Color3.fromRGB(15, 15, 15),
    MainColor = Color3.fromRGB(25, 25, 25),
    AccentColor = Color3.fromRGB(125, 85, 255),
    OutlineColor = Color3.fromRGB(40, 40, 40),
    FontColor = Color3.new(1, 1, 1),
    Font = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
    Red = Color3.fromRGB(255, 50, 50),
    Dark = Color3.new(0, 0, 0),
    White = Color3.new(1, 1, 1),
    IsLightTheme = false
}

local assets = {
    interFont = "rbxassetid://12187365364",
    userInfoBlurred = "rbxassetid://18824089198",
    toggleBackground = "rbxassetid://18772190202",
    togglerHead = "rbxassetid://18772309008",
    buttonImage = "rbxassetid://10709791437",
    searchIcon = "rbxassetid://86737463322606",
    colorWheel = "rbxassetid://2849458409",
    colorTarget = "rbxassetid://73265255323268",
    grid = "rbxassetid://121484455191370",
    globe = "rbxassetid://108952102602834",
    transform = "rbxassetid://90336395745819",
    dropdown = "rbxassetid://18865373378",
    sliderbar = "rbxassetid://18772615246",
    sliderhead = "rbxassetid://18772834246",
}

pcall(function()
    MacoriaLib.DevicePlatform = UserInputService:GetPlatform()
end)
MacoriaLib.IsMobile = (MacoriaLib.DevicePlatform == Enum.Platform.Android or MacoriaLib.DevicePlatform == Enum.Platform.IOS)
MacoriaLib.MinSize = MacoriaLib.IsMobile and Vector2.new(480, 240) or Vector2.new(480, 360)

local function isPointInFrame(frame, point)
    local absPos = frame.AbsolutePosition
    local absSize = frame.AbsoluteSize
    return point.X >= absPos.X and point.X <= absPos.X + absSize.X and point.Y >= absPos.Y and point.Y <= absPos.Y + absSize.Y
end

local function GetGui()
    local newGui = Instance.new("ScreenGui")
    newGui.ScreenInsets = Enum.ScreenInsets.None
    newGui.ResetOnSpawn = false
    newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    newGui.DisplayOrder = 2147483647
    local parent = RunService:IsStudio() and LocalPlayer:FindFirstChild("PlayerGui") or (gethui and gethui()) or (cloneref and cloneref(CoreGui) or CoreGui)
    newGui.Parent = parent
    return newGui
end

local function Tween(instance, tweeninfo, propertytable)
    return TweenService:Create(instance, tweeninfo, propertytable)
end

local function ApplyDPIScale(Dimension)
    if typeof(Dimension) == "UDim" then
        return UDim.new(Dimension.Scale, Dimension.Offset * MacoriaLib.DPIScale)
    end
    return UDim2.new(Dimension.X.Scale, Dimension.X.Offset * MacoriaLib.DPIScale, Dimension.Y.Scale, Dimension.Y.Offset * MacoriaLib.DPIScale)
end

local function ApplyTextScale(TextSize)
    return TextSize * MacoriaLib.DPIScale
end

local function GetTextBounds(Text, Font, Size, Width)
    local Params = Instance.new("GetTextBoundsParams")
    Params.Text = Text
    Params.RichText = true
    Params.Font = Font
    Params.Size = Size
    Params.Width = Width or workspace.CurrentCamera.ViewportSize.X - 32
    local Bounds = TextService:GetTextBoundsAsync(Params)
    return Bounds.X, Bounds.Y
end

local function MouseIsOverFrame(Frame, MousePos)
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    return MousePos.X >= AbsPos.X and MousePos.X <= AbsPos.X + AbsSize.X and MousePos.Y >= AbsPos.Y and MousePos.Y <= AbsPos.Y + AbsSize.Y
end

local function IsClickInput(Input)
    return (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and Input.UserInputState == Enum.UserInputState.Begin and MacoriaLib.IsRobloxFocused
end

local function IsHoverInput(Input)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and Input.UserInputState == Enum.UserInputState.Change
end

local function IsDragInput(Input)
    return (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change) and MacoriaLib.IsRobloxFocused
end

local function GetTableSize(Table)
    local Size = 0
    for _, _ in pairs(Table) do Size += 1 end
    return Size
end

local function SafeCallback(Func, ...)
    if not Func or typeof(Func) ~= "function" then return end
    local Result = table.pack(xpcall(Func, function(Error)
        task.defer(error, debug.traceback(Error, 2))
        if MacoriaLib.NotifyOnError then
            MacoriaLib:Notify(Error)
        end
        return Error
    end, ...))
    if not Result[1] then return nil end
    return table.unpack(Result, 2, Result.n)
end

local function GiveSignal(Connection)
    table.insert(MacoriaLib.Signals, Connection)
    return Connection
end

local function RemoveFromRegistry(Instance)
    MacoriaLib.Registry[Instance] = nil
end

local function UpdateColorsUsingRegistry()
    for Instance, Properties in pairs(MacoriaLib.Registry) do
        for Property, ColorIdx in pairs(Properties) do
            if typeof(ColorIdx) == "string" then
                Instance[Property] = MacoriaLib.Scheme[ColorIdx]
            elseif typeof(ColorIdx) == "function" then
                Instance[Property] = ColorIdx()
            end
        end
    end
end

local function UpdateDPI(Instance, Properties)
    if not MacoriaLib.DPIRegistry[Instance] then return end
    for Property, Value in pairs(Properties) do
        if Property == "DPIExclude" or Property == "DPIOffset" then continue
        elseif Property == "TextSize" then
            Instance[Property] = ApplyTextScale(Value)
        else
            Instance[Property] = ApplyDPIScale(Value)
        end
    end
end

local function SetDPIScale(DPIScale)
    MacoriaLib.DPIScale = DPIScale / 100
    MacoriaLib.MinSize *= MacoriaLib.DPIScale
    for Instance, Properties in pairs(MacoriaLib.DPIRegistry) do
        UpdateDPI(Instance, Properties)
    end
    for _, Tab in pairs(MacoriaLib.Tabs) do
        if not Tab.IsKeyTab then
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
    end
    for _, Option in pairs(MacoriaLib.Options) do
        if Option.Type == "Dropdown" then
            Option:RecalculateListSize()
        elseif Option.Type == "KeyPicker" then
            Option:Update()
        end
    end
    MacoriaLib:UpdateKeybindFrame()
    for _, Notification in pairs(MacoriaLib.Notifications) do
        Notification:Resize()
    end
end

local function MakeDraggable(UI, DragFrame, IgnoreToggled, IsMainWindow)
    local StartPos, FramePos, Dragging, Changed
    DragFrame.InputBegan:Connect(function(Input)
        if not IsClickInput(Input) or (IsMainWindow and MacoriaLib.CantDragForced) then return end
        StartPos = Input.Position
        FramePos = UI.Position
        Dragging = true
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then return end
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)
    GiveSignal(UserInputService.InputChanged:Connect(function(Input)
        if (not IgnoreToggled and not MacoriaLib.Toggled) or (IsMainWindow and MacoriaLib.CantDragForced) then
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
            return
        end
        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            UI.Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
        end
    end))
end

local function MakeResizable(UI, DragFrame, Callback)
    local StartPos, FrameSize, Dragging, Changed
    DragFrame.InputBegan:Connect(function(Input)
        if not IsClickInput(Input) then return end
        StartPos = Input.Position
        FrameSize = UI.Size
        Dragging = true
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then return end
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)
    GiveSignal(UserInputService.InputChanged:Connect(function(Input)
        if not UI.Visible then
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
            return
        end
        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            UI.Size = UDim2.new(FrameSize.X.Scale, math.clamp(FrameSize.X.Offset + Delta.X, MacoriaLib.MinSize.X, math.huge), FrameSize.Y.Scale, math.clamp(FrameSize.Y.Offset + Delta.Y, MacoriaLib.MinSize.Y, math.huge))
            if Callback then
                SafeCallback(Callback)
            end
        end
    end))
end

local function AddToRegistry(Instance, Properties)
    MacoriaLib.Registry[Instance] = Properties
end

local function UpdateDependencyBoxes()
    for _, Depbox in pairs(MacoriaLib.DependencyBoxes) do
        Depbox:Update(true)
    end
    if MacoriaLib.Searching then
        MacoriaLib:UpdateSearch(MacoriaLib.SearchText)
    end
end

local function CheckDepbox(Box, Search)
    local VisibleElements = 0
    for _, ElementInfo in pairs(Box.Elements) do
        if ElementInfo.Type == "Divider" then
            ElementInfo.Holder.Visible = false
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
        else
            if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                ElementInfo.Holder.Visible = true
                VisibleElements += 1
            else
                ElementInfo.Holder.Visible = false
            end
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

local function UpdateKeybindFrame()
    if not MacoriaLib.KeybindFrame then
        return
    end
    local XSize = 0
    for _, KeybindToggle in pairs(MacoriaLib.KeybindToggles) do
        if not KeybindToggle.Holder.Visible then
            continue
        end
        local FullSize = KeybindToggle.Label.Size.X.Offset + KeybindToggle.Label.Position.X.Offset
        if FullSize > XSize then
            XSize = FullSize
        end
    end
    MacoriaLib.KeybindFrame.Size = UDim2.fromOffset(XSize + 18 * MacoriaLib.DPIScale, 0)
end

local function Validate(Table, Template)
    if typeof(Table) ~= "table" then
        return Template
    end
    for k, v in pairs(Template) do
        if typeof(k) == "number" then
            continue
        end
        if typeof(v) == "table" then
            Table[k] = Validate(Table[k], v)
        elseif Table[k] == nil then
            Table[k] = v
        end
    end
    return Table
end

local function FillInstance(Properties, Instance)
    local ThemeProperties = MacoriaLib.Registry[Instance] or {}
    local DPIProperties = MacoriaLib.DPIRegistry[Instance] or {}
    local DPIExclude = DPIProperties["DPIExclude"] or Properties["DPIExclude"] or {}
    local DPIOffset = DPIProperties["DPIOffset"] or Properties["DPIOffset"] or {}
    for k, v in pairs(Properties) do
        if k == "DPIExclude" or k == "DPIOffset" then
            continue
        elseif ThemeProperties[k] then
            ThemeProperties[k] = nil
        elseif k ~= "Text" and (MacoriaLib.Scheme[v] or typeof(v) == "function") then
            ThemeProperties[k] = v
            Instance[k] = MacoriaLib.Scheme[v] or v()
            continue
        end
        if not DPIExclude[k] then
            if k == "Position" or k == "Size" or k:match("Padding") then
                DPIProperties[k] = v
                v = ApplyDPIScale(v)
            elseif k == "TextSize" then
                DPIProperties[k] = v
                v = ApplyTextScale(v)
            end
        end
        Instance[k] = v
    end
    if GetTableSize(ThemeProperties) > 0 then
        AddToRegistry(Instance, ThemeProperties)
    end
    if GetTableSize(DPIProperties) > 0 then
        DPIProperties["DPIExclude"] = DPIExclude
        DPIProperties["DPIOffset"] = DPIOffset
        MacoriaLib.DPIRegistry[Instance] = DPIProperties
    end
end

local function New(ClassName, Properties)
    local Instance = Instance.new(ClassName)
    FillInstance(Properties, Instance)
    if Properties["Parent"] and not Properties["ZIndex"] then
        pcall(function()
            Instance.ZIndex = Properties.Parent.ZIndex
        end)
    end
    return Instance
end

local function OnUnload(Callback)
    table.insert(MacoriaLib.UnloadSignals, Callback)
end

local function Unload()
    for Index = #MacoriaLib.Signals, 1, -1 do
        local Connection = table.remove(MacoriaLib.Signals, Index)
        Connection:Disconnect()
    end
    for _, Callback in pairs(MacoriaLib.UnloadSignals) do
        SafeCallback(Callback)
    end
    MacoriaLib.Unloaded = true
    if MacoriaLib.ScreenGui then
        MacoriaLib.ScreenGui:Destroy()
    end
    if MacoriaLib.ModalScreenGui then
        MacoriaLib.ModalScreenGui:Destroy()
    end
end

local function MakeOutline(Frame, Corner, ZIndex)
    local Holder = New("Frame", {
        BackgroundColor3 = "Dark",
        Position = UDim2.fromOffset(-2, -2),
        Size = UDim2.new(1, 4, 1, 4),
        ZIndex = ZIndex,
        Parent = Frame,
    })
    local Outline = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = ZIndex,
        Parent = Holder,
    })
    if Corner and Corner > 0 then
        New("UICorner", { CornerRadius = UDim.new(0, Corner + 1), Parent = Holder })
        New("UICorner", { CornerRadius = UDim.new(0, Corner), Parent = Outline })
    end
    return Holder
end

local function MakeLine(Frame, Info)
    local Line = New("Frame", {
        AnchorPoint = Info.AnchorPoint or Vector2.zero,
        BackgroundColor3 = "OutlineColor",
        Position = Info.Position,
        Size = Info.Size,
        Parent = Frame,
    })
    return Line
end

local Templates = {
    Window = { Title = "No Title", Subtitle = "", Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(720, 600), IconSize = UDim2.fromOffset(30, 30), AutoShow = true, Center = true, Resizable = true, SearchbarSize = UDim2.fromScale(1, 1), CornerRadius = 10, NotifySide = "Right", ShowCustomCursor = false, Font = Enum.Font.Code, ToggleKeybind = Enum.KeyCode.RightControl, MobileButtonsSide = "Left", AcrylicBlur = true },
    Toggle = { Text = "Toggle", Default = false, Callback = function() end, Changed = function() end, Risky = false, Disabled = false, Visible = true, Class = "Toggle", Prefix = "", Suffix = "", DisplayMethod = "Value", Precision = 0 },
    Input = { Text = "Input", Default = "", Finished = false, Numeric = false, ClearTextOnFocus = true, Placeholder = "", AllowEmpty = true, EmptyReset = "---", Callback = function() end, Changed = function() end, Disabled = false, Visible = true, Class = "Input", AcceptedCharacters = "All", CharacterLimit = nil, onChanged = nil },
    Slider = { Text = "Slider", Default = 0, Min = 0, Max = 100, Rounding = 0, Prefix = "", Suffix = "", Callback = function() end, Changed = function() end, Disabled = false, Visible = true, Class = "Slider", DisplayMethod = "Value", Precision = 0, onInputComplete = nil },
    Dropdown = { Values = {}, DisabledValues = {}, Multi = false, MaxVisibleDropdownItems = 8, Searchable = false, Callback = function() end, Changed = function() end, Disabled = false, Visible = true, Class = "Dropdown", Default = nil, Required = false, Search = false, SpecialType = nil, AllowNull = true, FormatDisplayValue = nil },
    KeyPicker = { Text = "KeyPicker", Default = "None", Mode = "Toggle", Modes = { "Always", "Toggle", "Hold" }, SyncToggleState = false, Callback = function() end, ChangedCallback = function() end, Changed = function() end, Clicked = function() end, Blacklist = nil, WaitForCallback = false, NoUI = false, onBinded = nil, onBindHeld = nil },
    ColorPicker = { Default = Color3.new(1, 1, 1), Transparency = 0, Title = nil, Callback = function() end, Changed = function() end },
    Section = { Side = "Left" },
    Button = { Name = "Button", Callback = function() end, DoubleClick = false, Risky = false, Disabled = false, Visible = true },
}

local function Window(Settings)
    local WindowFunctions = {}
    WindowFunctions.Settings = Validate(Settings, Templates.Window)
    
    MacoriaLib.ScreenGui = GetGui()
    MacoriaLib.ModalScreenGui = GetGui()
    MacoriaLib.ModalScreenGui.Name = "MacoriaModal"
    local ModalElement = New("TextButton", {
        BackgroundTransparency = 1,
        Modal = false,
        Size = UDim2.fromScale(0, 0),
        Text = "",
        ZIndex = -999,
        Parent = MacoriaLib.ModalScreenGui,
    })

    local base = New("Frame", {
        Name = "Base",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BackgroundTransparency = WindowFunctions.Settings.AcrylicBlur and 0.05 or 0,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = WindowFunctions.Settings.Size,
        Parent = MacoriaLib.ScreenGui,
    })

    local baseUIScale = New("UIScale", { Parent = base })
    local baseUICorner = New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = base })
    local baseUIStroke = New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.9,
        Parent = base,
    })

    local notifications = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = MacoriaLib.ScreenGui,
        ZIndex = 2,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = notifications,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        Parent = notifications,
    })

    local sidebar = New("Frame", {
        Name = "Sidebar",
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(-3.52e-08, 4.69e-08),
        Size = UDim2.fromScale(0.325, 1),
        Parent = base,
    })

    local divider = New("Frame", {
        Name = "Divider",
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 0.9,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Parent = sidebar,
    })

    local dividerInteract = New("TextButton", {
        Name = "DividerInteract",
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.new(1, 6, 1, 0),
        Text = "",
        Parent = divider,
    })

    local windowControls = New("Frame", {
        Name = "WindowControls",
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 31),
        Parent = sidebar,
    })

    local controls = New("Frame", {
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = windowControls,
    })

    New("UIListLayout", {
        Padding = UDim.new(0, 5),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = controls,
    })

    New("UIPadding", {
        PaddingLeft = UDim.new(0, 11),
        Parent = controls,
    })

    local windowControlSettings = {
        sizes = { enabled = UDim2.fromOffset(8, 8), disabled = UDim2.fromOffset(7, 7) },
        transparencies = { enabled = 0, disabled = 1 },
        strokeTransparency = 0.9,
    }

    local function applyState(button, enabled)
        local size = enabled and windowControlSettings.sizes.enabled or windowControlSettings.sizes.disabled
        local transparency = enabled and windowControlSettings.transparencies.enabled or windowControlSettings.transparencies.disabled
        button.Size = size
        button.BackgroundTransparency = transparency
        button.Active = enabled
        button.Interactable = enabled
        for _, child in ipairs(button:GetChildren()) do
            if child:IsA("UIStroke") then
                child.Transparency = transparency
            end
        end
        if not enabled then
            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Color3.fromRGB(255, 255, 255),
                Transparency = windowControlSettings.strokeTransparency,
                Parent = button,
            })
        end
    end

    local exit = New("TextButton", {
        Name = "Exit",
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(250, 93, 86),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Parent = controls,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = exit })

    local minimize = New("TextButton", {
        Name = "Minimize",
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(252, 190, 57),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Parent = controls,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = minimize })

    applyState(minimize, false)
    local controlsList = {exit}
    for _, button in pairs(controlsList) do
        local buttonName = button.Name
        local isEnabled = true
        if WindowFunctions.Settings.DisabledWindowControls and table.find(WindowFunctions.Settings.DisabledWindowControls, buttonName) then
            isEnabled = false
        end
        applyState(button, isEnabled)
    end

    New("Frame", {
        Name = "Divider",
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 0.9,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = windowControls,
    })

    local information = New("Frame", {
        Name = "Information",
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 31),
        Size = UDim2.new(1, 0, 0, 60),
        Parent = sidebar,
    })

    New("Frame", {
        Name = "Divider",
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 0.9,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = information,
    })

    local informationHolder = New("Frame", {
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = information,
    })

    New("UIPadding", {
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 23),
        PaddingRight = UDim.new(0, 22),
        PaddingTop = UDim.new(0, 10),
        Parent = informationHolder,
    })

    local titleFrame = New("Frame", {
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = informationHolder,
    })

    local title = New("TextLabel", {
        Name = "Title",
        FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = WindowFunctions.Settings.Title,
        RichText = true,
        TextTransparency = 0.1,
        TextTruncate = Enum.TextTruncate.SplitWord,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, 0),
        TextSize = ApplyTextScale(18),
        Parent = titleFrame,
    })

    local subtitle = New("TextLabel", {
        Name = "Subtitle",
        FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        RichText = true,
        Text = WindowFunctions.Settings.Subtitle or "",
        TextTransparency = 0.7,
        TextTruncate = Enum.TextTruncate.SplitWord,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Size = UDim2.new(1, -20, 0, 0),
        TextSize = ApplyTextScale(12),
        Parent = titleFrame,
    })

    New("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = titleFrame,
    })

    local sidebarGroup = New("Frame", {
        Name = "SidebarGroup",
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 91),
        Size = UDim2.new(1, 0, 1, -91),
        Parent = sidebar,
    })

    local userInfo = New("Frame", {
        Name = "UserInfo",
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 107),
        Parent = sidebarGroup,
    })

    local informationGroup = New("Frame", {
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = userInfo,
    })

    New("UIPadding", {
        PaddingBottom = UDim.new(0, 17),
        PaddingLeft = UDim.new(0, 25),
        Parent = informationGroup,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = informationGroup,
    })

    local userId = LocalPlayer.UserId
    local thumbType = Enum.ThumbnailType.AvatarBust
    local thumbSize = Enum.ThumbnailSize.Size48x48
    local headshotImage, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

    local headshot = New("ImageLabel", {
        Name = "Headshot",
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(32, 32),
        Image = (isReady and headshotImage) or "rbxassetid://0",
        Parent = informationGroup,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = headshot })
    New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.9,
        Parent = headshot,
    })

    local userAndDisplayFrame = New("Frame", {
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Size = UDim2.new(1, -42, 0, 32),
        Parent = informationGroup,
    })

    New("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 3),
        Parent = userAndDisplayFrame,
    })

    New("UIListLayout", {
        Padding = UDim.new(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = userAndDisplayFrame,
    })

    local displayName = New("TextLabel", {
        Name = "DisplayName",
        FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = LocalPlayer.DisplayName,
        TextTransparency = 0.1,
        TextTruncate = Enum.TextTruncate.SplitWord,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 0),
        TextSize = ApplyTextScale(13),
        Parent = userAndDisplayFrame,
    })

    local username = New("TextLabel", {
        Name = "Username",
        FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = "@" .. LocalPlayer.Name,
        TextTransparency = 0.7,
        TextTruncate = Enum.TextTruncate.SplitWord,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Size = UDim2.fromScale(1, 0),
        TextSize = ApplyTextScale(12),
        Parent = userAndDisplayFrame,
    })

    New("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = userInfo,
    })

    New("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 31),
        Parent = sidebarGroup,
    })

    local tabSwitchers = New("Frame", {
        Name = "TabSwitchers",
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, -107),
        Parent = sidebarGroup,
    })

    New("UIListLayout", {
        Padding = UDim.new(0, 17),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabSwitchers,
    })

    New("UIPadding", {
        PaddingTop = UDim.new(0, 2),
        Parent = tabSwitchers,
    })

    local content = New("Frame", {
        Name = "Content",
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(1, 4.69e-08),
        Size = UDim2.new(0, (base.AbsoluteSize.X - sidebar.AbsoluteSize.X), 1, 0),
        Parent = base,
    })

    local resizingContent = false
    local defaultSidebarWidth = sidebar.AbsoluteSize.X
    local initialMouseX, initialSidebarWidth
    local snapRange = 20
    local minSidebarWidth = 107
    local maxSidebarWidth = base.AbsoluteSize.X - minSidebarWidth

    local TweenSettings = { DefaultTransparency = 0.9, HoverTransparency = 0.85, EasingStyle = Enum.EasingStyle.Sine }

    local function ChangeState(State)
        Tween(divider, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
            BackgroundTransparency = State == "Idle" and TweenSettings.DefaultTransparency or TweenSettings.HoverTransparency
        }):Play()
    end

    dividerInteract.MouseEnter:Connect(function()
        ChangeState("Hover")
    end)
    dividerInteract.MouseLeave:Connect(function()
        ChangeState("Idle")
    end)
    dividerInteract.MouseButton1Down:Connect(function()
        resizingContent = true
        initialMouseX = UserInputService:GetMouseLocation().X
        initialSidebarWidth = sidebar.AbsoluteSize.X
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizingContent = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizingContent and input.UserInputType == Enum.UserInputType.MouseMovement then
            local deltaX = UserInputService:GetMouseLocation().X - initialMouseX
            local newSidebarWidth = initialSidebarWidth + deltaX
            if math.abs(newSidebarWidth - defaultSidebarWidth) < snapRange then
                newSidebarWidth = defaultSidebarWidth
            else
                newSidebarWidth = math.clamp(newSidebarWidth, minSidebarWidth, maxSidebarWidth)
            end
            sidebar.Size = UDim2.new(0, newSidebarWidth, 1, 0)
            content.Size = UDim2.new(0, base.AbsoluteSize.X - newSidebarWidth, 1, 0)
        end
    end)

    local topbar = New("Frame", {
        Name = "Topbar",
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 63),
        Parent = content,
    })

    New("Frame", {
        Name = "Divider",
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 0.9,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = topbar,
    })

    local elements = New("Frame", {
        Name = "Elements",
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = topbar,
    })

    New("UIPadding", {
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 20),
        Parent = elements,
    })

    local moveIcon = New("ImageButton", {
        Name = "MoveIcon",
        Image = assets.transform,
        ImageTransparency = 0.7,
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(1, 0.5),
        Size = UDim2.fromOffset(15, 15),
        Parent = elements,
        Visible = not WindowFunctions.Settings.DragStyle or WindowFunctions.Settings.DragStyle == 1,
    })

    local currentTab = New("TextLabel", {
        Name = "CurrentTab",
        FontFace = Font.new(assets.interFont),
        RichText = true,
        Text = "",
        RichText = true,
        TextTransparency = 0.5,
        TextTruncate = Enum.TextTruncate.SplitWord,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AnchorPoint = Vector2.new(0, 0.5),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromScale(0.9, 0),
        TextSize = ApplyTextScale(15),
        Parent = elements,
    })

    UpdateDPI(moveIcon, { Size = UDim2.fromOffset(15, 15) })
    MakeDraggable(base, moveIcon, true, true)

    local tabIndex = 0
    local globalSettings
    local hasGlobalSetting = false

    function WindowFunctions:GlobalSetting(Settings)
        hasGlobalSetting = true
        local GlobalSettingFunctions = {}
        local globalSetting = New("TextButton", {
            Text = "",
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(200, 30),
            Parent = globalSettings,
        })
        local settingName = New("TextLabel", {
            FontFace = Font.new(assets.interFont),
            RichText = true,
            TextTransparency = 0.5,
            TextTruncate = Enum.TextTruncate.SplitWord,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AnchorPoint = Vector2.new(0, 0.5),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(1.3e-07, 0.5),
            Size = UDim2.new(1, -40, 0, 0),
            Text = Settings.Name,
            TextSize = ApplyTextScale(13),
            Parent = globalSetting,
        })
        local checkmark = New("TextLabel", {
            FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            Text = "✓",
            TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AnchorPoint = Vector2.new(0, 0.5),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            LayoutOrder = -1,
            Position = UDim2.fromScale(1.3e-07, 0.5),
            Size = UDim2.fromOffset(-10, 0),
            Parent = globalSetting,
        })
        local tweensettings = {
            duration = 0.2,
            easingStyle = Enum.EasingStyle.Quint,
            transparencyIn = 0.2,
            transparencyOut = 0.5,
            checkSizeIncrease = 12,
            checkSizeDecrease = -10,
            waitTime = 1,
        }
        local toggled = Settings.Default
        local function Toggle()
            toggled = not toggled
            if not toggled then
                Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                    Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
                }):Play()
                Tween(settingName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                    TextTransparency = tweensettings.transparencyOut
                }):Play()
                checkmark:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    if checkmark.AbsoluteSize.X <= 0 then
                        checkmark.TextTransparency = 1
                    end
                end)
            else
                Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                    Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
                }):Play()
                Tween(settingName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                    TextTransparency = tweensettings.transparencyIn
                }):Play()
                checkmark:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    if checkmark.AbsoluteSize.X > 0 then
                        checkmark.TextTransparency = 0
                    end
                end)
            end
            task.spawn(function()
                if Settings.Callback then
                    Settings.Callback(toggled)
                end
            end)
        end
        globalSetting.MouseButton1Click:Connect(Toggle)
        function GlobalSettingFunctions:UpdateName(NewName)
            settingName.Text = NewName
        end
        function GlobalSettingFunctions:UpdateState(NewState)
            Toggle()
            toggled = NewState
        end
        return GlobalSettingFunctions
    end

    function WindowFunctions:Tab(Settings)
        local TabFunctions = {}
        tabIndex += 1
        Settings.LayoutOrder = tabIndex
        local tabSwitcher = New("TextButton", {
            Name = "TabSwitcher",
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(1, -21, 0, 40),
            Parent = tabSwitchers,
        })
        local tabSwitcherUICorner = New("UICorner", { Parent = tabSwitcher })
        local tabSwitcherUIStroke = New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 1,
            Parent = tabSwitcher,
        })
        local tabSwitcherName = New("TextLabel", {
            FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            RichText = true,
            Text = Settings.Name,
            TextTransparency = 0.5,
            TextTruncate = Enum.TextTruncate.SplitWord,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 0),
            TextSize = ApplyTextScale(16),
            Parent = tabSwitcher,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 5),
            Parent = tabSwitcher,
        })
        local tabHolder = New("ScrollingFrame", {
            Name = "Tab",
            Active = true,
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(1.08, 0.081),
            Size = UDim2.fromScale(1.11, 0.92),
            Visible = false,
            CanvasSize = UDim2.fromScale(0, 0),
            ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
            ScrollBarImageTransparency = 0.7,
            ScrollBarThickness = 3,
            Parent = content,
        })
        local tabLeftHolder = New("Frame", {
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(0.5, 1),
            Parent = tabHolder,
        })
        local tabRightHolder = New("Frame", {
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.fromScale(0.5, 1),
            Parent = tabHolder,
        })
        local tabLeftHolderList = New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tabLeftHolder,
        })
        local tabRightHolderList = New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tabRightHolder,
        })
        local tabLeftHolderPadding = New("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            Parent = tabLeftHolder,
        })
        local tabRightHolderPadding = New("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            Parent = tabRightHolder,
        })
        TabFunctions.Tab = tabHolder
        TabFunctions.TabLeftHolder = tabLeftHolder
        TabFunctions.TabRightHolder = tabRightHolder
        TabFunctions.TabLeftHolderList = tabLeftHolderList
        TabFunctions.TabRightHolderList = tabRightHolderList
        TabFunctions.TabLeftHolderPadding = tabLeftHolderPadding
        TabFunctions.TabRightHolderPadding = tabRightHolderPadding
        TabFunctions.Groupboxes = {}
        TabFunctions.Tabboxes = {}
        TabFunctions.Elements = {}
        TabFunctions.Buttons = {}
        TabFunctions.Name = Settings.Name
        TabFunctions.LogoSize = Settings.LogoSize
        table.insert(MacoriaLib.Tabs, TabFunctions)
        local function Show()
            currentTab.Text = Settings.Name
            if MacoriaLib.ActiveTab then
                MacoriaLib.ActiveTab.Visible = false
            end
            tabHolder.Visible = true
            MacoriaLib.ActiveTab = tabHolder
            MacoriaLib:UpdateSearch(MacoriaLib.SearchText)
        end
        local function RegisterSearch()
            for _, Element in pairs(TabFunctions.Elements) do
                if Element.Holder then
                    Element.Holder.LayoutOrder = Element.ZIndex
                end
            end
        end
        Show()
        RegisterSearch()
        local changed = false
        local function UpdateOutline(Active)
            if changed == Active then
                return
            end
            changed = Active
            Tween(tabSwitcherUIStroke, MacoriaLib.TweenInfo, {Transparency = Active and 0.7 or 1}):Play()
        end
        UpdateOutline(true)
        tabSwitcher.MouseEnter:Connect(function()
            UpdateOutline(true)
        end)
        tabSwitcher.MouseLeave:Connect(function()
            UpdateOutline(changed)
        end)
        tabSwitcher.InputBegan:Connect(function(Input)
            UpdateOutline(true)
        end)
        tabSwitcher.InputEnded:Connect(function(Input)
            UpdateOutline(changed)
        end)
        tabSwitcher.MouseButton1Click:Connect(function()
            Show()
            for _, Tab in pairs(MacoriaLib.Tabs) do
                if Tab.Tab == tabHolder then
                    changed = true
                else
                    changed = false
                end
            end
            UpdateOutline(true)
            for _, Tab in pairs(MacoriaLib.Tabs) do
                if Tab.UpdateOutline then
                    Tab.UpdateOutline(false)
                end
            end
        end)
        tabSwitcherName.InputBegan:Connect(function(Input)
            UpdateOutline(true)
        end)
        tabSwitcherName.InputEnded:Connect(function(Input)
            UpdateOutline(changed)
        end)
        TabFunctions.UpdateOutline = UpdateOutline
        function TabFunctions:Show()
            Show()
            changed = true
            Tween(tabSwitcherUIStroke, MacoriaLib.TweenInfo, {Transparency = 0.7}):Play()
            for _, Tab in pairs(MacoriaLib.Tabs) do
                if Tab.UpdateOutline then
                    Tab.UpdateOutline(false)
                end
            end
        end
        function TabFunctions:Resize(Smooth)
            local SizeYLeft, ListYLeft, SizeYRight, ListYRight = 0, 0, 0, 0
            for _, Groupbox in pairs(TabFunctions.Groupboxes) do
                if Groupbox.Side == "Left" then
                    Groupbox:Resize(Smooth)
                    local GpY = Groupbox.OuterHolder.AbsoluteSize.Y
                    SizeYLeft = SizeYLeft + GpY + 6
                    for _, Element in pairs(Groupbox.Elements) do
                        ListYLeft = ListYLeft + (Element.Holder and Element.Holder.AbsoluteSize.Y or Element.AbsoluteSize.Y) + 6
                    end
                elseif Groupbox.Side == "Right" then
                    Groupbox:Resize(Smooth)
                    local GpY = Groupbox.OuterHolder.AbsoluteSize.Y
                    SizeYRight = SizeYRight + GpY + 6
                    for _, Element in pairs(Groupbox.Elements) do
                        ListYRight = ListYRight + (Element.Holder and Element.Holder.AbsoluteSize.Y or Element.AbsoluteSize.Y) + 6
                    end
                end
            end
            for _, Tabbox in pairs(TabFunctions.Tabboxes) do
                Tabbox:Resize()
                local TbY = Tabbox.TabsHolder.AbsoluteSize.Y
                if Tabbox.Side == "Left" then
                    SizeYLeft = SizeYLeft + TbY + 6
                elseif Tabbox.Side == "Right" then
                    SizeYRight = SizeYRight + TbY + 6
                end
                for _, Tab in pairs(Tabbox.Tabs) do
                    for _, Groupbox in pairs(Tab.Groupboxes) do
                        Groupbox:Resize(Smooth)
                        local GpY = Groupbox.OuterHolder.AbsoluteSize.Y
                        if Tabbox.Side == "Left" then
                            SizeYLeft = SizeYLeft + GpY + 6
                        elseif Tabbox.Side == "Right" then
                            SizeYRight = SizeYRight + GpY + 6
                        end
                        for _, Element in pairs(Groupbox.Elements) do
                            if Tabbox.Side == "Left" then
                                ListYLeft = ListYLeft + (Element.Holder and Element.Holder.AbsoluteSize.Y or Element.AbsoluteSize.Y) + 6
                            elseif Tabbox.Side == "Right" then
                                ListYRight = ListYRight + (Element.Holder and Element.Holder.AbsoluteSize.Y or Element.AbsoluteSize.Y) + 6
                            end
                        end
                    end
                end
            end
            local SizeY = math.max(SizeYLeft, SizeYRight)
            tabHolder.CanvasSize = UDim2.new(0, 0, 0, SizeY)
            tabLeftHolderList.VerticalAlignment = if ListYLeft < tabLeftHolder.AbsoluteSize.Y then Enum.VerticalAlignment.Top else Enum.VerticalAlignment.Top
            tabRightHolderList.VerticalAlignment = if ListYRight < tabRightHolder.AbsoluteSize.Y then Enum.VerticalAlignment.Top else Enum.VerticalAlignment.Top
        end

        function TabFunctions:Groupbox(Settings)
            local GroupboxFunctions = {}
            local Groupbox = New("Frame", {
                Name = "Groupbox",
                BackgroundColor3 = "BackgroundColor",
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(420, 2),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = TabFunctions[Settings.Side .. "Holder"],
            })
            local GroupboxCorner = New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Groupbox })
            AddToRegistry(Groupbox, { BackgroundColor3 = "BackgroundColor" })
            local OutlineHolder = MakeOutline(Groupbox, 8, 0)
            local GroupboxHolder = New("Frame", {
                Name = "GroupboxHolder",
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(6, 6),
                Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(12, 12),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = Groupbox,
            })
            local GroupboxTitle = New("TextLabel", {
                Name = "GroupboxTitle",
                FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                RichText = true,
                Text = Settings.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = ApplyTextScale(14),
                TextTransparency = 0,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                AnchorPoint = Vector2.new(0, 0),
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0, 0),
                Parent = GroupboxHolder,
            })
            local GroupboxDivider = New("Frame", {
                Name = "Divider",
                AnchorPoint = Vector2.new(0, 0),
                BackgroundColor3 = "OutlineColor",
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, GroupboxTitle.TextSize + 2),
                Size = UDim2.new(0.5, -2, 0, 1),
                Parent = GroupboxHolder,
            })
            AddToRegistry(GroupboxDivider, { BackgroundColor3 = "OutlineColor" })
            local GroupboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = GroupboxHolder,
            })
            local GroupboxPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, GroupboxTitle.TextSize + 8),
                Parent = GroupboxHolder,
            })
            GroupboxFunctions.OuterHolder = Groupbox
            GroupboxFunctions.InnerHolder = GroupboxHolder
            GroupboxFunctions.Elements = {}
            GroupboxFunctions.Side = Settings.Side
            GroupboxFunctions.Text = Settings.Name
            function GroupboxFunctions:Resize()
                local Size = 0
                for _, Element in pairs(GroupboxFunctions.Elements) do
                    if Element.Holder then
                        if Element.Holder.Visible then
                            Size += Element.Holder.AbsoluteSize.Y + 8
                        end
                    end
                end
                GroupboxHolder.Size = UDim2.fromOffset(GroupboxHolder.AbsoluteSize.X, Size + GroupboxTitle.TextSize + 16)
                Groupbox.Size = UDim2.fromOffset(420, GroupboxHolder.Size.Y.Offset + 12)
            end
            table.insert(TabFunctions.Groupboxes, GroupboxFunctions)
            return GroupboxFunctions
        end

        function TabFunctions:Tabbox(Settings)
            local TabboxFunctions = {}
            local Tabbox = New("Frame", {
                Name = "Tabbox",
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(420, 28),
                Parent = TabFunctions[Settings.Side .. "Holder"],
            })
            local TabboxTop = New("Frame", {
                Name = "TabboxTop",
                BackgroundColor3 = "BackgroundColor",
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(420, 28),
                Parent = Tabbox,
            })
            TabboxTop.ClipsDescendants = true
            local TabboxTopCorner = New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = TabboxTop })
            AddToRegistry(TabboxTop, { BackgroundColor3 = "BackgroundColor" })
            local TabboxTopDivider = New("Frame", {
                Name = "Divider",
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = "OutlineColor",
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0, 1),
                Size = UDim2.fromScale(1, 0),
                Parent = TabboxTop,
            })
            AddToRegistry(TabboxTopDivider, { BackgroundColor3 = "OutlineColor" })
            local TabboxPadding = New("UIPadding", {
                PaddingLeft = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 5),
                Parent = TabboxTop,
            })
            local TabboxList = New("UIListLayout", {
                Padding = UDim.new(0, 4),
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = TabboxTop,
            })
            local TabboxTabsHolder = New("Frame", {
                Name = "TabsHolder",
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(0, 35),
                Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(0, 35),
                Parent = Tabbox,
            })
            TabboxFunctions.Tabs = {}
            TabboxFunctions.OuterHolder = Tabbox
            TabboxFunctions.TopHolder = TabboxTop
            TabboxFunctions.TabsHolder = TabboxTabsHolder
            TabboxFunctions.Side = Settings.Side
            function TabboxFunctions:Resize()
                local Size = 0
                for _, Tab in pairs(TabboxFunctions.Tabs) do
                    Size = math.max(Size, Tab.OuterHolder.AbsoluteSize.Y + 35)
                end
                Tabbox.Size = UDim2.fromOffset(420, Size)
            end
            function TabboxFunctions:AddTab(Name)
                local TabboxTabFunctions = {}
                local TabboxTab = New("ScrollingFrame", {
                    Name = "Tab",
                    Active = true,
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 1),
                    Visible = false,
                    ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
                    ScrollBarImageTransparency = 0.7,
                    ScrollBarThickness = 3,
                    Parent = TabboxTabsHolder,
                })
                local TabboxTabLeft = New("Frame", {
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(0.5, 1),
                    Parent = TabboxTab,
                })
                local TabboxTabRight = New("Frame", {
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.fromScale(0.5, 0),
                    Size = UDim2.fromScale(0.5, 1),
                    Parent = TabboxTab,
                })
                local TabboxTabLeftList = New("UIListLayout", {
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = TabboxTabLeft,
                })
                local TabboxTabRightList = New("UIListLayout", {
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = TabboxTabRight,
                })
                local TabboxTabLeftPadding = New("UIPadding", {
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    Parent = TabboxTabLeft,
                })
                local TabboxTabRightPadding = New("UIPadding", {
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    Parent = TabboxTabRight,
                })
                TabboxTabFunctions.Name = Name
                TabboxTabFunctions.OuterHolder = TabboxTab
                TabboxTabFunctions.TabLeftHolder = TabboxTabLeft
                TabboxTabFunctions.TabRightHolder = TabboxTabRight
                TabboxTabFunctions.TabLeftHolderList = TabboxTabLeftList
                TabboxTabFunctions.TabRightHolderList = TabboxTabRightList
                TabboxTabFunctions.TabLeftHolderPadding = TabboxTabLeftPadding
                TabboxTabFunctions.TabRightHolderPadding = TabboxTabRightPadding
                TabboxTabFunctions.Groupboxes = {}
                function TabboxTabFunctions:Show()
                    for _, Tab in pairs(TabboxFunctions.Tabs) do
                        Tab.OuterHolder.Visible = false
                    end
                    TabboxTab.Visible = true
                    Tabbox:Resize()
                    TabFunctions:Resize(true)
                end
                function TabboxTabFunctions:Groupbox(Settings)
                    local GroupboxFunctions = {}
                    local Groupbox = New("Frame", {
                        Name = "Groupbox",
                        BackgroundColor3 = "BackgroundColor",
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromOffset(420, 2),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Parent = TabboxTabFunctions[Settings.Side .. "Holder"],
                    })
                    local GroupboxCorner = New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Groupbox })
                    AddToRegistry(Groupbox, { BackgroundColor3 = "BackgroundColor" })
                    local OutlineHolder = MakeOutline(Groupbox, 8, 0)
                    local GroupboxHolder = New("Frame", {
                        Name = "GroupboxHolder",
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromOffset(6, 6),
                        Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(12, 12),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Parent = Groupbox,
                    })
                    local GroupboxTitle = New("TextLabel", {
                        Name = "GroupboxTitle",
                        FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        RichText = true,
                        Text = Settings.Name,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = ApplyTextScale(14),
                        TextTransparency = 0,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        AnchorPoint = Vector2.new(0, 0),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0, 0),
                        Parent = GroupboxHolder,
                    })
                    local GroupboxDivider = New("Frame", {
                        Name = "Divider",
                        AnchorPoint = Vector2.new(0, 0),
                        BackgroundColor3 = "OutlineColor",
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, GroupboxTitle.TextSize + 2),
                        Size = UDim2.new(0.5, -2, 0, 1),
                        Parent = GroupboxHolder,
                    })
                    AddToRegistry(GroupboxDivider, { BackgroundColor3 = "OutlineColor" })
                    local GroupboxList = New("UIListLayout", {
                        Padding = UDim.new(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = GroupboxHolder,
                    })
                    local GroupboxPadding = New("UIPadding", {
                        PaddingBottom = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 8),
                        PaddingTop = UDim.new(0, GroupboxTitle.TextSize + 8),
                        Parent = GroupboxHolder,
                    })
                    GroupboxFunctions.OuterHolder = Groupbox
                    GroupboxFunctions.InnerHolder = GroupboxHolder
                    GroupboxFunctions.Elements = {}
                    GroupboxFunctions.Side = Settings.Side
                    GroupboxFunctions.Text = Settings.Name
                    function GroupboxFunctions:Resize()
                        local Size = 0
                        for _, Element in pairs(GroupboxFunctions.Elements) do
                            if Element.Holder then
                                if Element.Holder.Visible then
                                    Size += Element.Holder.AbsoluteSize.Y + 8
                                end
                            end
                        end
                        GroupboxHolder.Size = UDim2.fromOffset(GroupboxHolder.AbsoluteSize.X, Size + GroupboxTitle.TextSize + 16)
                        Groupbox.Size = UDim2.fromOffset(420, GroupboxHolder.Size.Y.Offset + 12)
                    end
                    table.insert(TabboxTabFunctions.Groupboxes, GroupboxFunctions)
                    return GroupboxFunctions
                end
                local Button = New("TextButton", {
                    Text = Name,
                    BackgroundTransparency = 1,
                    FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                    RichText = true,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = ApplyTextScale(14),
                    TextTransparency = 0.5,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    Size = UDim2.fromOffset(0, 20),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Parent = TabboxTop,
                })
                Button.MouseButton1Click:Connect(function()
                    for _, Tab in pairs(TabboxFunctions.Tabs) do
                        Tab.OuterHolder.Visible = false
                    end
                    TabboxTab.Visible = true
                    for _, Button in pairs(TabboxTop:GetChildren() do
                        if Button:IsA("TextButton") then
                            Button.TextTransparency = 0.5
                        end
                    end
                    Button.TextTransparency = 0
                    Tabbox:Resize()
                    TabFunctions:Resize(true)
                end)
                table.insert(TabboxFunctions.Tabs, TabboxTabFunctions)
                return TabboxTabFunctions
            end
            local function First()
                for _, Tab in pairs(TabboxFunctions.Tabs) do
                    Tab.OuterHolder.Visible = false
                end
                local FirstTab = TabboxFunctions.Tabs[1]
                if FirstTab then
                    FirstTab.OuterHolder.Visible = true
                    FirstTabButton = TabboxTop:FindFirstChild("TextButton")
                    if FirstTabButton then
                        FirstTabButton.TextTransparency = 0
                    end
                end
            end
            task.spawn(First)
            table.insert(TabFunctions.Tabboxes, TabboxFunctions)
            return TabboxFunctions
        end

        function TabFunctions:ButtonHolder()
            local ButtonHolderFunctions = {}
            local ButtonHolder = New("Frame", {
                Name = "ButtonHolder",
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(420, 30),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = TabFunctions.TabLeftHolder,
            })
            local ButtonHolderList = New("UIListLayout", {
                Padding = UDim.new(0, 4),
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = ButtonHolder,
            })
            ButtonHolderFunctions.Elements = {}
            ButtonHolderFunctions.Holder = ButtonHolder
            table.insert(TabFunctions.Buttons, ButtonHolderFunctions)
            return ButtonHolderFunctions
        end

        return TabFunctions
    end

    local KeyTab
    local KeyTabFunctions = {}
    function WindowFunctions:SetKeybindTab(Enabled)
        if not Enabled or KeyTab then
            return
        end
        tabIndex += 1000
        KeyTab = New("TextButton", {
            Name = "KeybindTabSwitcher",
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 400),
            Size = UDim2.new(1, -20, 0, 28),
            Parent = tabSwitchers,
        })
        New("UITextSizeConstraint", { MaxTextSize = 14, Parent = KeyTab })
        New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = KeyTab })
        local KeyTabIcon = New("ImageLabel", {
            Image = "rbxassetid://12518906759",
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(16, 16),
            Parent = KeyTab,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 4),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = KeyTab,
        })
        local KeyTabTitle = New("TextLabel", {
            Text = "Keybinds",
            FontFace = MacoriaLib.Scheme.Font,
            RichText = false,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = ApplyTextScale(14),
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Parent = KeyTab,
        })
        local KeyTabHolder = New("ScrollingFrame", {
            Name = "KeyTab",
            Active = true,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(6, 35),
            Size = UDim2.fromScale(0.972, 0.901),
            Visible = false,
            CanvasSize = UDim2.fromScale(0, 0),
            ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
            ScrollBarImageTransparency = 0.7,
            ScrollBarThickness = 3,
            Parent = content,
        })
        local KeyTabLeftHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0.5, 1),
            Parent = KeyTabHolder,
        })
        local KeyTabRightHolder = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.fromScale(0.5, 1),
            Parent = KeyTabHolder,
        })
        local KeyTabLeftHolderList = New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = KeyTabLeftHolder,
        })
        local KeyTabRightHolderList = New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = KeyTabRightHolder,
        })
        local KeyTabLeftHolderPadding = New("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            Parent = KeyTabLeftHolder,
        })
        local KeyTabRightHolderPadding = New("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            Parent = KeyTabRightHolder,
        })
        local KeybindFrame = New("Frame", {
            Name = "KeybindFrame",
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.fromOffset(4, 4),
            Size = UDim2.fromOffset(200, 0),
            Parent = KeyTabHolder,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 2),
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = KeybindFrame,
        })
        local KeybindFrameCorner = New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = KeybindFrame })
        local KeybindFrameOutline = MakeOutline(KeybindFrame, 4, 0)
        AddToRegistry(KeybindFrame, { BackgroundColor3 = "BackgroundColor" })
        MacoriaLib.KeybindFrame = KeybindFrame
        KeyTabFunctions.Holder = KeyTabHolder
        KeyTabFunctions.LeftHolder = KeyTabLeftHolder
        KeyTabFunctions.RightHolder = KeyTabRightHolder
        KeyTabFunctions.LeftHolderList = KeyTabLeftHolderList
        KeyTabFunctions.RightHolderList = KeyTabRightHolderList
        KeyTabFunctions.LeftHolderPadding = KeyTabLeftHolderPadding
        KeyTabFunctions.RightHolderPadding = KeyTabRightHolderPadding
        KeyTabFunctions.Button = KeyTab
        KeyTabFunctions.IsKeyTab = true
        function KeyTabFunctions:AddGroupbox(Settings)
            local GroupboxFunctions = {}
            local Groupbox = New("Frame", {
                Name = "Groupbox",
                BackgroundColor3 = "BackgroundColor",
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(420, 2),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = KeyTabFunctions[Settings.Side .. "Holder"],
            })
            local GroupboxCorner = New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Groupbox })
            AddToRegistry(Groupbox, { BackgroundColor3 = "BackgroundColor" })
            local OutlineHolder = MakeOutline(Groupbox, 8, 0)
            local GroupboxHolder = New("Frame", {
                Name = "GroupboxHolder",
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(6, 6),
                Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(12, 12),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = Groupbox,
            })
            local GroupboxTitle = New("TextLabel", {
                Name = "GroupboxTitle",
                FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                RichText = true,
                Text = Settings.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = ApplyTextScale(14),
                TextTransparency = 0,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                AnchorPoint = Vector2.new(0, 0),
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0, 0),
                Parent = GroupboxHolder,
            })
            local GroupboxDivider = New("Frame", {
                Name = "Divider",
                AnchorPoint = Vector2.new(0, 0),
                BackgroundColor3 = "OutlineColor",
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, GroupboxTitle.TextSize + 2),
                Size = UDim2.new(0.5, -2, 0, 1),
                Parent = GroupboxHolder,
            })
            AddToRegistry(GroupboxDivider, { BackgroundColor3 = "OutlineColor" })
            local GroupboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = GroupboxHolder,
            })
            local GroupboxPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, GroupboxTitle.TextSize + 8),
                Parent = GroupboxHolder,
            })
            GroupboxFunctions.OuterHolder = Groupbox
            GroupboxFunctions.InnerHolder = GroupboxHolder
            GroupboxFunctions.Elements = {}
            GroupboxFunctions.Side = Settings.Side
            GroupboxFunctions.Text = Settings.Name
            function GroupboxFunctions:Resize()
                local Size = 0
                for _, Element in pairs(GroupboxFunctions.Elements) do
                    if Element.Holder then
                        if Element.Holder.Visible then
                            Size += Element.Holder.AbsoluteSize.Y + 8
                        end
                    end
                end
                GroupboxHolder.Size = UDim2.fromOffset(GroupboxHolder.AbsoluteSize.X, Size + GroupboxTitle.TextSize + 16)
                Groupbox.Size = UDim2.fromOffset(420, GroupboxHolder.Size.Y.Offset + 12)
            end
            table.insert(KeyTabFunctions.Groupboxes, GroupboxFunctions)
            return GroupboxFunctions
        end
        local function Show()
            currentTab.Text = "Keybinds"
            TabFunctions.Tab.Visible = false
            for _, Tab in pairs(MacoriaLib.Tabs) do
                if Tab.Tab then
                    Tab.Tab.Visible = false
                end
            end
            KeyTabHolder.Visible = true
            MacoriaLib:UpdateSearch(MacoriaLib.SearchText)
        end
        local function UpdateOutline(Active)
            Tween(KeyTab, MacoriaLib.TweenInfo, { BackgroundTransparency = Active and 0.5 or 1}):Play()
            Tween(KeyTabIcon, MacoriaLib.TweenInfo, { ImageTransparency = Active and 0 or 0.5}):Play()
            Tween(KeyTabTitle, MacoriaLib.TweenInfo, { TextTransparency = Active and 0 or 0.5}):Play()
        end
        UpdateOutline(false)
        KeyTab.MouseEnter:Connect(function()
            UpdateOutline(true)
        end)
        KeyTab.MouseLeave:Connect(function()
            if MacoriaLib.ActiveTab ~= KeyTabHolder then
                UpdateOutline(false)
            end
        end)
        KeyTab.MouseButton1Click:Connect(function()
            Show()
            MacoriaLib.ActiveTab = KeyTabHolder
            UpdateOutline(true)
            for _, Tab in pairs(MacoriaLib.Tabs) do
                if Tab.UpdateOutline then
                    Tab.UpdateOutline(false)
                end
            end
        end)
        KeyTabFunctions.UpdateOutline = UpdateOutline
        table.insert(MacoriaLib.Tabs, KeyTabFunctions)
    end

    function WindowFunctions:ButtonHolder()
        local ButtonHolderFunctions = {}
        local ButtonHolder = New("Frame", {
            Name = "ButtonHolder",
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(420, 30),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = content,
        })
        local ButtonHolderList = New("UIListLayout", {
            Padding = UDim.new(0, 4),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = ButtonHolder,
        })
        ButtonHolderFunctions.Elements = {}
        ButtonHolderFunctions.Holder = ButtonHolder
        return ButtonHolderFunctions
    end

    function WindowFunctions:ShowNotification(...)
        MacoriaLib:ShowNotification(...)
    end

    function WindowFunctions:Toggle()
        MacoriaLib.Toggled = not MacoriaLib.Toggled
        base.Visible = MacoriaLib.Toggled
        ModalElement.Modal = MacoriaLib.Toggled
    end

    function WindowFunctions:ChangeToggleKeybind(Keybind)
        MacoriaLib.ToggleKeybind = Keybind
    end

    function WindowFunctions:ChangeKeybindFrameVisibility(Visibility)
        MacoriaLib.ShowToggleFrameInKeybinds = Visibility
        UpdateKeybindFrame()
    end

    function WindowFunctions:Unload()
        Unload()
    end

    function WindowFunctions:SetBackgroundColor(Color)
        MacoriaLib.Scheme.BackgroundColor = Color
        UpdateColorsUsingRegistry()
    end

    function WindowFunctions:SetMainColor(Color)
        MacoriaLib.Scheme.MainColor = Color
        UpdateColorsUsingRegistry()
    end

    function WindowFunctions:SetAccentColor(Color)
        MacoriaLib.Scheme.AccentColor = Color
        UpdateColorsUsingRegistry()
    end

    function WindowFunctions:SetOutlineColor(Color)
        MacoriaLib.Scheme.OutlineColor = Color
        UpdateColorsUsingRegistry()
    end

    function WindowFunctions:SetFontColor(Color)
        MacoriaLib.Scheme.FontColor = Color
        UpdateColorsUsingRegistry()
    end

    function WindowFunctions:SetFont(Font)
        MacoriaLib.Scheme.Font = Font
        UpdateColorsUsingRegistry()
    end

    function WindowFunctions:SetTheme(Theme)
        if Theme then
            MacoriaLib.Scheme = Theme
            UpdateColorsUsingRegistry()
        end
    end

    function WindowFunctions:GetTheme()
        return MacoriaLib.Scheme
    end

    function WindowFunctions:SetDPIScale(Scale)
        SetDPIScale(Scale)
    end

    function WindowFunctions:SetFolder(Folder)
        MacoriaLib.Folder = Folder
    end

    function WindowFunctions:SetWindowTitle(Title)
        title.Text = Title
    end

    function WindowFunctions:SetWindowSubtitle(Subtitle)
        subtitle.Text = Subtitle
    end

    function WindowFunctions:SetWindowIcon(Icon)
    end

    function WindowFunctions:GetWindowIcon()
        return nil
    end

    function WindowFunctions:SetWindowTitleProperty(Property, Value)
        title[Property] = Value
    end

    function WindowFunctions:CreatePrompt(PromptName, PromptText, Buttons)
        local Prompt = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "BackgroundColor",
            Size = UDim2.fromOffset(280, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = base,
            ZIndex = 101,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Prompt })
        MakeOutline(Prompt, 8, 101)
        AddToRegistry(Prompt, { BackgroundColor3 = "BackgroundColor" })
        local Overlay = New("Frame", {
            BackgroundColor3 = "Dark",
            BackgroundTransparency = 0.5,
            Size = UDim2.fromScale(1, 1),
            Parent = base,
            ZIndex = 100,
        })
        AddToRegistry(Overlay, { BackgroundColor3 = "Dark" })
        New("TextLabel", {
            FontFace = MacoriaLib.Scheme.Font,
            Text = PromptText,
            RichText = true,
            TextColor3 = MacoriaLib.Scheme.FontColor,
            TextSize = ApplyTextScale(14),
            TextWrapped = true,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 12),
            Size = UDim2.fromOffset(256, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = Prompt,
            ZIndex = 102,
        })
        local ButtonsHolder = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, -12, 0, 36),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = Prompt,
            ZIndex = 102,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 12),
            Parent = ButtonsHolder,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ButtonsHolder,
        })
        local RButtons = {}
        for _, ButtonInfo in ipairs(Buttons) do
            local Button = New("TextButton", {
                BackgroundColor3 = "MainColor",
                FontFace = MacoriaLib.Scheme.Font,
                Text = ButtonInfo.Text,
                RichText = true,
                TextColor3 = MacoriaLib.Scheme.FontColor,
                TextSize = ApplyTextScale(14),
                Size = ButtonInfo.Size or UDim2.fromOffset(120, 28),
                Parent = ButtonsHolder,
                ZIndex = 103,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Button })
            AddToRegistry(Button, { BackgroundColor3 = "MainColor" })
            MakeOutline(Button, 6, 103)
            Button.MouseButton1Click:Connect(function()
                SafeCallback(ButtonInfo.Callback)
                Prompt:Destroy()
                Overlay:Destroy()
            end)
            table.insert(RButtons, Button)
        end
        Overlay.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Prompt:Destroy()
                Overlay:Destroy()
            end
        end)
        return Prompt, Overlay, RButtons
    end

    function WindowFunctions:SaveConfig(ConfigName)
        if not ConfigName then
            return false, "No config name specified"
        end
        local FullName = ConfigName
        if string.sub(ConfigName, -5) ~= ".json" then
            FullName = FullName .. ".json"
        end
        local HttpService = MacoriaLib:GetService("HttpService")
        local JSON = HttpService:JSONEncode(MacoriaLib:SaveConfiguration())
        if not isfolder(MacoriaLib.Folder) then
            makefolder(MacoriaLib.Folder)
        end
        if not isfolder(MacoriaLib.Folder .. "/MacoriaLib") then
            makefolder(MacoriaLib.Folder .. "/MacoriaLib")
        end
        writefile(MacoriaLib.Folder .. "/MacoriaLib/" .. FullName, JSON)
        return true
    end

    function WindowFunctions:LoadConfig(ConfigName)
        if not ConfigName then
            return false, "No config name specified"
        end
        local FullName = ConfigName
        if not isfile(MacoriaLib.Folder .. "/MacoriaLib/" .. FullName .. ".json") then
            if not isfile(MacoriaLib.Folder .. "/MacoriaLib/" .. FullName) then
                return false, "Can't find specified config"
            end
            FullName = FullName
        else
            FullName = FullName .. ".json"
        end
        local HttpService = MacoriaLib:GetService("HttpService")
        local JSON = readfile(MacoriaLib.Folder .. "/MacoriaLib/" .. FullName)
        local Decoded = HttpService:JSONDecode(JSON)
        MacoriaLib:LoadConfiguration(Decoded)
        return true
    end

    function WindowFunctions:GetConfigList()
        if not isfolder(MacoriaLib.Folder) then
            makefolder(MacoriaLib.Folder)
        end
        if not isfolder(MacoriaLib.Folder .. "/MacoriaLib") then
            makefolder(MacoriaLib.Folder .. "/MacoriaLib")
        end
        local list = listfiles(MacoriaLib.Folder .. "/MacoriaLib")
        for idx, file in ipairs(list) do
            if file:sub(-5) == ".json" then
                list[idx] = file:sub(1, -6)
            end
            list[idx] = string.match(list[idx], "[^/\\]+$")
        end
        return list
    end

    function MacoriaLib:SaveConfiguration()
        local Data = {}
        for _, Option in pairs(MacoriaLib.Options) do
            local Value = Option.Value
            local Safe = true
            if Option.Type == "KeyPicker" then
                Value = { Value = Option.Value, Mode = Option.Mode }
            elseif Option.Type == "ColorPicker" then
                local Hue, Saturation, Value = Color3.toHSV(Option.Value)
                Value = { Hue = Hue, Saturation = Saturation, Value = Value, Transparency = Option.Transparency }
            end
            if Safe then
                table.insert(Data, {
                    Name = Option.Name,
                    Value = Value,
                    Type = Option.Type,
                })
            end
        end
        return Data
    end

    function MacoriaLib:LoadConfiguration(Data)
        for _, Option in pairs(MacoriaLib.Options) do
            for _, Table in pairs(Data) do
                if Table.Name ~= Option.Name then
                    continue
                end
                if Table.Type ~= Option.Type then
                    continue
                end
                if Option.Type == "KeyPicker" then
                    if Table.Value.Mode then
                        Option:SetValue(Table.Value.Value, Table.Value.Mode)
                    else
                        Option:SetValue(Table.Value)
                    end
                elseif Option.Type == "ColorPicker" then
                    local Color = Color3.fromHSV(Table.Value.Hue, Table.Value.Saturation, Table.Value.Value)
                    Option:UpdateColor(Color, Table.Value.Transparency)
                elseif Option.Type == "Input" then
                    Option:SetValue(Table.Value)
                else
                    Option:SetValue(Table.Value)
                end
                break
            end
        end
    end

    MacoriaLib.ScreenGui.DisplayOrder = 1000
    MacoriaLib.ModalScreenGui.DisplayOrder = 999
    MacoriaLib.NotifySide = WindowFunctions.Settings.NotifySide
    MacoriaLib.ShowCustomCursor = WindowFunctions.Settings.ShowCustomCursor

    local Icon
    if WindowFunctions.Settings.Icon then
        if WindowFunctions.Settings.Icon:find("rbxasset") or WindowFunctions.Settings.Icon:find("http") then
            local success, result = pcall(function()
                return game:HttpGet(WindowFunctions.Settings.Icon)
            end)
            if success then
                Icon = WindowFunctions.Settings.Icon
            end
        else
            local success, result = pcall(function()
                return game:HttpGet("https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=30&height=30&format=png")
            end)
            if success and result:find("PNG") then
                Icon = WindowFunctions.Settings.Icon
            else
                Icon = "rbxassetid://18824089198"
            end
        end
    end

    local OnInputBegan = function(Input)
        if Input.KeyCode == MacoriaLib.ToggleKeybind then
            WindowFunctions:Toggle()
        end
        if Input.KeyCode == Enum.KeyCode.G then
            MacoriaLib.CursorPosition = Input.Position
        end
    end

    local OnInputChanged = function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            MacoriaLib.CursorPosition = Input.Position
        end
    end

    local On_guifocus = function(CoreType)
        if CoreType then
            CoreType = CoreType:lower()
        end
        MacoriaLib.IsRobloxFocused = (not CoreType or CoreType == "chat" or CoreType:find("lua") or CoreType:find("gamepad"))
    end

    local On unloading = function()
        Unload()
    end

    GiveSignal(Mouse.Move:Connect(function()
        local Position = Vector2.new(Mouse.X, Mouse.Y)
        MacoriaLib.MousePosition = Position
    end))

    GiveSignal(UserInputService.InputBegan:Connect(OnInputBegan))
    GiveSignal(UserInputService.InputChanged:Connect(OnInputChanged))
    GiveSignal(UserInputService.WindowFocused:Connect(function()
        MacoriaLib.IsRobloxFocused = true
    end))
    GiveSignal(UserInputService.WindowFocusReleased:Connect(function()
        MacoriaLib.IsRobloxFocused = false
    end))
    pcall(function()
        GiveSignal(game:GetService("GuiService").GuiFocusChanged:Connect(On_guifocus))
    end)
    if not isStudio then
        pcall(function()
            GiveSignal(game.Close:Connect(unloading))
        end)
    end

    function MacoriaLib:UpdateSearch(Search)
        Search = Search:lower()
        local Total = 0
        for _, Tab in pairs(MacoriaLib.Tabs) do
            if not Tab.IsKeyTab then
                if Tab.Searchable then
                    local Groups = 0
                    for _, Groupbox in pairs(Tab.Groupboxes) do
                        local GroupCount = CheckDepbox(Groupbox, Search)
                        if GroupCount > 0 then
                            Groups += GroupCount
                        end
                    end
                    for _, Tabbox in pairs(Tab.Tabboxes) do
                        for _, SubTab in pairs(Tabbox.Tabs) do
                            for _, Groupbox in pairs(SubTab.Groupboxes) do
                                local GroupCount = CheckDepbox(Groupbox, Search)
                                if GroupCount > 0 then
                                    Groups += GroupCount
                                end
                            end
                        end
                    end
                    Tab.Tab.Visible = Groups > 0
                    if Groups > 0 and (MacoriaLib.LastSearchTab == nil or Search == "") then
                        if not MacoriaLib.LastSearchTab then
                            MacoriaLib.LastSearchTab = Tab.Tab
                        end
                        task.wait()
                        Tab:Show()
                    end
                    Total += Groups
                end
            end
        end
        if Total == 0 and (MacoriaLib.LastSearchTab and Search ~= "") then
            MacoriaLib.LastSearchTab = nil
        end
        return Total
    end

    function MacoriaLib:ShowNotification(Title, Content, Image, Duration)
        local Notification = {}
        Duration = Duration or 6
        Notification.Holder = New("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Size = UDim2.fromOffset(280, 72),
            Parent = notifications,
        })
        local NotificationFrame = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "BackgroundColor",
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1),
            Parent = Notification.Holder,
        })
        local NotificationCorner = New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = NotificationFrame })
        AddToRegistry(NotificationFrame, { BackgroundColor3 = "BackgroundColor" })
        local NotificationTitle = New("TextLabel", {
            FontFace = MacoriaLib.Scheme.Font,
            Text = Title,
            RichText = false,
            TextColor3 = MacoriaLib.Scheme.FontColor,
            TextSize = ApplyTextScale(14),
            TextStrokeTransparency = 0.8,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(44, 10),
            Size = UDim2.new(1, -54, 0, 14),
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = NotificationFrame,
        })
        local NotificationContent = New("TextLabel", {
            FontFace = MacoriaLib.Scheme.Font,
            Text = Content,
            RichText = true,
            TextColor3 = MacoriaLib.Scheme.FontColor,
            TextSize = ApplyTextScale(14),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(44, 28),
            Size = UDim2.new(1, -54, 1, -38),
            TextWrapped = true,
            Parent = NotificationFrame,
        })
        local NotificationIcon = New("ImageLabel", {
            Image = Image or "rbxassetid://16852544912",
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, 0.5),
            Size = UDim2.fromOffset(28, 28),
            Parent = NotificationFrame,
        })
        MakeOutline(NotificationFrame, 8, 0)
        Notification.Holder.Size = UDim2.fromOffset(0, 0)
        Tween(Notification.Holder, MacoriaLib.NotifyTweenInfo, { Size = UDim2.fromOffset(280, 72) }):Play()
        table.insert(MacoriaLib.Notifications, Notification)
        task.spawn(function()
            task.wait(Duration)
            Tween(Notification.Holder, MacoriaLib.NotifyTweenInfo, { Size = UDim2.fromOffset(0, 72) }):Play()
            task.wait(0.3)
            Notification.Holder:Destroy()
            for idx, Notif in pairs(MacoriaLib.Notifications) do
                if Notif == Notification then
                    table.remove(MacoriaLib.Notifications, idx)
                end
            end
        end)
    end

    function MacoriaLib:Notify(...)
        MacoriaLib:ShowNotification(...)
    end
    function MacoriaLib:SetTheme(Theme)
        if Theme then
            MacoriaLib.Scheme = Theme
            UpdateColorsUsingRegistry()
        end
    end

    MacoriaLib.Searching = false
    MacoriaLib.SearchText = ""
    MacoriaLib.Options = {}
    MacoriaLib.Tabs = {}
    MacoriaLib.DependencyBoxes = {}
    MacoriaLib.KeybindToggles = {}
    MacoriaLib.Notifications = {}
    MacoriaLib.Registry = {}
    MacoriaLib.DPIRegistry = {}
    MacoriaLib.UnloadSignals = {}
    MacoriaLib.Signals = {}
    MacoriaLib.Toggled = true
    MacoriaLib.Unloaded = false
    MacoriaLib.DPIScale = 1
    MacoriaLib.ToggleKeybind = WindowFunctions.Settings.ToggleKeybind
    MacoriaLib.NotifySide = WindowFunctions.Settings.NotifySide
    MacoriaLib.ShowCustomCursor = WindowFunctions.Settings.ShowCustomCursor
    MacoriaLib.ForceCheckbox = WindowFunctions.Settings.ForceCheckbox
    MacoriaLib.ShowToggleFrameInKeybinds = WindowFunctions.Settings.ShowToggleFrameInKeybinds
    MacoriaLib.NotifyOnError = WindowFunctions.Settings.NotifyOnError
    MacoriaLib.CantDragForced = WindowFunctions.Settings.CantDragforced
    MacoriaLib.MinSize = Vector2.new(WindowFunctions.Settings.Size.X.Offset / 3, WindowFunctions.Settings.Size.Y.Offset / 3)
    MacoriaLib.IsKeyDown = {}
    MacoriaLib.CursorPosition = Vector2.zero

    local Keyitems = {}
    for _, EnumItem in pairs(Enum.KeyCode:GetEnumItems()) do
        local keyname = EnumItem.Name:lower():gsub("left", "l"):gsub("right", "r")
        if (keyname:match("^%a$") or keyname:match("^%d$") or keyname:find("control") or keyname:find("shift") or keyname:find("alt")) and not keyname:find("unknown") then
            Keyitems[EnumItem] = keyname
        end
    end
    for _, EnumItem in pairs(Enum.UserInputType:GetEnumItems()) do
        if EnumItem.Name:find("MouseButton") then
            Keyitems[EnumItem] = EnumItem.Name:lower()
        end
    end
    for _, EnumItem in pairs(Enum.KeyCode:GetEnumItems()) do
        if EnumItem.Name:find("MouseButton") then
            Keyitems[EnumItem] = EnumItem.Name:lower()
        end
    end
    Keyitems[Enum.KeyCode.Unknown] = "none"
    Keyitems[Enum.UserInputType.Focus] = "none"

    local function MakeToggle(Option)
        local ToggleFunctions = {}
        local Toggle = New("TextButton", {
            Text = "",
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(26, 20),
            ZIndex = 2,
        })
        local ToggleFrame = New("Frame", {
            Name = "ToggleFrame",
            BackgroundColor3 = "OutlineColor",
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(36, 14),
            Position = UDim2.fromScale(1, 0.5),
            AnchorPoint = Vector2.new(1, 0.5),
            Parent = Toggle,
        })
        AddToRegistry(ToggleFrame, { BackgroundColor3 = "OutlineColor" })
        local ToggleFrameCorner = New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleFrame })
        local ToggleFrameStroke = New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0.9,
            Parent = ToggleFrame,
        })
        local ToggleHead = New("Frame", {
            Name = "ToggleHead",
            BackgroundColor3 = "White",
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(1, 1),
            Size = UDim2.fromOffset(12, 12),
            Parent = ToggleFrame,
        })
        AddToRegistry(ToggleHead, { BackgroundColor3 = "White" })
        local ToggleHeadCorner = New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleHead })
        local ToggleHeadStroke = New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0.9,
            Parent = ToggleHead,
        })
        local ToggleLabel = New("TextLabel", {
            Name = "ToggleLabel",
            FontFace = MacoriaLib.Scheme.Font,
            RichText = true,
            Text = Option.Text,
            TextColor3 = MacoriaLib.Scheme.FontColor,
            TextSize = ApplyTextScale(14),
            TextTransparency = Option.Risky and 0.2 or 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.fromScale(0, 0),
            Parent = Toggle,
        })
        local ToggleLabelHolder = New("Frame", {
            Name = "ToggleLabelHolder",
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.fromScale(1, 0) - UDim2.fromOffset(36, 0),
            Parent = Toggle,
        })
        local ToggleLabelList = New("UIListLayout", {
            Padding = UDim.new(0, 4),
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ToggleLabelHolder,
        })
        local ToggleLabelPadding = New("UIPadding", {
            PaddingTop = UDim.new(0, 3),
            Parent = ToggleLabelHolder,
        })
        local PrefixBox, SuffixBox
        if Option.Prefix then
            PrefixBox = New("TextLabel", {
                FontFace = MacoriaLib.Scheme.Font,
                Text = "<b>" .. tostring(Option.Prefix) .. "</b>",
                RichText = true,
                TextColor3 = MacoriaLib.Scheme.FontColor,
                TextSize = ApplyTextScale(14),
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = -1,
                Parent = ToggleLabelHolder,
            })
        end
        if Option.Suffix then
            SuffixBox = New("TextLabel", {
                FontFace = MacoriaLib.Scheme.Font,
                Text = "<b>" .. tostring(Option.Suffix) .. "</b>",
                RichText = true,
                TextColor3 = MacoriaLib.Scheme.FontColor,
                TextSize = ApplyTextScale(14),
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = ToggleLabelHolder,
            })
        end
        ToggleLabel.Parent = ToggleLabelHolder
        local State = false
        local AnimateToggled = false
        local function SetState(NewState, Animate)
            if Option.Disabled then
                return
            end
            State = NewState
            AnimateToggled = Animate
            Animate = Animate == nil and true or Animate
            if Animate then
                local TweenRight = Tween(ToggleHead, MacoriaLib.TweenInfo, { Position = State and UDim2.fromScale(1, 0) + UDim2.fromOffset(-13, 0) or UDim2.fromOffset(1, 1) })
                TweenRight:Play()
                local HideLerp = State and 0 or 1
                local function Lerp()
                    local Connection
                    Connection = RunService.Heartbeat:Connect(function()
                        local Transparency = 1 - (ToggleHead.Position.X.Offset / 23)
                        ToggleHeadStroke.Transparency = Transparency
                        ToggleFrameStroke.Transparency = Transparency
                        if (State and Transparency <= HideLerp) or (not State and Transparency >= HideLerp) then
                            Connection:Disconnect()
                        end
                    end)
                end
                Lerp()
            else
                ToggleHead.Position = State and UDim2.fromScale(1, 0) + UDim2.fromOffset(-13, 0) or UDim2.fromOffset(1, 1)
            end
            Tween(ToggleFrame, MacoriaLib.TweenInfo, { BackgroundColor3 = State and MacoriaLib.Scheme.AccentColor or MacoriaLib.Scheme.OutlineColor }):Play()
            UpdateDependencyBoxes()
            SafeCallback(Option.Callback, State)
            Option:Update()
        end
        
        Toggle.MouseButton1Click:Connect(function()
            SetState(not State, true)
        end)
        function ToggleFunctions:SetValue(NewState, Animate)
            SetState(NewState, Animate)
        end
        function ToggleFunctions:Update()
            if Option.Prefix or Option.Suffix then
                local DisplayValue = Option.DisplayMethod or "Value"
                local Value = State
                local Text = ""
                if DisplayValue == "Value" and Option.Precision then
                    Value = string.format("%." .. tostring(Option.Precision) .. "f", Value)
                elseif DisplayValue == "Inverted" then
                    Value = not Value
                end
                local Prefix = Option.Prefix and tostring(Option.Prefix) .. " " or ""
                local Suffix = Option.Suffix and " " .. tostring(Option.Suffix) or ""
                Text = Prefix .. tostring(Value) .. Suffix
                if PrefixBox then
                    PrefixBox.Text = "<b>" .. Prefix .. "</b>"
                end
                if SuffixBox then
                    SuffixBox.Text = "<b>" .. Suffix .. "</b>"
                end
                if Option.Domino then
                    local DominoValue = Option.Domino(Value)
                    if PrefixBox then
                        PrefixBox.Text = PrefixBox.Text .. " " .. tostring(DominoValue)
                    else
                        if SuffixBox then
                            SuffixBox.Text = " " .. tostring(DominoValue) .. SuffixBox.Text
                        end
                    end
                end
            end
        end
        SetState(Option.Default, false)
        return ToggleFunctions, Toggle
    end

    local function MakeSlider(Option)
        local SliderFunctions = {}
        local Slider = New("Frame", {
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        local SliderLabel = New("TextLabel", {
            Name = "SliderLabel",
            FontFace = MacoriaLib.Scheme.Font,
            Text = Option.Text,
            RichText = true,
            TextColor3 = MacoriaLib.Scheme.FontColor,
            TextSize = ApplyTextScale(14),
            TextTransparency = Option.Risky and 0.2 or 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = Slider,
        })
        local SliderLabelHolder = New("Frame", {
            Name = "SliderLabelHolder",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = Slider,
        })
        local SliderLabelList = New("UIListLayout", {
            Padding = UDim.new(0, 4),
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = SliderLabelHolder,
        })
        local SliderLabelPadding = New("UIPadding", {
            PaddingTop = UDim.new(0, 3),
            Parent = SliderLabelHolder,
        })
        local PrefixBox, SuffixBox
        if Option.Prefix then
            PrefixBox = New("TextLabel", {
                FontFace = MacoriaLib.Scheme.Font,
                Text = "<b>" .. tostring(Option.Prefix) .. "</b>",
                RichText = true,
                TextColor3 = MacoriaLib.Scheme.FontColor,
                TextSize = ApplyTextScale(14),
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = -1,
                Parent = SliderLabelHolder,
            })
        end
        if Option.Suffix then
            SuffixBox = New("TextLabel", {
                FontFace = MacoriaLib.Scheme.Font,
                Text = "<b>" .. tostring(Option.Suffix) .. "</b>",
                RichText = true,
                TextColor3 = MacoriaLib.Scheme.FontColor,
                TextSize = ApplyTextScale(14),
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SliderLabelHolder,
            })
        end
        SliderLabel.Parent = SliderLabelHolder
        local SliderOuter = New("Frame", {
            Name = "SliderOuter",
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 0) + UDim2.fromOffset(0, 16),
            Position = UDim2.fromScale(0, 1) + UDim2.fromOffset(0, 6),
            Parent = Slider,
        })
        AddToRegistry(SliderOuter, { BackgroundColor3 = "MainColor" })
        local SliderOuterCorner = New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = SliderOuter })
        local SliderOuterStroke = New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0.9,
            Parent = SliderOuter,
        })
        local SliderInner = New("Frame", {
            Name = "SliderInner",
            BackgroundColor3 = "AccentColor",
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            Parent = SliderOuter,
        })
        AddToRegistry(SliderInner, { BackgroundColor3 = "AccentColor" })
        local SliderInnerCorner = New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = SliderInner })
        local SliderThumb = New("Frame", {
            Name = "SliderThumb",
            BackgroundColor3 = "White",
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(1, 0) + UDim2.fromOffset(-10, -2),
            Size = UDim2.fromOffset(20, 20),
            Parent = SliderOuter,
        })
        AddToRegistry(SliderThumb, { BackgroundColor3 = "White" })
        local SliderThumbCorner = New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderThumb })
        local SliderThumbStroke = New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0.9,
            Parent = SliderThumb,
        })
        local Value = Option.Default
        local Min, Max, Rounding = Option.Min, Option.Max, Option.Rounding
        local Precise = Rounding < 1
        local function GetValueFromXOffset(X)
            local AbsSize = SliderInner.AbsoluteSize.X
            local Rel = math.clamp(X - SliderInner.AbsolutePosition.X, 0, AbsSize) / AbsSize
            local Value = Rel * (Max - Min) + Min
            if Rounding > 0 then
                Value = math.floor(Value * (10 ^ Rounding) + 0.5) / (10 ^ Rounding)
            end
            return Value
        end
        local function Update()
            local X = SliderInner.AbsoluteSize.X * ((Value - Min) / (Max - Min))
            Tween(SliderThumb, MacoriaLib.TweenInfo, { Position = UDim2.fromOffset(X - 10, -2) }):Play()
            Tween(SliderInner, MacoriaLib.TweenInfo, { Size = UDim2.fromScale((Value - Min) / (Max - Min), 1) }):Play()
            UpdateDependencyBoxes()
            Option:Update()
        end
        local function SetValue(NewValue, Animate)
            NewValue = math.clamp(NewValue, Min, Max)
            Value = NewValue
            Animate = Animate == nil and true or Animate
            if Animate then
                Update()
            else
                local X = SliderInner.AbsoluteSize.X * ((Value - Min) / (Max - Min))
                SliderThumb.Position = UDim2.fromOffset(X - 10, -2)
                SliderInner.Size = UDim2.fromScale((Value - Min) / (Max - Min), 1)
            end
            SafeCallback(Option.Callback, Value)
        end
        function SliderFunctions:SetValue(NewValue)
            SetValue(NewValue, true)
        end
        function SliderFunctions:Update()
            if Option.Prefix or Option.Suffix then
                local DisplayValue = Option.DisplayMethod or "Value"
                local CurrentValue = Value
                local Text = ""
                if DisplayValue == "Inverted" then
                    CurrentValue = (Max + Min) - CurrentValue
                elseif DisplayValue == "Centered" then
                    CurrentValue = CurrentValue - (Max + Min) / 2
                elseif DisplayValue == "Percentage" then
                    CurrentValue = (CurrentValue - Min) / (Max - Min) * 100
                end
                if Option.Precision and DisplayValue == "Value" then
                    CurrentValue = string.format("%." .. tostring(Option.Precision) .. "f", CurrentValue)
                end
                local Prefix = Option.Prefix and tostring(Option.Prefix) .. " " or ""
                local Suffix = Option.Suffix and " " .. tostring(Option.Suffix) or ""
                Text = Prefix .. tostring(CurrentValue) .. Suffix
                if PrefixBox then
                    PrefixBox.Text = "<b>" .. Prefix .. "</b>"
                end
                if SuffixBox then
                    SuffixBox.Text = "<b>" .. Suffix .. "</b>"
                end
                if Option.Domino then
                    local DominoValue = Option.Domino(Value)
                    if PrefixBox then
                        PrefixBox.Text = PrefixBox.Text .. " " .. tostring(DominoValue)
                    else
                        if SuffixBox then
                            SuffixBox.Text = " " .. tostring(DominoValue) .. SuffixBox.Text
                        end
                    end
                end
            end
        end
        SliderLabelHolder.Size = UDim2.fromScale(1, 0)
        SliderOuter.Size = UDim2.fromScale(1, 0) + UDim2.fromOffset(0, 16)
        SliderInner.Size = UDim2.fromScale((Value - Min) / (Max - Min), 1)
        SliderThumb.Position = UDim2.fromScale(1, 0) + UDim2.fromOffset(-10, -2)
        if Option.Changed then
            Option.Changed:Connect(function()
                UpdateDependencyBoxes()
            end)
        end
        local Dragging = false
        local currentInput = nil
        local inputChangedConnection = nil
        local function OnInputBegan(Input)
            if Option.Disabled then
                return
            end
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                currentInput = Input
                local Changed = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                        if inputChangedConnection then
                            inputChangedConnection:Disconnect()
                            inputChangedConnection = nil
                        end
                    end
                end)
            end
        end
        local function OnInputChanged(Input)
            if not Dragging or Option.Disabled then
                return
            end
            if Input.UserInputType == Enum.UserInputType.MouseMovement then
                local NewValue = GetValueFromXOffset(Input.Position.X)
                SetValue(NewValue)
            end
        end
        GiveSignal(SliderInner.InputBegan:Connect(OnInputBegan))
        GiveSignal(SliderOuter.InputBegan:Connect(OnInputBegan))
        GiveSignal(SliderThumb.InputBegan:Connect(OnInputBegan))
        GiveSignal(UserInputService.InputChanged:Connect(function(Input)
            if Dragging and isPointInFrame(SliderOuter, Input.Position) then
                OnInputChanged(Input)
            end
        end))
        SetValue(Value, false)
        Option:SetValue = SetValue
        SliderFunctions:SetValue = SetValue
        return SliderFunctions, Slider
    end

    local function MakeDropdown(Option)
        local DropdownFunctions = {}
        local Dropdown = New("Frame", {
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        local DropdownLabel = New("TextLabel", {
            Name = "DropdownLabel",
            FontFace = MacoriaLib.Scheme.Font,
            Text = Option.Text,
            RichText = true,
            TextColor3 = MacoriaLib.Scheme.FontColor,
            TextSize = ApplyTextScale(14),
            TextTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = Dropdown,
        })
        local DropdownOuter = New("Frame", {
            Name = "DropdownOuter",
            BackgroundColor3 = "MainColor",
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0, 1) + UDim2.fromOffset(0, 6),
            Size = UDim2.fromScale(1, 0) + UDim2.fromOffset(0, 24),
            Parent = Dropdown,
        })
        AddToRegistry(DropdownOuter, { BackgroundColor3 = "MainColor" })
        local DropdownCorner = New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = DropdownOuter })
        local DisplayFrame = New("Frame", {
            Name = "DisplayFrame",
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            Parent = DropdownOuter,
        })
        local DisplayText = New("TextLabel", {
            Name = "DisplayText",
            FontFace = MacoriaLib.Scheme.Font,
            Text = Option.AllowNull and "None" or tostring(Option.Values[1]),
            RichText = true,
            TextColor3 = MacoriaLib.Scheme.FontColor,
            TextSize = ApplyTextScale(14),
            TextTransparency = 0.3,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(6, 0),
            Size = UDim2.new(1, -42, 1, 0),
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = DisplayFrame,
        })
        local DropdownButton = New("ImageButton", {
            Image = assets.dropdown,
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(1, 0.5) + UDim2.fromOffset(-4, 0),
            Size = UDim2.fromOffset(20, 20),
            Parent = DisplayFrame,
        })
        local DropdownDisabledValues = Option.DisabledValues or {}
        local Values = Option.Values or {}
        local Multiselect = Option.Multi or false
        local Selected
        local ValuesList = {}
        if Multiselect then
            Selected = {}
            for _, Value in pairs(Values) do
                Selected[Value] = false
            end
        else
            Selected = Option.AllowNull and nil or Values[1]
        end
        local DropdownList = New("ScrollingFrame", {
            Active = true,
            BackgroundColor3 = "MainColor",
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0, 1) + UDim2.fromOffset(0, 2),
            Size = UDim2.fromScale(1, 0),
            CanvasSize = UDim2.fromScale(1, 0),
            ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
            ScrollBarImageTransparency = 0.7,
            ScrollBarThickness = 3,
            Visible = false,
            ZIndex = 4,
            Parent = DropdownOuter,
        })
        AddToRegistry(DropdownList, { BackgroundColor3 = "MainColor" })
        local DropdownListCorner = New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = DropdownList })
        local DropdownListLayout = New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = DropdownList,
        })
        local DropdownListPadding = New("UIPadding", {
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 2),
            Parent = DropdownList,
        })
        local Showing = false
        local MaxItems = Option.MaxVisibleDropdownItems or 8
        local function UpdateDropdownList()
            local OptionCount = 0
            for _, _ in pairs(Values) do OptionCount += 1 end
            local Height = OptionCount * 24 + 4
            if OptionCount > MaxItems then
                Height = MaxItems * 24 + 4
            end
            DropdownList.Size = UDim2.fromScale(1, 0) + UDim2.fromOffset(0, Height)
            DropdownList.CanvasSize = UDim2.fromScale(1, 0) + UDim2.fromOffset(0, OptionCount * 24 + 4)
        end
        UpdateDropdownList()
        local function AddValue(Value)
            local ValueLabel = New("TextLabel", {
                FontFace = MacoriaLib.Scheme.Font,
                Text = Value,
                RichText = true,
                TextColor3 = MacoriaLib.Scheme.FontColor,
                TextSize = ApplyTextScale(14),
                TextTransparency = 0.3,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0) + UDim2.fromOffset(0, 24),
                TextTruncate = Enum.TextTruncate.AtEnd,
                LayoutOrder = #ValuesList,
                Parent = DropdownList,
                ZIndex = 5,
            })
            local ValueButton = New("TextButton", {
                Text = "",
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = ValueLabel,
            })
            ValueButton.MouseButton1Click:Connect(function()
                if table.find(DropdownDisabledValues, Value) then
                    return
                end
                if Multiselect then
                    Selected[Value] = not Selected[Value]
                    local Text = ""
                    local Count = 0
                    for _, v in pairs(Selected) do
                        if v then
                            Count += 1
                        end
                    end
                    if Count == 0 then
                        Text = "None"
                    else
                        local Added = 0
                        for V, B in pairs(Selected) do
                            if B then
                                Added += 1
                                Text = Text .. V .. (Added < Count and ", " or "")
                            end
                        end
                    end
                    DisplayText.Text = Text
                else
                    Selected = Value
                    DisplayText.Text = Value
                    task.wait()
                    Showing = false
                    DropdownList.Visible = false
                    Tween(DisplayText, MacoriaLib.TweenInfo, { TextTransparency = 0.3 }):Play()
                end
                UpdateDependencyBoxes()
                SafeCallback(Option.Callback, Value)
                Option:Update()
            end)
            ValueButton.MouseEnter:Connect(function()
                if table.find(DropdownDisabledValues, Value) then
                    return
                end
                if not Multiselect or not Selected[Value] then
                    Tween(ValueLabel, MacoriaLib.TweenInfo, { TextTransparency = 0 }):Play()
                end
            end)
            ValueButton.MouseLeave:Connect(function()
                if table.find(DropdownDisabledValues, Value) then
                    return
                end
                local Transparency = (Multiselect and Selected[Value]) and 0 or 0.3
                Tween(ValueLabel, MacoriaLib.TweenInfo, { TextTransparency = Transparency }):Play()
            end)
            
            if Multiselect then
                local Checkmark = New("TextLabel", {
                    FontFace = MacoriaLib.Scheme.Font,
                    Text = "✓",
                    RichText = true,
                    TextColor3 = MacoriaLib.Scheme.FontColor,
                    TextSize = ApplyTextScale(14),
                    TextTransparency = 0,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Parent = ValueLabel,
                    ZIndex = 6,
                })
                local function UpdateCheckmark()
                    Checkmark.Visible = Selected[Value]
                end
                UpdateCheckmark()
                table.insert(ValuesList, UpdateCheckmark)
            else
                table.insert(ValuesList, ValueLabel)
            end
        end

        for _, Value in pairs(Values) do
            AddValue(Value)
        end

        local function UpdateDropdown()
            if Option.SpecialType == "PlayerList" then
                for _, Player in pairs(Players:GetPlayers()) do
                    if not table.find(Values, Player.Name) then
                        AddValue(Player.Name)
                    end
                end
            elseif Option.SpecialType == "TeamList" then
                for _, Team in pairs(game:GetService("Teams"):GetTeams()) do
                    if not table.find(Values, Team.Name) then
                        AddValue(Team.Name)
                    end
                end
            end
        end

        DropdownButton.MouseButton1Click:Connect(function()
            if Option.Disabled then
                return
            end
            Showing = not Showing
            DropdownList.Visible = Showing
            Tween(DisplayText, MacoriaLib.TweenInfo, { TextTransparency = Showing and 0 or 0.3 }):Play()
            UpdateDropdownList()
        end)

        UserInputService.InputBegan:Connect(function(Input)
            if Showing and Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local MousePos = Vector2.new(Mouse.X, Mouse.Y)
                if not isPointInFrame(DropdownOuter, MousePos) then
                    Showing = false
                    DropdownList.Visible = false
                    Tween(DisplayText, MacoriaLib.TweenInfo, { TextTransparency = 0.3 }):Play()
                end
            end
        end)

        function DropdownFunctions.SetValues(NewValues)
            Values = NewValues
            for _, v in ipairs(DropdownList:GetChildren()) do
                if v:IsA("TextLabel") then
                    v:Destroy()
                end
            end
            ValuesList = {}
            if Multiselect then
                Selected = {}
                for _, Value in pairs(Values) do
                    Selected[Value] = false
                end
            else
                Selected = Option.AllowNull and nil or Values[1]
                DisplayText.Text = Selected or "None"
            end
            for _, Value in pairs(Values) do
                AddValue(Value)
            end
            UpdateDropdownList()
        end

        function DropdownFunctions:AddValue(Value)
            if not table.find(Values, Value) then
                table.insert(Values, Value)
                AddValue(Value)
                UpdateDropdownList()
            end
        end

        function DropdownFunctions:RemoveValue(Value)
            local Index = table.find(Values, Value)
            if Index then
                table.remove(Values, Index)
                for _, v in ipairs(DropdownList:GetChildren()) do
                    if v:IsA("TextLabel") and v.Text == Value then
                        v:Destroy()
                        break
                    end
                end
                UpdateDropdownList()
                if not Multiselect and Selected == Value then
                    Selected = Option.AllowNull and nil or Values[1]
                    DisplayText.Text = Selected or "None"
                end
            end
        end

        function DropdownFunctions:SetValue(NewValue)
            if Multiselect then
                Selected = {}
                for _, Value in pairs(NewValue) do
                    Selected[Value] = true
                end
                local Text = ""
                local Count = 0
                for _, v in pairs(Selected) do
                    if v then
                        Count += 1
                    end
                end
                if Count == 0 then
                    Text = "None"
                else
                    local Added = 0
                    for V, B in pairs(Selected) do
                        if B then
                            Added += 1
                            Text = Text .. V .. (Added < Count and ", " or "")
                        end
                    end
                end
                DisplayText.Text = Text
            else
                if Option.AllowNull and NewValue == nil then
                    Selected = nil
                    DisplayText.Text = "None"
                else
                    Selected = NewValue
                    DisplayText.Text = NewValue
                end
            end
            UpdateDependencyBoxes()
        end

        function DropdownFunctions:Update()
        end

        function DropdownFunctions:RecalculateListSize()
            UpdateDropdownList()
        end

        if Option.Default ~= nil then
            DropdownFunctions:SetValue(Option.Default)
        end

        Option.SetValue = DropdownFunctions.SetValue
        Option.SetValues = DropdownFunctions.SetValues
        Option.AddValue = DropdownFunctions.AddValue
        Option.RemoveValue = DropdownFunctions.RemoveValue
        Option.RecalculateListSize = DropdownFunctions.RecalculateListSize

        return DropdownFunctions, Dropdown
    end

    local function MakeInput(Option)
        local InputFunctions = {}
        local Input = New("Frame", {
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        local InputLabel = New("TextLabel", {
            Name = "InputLabel",
            FontFace = MacoriaLib.Scheme.Font,
            Text = Option.Text,
            RichText = true,
            TextColor3 = MacoriaLib.Scheme.FontColor,
            TextSize = ApplyTextScale(14),
            TextTransparency = Option.Risky and 0.2 or 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = Input,
        })
        local InputBox = New("TextBox", {
            Name = "InputBox",
            ClearTextOnFocus = Option.ClearTextOnFocus,
            FontFace = MacoriaLib.Scheme.Font,
            PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
            PlaceholderText = Option.Placeholder or "",
            RichText = false,
            Text = tostring(Option.Default),
            TextColor3 = MacoriaLib.Scheme.FontColor,
            TextSize = ApplyTextScale(14),
            TextTransparency = 0.3,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            BackgroundColor3 = "MainColor",
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0, 1) + UDim2.fromOffset(0, 6),
            Size = UDim2.fromScale(1, 0) + UDim2.fromOffset(0, 28),
            Parent = Input,
        })
        AddToRegistry(InputBox, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor" })
        local InputBoxCorner = New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = InputBox })
        local InputBoxStroke = New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0.9,
            Parent = InputBox,
        })
        local Value = Option.Default
        local function SetValue(NewValue)
            NewValue = tostring(NewValue)
            Value = NewValue
            InputBox.Text = NewValue
            UpdateDependencyBoxes()
            SafeCallback(Option.Callback, Value)
            Option:Update()
        end
        function InputFunctions:SetValue(NewValue)
            SetValue(NewValue)
        end
        function InputFunctions:Update()
        end
        InputBox.Focused:Connect(function()
            Tween(InputBox, MacoriaLib.TweenInfo, { TextTransparency = 0 }):Play()
        end)
        InputBox.FocusLost:Connect(function(Enter)
            local NewValue = InputBox.Text
            if Option.Numeric then
                NewValue = tonumber(NewValue) or Value
                if Option.Rounding then
                    NewValue = math.floor(NewValue * (10 ^ Option.Rounding) + 0.5) / (10 ^ Option.Rounding)
                end
            end
            if not Option.AllowEmpty and (NewValue == "" or (Option.Numeric and tonumber(NewValue) == nil)) then
                NewValue = Value
            end
            if Option.AcceptedCharacters ~= "All" then
                local Filtered = ""
                for c in NewValue:gmatch(Option.AcceptedCharacters) do
                    Filtered = Filtered .. c
                end
                NewValue = Filtered
            end
            if Option.CharacterLimit and #NewValue > Option.CharacterLimit then
                NewValue = NewValue:sub(1, Option.CharacterLimit)
            end
            if not Option.Finished or Enter then
                SetValue(NewValue)
            end
            Tween(InputBox, MacoriaLib.TweenInfo, { TextTransparency = 0.3 }):Play()
        end)
        InputBox:GetPropertyChangedSignal("Text"):Connect(function()
            if not Option.Finished then
                SetValue(InputBox.Text)
            end
            if Option.onChanged then
                SafeCallback(Option.onChanged, InputBox.Text)
            end
        end)
        Option:SetValue = SetValue
        InputFunctions:SetValue = SetValue
        return InputFunctions, Input
    end

    local function MakeKeyPicker(Option)
        local KeyPickerFunctions = {}
        local KeyPicker = New("Frame", {
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        local KeyPickerLabel = New("TextLabel", {
            Name = "KeyPickerLabel",
            FontFace = MacoriaLib.Scheme.Font,
            Text = Option.Text,
            RichText = true,
            TextColor3 = MacoriaLib.Scheme.FontColor,
            TextSize = ApplyTextScale(14),
            TextTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = KeyPicker,
        })
        local KeyPickerOuter = New("Frame", {
            Name = "KeyPickerOuter",
            BackgroundColor3 = "MainColor",
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(1, 0),
            AnchorPoint = Vector2.new(1, 0),
            Size = UDim2.fromOffset(80, 28),
            Parent = KeyPicker,
        })
        AddToRegistry(KeyPickerOuter, { BackgroundColor3 = "MainColor" })
        local KeyPickerCorner = New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = KeyPickerOuter })
        local KeyPickerStroke = New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0.9,
            Parent = KeyPickerOuter,
        })
        local KeyPickerButton = New("TextButton", {
            Text = "<b>" .. tostring(Option.Default) .. "</b>",
            FontFace = MacoriaLib.Scheme.Font,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = KeyPickerOuter,
        })
        KeyPickerLabel.Position = UDim2.fromScale(0, 0)
        KeyPickerOuter.Position = UDim2.fromScale(1, 0) + UDim2.fromOffset(0, -4)
        local WrappedModeObjects = {}
        local function UpdateToggleFrame()
            if not MacoriaLib.ShowToggleFrameInKeybinds then
                return
            end
            local ToggleFrame = nil
            for _, Object in pairs(WrappedModeObjects) do
                Object:Destroy()
            end
            WrappedModeObjects = {}
            if Option.Mode == "Toggle" then
                ToggleFrame = New("Frame", {
                    Name = "ToggleFrame",
                    BackgroundColor3 = "MainColor",
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromOffset(30, 16),
                    Position = UDim2.fromScale(1, 1) + UDim2.fromOffset(0, 6),
                    Parent = KeyPicker,
                })
                AddToRegistry(ToggleFrame, { BackgroundColor3 = "MainColor" })
                local ToggleFrameCorner = New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleFrame })
                local ToggleFrameStroke = New("UIStroke", {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = Color3.fromRGB(255, 255, 255),
                    Transparency = 0.9,
                    Parent = ToggleFrame,
                })
                local ToggleHead = New("Frame", {
                    Name = "ToggleHead",
                    BackgroundColor3 = "White",
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(1, 1),
                    Size = UDim2.fromOffset(12, 12),
                    Parent = ToggleFrame,
                })
                AddToRegistry(ToggleHead, { BackgroundColor3 = "White" })
                local ToggleHeadCorner = New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleHead })
                local ToggleHeadStroke = New("UIStroke", {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = Color3.fromRGB(255, 255, 255),
                    Transparency = 0.9,
                    Parent = ToggleHead,
                })
                local ToggleState = false
                local function UpdateToggle()
                    Tween(ToggleHead, MacoriaLib.TweenInfo, {
                        Position = ToggleState and UDim2.fromScale(1, 0) + UDim2.fromOffset(-13, 1) or UDim2.fromOffset(1, 1)
                    }):Play()
                    Tween(ToggleFrame, MacoriaLib.TweenInfo, {
                        BackgroundColor3 = ToggleState and MacoriaLib.Scheme.AccentColor or MacoriaLib.Scheme.MainColor
                    }):Play()
                end
                UpdateToggle()
                ToggleFrame.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        ToggleState = not ToggleState
                        UpdateToggle()
                        MacoriaLib.KeybindToggles[Option.Name].ToggleState = ToggleState
                    end
                end)
                MacoriaLib.KeybindToggles[Option.Name].ToggleFrame = ToggleFrame
                MacoriaLib.KeybindToggles[Option.Name].ToggleState = false
                table.insert(WrappedModeObjects, ToggleFrame)
            end
            UpdateKeybindFrame()
        end
        if MacoriaLib.ShowToggleFrameInKeybinds then
            UpdateToggleFrame()
        end
        local ValueChanged = Instance.new("BindableEvent")
        local Value = Option.Default
        local Mode = Option.Mode or "Toggle"
        local Modes = Option.Modes or { "Always", "Toggle", "Hold" }
        Mode = table.find(Modes, Mode) and Mode or Modes[1]
        local Binded = Instance.new("BindableEvent")
        local Time = 0
        local function SetValue(NewValue)
            Value = NewValue
            KeyPickerButton.Text = "<b>" .. tostring(NewValue) .. "</b>"
            UpdateDependencyBoxes()
            SafeCallback(Option.Callback, NewValue)
            ValueChanged:Fire(NewValue)
            Option:Update()
        end
        local function SetMode(NewMode)
            Mode = NewMode
            UpdateToggleFrame()
        end
        local function OnInput(Input, GameProcessed)
            if GameProcessed then
                return
            end
            if Input.UserInputType == Enum.UserInputType.Keyboard then
                if Input.KeyCode == Enum.KeyCode.Backspace then
                    SetValue("None")
                    Binded:Fire("None")
                elseif Input.KeyCode ~= Enum.KeyCode.Unknown then
                    local Key = Keyitems[Input.KeyCode] or Input.KeyCode.Name
                    SetValue(Key)
                    Binded:Fire(Key)
                end
            elseif Input.UserInputType.Name:find("MouseButton") then
                local Key = Input.UserInputType.Name
                SetValue(Key)
                Binded:Fire(Key)
            end
        end
        local function OnRelease(Input, GameProcessed)
            if GameProcessed then
                return
            end
            if Input.UserInputType == Enum.UserInputType.Keyboard or Input.UserInputType.Name:find("MouseButton") then
                Time = 0
            end
        end
        local function OnUpdate(Input, GameProcessed)
            if GameProcessed then
                return
            end
            if Input.UserInputType == Enum.UserInputType.Keyboard or Input.UserInputType.Name:find("MouseButton") then
                Time += RunService.Heartbeat:Wait()
                if Option.onBindHeld then
                    SafeCallback(Option.onBindHeld, Value, Time)
                end
            end
        end
        local lastInput = nil
        KeyPickerButton.MouseButton1Click:Connect(function()
            KeyPickerButton.Text = "<b>Press a key</b>"
            local Connection
            Connection = UserInputService.InputBegan:Connect(function(Input)
                OnInput(Input, false)
                Connection:Disconnect()
            end)
            task.wait(5)
            if Connection and Connection.Connected then
                Connection:Disconnect()
                KeyPickerButton.Text = "<b>" .. tostring(Value) .. "</b>"
            end
        end)
        local function ListenForBind()
            local Connection
            Connection = ValueChanged.Event:Connect(function(NewValue)
                if NewValue == "None" then
                    MacoriaLib.KeybindToggles[Option.Name] = nil
                else
                    MacoriaLib.KeybindToggles[Option.Name] = {
                        Label = KeyPickerLabel,
                        Key = NewValue,
                        Mode = Mode,
                        Value = false,
                        ToggleState = false,
                    }
                end
                UpdateKeybindFrame()
            end)
            local InputBeganConnection = UserInputService.InputBegan:Connect(function(Input, GameProcessed)
                if Value == "None" then
                    return
                end
                local Key = Keyitems[Input.KeyCode] or (Input.UserInputType.Name:find("MouseButton") and Input.UserInputType.Name)
                if Key == Value then
                    if Option.Mode == "Hold" then
                        MacoriaLib.KeybindToggles[Option.Name].Value = true
                        lastInput = Input
                        while MacoriaLib.KeybindToggles[Option.Name].Value do
                            OnUpdate(lastInput, false)
                            task.wait()
                        end
                    elseif Option.Mode == "Toggle" then
                        MacoriaLib.KeybindToggles[Option.Name].Value = not MacoriaLib.KeybindToggles[Option.Name].Value
                        if MacoriaLib.KeybindToggles[Option.Name].Value then
                            lastInput = Input
                            while MacoriaLib.KeybindToggles[Option.Name].Value do
                                OnUpdate(lastInput, false)
                                task.wait()
                            end
                        end
                    elseif Option.Mode == "Always" then
                        OnUpdate(Input, false)
                    end
                end
            end)
            local InputEndedConnection = UserInputService.InputEnded:Connect(function(Input, GameProcessed)
                if Value == "None" then
                    return
                end
                local Key = Keyitems[Input.KeyCode] or (Input.UserInputType.Name:find("MouseButton") and Input.UserInputType.Name)
                if Key == Value and Mode == "Hold" then
                    MacoriaLib.KeybindToggles[Option.Name].Value = false
                end
            end)
        end
        ListenForBind()
        ValueChanged:Fire(Value)
        function KeyPickerFunctions:SetValue(NewValue)
            SetValue(NewValue)
        end
        function KeyPickerFunctions:Update()
            KeyPickerButton.Text = "<b>" .. tostring(Value) .. "</b>"
        end
        Option.Update = KeyPickerFunctions.Update
        Option.SetMode = SetMode
        Option.SetValue = SetValue
        Option.Mode = Mode
        return KeyPickerFunctions, KeyPicker
    end

    local function MakeColorPicker(Option)
        local ColorPickerFunctions = {}
        local ColorPicker = New("Frame", {
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        local ColorPickerLabel = New("TextLabel", {
            Name = "ColorPickerLabel",
            FontFace = MacoriaLib.Scheme.Font,
            Text = Option.Text,
            RichText = true,
            TextColor3 = MacoriaLib.Scheme.FontColor,
            TextSize = ApplyTextScale(14),
            TextTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = ColorPicker,
        })
        local DefaultColor = Option.Default or Color3.new(1, 1, 1)
        local DefaultTransparency = Option.Transparency or 0
        local ColorPickerButton = New("TextButton", {
            Text = "",
            BackgroundColor3 = DefaultColor,
            BorderColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 2,
            Position = UDim2.fromScale(1, 0) + UDim2.fromOffset(-4, 0),
            AnchorPoint = Vector2.new(1, 0),
            Size = UDim2.fromOffset(40, 20),
            Parent = ColorPicker,
        })
        AddToRegistry(ColorPickerButton, { BackgroundColor3 = "AccentColor", BorderColor3 = "OutlineColor" })
        local ColorPickerFrame = New("Frame", {
            Name = "ColorPickerFrame",
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = "BackgroundColor",
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(1, 1) + UDim2.fromOffset(0, 2),
            Size = UDim2.fromOffset(0, 0),
            Visible = false,
            Parent = ColorPicker,
        })
        local ColorPickerFrameCorner = New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = ColorPickerFrame })
        AddToRegistry(ColorPickerFrame, { BackgroundColor3 = "BackgroundColor" })
        local ColorPickerFrameOutline = MakeOutline(ColorPickerFrame, 8, 0)
        local Hue, Saturation, Value = Color3.toHSV(DefaultColor)
        local Transparency = DefaultTransparency
        local function UpdateColor(NewColor, NewTransparency)
            Hue, Saturation, Value = Color3.toHSV(NewColor)
            Transparency = NewTransparency or Transparency
            ColorPickerButton.BackgroundColor3 = NewColor
            SafeCallback(Option.Callback, NewColor, Transparency)
        end
        local function UpdateHue(NewHue)
            Hue = NewHue
            local NewColor = Color3.fromHSV(Hue, Saturation, Value)
            ColorPickerButton.BackgroundColor3 = NewColor
            SafeCallback(Option.Callback, NewColor, Transparency)
        end
        local function UpdateSV(NewSaturation, NewValue)
            Saturation = NewSaturation
            Value = NewValue
            local NewColor = Color3.fromHSV(Hue, Saturation, Value)
            ColorPickerButton.BackgroundColor3 = NewColor
            SafeCallback(Option.Callback, NewColor, Transparency)
        end
        local function UpdateTransparency(NewTransparency)
            Transparency = NewTransparency
            SafeCallback(Option.Callback, ColorPickerButton.BackgroundColor3, Transparency)
        end
        local Wheel
        local WheelCursor
        local HueSlider
        local HueSliderCursor
        local TransparencySlider
        local TransparencySliderCursor
        local function CreatePicker()
            local PickerLayout = New("UIListLayout", {
                Padding = UDim.new(0, 12),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = ColorPickerFrame,
            })
            local PickerPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, 12),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 12),
                Parent = ColorPickerFrame,
            })
            local SVFrame = New("Frame", {
                Name = "SVFrame",
                BackgroundColor3 = DefaultColor,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(140, 140),
                Parent = ColorPickerFrame,
            })
            local SVFrameCorner = New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SVFrame })
            local SFrame = New("Frame", {
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                Parent = SVFrame,
            })
            local VFrame = New("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                Parent = SFrame,
            })
            Wheel = New("ImageLabel", {
                Image = assets.colorWheel,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = VFrame,
            })
            WheelCursor = New("Frame", {
                BackgroundColor3 = "White",
                BorderColor3 = "Dark",
                BorderSizePixel = 2,
                Position = UDim2.fromScale(Saturation, 1 - Value) + UDim2.fromOffset(-6, -6),
                Size = UDim2.fromOffset(12, 12),
                Parent = Wheel,
            })
            AddToRegistry(WheelCursor, { BackgroundColor3 = "White", BorderColor3 = "Dark" })
            local HueFrame = New("Frame", {
                Name = "HueFrame",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(1, 0) + UDim2.fromOffset(12, 0),
                Size = UDim2.fromOffset(20, 140),
                Parent = SVFrame,
            })
            local HueFrameCorner = New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = HueFrame })
            HueSlider = New("ImageLabel", {
                Image = "rbxassetid://6215455046",
                BackgroundTransparency = 1,
                ScaleType = Enum.ScaleType.Stretch,
                Size = UDim2.fromScale(1, 1),
                Parent = HueFrame,
            })
            HueSliderCursor = New("Frame", {
                BackgroundColor3 = "White",
                BorderColor3 = "Dark",
                BorderSizePixel = 2,
                Position = UDim2.fromScale(0.5, Hue) + UDim2.fromOffset(-8, -2),
                Size = UDim2.fromOffset(20, 4),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Parent = HueSlider,
            })
            AddToRegistry(HueSliderCursor, { BackgroundColor3 = "White", BorderColor3 = "Dark" })
            local TransparencyFrame = New("Frame", {
                Name = "TransparencyFrame",
                BackgroundColor3 = DefaultColor,
                BackgroundTransparency = Transparency,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(140, 16),
                Parent = ColorPickerFrame,
            })
            local TransparencyFrameCorner = New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TransparencyFrame })
            local TransparencyFrameImage = New("ImageLabel", {
                Image = assets.grid,
                BackgroundTransparency = 1,
                ScaleType = Enum.ScaleType.Tile,
                TileSize = UDim2.fromOffset(16, 16),
                Size = UDim2.fromScale(1, 1),
                Parent = TransparencyFrame,
            })
            local TransparencySlider = New("Frame", {
                Name = "TransparencySlider",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(140, 16),
                Parent = TransparencyFrame,
            })
            local TransparencySliderCorner = New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TransparencySlider })
            local TransparencySliderImage = New("ImageLabel", {
                Image = "rbxassetid://6215455046",
                BackgroundTransparency = 1,
                ScaleType = Enum.ScaleType.Stretch,
                Size = UDim2.fromScale(1, 1),
                Parent = TransparencySlider,
            })
            TransparencySliderCursor = New("Frame", {
                BackgroundColor3 = "White",
                BorderColor3 = "Dark",
                BorderSizePixel = 2,
                Position = UDim2.fromScale(1 - Transparency, 0.5) + UDim2.fromOffset(-2, -6),
                Size = UDim2.fromOffset(4, 20),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Parent = TransparencySlider,
            })
            AddToRegistry(TransparencySliderCursor, { BackgroundColor3 = "White", BorderColor3 = "Dark" })
            local function UpdateSV(Input)
                local Pos = Input.Position
                local X = math.clamp((Pos.X - Wheel.AbsolutePosition.X) / Wheel.AbsoluteSize.X, 0, 1)
                local Y = math.clamp((Pos.Y - Wheel.AbsolutePosition.Y) / Wheel.AbsoluteSize.Y, 0, 1)
                WheelCursor.Position = UDim2.fromScale(X, Y) + UDim2.fromOffset(-6, -6)
                UpdateSV(X, 1 - Y)
            end
            local function UpdateHue(Input)
                local Pos = Input.Position
                local Y = math.clamp((Pos.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
                HueSliderCursor.Position = UDim2.fromScale(0.5, Y) + UDim2.fromOffset(0, -2)
                UpdateHue(Y)
            end
            local function UpdateTransparency(Input)
                local Pos = Input.Position
                local X = math.clamp((Pos.X - TransparencySlider.AbsolutePosition.X) / TransparencySlider.AbsoluteSize.X, 0, 1)
                TransparencySliderCursor.Position = UDim2.fromScale(X, 0.5) + UDim2.fromOffset(-2, -6)
                UpdateTransparency(1 - X)
            end
            Wheel.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local Connection
                    Connection = UserInputService.InputChanged:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseMovement then
                            UpdateSV(Input)
                        end
                    end)
                    local Disconnect
                    Disconnect = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Connection:Disconnect()
                            Disconnect:Disconnect()
                        end
                    end)
                    UpdateSV(Input)
                end
            end)
            HueSlider.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local Connection
                    Connection = UserInputService.InputChanged:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseMovement then
                            UpdateHue(Input)
                        end
                    end)
                    local Disconnect
                    Disconnect = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Connection:Disconnect()
                            Disconnect:Disconnect()
                        end
                    end)
                    UpdateHue(Input)
                end
            end)
            TransparencySlider.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local Connection
                    Connection = UserInputService.InputChanged:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseMovement then
                            UpdateTransparency(Input)
                        end
                    end)
                    local Disconnect
                    Disconnect = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Connection:Disconnect()
                            Disconnect:Disconnect()
                        end
                    end)
                    UpdateTransparency(Input)
                end
            end)
            ColorPickerFrame.Size = UDim2.fromOffset(164, 210)
        end
        CreatePicker()
        ColorPickerButton.MouseButton1Click:Connect(function()
            ColorPickerFrame.Visible = not ColorPickerFrame.Visible
            Tween(ColorPickerFrame, MacoriaLib.TweenInfo, { Size = ColorPickerFrame.Visible and UDim2.fromOffset(164, 210) or UDim2.fromOffset(0, 0) }):Play()
        end)
        function ColorPickerFunctions:UpdateColor(NewColor, NewTransparency)
            Hue, Saturation, Value = Color3.toHSV(NewColor)
            Transparency = NewTransparency or Transparency
            ColorPickerButton.BackgroundColor3 = NewColor
            ColorPickerButton.BackgroundTransparency = Transparency
            local X = Saturation * Wheel.AbsoluteSize.X
            local Y = (1 - Value) * Wheel.AbsoluteSize.Y
            WheelCursor.Position = UDim2.fromOffset(X - 6, Y - 6)
            HueSliderCursor.Position = UDim2.fromScale(0.5, Hue) + UDim2.fromOffset(0, -2)
            TransparencySliderCursor.Position = UDim2.fromScale(1 - Transparency, 0.5) + UDim2.fromOffset(-2, -6)
            SFrame.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
            TransparencyFrame.BackgroundColor3 = NewColor
        end
        function ColorPickerFunctions:Update()
            ColorPickerButton.BackgroundColor3 = Option.Value or DefaultColor
        end
        ColorPickerFrame.Size = UDim2.fromOffset(0, 0)
        return ColorPickerFunctions, ColorPicker
    end

    local function MakeLabel(Groupbox, Name)
        local LabelFunctions = {}
        local Label = New("TextLabel", {
            Name = Name,
            FontFace = MacoriaLib.Scheme.Font,
            Text = Name,
            RichText = true,
            TextColor3 = MacoriaLib.Scheme.FontColor,
            TextSize = ApplyTextScale(14),
            TextTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = Groupbox.InnerHolder,
            ZIndex = 0,
        })
        function LabelFunctions:Update()
        end
        return LabelFunctions, Label
    end

    local function MakeDivider(Groupbox)
        local DividerFunctions = {}
        local Divider = New("Frame", {
            Name = "Divider",
            BackgroundTransparency = 0.9,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            Parent = Groupbox.InnerHolder,
        })
        local DividerText = New("TextLabel", {
            FontFace = MacoriaLib.Scheme.Font,
            Text = "",
            RichText = true,
            TextColor3 = MacoriaLib.Scheme.FontColor,
            TextSize = ApplyTextScale(14),
            TextTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0, 0),
            AutomaticSize = Enum.AutomaticSize.XY,
            Parent = Divider,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 4),
            PaddingTop = UDim.new(0, 4),
            Parent = Divider,
        })
        function DividerFunctions:Update()
        end
        return DividerFunctions, Divider
    end

    local function MakeButton(Option)
        local ButtonFunctions = {}
        local Button = New("TextButton", {
            Text = "",
            BackgroundColor3 = Option.Risky and Color3.fromRGB(255, 50, 50) or "MainColor",
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(0, 32),
            AutomaticSize = Enum.AutomaticSize.X,
            Parent = Option.ButtonHolder and Option.ButtonHolder.Holder or Option.Groupbox.InnerHolder,
        })
        local ButtonCorner = New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Button })
        AddToRegistry(Button, { BackgroundColor3 = Option.Risky and "Red" or "MainColor" })
        local ButtonStroke = New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0.9,
            Parent = Button,
        })
        local ButtonLabel = New("TextLabel", {
            FontFace = MacoriaLib.Scheme.Font,
            Text = Option.Name,
            RichText = true,
            TextColor3 = MacoriaLib.Scheme.FontColor,
            TextSize = ApplyTextScale(14),
            TextTransparency = 0,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(12, 0),
            Parent = Button,
        })
        local function Click()
            if Option.Disabled then
                return
            end
            if Option.DoubleClick then
                local ClickTime = tick()
                if ButtonFunctions.LastClick and ClickTime - ButtonFunctions.LastClick < 0.3 then
                    SafeCallback(Option.Callback)
                    ButtonFunctions.LastClick = nil
                else
                    ButtonFunctions.LastClick = ClickTime
                end
            else
                SafeCallback(Option.Callback)
            end
        end
        Button.MouseButton1Click:Connect(Click)
        function ButtonFunctions:Update()
        end
        return ButtonFunctions, Button
    end

    function MacoriaLib:CreateOption(Type, Groupbox, ...)
        local Options = { ... }
        local Option = Options[1]
        Option.Groupbox = Groupbox
        if not Option.Changed then
            Option.Changed = Instance.new("BindableEvent")
        end
        local Functions, Element
        if Type == "Toggle" then
            Functions, Element = MakeToggle(Option)
            Option.Type = "Toggle"
        elseif Type == "Slider" then
            Functions, Element = MakeSlider(Option)
            Option.Type = "Slider"
        elseif Type == "Dropdown" then
            Functions, Element = MakeDropdown(Option)
            Option.Type = "Dropdown"
        elseif Type == "Input" then
            Functions, Element = MakeInput(Option)
            Option.Type = "Input"
        elseif Type == "KeyPicker" then
            Functions, Element = MakeKeyPicker(Option)
            Option.Type = "KeyPicker"
        elseif Type == "ColorPicker" then
            Functions, Element = MakeColorPicker(Option)
            Option.Type = "ColorPicker"
        elseif Type == "Label" then
            Functions, Element = MakeLabel(Groupbox, Option)
            Option.Type = "Label"
        elseif Type == "Divider" then
            Functions, Element = MakeDivider(Groupbox)
            Option.Type = "Divider"
        elseif Type == "Button" then
            Functions, Element = MakeButton(Option)
            Option.Type = "Button"
        end
        if Element then
            Element.Name = Option.Text or Option.Name
            Element.ZIndex = Groupbox.InnerHolder.ZIndex
            Element.Parent = Groupbox.InnerHolder
            local Holder = Element
            if Type ~= "Label" and Type ~= "Divider" and Type ~= "Button" then
                Holder = Element:FindFirstChild(Type .. "Label") or Element
            end
            table.insert(Groupbox.Elements, {
                Type = Type,
                Holder = Holder,
                Text = Option.Text or Option.Name,
                Visible = true,
            })
            table.insert(MacoriaLib.Options, Option)
            Option.ID = #MacoriaLib.Options
            Option.Update = Functions.Update
            Option.SetValue = Functions.SetValue
            if Type == "KeyPicker" then
                Option.UpdateToggleFrame = UpdateToggleFrame
                Option.UpdateToggleFrame()
            elseif Type == "ColorPicker" then
                Option.UpdateColor = Functions.UpdateColor
                Option.UpdateColor(DefaultColor, DefaultTransparency)
            end
        end
        return Option
    end

    function TabFunctions:CreateToggle(...)
        local Tab = self
        local Option = ...
        if type(Option) == "table" then
            Option = Option[1]
        end
        local Groupbox = Option.Groupbox or Tab:AddGroupbox({ Side = Option.Side or "Left", Name = Option.GroupboxName })
        Groupbox.Searchable = true
        return MacoriaLib:CreateOption("Toggle", Groupbox, Option)
    end

    function TabFunctions:CreateSlider(...)
        local Tab = self
        local Option = ...
        if type(Option) == "table" then
            Option = Option[1]
        end
        local Groupbox = Option.Groupbox or Tab:AddGroupbox({ Side = Option.Side or "Left", Name = Option.GroupboxName })
        Groupbox.Searchable = true
        return MacoriaLib:CreateOption("Slider", Groupbox, Option)
    end

    function TabFunctions:CreateDropdown(...)
        local Tab = self
        local Option = ...
        if type(Option) == "table" then
            Option = Option[1]
        end
        local Groupbox = Option.Groupbox or Tab:AddGroupbox({ Side = Option.Side or "Left", Name = Option.GroupboxName })
        Groupbox.Searchable = true
        return MacoriaLib:CreateOption("Dropdown", Groupbox, Option)
    end

    function TabFunctions:CreateInput(...)
        local Tab = self
        local Option = ...
        if type(Option) == "table" then
            Option = Option[1]
        end
        local Groupbox = Option.Groupbox or Tab:AddGroupbox({ Side = Option.Side or "Left", Name = Option.GroupboxName })
        Groupbox.Searchable = true
        return MacoriaLib:CreateOption("Input", Groupbox, Option)
    end

    function TabFunctions:CreateKeyPicker(...)
        local Tab = self
        local Option = ...
        if type(Option) == "table" then
            Option = Option[1]
        end
        local Groupbox = Option.Groupbox or Tab:AddGroupbox({ Side = Option.Side or "Left", Name = Option.GroupboxName })
        Groupbox.Searchable = true
        return MacoriaLib:CreateOption("KeyPicker", Groupbox, Option)
    end

    function TabFunctions:CreateColorPicker(...)
        local Tab = self
        local Option = ...
        if type(Option) == "table" then
            Option = Option[1]
        end
        local Groupbox = Option.Groupbox or Tab:AddGroupbox({ Side = Option.Side or "Left", Name = Option.GroupboxName })
        Groupbox.Searchable = true
        return MacoriaLib:CreateOption("ColorPicker", Groupbox, Option)
    end

    function TabFunctions:CreateLabel(...)
        local Tab = self
        local Option = ...
        if type(Option) == "table" then
            Option = Option[1]
        end
        local Groupbox = Option.Groupbox or Tab:AddGroupbox({ Side = Option.Side or "Left", Name = Option.GroupboxName })
        Groupbox.Searchable = true
        return MacoriaLib:CreateOption("Label", Groupbox, Option)
    end

    function TabFunctions:CreateDivider(...)
        local Tab = self
        local Option = ...
        if type(Option) == "table" then
            Option = Option[1]
        end
        local Groupbox = Option.Groupbox or Tab:AddGroupbox({ Side = Option.Side or "Left", Name = Option.GroupboxName })
        Groupbox.Searchable = true
        return MacoriaLib:CreateOption("Divider", Groupbox, Option)
    end

    function TabFunctions:CreateButton(...)
        local Tab = self
        local Option = ...
        if type(Option) == "table" then
            Option = Option[1]
        end
        local ButtonHolder = Option.ButtonHolder or Tab:AddButtonHolder()
        Option.ButtonHolder = ButtonHolder
        ButtonHolder.Searchable = true
        return MacoriaLib:CreateOption("Button", ButtonHolder, Option)
    end

    function MacoriaLib:CreateTab(...)
        return WindowFunctions:Tab(...)
    end

    function MacoriaLib:CreateWindow(...)
        local args = {...}
        local Settings = args[1]
        if type(Settings) ~= "table" then
            Settings = args
        end
        return Window(Settings)
    end

    function MacoriaLib:Toggle()
        WindowFunctions:Toggle()
    end

    function MacoriaLib:SetTheme(Theme)
        if Theme then
            MacoriaLib.Scheme = Theme
            UpdateColorsUsingRegistry()
        end
    end

    function MacoriaLib:GetTheme()
        return MacoriaLib.Scheme
    end

    function MacoriaLib:AddDependencyBox()
    end

    function MacoriaLib:OnUnload(Callback)
        OnUnload(Callback)
    end

    function MacoriaLib:Unload()
        Unload()
    end

    if WindowFunctions.Settings.Center then
        base.Position = UDim2.fromScale(0.5, 0.5)
    end
    if WindowFunctions.Settings.AutoShow then
        base.Visible = true
    end
    if WindowFunctions.Settings.Resizable then
        local ResizerFrame = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(1, 1),
            AnchorPoint = Vector2.new(1, 1),
            Size = UDim2.fromOffset(16, 16),
            Parent = base,
        })
        local ResizerIcon = New("ImageLabel", {
            Image = assets.transform,
            ImageTransparency = 0.7,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(16, 16),
            Rotation = 90,
            Parent = ResizerFrame,
        })
        MakeResizable(base, ResizerFrame, function()
            content.Size = UDim2.fromOffset(base.AbsoluteSize.X - sidebar.AbsoluteSize.X, content.AbsoluteSize.Y)
            for _, Tab in pairs(MacoriaLib.Tabs) do
                if Tab.Tab and Tab.Tab.Visible then
                    Tab:Resize(true)
                end
            end
        end)
    end

    WindowFunctions:SetKeybindTab(true)

    return WindowFunctions
end

getgenv().MacoriaLib = MacoriaLib

return MacoriaLib