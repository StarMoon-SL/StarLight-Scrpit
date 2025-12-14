local MacLib = {
    Options = {},
    Folder = "Maclib",
    GetService = function(service)
        return cloneref and cloneref(game:GetService(service)) or game:GetService(service)
    end
}

local TweenService = MacLib.GetService("TweenService")
local RunService = MacLib.GetService("RunService")
local HttpService = MacLib.GetService("HttpService")
local ContentProvider = MacLib.GetService("ContentProvider")
local UserInputService = MacLib.GetService("UserInputService")
local Lighting = MacLib.GetService("Lighting")
local Players = MacLib.GetService("Players")
local TextService = MacLib.GetService("TextService")

local isStudio = RunService:IsStudio()
local LocalPlayer = Players.LocalPlayer

local DevicePlatform = nil
local IsMobile = false

if RunService:IsStudio() then
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        IsMobile = true
    end
else
    pcall(function()
        DevicePlatform = UserInputService:GetPlatform()
    end)
    IsMobile = DevicePlatform == Enum.Platform.Android or DevicePlatform == Enum.Platform.IOS
end

local windowState
local acrylicBlur = true
local hasGlobalSetting = false
local tabs = {}
local currentTabInstance = nil
local tabIndex = 0
local unloaded = false
local DPIRan = false
local DPIScale = IsMobile and 0.8 or 1

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
    keybindIcon = "rbxassetid://10723407354"
}

local function GetGui()
    local newGui = Instance.new("ScreenGui")
    newGui.ScreenInsets = Enum.ScreenInsets.None
    newGui.ResetOnSpawn = false
    newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    newGui.DisplayOrder = 2147483647
    local parent = RunService:IsStudio() and LocalPlayer:FindFirstChild("PlayerGui") or (gethui and gethui()) or (cloneref and cloneref(MacLib.GetService("CoreGui")) or MacLib.GetService("CoreGui"))
    newGui.Parent = parent
    return newGui
end

local function Tween(instance, tweeninfo, propertytable)
    return TweenService:Create(instance, tweeninfo, propertytable)
end

local function ApplyDPIScale(value)
    if typeof(value) == "number" then
        return value * DPIScale
    elseif typeof(value) == "UDim2" then
        return UDim2.new(value.X.Scale, value.X.Offset * DPIScale, value.Y.Scale, value.Y.Offset * DPIScale)
    elseif typeof(value) == "UDim" then
        return UDim.new(value.Scale, value.Offset * DPIScale)
    end
    return value
end

local function GetTextBounds(Text, Font, Size, Width)
    local Params = Instance.new("GetTextBoundsParams")
    Params.Text = Text
    Params.RichText = true
    Params.Font = Font
    Params.Size = Size
    Params.Width = Width or workspace.CurrentCamera.ViewportSize.X
    local Bounds = TextService:GetTextBoundsAsync(Params)
    return Bounds.X, Bounds.Y
end

function MacLib:Window(Settings)
    local WindowFunctions = {Settings = Settings}
    if Settings.AcrylicBlur ~= nil then
        acrylicBlur = Settings.AcrylicBlur
    end

    local macLib = GetGui()
    
    local notifications = Instance.new("Frame")
    notifications.Name = "Notifications"
    notifications.BackgroundTransparency = 1
    notifications.Size = UDim2.fromScale(1, 1)
    notifications.Parent = macLib
    notifications.ZIndex = 2
    
    local notificationsUIListLayout = Instance.new("UIListLayout")
    notificationsUIListLayout.Padding = UDim.new(0, 10)
    notificationsUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notificationsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notificationsUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notificationsUIListLayout.Parent = notifications
    
    local notificationsUIPadding = Instance.new("UIPadding")
    notificationsUIPadding.PaddingBottom = UDim.new(0, 10)
    notificationsUIPadding.PaddingLeft = UDim.new(0, 10)
    notificationsUIPadding.PaddingRight = UDim.new(0, 10)
    notificationsUIPadding.PaddingTop = UDim.new(0, 10)
    notificationsUIPadding.Parent = notifications

    local base = Instance.new("Frame")
    base.Name = "Base"
    base.AnchorPoint = Vector2.new(0.5, 0.5)
    base.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    base.BackgroundTransparency = acrylicBlur and 0.05 or 0
    base.BorderSizePixel = 0
    base.Position = UDim2.fromScale(0.5, 0.5)
    base.Size = Settings.Size or ApplyDPIScale(UDim2.fromOffset(868, 650))

    local baseUIScale = Instance.new("UIScale")
    baseUIScale.Scale = DPIScale
    baseUIScale.Parent = base

    local baseUICorner = Instance.new("UICorner")
    baseUICorner.CornerRadius = UDim.new(0, 10)
    baseUICorner.Parent = base

    local baseUIStroke = Instance.new("UIStroke")
    baseUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    baseUIStroke.Color = Color3.fromRGB(255, 255, 255)
    baseUIStroke.Transparency = 0.9
    baseUIStroke.Parent = base

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundTransparency = 1
    sidebar.BorderSizePixel = 0
    sidebar.Position = UDim2.fromScale(0, 0)
    sidebar.Size = UDim.fromScale(0.325, 1)

    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.AnchorPoint = Vector2.new(1, 0)
    divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider.BackgroundTransparency = 0.9
    divider.BorderSizePixel = 0
    divider.Position = UDim2.fromScale(1, 0)
    divider.Size = UDim2.new(0, 1, 1, 0)
    divider.Parent = sidebar

    local dividerInteract = Instance.new("TextButton")
    dividerInteract.Name = "DividerInteract"
    dividerInteract.AnchorPoint = Vector2.new(0.5, 0)
    dividerInteract.BackgroundTransparency = 1
    dividerInteract.BorderSizePixel = 0
    dividerInteract.Position = UDim2.fromScale(0.5, 0)
    dividerInteract.Size = UDim2.new(1, 6, 1, 0)
    dividerInteract.Text = ""
    dividerInteract.Parent = divider

    local windowControls = Instance.new("Frame")
    windowControls.Name = "WindowControls"
    windowControls.BackgroundTransparency = 1
    windowControls.BorderSizePixel = 0
    windowControls.Size = UDim.new(1, 0, 0, ApplyDPIScale(31))

    local controls = Instance.new("Frame")
    controls.BackgroundTransparency = 1
    controls.BorderSizePixel = 0
    controls.Size = UDim2.fromScale(1, 1)
    controls.Parent = windowControls

    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.Padding = UDim.new(0, 5)
    uIListLayout.FillDirection = Enum.FillDirection.Horizontal
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uIListLayout.Parent = controls

    local uIPadding = Instance.new("UIPadding")
    uIPadding.PaddingLeft = UDim.new(0, ApplyDPIScale(11))
    uIPadding.Parent = controls

    local windowControlSettings = {
        sizes = { enabled = UDim2.fromOffset(8, 8), disabled = UDim2.fromOffset(7, 7) },
        transparencies = { enabled = 0, disabled = 1 },
        strokeTransparency = 0.9,
    }

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = windowControlSettings.strokeTransparency

    local exit = Instance.new("TextButton")
    exit.Name = "Exit"
    exit.Text = ""
    exit.AutoButtonColor = false
    exit.BackgroundColor3 = Color3.fromRGB(250, 93, 86)
    exit.BorderSizePixel = 0
    local uICorner = Instance.new("UICorner")
    uICorner.CornerRadius = UDim.new(1, 0)
    uICorner.Parent = exit
    exit.Parent = controls

    local minimize = Instance.new("TextButton")
    minimize.Name = "Minimize"
    minimize.Text = ""
    minimize.AutoButtonColor = false
    minimize.BackgroundColor3 = Color3.fromRGB(252, 190, 57)
    minimize.BorderSizePixel = 0
    minimize.LayoutOrder = 1
    local uICorner1 = Instance.new("UICorner")
    uICorner1.CornerRadius = UDim.new(1, 0)
    uICorner1.Parent = minimize
    minimize.Parent = controls

    local maximize = Instance.new("TextButton")
    maximize.Name = "Maximize"
    maximize.Text = ""
    maximize.AutoButtonColor = false
    maximize.BackgroundColor3 = Color3.fromRGB(119, 174, 94)
    maximize.BorderSizePixel = 0
    maximize.LayoutOrder = 1
    local uICorner2 = Instance.new("UICorner")
    uICorner2.CornerRadius = UDim.new(1, 0)
    uICorner2.Parent = maximize
    maximize.Parent = controls

    local function applyState(button, enabled)
        local size = enabled and windowControlSettings.sizes.enabled or windowControlSettings.sizes.disabled
        local transparency = enabled and windowControlSettings.transparencies.enabled or windowControlSettings.transparencies.disabled
        button.Size = ApplyDPIScale(size)
        button.BackgroundTransparency = transparency
        button.Active = enabled
        button.Interactable = enabled
        for _, child in ipairs(button:GetChildren()) do
            if child:IsA("UIStroke") then
                child.Transparency = transparency
            end
        end
        if not enabled then
            stroke:Clone().Parent = button
        end
    end

    applyState(maximize, false)
    local controlsList = {exit, minimize}
    for _, button in pairs(controlsList) do
        local buttonName = button.Name
        local isEnabled = true
        if Settings.DisabledWindowControls and table.find(Settings.DisabledWindowControls, buttonName) then
            isEnabled = false
        end
        applyState(button, isEnabled)
    end

    controls.Parent = windowControls

    local divider1 = Instance.new("Frame")
    divider1.Name = "Divider"
    divider1.AnchorPoint = Vector2.new(0, 1)
    divider1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider1.BackgroundTransparency = 0.9
    divider1.BorderSizePixel = 0
    divider1.Position = UDim2.fromScale(0, 1)
    divider1.Size = UDim2.new(1, 0, 0, 1)
    divider1.Parent = windowControls

    windowControls.Parent = sidebar

    local information = Instance.new("Frame")
    information.Name = "Information"
    information.BackgroundTransparency = 1
    information.BorderSizePixel = 0
    information.Position = UDim2.fromOffset(0, ApplyDPIScale(31))
    information.Size = UDim2.new(1, 0, 0, ApplyDPIScale(60))

    local divider2 = Instance.new("Frame")
    divider2.Name = "Divider"
    divider2.AnchorPoint = Vector2.new(0, 1)
    divider2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider2.BackgroundTransparency = 0.9
    divider2.BorderSizePixel = 0
    divider2.Position = UDim2.fromScale(0, 1)
    divider2.Size = UDim2.new(1, 0, 0, 1)
    divider2.Parent = information

    local informationHolder = Instance.new("Frame")
    informationHolder.Name = "InformationHolder"
    informationHolder.BackgroundTransparency = 1
    informationHolder.BorderSizePixel = 0
    informationHolder.Size = UDim2.fromScale(1, 1)
    local informationHolderUIPadding = Instance.new("UIPadding")
    informationHolderUIPadding.PaddingBottom = UDim.new(0, ApplyDPIScale(10))
    informationHolderUIPadding.PaddingLeft = UDim.new(0, ApplyDPIScale(23))
    informationHolderUIPadding.PaddingRight = UDim.new(0, ApplyDPIScale(22))
    informationHolderUIPadding.PaddingTop = UDim.new(0, ApplyDPIScale(10))
    informationHolderUIPadding.Parent = informationHolder

    local globalSettingsButton = Instance.new("ImageButton")
    globalSettingsButton.Name = "GlobalSettingsButton"
    globalSettingsButton.Image = assets.globe
    globalSettingsButton.ImageTransparency = 0.5
    globalSettingsButton.AnchorPoint = Vector2.new(1, 0.5)
    globalSettingsButton.BackgroundTransparency = 1
    globalSettingsButton.BorderSizePixel = 0
    globalSettingsButton.Position = UDim2.fromScale(1, 0.5)
    globalSettingsButton.Size = UDim2.fromOffset(16, 16)
    globalSettingsButton.Parent = informationHolder

    local function ChangeGlobalSettingsButtonState(State)
        if State == "Default" then
            Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {ImageTransparency = 0.5}):Play()
        elseif State == "Hover" then
            Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {ImageTransparency = 0.3}):Play()
        end
    end

    globalSettingsButton.MouseEnter:Connect(function()
        ChangeGlobalSettingsButtonState("Hover")
    end)
    globalSettingsButton.MouseLeave:Connect(function()
        ChangeGlobalSettingsButtonState("Default")
    end)

    local titleFrame = Instance.new("Frame")
    titleFrame.Name = "TitleFrame"
    titleFrame.BackgroundTransparency = 1
    titleFrame.BorderSizePixel = 0
    titleFrame.Size = UDim2.fromScale(1, 1)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    title.Text = Settings.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.RichText = true
    title.TextSize = ApplyDPIScale(18)
    title.TextTransparency = 0.1
    title.TextTruncate = Enum.TextTruncate.SplitWord
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Top
    title.AutomaticSize = Enum.AutomaticSize.Y
    title.BackgroundTransparency = 1
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, -20, 0, 0)
    title.Parent = titleFrame

    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    subtitle.RichText = true
    subtitle.Text = Settings.Subtitle
    subtitle.RichText = true
    subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    subtitle.TextSize = ApplyDPIScale(12)
    subtitle.TextTransparency = 0.7
    subtitle.TextTruncate = Enum.TextTruncate.SplitWord
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextYAlignment = Enum.TextYAlignment.Top
    subtitle.AutomaticSize = Enum.AutomaticSize.Y
    subtitle.BackgroundTransparency = 1
    subtitle.BorderSizePixel = 0
    subtitle.LayoutOrder = 1
    subtitle.Size = UDim2.new(1, -20, 0, 0)
    subtitle.Parent = titleFrame

    local titleFrameUIListLayout = Instance.new("UIListLayout")
    titleFrameUIListLayout.Padding = UDim.new(0, 3)
    titleFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    titleFrameUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    titleFrameUIListLayout.Parent = titleFrame

    titleFrame.Parent = informationHolder
    informationHolder.Parent = information
    information.Parent = sidebar

    local sidebarGroup = Instance.new("Frame")
    sidebarGroup.Name = "SidebarGroup"
    sidebarGroup.BackgroundTransparency = 1
    sidebarGroup.BorderSizePixel = 0
    sidebarGroup.Position = UDim2.fromOffset(0, ApplyDPIScale(91))
    sidebarGroup.Size = UDim2.new(1, 0, 1, -ApplyDPIScale(91))

    local userInfo = Instance.new("Frame")
    userInfo.Name = "UserInfo"
    userInfo.AnchorPoint = Vector2.new(0, 1)
    userInfo.BackgroundTransparency = 1
    userInfo.BorderSizePixel = 0
    userInfo.Position = UDim2.fromScale(0, 1)
    userInfo.Size = UDim2.new(1, 0, 0, ApplyDPIScale(107))

    local informationGroup = Instance.new("Frame")
    informationGroup.Name = "InformationGroup"
    informationGroup.BackgroundTransparency = 1
    informationGroup.BorderSizePixel = 0
    informationGroup.Size = UDim2.fromScale(1, 1)
    local informationGroupUIPadding = Instance.new("UIPadding")
    informationGroupUIPadding.PaddingBottom = UDim.new(0, ApplyDPIScale(17))
    informationGroupUIPadding.PaddingLeft = UDim.new(0, ApplyDPIScale(25))
    informationGroupUIPadding.Parent = informationGroup

    local informationGroupUIListLayout = Instance.new("UIListLayout")
    informationGroupUIListLayout.FillDirection = Enum.FillDirection.Horizontal
    informationGroupUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    informationGroupUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    informationGroupUIListLayout.Parent = informationGroup

    local userId = LocalPlayer.UserId
    local thumbType = Enum.ThumbnailType.AvatarBust
    local thumbSize = Enum.ThumbnailSize.Size48x48
    local headshotImage, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

    local headshot = Instance.new("ImageLabel")
    headshot.Name = "Headshot"
    headshot.BackgroundTransparency = 1
    headshot.BorderSizePixel = 0
    headshot.Size = UDim2.fromOffset(32, 32)
    headshot.Image = isReady and headshotImage or "rbxassetid://0"
    local uICorner3 = Instance.new("UICorner")
    uICorner3.CornerRadius = UDim.new(1, 0)
    uICorner3.Parent = headshot
    local baseUIStroke2 = Instance.new("UIStroke")
    baseUIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    baseUIStroke2.Color = Color3.fromRGB(255, 255, 255)
    baseUIStroke2.Transparency = 0.9
    baseUIStroke2.Parent = headshot
    headshot.Parent = informationGroup

    local userAndDisplayFrame = Instance.new("Frame")
    userAndDisplayFrame.Name = "UserAndDisplayFrame"
    userAndDisplayFrame.BackgroundTransparency = 1
    userAndDisplayFrame.BorderSizePixel = 0
    userAndDisplayFrame.LayoutOrder = 1
    userAndDisplayFrame.Size = UDim2.new(1, -42, 0, 32)
    local displayName = Instance.new("TextLabel")
    displayName.Name = "DisplayName"
    displayName.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    displayName.Text = LocalPlayer.DisplayName
    displayName.TextColor3 = Color3.fromRGB(255, 255, 255)
    displayName.TextSize = ApplyDPIScale(13)
    displayName.TextTransparency = 0.1
    displayName.TextTruncate = Enum.TextTruncate.SplitWord
    displayName.TextXAlignment = Enum.TextXAlignment.Left
    displayName.TextYAlignment = Enum.TextYAlignment.Top
    displayName.AutomaticSize = Enum.AutomaticSize.XY
    displayName.BackgroundTransparency = 1
    displayName.BorderSizePixel = 0
    displayName.Parent = userAndDisplayFrame
    displayName.Size = UDim2.fromScale(1, 0)
    local userAndDisplayFrameUIPadding = Instance.new("UIPadding")
    userAndDisplayFrameUIPadding.PaddingLeft = UDim.new(0, ApplyDPIScale(8))
    userAndDisplayFrameUIPadding.PaddingTop = UDim.new(0, ApplyDPIScale(3))
    userAndDisplayFrameUIPadding.Parent = userAndDisplayFrame
    local userAndDisplayFrameUIListLayout = Instance.new("UIListLayout")
    userAndDisplayFrameUIListLayout.Padding = UDim.new(0, 1)
    userAndDisplayFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    userAndDisplayFrameUIListLayout.Parent = userAndDisplayFrame
    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    username.Text = "@" .. LocalPlayer.Name
    username.TextColor3 = Color3.fromRGB(255, 255, 255)
    username.TextSize = ApplyDPIScale(12)
    username.TextTransparency = 0.7
    username.TextTruncate = Enum.TextTruncate.SplitWord
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.TextYAlignment = Enum.TextYAlignment.Top
    username.AutomaticSize = Enum.AutomaticSize.XY
    username.BackgroundTransparency = 1
    username.BorderSizePixel = 0
    username.LayoutOrder = 1
    username.Parent = userAndDisplayFrame
    username.Size = UDim2.fromScale(1, 0)
    userAndDisplayFrame.Parent = informationGroup
    informationGroup.Parent = userInfo
    local userInfoUIPadding = Instance.new("UIPadding")
    userInfoUIPadding.PaddingLeft = UDim.new(0, ApplyDPIScale(10))
    userInfoUIPadding.PaddingRight = UDim.new(0, ApplyDPIScale(10))
    userInfoUIPadding.Parent = userInfo
    userInfo.Parent = sidebarGroup
    local sidebarGroupUIPadding = Instance.new("UIPadding")
    sidebarGroupUIPadding.PaddingLeft = UDim.new(0, ApplyDPIScale(10))
    sidebarGroupUIPadding.PaddingRight = UDim.new(0, ApplyDPIScale(10))
    sidebarGroupUIPadding.PaddingTop = UDim.new(0, ApplyDPIScale(31))
    sidebarGroupUIPadding.Parent = sidebarGroup

    local tabSwitchers = Instance.new("Frame")
    tabSwitchers.Name = "TabSwitchers"
    tabSwitchers.BackgroundTransparency = 1
    tabSwitchers.BorderSizePixel = 0
    tabSwitchers.Size = UDim2.new(1, 0, 1, -ApplyDPIScale(107))

    local tabSwitchersScrollingFrame = Instance.new("ScrollingFrame")
    tabSwitchersScrollingFrame.Name = "TabSwitchersScrollingFrame"
    tabSwitchersScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabSwitchersScrollingFrame.BottomImage = ""
    tabSwitchersScrollingFrame.CanvasSize = UDim2.new()
    tabSwitchersScrollingFrame.ScrollBarImageTransparency = 0.8
    tabSwitchersScrollingFrame.ScrollBarThickness = 1
    tabSwitchersScrollingFrame.TopImage = ""
    tabSwitchersScrollingFrame.BackgroundTransparency = 1
    tabSwitchersScrollingFrame.BorderSizePixel = 0
    tabSwitchersScrollingFrame.Size = UDim2.fromScale(1, 1)
    local tabSwitchersScrollingFrameUIListLayout = Instance.new("UIListLayout")
    tabSwitchersScrollingFrameUIListLayout.Padding = UDim.new(0, ApplyDPIScale(17))
    tabSwitchersScrollingFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabSwitchersScrollingFrameUIListLayout.Parent = tabSwitchersScrollingFrame
    local tabSwitchersScrollingFrameUIPadding = Instance.new("UIPadding")
    tabSwitchersScrollingFrameUIPadding.PaddingTop = UDim.new(0, 2)
    tabSwitchersScrollingFrameUIPadding.Parent = tabSwitchersScrollingFrame
    tabSwitchersScrollingFrame.Parent = tabSwitchers
    tabSwitchers.Parent = sidebarGroup
    sidebarGroup.Parent = sidebar

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.AnchorPoint = Vector2.new(1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Position = UDim2.fromScale(1, 0)
    content.Size = UDim2.new(0, (base.AbsoluteSize.X - sidebar.AbsoluteSize.X), 1, 0)

    local resizingContent = false
    local defaultSidebarWidth = sidebar.AbsoluteSize.X
    local initialMouseX, initialSidebarWidth
    local snapRange = 20
    local minSidebarWidth = ApplyDPIScale(107)
    local maxSidebarWidth = base.AbsoluteSize.X - minSidebarWidth

    local TweenSettings = {
        DefaultTransparency = 0.9,
        HoverTransparency = 0.85,
        EasingStyle = Enum.EasingStyle.Sine
    }

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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizingContent = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizingContent and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local deltaX = UserInputService:GetMouseLocation().X - initialMouseX
            local newSidebarWidth = initialSidebarWidth + deltaX
            if math.abs(newSidebarWidth - defaultSidebarWidth) < snapRange then
                newSidebarWidth = defaultSidebarWidth
            else
                newSidebarWidth = math.clamp(newSidebarWidth, minSidebarWidth, maxSidebarWidth)
            end
            sidebar.Size = UDim2.fromOffset(newSidebarWidth, sidebar.AbsoluteSize.Y)
            content.Size = UDim2.fromOffset(base.AbsoluteSize.X - newSidebarWidth, content.AbsoluteSize.Y)
        end
    end)

    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.BackgroundTransparency = 1
    topbar.BorderSizePixel = 0
    topbar.Size = UDim2.new(1, 0, 0, ApplyDPIScale(63))

    local divider4 = Instance.new("Frame")
    divider4.Name = "Divider"
    divider4.AnchorPoint = Vector2.new(0, 1)
    divider4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider4.BackgroundTransparency = 0.9
    divider4.BorderSizePixel = 0
    divider4.Position = UDim2.fromScale(0, 1)
    divider4.Size = UDim2.new(1, 0, 0, 1)
    divider4.Parent = topbar

    local elements = Instance.new("Frame")
    elements.Name = "Elements"
    elements.BackgroundTransparency = 1
    elements.BorderSizePixel = 0
    elements.Size = UDim2.fromScale(1, 1)
    local uIPadding2 = Instance.new("UIPadding")
    uIPadding2.PaddingLeft = UDim.new(0, ApplyDPIScale(20))
    uIPadding2.PaddingRight = UDim.new(0, ApplyDPIScale(20))
    uIPadding2.Parent = elements

    local moveIcon = Instance.new("ImageButton")
    moveIcon.Name = "MoveIcon"
    moveIcon.Image = assets.transform
    moveIcon.ImageTransparency = 0.7
    moveIcon.AnchorPoint = Vector2.new(1, 0.5)
    moveIcon.BackgroundTransparency = 1
    moveIcon.BorderSizePixel = 0
    moveIcon.Position = UDim2.fromScale(1, 0.5)
    moveIcon.Size = UDim2.fromOffset(15, 15)
    moveIcon.Parent = elements
    moveIcon.Visible = not Settings.DragStyle or Settings.DragStyle == 1

    local interact = Instance.new("TextButton")
    interact.Name = "Interact"
    interact.Text = ""
    interact.AnchorPoint = Vector2.new(0.5, 0.5)
    interact.BackgroundTransparency = 1
    interact.BorderSizePixel = 0
    interact.Position = UDim2.fromScale(0.5, 0.5)
    interact.Size = UDim2.fromOffset(40, 40)
    interact.Parent = moveIcon

    local function ChangemoveIconState(State)
        if State == "Default" then
            Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {ImageTransparency = 0.7}):Play()
        elseif State == "Hover" then
            Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {ImageTransparency = 0.4}):Play()
        end
    end

    interact.MouseEnter:Connect(function()
        ChangemoveIconState("Hover")
    end)
    interact.MouseLeave:Connect(function()
        ChangemoveIconState("Default")
    end)

    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    local function onDragStart(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = base.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end

    local function onDragUpdate(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            dragInput = input
        end
    end

    if not Settings.DragStyle or Settings.DragStyle == 1 then
        interact.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                onDragStart(input)
            end
        end)
        interact.InputChanged:Connect(onDragUpdate)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
        interact.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    elseif Settings.DragStyle == 2 then
        base.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                onDragStart(input)
            end
        end)
        base.InputChanged:Connect(onDragUpdate)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
        base.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local currentTab = Instance.new("TextLabel")
    currentTab.Name = "CurrentTab"
    currentTab.FontFace = Font.new(assets.interFont)
    currentTab.RichText = true
    currentTab.Text = ""
    currentTab.RichText = true
    currentTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    currentTab.TextSize = ApplyDPIScale(15)
    currentTab.TextTransparency = 0.5
    currentTab.TextTruncate = Enum.TextTruncate.SplitWord
    currentTab.TextXAlignment = Enum.TextXAlignment.Left
    currentTab.TextYAlignment = Enum.TextYAlignment.Top
    currentTab.AnchorPoint = Vector2.new(0, 0.5)
    currentTab.AutomaticSize = Enum.AutomaticSize.Y
    currentTab.BackgroundTransparency = 1
    currentTab.BorderSizePixel = 0
    currentTab.Position = UDim2.fromScale(0, 0.5)
    currentTab.Size = UDim2.fromScale(0.9, 0)
    currentTab.Parent = elements
    elements.Parent = topbar
    topbar.Parent = content

    local elements1 = Instance.new("Frame")
    elements1.Name = "Elements"
    elements1.BackgroundTransparency = 1
    elements1.BorderSizePixel = 0
    elements1.Position = UDim2.fromOffset(0, ApplyDPIScale(63))
    elements1.Size = UDim2.new(1, 0, 1, -ApplyDPIScale(63))
    elements1.ClipsDescendants = true
    local elementsUIPadding = Instance.new("UIPadding")
    elementsUIPadding.PaddingRight = UDim.new(0, 5)
    elementsUIPadding.PaddingTop = UDim.new(0, ApplyDPIScale(10))
    elementsUIPadding.PaddingBottom = UDim.new(0, ApplyDPIScale(10))
    elementsUIPadding.Parent = elements1

    local elementsScrolling = Instance.new("ScrollingFrame")
    elementsScrolling.Name = "ElementsScrolling"
    elementsScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
    elementsScrolling.BottomImage = ""
    elementsScrolling.CanvasSize = UDim2.new()
    elementsScrolling.ScrollBarImageTransparency = 0.5
    elementsScrolling.ScrollBarThickness = 1
    elementsScrolling.TopImage = ""
    elementsScrolling.BackgroundTransparency = 1
    elementsScrolling.BorderSizePixel = 0
    elementsScrolling.Size = UDim2.fromScale(1, 1)
    elementsScrolling.ClipsDescendants = false

    local elementsScrollingUIPadding = Instance.new("UIPadding")
    elementsScrollingUIPadding.PaddingBottom = UDim.new(0, 5)
    elementsScrollingUIPadding.PaddingLeft = UDim.new(0, 11)
    elementsScrollingUIPadding.PaddingRight = UDim.new(0, 3)
    elementsScrollingUIPadding.PaddingTop = UDim.new(0, 5)
    elementsScrollingUIPadding.Parent = elementsScrolling

    local elementsScrollingUIListLayout = Instance.new("UIListLayout")
    elementsScrollingUIListLayout.Padding = UDim.new(0, ApplyDPIScale(15))
    elementsScrollingUIListLayout.FillDirection = Enum.FillDirection.Horizontal
    elementsScrollingUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    elementsScrollingUIListLayout.Parent = elementsScrolling

    local left = Instance.new("Frame")
    left.Name = "Left"
    left.AutomaticSize = Enum.AutomaticSize.Y
    left.BackgroundTransparency = 1
    left.BorderSizePixel = 0
    left.Position = UDim2.fromScale(0.512, 0)
    left.Size = UDim2.new(0.5, -10, 0, 0)
    local leftUIListLayout = Instance.new("UIListLayout")
    leftUIListLayout.Padding = UDim.new(0, ApplyDPIScale(15))
    leftUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftUIListLayout.Parent = left
    left.Parent = elementsScrolling

    local right = Instance.new("Frame")
    right.Name = "Right"
    right.AutomaticSize = Enum.AutomaticSize.Y
    right.BackgroundTransparency = 1
    right.BorderSizePixel = 0
    right.LayoutOrder = 1
    right.Position = UDim2.fromScale(0.512, 0)
    right.Size = UDim2.new(0.5, -10, 0, 0)
    local rightUIListLayout = Instance.new("UIListLayout")
    rightUIListLayout.Padding = UDim.new(0, ApplyDPIScale(15))
    rightUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightUIListLayout.Parent = right
    right.Parent = elementsScrolling
    elementsScrolling.Parent = elements1
    elements1.Parent = content

    local globalSettings = Instance.new("Frame")
    globalSettings.Name = "GlobalSettings"
    globalSettings.AutomaticSize = Enum.AutomaticSize.XY
    globalSettings.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    globalSettings.BorderSizePixel = 0
    globalSettings.Position = UDim2.fromScale(0.298, 0.104)
    local globalSettingsUIStroke = Instance.new("UIStroke")
    globalSettingsUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    globalSettingsUIStroke.Color = Color3.fromRGB(255, 255, 255)
    globalSettingsUIStroke.Transparency = 0.9
    globalSettingsUIStroke.Parent = globalSettings
    local globalSettingsUICorner = Instance.new("UICorner")
    globalSettingsUICorner.CornerRadius = UDim.new(0, 10)
    globalSettingsUICorner.Parent = globalSettings
    local globalSettingsUIPadding = Instance.new("UIPadding")
    globalSettingsUIPadding.PaddingBottom = UDim.new(0, 10)
    globalSettingsUIPadding.PaddingTop = UDim.new(0, 10)
    globalSettingsUIPadding.Parent = globalSettings
    local globalSettingsUIListLayout = Instance.new("UIListLayout")
    globalSettingsUIListLayout.Padding = UDim.new(0, 5)
    globalSettingsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    globalSettingsUIListLayout.Parent = globalSettings
    local globalSettingsUIScale = Instance.new("UIScale")
    globalSettingsUIScale.Scale = 1e-07
    globalSettingsUIScale.Parent = globalSettings
    globalSettings.Parent = base

    base.Parent = macLib
    
    local BlurTarget = base
    local HS = HttpService
    local camera = workspace.CurrentCamera
    local MTREL = "Glass"
    local binds = {}
    local wedgeguid = HS:GenerateGUID(true)
    local DepthOfField

    for _,v in pairs(Lighting:GetChildren()) do
        if not v:IsA("DepthOfFieldEffect") and v:HasTag(".") then
            DepthOfField = Instance.new('DepthOfFieldEffect')
            DepthOfField.FarIntensity = 0
            DepthOfField.FocusDistance = 51.6
            DepthOfField.InFocusRadius = 50
            DepthOfField.NearIntensity = 1
            DepthOfField.Name = HS:GenerateGUID(true)
            DepthOfField:AddTag(".")
        elseif v:IsA("DepthOfFieldEffect") and v:HasTag(".") then
            DepthOfField = v
        end
    end

    if not DepthOfField then
        DepthOfField = Instance.new('DepthOfFieldEffect')
        DepthOfField.FarIntensity = 0
        DepthOfField.FocusDistance = 51.6
        DepthOfField.InFocusRadius = 50
        DepthOfField.NearIntensity = 1
        DepthOfField.Name = HS:GenerateGUID(true)
        DepthOfField:AddTag(".")
    end

    local frame = Instance.new('Frame')
    frame.Parent = BlurTarget
    frame.Size = UDim2.new(0.97, 0, 0.97, 0)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundTransparency = 1
    frame.Name = HS:GenerateGUID(true)

    local function IsNotNaN(x)
        return x == x
    end
    local continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
    while not continue do
        RunService.RenderStepped:Wait()
        continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
    end

    local function DrawQuad(v1, v2, v3, v4, parts)
        local function DrawTriangle(v1, v2, v3, p0, p1)
            local s1 = (v1 - v2).magnitude
            local s2 = (v2 - v3).magnitude
            local s3 = (v3 - v1).magnitude
            local smax = math.max(s1, s2, s3)
            local A, B, C
            if s1 == smax then
                A, B, C = v1, v2, v3
            elseif s2 == smax then
                A, B, C = v2, v3, v1
            elseif s3 == smax then
                A, B, C = v3, v1, v2
            end
            local para = ((B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z) / (A-B).magnitude
            local perp = math.sqrt((C-A).magnitude^2 - para*para)
            local dif_para = (A - B).magnitude - para
            local st = CFrame.new(B, A)
            local za = CFrame.Angles(math.pi/2,0,0)
            local cf0 = st
            local Top_Look = (cf0 * za).lookVector
            local Mid_Point = A + CFrame.new(A, B).lookVector * para
            local Needed_Look = CFrame.new(Mid_Point, C).lookVector
            local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.z*Needed_Look.z
            local ac = CFrame.Angles(0, 0, math.acos(dot))
            cf0 = cf0 * ac
            if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
                cf0 = cf0 * CFrame.Angles(0, 0, -2*math.acos(dot))
            end
            cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))
            local cf1 = st * ac * CFrame.Angles(0, math.pi, 0)
            if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
                cf1 = cf1 * CFrame.Angles(0, 0, 2*math.acos(dot))
            end
            cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)
            if not p0 then
                p0 = Instance.new('Part')
                p0.FormFactor = 'Custom'
                p0.TopSurface = 0
                p0.BottomSurface = 0
                p0.Anchored = true
                p0.CanCollide = false
                p0.CastShadow = false
                p0.Material = MTREL
                p0.Size = Vector3.new(0.2, 0.2, 0.2)
                p0.Name = HS:GenerateGUID(true)
                local mesh = Instance.new('SpecialMesh', p0)
                mesh.MeshType = 2
                mesh.Name = wedgeguid
            end
            p0[wedgeguid].Scale = Vector3.new(0, perp/0.2, para/0.2)
            p0.CFrame = cf0
            if not p1 then
                p1 = p0:clone()
            end
            p1[wedgeguid].Scale = Vector3.new(0, perp/0.2, dif_para/0.2)
            p1.CFrame = cf1
            return p0, p1
        end
        parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
        parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
    end

    if binds[frame] then
        return binds[frame].parts
    end

    local parts = {}
    local parents = {}
    local function add(child)
        if child:IsA'GuiObject' then
            parents[#parents + 1] = child
            add(child.Parent)
        end
    end
    add(frame)

    local function IsVisible(instance)
        while instance do
            if instance:IsA("GuiObject") then
                if not instance.Visible then
                    return false
                end
            elseif instance:IsA("ScreenGui") then
                if not instance.Enabled then
                    return false
                end
                break
            end
            instance = instance.Parent
        end
        return true
    end

    local function UpdateOrientation(fetchProps)
        if not IsVisible(frame) or not acrylicBlur or unloaded then
            for _, pt in pairs(parts) do
                pt.Parent = nil
                DepthOfField.Enabled = false
                DepthOfField.Parent = nil
            end
            return
        end
        if not DepthOfField.Parent then
            DepthOfField.Parent = Lighting
        end
        DepthOfField.Enabled = true
        local properties = {
            Transparency = 0.98;
            BrickColor = BrickColor.new('Institutional white');
        }
        local zIndex = 1 - 0.05*frame.ZIndex
        local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
        local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
        local rot = 0;
        for _, v in ipairs(parents) do
            rot = rot + v.Rotation
        end
        if rot ~= 0 and rot%180 ~= 0 then
            local mid = tl:lerp(br, 0.5)
            local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
            local vec = tl
            tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid
            tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid
            bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid
            br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid
        end
        DrawQuad(
            camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin,
            camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin,
            camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin,
            camera:ScreenPointToRay(br.x, br.y, zIndex).Origin,
            parts
        )
        if fetchProps then
            for _, pt in pairs(parts) do
                pt.Parent = camera
            end
            for propName, propValue in pairs(properties) do
                for _, pt in pairs(parts) do
                    pt[propName] = propValue
                end
            end
        end
    end

    UpdateOrientation(true)
    RunService.RenderStepped:Connect(UpdateOrientation)

    function WindowFunctions:UpdateTitle(NewTitle)
        title.Text = NewTitle
    end

    function WindowFunctions:UpdateSubtitle(NewSubtitle)
        subtitle.Text = NewSubtitle
    end

    function WindowFunctions:GlobalSetting(Settings)
        hasGlobalSetting = true
        local GlobalSettingFunctions = {}
        local globalSetting = Instance.new("TextButton")
        globalSetting.Name = "GlobalSetting"
        globalSetting.Text = ""
        globalSetting.BackgroundTransparency = 1
        globalSetting.BorderSizePixel = 0
        globalSetting.Size = UDim2.fromOffset(200, ApplyDPIScale(30))
        local globalSettingToggleUIPadding = Instance.new("UIPadding")
        globalSettingToggleUIPadding.PaddingLeft = UDim.new(0, ApplyDPIScale(15))
        globalSettingToggleUIPadding.Parent = globalSetting

        local settingName = Instance.new("TextLabel")
        settingName.Name = "SettingName"
        settingName.FontFace = Font.new(assets.interFont)
        settingName.Text = Settings.Name
        settingName.RichText = true
        settingName.TextColor3 = Color3.fromRGB(255, 255, 255)
        settingName.TextSize = ApplyDPIScale(13)
        settingName.TextTransparency = 0.5
        settingName.TextTruncate = Enum.TextTruncate.SplitWord
        settingName.TextXAlignment = Enum.TextXAlignment.Left
        settingName.TextYAlignment = Enum.TextYAlignment.Top
        settingName.AnchorPoint = Vector2.new(0, 0.5)
        settingName.AutomaticSize = Enum.AutomaticSize.Y
        settingName.BackgroundTransparency = 1
        settingName.BorderSizePixel = 0
        settingName.Position = UDim2.fromScale(0, 0.5)
        settingName.Size = UDim2.new(1, -40, 0, 0)
        settingName.Parent = globalSetting

        local globalSettingToggleUIListLayout = Instance.new("UIListLayout")
        globalSettingToggleUIListLayout.Padding = UDim.new(0, 10)
        globalSettingToggleUIListLayout.FillDirection = Enum.FillDirection.Horizontal
        globalSettingToggleUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        globalSettingToggleUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        globalSettingToggleUIListLayout.Parent = globalSetting

        local checkmark = Instance.new("TextLabel")
        checkmark.Name = "Checkmark"
        checkmark.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        checkmark.Text = "✓"
        checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
        checkmark.TextSize = ApplyDPIScale(13)
        checkmark.TextTransparency = 1
        checkmark.TextXAlignment = Enum.TextXAlignment.Left
        checkmark.TextYAlignment = Enum.TextYAlignment.Top
        checkmark.AnchorPoint = Vector2.new(0, 0.5)
        checkmark.AutomaticSize = Enum.AutomaticSize.Y
        checkmark.BackgroundTransparency = 1
        checkmark.BorderSizePixel = 0
        checkmark.LayoutOrder = -1
        checkmark.Position = UDim2.fromScale(0, 0.5)
        checkmark.Size = UDim2.fromOffset(-10, 0)
        checkmark.Parent = globalSetting

        globalSetting.Parent = globalSettings

        local tweensettings = {
            duration = 0.2,
            easingStyle = Enum.EasingStyle.Quint,
            transparencyIn = 0.2,
            transparencyOut = 0.5,
            checkSizeIncrease = ApplyDPIScale(12),
            checkSizeDecrease = -globalSettingToggleUIListLayout.Padding.Offset,
            waitTime = 1
        }

        local tweens = {
            checkIn = Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
            }),
            checkOut = Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
            }),
            nameIn = Tween(settingName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                TextTransparency = tweensettings.transparencyIn
            }),
            nameOut = Tween(settingName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                TextTransparency = tweensettings.transparencyOut
            })
        }

        local function Toggle(State)
            if not State then
                tweens.checkOut:Play()
                tweens.nameOut:Play()
                checkmark:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    if checkmark.AbsoluteSize.X <= 0 then
                        checkmark.TextTransparency = 1
                    end
                end)
            else
                tweens.checkIn:Play()
                tweens.nameIn:Play()
                checkmark:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    if checkmark.AbsoluteSize.X > 0 then
                        checkmark.TextTransparency = 0
                    end
                end)
            end
        end

        local toggled = Settings.Default
        Toggle(toggled)

        globalSetting.MouseButton1Click:Connect(function()
            toggled = not toggled
            Toggle(toggled)
            task.spawn(function()
                if Settings.Callback then
                    Settings.Callback(toggled)
                end
            end)
        end)

        function GlobalSettingFunctions:UpdateName(NewName)
            settingName.Text = NewName
        end

        function GlobalSettingFunctions:UpdateState(NewState)
            Toggle(NewState)
            toggled = NewState
        end

        return GlobalSettingFunctions
    end

    local hovering
    local toggled = globalSettingsUIScale.Scale == 1 and true or false

    local function toggle()
        if not toggled then
            local intween = Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Scale = 1})
            intween:Play()
            intween.Completed:Wait()
            toggled = true
        elseif toggled then
            local outtween = Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Scale = 0})
            outtween:Play()
            outtween.Completed:Wait()
            toggled = false
        end
    end

    globalSettingsButton.MouseButton1Click:Connect(function()
        if not hasGlobalSetting then return end
        toggle()
    end)

    globalSettings.MouseEnter:Connect(function()
        hovering = true
    end)

    globalSettings.MouseLeave:Connect(function()
        hovering = false
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 and toggled and not hovering then
            toggle()
        end
    end)

    function WindowFunctions:Notification(Settings)
        local NotificationFunctions = {}
        local notification = Instance.new("Frame")
        notification.Name = "Notification"
        notification.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        notification.BackgroundTransparency = 0
        notification.BorderSizePixel = 0
        notification.Size = UDim2.fromOffset(0, 0)
        notification.AutomaticSize = Enum.AutomaticSize.XY
        notification.ZIndex = 2
        notification.Parent = notifications
        local notificationUIStroke = Instance.new("UIStroke")
        notificationUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        notificationUIStroke.Color = Color3.fromRGB(255, 255, 255)
        notificationUIStroke.Transparency = 0.9
        notificationUIStroke.Parent = notification
        local notificationUICorner = Instance.new("UICorner")
        notificationUICorner.CornerRadius = UDim.new(0, 8)
        notificationUICorner.Parent = notification

        local notificationTitle = Instance.new("TextLabel")
        notificationTitle.Name = "NotificationTitle"
        notificationTitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        notificationTitle.Text = Settings.Title or "Notification"
        notificationTitle.RichText = true
        notificationTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        notificationTitle.TextSize = ApplyDPIScale(16)
        notificationTitle.TextTransparency = 0.1
        notificationTitle.TextXAlignment = Enum.TextXAlignment.Left
        notificationTitle.TextYAlignment = Enum.TextYAlignment.Top
        notificationTitle.AutomaticSize = Enum.AutomaticSize.Y
        notificationTitle.BackgroundTransparency = 1
        notificationTitle.BorderSizePixel = 0
        notificationTitle.Size = UDim2.new(1, -40, 0, 0)
        notificationTitle.Parent = notification

        local notificationText = Instance.new("TextLabel")
        notificationText.Name = "NotificationText"
        notificationText.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        notificationText.Text = Settings.Text or ""
        notificationText.RichText = true
        notificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
        notificationText.TextSize = ApplyDPIScale(13)
        notificationText.TextTransparency = 0.3
        notificationText.TextXAlignment = Enum.TextXAlignment.Left
        notificationText.TextYAlignment = Enum.TextYAlignment.Top
        notificationText.AutomaticSize = Enum.AutomaticSize.Y
        notificationText.BackgroundTransparency = 1
        notificationText.BorderSizePixel = 0
        notificationText.LayoutOrder = 1
        notificationText.Size = UDim2.new(1, -40, 0, 0)
        notificationText.Parent = notification

        local notificationUIPadding = Instance.new("UIPadding")
        notificationUIPadding.PaddingBottom = UDim.new(0, ApplyDPIScale(15))
        notificationUIPadding.PaddingLeft = UDim.new(0, ApplyDPIScale(20))
        notificationUIPadding.PaddingRight = UDim.new(0, ApplyDPIScale(20))
        notificationUIPadding.PaddingTop = UDim.new(0, ApplyDPIScale(15))
        notificationUIPadding.Parent = notification

        local duration = Settings.Duration or 5
        task.spawn(function()
            Tween(notification, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = notification.Size
            }):Play()
            task.wait(duration)
            Tween(notification, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset(0, 0)
            }):Play()
            task.wait(0.25)
            notification:Destroy()
        end)

        function NotificationFunctions:Hide()
            notification:Destroy()
        end

        return NotificationFunctions
    end

    function WindowFunctions:TabGroup()
        local SectionFunctions = {}
        local tabGroup = Instance.new("Frame")
        tabGroup.Name = "Section"
        tabGroup.AutomaticSize = Enum.AutomaticSize.Y
        tabGroup.BackgroundTransparency = 1
        tabGroup.BorderSizePixel = 0
        tabGroup.Size = UDim2.fromScale(1, 0)

        local divider3 = Instance.new("Frame")
        divider3.Name = "Divider"
        divider3.AnchorPoint = Vector2.new(0.5, 1)
        divider3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        divider3.BackgroundTransparency = 0.9
        divider3.BorderSizePixel = 0
        divider3.Position = UDim2.fromScale(0.5, 1)
        divider3.Size = UDim2.new(1, -21, 0, 1)
        divider3.Parent = tabGroup

        local sectionTabSwitchers = Instance.new("Frame")
        sectionTabSwitchers.Name = "SectionTabSwitchers"
        sectionTabSwitchers.BackgroundTransparency = 1
        sectionTabSwitchers.BorderSizePixel = 0
        sectionTabSwitchers.Size = UDim2.fromScale(1, 1)
        local uIListLayout1 = Instance.new("UIListLayout")
        uIListLayout1.Padding = UDim.new(0, ApplyDPIScale(15))
        uIListLayout1.HorizontalAlignment = Enum.HorizontalAlignment.Center
        uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
        uIListLayout1.Parent = sectionTabSwitchers
        local uIPadding1 = Instance.new("UIPadding")
        uIPadding1.PaddingBottom = UDim.new(0, ApplyDPIScale(15))
        uIPadding1.Parent = sectionTabSwitchers
        sectionTabSwitchers.Parent = tabGroup
        tabGroup.Parent = tabSwitchersScrollingFrame

        function SectionFunctions:Tab(Settings)
            local TabFunctions = {Settings = Settings}
            local tabSwitcher = Instance.new("TextButton")
            tabSwitcher.Name = "TabSwitcher"
            tabSwitcher.Text = ""
            tabSwitcher.AutoButtonColor = false
            tabSwitcher.AnchorPoint = Vector2.new(0.5, 0)
            tabSwitcher.BackgroundTransparency = 1
            tabSwitcher.BorderSizePixel = 0
            tabSwitcher.Position = UDim2.fromScale(0.5, 0)
            tabSwitcher.Size = UDim2.new(1, -21, 0, ApplyDPIScale(40))

            tabIndex += 1
            tabSwitcher.LayoutOrder = tabIndex

            local tabSwitcherUICorner = Instance.new("UICorner")
            tabSwitcherUICorner.Parent = tabSwitcher

            local tabSwitcherUIStroke = Instance.new("UIStroke")
            tabSwitcherUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            tabSwitcherUIStroke.Color = Color3.fromRGB(255, 255, 255)
            tabSwitcherUIStroke.Transparency = 1
            tabSwitcherUIStroke.Parent = tabSwitcher

            local tabSwitcherUIListLayout = Instance.new("UIListLayout")
            tabSwitcherUIListLayout.Padding = UDim.new(0, ApplyDPIScale(9))
            tabSwitcherUIListLayout.FillDirection = Enum.FillDirection.Horizontal
            tabSwitcherUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            tabSwitcherUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            tabSwitcherUIListLayout.Parent = tabSwitcher

            local tabImage
            if Settings.Image then
                tabImage = Instance.new("ImageLabel")
                tabImage.Name = "TabImage"
                tabImage.Image = Settings.Image
                tabImage.ImageTransparency = 0.5
                tabImage.BackgroundTransparency = 1
                tabImage.BorderSizePixel = 0
                tabImage.Size = UDim2.fromOffset(18, 18)
                tabImage.Parent = tabSwitcher
            end

            local tabSwitcherName = Instance.new("TextLabel")
            tabSwitcherName.Name = "TabSwitcherName"
            tabSwitcherName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
            tabSwitcherName.Text = Settings.Name
            tabSwitcherName.RichText = true
            tabSwitcherName.TextColor3 = Color3.fromRGB(255, 255, 255)
            tabSwitcherName.TextSize = ApplyDPIScale(16)
            tabSwitcherName.TextTransparency = 0.5
            tabSwitcherName.TextTruncate = Enum.TextTruncate.SplitWord
            tabSwitcherName.TextXAlignment = Enum.TextXAlignment.Left
            tabSwitcherName.TextYAlignment = Enum.TextYAlignment.Top
            tabSwitcherName.AutomaticSize = Enum.AutomaticSize.Y
            tabSwitcherName.BackgroundTransparency = 1
            tabSwitcherName.BorderSizePixel = 0
            tabSwitcherName.Size = UDim2.fromScale(1, 0)
            tabSwitcherName.Parent = tabSwitcher
            tabSwitcherName.LayoutOrder = 1

            local tabSwitcherUIPadding = Instance.new("UIPadding")
            tabSwitcherUIPadding.PaddingLeft = UDim.new(0, ApplyDPIScale(24))
            tabSwitcherUIPadding.PaddingRight = UDim.new(0, ApplyDPIScale(35))
            tabSwitcherUIPadding.PaddingTop = UDim.new(0, 1)
            tabSwitcherUIPadding.Parent = tabSwitcher
            tabSwitcher.Parent = sectionTabSwitchers

            local elements1_copy = elements1:Clone()
            elements1_copy.Name = "Elements"
            elements1_copy.Visible = false
            elements1_copy.Parent = content

            local tabElements = {
                Left = elements1_copy.ElementsScrolling.Left,
                Right = elements1_copy.ElementsScrolling.Right,
                Holder = elements1_copy
            }

            function TabFunctions:Section(Settings)
                local SectionFunctions = {}
                local section = Instance.new("Frame")
                section.Name = "Section"
                section.AutomaticSize = Enum.AutomaticSize.Y
                section.BackgroundTransparency = 0.98
                section.BorderSizePixel = 0
                section.Position = UDim2.fromScale(0, 0)
                section.Size = UDim2.fromScale(1, 0)
                section.ClipsDescendants = true
                section.Parent = Settings.Side == "Left" and tabElements.Left or tabElements.Right
                local sectionUICorner = Instance.new("UICorner")
                sectionUICorner.Parent = section
                local sectionUIStroke = Instance.new("UIStroke")
                sectionUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                sectionUIStroke.Color = Color3.fromRGB(255, 255, 255)
                sectionUIStroke.Transparency = 0.95
                sectionUIStroke.Parent = section
                local sectionUIListLayout = Instance.new("UIListLayout")
                sectionUIListLayout.Padding = UDim.new(0, ApplyDPIScale(10))
                sectionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                sectionUIListLayout.Parent = section
                local sectionUIPadding = Instance.new("UIPadding")
                sectionUIPadding.PaddingBottom = UDim.new(0, ApplyDPIScale(20))
                sectionUIPadding.PaddingLeft = UDim.new(0, ApplyDPIScale(20))
                sectionUIPadding.PaddingRight = UDim.new(0, ApplyDPIScale(18))
                sectionUIPadding.PaddingTop = UDim.new(0, ApplyDPIScale(22))
                sectionUIPadding.Parent = section

                function SectionFunctions:Button(Settings, Flag)
                    local ButtonFunctions = {Settings = Settings}
                    local button = Instance.new("Frame")
                    button.Name = "Button"
                    button.AutomaticSize = Enum.AutomaticSize.Y
                    button.BackgroundTransparency = 1
                    button.BorderSizePixel = 0
                    button.Size = UDim2.new(1, 0, 0, ApplyDPIScale(38))
                    button.Parent = section

                    local buttonInteract = Instance.new("TextButton")
                    buttonInteract.Name = "ButtonInteract"
                    buttonInteract.FontFace = Font.new(assets.interFont)
                    buttonInteract.RichText = true
                    buttonInteract.TextColor3 = Color3.fromRGB(255, 255, 255)
                    buttonInteract.TextSize = ApplyDPIScale(13)
                    buttonInteract.TextTransparency = 0.5
                    buttonInteract.TextTruncate = Enum.TextTruncate.AtEnd
                    buttonInteract.TextXAlignment = Enum.TextXAlignment.Left
                    buttonInteract.BackgroundTransparency = 1
                    buttonInteract.BorderSizePixel = 0
                    buttonInteract.Size = UDim2.fromScale(1, 1)
                    buttonInteract.Parent = button
                    buttonInteract.Text = Settings.Name

                    local buttonImage = Instance.new("ImageLabel")
                    buttonImage.Name = "ButtonImage"
                    buttonImage.Image = assets.buttonImage
                    buttonImage.ImageTransparency = 0.5
                    buttonImage.AnchorPoint = Vector2.new(1, 0.5)
                    buttonImage.BackgroundTransparency = 1
                    buttonImage.BorderSizePixel = 0
                    buttonImage.Position = UDim2.fromScale(1, 0.5)
                    buttonImage.Size = UDim2.fromOffset(15, 15)
                    buttonImage.Parent = button

                    local TweenSettings = {
                        DefaultTransparency = 0.5,
                        HoverTransparency = 0.3,
                        EasingStyle = Enum.EasingStyle.Sine
                    }

                    local function ChangeState(State)
                        if State == "Idle" then
                            Tween(buttonInteract, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
                                TextTransparency = TweenSettings.DefaultTransparency
                            }):Play()
                            Tween(buttonImage, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
                                ImageTransparency = TweenSettings.DefaultTransparency
                            }):Play()
                        elseif State == "Hover" then
                            Tween(buttonInteract, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
                                TextTransparency = TweenSettings.HoverTransparency
                            }):Play()
                            Tween(buttonImage, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
                                ImageTransparency = TweenSettings.HoverTransparency
                            }):Play()
                        end
                    end

                    local function Callback()
                        if Settings.Callback then
                            Settings.Callback()
                        end
                    end

                    buttonInteract.MouseEnter:Connect(function()
                        ChangeState("Hover")
                    end)
                    buttonInteract.MouseLeave:Connect(function()
                        ChangeState("Idle")
                    end)
                    buttonInteract.MouseButton1Click:Connect(Callback)

                    function ButtonFunctions:UpdateName(Name)
                        buttonInteract.Text = Name
                    end

                    function ButtonFunctions:SetVisibility(State)
                        button.Visible = State
                    end

                    if Flag then
                        MacLib.Options[Flag] = ButtonFunctions
                    end
                    return ButtonFunctions
                end

                function SectionFunctions:Toggle(Settings, Flag)
                    local ToggleFunctions = {Settings = Settings}
                    local toggle = Instance.new("Frame")
                    toggle.Name = "Toggle"
                    toggle.AutomaticSize = Enum.AutomaticSize.Y
                    toggle.BackgroundTransparency = 1
                    toggle.BorderSizePixel = 0
                    toggle.Size = UDim2.new(1, 0, 0, ApplyDPIScale(38))
                    toggle.Parent = section

                    local toggleName = Instance.new("TextLabel")
                    toggleName.Name = "ToggleName"
                    toggleName.FontFace = Font.new(assets.interFont)
                    toggleName.Text = Settings.Name
                    toggleName.RichText = true
                    toggleName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    toggleName.TextSize = ApplyDPIScale(13)
                    toggleName.TextTransparency = 0.5
                    toggleName.TextTruncate = Enum.TextTruncate.AtEnd
                    toggleName.TextXAlignment = Enum.TextXAlignment.Left
                    toggleName.TextYAlignment = Enum.TextYAlignment.Top
                    toggleName.AnchorPoint = Vector2.new(0, 0.5)
                    toggleName.AutomaticSize = Enum.AutomaticSize.Y
                    toggleName.BackgroundTransparency = 1
                    toggleName.BorderSizePixel = 0
                    toggleName.Position = UDim2.fromScale(0, 0.5)
                    toggleName.Size = UDim2.new(1, -50, 0, 0)
                    toggleName.Parent = toggle

                    local toggle1 = Instance.new("ImageButton")
                    toggle1.Name = "Toggle"
                    toggle1.Image = assets.toggleBackground
                    toggle1.ImageColor3 = Color3.fromRGB(87, 86, 86)
                    toggle1.AutoButtonColor = false
                    toggle1.AnchorPoint = Vector2.new(1, 0.5)
                    toggle1.BackgroundTransparency = 1
                    toggle1.BorderSizePixel = 0
                    toggle1.Position = UDim2.fromScale(1, 0.5)
                    toggle1.Size = UDim2.fromOffset(41, 21)
                    toggle1.ImageTransparency = 0.5
                    local toggleUIPadding = Instance.new("UIPadding")
                    toggleUIPadding.PaddingBottom = UDim.new(0, ApplyDPIScale(1))
                    toggleUIPadding.PaddingLeft = UDim.new(0, -2)
                    toggleUIPadding.PaddingRight = UDim.new(0, 3)
                    toggleUIPadding.PaddingTop = UDim.new(0, ApplyDPIScale(1))
                    toggleUIPadding.Parent = toggle1

                    local togglerHead = Instance.new("ImageLabel")
                    togglerHead.Name = "TogglerHead"
                    togglerHead.Image = assets.togglerHead
                    togglerHead.ImageColor3 = Color3.fromRGB(255, 255, 255)
                    togglerHead.AnchorPoint = Vector2.new(1, 0.5)
                    togglerHead.BackgroundTransparency = 1
                    togglerHead.BorderSizePixel = 0
                    togglerHead.Position = UDim2.fromScale(0.5, 0.5)
                    togglerHead.Size = UDim2.fromOffset(15, 15)
                    togglerHead.ZIndex = 2
                    togglerHead.Parent = toggle1
                    togglerHead.ImageTransparency = 0.8
                    toggle1.Parent = toggle

                    local toggle1Transparency = {Enabled = 0, Disabled = 0.5}
                    local togglerHeadTransparency = {Enabled = 0, Disabled = 0.85}

                    local TweenSettings = {
                        Info = TweenInfo.new(0.15, Enum.EasingStyle.Quad),
                        EnabledPosition = UDim2.new(1, 0, 0.5, 0),
                        DisabledPosition = UDim2.new(0.5, 0, 0.5, 0),
                    }

                    local togglebool = Settings.Default
                    local function NewState(State, callback)
                        local transparencyValues = State and {toggle1Transparency.Enabled, togglerHeadTransparency.Enabled} or {toggle1Transparency.Disabled, togglerHeadTransparency.Disabled}
                        local position = State and TweenSettings.EnabledPosition or TweenSettings.DisabledPosition
                        Tween(toggle1, TweenSettings.Info, {ImageTransparency = transparencyValues[1]}):Play()
                        Tween(togglerHead, TweenSettings.Info, {ImageTransparency = transparencyValues[2]}):Play()
                        Tween(togglerHead, TweenSettings.Info, {Position = position}):Play()
                        ToggleFunctions.State = State
                        if callback then
                            callback(togglebool)
                        end
                    end

                    NewState(togglebool)
                    local function Toggle()
                        togglebool = not togglebool
                        NewState(togglebool, Settings.Callback)
                    end
                    toggle1.MouseButton1Click:Connect(Toggle)

                    function ToggleFunctions:Toggle()
                        Toggle()
                    end

                    function ToggleFunctions:UpdateState(State)
                        togglebool = State
                        NewState(togglebool, Settings.Callback)
                    end

                    function ToggleFunctions:GetState()
                        return togglebool
                    end

                    function ToggleFunctions:UpdateName(Name)
                        toggleName.Text = Name
                    end

                    function ToggleFunctions:SetVisibility(State)
                        toggle.Visible = State
                    end

                    if Flag then
                        MacLib.Options[Flag] = ToggleFunctions
                    end
                    return ToggleFunctions
                end

                function SectionFunctions:Slider(Settings, Flag)
                    local SliderFunctions = {Settings = Settings}
                    local slider = Instance.new("Frame")
                    slider.Name = "Slider"
                    slider.AutomaticSize = Enum.AutomaticSize.Y
                    slider.BackgroundTransparency = 1
                    slider.BorderSizePixel = 0
                    slider.Size = UDim2.new(1, 0, 0, ApplyDPIScale(38))
                    slider.Parent = section

                    local sliderName = Instance.new("TextLabel")
                    sliderName.Name = "SliderName"
                    sliderName.FontFace = Font.new(assets.interFont)
                    sliderName.Text = Settings.Name
                    sliderName.RichText = true
                    sliderName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    sliderName.TextSize = ApplyDPIScale(13)
                    sliderName.TextTransparency = 0.5
                    sliderName.TextTruncate = Enum.TextTruncate.AtEnd
                    sliderName.TextXAlignment = Enum.TextXAlignment.Left
                    sliderName.TextYAlignment = Enum.TextYAlignment.Top
                    sliderName.AnchorPoint = Vector2.new(0, 0.5)
                    sliderName.AutomaticSize = Enum.AutomaticSize.XY
                    sliderName.BackgroundTransparency = 1
                    sliderName.BorderSizePixel = 0
                    sliderName.Position = UDim2.fromScale(0, 0.5)
                    sliderName.Parent = slider

                    local sliderElements = Instance.new("Frame")
                    sliderElements.Name = "SliderElements"
                    sliderElements.AnchorPoint = Vector2.new(1, 0)
                    sliderElements.BackgroundTransparency = 1
                    sliderElements.BorderSizePixel = 0
                    sliderElements.Position = UDim2.fromScale(1, 0)
                    sliderElements.Size = UDim2.fromScale(1, 1)

                    local sliderValue = Instance.new("TextBox")
                    sliderValue.Name = "SliderValue"
                    sliderValue.FontFace = Font.new(assets.interFont)
                    sliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
                    sliderValue.TextSize = ApplyDPIScale(12)
                    sliderValue.TextTransparency = 0.1
                    sliderValue.BackgroundTransparency = 0.95
                    sliderValue.BorderSizePixel = 0
                    sliderValue.LayoutOrder = 1
                    sliderValue.Position = UDim2.fromScale(-0.0789, 0.171)
                    sliderValue.Size = UDim2.fromOffset(41, ApplyDPIScale(21))
                    sliderValue.ClipsDescendants = true
                    local sliderValueUICorner = Instance.new("UICorner")
                    sliderValueUICorner.CornerRadius = UDim.new(0, 4)
                    sliderValueUICorner.Parent = sliderValue
                    local sliderValueUIStroke = Instance.new("UIStroke")
                    sliderValueUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    sliderValueUIStroke.Color = Color3.fromRGB(255, 255, 255)
                    sliderValueUIStroke.Transparency = 0.9
                    sliderValueUIStroke.Parent = sliderValue
                    local sliderValueUIPadding = Instance.new("UIPadding")
                    sliderValueUIPadding.PaddingLeft = UDim.new(0, 2)
                    sliderValueUIPadding.PaddingRight = UDim.new(0, 2)
                    sliderValueUIPadding.Parent = sliderValue
                    sliderValue.Parent = sliderElements

                    local sliderElementsUIListLayout = Instance.new("UIListLayout")
                    sliderElementsUIListLayout.Padding = UDim.new(0, 20)
                    sliderElementsUIListLayout.FillDirection = Enum.FillDirection.Horizontal
                    sliderElementsUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                    sliderElementsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    sliderElementsUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                    sliderElementsUIListLayout.Parent = sliderElements

                    local sliderBar = Instance.new("ImageLabel")
                    sliderBar.Name = "SliderBar"
                    sliderBar.Image = assets.sliderbar
                    sliderBar.ImageColor3 = Color3.fromRGB(87, 86, 86)
                    sliderBar.BackgroundTransparency = 1
                    sliderBar.BorderSizePixel = 0
                    sliderBar.Position = UDim2.fromScale(0.219, 0.457)
                    sliderBar.Size = UDim2.fromOffset(123, 3)

                    local sliderHead = Instance.new("ImageButton")
                    sliderHead.Name = "SliderHead"
                    sliderHead.Image = assets.sliderhead
                    sliderHead.AnchorPoint = Vector2.new(0.5, 0.5)
                    sliderHead.BackgroundTransparency = 1
                    sliderHead.BorderSizePixel = 0
                    sliderHead.Position = UDim2.fromScale(1, 0.5)
                    sliderHead.Size = UDim2.fromOffset(ApplyDPIScale(12), ApplyDPIScale(12))
                    sliderHead.Parent = sliderBar
                    sliderBar.Parent = sliderElements
                    local sliderElementsUIPadding = Instance.new("UIPadding")
                    sliderElementsUIPadding.PaddingTop = UDim.new(0, 3)
                    sliderElementsUIPadding.Parent = sliderElements
                    sliderElements.Parent = slider

                    local DisplayMethods = {
                        Hundredths = function(sliderValue)
                            return string.format("%.2f", sliderValue)
                        end,
                        Tenths = function(sliderValue)
                            return string.format("%.1f", sliderValue)
                        end,
                        Round = function(sliderValue, precision)
                            if precision then
                                return string.format("%." .. precision .. "f", sliderValue)
                            else
                                return tostring(math.round(sliderValue))
                            end
                        end,
                        Degrees = function(sliderValue, precision)
                            local formattedValue = precision and string.format("%." .. precision .. "f", sliderValue) or tostring(sliderValue)
                            return formattedValue .. "°"
                        end,
                        Percent = function(sliderValue, precision)
                            local percentage = (sliderValue - Settings.Minimum) / (Settings.Maximum - Settings.Minimum) * 100
                            return precision and string.format("%." .. precision .. "f", percentage) .. "%" or tostring(math.round(percentage)) .. "%"
                        end,
                        Value = function(sliderValue, precision)
                            return precision and string.format("%." .. precision .. "f", sliderValue) or tostring(sliderValue)
                        end
                    }

                    local ValueDisplayMethod = DisplayMethods[Settings.DisplayMethod] or DisplayMethods.Value
                    local finalValue

                    local function SetValue(val, ignorecallback)
                        local posXScale
                        if typeof(val) == "Instance" then
                            local input = val
                            posXScale = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                        else
                            local value = val
                            posXScale = (value - Settings.Minimum) / (Settings.Maximum - Settings.Minimum)
                        end
                        local pos = UDim2.new(posXScale, 0, 0.5, 0)
                        sliderHead.Position = pos
                        finalValue = posXScale * (Settings.Maximum - Settings.Minimum) + Settings.Minimum
                        sliderValue.Text = (Settings.Prefix or "") .. ValueDisplayMethod(finalValue, Settings.Precision) .. (Settings.Suffix or "")
                        if not ignorecallback and Settings.Callback then
                            Settings.Callback(finalValue)
                        end
                    end

                    SliderFunctions.Value = finalValue
                    SetValue(Settings.Default, true)

                    sliderHead.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            SetValue(input)
                        end
                    end)

                    sliderHead.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                            if Settings.onInputComplete then
                                Settings.onInputComplete(finalValue)
                            end
                        end
                    end)

                    sliderValue.FocusLost:Connect(function(enterPressed)
                        local inputText = sliderValue.Text
                        local value, isPercent = inputText:match("^(%-?%d+%.?%d*)(%%?)$")
                        if value then
                            value = tonumber(value)
                            isPercent = isPercent == "%"
                            if isPercent then
                                value = Settings.Minimum + (value / 100) * (Settings.Maximum - Settings.Minimum)
                            end
                            local newValue = math.clamp(value, Settings.Minimum, Settings.Maximum)
                            SetValue(newValue)
                        else
                            sliderValue.Text = ValueDisplayMethod(sliderValue)
                        end
                        if Settings.onInputComplete then
                            Settings.onInputComplete(finalValue)
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if dragging then
                            SetValue(input)
                        end
                    end)

                    local function updateSliderBarSize()
                        local padding = sliderElementsUIListLayout.Padding.Offset
                        local sliderValueWidth = sliderValue.AbsoluteSize.X
                        local sliderNameWidth = sliderName.AbsoluteSize.X
                        local totalWidth = sliderElements.AbsoluteSize.X
                        local newBarWidth = (totalWidth - (padding + sliderValueWidth + sliderNameWidth + ApplyDPIScale(20))) / baseUIScale.Scale
                        sliderBar.Size = UDim2.new(sliderBar.Size.X.Scale, newBarWidth, sliderBar.Size.Y.Scale, sliderBar.Size.Y.Offset)
                    end

                    updateSliderBarSize()
                    sliderName:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSliderBarSize)
                    section:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSliderBarSize)

                    function SliderFunctions:UpdateName(Name)
                        sliderName = Name
                    end

                    function SliderFunctions:SetVisibility(State)
                        slider.Visible = State
                    end

                    function SliderFunctions:UpdateValue(Value)
                        SetValue(tonumber(Value), true)
                    end

                    function SliderFunctions:GetValue()
                        return finalValue
                    end

                    if Flag then
                        MacLib.Options[Flag] = SliderFunctions
                    end
                    return SliderFunctions
                end

                function SectionFunctions:Input(Settings, Flag)
                    local InputFunctions = {Settings = Settings}
                    local input = Instance.new("Frame")
                    input.Name = "Input"
                    input.AutomaticSize = Enum.AutomaticSize.Y
                    input.BackgroundTransparency = 1
                    input.BorderSizePixel = 0
                    input.Size = UDim2.new(1, 0, 0, ApplyDPIScale(38))
                    input.Parent = section

                    local inputName = Instance.new("TextLabel")
                    inputName.Name = "InputName"
                    inputName.FontFace = Font.new(assets.interFont)
                    inputName.Text = Settings.Name
                    inputName.RichText = true
                    inputName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    inputName.TextSize = ApplyDPIScale(13)
                    inputName.TextTransparency = 0.5
                    inputName.TextTruncate = Enum.TextTruncate.AtEnd
                    inputName.TextXAlignment = Enum.TextXAlignment.Left
                    inputName.TextYAlignment = Enum.TextYAlignment.Top
                    inputName.AnchorPoint = Vector2.new(0, 0.5)
                    inputName.AutomaticSize = Enum.AutomaticSize.XY
                    inputName.BackgroundTransparency = 1
                    inputName.BorderSizePixel = 0
                    inputName.Position = UDim2.fromScale(0, 0.5)
                    inputName.Parent = input

                    local inputBox = Instance.new("TextBox")
                    inputBox.Name = "InputBox"
                    inputBox.FontFace = Font.new(assets.interFont)
                    inputBox.Text = Settings.Default or ""
                    inputBox.PlaceholderText = Settings.Placeholder or ""
                    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                    inputBox.TextSize = ApplyDPIScale(12)
                    inputBox.TextTransparency = 0.1
                    inputBox.AnchorPoint = Vector2.new(1, 0.5)
                    inputBox.AutomaticSize = Enum.AutomaticSize.X
                    inputBox.BackgroundTransparency = 0.95
                    inputBox.BorderSizePixel = 0
                    inputBox.ClipsDescendants = true
                    inputBox.LayoutOrder = 1
                    inputBox.Position = UDim2.fromScale(1, 0.5)
                    inputBox.Size = UDim2.fromOffset(21, ApplyDPIScale(21))
                    inputBox.TextXAlignment = Enum.TextXAlignment.Right
                    local inputBoxUICorner = Instance.new("UICorner")
                    inputBoxUICorner.CornerRadius = UDim.new(0, 4)
                    inputBoxUICorner.Parent = inputBox
                    local inputBoxUIStroke = Instance.new("UIStroke")
                    inputBoxUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    inputBoxUIStroke.Color = Color3.fromRGB(255, 255, 255)
                    inputBoxUIStroke.Transparency = 0.9
                    inputBoxUIStroke.Parent = inputBox
                    local inputBoxUIPadding = Instance.new("UIPadding")
                    inputBoxUIPadding.PaddingLeft = UDim.new(0, 5)
                    inputBoxUIPadding.PaddingRight = UDim.new(0, 5)
                    inputBoxUIPadding.Parent = inputBox
                    local inputBoxUISizeConstraint = Instance.new("UISizeConstraint")
                    inputBoxUISizeConstraint.Parent = inputBox
                    inputBox.Parent = input

                    local AcceptedCharacters = Settings.AcceptedCharacters or "All"
                    local CharacterSubs = {
                        All = function(value)
                            return value
                        end,
                        Numeric = function(value)
                            local result = value:match("^%-?%d*$") and value or value:gsub("[^%d%-]", ""):gsub("(%-)", function(match, pos)
                                return pos == 1 and match or ""
                            end)
                            return result
                        end,
                        Alphabetic = function(value)
                            return value:gsub("[^a-zA-Z ]", "")
                        end,
                        AlphaNumeric = function(value)
                            return value:gsub("[^a-zA-Z0-9]", "")
                        end,
                    }

                    local function applyCharacterLimit(value)
                        if Settings.CharacterLimit then
                            return value:sub(1, Settings.CharacterLimit)
                        end
                        return value
                    end

                    local function checkSize()
                        local nameWidth = inputName.AbsoluteSize.X
                        local totalWidth = input.AbsoluteSize.X
                        local maxWidth = (totalWidth - nameWidth - ApplyDPIScale(20)) / baseUIScale.Scale
                        inputBoxUISizeConstraint.MaxSize = Vector2.new(maxWidth, 9e9)
                    end

                    checkSize()
                    inputName:GetPropertyChangedSignal("AbsoluteSize"):Connect(checkSize)

                    inputBox.FocusLost:Connect(function()
                        local inputText = inputBox.Text
                        local filteredText = applyCharacterLimit((CharacterSubs[AcceptedCharacters] or CharacterSubs.All)(inputText))
                        inputBox.Text = filteredText
                        if Settings.Callback then
                            Settings.Callback(filteredText)
                        end
                        InputFunctions.Text = filteredText
                    end)

                    inputBox:GetPropertyChangedSignal("Text"):Connect(function()
                        local filteredText = applyCharacterLimit((CharacterSubs[AcceptedCharacters] or CharacterSubs.All)(inputBox.Text))
                        if inputBox.Text ~= filteredText then
                            inputBox.Text = filteredText
                        end
                        if Settings.onChanged then
                            Settings.onChanged(inputBox.Text)
                        end
                        InputFunctions.Text = inputBox.Text
                    end)

                    function InputFunctions:UpdateName(Name)
                        inputName.Text = Name
                    end

                    function InputFunctions:SetVisibility(State)
                        input.Visible = State
                    end

                    function InputFunctions:GetInput()
                        return inputBox.Text
                    end

                    function InputFunctions:UpdatePlaceholder(Placeholder)
                        inputBox.PlaceholderText = Placeholder
                    end

                    function InputFunctions:UpdateText(Text)
                        local filteredText = applyCharacterLimit((CharacterSubs[AcceptedCharacters] or CharacterSubs.All)(Text))
                        inputBox.Text = filteredText
                        InputFunctions.Text = filteredText
                        if Settings.Callback then
                            Settings.Callback(filteredText)
                        end
                    end

                    if Flag then
                        MacLib.Options[Flag] = InputFunctions
                    end
                    return InputFunctions
                end

                function SectionFunctions:Keybind(Settings, Flag)
                    local KeybindFunctions = {Settings = Settings}
                    local keybind = Instance.new("Frame")
                    keybind.Name = "Keybind"
                    keybind.AutomaticSize = Enum.AutomaticSize.Y
                    keybind.BackgroundTransparency = 1
                    keybind.BorderSizePixel = 0
                    keybind.Size = UDim2.new(1, 0, 0, ApplyDPIScale(38))
                    keybind.Parent = section

                    local keybindName = Instance.new("TextLabel")
                    keybindName.Name = "KeybindName"
                    keybindName.FontFace = Font.new(assets.interFont)
                    keybindName.Text = Settings.Name
                    keybindName.RichText = true
                    keybindName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    keybindName.TextSize = ApplyDPIScale(13)
                    keybindName.TextTransparency = 0.5
                    keybindName.TextTruncate = Enum.TextTruncate.AtEnd
                    keybindName.TextXAlignment = Enum.TextXAlignment.Left
                    keybindName.TextYAlignment = Enum.TextYAlignment.Top
                    keybindName.AnchorPoint = Vector2.new(0, 0.5)
                    keybindName.AutomaticSize = Enum.AutomaticSize.XY
                    keybindName.BackgroundTransparency = 1
                    keybindName.BorderSizePixel = 0
                    keybindName.Position = UDim2.fromScale(0, 0.5)
                    keybindName.Parent = keybind

                    local binderBox = Instance.new("TextButton")
                    binderBox.Name = "BinderBox"
                    binderBox.Text = Settings.Default or "None"
                    binderBox.FontFace = Font.new(assets.interFont)
                    binderBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                    binderBox.TextSize = ApplyDPIScale(12)
                    binderBox.TextTransparency = 0.1
                    binderBox.AnchorPoint = Vector2.new(1, 0.5)
                    binderBox.AutomaticSize = Enum.AutomaticSize.X
                    binderBox.BackgroundTransparency = 0.95
                    binderBox.BorderSizePixel = 0
                    binderBox.ClipsDescendants = true
                    binderBox.LayoutOrder = 1
                    binderBox.Position = UDim2.fromScale(1, 0.5)
                    binderBox.Size = UDim2.fromOffset(21, ApplyDPIScale(21))
                    local binderBoxUICorner = Instance.new("UICorner")
                    binderBoxUICorner.CornerRadius = UDim.new(0, 4)
                    binderBoxUICorner.Parent = binderBox
                    local binderBoxUIStroke = Instance.new("UIStroke")
                    binderBoxUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    binderBoxUIStroke.Color = Color3.fromRGB(255, 255, 255)
                    binderBoxUIStroke.Transparency = 0.9
                    binderBoxUIStroke.Parent = binderBox
                    local binderBoxUIPadding = Instance.new("UIPadding")
                    binderBoxUIPadding.PaddingLeft = UDim.new(0, 5)
                    binderBoxUIPadding.PaddingRight = UDim.new(0, 5)
                    binderBoxUIPadding.Parent = binderBox
                    local binderBoxUISizeConstraint = Instance.new("UISizeConstraint")
                    binderBoxUISizeConstraint.Parent = binderBox
                    binderBox.Parent = keybind

                    local focused = false
                    local isBinding = false
                    local reset = false
                    local binded = Settings.Default

                    local function resetFocusState()
                        focused = false
                        isBinding = false
                    end

                    local function updateSize()
                        local nameWidth = keybindName.AbsoluteSize.X
                        local totalWidth = keybind.AbsoluteSize.X
                        local maxWidth = (totalWidth - nameWidth - ApplyDPIScale(30)) / baseUIScale.Scale
                        binderBoxUISizeConstraint.MaxSize = Vector2.new(maxWidth, 9e9)
                        binderBox.Text = binded or "None"
                    end

                    updateSize()
                    keybindName:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)

                    binderBox.MouseButton1Click:Connect(function()
                        if focused or isBinding then return end
                        focused = true
                        isBinding = true
                        local originalText = binderBox.Text
                        binderBox.Text = "..."
                        local Event
                        Event = UserInputService.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                binded = input.KeyCode.Name
                                binderBox.Text = input.KeyCode.Name
                            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                                binded = "MB1"
                                binderBox.Text = "MB1"
                            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                                binded = "MB2"
                                binderBox.Text = "MB2"
                            elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                                binded = "MB3"
                                binderBox.Text = "MB3"
                            end
                            if Settings.Blacklist and table.find(Settings.Blacklist, binded) then
                                binderBox.Text = originalText
                                binded = nil
                            else
                                if Settings.onBinded then
                                    Settings.onBinded(binded)
                                end
                            end
                            resetFocusState()
                            Event:Disconnect()
                        end)
                    end)

                    UserInputService.InputBegan:Connect(function(inp)
                        if not focused and not isBinding then
                            if inp.KeyCode.Name == binded or inp.UserInputType.Name == binded then
                                if Settings.Callback then
                                    Settings.Callback(binded)
                                end
                                if Settings.onBindHeld then
                                    Settings.onBindHeld(true, binded)
                                end
                            end
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(inp)
                        if not focused and not isBinding then
                            if inp.KeyCode.Name == binded or inp.UserInputType.Name == binded then
                                if Settings.onBindHeld then
                                    Settings.onBindHeld(false, binded)
                                end
                            end
                        end
                    end)

                    function KeybindFunctions:Bind(Key)
                        binded = Key
                        binderBox.Text = Key
                    end

                    function KeybindFunctions:Unbind()
                        binded = nil
                        binderBox.Text = "None"
                    end

                    function KeybindFunctions:GetBind()
                        return binded
                    end

                    function KeybindFunctions:UpdateName(Name)
                        keybindName.Text = Name
                    end

                    function KeybindFunctions:SetVisibility(State)
                        keybind.Visible = State
                    end

                    if Flag then
                        MacLib.Options[Flag] = KeybindFunctions
                    end

                    return KeybindFunctions
                end

                function SectionFunctions:Dropdown(Settings, Flag)
                    local DropdownFunctions = {Settings = Settings}
                    local Selected = {}
                    local OptionObjs = {}
                    local dropdown = Instance.new("Frame")
                    dropdown.Name = "Dropdown"
                    dropdown.BackgroundTransparency = 0.985
                    dropdown.BorderSizePixel = 0
                    dropdown.Size = UDim2.new(1, 0, 0, ApplyDPIScale(38))
                    dropdown.Parent = section
                    dropdown.ClipsDescendants = true

                    local dropdownUIPadding = Instance.new("UIPadding")
                    dropdownUIPadding.PaddingLeft = UDim.new(0, ApplyDPIScale(15))
                    dropdownUIPadding.PaddingRight = UDim.new(0, ApplyDPIScale(15))
                    dropdownUIPadding.Parent = dropdown

                    local interact = Instance.new("TextButton")
                    interact.Name = "Interact"
                    interact.Text = ""
                    interact.BackgroundTransparency = 1
                    interact.BorderSizePixel = 0
                    interact.Size = UDim2.new(1, 0, 0, ApplyDPIScale(38))
                    interact.Parent = dropdown

                    local dropdownName = Instance.new("TextLabel")
                    dropdownName.Name = "DropdownName"
                    dropdownName.FontFace = Font.new(assets.interFont)
                    dropdownName.Text = Settings.Default and (Settings.Name .. " • " .. table.concat(Selected, ", ")) or (Settings.Name .. "...")
                    dropdownName.RichText = true
                    dropdownName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    dropdownName.TextSize = ApplyDPIScale(13)
                    dropdownName.TextTransparency = 0.5
                    dropdownName.TextTruncate = Enum.TextTruncate.SplitWord
                    dropdownName.TextXAlignment = Enum.TextXAlignment.Left
                    dropdownName.AutomaticSize = Enum.AutomaticSize.Y
                    dropdownName.BackgroundTransparency = 1
                    dropdownName.BorderSizePixel = 0
                    dropdownName.Size = UDim2.new(1, -20, 0, ApplyDPIScale(38))
                    dropdownName.Parent = dropdown

                    local dropdownUIStroke = Instance.new("UIStroke")
                    dropdownUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    dropdownUIStroke.Color = Color3.fromRGB(255, 255, 255)
                    dropdownUIStroke.Transparency = 0.95
                    dropdownUIStroke.Parent = dropdown

                    local dropdownUICorner = Instance.new("UICorner")
                    dropdownUICorner.CornerRadius = UDim.new(0, 6)
                    dropdownUICorner.Parent = dropdown

                    local dropdownImage = Instance.new("ImageLabel")
                    dropdownImage.Name = "DropdownImage"
                    dropdownImage.Image = assets.dropdown
                    dropdownImage.ImageTransparency = 0.5
                    dropdownImage.AnchorPoint = Vector2.new(1, 0)
                    dropdownImage.BackgroundTransparency = 1
                    dropdownImage.BorderSizePixel = 0
                    dropdownImage.Position = UDim2.new(1, 0, 0, ApplyDPIScale(12))
                    dropdownImage.Size = UDim2.fromOffset(14, 14)
                    dropdownImage.Parent = dropdown

                    local dropdownFrame = Instance.new("Frame")
                    dropdownFrame.Name = "DropdownFrame"
                    dropdownFrame.BackgroundTransparency = 1
                    dropdownFrame.BorderSizePixel = 0
                    dropdownFrame.ClipsDescendants = true
                    dropdownFrame.Size = UDim2.fromScale(1, 1)
                    dropdownFrame.Visible = false
                    dropdownFrame.AutomaticSize = Enum.AutomaticSize.Y
                    local dropdownFrameUIPadding = Instance.new("UIPadding")
                    dropdownFrameUIPadding.PaddingTop = UDim.new(0, ApplyDPIScale(38))
                    dropdownFrameUIPadding.PaddingBottom = UDim.new(0, ApplyDPIScale(10))
                    dropdownFrameUIPadding.Parent = dropdownFrame
                    local dropdownFrameUIListLayout = Instance.new("UIListLayout")
                    dropdownFrameUIListLayout.Padding = UDim.new(0, 5)
                    dropdownFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    dropdownFrameUIListLayout.Parent = dropdownFrame

                    local search
                    if Settings.Searchable then
                        search = Instance.new("Frame")
                        search.Name = "Search"
                        search.BackgroundTransparency = 0.95
                        search.BorderSizePixel = 0
                        search.LayoutOrder = -1
                        search.Size = UDim2.new(1, 0, 0, ApplyDPIScale(30))
                        search.Parent = dropdownFrame
                        search.Visible = true
                        local sectionUICorner = Instance.new("UICorner")
                        sectionUICorner.Parent = search
                        local searchIcon = Instance.new("ImageLabel")
                        searchIcon.Name = "SearchIcon"
                        searchIcon.Image = assets.searchIcon
                        searchIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
                        searchIcon.AnchorPoint = Vector2.new(0, 0.5)
                        searchIcon.BackgroundTransparency = 1
                        searchIcon.BorderSizePixel = 0
                        searchIcon.Position = UDim2.fromScale(0, 0.5)
                        searchIcon.Size = UDim2.fromOffset(12, 12)
                        searchIcon.Parent = search
                        local uIPadding = Instance.new("UIPadding")
                        uIPadding.PaddingLeft = UDim.new(0, ApplyDPIScale(15))
                        uIPadding.Parent = search
                        local searchBox = Instance.new("TextBox")
                        searchBox.Name = "SearchBox"
                        searchBox.CursorPosition = -1
                        searchBox.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                        searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
                        searchBox.PlaceholderText = "Search..."
                        searchBox.Text = ""
                        searchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
                        searchBox.TextSize = ApplyDPIScale(14)
                        searchBox.TextXAlignment = Enum.TextXAlignment.Left
                        searchBox.BackgroundTransparency = 1
                        searchBox.BorderSizePixel = 0
                        searchBox.Size = UDim2.fromScale(1, 1)
                        local uIPadding1 = Instance.new("UIPadding")
                        uIPadding1.PaddingLeft = UDim.new(0, ApplyDPIScale(23))
                        uIPadding1.Parent = searchBox
                        searchBox.Parent = search

                        local function findOption()
                            local searchTerm = searchBox.Text:lower()
                            for _, v in pairs(OptionObjs) do
                                local optionText = v.NameLabel.Text:lower()
                                local isVisible = string.find(optionText, searchTerm) ~= nil
                                if v.Button.Visible ~= isVisible then
                                    v.Button.Visible = isVisible
                                end
                            end
                        end

                        searchBox:GetPropertyChangedSignal("Text"):Connect(findOption)
                    end

                    local tweensettings = {
                        duration = 0.2,
                        easingStyle = Enum.EasingStyle.Quint,
                        transparencyIn = 0.2,
                        transparencyOut = 0.5,
                        checkSizeIncrease = ApplyDPIScale(12),
                        checkSizeDecrease = -13,
                        waitTime = 1
                    }

                    local function Toggle(optionName, State)
                        local option = OptionObjs[optionName]
                        if not option then return end
                        local checkmark = option.Checkmark
                        local optionNameLabel = option.NameLabel
                        if State then
                            if Settings.Multi then
                                if not table.find(Selected, optionName) then
                                    table.insert(Selected, optionName)
                                end
                            else
                                for name, opt in pairs(OptionObjs) do
                                    if name ~= optionName then
                                        Tween(opt.Checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                                            Size = UDim2.new(opt.Checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, opt.Checkmark.Size.Y.Scale, opt.Checkmark.Size.Y.Offset)
                                        }):Play()
                                        Tween(opt.NameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                                            TextTransparency = tweensettings.transparencyOut
                                        }):Play()
                                        opt.Checkmark.TextTransparency = 1
                                    end
                                end
                                Selected = {optionName}
                            end
                            Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                                Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
                            }):Play()
                            Tween(optionNameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                                TextTransparency = tweensettings.transparencyIn
                            }):Play()
                            checkmark.TextTransparency = 0
                        else
                            if Settings.Multi then
                                local idx = table.find(Selected, optionName)
                                if idx then
                                    table.remove(Selected, idx)
                                end
                            else
                                Selected = {}
                            end
                            Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                                Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
                            }):Play()
                            Tween(optionNameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                                TextTransparency = tweensettings.transparencyOut
                            }):Play()
                            checkmark.TextTransparency = 1
                        end
                        if Settings.Required and #Selected == 0 and not State then
                            return
                        end
                        if #Selected > 0 then
                            dropdownName.Text = Settings.Name .. " • " .. table.concat(Selected, ", ")
                        else
                            dropdownName.Text = Settings.Name .. "..."
                        end
                    end

                    local dropped = false
                    local db = false

                    local function CalculateDropdownSize()
                        local totalHeight = 0
                        local visibleChildrenCount = 0
                        local padding = dropdownFrameUIPadding.PaddingTop.Offset + dropdownFrameUIPadding.PaddingBottom.Offset
                        for _, v in pairs(dropdownFrame:GetChildren()) do
                            if not v:IsA("UIComponent") and v.Visible then
                                totalHeight += v.AbsoluteSize.Y
                                visibleChildrenCount += 1
                            end
                        end
                        local spacing = dropdownFrameUIListLayout.Padding.Offset * (visibleChildrenCount - 1)
                        return totalHeight + spacing + padding
                    end

                    local function ToggleDropdown()
                        if db then return end
                        db = true
                        local defaultDropdownSize = ApplyDPIScale(38)
                        local isDropdownOpen = not dropped
                        local targetSize = isDropdownOpen and UDim2.new(1, 0, 0, CalculateDropdownSize()) or UDim2.new(1, 0, 0, defaultDropdownSize)
                        local dropTween = Tween(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                            Size = targetSize
                        })
                        local iconTween = Tween(dropdownImage, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Rotation = isDropdownOpen and -90 or 0
                        })
                        dropTween:Play()
                        iconTween:Play()
                        if isDropdownOpen then
                            dropdownFrame.Visible = true
                            dropTween.Completed:Connect(function()
                                db = false
                            end)
                        else
                            dropTween.Completed:Connect(function()
                                dropdownFrame.Visible = false
                                db = false
                            end)
                        end
                        dropped = isDropdownOpen
                    end

                    interact.MouseButton1Click:Connect(ToggleDropdown)

                    local function addOption(i, v)
                        local option = Instance.new("TextButton")
                        option.Name = "Option"
                        option.Text = ""
                        option.BackgroundTransparency = 1
                        option.BorderSizePixel = 0
                        option.Size = UDim2.new(1, 0, 0, ApplyDPIScale(30))
                        local optionUIPadding = Instance.new("UIPadding")
                        optionUIPadding.PaddingLeft = UDim.new(0, ApplyDPIScale(15))
                        optionUIPadding.PaddingRight = UDim.new(0, ApplyDPIScale(15))
                        optionUIPadding.Parent = option
                        local optionName = Instance.new("TextLabel")
                        optionName.Name = "OptionName"
                        optionName.FontFace = Font.new(assets.interFont)
                        optionName.Text = v
                        optionName.RichText = true
                        optionName.TextColor3 = Color3.fromRGB(255, 255, 255)
                        optionName.TextSize = ApplyDPIScale(13)
                        optionName.TextTransparency = 0.5
                        optionName.TextTruncate = Enum.TextTruncate.AtEnd
                        optionName.TextXAlignment = Enum.TextXAlignment.Left
                        optionName.TextYAlignment = Enum.TextYAlignment.Top
                        optionName.AnchorPoint = Vector2.new(0, 0.5)
                        optionName.AutomaticSize = Enum.AutomaticSize.Y
                        optionName.BackgroundTransparency = 1
                        optionName.BorderSizePixel = 0
                        optionName.Position = UDim2.fromScale(0, 0.5)
                        optionName.Parent = option
                        local optionUIListLayout = Instance.new("UIListLayout")
                        optionUIListLayout.Padding = UDim.new(0, ApplyDPIScale(10))
                        optionUIListLayout.FillDirection = Enum.FillDirection.Horizontal
                        optionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        optionUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                        optionUIListLayout.Parent = option
                        local checkmark = Instance.new("TextLabel")
                        checkmark.Name = "Checkmark"
                        checkmark.FontFace = Font.new(assets.interFont)
                        checkmark.Text = "✓"
                        checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
                        checkmark.TextSize = ApplyDPIScale(13)
                        checkmark.TextTransparency = 1
                        checkmark.TextXAlignment = Enum.TextXAlignment.Left
                        checkmark.TextYAlignment = Enum.TextYAlignment.Top
                        checkmark.AnchorPoint = Vector2.new(0, 0.5)
                        checkmark.AutomaticSize = Enum.AutomaticSize.Y
                        checkmark.BackgroundTransparency = 1
                        checkmark.BorderSizePixel = 0
                        checkmark.LayoutOrder = -1
                        checkmark.Position = UDim2.fromScale(0, 0.5)
                        checkmark.Size = UDim2.fromOffset(-10, 0)
                        checkmark.Parent = option
                        option.Parent = dropdownFrame
                        OptionObjs[v] = {
                            Index = i,
                            Button = option,
                            NameLabel = optionName,
                            Checkmark = checkmark
                        }
                        local tweensettings = {
                            duration = 0.2,
                            easingStyle = Enum.EasingStyle.Quint,
                            transparencyIn = 0.2,
                            transparencyOut = 0.5,
                            checkSizeIncrease = ApplyDPIScale(12),
                            checkSizeDecrease = -optionUIListLayout.Padding.Offset,
                            waitTime = 1
                        }
                        local isSelected = false
                        if Settings.Default then
                            if Settings.Multi then
                                isSelected = table.find(Settings.Default, v) and true or false
                            else
                                isSelected = (Settings.Default == i) and true or false
                            end
                        end
                        Toggle(v, isSelected)
                        option.MouseButton1Click:Connect(function()
                            local isSelected = table.find(Selected, v) and true or false
                            local newSelected = not isSelected
                            if Settings.Required and not newSelected and not Settings.Multi then
                                return
                            end
                            if Settings.Multi then
                                Toggle(v, newSelected)
                            else
                                if newSelected then
                                    for _, otherOption in pairs(Settings.Values) do
                                        Toggle(otherOption, false)
                                    end
                                    Toggle(v, true)
                                else
                                    Toggle(v, false)
                                end
                            end
                            if Settings.Callback then
                                Settings.Callback(Settings.Multi and Selected or (#Selected > 0 and Selected[1] or nil))
                            end
                        end)
                    end

                    for i, v in ipairs(Settings.Values) do
                        addOption(i, v)
                    end

                    dropdownFrame.Parent = dropdown

                    function DropdownFunctions:UpdateOptions(newValues)
                        Settings.Values = newValues
                        Selected = {}
                        for _, v in pairs(OptionObjs) do
                            v.Button:Destroy()
                        end
                        OptionObjs = {}
                        for i, v in ipairs(newValues) do
                            addOption(i, v)
                        end
                        dropdownName.Text = Settings.Name .. "..."
                    end

                    function DropdownFunctions:GetSelected()
                        return Settings.Multi and Selected or (#Selected > 0 and Selected[1] or nil)
                    end

                    function DropdownFunctions:SetSelected(values)
                        if Settings.Multi then
                            Selected = {}
                            for _, v in ipairs(Settings.Values) do
                                Toggle(v, false)
                            end
                            for _, v in ipairs(values) do
                                Toggle(v, true)
                            end
                        else
                            for _, v in ipairs(Settings.Values) do
                                Toggle(v, false)
                            end
                            Toggle(values, true)
                        end
                    end

                    function DropdownFunctions:UpdateName(Name)
                        Settings.Name = Name
                        dropdownName.Text = (#Selected > 0 and Name .. " • " .. table.concat(Selected, ", ") or Name .. "...")
                    end

                    function DropdownFunctions:SetVisibility(State)
                        dropdown.Visible = State
                    end

                    if Flag then
                        MacLib.Options[Flag] = DropdownFunctions
                    end
                    return DropdownFunctions
                end

                function SectionFunctions:ColorPicker(Settings, Flag)
                    local ColorPickerFunctions = {Settings = Settings}
                    local colorPicker = Instance.new("Frame")
                    colorPicker.Name = "ColorPicker"
                    colorPicker.AutomaticSize = Enum.AutomaticSize.Y
                    colorPicker.BackgroundTransparency = 1
                    colorPicker.BorderSizePixel = 0
                    colorPicker.Size = UDim2.new(1, 0, 0, ApplyDPIScale(38))
                    colorPicker.Parent = section

                    local colorPickerName = Instance.new("TextLabel")
                    colorPickerName.Name = "ColorPickerName"
                    colorPickerName.FontFace = Font.new(assets.interFont)
                    colorPickerName.Text = Settings.Name
                    colorPickerName.RichText = true
                    colorPickerName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    colorPickerName.TextSize = ApplyDPIScale(13)
                    colorPickerName.TextTransparency = 0.5
                    colorPickerName.TextTruncate = Enum.TextTruncate.AtEnd
                    colorPickerName.TextXAlignment = Enum.TextXAlignment.Left
                    colorPickerName.TextYAlignment = Enum.TextYAlignment.Top
                    colorPickerName.AnchorPoint = Vector2.new(0, 0.5)
                    colorPickerName.AutomaticSize = Enum.AutomaticSize.Y
                    colorPickerName.BackgroundTransparency = 1
                    colorPickerName.BorderSizePixel = 0
                    colorPickerName.Position = UDim2.fromScale(0, 0.5)
                    colorPickerName.Size = UDim2.new(1, -50, 0, 0)
                    colorPickerName.Parent = colorPicker

                    local colorDisplay = Instance.new("TextButton")
                    colorDisplay.Name = "ColorDisplay"
                    colorDisplay.Text = ""
                    colorDisplay.AnchorPoint = Vector2.new(1, 0.5)
                    colorDisplay.BackgroundColor3 = Settings.Default or Color3.new(1, 1, 1)
                    colorDisplay.BorderSizePixel = 0
                    colorDisplay.Position = UDim2.fromScale(1, 0.5)
                    colorDisplay.Size = UDim2.fromOffset(ApplyDPIScale(30), ApplyDPIScale(21))
                    local colorDisplayUICorner = Instance.new("UICorner")
                    colorDisplayUICorner.CornerRadius = UDim.new(0, 4)
                    colorDisplayUICorner.Parent = colorDisplay
                    local colorDisplayUIStroke = Instance.new("UIStroke")
                    colorDisplayUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    colorDisplayUIStroke.Color = Color3.fromRGB(255, 255, 255)
                    colorDisplayUIStroke.Transparency = 0.9
                    colorDisplayUIStroke.Parent = colorDisplay
                    colorDisplay.Parent = colorPicker

                    local colorMenu = Instance.new("Frame")
                    colorMenu.Name = "ColorMenu"
                    colorMenu.AutomaticSize = Enum.AutomaticSize.XY
                    colorMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                    colorMenu.BorderSizePixel = 0
                    colorMenu.Position = UDim2.fromOffset(colorDisplay.AbsoluteSize.X + 5, 0)
                    colorMenu.Visible = false
                    local colorMenuUIStroke = Instance.new("UIStroke")
                    colorMenuUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    colorMenuUIStroke.Color = Color3.fromRGB(255, 255, 255)
                    colorMenuUIStroke.Transparency = 0.9
                    colorMenuUIStroke.Parent = colorMenu
                    local colorMenuUICorner = Instance.new("UICorner")
                    colorMenuUICorner.CornerRadius = UDim.new(0, 8)
                    colorMenuUICorner.Parent = colorMenu
                    local colorMenuUIPadding = Instance.new("UIPadding")
                    colorMenuUIPadding.PaddingBottom = UDim.new(0, ApplyDPIScale(10))
                    colorMenuUIPadding.PaddingLeft = UDim.new(0, ApplyDPIScale(10))
                    colorMenuUIPadding.PaddingRight = UDim.new(0, ApplyDPIScale(10))
                    colorMenuUIPadding.PaddingTop = UDim.new(0, ApplyDPIScale(10))
                    colorMenuUIPadding.Parent = colorMenu
                    colorMenu.Parent = colorPicker

                    local hueSlider = Instance.new("Frame")
                    hueSlider.Name = "HueSlider"
                    hueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
                    hueSlider.BorderSizePixel = 0
                    hueSlider.Size = UDim2.new(1, 0, 0, ApplyDPIScale(20))
                    hueSlider.Parent = colorMenu

                    local hueGradient = Instance.new("UIGradient")
                    hueGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.new(1, 1, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.new(0, 1, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
                        ColorSequenceKeypoint.new(0.67, Color3.new(0, 0, 1)),
                        ColorSequenceKeypoint.new(0.83, Color3.new(1, 0, 1)),
                        ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
                    })
                    hueGradient.Parent = hueSlider

                    local huePicker = Instance.new("Frame")
                    huePicker.Name = "HuePicker"
                    huePicker.BackgroundColor3 = Color3.new(1, 1, 1)
                    huePicker.BorderSizePixel = 0
                    huePicker.Size = UDim2.fromOffset(2, ApplyDPIScale(20))
                    huePicker.Parent = hueSlider

                    local saturationBrightness = Instance.new("Frame")
                    saturationBrightness.Name = "SaturationBrightness"
                    saturationBrightness.BackgroundColor3 = colorDisplay.BackgroundColor3
                    saturationBrightness.BorderSizePixel = 0
                    saturationBrightness.Position = UDim2.fromOffset(0, ApplyDPIScale(25))
                    saturationBrightness.Size = UDim2.new(1, 0, 0, ApplyDPIScale(100))
                    saturationBrightness.Parent = colorMenu

                    local sbPicker = Instance.new("Frame")
                    sbPicker.Name = "SBPicker"
                    sbPicker.AnchorPoint = Vector2.new(0.5, 0.5)
                    sbPicker.BackgroundColor3 = Color3.new(1, 1, 1)
                    sbPicker.BorderSizePixel = 0
                    sbPicker.Position = UDim2.fromScale(0.5, 0.5)
                    sbPicker.Size = UDim2.fromOffset(4, 4)
                    sbPicker.Parent = saturationBrightness

                    local currentHue = 0
                    local currentSaturation = 0
                    local currentBrightness = 1

                    local function updateColor()
                        local color = Color3.fromHSV(currentHue, currentSaturation, currentBrightness)
                        colorDisplay.BackgroundColor3 = color
                        saturationBrightness.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
                        if Settings.Callback then
                            Settings.Callback(color)
                        end
                    end

                    hueSlider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            local dragging = true
                            local conn
                            conn = RunService.RenderStepped:Connect(function()
                                if not dragging then
                                    conn:Disconnect()
                                    return
                                end
                                local pos = UserInputService:GetMouseLocation().X - hueSlider.AbsolutePosition.X
                                local relative = math.clamp(pos / hueSlider.AbsoluteSize.X, 0, 1)
                                currentHue = relative
                                huePicker.Position = UDim2.fromScale(relative, 0)
                                updateColor()
                            end)
                            input.Changed:Connect(function()
                                if input.UserInputState == Enum.UserInputState.End then
                                    dragging = false
                                end
                            end)
                        end
                    end)

                    saturationBrightness.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            local dragging = true
                            local conn
                            conn = RunService.RenderStepped:Connect(function()
                                if not dragging then
                                    conn:Disconnect()
                                    return
                                end
                                local pos = UserInputService:GetMouseLocation() - saturationBrightness.AbsolutePosition
                                local x = math.clamp(pos.X / saturationBrightness.AbsoluteSize.X, 0, 1)
                                local y = math.clamp(pos.Y / saturationBrightness.AbsoluteSize.Y, 0, 1)
                                currentSaturation = x
                                currentBrightness = 1 - y
                                sbPicker.Position = UDim2.fromScale(x, y)
                                updateColor()
                            end)
                            input.Changed:Connect(function()
                                if input.UserInputState == Enum.UserInputState.End then
                                    dragging = false
                                end
                            end)
                        end
                    end)

                    colorDisplay.MouseButton1Click:Connect(function()
                        colorMenu.Visible = not colorMenu.Visible
                    end)

                    function ColorPickerFunctions:SetColor(color)
                        local h, s, v = color:ToHSV()
                        currentHue = h
                        currentSaturation = s
                        currentBrightness = v
                        huePicker.Position = UDim2.fromScale(h, 0)
                        sbPicker.Position = UDim2.fromScale(s, 1 - v)
                        updateColor()
                    end

                    if Settings.Default then
                        ColorPickerFunctions:SetColor(Settings.Default)
                    end

                    if Flag then
                        MacLib.Options[Flag] = ColorPickerFunctions
                    end
                    return ColorPickerFunctions
                end

                SectionFunctions.Container = section
                return SectionFunctions
            end

            tabSwitcher.MouseButton1Click:Connect(function()
                for _, tab in pairs(tabSwitchersScrollingFrame:GetChildren()) do
                    if tab:IsA("Frame") then
                        local tabButton = tab:FindFirstChild("TabSwitcher")
                        if tabButton then
                            Tween(tabButton.UIStroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Transparency = 1}):Play()
                            Tween(tabButton.TabSwitcherName, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {TextTransparency = 0.5}):Play()
                            if tabButton:FindFirstChild("TabImage") then
                                Tween(tabButton.TabImage, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {ImageTransparency = 0.5}):Play()
                            end
                        end
                    end
                end
                Tween(tabSwitcherUIStroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Transparency = 0}):Play()
                Tween(tabSwitcherName, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {TextTransparency = 0}):Play()
                if tabImage then
                    Tween(tabImage, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {ImageTransparency = 0}):Play()
                end
                for _, element in pairs(content:GetChildren()) do
                    if element:IsA("Frame") and element.Name == "Elements" then
                        element.Visible = false
                    end
                end
                elements1_copy.Visible = true
                currentTab.Text = Settings.Name
                currentTabInstance = elements1_copy
            end)

            if tabIndex == 1 then
                tabSwitcher.MouseButton1Click:Fire()
            end

            table.insert(tabs, elements1_copy)
            return TabFunctions
        end

        return SectionFunctions
    end

    sidebar.Parent = base
    content.Parent = base
    base.Parent = macLib

    base.Size = Settings.Size or (IsMobile and ApplyDPIScale(UDim2.fromOffset(600, 400)) or ApplyDPIScale(UDim2.fromOffset(868, 650)))
    exit.MouseButton1Click:Connect(function()
        macLib:Destroy()
    end)

    minimize.MouseButton1Click:Connect(function()
        base.Visible = not base.Visible
    end)

    return WindowFunctions
end

return MacLib