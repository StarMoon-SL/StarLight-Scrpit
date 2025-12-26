local StarLight = {}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local isStudio = RunService:IsStudio()
local LocalPlayer = Players.LocalPlayer

local windowState
local acrylicBlur
local hasGlobalSetting

local tabs = {}
local currentTabInstance = nil
local tabIndex = 0

StarLight.MobileConfig = {
    Enabled = false,
    SidebarExpanded = false,
    FloatingButton = nil,
    DefaultPCSize = UDim2.fromOffset(868, 650),
    DefaultMobileSize = UDim2.fromOffset(500, 350),
    MinMobileSize = Vector2.new(480, 300),
    SidebarCompactWidth = 54,
    SidebarExpandedWidth = 180,
    FloatingButtonSize = 56,
    FloatingButtonOffset = UDim2.new(1, -70, 1, -120),
}

local function Tween(instance, tweeninfo, propertytable)
    return TweenService:Create(instance, tweeninfo, propertytable)
end

local function CheckMobile()
    return (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) or 
           (UserInputService:GetPlatform() == Enum.Platform.Android) or
           (UserInputService:GetPlatform() == Enum.Platform.IOS)
end

StarLight.MobileConfig.Enabled = CheckMobile()

local assets = {
    interFont = "rbxassetid://12187365364",
    userInfoBlurred = "rbxassetid://18824089198",
    toggleBackground = "rbxassetid://18772190202",
    togglerHead = "rbxassetid://18772309008",
    buttonImage = "rbxassetid://10709791437",
    searchIcon = "rbxassetid://86737463322606",
    menuIcon = "rbxassetid://10734900011",
    dropdownArrow = "rbxassetid://18865373378",
    colorPickerBg = "rbxassetid://121484455191370",
    sliderBar = "rbxassetid://18772615246",
    sliderHead = "rbxassetid://18772834246",
    plusIcon = "rbxassetid://83114982417764",
    keybindLock = "rbxassetid://10734900011",
    keybindUnlock = "rbxassetid://10734950309",
}

function StarLight:Window(Settings)
    local WindowFunctions = {}
    if Settings.AcrylicBlur ~= nil then
        acrylicBlur = Settings.AcrylicBlur
    else
        acrylicBlur = true
    end

    local starLight = Instance.new("ScreenGui")
    starLight.Name = "StarLight"
    starLight.ResetOnSpawn = false
    starLight.DisplayOrder = 100
    starLight.IgnoreGuiInset = true
    starLight.ScreenInsets = Enum.ScreenInsets.None
    starLight.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    starLight.Parent = (isStudio and LocalPlayer.PlayerGui) or game:GetService("CoreGui")

    local notifications = Instance.new("Frame")
    notifications.Name = "Notifications"
    notifications.BackgroundTransparency = 1
    notifications.Size = UDim2.fromScale(1, 1)
    notifications.Parent = starLight
    notifications.ZIndex = 2

    local notificationsUIListLayout = Instance.new("UIListLayout")
    notificationsUIListLayout.Name = "NotificationsUIListLayout"
    notificationsUIListLayout.Padding = UDim.new(0, 10)
    notificationsUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notificationsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notificationsUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notificationsUIListLayout.Parent = notifications

    local notificationsUIPadding = Instance.new("UIPadding")
    notificationsUIPadding.Name = "NotificationsUIPadding"
    notificationsUIPadding.PaddingBottom = UDim.new(0, 10)
    notificationsUIPadding.PaddingLeft = UDim.new(0, 10)
    notificationsUIPadding.PaddingRight = UDim.new(0, 10)
    notificationsUIPadding.PaddingTop = UDim.new(0, 10)
    notificationsUIPadding.Parent = notifications

    local base = Instance.new("Frame")
    base.Name = "Base"
    base.AnchorPoint = Vector2.new(0.5, 0.5)
    base.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    base.BackgroundTransparency = Settings.AcrylicBlur and 0.05 or 0
    base.BorderSizePixel = 0
    base.Position = UDim2.fromScale(0.5, 0.5)
    base.Size = StarLight.MobileConfig.Enabled and (Settings.Size or StarLight.MobileConfig.DefaultMobileSize) or (Settings.Size or StarLight.MobileConfig.DefaultPCSize)

    local baseUIScale = Instance.new("UIScale")
    baseUIScale.Name = "BaseUIScale"
    baseUIScale.Parent = base

    local baseUICorner = Instance.new("UICorner")
    baseUICorner.Name = "BaseUICorner"
    baseUICorner.CornerRadius = UDim.new(0, 10)
    baseUICorner.Parent = base

    local baseUIStroke = Instance.new("UIStroke")
    baseUIStroke.Name = "BaseUIStroke"
    baseUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    baseUIStroke.Color = Color3.fromRGB(255, 255, 255)
    baseUIStroke.Transparency = 0.9
    baseUIStroke.Parent = base

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundTransparency = 1
    sidebar.BorderSizePixel = 0
    sidebar.Position = UDim2.fromScale(0, 0)
    sidebar.Size = UDim2.fromScale(0.325, 1)

    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.AnchorPoint = Vector2.new(1, 0)
    divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider.BackgroundTransparency = 0.9
    divider.BorderSizePixel = 0
    divider.Position = UDim2.fromScale(1, 0)
    divider.Size = UDim2.new(0, 1, 1, 0)
    divider.Parent = sidebar

    local windowControls = Instance.new("Frame")
    windowControls.Name = "WindowControls"
    windowControls.BackgroundTransparency = 1
    windowControls.BorderSizePixel = 0
    windowControls.Size = UDim2.new(1, 0, 0, 31)

    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.BackgroundTransparency = 1
    controls.BorderSizePixel = 0
    controls.Size = UDim2.fromScale(1, 1)

    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.Name = "UIListLayout"
    uIListLayout.Padding = UDim.new(0, 5)
    uIListLayout.FillDirection = Enum.FillDirection.Horizontal
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uIListLayout.Parent = controls

    local uIPadding = Instance.new("UIPadding")
    uIPadding.Name = "UIPadding"
    uIPadding.PaddingLeft = UDim.new(0, 11)
    uIPadding.Parent = controls

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
    information.Position = UDim2.fromOffset(0, 31)
    information.Size = UDim2.new(1, 0, 0, 60)

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
    informationHolderUIPadding.Name = "InformationHolderUIPadding"
    informationHolderUIPadding.PaddingBottom = UDim.new(0, 10)
    informationHolderUIPadding.PaddingLeft = UDim.new(0, 23)
    informationHolderUIPadding.PaddingRight = UDim.new(0, 22)
    informationHolderUIPadding.PaddingTop = UDim.new(0, 10)
    informationHolderUIPadding.Parent = informationHolder

    local titleFrame = Instance.new("Frame")
    titleFrame.Name = "TitleFrame"
    titleFrame.BackgroundTransparency = 1
    titleFrame.BorderSizePixel = 0
    titleFrame.Size = UDim2.fromScale(1, 1)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    title.Text = Settings.Title or "StarLight"
    title.RichText = true
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.TextTransparency = 0.2
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
    subtitle.Text = Settings.Subtitle or ""
    subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    subtitle.TextSize = 12
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
    titleFrameUIListLayout.Name = "TitleFrameUIListLayout"
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
    sidebarGroup.Position = UDim2.fromOffset(0, 91)
    sidebarGroup.Size = UDim2.new(1, 0, 1, -91)

    local userInfo = Instance.new("Frame")
    userInfo.Name = "UserInfo"
    userInfo.AnchorPoint = Vector2.new(0, 1)
    userInfo.BackgroundTransparency = 1
    userInfo.BorderSizePixel = 0
    userInfo.Position = UDim2.fromScale(0, 1)
    userInfo.Size = UDim2.new(1, 0, 0, 107)

    local informationGroup = Instance.new("Frame")
    informationGroup.Name = "InformationGroup"
    informationGroup.BackgroundTransparency = 1
    informationGroup.BorderSizePixel = 0
    informationGroup.Size = UDim2.fromScale(1, 1)

    local informationGroupUIPadding = Instance.new("UIPadding")
    informationGroupUIPadding.Name = "InformationGroupUIPadding"
    informationGroupUIPadding.PaddingBottom = UDim.new(0, 17)
    informationGroupUIPadding.PaddingLeft = UDim.new(0, 25)
    informationGroupUIPadding.Parent = informationGroup

    local informationGroupUIListLayout = Instance.new("UIListLayout")
    informationGroupUIListLayout.Name = "InformationGroupUIListLayout"
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
    headshot.Image = (isReady and headshotImage) or "rbxassetid://0"

    local uICorner3 = Instance.new("UICorner")
    uICorner3.Name = "UICorner"
    uICorner3.CornerRadius = UDim.new(1, 0)
    uICorner3.Parent = headshot

    local baseUIStroke2 = Instance.new("UIStroke")
    baseUIStroke2.Name = "BaseUIStroke"
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
    displayName.TextSize = 13
    displayName.TextTransparency = 0.2
    displayName.TextTruncate = Enum.TextTruncate.SplitWord
    displayName.TextXAlignment = Enum.TextXAlignment.Left
    displayName.TextYAlignment = Enum.TextYAlignment.Top
    displayName.AutomaticSize = Enum.AutomaticSize.XY
    displayName.BackgroundTransparency = 1
    displayName.BorderSizePixel = 0
    displayName.Parent = userAndDisplayFrame

    local userAndDisplayFrameUIPadding = Instance.new("UIPadding")
    userAndDisplayFrameUIPadding.Name = "UserAndDisplayFrameUIPadding"
    userAndDisplayFrameUIPadding.PaddingLeft = UDim.new(0, 8)
    userAndDisplayFrameUIPadding.PaddingTop = UDim.new(0, 3)
    userAndDisplayFrameUIPadding.Parent = userAndDisplayFrame

    local userAndDisplayFrameUIListLayout = Instance.new("UIListLayout")
    userAndDisplayFrameUIListLayout.Name = "UserAndDisplayFrameUIListLayout"
    userAndDisplayFrameUIListLayout.Padding = UDim.new(0, 1)
    userAndDisplayFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    userAndDisplayFrameUIListLayout.Parent = userAndDisplayFrame

    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    username.Text = "@"..LocalPlayer.Name
    username.TextColor3 = Color3.fromRGB(255, 255, 255)
    username.TextSize = 12
    username.TextTransparency = 0.8
    username.TextTruncate = Enum.TextTruncate.SplitWord
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.TextYAlignment = Enum.TextYAlignment.Top
    username.AutomaticSize = Enum.AutomaticSize.XY
    username.BackgroundTransparency = 1
    username.BorderSizePixel = 0
    username.LayoutOrder = 1
    username.Parent = userAndDisplayFrame

    userAndDisplayFrame.Parent = informationGroup

    informationGroup.Parent = userInfo

    local userInfoUIPadding = Instance.new("UIPadding")
    userInfoUIPadding.Name = "UserInfoUIPadding"
    userInfoUIPadding.PaddingLeft = UDim.new(0, 10)
    userInfoUIPadding.PaddingRight = UDim.new(0, 10)
    userInfoUIPadding.Parent = userInfo

    userInfo.Parent = sidebarGroup

    local sidebarGroupUIPadding = Instance.new("UIPadding")
    sidebarGroupUIPadding.Name = "SidebarGroupUIPadding"
    sidebarGroupUIPadding.PaddingLeft = UDim.new(0, 10)
    sidebarGroupUIPadding.PaddingRight = UDim.new(0, 10)
    sidebarGroupUIPadding.PaddingTop = UDim.new(0, 31)
    sidebarGroupUIPadding.Parent = sidebarGroup

    local tabSwitchers = Instance.new("Frame")
    tabSwitchers.Name = "TabSwitchers"
    tabSwitchers.BackgroundTransparency = 1
    tabSwitchers.BorderSizePixel = 0
    tabSwitchers.Size = UDim2.new(1, 0, 1, -107)

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
    tabSwitchersScrollingFrameUIListLayout.Name = "TabSwitchersScrollingFrameUIListLayout"
    tabSwitchersScrollingFrameUIListLayout.Padding = UDim.new(0, 17)
    tabSwitchersScrollingFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabSwitchersScrollingFrameUIListLayout.Parent = tabSwitchersScrollingFrame

    local tabSwitchersScrollingFrameUIPadding = Instance.new("UIPadding")
    tabSwitchersScrollingFrameUIPadding.Name = "TabSwitchersScrollingFrameUIPadding"
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
    content.Size = UDim2.fromScale(0.675, 1)

    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.BackgroundTransparency = 1
    topbar.BorderSizePixel = 0
    topbar.Size = UDim2.new(1, 0, 0, 63)

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
    uIPadding2.Name = "UIPadding"
    uIPadding2.PaddingLeft = UDim.new(0, 20)
    uIPadding2.PaddingRight = UDim.new(0, 20)
    uIPadding2.Parent = elements

    local topImage = nil
    if Settings.TopImage then
        topImage = Instance.new("ImageLabel")
        topImage.Name = "TopImage"
        topImage.Image = Settings.TopImage
        topImage.BackgroundTransparency = 1
        topImage.BorderSizePixel = 0
        topImage.Size = UDim2.fromOffset(30, 30)
        topImage.Position = UDim2.new(0, 20, 0.5, -15)
        topImage.ZIndex = 5
        topImage.Parent = topbar
    end

    local moveIcon = Instance.new("ImageButton")
    moveIcon.Name = "MoveIcon"
    moveIcon.Image = assets.menuIcon
    moveIcon.ImageTransparency = 0.5
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
    interact.TextColor3 = Color3.fromRGB(0, 0, 0)
    interact.TextSize = 14
    interact.AnchorPoint = Vector2.new(0.5, 0.5)
    interact.BackgroundTransparency = 1
    interact.BorderSizePixel = 0
    interact.Position = UDim2.fromScale(0.5, 0.5)
    interact.Size = UDim2.fromOffset(30, 30)
    interact.Parent = moveIcon

    local function ChangemoveIconState(State)
        if State == "Default" then
            Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                ImageTransparency = 0.5
            }):Play()
        elseif State == "Hover" then
            Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                ImageTransparency = 0.2
            }):Play()
        end
    end

    interact.MouseEnter:Connect(function()
        ChangemoveIconState("Hover")
    end)
    interact.MouseLeave:Connect(function()
        ChangemoveIconState("Default")
    end)

    local dragging_ = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    local function onDragStart(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging_ = true
            dragStart = input.Position
            startPos = base.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging_ = false
                end
            end)
        end
    end

    local function onDragUpdate(input)
        if dragging_ and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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
            if input == dragInput and dragging_ then
                update(input)
            end
        end)
        interact.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging_ = false
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
            if input == dragInput and dragging_ then
                update(input)
            end
        end)
        base.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging_ = false
            end
        end)
    end

    local currentTab = Instance.new("TextLabel")
    currentTab.Name = "CurrentTab"
    currentTab.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    currentTab.RichText = true
    currentTab.Text = "Tab"
    currentTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    currentTab.TextSize = 15
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
    content.Parent = base

    local globalSettings = Instance.new("Frame")
    globalSettings.Name = "GlobalSettings"
    globalSettings.AutomaticSize = Enum.AutomaticSize.XY
    globalSettings.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    globalSettings.BorderSizePixel = 0
    globalSettings.Position = UDim2.fromScale(0.298, 0.104)

    local globalSettingsUIStroke = Instance.new("UIStroke")
    globalSettingsUIStroke.Name = "GlobalSettingsUIStroke"
    globalSettingsUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    globalSettingsUIStroke.Color = Color3.fromRGB(255, 255, 255)
    globalSettingsUIStroke.Transparency = 0.9
    globalSettingsUIStroke.Parent = globalSettings

    local globalSettingsUICorner = Instance.new("UICorner")
    globalSettingsUICorner.Name = "GlobalSettingsUICorner"
    globalSettingsUICorner.CornerRadius = UDim.new(0, 10)
    globalSettingsUICorner.Parent = globalSettings

    local globalSettingsUIPadding = Instance.new("UIPadding")
    globalSettingsUIPadding.Name = "GlobalSettingsUIPadding"
    globalSettingsUIPadding.PaddingBottom = UDim.new(0, 10)
    globalSettingsUIPadding.PaddingTop = UDim.new(0, 10)
    globalSettingsUIPadding.Parent = globalSettings

    local globalSettingsUIListLayout = Instance.new("UIListLayout")
    globalSettingsUIListLayout.Name = "GlobalSettingsUIListLayout"
    globalSettingsUIListLayout.Padding = UDim.new(0, 5)
    globalSettingsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    globalSettingsUIListLayout.Parent = globalSettings

    local globalSettingsUIScale = Instance.new("UIScale")
    globalSettingsUIScale.Name = "GlobalSettingsUIScale"
    globalSettingsUIScale.Scale = 1e-07
    globalSettingsUIScale.Parent = globalSettings

    globalSettings.Parent = base
    base.Parent = starLight

    function WindowFunctions:UpdateTitle(NewTitle)
        title.Text = NewTitle
    end

    function WindowFunctions:UpdateSubtitle(NewSubtitle)
        subtitle.Text = NewSubtitle
    end

    if StarLight.MobileConfig.Enabled then
        local FloatContainer = Instance.new("Frame")
        FloatContainer.Name = "FloatContainer"
        FloatContainer.BackgroundTransparency = 1
        FloatContainer.Size = UDim2.fromScale(1, 1)
        FloatContainer.Parent = starLight
        FloatContainer.ZIndex = 100

        local ToggleBtn = Instance.new("ImageButton")
        ToggleBtn.Name = "ToggleButton"
        ToggleBtn.Image = assets.menuIcon
        ToggleBtn.AnchorPoint = Vector2.new(1, 1)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(87, 86, 86)
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Position = StarLight.MobileConfig.FloatingButtonOffset
        ToggleBtn.Size = UDim2.fromOffset(StarLight.MobileConfig.FloatingButtonSize, StarLight.MobileConfig.FloatingButtonSize)
        ToggleBtn.ZIndex = 100
        ToggleBtn.Parent = FloatContainer

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 14)
        ToggleCorner.Parent = ToggleBtn

        local ToggleStroke = Instance.new("UIStroke")
        ToggleStroke.Thickness = 1
        ToggleStroke.Transparency = 0.8
        ToggleStroke.Color = baseUIStroke.Color
        ToggleStroke.Parent = ToggleBtn

        baseUIStroke:GetPropertyChangedSignal("Color"):Connect(function()
            ToggleStroke.Color = baseUIStroke.Color
        end)

        local LockBtn = Instance.new("ImageButton")
        LockBtn.Name = "LockButton"
        LockBtn.Image = assets.keybindUnlock
        LockBtn.AnchorPoint = Vector2.new(1, 1)
        LockBtn.BackgroundColor3 = Color3.fromRGB(87, 86, 86)
        LockBtn.BorderSizePixel = 0
        LockBtn.Position = UDim2.new(1, -70, 1, -190)
        LockBtn.Size = UDim2.fromOffset(StarLight.MobileConfig.FloatingButtonSize, StarLight.MobileConfig.FloatingButtonSize)
        LockBtn.ZIndex = 100
        LockBtn.Parent = FloatContainer

        local LockCorner = Instance.new("UICorner")
        LockCorner.CornerRadius = UDim.new(0, 14)
        LockCorner.Parent = LockBtn

        local LockStroke = Instance.new("UIStroke")
        LockStroke.Thickness = 1
        LockStroke.Transparency = 0.8
        LockStroke.Color = baseUIStroke.Color
        LockStroke.Parent = LockBtn

        baseUIStroke:GetPropertyChangedSignal("Color"):Connect(function()
            LockStroke.Color = baseUIStroke.Color
        end)

        local isLocked = false
        local holdTime = 0
        local isHolding = false
        local holdDuration = 1

        local holdBar = Instance.new("Frame", ToggleBtn)
        holdBar.AnchorPoint = Vector2.new(0.5, 1)
        holdBar.Position = UDim2.new(0.5, 0, 1, -5)
        holdBar.Size = UDim2.new(0, 0, 0, 3)
        holdBar.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        holdBar.BorderSizePixel = 0
        holdBar.ZIndex = 101

        ToggleBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                isHolding = true
                holdBar.Size = UDim2.new(0, 0, 0, 3)
                local tweenInfo = TweenInfo.new(holdDuration, Enum.EasingStyle.Linear)
                local holdTween = TweenService:Create(holdBar, tweenInfo, {Size = UDim2.new(0.8, 0, 0, 3)})
                holdTween:Play()
                holdTween.Completed:Connect(function()
                    if isHolding then
                        TweenService:Create(base, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                            Position = UDim2.new(0.5, 0, 0.5, 0)
                        }):Play()
                        holdBar.Size = UDim2.new(0, 0, 0, 3)
                    end
                end)
            end
        end)

        ToggleBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                isHolding = false
                TweenService:Create(holdBar, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, 0, 0, 3)
                }):Play()
                base.Visible = not base.Visible
                local tweenInfo2 = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                if base.Visible then
                    TweenService:Create(base, tweenInfo2, {
                        Position = base.Position - UDim2.new(0, 0, 0.1, 0)
                    }):Play()
                else
                    TweenService:Create(base, tweenInfo2, {
                        Position = base.Position + UDim2.new(0, 0, 0.1, 0)
                    }):Play()
                end
            end
        end)

        ToggleBtn.MouseEnter:Connect(function()
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, StarLight.MobileConfig.FloatingButtonSize + 6, 0, StarLight.MobileConfig.FloatingButtonSize + 10)}):Play()
        end)

        ToggleBtn.MouseLeave:Connect(function()
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, StarLight.MobileConfig.FloatingButtonSize, 0, StarLight.MobileConfig.FloatingButtonSize)}):Play()
        end)

        LockBtn.MouseButton1Click:Connect(function()
            isLocked = not isLocked
            LockBtn.Image = isLocked and assets.keybindLock or assets.keybindUnlock
            local LockedNotification = StarLight:Notification({
                Title = isLocked and "UI Locked" or "UI Unlocked",
                Content = isLocked and "UI is now locked" or "UI is now unlocked",
                Duration = 2
            })
        end)

        StarLight.MobileConfig.FloatingButton = ToggleBtn

        local dragging = false
        local dragStart
        local startPos

        ToggleBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = ToggleBtn.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local delta = input.Position - dragStart
                ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                StarLight.MobileConfig.FloatingButtonOffset = ToggleBtn.Position
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        local SidebarToggle = Instance.new("ImageButton")
        SidebarToggle.Name = "SidebarToggle"
        SidebarToggle.Image = assets.dropdownArrow
        SidebarToggle.Rotation = 180
        SidebarToggle.ImageTransparency = 0.5
        SidebarToggle.AnchorPoint = Vector2.new(0, 0.5)
        SidebarToggle.BackgroundColor3 = Color3.fromRGB(87, 86, 86)
        SidebarToggle.BorderSizePixel = 0
        SidebarToggle.Position = UDim2.new(0, 5, 0.5, 0)
        SidebarToggle.Size = UDim2.fromOffset(30, 30)
        SidebarToggle.ZIndex = 20
        SidebarToggle.Parent = base

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 6)
        ToggleCorner.Parent = SidebarToggle

        sidebar.Size = UDim2.fromOffset(StarLight.MobileConfig.SidebarCompactWidth, sidebar.AbsoluteSize.Y)
        StarLight.MobileConfig.SidebarExpanded = false

        SidebarToggle.MouseButton1Click:Connect(function()
            StarLight.MobileConfig.SidebarExpanded = not StarLight.MobileConfig.SidebarExpanded
            local targetWidth = StarLight.MobileConfig.SidebarExpanded and StarLight.MobileConfig.SidebarExpandedWidth or StarLight.MobileConfig.SidebarCompactWidth
            TweenService:Create(sidebar, TweenInfo.new(0.2), {Size = UDim2.new(0, targetWidth, sidebar.Size.Y.Scale, sidebar.Size.Y.Offset)}):Play()
            TweenService:Create(SidebarToggle, TweenInfo.new(0.2), {Rotation = StarLight.MobileConfig.SidebarExpanded and 0 or 180}):Play()
        end)

        local function updateSidebarLayout()
            local isExpanded = sidebar.AbsoluteSize.X > 100
            for _, tab in pairs(tabSwitchersScrollingFrame:GetChildren()) do
                if tab:IsA("TextButton") then
                    local nameLabel = tab:FindFirstChild("TabSwitcherName")
                    if nameLabel then
                        nameLabel.Visible = isExpanded
                    end
                    local image = tab:FindFirstChild("TabImage")
                    if image then
                        image.Visible = not isExpanded
                    end
                end
            end
            userInfo.Visible = isExpanded
        end

        sidebar:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSidebarLayout)

        local viewportSize = workspace.CurrentCamera.ViewportSize
        local UIScale = Instance.new("UIScale")
        UIScale.Name = "MobileUIScale"
        UIScale.Parent = base
        local scale = math.min(viewportSize.X / StarLight.MobileConfig.MinMobileSize.X, viewportSize.Y / StarLight.MobileConfig.MinMobileSize.Y)
        UIScale.Scale = math.clamp(scale, 0.8, 1.2)

        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            local viewportSize = workspace.CurrentCamera.ViewportSize
            local scale = math.min(viewportSize.X / StarLight.MobileConfig.MinMobileSize.X, viewportSize.Y / StarLight.MobileConfig.MinMobileSize.Y)
            UIScale.Scale = math.clamp(scale, 0.8, 1.2)
        end)
    end

    local BlurTarget = base
    local HS = game:GetService('HttpService')
    local camera = workspace.CurrentCamera
    local MTREL = "Glass"
    local binds = {}
    local wedgeguid = HS:GenerateGUID(true)
    local DepthOfField

    for _,v in pairs(game:GetService("Lighting"):GetChildren()) do
        if not v:IsA("DepthOfFieldEffect") and v:HasTag(".") then
            DepthOfField = Instance.new('DepthOfFieldEffect', game:GetService("Lighting"))
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
        DepthOfField = Instance.new('DepthOfFieldEffect', game:GetService("Lighting"))
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

    do
        local function IsNotNaN(x)
            return x == x
        end
        local continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
        while not continue do
            RunService.RenderStepped:wait()
            continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
        end
    end

    local function DrawQuad(v1, v2, v3, v4, parts)
        local function DrawTriangle(A, B, C, p0, p1)
            local s1 = (A - B).magnitude
            local s2 = (B - C).magnitude
            local s3 = (C - A).magnitude
            local smax = math.max(s1, s2, s3)
            
            if s1 == smax then
                A, B, C = A, B, C
            elseif s2 == smax then
                A, B, C = B, C, A
            elseif s3 == smax then
                A, B, C = C, A, B
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
            local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.lookVector.z*Needed_Look.z

            local ac = CFrame.Angles(0, 0, math.acos(dot))

            cf0 = cf0 * ac
            if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
                cf0 = cf0 * CFrame.Angles(0, 0, -2*math.acos(dot))
            end
            cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))

            local cf1 = st * ac * CFrame.Angles(0, math.pi, 0)
            if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
                cf1 = cf1 * CFrames.Angles(0, 0, 2*math.acos(dot))
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
                p0.Size = Vector3.new(0.1, 0.1, 0.1)
                p0.Name = HS:GenerateGUID(true)
                local mesh = Instance.new('SpecialMesh', p0)
                mesh.MeshType = Enum.MeshType.Wedge
                mesh.Name = wedgeguid
            end
            p0[wedgeguid].Scale = Vector3.new(0, perp/0.1, para/0.1)
            p0.CFrame = cf0

            if not p1 then
                p1 = p0:clone()
            end
            p1[wedgeguid].Scale = Vector3.new(0, perp/0.1, dif_para/0.1)
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
    do
        local function add(child)
            if child:IsA('GuiObject') then
                parents[#parents + 1] = child
                add(child.Parent)
            end
        end
        add(frame)
    end

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
        if not IsVisible(frame) or not acrylicBlur then
            for _, pt in pairs(parts) do
                pt.Parent = nil
                DepthOfField.Enabled = false
            end
            return
        end
        DepthOfField.Enabled = true
        local properties = {
            Transparency = 0.98;
            BrickColor = BrickColor.new('Institutional white');
        }
        local zIndex = 1 - 0.05*frame.ZIndex

        local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
        local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
        do
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

    RunService.RenderStepped:connect(UpdateOrientation)

    function WindowFunctions:GlobalSetting(Settings)
        hasGlobalSetting = true
        local GlobalSettingFunctions = {}
        local globalSetting = Instance.new("TextButton")
        globalSetting.Name = "GlobalSetting"
        globalSetting.Text = ""
        globalSetting.TextColor3 = Color3.fromRGB(0, 0, 0)
        globalSetting.TextSize = 14
        globalSetting.BackgroundTransparency = 1
        globalSetting.BorderSizePixel = 0
        globalSetting.Size = UDim2.fromOffset(200, 30)

        local globalSettingToggleUIPadding = Instance.new("UIPadding")
        globalSettingToggleUIPadding.Name = "GlobalSettingToggleUIPadding"
        globalSettingToggleUIPadding.PaddingLeft = UDim.new(0, 15)
        globalSettingToggleUIPadding.Parent = globalSetting

        local settingName = Instance.new("TextLabel")
        settingName.Name = "SettingName"
        settingName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        settingName.Text = Settings.Name
        settingName.RichText = true
        settingName.TextColor3 = Color3.fromRGB(255, 255, 255)
        settingName.TextSize = 13
        settingName.TextTransparency = 0.5
        settingName.TextTruncate = Enum.TextTruncate.AtEnd
        settingName.TextXAlignment = Enum.TextXAlignment.Left
        settingName.TextYAlignment = Enum.TextYAlignment.Top
        settingName.AnchorPoint = Vector2.new(0, 0.5)
        settingName.AutomaticSize = Enum.AutomaticSize.Y
        settingName.BackgroundTransparency = 1
        settingName.BorderSizePixel = 0
        settingName.Position = UDim2.fromScale(0, 0.5)
        settingName.Size = UDim2.new(1,-40,0,0)
        settingName.Parent = globalSetting

        local globalSettingToggleUIListLayout = Instance.new("UIListLayout")
        globalSettingToggleUIListLayout.Name = "GlobalSettingToggleUIListLayout"
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
        checkmark.TextSize = 13
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
            checkSizeIncrease = 12,
            checkSizeDecrease = -globalSettingToggleUIListLayout.Padding.Offset,
            waitTime = 1
        }

        local tweens = {
            checkIn = Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
            }),
            checkOut = Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle),{
                Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
            }),
            nameIn = Tween(settingName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle),{
                TextTransparency = tweensettings.transparencyIn
            }),
            nameOut = Tween(settingName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle),{
                TextTransparency = tweensettings.transparencyOut
            })
        }

        local toggled = Settings.Default
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
            task.spawn(function()
                if Settings.Callback then
                    Settings.Callback(toggled)
                end
            end)
        end

        return GlobalSettingFunctions
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
        uIListLayout1.Name = "UIListLayout"
        uIListLayout1.Padding = UDim.new(0, 15)
        uIListLayout1.HorizontalAlignment = Enum.HorizontalAlignment.Center
        uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
        uIListLayout1.Parent = sectionTabSwitchers

        local uIPadding1 = Instance.new("UIPadding")
        uIPadding1.Name = "UIPadding"
        uIPadding1.PaddingBottom = UDim.new(0, 15)
        uIPadding1.Parent = sectionTabSwitchers

        sectionTabSwitchers.Parent = tabGroup

        function SectionFunctions:Tab(Settings)
            local TabFunctions = {}
            local tabSwitcher = Instance.new("TextButton")
            tabSwitcher.Name = "TabSwitcher"
            tabSwitcher.Text = ""
            tabSwitcher.TextColor3 = Color3.fromRGB(0, 0, 0)
            tabSwitcher.TextSize = 14
            tabSwitcher.AutoButtonColor = false
            tabSwitcher.AnchorPoint = Vector2.new(0.5, 0)
            tabSwitcher.BackgroundTransparency = 1
            tabSwitcher.BorderSizePixel = 0
            tabSwitcher.Position = UDim2.fromScale(0.5, 0)
            tabSwitcher.Size = UDim2.new(1, -21, 0, 40)

            tabIndex += 1
            tabSwitcher.LayoutOrder = tabIndex

            local tabSwitcherUICorner = Instance.new("UICorner")
            tabSwitcherUICorner.Name = "TabSwitcherUICorner"
            tabSwitcherUICorner.Parent = tabSwitcher

            local tabSwitcherUIStroke = Instance.new("UIStroke")
            tabSwitcherUIStroke.Name = "TabSwitcherUIStroke"
            tabSwitcherUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            tabSwitcherUIStroke.Color = Color3.fromRGB(255, 255, 255)
            tabSwitcherUIStroke.Transparency = 1
            tabSwitcherUIStroke.Parent = tabSwitcher

            local tabSwitcherUIListLayout = Instance.new("UIListLayout")
            tabSwitcherUIListLayout.Name = "TabSwitcherUIListLayout"
            tabSwitcherUIListLayout.Padding = UDim.new(0, 9)
            tabSwitcherUIListLayout.FillDirection = Enum.FillDirection.Horizontal
            tabSwitcherUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            tabSwitcherUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            tabSwitcherUIListLayout.Parent = tabSwitcher

            local tabImage
            if Settings.Image then
                tabImage = Instance.new("ImageLabel")
                tabImage.Name = "TabImage"
                tabImage.Image = Settings.Image
                tabImage.ImageTransparency = 0.4
                tabImage.BackgroundTransparency = 1
                tabImage.BorderSizePixel = 0
                tabImage.Size = UDim2.fromOffset(16, 16)
                tabImage.Parent = tabSwitcher
            end

            local tabSwitcherName = Instance.new("TextLabel")
            tabSwitcherName.Name = "TabSwitcherName"
            tabSwitcherName.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            tabSwitcherName.Text = Settings.Name
            tabSwitcherName.RichText = true
            tabSwitcherName.TextColor3 = Color3.fromRGB(255, 255, 255)
            tabSwitcherName.TextSize = 16
            tabSwitcherName.TextTransparency = 0.4
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
            tabSwitcherUIPadding.Name = "TabSwitcherUIPadding"
            tabSwitcherUIPadding.PaddingLeft = UDim.new(0, 24)
            tabSwitcherUIPadding.PaddingRight = UDim.new(0, 35)
            tabSwitcherUIPadding.PaddingTop = UDim.new(0, 1)
            tabSwitcherUIPadding.Parent = tabSwitcher

            tabSwitcher.Parent = sectionTabSwitchers

            local elements1 = Instance.new("Frame")
            elements1.Name = "Elements"
            elements1.BackgroundTransparency = 1
            elements1.BorderSizePixel = 0
            elements1.Position = UDim2.fromOffset(0, 63)
            elements1.Size = UDim2.new(1, 0, 1, -63)

            local elementsUIPadding = Instance.new("UIPadding")
            elementsUIPadding.Name = "ElementsUIPadding"
            elementsUIPadding.PaddingRight = UDim.new(0, 5)
            elementsUIPadding.PaddingTop = UDim.new(0, 10)
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

            local elementsScrollingUIPadding = Instance.new("UIPadding")
            elementsScrollingUIPadding.Name = "ElementsScrollingUIPadding"
            elementsScrollingUIPadding.PaddingBottom = UDim.new(0, 15)
            elementsScrollingUIPadding.PaddingLeft = UDim.new(0, 11)
            elementsScrollingUIPadding.PaddingRight = UDim.new(0, 3)
            elementsScrollingUIPadding.PaddingTop = UDim.new(0, 5)
            elementsScrollingUIPadding.Parent = elementsScrolling

            local elementsScrollingUIListLayout = Instance.new("UIListLayout")
            elementsScrollingUIListLayout.Name = "ElementsScrollingUIListLayout"
            elementsScrollingUIListLayout.Padding = UDim.new(0, 15)
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
            leftUIListLayout.Name = "LeftUIListLayout"
            leftUIListLayout.Padding = UDim.new(0, 15)
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
            rightUIListLayout.Name = "RightUIListLayout"
            rightUIListLayout.Padding = UDim.new(0, 15)
            rightUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            rightUIListLayout.Parent = right

            right.Parent = elementsScrolling

            elementsScrolling.Parent = elements1

            function TabFunctions:Section(Settings)
                local SectionFunctions = {}
                local section = Instance.new("Frame")
                section.Name = "Section"
                section.AutomaticSize = Enum.AutomaticSize.Y
                section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                section.BackgroundTransparency = 0.98
                section.BorderSizePixel = 0
                section.Position = UDim2.fromScale(0, 0)
                section.Size = UDim2.fromScale(1, 0)
                section.Parent = Settings.Side == "Left" and left or right

                local sectionUICorner = Instance.new("UICorner")
                sectionUICorner.Name = "SectionUICorner"
                sectionUICorner.Parent = section

                local sectionUIStroke = Instance.new("UIStroke")
                sectionUIStroke.Name = "SectionUIStroke"
                sectionUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                sectionUIStroke.Color = Color3.fromRGB(255, 255, 255)
                sectionUIStroke.Transparency = 0.95
                sectionUIStroke.Parent = section

                local sectionUIListLayout = Instance.new("UIListLayout")
                sectionUIListLayout.Name = "SectionUIListLayout"
                sectionUIListLayout.Padding = UDim.new(0, 10)
                sectionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                sectionUIListLayout.Parent = section

                local sectionUIPadding = Instance.new("UIPadding")
                sectionUIPadding.Name = "SectionUIPadding"
                sectionUIPadding.PaddingBottom = UDim.new(0, 20)
                sectionUIPadding.PaddingLeft = UDim.new(0, 20)
                sectionUIPadding.PaddingRight = UDim.new(0, 18)
                sectionUIPadding.PaddingTop = UDim.new(0, 22)
                sectionUIPadding.Parent = section

                function SectionFunctions:Button(Settings)
                    local ButtonFunctions = {}
                    local button = Instance.new("Frame")
                    button.Name = "Button"
                    button.AutomaticSize = Enum.AutomaticSize.Y
                    button.BackgroundTransparency = 1
                    button.BorderSizePixel = 0
                    button.Size = UDim2.new(1, 0, 0, 38)
                    button.Parent = section

                    local buttonInteract = Instance.new("TextButton")
                    buttonInteract.Name = "ButtonInteract"
                    buttonInteract.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    buttonInteract.RichText = true
                    buttonInteract.TextColor3 = Color3.fromRGB(255, 255, 255)
                    buttonInteract.TextSize = 13
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
                    return ButtonFunctions
                end

                function SectionFunctions:Toggle(Settings)
                    local ToggleFunctions = {}
                    local toggle = Instance.new("Frame")
                    toggle.Name = "Toggle"
                    toggle.AutomaticSize = Enum.AutomaticSize.Y
                    toggle.BackgroundTransparency = 1
                    toggle.BorderSizePixel = 0
                    toggle.Size = UDim2.new(1, 0, 0, 38)
                    toggle.Parent = section

                    local toggleName = Instance.new("TextLabel")
                    toggleName.Name = "ToggleName"
                    toggleName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    toggleName.Text = Settings.Name
                    toggleName.RichText = true
                    toggleName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    toggleName.TextSize = 13
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
                    toggle1.ImageColor3 = Color3.fromRGB(61, 61, 61)
                    toggle1.AutoButtonColor = false
                    toggle1.AnchorPoint = Vector2.new(1, 0.5)
                    toggle1.BackgroundTransparency = 1
                    toggle1.BorderSizePixel = 0
                    toggle1.Position = UDim2.fromScale(1, 0.5)
                    toggle1.Size = UDim2.fromOffset(41, 21)

                    local toggleUIPadding = Instance.new("UIPadding")
                    toggleUIPadding.Name = "ToggleUIPadding"
                    toggleUIPadding.PaddingBottom = UDim.new(0, 1)
                    toggleUIPadding.PaddingLeft = UDim.new(0, -2)
                    toggleUIPadding.PaddingRight = UDim.new(0, 3)
                    toggleUIPadding.PaddingTop = UDim.new(0, 1)
                    toggleUIPadding.Parent = toggle1

                    local togglerHead = Instance.new("ImageLabel")
                    togglerHead.Name = "TogglerHead"
                    togglerHead.Image = assets.togglerHead
                    togglerHead.ImageColor3 = Color3.fromRGB(91, 91, 91)
                    togglerHead.AnchorPoint = Vector2.new(1, 0.5)
                    togglerHead.BackgroundTransparency = 1
                    togglerHead.BorderSizePixel = 0
                    togglerHead.Position = UDim2.fromScale(0.5, 0.5)
                    togglerHead.Size = UDim2.fromOffset(15, 15)
                    togglerHead.ZIndex = 2
                    togglerHead.Parent = toggle1

                    toggle1.Parent = toggle

                    local TweenSettings = {
                        Info = TweenInfo.new(0.2, Enum.EasingStyle.Sine),
                        EnabledColors = {Toggle = Color3.fromRGB(87, 86, 86), ToggleHead = Color3.fromRGB(255, 255, 255)},
                        DisabledColors = {Toggle = Color3.fromRGB(61, 61, 61), ToggleHead = Color3.fromRGB(91, 91, 91)},
                        EnabledPosition = UDim2.new(1, 0, 0.5, 0),
                        DisabledPosition = UDim2.new(0.5, 0, 0.5, 0),
                    }

                    local function ToggleState(State)
                        if State then
                            Tween(toggle1, TweenSettings.Info, {ImageColor3 = TweenSettings.EnabledColors.Toggle}):Play()
                            Tween(togglerHead, TweenSettings.Info, {ImageColor3 = TweenSettings.EnabledColors.ToggleHead}):Play()
                            Tween(togglerHead, TweenSettings.Info, {Position = TweenSettings.EnabledPosition}):Play()
                        else
                            Tween(toggle1, TweenSettings.Info, {ImageColor3 = TweenSettings.DisabledColors.Toggle}):Play()
                            Tween(togglerHead, TweenSettings.Info, {ImageColor3 = TweenSettings.DisabledColors.ToggleHead}):Play()
                            Tween(togglerHead, TweenSettings.Info, {Position = TweenSettings.DisabledPosition}):Play()
                        end
                        ToggleFunctions.State = State
                    end

                    local togglebool = Settings.Default
                    ToggleState(togglebool)

                    local function Toggle()
                        togglebool = not togglebool
                        ToggleState(togglebool)
                        if Settings.Callback then
                            Settings.Callback(togglebool)
                        end
                    end

                    toggle1.MouseButton1Click:Connect(Toggle)

                    function ToggleFunctions:Toggle()
                        Toggle()
                    end
                    function ToggleFunctions:UpdateState(State)
                        togglebool = State
                        ToggleState(togglebool)
                        if Settings.Callback then
                            Settings.Callback(togglebool)
                        end
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
                    return ToggleFunctions
                end

                function SectionFunctions:Slider(Settings)
                    local SliderFunctions = {}
                    local slider = Instance.new("Frame")
                    slider.Name = "Slider"
                    slider.AutomaticSize = Enum.AutomaticSize.Y
                    slider.BackgroundTransparency = 1
                    slider.BorderSizePixel = 0
                    slider.Size = UDim2.new(1, 0, 0, 38)
                    slider.Parent = section

                    local sliderName = Instance.new("TextLabel")
                    sliderName.Name = "SliderName"
                    sliderName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    sliderName.Text = Settings.Name
                    sliderName.RichText = true
                    sliderName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    sliderName.TextSize = 13
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
                    sliderValue.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    sliderValue.Text = "100%"
                    sliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
                    sliderValue.TextSize = 12
                    sliderValue.TextTransparency = 0.4
                    sliderValue.TextTruncate = Enum.TextTruncate.AtEnd
                    sliderValue.BackgroundTransparency = 0.95
                    sliderValue.BorderSizePixel = 0
                    sliderValue.LayoutOrder = 1
                    sliderValue.Position = UDim2.fromScale(-0.0789, 0.171)
                    sliderValue.Size = UDim2.fromOffset(41, 21)

                    local sliderValueUICorner = Instance.new("UICorner")
                    sliderValueUICorner.Name = "SliderValueUICorner"
                    sliderValueUICorner.CornerRadius = UDim.new(0, 4)
                    sliderValueUICorner.Parent = sliderValue

                    local sliderValueUIStroke = Instance.new("UIStroke")
                    sliderValueUIStroke.Name = "SliderValueUIStroke"
                    sliderValueUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    sliderValueUIStroke.Color = Color3.fromRGB(255, 255, 255)
                    sliderValueUIStroke.Transparency = 0.9
                    sliderValueUIStroke.Parent = sliderValue

                    local sliderValueUIPadding = Instance.new("UIPadding")
                    sliderValueUIPadding.Name = "SliderValueUIPadding"
                    sliderValueUIPadding.PaddingLeft = UDim.new(0, 2)
                    sliderValueUIPadding.PaddingRight = UDim.new(0, 2)
                    sliderValueUIPadding.Parent = sliderValue

                    sliderValue.Parent = sliderElements

                    local sliderElementsUIListLayout = Instance.new("UIListLayout")
                    sliderElementsUIListLayout.Name = "SliderElementsUIListLayout"
                    sliderElementsUIListLayout.Padding = UDim.new(0, 20)
                    sliderElementsUIListLayout.FillDirection = Enum.FillDirection.Horizontal
                    sliderElementsUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                    sliderElementsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    sliderElementsUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                    sliderElementsUIListLayout.Parent = sliderElements

                    local sliderBar = Instance.new("ImageLabel")
                    sliderBar.Name = "SliderBar"
                    sliderBar.Image = assets.sliderBar
                    sliderBar.ImageColor3 = Color3.fromRGB(87, 86, 86)
                    sliderBar.BackgroundTransparency = 1
                    sliderBar.BorderSizePixel = 0
                    sliderBar.Position = UDim2.fromScale(0.219, 0.457)
                    sliderBar.Size = UDim2.fromOffset(123, 3)

                    local sliderHead = Instance.new("ImageButton")
                    sliderHead.Name = "SliderHead"
                    sliderHead.Image = assets.sliderHead
                    sliderHead.AnchorPoint = Vector2.new(0.5, 0.5)
                    sliderHead.BackgroundTransparency = 1
                    sliderHead.BorderSizePixel = 0
                    sliderHead.Position = UDim2.fromScale(1, 0.5)
                    sliderHead.Size = UDim2.fromOffset(12, 12)
                    sliderHead.Parent = sliderBar

                    sliderBar.Parent = sliderElements

                    local sliderElementsUIPadding = Instance.new("UIPadding")
                    sliderElementsUIPadding.Name = "SliderElementsUIPadding"
                    sliderElementsUIPadding.PaddingTop = UDim.new(0, 3)
                    sliderElementsUIPadding.Parent = sliderElements

                    sliderElements.Parent = slider

                    local dragging = false

                    local DisplayMethods = {
                        Hundredths = function(sliderValue)
                            return string.format("%.2f", sliderValue)
                        end,
                        Tenths = function(sliderValue)
                            return string.format("%.1f", sliderValue)
                        end,
                        Round = function(sliderValue)
                            return tostring(math.round(sliderValue))
                        end,
                        Degrees = function(sliderValue)
                            return tostring(math.round(sliderValue)) .. "°"
                        end,
                        Percent = function(sliderValue)
                            local percentage = (sliderValue - Settings.Minimum) / (Settings.Maximum - Settings.Minimum) * 100
                            return tostring(math.round(percentage)) .. "%"
                        end,
                        Value = function(sliderValue)
                            return tostring(sliderValue)
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
                        sliderValue.Text = ValueDisplayMethod(finalValue)

                        if not ignorecallback then
                            task.spawn(function()
                                if Settings.Callback then
                                    Settings.Callback(finalValue)
                                end
                            end)
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
                            sliderValue.Text = ValueDisplayMethod(finalValue)
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            SetValue(input)
                        end
                    end)

                    local function updateSliderBarSize()
                        local padding = sliderElementsUIListLayout.Padding.Offset
                        local sliderValueWidth = sliderValue.AbsoluteSize.X
                        local sliderNameWidth = sliderName.AbsoluteSize.X
                        local totalWidth = sliderElements.AbsoluteSize.X
                        local newBarWidth = totalWidth - (padding + sliderValueWidth + sliderNameWidth + 20)
                        sliderBar.Size = UDim2.new(sliderBar.Size.X.Scale, newBarWidth, sliderBar.Size.Y.Scale, sliderBar.Size.Y.Offset)
                    end

                    updateSliderBarSize()
                    sliderName:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSliderBarSize)
                    section:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSliderBarSize)

                    function SliderFunctions:UpdateName(Name)
                        sliderName.Text = Name
                    end
                    function SliderFunctions:SetVisibility(State)
                        slider.Visible = State
                    end
                    function SliderFunctions:UpdateValue(Value)
                        SetValue(Value)
                    end
                    function SliderFunctions:GetValue()
                        return finalValue
                    end
                    return SliderFunctions
                end

                function SectionFunctions:Input(Settings)
                    local InputFunctions = {}
                    local input = Instance.new("Frame")
                    input.Name = "Input"
                    input.AutomaticSize = Enum.AutomaticSize.Y
                    input.BackgroundTransparency = 1
                    input.BorderSizePixel = 0
                    input.Size = UDim2.new(1, 0, 0, 38)
                    input.Parent = section

                    local inputName = Instance.new("TextLabel")
                    inputName.Name = "InputName"
                    inputName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    inputName.Text = Settings.Name
                    inputName.RichText = true
                    inputName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    inputName.TextSize = 13
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
                    inputBox.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    inputBox.Text = Settings.Default or ""
                    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                    inputBox.TextSize = 12
                    inputBox.TextTransparency = 0.4
                    inputBox.AnchorPoint = Vector2.new(1, 0.5)
                    inputBox.AutomaticSize = Enum.AutomaticSize.X
                    inputBox.BackgroundTransparency = 0.95
                    inputBox.BorderSizePixel = 0
                    inputBox.ClipsDescendants = true
                    inputBox.LayoutOrder = 1
                    inputBox.Position = UDim2.fromScale(1, 0.5)
                    inputBox.Size = UDim2.fromOffset(21, 21)

                    local inputBoxUICorner = Instance.new("UICorner")
                    inputBoxUICorner.Name = "InputBoxUICorner"
                    inputBoxUICorner.CornerRadius = UDim.new(0, 4)
                    inputBoxUICorner.Parent = inputBox

                    local inputBoxUIStroke = Instance.new("UIStroke")
                    inputBoxUIStroke.Name = "InputBoxUIStroke"
                    inputBoxUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    inputBoxUIStroke.Color = Color3.fromRGB(255, 255, 255)
                    inputBoxUIStroke.Transparency = 0.9
                    inputBoxUIStroke.Parent = inputBox

                    local inputBoxUIPadding = Instance.new("UIPadding")
                    inputBoxUIPadding.Name = "InputBoxUIPadding"
                    inputBoxUIPadding.PaddingLeft = UDim.new(0, 5)
                    inputBoxUIPadding.PaddingRight = UDim.new(0, 5)
                    inputBoxUIPadding.Parent = inputBox

                    local inputBoxUISizeConstraint = Instance.new("UISizeConstraint")
                    inputBoxUISizeConstraint.Name = "InputBoxUISizeConstraint"
                    inputBoxUISizeConstraint.Parent = inputBox

                    inputBox.Parent = input

                    local CharacterSubs = {
                        All = function(value)
                            return value
                        end,
                        Numeric = function(value)
                            return value:match("^%-?%d*$") and value or value:gsub("[^%d-]", ""):gsub("(%-)", function(match, pos, original)
                                if pos == 1 then
                                    return match
                                else
                                    return ""
                                end
                            end)
                        end,
                        Alphabetic = function(value)
                            return value:gsub("[^a-zA-Z ]", "")
                        end,
                    }

                    local AcceptedCharacters = CharacterSubs[Settings.AcceptedCharacters] or CharacterSubs.All
                    InputBox.AutomaticSize = Enum.AutomaticSize.X

                    local function checkSize()
                        local nameWidth = inputName.AbsoluteSize.X
                        local totalWidth = input.AbsoluteSize.X
                        local maxWidth = totalWidth - nameWidth - 20
                        inputBoxUISizeConstraint.MaxSize = Vector2.new(maxWidth, 9e9)
                    end

                    checkSize()
                    inputName:GetPropertyChangedSignal("AbsoluteSize"):Connect(checkSize)

                    inputBox.FocusLost:Connect(function()
                        local inputText = inputBox.Text
                        local filteredText = AcceptedCharacters(inputText)
                        inputBox.Text = filteredText
                        task.spawn(function()
                            if Settings.Callback then
                                Settings.Callback(filteredText)
                            end
                        end)
                    end)

                    inputBox.PlaceholderText = Settings.Placeholder or ""

                    inputBox:GetPropertyChangedSignal("Text"):Connect(function()
                        inputBox.Text = AcceptedCharacters(inputBox.Text)
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
                        inputBox.Text = Text
                    end
                    return InputFunctions
                end

                function SectionFunctions:Keybind(Settings)
                    local KeybindFunctions = {}
                    local keybind = Instance.new("Frame")
                    keybind.Name = "Keybind"
                    keybind.AutomaticSize = Enum.AutomaticSize.Y
                    keybind.BackgroundTransparency = 1
                    keybind.BorderSizePixel = 0
                    keybind.Size = UDim2.new(1, 0, 0, 38)
                    keybind.Parent = section

                    local keybindName = Instance.new("TextLabel")
                    keybindName.Name = "KeybindName"
                    keybindName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    keybindName.Text = Settings.Name
                    keybindName.RichText = true
                    keybindName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    keybindName.TextSize = 13
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

                    local binderBox = Instance.new("TextBox")
                    binderBox.Name = "BinderBox"
                    binderBox.CursorPosition = -1
                    binderBox.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    binderBox.PlaceholderText = "..."
                    binderBox.Text = ""
                    binderBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                    binderBox.TextSize = 12
                    binderBox.TextTransparency = 0.4
                    binderBox.AnchorPoint = Vector2.new(1, 0.5)
                    binderBox.AutomaticSize = Enum.AutomaticSize.X
                    binderBox.BackgroundTransparency = 0.95
                    binderBox.BorderSizePixel = 0
                    binderBox.ClipsDescendants = true
                    binderBox.LayoutOrder = 1
                    binderBox.Position = UDim2.fromScale(1, 0.5)
                    binderBox.Size = UDim2.fromOffset(21, 21)

                    local binderBoxUICorner = Instance.new("UICorner")
                    binderBoxUICorner.Name = "BinderBoxUICorner"
                    binderBoxUICorner.CornerRadius = UDim.new(0, 4)
                    binderBoxUICorner.Parent = binderBox

                    local binderBoxUIStroke = Instance.new("UIStroke")
                    binderBoxUIStroke.Name = "BinderBoxUIStroke"
                    binderBoxUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    binderBoxUIStroke.Color = Color3.fromRGB(255, 255, 255)
                    binderBoxUIStroke.Transparency = 0.9
                    binderBoxUIStroke.Parent = binderBox

                    local binderBoxUIPadding = Instance.new("UIPadding")
                    binderBoxUIPadding.Name = "BinderBoxUIPadding"
                    binderBoxUIPadding.PaddingLeft = UDim.new(0, 5)
                    binderBoxUIPadding.PaddingRight = UDim.new(0, 5)
                    binderBoxUIPadding.Parent = binderBox

                    local binderBoxUISizeConstraint = Instance.new("UISizeConstraint")
                    binderBoxUISizeConstraint.Name = "BinderBoxUISizeConstraint"
                    binderBoxUISizeConstraint.Parent = binderBox

                    binderBox.Parent = keybind

                    local focused
                    local binded = Settings.Default
                    if binded then
                        binderBox.Text = binded.Name
                    end

                    binderBox.Focused:Connect(function()
                        focused = true
                    end)
                    binderBox.FocusLost:Connect(function()
                        focused = false
                    end)

                    UserInputService.InputEnded:Connect(function(inp)
                        if starLight ~= nil then
                            if focused and inp.KeyCode.Name ~= "Unknown" then
                                binded = inp.KeyCode
                                KeybindFunctions.Bind = binded
                                binderBox.Text = inp.KeyCode.Name
                                binderBox:ReleaseFocus()
                                if Settings.onBinded then
                                    Settings.onBinded(binded)
                                end
                            elseif inp.KeyCode == binded then
                                if Settings.Callback then
                                    Settings.Callback(binded)
                                end
                            end
                        end
                    end)

                    function KeybindFunctions:Bind(Key)
                        binded = Key
                        binderBox.Text = Key.Name
                    end
                    function KeybindFunctions:Unbind()
                        binded = nil
                        binderBox.Text = ""
                    end
                    function KeybindFunctions:GetBind()
                        return binded
                    end
                    function KeybindFunctions:UpdateName(Name)
                        keybindName = Name
                    end
                    function KeybindFunctions:SetVisibility(State)
                        keybind.Visible = State
                    end
                    return KeybindFunctions
                end

                function SectionFunctions:Dropdown(Settings)
                    local DropdownFunctions = {}
                    local Selected = {}
                    local OptionObjs = {}

                    local dropdown = Instance.new("Frame")
                    dropdown.Name = "Dropdown"
                    dropdown.BackgroundTransparency = 0.985
                    dropdown.BorderSizePixel = 0
                    dropdown.Size = UDim2.new(1, 0, 0, 38)
                    dropdown.Parent = section
                    dropdown.ClipsDescendants = true

                    local dropdownUIPadding = Instance.new("UIPadding")
                    dropdownUIPadding.Name = "DropdownUIPadding"
                    dropdownUIPadding.PaddingLeft = UDim.new(0, 15)
                    dropdownUIPadding.PaddingRight = UDim.new(0, 15)
                    dropdownUIPadding.Parent = dropdown

                    local interact = Instance.new("TextButton")
                    interact.Name = "Interact"
                    interact.Text = ""
                    interact.TextColor3 = Color3.fromRGB(0, 0, 0)
                    interact.TextSize = 14
                    interact.BackgroundTransparency = 1
                    interact.BorderSizePixel = 0
                    interact.Size = UDim2.new(1, 0, 0, 38)
                    interact.Parent = dropdown

                    local dropdownName = Instance.new("TextLabel")
                    dropdownName.Name = "DropdownName"
                    dropdownName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    dropdownName.Text = Settings.Name
                    dropdownName.RichText = true
                    dropdownName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    dropdownName.TextSize = 13
                    dropdownName.TextTransparency = 0.5
                    dropdownName.TextTruncate = Enum.TextTruncate.AtEnd
                    dropdownName.TextXAlignment = Enum.TextXAlignment.Left
                    dropdownName.AutomaticSize = Enum.AutomaticSize.Y
                    dropdownName.BackgroundTransparency = 1
                    dropdownName.BorderSizePixel = 0
                    dropdownName.Size = UDim2.new(1, -20, 0, 38)
                    dropdownName.Parent = dropdown

                    local dropdownUIStroke = Instance.new("UIStroke")
                    dropdownUIStroke.Name = "DropdownUIStroke"
                    dropdownUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    dropdownUIStroke.Color = Color3.fromRGB(255, 255, 255)
                    dropdownUIStroke.Transparency = 0.95
                    dropdownUIStroke.Parent = dropdown

                    local dropdownUICorner = Instance.new("UICorner")
                    dropdownUICorner.Name = "DropdownUICorner"
                    dropdownUICorner.CornerRadius = UDim.new(0, 6)
                    dropdownUICorner.Parent = dropdown

                    local dropdownImage = Instance.new("ImageLabel")
                    dropdownImage.Name = "DropdownImage"
                    dropdownImage.Image = assets.dropdownArrow
                    dropdownImage.ImageTransparency = 0.5
                    dropdownImage.AnchorPoint = Vector2.new(1, 0)
                    dropdownImage.BackgroundTransparency = 1
                    dropdownImage.BorderSizePixel = 0
                    dropdownImage.Position = UDim2.new(1, 0, 0, 12)
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
                    dropdownFrameUIPadding.Name = "DropdownFrameUIPadding"
                    dropdownFrameUIPadding.PaddingTop = UDim.new(0, 38)
                    dropdownFrameUIPadding.PaddingBottom = UDim.new(0, 10)
                    dropdownFrameUIPadding.Parent = dropdownFrame

                    local dropdownFrameUIListLayout = Instance.new("UIListLayout")
                    dropdownFrameUIListLayout.Name = "DropdownFrameUIListLayout"
                    dropdownFrameUIListLayout.Padding = UDim.new(0, 5)
                    dropdownFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    dropdownFrameUIListLayout.Parent = dropdownFrame

                    local search = Instance.new("Frame")
                    search.Name = "Search"
                    search.BackgroundTransparency = 0.95
                    search.BorderSizePixel = 0
                    search.LayoutOrder = -1
                    search.Size = UDim2.new(1, 0, 0, 30)
                    search.Parent = dropdownFrame
                    search.Visible = Settings.Search

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
                    uIPadding.Name = "UIPadding"
                    uIPadding.PaddingLeft = UDim.new(0, 15)
                    uIPadding.Parent = search

                    local searchBox = Instance.new("TextBox")
                    searchBox.Name = "SearchBox"
                    searchBox.CursorPosition = -1
                    searchBox.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
                    searchBox.PlaceholderText = "Search..."
                    searchBox.Text = ""
                    searchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
                    searchBox.TextSize = 14
                    searchBox.TextXAlignment = Enum.TextXAlignment.Left
                    searchBox.BackgroundTransparency = 1
                    searchBox.BorderSizePixel = 0
                    searchBox.Size = UDim2.fromScale(1, 1)

                    function CalculateDropdownSize()
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

                    local function findOption()
                        local searchTerm = searchBox.Text:lower()
                        for _, v in pairs(OptionObjs) do
                            local optionText = v.NameLabel.Text:lower()
                            local isVisible = string.find(optionText, searchTerm) ~= nil
                            if v.Button.Visible ~= isVisible then
                                v.Button.Visible = isVisible
                            end
                        end
                        dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
                    end

                    searchBox:GetPropertyChangedSignal("Text"):Connect(findOption)

                    local uIPadding1 = Instance.new("UIPadding")
                    uIPadding1.Name = "UIPadding"
                    uIPadding1.PaddingLeft = UDim.new(0, 23)
                    uIPadding1.Parent = searchBox

                    searchBox.Parent = search

                    search.Parent = dropdownFrame

                    local tweensettings = {
                        duration = 0.2,
                        easingStyle = Enum.EasingStyle.Quint,
                        transparencyIn = 0.2,
                        transparencyOut = 0.5,
                        checkSizeIncrease = 12,
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
                                    DropdownFunctions.Value = Selected
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
                                DropdownFunctions.Value = Selected[1]
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
                            dropdownName.Text = Settings.Name
                        end
                    end

                    local dropped = false
                    local db = false

                    local function ToggleDropdown()
                        if db then return end
                        db = true
                        local defaultDropdownSize = 38
                        local isDropdownOpen = not dropped
                        local targetSize = isDropdownOpen and UDim2.new(1, 0, 0, CalculateDropdownSize()) or UDim2.new(1, 0, 0, defaultDropdownSize)

                        local tween = Tween(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                            Size = targetSize
                        })
                        tween:Play()

                        if isDropdownOpen then
                            dropdownFrame.Visible = true
                            tween.Completed:Connect(function()
                                db = false
                            end)
                        else
                            tween.Completed:Connect(function()
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
                        option.TextColor3 = Color3.fromRGB(0, 0, 0)
                        option.TextSize = 14
                        option.BackgroundTransparency = 1
                        option.BorderSizePixel = 0
                        option.Size = UDim2.new(1, 0, 0, 30)

                        local optionUIPadding = Instance.new("UIPadding")
                        optionUIPadding.Name = "OptionUIPadding"
                        optionUIPadding.PaddingLeft = UDim.new(0, 15)
                        optionUIPadding.Parent = option

                        local optionName = Instance.new("TextLabel")
                        optionName.Name = "OptionName"
                        optionName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                        optionName.Text = v
                        optionName.RichText = true
                        optionName.TextColor3 = Color3.fromRGB(255, 255, 255)
                        optionName.TextSize = 13
                        optionName.TextTransparency = 0.5
                        optionName.TextTruncate = Enum.TextTruncate.AtEnd
                        optionName.TextXAlignment = Enum.TextXAlignment.Left
                        optionName.TextYAlignment = Enum.TextYAlignment.Top
                        optionName.AnchorPoint = Vector2.new(0, 0.5)
                        optionName.AutomaticSize = Enum.AutomaticSize.XY
                        optionName.BackgroundTransparency = 1
                        optionName.BorderSizePixel = 0
                        optionName.Position = UDim2.fromScale(0, 0.5)
                        optionName.Parent = option

                        local optionUIListLayout = Instance.new("UIListLayout")
                        optionUIListLayout.Name = "OptionUIListLayout"
                        optionUIListLayout.Padding = UDim.new(0, 10)
                        optionUIListLayout.FillDirection = Enum.FillDirection.Horizontal
                        optionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        optionUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                        optionUIListLayout.Parent = option

                        local checkmark = Instance.new("TextLabel")
                        checkmark.Name = "Checkmark"
                        checkmark.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                        checkmark.Text = "✓"
                        checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
                        checkmark.TextSize = 13
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

                        local tweensettings2 = {
                            duration = 0.2,
                            easingStyle = Enum.EasingStyle.Quint,
                            transparencyIn = 0.2,
                            transparencyOut = 0.5,
                            checkSizeIncrease = 12,
                            checkSizeDecrease = -optionUIListLayout.Padding.Offset,
                            waitTime = 1
                        }
                        local tweens2 = {
                            checkIn = Tween(checkmark, TweenInfo.new(tweensettings2.duration, tweensettings2.easingStyle), {
                                Size = UDim2.new(checkmark.Size.X.Scale, tweensettings2.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
                            }),
                            checkOut = Tween(checkmark, TweenInfo.new(tweensettings2.duration, tweensettings2.easingStyle),{
                                Size = UDim2.new(checkmark.Size.X.Scale, tweensettings2.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
                            }),
                            nameIn = Tween(optionName, TweenInfo.new(tweensettings2.duration, tweensettings2.easingStyle),{
                                TextTransparency = tweensettings2.transparencyIn
                            }),
                            nameOut = Tween(optionName, TweenInfo.new(tweensettings2.duration, tweensettings2.easingStyle),{
                                TextTransparency = tweensettings2.transparencyOut
                            })
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

                        local optionButton = OptionObjs[v].Button
                        optionButton.MouseButton1Click:Connect(function()
                            local isSelected = table.find(Selected, v) and true or false
                            local newSelected = not isSelected

                            if Settings.Required and not newSelected and #Selected <= 1 then
                                return
                            end

                            Toggle(v, newSelected)

                            task.spawn(function()
                                if Settings.Multi then
                                    local Return = {}
                                    for _, opt in ipairs(Selected) do
                                        Return[opt] = true
                                    end
                                    if Settings.Callback then
                                        Settings.Callback(Return)
                                    end
                                else
                                    if newSelected and Settings.Callback then
                                        Settings.Callback(Selected[1] or nil)
                                    end
                                end
                            end)
                        end)

                        if dropped then
                            dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
                        end
                    end

                    for i, v in pairs(Settings.Options) do
                        addOption(i, v)
                    end

                    function DropdownFunctions:UpdateName(New)
                        dropdownName.Text = New
                    end
                    function DropdownFunctions:SetVisibility(State)
                        dropdown.Visible = State
                    end
                    function DropdownFunctions:UpdateSelection(newSelection)
                        if type(newSelection) == "number" then
                            for option, data in pairs(OptionObjs) do
                                local isSelected = data.Index == newSelection
                                Toggle(option, isSelected)
                            end
                        elseif type(newSelection) == "table" then
                            for option, data in pairs(OptionObjs) do
                                local isSelected = table.find(newSelection, option) ~= nil
                                Toggle(option, isSelected)
                            end
                        end
                    end
                    function DropdownFunctions:InsertOptions(newOptions)
                        Settings.Options = newOptions
                        for i, v in pairs(newOptions) do
                            addOption(i, v)
                        end
                    end
                    function DropdownFunctions:ClearOptions()
                        for _, optionData in pairs(OptionObjs) do
                            optionData.Button:Destroy()
                        end
                        OptionObjs = {}
                        Selected = {}

                        if dropped then
                            dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
                        end
                    end
                    function DropdownFunctions:GetOptions()
                        local optionsStatus = {}
                        for option, _ in pairs(OptionObjs) do
                            local isSelected = table.find(Selected, option) and true or false
                            optionsStatus[option] = isSelected
                        end
                        return optionsStatus
                    end
                    function DropdownFunctions:RemoveOptions(remove)
                        for _, optionName in ipairs(remove) do
                            local optionData = OptionObjs[optionName]
                            if optionData then
                                for i = #Selected, 1, -1 do
                                    if Selected[i] == optionName then
                                        table.remove(Selected, i)
                                    end
                                end
                                optionData.Button:Destroy()
                                OptionObjs[optionName] = nil
                            end
                        end

                        if dropped then
                            dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
                        end
                    end
                    function DropdownFunctions:IsOption(optionName)
                        return OptionObjs[optionName] ~= nil
                    end

                    return DropdownFunctions
                end

                function SectionFunctions:Colorpicker(Settings)
                    local ColorpickerFunctions = {}
                    local isAlpha = Settings.Alpha and true or false
                    ColorpickerFunctions.Color = Settings.Default
                    ColorpickerFunctions.Alpha = isAlpha and Settings.Alpha

                    local colorpicker = Instance.new("Frame")
                    colorpicker.Name = "Colorpicker"
                    colorpicker.AutomaticSize = Enum.AutomaticSize.Y
                    colorpicker.BackgroundTransparency = 1
                    colorpicker.BorderSizePixel = 0
                    colorpicker.Size = UDim2.new(1, 0, 0, 38)
                    colorpicker.Parent = section

                    local colorpickerName = Instance.new("TextLabel")
                    colorpickerName.Name = "KeybindName"
                    colorpickerName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    colorpickerName.Text = Settings.Name
                    colorpickerName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    colorpickerName.TextSize = 13
                    colorpickerName.TextTransparency = 0.5
                    colorpickerName.RichText = true
                    colorpickerName.TextTruncate = Enum.TextTruncate.AtEnd
                    colorpickerName.TextXAlignment = Enum.TextXAlignment.Left
                    colorpickerName.TextYAlignment = Enum.TextYAlignment.Top
                    colorpickerName.AnchorPoint = Vector2.new(0, 0.5)
                    colorpickerName.AutomaticSize = Enum.AutomaticSize.XY
                    colorpickerName.BackgroundTransparency = 1
                    colorpickerName.BorderSizePixel = 0
                    colorpickerName.Position = UDim2.fromScale(0, 0.5)
                    colorpickerName.Parent = colorpicker

                    local colorCbg = Instance.new("ImageLabel")
                    colorCbg.Name = "NewColor"
                    colorCbg.Image = assets.colorPickerBg
                    colorCbg.ScaleType = Enum.ScaleType.Tile
                    colorCbg.TileSize = UDim2.fromOffset(500, 500)
                    colorCbg.AnchorPoint = Vector2.new(1, 0.5)
                    colorCbg.BackgroundTransparency = 1
                    colorCbg.BorderSizePixel = 0
                    colorCbg.Position = UDim2.fromScale(1, 0.5)
                    colorCbg.Size = UDim2.fromOffset(21, 21)

                    local colorC = Instance.new("Frame")
                    colorC.Name = "Color"
                    colorC.AnchorPoint = Vector2.new(0.5, 0.5)
                    colorC.BackgroundColor3 = ColorpickerFunctions.Color
                    colorC.BorderSizePixel = 0
                    colorC.Position = UDim2.fromScale(0.5, 0.5)
                    colorC.Size = UDim2.fromScale(1, 1)
                    colorC.BackgroundTransparency = ColorpickerFunctions.Alpha or 0

                    local uICorner = Instance.new("UICorner")
                    uICorner.Name = "UICorner"
                    uICorner.CornerRadius = UDim.new(0, 6)
                    uICorner.Parent = colorC

                    local interact = Instance.new("TextButton")
                    interact.Name = "Interact"
                    interact.Text = ""
                    interact.TextColor3 = Color3.fromRGB(0, 0, 0)
                    interact.TextSize = 14
                    interact.BackgroundTransparency = 1
                    interact.BorderSizePixel = 0
                    interact.Size = UDim2.fromScale(1, 1)
                    interact.Parent = colorC

                    colorC.Parent = colorCbg

                    local uICorner1 = Instance.new("UICorner")
                    uICorner1.Name = "UICorner"
                    uICorner1.CornerRadius = UDim.new(0, 8)
                    uICorner1.Parent = colorCbg

                    colorCbg.Parent = colorpicker

                    local function updateImageColor()
                        local color = baseUIStroke.Color
                        local h, s, v = color:ToHSV()
                        local complementColor = Color3.fromHSV((h + 0.5) % 1, s, v)
                        colorCbg.ImageColor3 = complementColor
                    end

                    updateImageColor()
                    baseUIStroke:GetPropertyChangedSignal("Color"):Connect(updateImageColor)

                    return ColorpickerFunctions
                end

                return SectionFunctions
            end

            elements1.Parent = tabSwitcher

            if not currentTabInstance then
                currentTabInstance = elements1
            else
                elements1.Visible = false
            end

            tabSwitcher.MouseButton1Click:Connect(function()
                if currentTabInstance then
                    currentTabInstance.Visible = false
                end
                currentTabInstance = elements1
                elements1.Visible = true

                for _, tab in pairs(sectionTabSwitchers:GetChildren()) do
                    if tab:IsA("TextButton") then
                        local stroke = tab:FindFirstChild("TabSwitcherUIStroke")
                        local text = tab:FindFirstChild("TabSwitcherName")
                        local image = tab:FindFirstChild("TabImage")
                        Tween(stroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
                        Tween(text, TweenInfo.new(0.2), {TextTransparency = 0.4}):Play()
                        if image then
                            Tween(image, TweenInfo.new(0.2), {ImageTransparency = 0.4}):Play()
                        end
                    end
                end

                Tween(tabSwitcherUIStroke, TweenInfo.new(0.2), {Transparency = 0.8}):Play()
                Tween(tabSwitcherName, TweenInfo.new(0.2), {TextTransparency = 0.2}):Play()
                if tabImage then
                    Tween(tabImage, TweenInfo.new(0.2), {ImageTransparency = 0.2}):Play()
                end

                currentTab.Text = Settings.Name
            end)

            return TabFunctions
        end

        return SectionFunctions
    end

    function WindowFunctions:Notification(Settings)
        local NotificationHolder = Instance.new("Frame")
        NotificationHolder.Name = "Notification"
        NotificationHolder.Size = UDim2.new(0, 0, 0, 0)
        NotificationHolder.BackgroundTransparency = 1
        NotificationHolder.BorderSizePixel = 0
        NotificationHolder.Parent = notifications

        local notificationMain = Instance.new("Frame")
        notificationMain.Name = "NotificationMain"
        notificationMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        notificationMain.BorderSizePixel = 0
        notificationMain.Size = UDim2.new(0, 309, 0, 68)

        local notificationMainCorner = Instance.new("UICorner")
        notificationMainCorner.CornerRadius = UDim.new(0, 6)
        notificationMainCorner.Parent = notificationMain

        local notificationMainStroke = Instance.new("UIStroke")
        notificationMainStroke.Color = Color3.fromRGB(255, 255, 255)
        notificationMainStroke.Transparency = 0.9
        notificationMainStroke.Parent = notificationMain

        local notificationTitle = Instance.new("TextLabel")
        notificationTitle.Name = "Title"
        notificationTitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        notificationTitle.Text = Settings.Title
        notificationTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        notificationTitle.TextSize = 18
        notificationTitle.TextTransparency = 0.2
        notificationTitle.TextXAlignment = Enum.TextXAlignment.Left
        notificationTitle.BackgroundTransparency = 1
        notificationTitle.BorderSizePixel = 0
        notificationTitle.Size = UDim2.new(0, 0, 0, 20)
        notificationTitle.Position = UDim2.new(0, 20, 0, 15)
        notificationTitle.Parent = notificationMain

        local notificationSubtitle = Instance.new("TextLabel")
        notificationSubtitle.Name = "Subtitle"
        notificationSubtitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        notificationSubtitle.Text = Settings.Content or ""
        notificationSubtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        notificationSubtitle.TextSize = 14
        notificationSubtitle.TextTransparency = 0.7
        notificationSubtitle.TextYAlignment = Enum.TextYAlignment.Top
        notificationSubtitle.TextXAlignment = Enum.TextXAlignment.Left
        notificationSubtitle.BackgroundTransparency = 1
        notificationSubtitle.BorderSizePixel = 0
        notificationSubtitle.AutomaticSize = Enum.AutomaticSize.XY
        notificationSubtitle.Position = UDim2.new(0, 20, 0, 40)
        notificationSubtitle.Size = UDim2.new(1, -40, 0, 0)
        notificationSubtitle.Parent = notificationMain

        notificationMain.Parent = NotificationHolder

        Tween(notificationHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 309, 0, 68)}):Play()

        if Settings.Duration then
            task.wait(Settings.Duration)
            Tween(notificationHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            task.wait(0.3)
            NotificationHolder:Destroy()
        end

        return NotificationHolder
    end

    return WindowFunctions
end

return StarLight
