local StarLight = {}
local HttpService = game:GetService("HttpService")

--// Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

--// Mobile Detection
local isStudio = RunService:IsStudio()
local LocalPlayer = Players.LocalPlayer
local DevicePlatform = nil
local IsMobile = false

if isStudio then
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        IsMobile = true
    end
else
    pcall(function()
        DevicePlatform = UserInputService:GetPlatform()
    end)
    IsMobile = (DevicePlatform == Enum.Platform.Android or DevicePlatform == Enum.Platform.IOS)
end

--// Configuration
local MOBILE_MIN_SIZE = UDim2.fromOffset(450, 350)
local DESKTOP_MIN_SIZE = UDim2.fromOffset(868, 650)
local TOUCH_TARGET_SIZE = 44
local MOBILE_SCALE = IsMobile and 1.2 or 1

--// UI Assets
local assets = {
    interFont = "rbxassetid://12187365364",
    userInfoBlurred = "rbxassetid://18824089198",
    toggleBackground = "rbxassetid://18772190202",
    togglerHead = "rbxassetid://18772309008",
    buttonImage = "rbxassetid://10709791437",
    searchIcon = "rbxassetid://86737463322606",
    moveIcon = "rbxassetid://10734900011",
    dropdownArrow = "rbxassetid://18865373378",
    quickMenuIcon = "rbxassetid://10734909332"
}

--// Variables
local windowState = nil
local acrylicBlur = not IsMobile
local hasGlobalSetting = false
local tabs = {}
local currentTabInstance = nil
local tabIndex = 0
local quickMenu = nil
local quickMenuToggled = false
local keybinds = {}
local currentKeybindConnection = nil

--// Utility Functions
local function Tween(instance, tweeninfo, propertytable)
    return TweenService:Create(instance, tweeninfo, propertytable)
end

local function ApplyMobileScaling(size)
    if not IsMobile then return size end
    if typeof(size) == "UDim2" then
        return UDim2.new(size.X.Scale, size.X.Offset * MOBILE_SCALE, size.Y.Scale, size.Y.Offset * MOBILE_SCALE)
    end
    return size
end

local function GetMinimumSize()
    return IsMobile and MOBILE_MIN_SIZE or DESKTOP_MIN_SIZE
end

--// Quick Menu System
local function CreateQuickMenu()
    if not IsMobile then return nil end
    
    local menu = Instance.new("ScreenGui")
    menu.Name = "QuickMenu"
    menu.ResetOnSpawn = false
    menu.DisplayOrder = 101
    menu.IgnoreGuiInset = true
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.AnchorPoint = Vector2.new(1, 1)
    container.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    container.BackgroundTransparency = 0.05
    container.BorderSizePixel = 0
    container.Position = UDim2.new(1, -20, 1, -20)
    container.Size = UDim2.fromOffset(60, 60)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.9
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = container
    
    local button = Instance.new("ImageButton")
    button.Name = "QuickMenuButton"
    button.Image = assets.quickMenuIcon
    button.ImageColor3 = Color3.fromRGB(255, 255, 255)
    button.ImageTransparency = 0.8
    button.BackgroundTransparency = 1
    button.Size = UDim2.fromScale(0.6, 0.6)
    button.Position = UDim2.fromScale(0.5, 0.5)
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.Parent = container
    
    -- Quick menu panel
    local panel = Instance.new("Frame")
    panel.Name = "QuickPanel"
    panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    panel.BackgroundTransparency = 0.05
    panel.BorderSizePixel = 0
    panel.Size = UDim2.fromOffset(0, 0)
    panel.Position = UDim2.new(1, -70, 1, -320)
    panel.Visible = true
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 12)
    panelCorner.Parent = panel
    
    local panelStroke = Instance.new("UIStroke")
    panelStroke.Color = Color3.fromRGB(255, 255, 255)
    panelStroke.Transparency = 0.9
    panelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    panelStroke.Parent = panel
    
    local scrolling = Instance.new("ScrollingFrame")
    scrolling.Name = "MenuList"
    scrolling.BackgroundTransparency = 1
    scrolling.Size = UDim2.fromScale(1, 1)
    scrolling.CanvasSize = UDim2.new()
    scrolling.ScrollBarThickness = 2
    scrolling.ScrollBarImageTransparency = 0.7
    scrolling.Parent = panel
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scrolling
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = scrolling
    
    container.Parent = menu
    panel.Parent = menu
    
    local function ToggleQuickMenu()
        quickMenuToggled = not quickMenuToggled
        
        local targetSize = quickMenuToggled and UDim2.fromOffset(280, 350) or UDim2.fromOffset(0, 0)
        local targetTransparency = quickMenuToggled and 0.05 or 1
        
        Tween(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = targetSize,
            BackgroundTransparency = targetTransparency
        }):Play()
        
        if quickMenuToggled then
            panel.Visible = true
        else
            task.wait(0.3)
            panel.Visible = false
        end
    end
    
    button.MouseButton1Click:Connect(ToggleQuickMenu)
    
    return {
        Gui = menu,
        Panel = panel,
        List = scrolling,
        Toggle = ToggleQuickMenu,
        AddItem = function(self, name, callback, keybind)
            local item = Instance.new("TextButton")
            item.Name = name
            item.Text = name .. (keybind and " [" .. keybind .. "]" or "")
            item.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
            item.TextColor3 = Color3.fromRGB(255, 255, 255)
            item.TextSize = 14
            item.TextTransparency = 0.4
            item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            item.BackgroundTransparency = 0.95
            item.BorderSizePixel = 0
            item.Size = UDim2.new(1, 0, 0, TOUCH_TARGET_SIZE)
            item.LayoutOrder = #scrolling:GetChildren()
            item.Parent = scrolling
            
            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 8)
            itemCorner.Parent = item
            
            item.MouseButton1Click:Connect(function()
                callback()
                ToggleQuickMenu()
            end)
            
            item.MouseEnter:Connect(function()
                Tween(item, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                    BackgroundTransparency = 0.9,
                    TextTransparency = 0.2
                }):Play()
            end)
            
            item.MouseLeave:Connect(function()
                Tween(item, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                    BackgroundTransparency = 0.95,
                    TextTransparency = 0.4
                }):Play()
            end)
        end
    }
end

--// Keybinding System
local function RegisterKeybind(key, callback, name)
    if not key or not callback then return end
    
    local bind = {
        Key = key,
        Callback = callback,
        Name = name or "Unnamed"
    }
    
    table.insert(keybinds, bind)
    
    if quickMenu and IsMobile then
        quickMenu:AddItem(bind.Name, callback, key)
    end
    
    return bind
end

local function SetupKeybindListener()
    if currentKeybindConnection then
        currentKeybindConnection:Disconnect()
    end
    
    currentKeybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        for _, bind in ipairs(keybinds) do
            if input.KeyCode.Name == bind.Key or input.UserInputType.Name == bind.Key then
                bind.Callback()
            end
        end
    end)
end

--// Main Window
function StarLight:Window(Settings)
    local WindowFunctions = {}
    
    if Settings.AcrylicBlur ~= nil then
        acrylicBlur = Settings.AcrylicBlur
    else
        acrylicBlur = not IsMobile
    end
    
    local starlightGui = Instance.new("ScreenGui")
    starlightGui.Name = "StarLightUI"
    starlightGui.ResetOnSpawn = false
    starlightGui.DisplayOrder = 100
    starlightGui.IgnoreGuiInset = true
    starlightGui.ScreenInsets = Enum.ScreenInsets.None
    starlightGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    starlightGui.Parent = (isStudio and LocalPlayer.PlayerGui) or game:GetService("CoreGui")
    
    local notifications = Instance.new("Frame")
    notifications.Name = "Notifications"
    notifications.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    notifications.BackgroundTransparency = 1
    notifications.BorderColor3 = Color3.fromRGB(0, 0, 0)
    notifications.BorderSizePixel = 0
    notifications.Size = UDim2.fromScale(1, 1)
    notifications.Parent = starlightGui
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
    base.BackgroundTransparency = acrylicBlur and 0.05 or 0
    base.BorderColor3 = Color3.fromRGB(0, 0, 0)
    base.BorderSizePixel = 0
    base.Position = Settings.Position or UDim2.fromScale(0.5, 0.5)
    base.Size = ApplyMobileScaling(Settings.Size or GetMinimumSize())
    base.ClipsDescendants = true
    
    local baseUIScale = Instance.new("UIScale")
    baseUIScale.Name = "BaseUIScale"
    baseUIScale.Parent = base
    
    local baseUICorner = Instance.new("UICorner")
    baseUICorner.Name = "BaseUICorner"
    baseUICorner.CornerRadius = UDim.new(0, IsMobile and 15 or 10)
    baseUICorner.Parent = base
    
    local baseUIStroke = Instance.new("UIStroke")
    baseUIStroke.Name = "BaseUIStroke"
    baseUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    baseUIStroke.Color = Color3.fromRGB(255, 255, 255)
    baseUIStroke.Transparency = 0.9
    baseUIStroke.Parent = base
    
    --// Acrylic Blur (desktop only)
    if acrylicBlur then
        local blurTop = Instance.new("ImageLabel")
        blurTop.Name = "BlurTop"
        blurTop.BackgroundTransparency = 1
        blurTop.BorderSizePixel = 0
        blurTop.Image = assets.userInfoBlurred
        blurTop.ImageTransparency = 0
        blurTop.ScaleType = Enum.ScaleType.Slice
        blurTop.SliceScale = 1
        blurTop.Size = UDim2.fromScale(1, 0)
        blurTop.SizeConstraint = Enum.SizeConstraint.RelativeYY
        blurTop.SliceCenter = Rect.new(128, 128, 128, 128)
        blurTop.ImageColor3 = Color3.fromRGB(15, 15, 15)
        blurTop.Parent = base
        
        local blurSide = Instance.new("ImageLabel")
        blurSide.Name = "BlurSide"
        blurSide.AnchorPoint = Vector2.new(0, 1)
        blurSide.BackgroundTransparency = 1
        blurSide.BorderSizePixel = 0
        blurSide.Image = assets.userInfoBlurred
        blurSide.ImageTransparency = 0
        blurSide.Position = UDim2.fromScale(0, 1)
        blurSide.ScaleType = Enum.ScaleType.Slice
        blurSide.SliceScale = 1
        blurSide.Size = UDim2.fromScale(1, 0)
        blurSide.SizeConstraint = Enum.SizeConstraint.RelativeYY
        blurSide.SliceCenter = Rect.new(128, 128, 128, 128)
        blurSide.ImageColor3 = Color3.fromRGB(15, 15, 15)
        blurSide.Parent = base
    end
    
    --// Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sidebar.BackgroundTransparency = 1
    sidebar.BorderColor3 = Color3.fromRGB(0, 0, 0)
    sidebar.BorderSizePixel = 0
    sidebar.Position = UDim2.fromScale(-3.52e-08, 4.69e-08)
    sidebar.Size = UDim2.fromScale(IsMobile and 0.4 or 0.325, 1)
    
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.AnchorPoint = Vector2.new(1, 0)
    divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider.BackgroundTransparency = 0.9
    divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
    divider.BorderSizePixel = 0
    divider.Position = UDim2.fromScale(1, 0)
    divider.Size = UDim2.new(0, 1, 1, 0)
    divider.Parent = sidebar
    
    --// Window Controls
    local windowControls = Instance.new("Frame")
    windowControls.Name = "WindowControls"
    windowControls.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    windowControls.BackgroundTransparency = 1
    windowControls.BorderColor3 = Color3.fromRGB(0, 0, 0)
    windowControls.BorderSizePixel = 0
    windowControls.Size = UDim2.new(1, 0, 0, IsMobile and 40 or 31)
    
    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.BackgroundColor3 = Color3.fromRGB(119, 174, 94)
    controls.BackgroundTransparency = 1
    controls.BorderColor3 = Color3.fromRGB(0, 0, 0)
    controls.BorderSizePixel = 0
    controls.Size = UDim2.fromScale(1, 1)
    
    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.Name = "UIListLayout"
    uIListLayout.Padding = UDim.new(0, IsMobile and 8 or 5)
    uIListLayout.FillDirection = Enum.FillDirection.Horizontal
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uIListLayout.Parent = controls
    
    local uIPadding = Instance.new("UIPadding")
    uIPadding.Name = "UIPadding"
    uIPadding.PaddingLeft = UDim.new(0, IsMobile and 15 or 11)
    uIPadding.Parent = controls
    
    local windowControlSettings = {
        sizes = { enabled = UDim2.fromOffset(IsMobile and 12 or 8, IsMobile and 12 or 8), disabled = UDim2.fromOffset(7, 7) },
        transparencies = { enabled = 0, disabled = 1 },
        strokeTransparency = 0.9,
    }
    
    local stroke = Instance.new("UIStroke")
    stroke.Name = "BaseUIStroke"
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = windowControlSettings.strokeTransparency
    
    local exit = Instance.new("TextButton")
    exit.Name = "Exit"
    exit.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
    exit.Text = ""
    exit.TextColor3 = Color3.fromRGB(0, 0, 0)
    exit.TextSize = 14
    exit.AutoButtonColor = false
    exit.BackgroundColor3 = Color3.fromRGB(250, 93, 86)
    exit.BorderColor3 = Color3.fromRGB(0, 0, 0)
    exit.BorderSizePixel = 0
    
    local uICorner = Instance.new("UICorner")
    uICorner.Name = "UICorner"
    uICorner.CornerRadius = UDim.new(1, 0)
    uICorner.Parent = exit
    
    exit.Parent = controls
    
    local minimize = Instance.new("TextButton")
    minimize.Name = "Minimize"
    minimize.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
    minimize.Text = ""
    minimize.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimize.TextSize = 14
    minimize.AutoButtonColor = false
    minimize.BackgroundColor3 = Color3.fromRGB(252, 190, 57)
    minimize.BorderColor3 = Color3.fromRGB(0, 0, 0)
    minimize.BorderSizePixel = 0
    minimize.LayoutOrder = 1
    
    local uICorner1 = Instance.new("UICorner")
    uICorner1.Name = "UICorner"
    uICorner1.CornerRadius = UDim.new(1, 0)
    uICorner1.Parent = minimize
    
    minimize.Parent = controls
    
    local maximize = Instance.new("TextButton")
    maximize.Name = "Maximize"
    maximize.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
    maximize.Text = ""
    maximize.TextColor3 = Color3.fromRGB(0, 0, 0)
    maximize.TextSize = 14
    maximize.AutoButtonColor = false
    maximize.BackgroundColor3 = Color3.fromRGB(119, 174, 94)
    maximize.BorderColor3 = Color3.fromRGB(0, 0, 0)
    maximize.BorderSizePixel = 0
    maximize.LayoutOrder = 1
    
    local uICorner2 = Instance.new("UICorner")
    uICorner2.Name = "UICorner"
    uICorner2.CornerRadius = UDim.new(1, 0)
    uICorner2.Parent = maximize
    
    maximize.Parent = controls
    
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
    divider1.BorderColor3 = Color3.fromRGB(0, 0, 0)
    divider1.BorderSizePixel = 0
    divider1.Position = UDim2.fromScale(0, 1)
    divider1.Size = UDim2.new(1, 0, 0, 1)
    divider1.Parent = windowControls
    
    windowControls.Parent = sidebar
    
    --// Information Section
    local information = Instance.new("Frame")
    information.Name = "Information"
    information.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    information.BackgroundTransparency = 1
    information.BorderColor3 = Color3.fromRGB(0, 0, 0)
    information.BorderSizePixel = 0
    information.Position = UDim2.fromOffset(0, IsMobile and 40 or 31)
    information.Size = UDim2.new(1, 0, 0, IsMobile and 70 or 60)
    
    local divider2 = Instance.new("Frame")
    divider2.Name = "Divider"
    divider2.AnchorPoint = Vector2.new(0, 1)
    divider2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider2.BackgroundTransparency = 0.9
    divider2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    divider2.BorderSizePixel = 0
    divider2.Position = UDim2.fromScale(0, 1)
    divider2.Size = UDim2.new(1, 0, 0, 1)
    divider2.Parent = information
    
    local informationHolder = Instance.new("Frame")
    informationHolder.Name = "InformationHolder"
    informationHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    informationHolder.BackgroundTransparency = 1
    informationHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
    informationHolder.BorderSizePixel = 0
    informationHolder.Size = UDim2.fromScale(1, 1)
    
    local informationHolderUIPadding = Instance.new("UIPadding")
    informationHolderUIPadding.Name = "InformationHolderUIPadding"
    informationHolderUIPadding.PaddingBottom = UDim.new(0, IsMobile and 15 or 10)
    informationHolderUIPadding.PaddingLeft = UDim.new(0, IsMobile and 25 or 23)
    informationHolderUIPadding.PaddingRight = UDim.new(0, IsMobile and 25 or 22)
    informationHolderUIPadding.PaddingTop = UDim.new(0, IsMobile and 15 or 10)
    informationHolderUIPadding.Parent = informationHolder
    
    local globalSettingsButton = Instance.new("ImageButton")
    globalSettingsButton.Name = "GlobalSettingsButton"
    globalSettingsButton.Image = "rbxassetid://18767849817"
    globalSettingsButton.ImageTransparency = 0.4
    globalSettingsButton.AnchorPoint = Vector2.new(1, 0.5)
    globalSettingsButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    globalSettingsButton.BackgroundTransparency = 1
    globalSettingsButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    globalSettingsButton.BorderSizePixel = 0
    globalSettingsButton.Position = UDim2.fromScale(1, 0.5)
    globalSettingsButton.Size = UDim2.fromOffset(IsMobile and 20 or 15, IsMobile and 20 or 15)
    globalSettingsButton.Parent = informationHolder
    
    local function ChangeGlobalSettingsButtonState(State)
        if State == "Default" then
            Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                ImageTransparency = 0.4
            }):Play()
        elseif State == "Hover" then
            Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                ImageTransparency = 0.2
            }):Play()
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
    titleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    titleFrame.BackgroundTransparency = 1
    titleFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    titleFrame.BorderSizePixel = 0
    titleFrame.Size = UDim2.fromScale(1, 1)
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.FontFace = Font.new(
        assets.interFont,
        Enum.FontWeight.SemiBold,
        Enum.FontStyle.Normal
    )
    title.Text = Settings.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.RichText = true
    title.TextSize = IsMobile and 23 or 20
    title.TextTransparency = 0.2
    title.TextTruncate = Enum.TextTruncate.SplitWord
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Top
    title.AutomaticSize = Enum.AutomaticSize.Y
    title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.BorderColor3 = Color3.fromRGB(0, 0, 0)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, -20, 0, 0)
    title.Parent = titleFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.FontFace = Font.new(
        assets.interFont,
        Enum.FontWeight.Medium,
        Enum.FontStyle.Normal
    )
    subtitle.RichText = true
    subtitle.Text = Settings.Subtitle
    subtitle.RichText = true
    subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    subtitle.TextSize = IsMobile and 14 or 12
    subtitle.TextTransparency = 0.7
    subtitle.TextTruncate = Enum.TextTruncate.SplitWord
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextYAlignment = Enum.TextYAlignment.Top
    subtitle.AutomaticSize = Enum.AutomaticSize.Y
    subtitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    subtitle.BackgroundTransparency = 1
    subtitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    subtitle.BorderSizePixel = 0
    subtitle.LayoutOrder = 1
    subtitle.Size = UDim2.new(1, -20, 0, 0)
    subtitle.Parent = titleFrame
    
    local titleFrameUIListLayout = Instance.new("UIListLayout")
    titleFrameUIListLayout.Name = "TitleFrameUIListLayout"
    titleFrameUIListLayout.Padding = UDim.new(0, IsMobile and 5 or 3)
    titleFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    titleFrameUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    titleFrameUIListLayout.Parent = titleFrame
    
    titleFrame.Parent = informationHolder
    
    informationHolder.Parent = information
    
    information.Parent = sidebar
    
    --// Sidebar Group
    local sidebarGroup = Instance.new("Frame")
    sidebarGroup.Name = "SidebarGroup"
    sidebarGroup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sidebarGroup.BackgroundTransparency = 1
    sidebarGroup.BorderColor3 = Color3.fromRGB(0, 0, 0)
    sidebarGroup.BorderSizePixel = 0
    sidebarGroup.Position = UDim2.fromOffset(0, IsMobile and 111 or 91)
    sidebarGroup.Size = UDim2.new(1, 0, 1, IsMobile and -111 or -91)
    
    local userInfo = Instance.new("Frame")
    userInfo.Name = "UserInfo"
    userInfo.AnchorPoint = Vector2.new(0, 1)
    userInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    userInfo.BackgroundTransparency = 1
    userInfo.BorderColor3 = Color3.fromRGB(0, 0, 0)
    userInfo.BorderSizePixel = 0
    userInfo.Position = UDim2.fromScale(0, 1)
    userInfo.Size = UDim2.new(1, 0, 0, IsMobile and 120 or 107)
    
    local informationGroup = Instance.new("Frame")
    informationGroup.Name = "InformationGroup"
    informationGroup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    informationGroup.BackgroundTransparency = 1
    informationGroup.BorderColor3 = Color3.fromRGB(0, 0, 0)
    informationGroup.BorderSizePixel = 0
    informationGroup.Size = UDim2.fromScale(1, 1)
    
    local informationGroupUIPadding = Instance.new("UIPadding")
    informationGroupUIPadding.Name = "InformationGroupUIPadding"
    informationGroupUIPadding.PaddingBottom = UDim.new(0, IsMobile and 20 or 17)
    informationGroupUIPadding.PaddingLeft = UDim.new(0, IsMobile and 28 or 25)
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
    headshot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    headshot.BackgroundTransparency = 1
    headshot.BorderColor3 = Color3.fromRGB(0, 0, 0)
    headshot.BorderSizePixel = 0
    headshot.Size = IsMobile and UDim2.fromOffset(40, 40) or UDim2.fromOffset(32, 32)
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
    userAndDisplayFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    userAndDisplayFrame.BackgroundTransparency = 1
    userAndDisplayFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    userAndDisplayFrame.BorderSizePixel = 0
    userAndDisplayFrame.LayoutOrder = 1
    userAndDisplayFrame.Size = UDim2.new(1, -42, 0, 32)
    
    local displayName = Instance.new("TextLabel")
    displayName.Name = "DisplayName"
    displayName.FontFace = Font.new(
        assets.interFont,
        Enum.FontWeight.SemiBold,
        Enum.FontStyle.Normal
    )
    displayName.Text = LocalPlayer.DisplayName
    displayName.TextColor3 = Color3.fromRGB(255, 255, 255)
    displayName.TextSize = IsMobile and 15 or 13
    displayName.TextTransparency = 0.2
    displayName.TextTruncate = Enum.TextTruncate.SplitWord
    displayName.TextXAlignment = Enum.TextXAlignment.Left
    displayName.TextYAlignment = Enum.TextYAlignment.Top
    displayName.AutomaticSize = Enum.AutomaticSize.XY
    displayName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    displayName.BackgroundTransparency = 1
    displayName.BorderColor3 = Color3.fromRGB(0, 0, 0)
    displayName.BorderSizePixel = 0
    displayName.Parent = userAndDisplayFrame
    displayName.Size = UDim2.fromScale(1,0)
    
    local userAndDisplayFrameUIPadding = Instance.new("UIPadding")
    userAndDisplayFrameUIPadding.Name = "UserAndDisplayFrameUIPadding"
    userAndDisplayFrameUIPadding.PaddingLeft = UDim.new(0, IsMobile and 10 or 8)
    userAndDisplayFrameUIPadding.PaddingTop = UDim.new(0, IsMobile and 3 or 3)
    userAndDisplayFrameUIPadding.Parent = userAndDisplayFrame
    
    local userAndDisplayFrameUIListLayout = Instance.new("UIListLayout")
    userAndDisplayFrameUIListLayout.Name = "UserAndDisplayFrameUIListLayout"
    userAndDisplayFrameUIListLayout.Padding = UDim.new(0, IsMobile and 2 or 1)
    userAndDisplayFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    userAndDisplayFrameUIListLayout.Parent = userAndDisplayFrame
    
    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.FontFace = Font.new(
        assets.interFont,
        Enum.FontWeight.SemiBold,
        Enum.FontStyle.Normal
    )
    username.Text = "@"..LocalPlayer.Name
    username.TextColor3 = Color3.fromRGB(255, 255, 255)
    username.TextSize = IsMobile and 13 or 12
    username.TextTransparency = 0.8
    username.TextTruncate = Enum.TextTruncate.SplitWord
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.TextYAlignment = Enum.TextYAlignment.Top
    username.AutomaticSize = Enum.AutomaticSize.XY
    username.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    username.BackgroundTransparency = 1
    username.BorderColor3 = Color3.fromRGB(0, 0, 0)
    username.BorderSizePixel = 0
    username.LayoutOrder = 1
    username.Parent = userAndDisplayFrame
    username.Size = UDim2.fromScale(1,0)
    
    userAndDisplayFrame.Parent = informationGroup
    
    informationGroup.Parent = userInfo
    
    local userInfoUIPadding = Instance.new("UIPadding")
    userInfoUIPadding.Name = "UserInfoUIPadding"
    userInfoUIPadding.PaddingLeft = UDim.new(0, IsMobile and 12 or 10)
    userInfoUIPadding.PaddingRight = UDim.new(0, IsMobile and 12 or 10)
    userInfoUIPadding.Parent = userInfo
    
    userInfo.Parent = sidebarGroup
    
    local sidebarGroupUIPadding = Instance.new("UIPadding")
    sidebarGroupUIPadding.Name = "SidebarGroupUIPadding"
    sidebarGroupUIPadding.PaddingLeft = UDim.new(0, IsMobile and 12 or 10)
    sidebarGroupUIPadding.PaddingRight = UDim.new(0, IsMobile and 12 or 10)
    sidebarGroupUIPadding.PaddingTop = UDim.new(0, IsMobile and 35 or 31)
    sidebarGroupUIPadding.Parent = sidebarGroup
    
    local tabSwitchers = Instance.new("Frame")
    tabSwitchers.Name = "TabSwitchers"
    tabSwitchers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabSwitchers.BackgroundTransparency = 1
    tabSwitchers.BorderColor3 = Color3.fromRGB(0, 0, 0)
    tabSwitchers.BorderSizePixel = 0
    tabSwitchers.Size = UDim2.new(1, 0, 1, IsMobile and -120 or -107)
    
    local tabSwitchersScrollingFrame = Instance.new("ScrollingFrame")
    tabSwitchersScrollingFrame.Name = "TabSwitchersScrollingFrame"
    tabSwitchersScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabSwitchersScrollingFrame.BottomImage = ""
    tabSwitchersScrollingFrame.CanvasSize = UDim2.new()
    tabSwitchersScrollingFrame.ScrollBarImageTransparency = 0.8
    tabSwitchersScrollingFrame.ScrollBarThickness = IsMobile and 3 or 1
    tabSwitchersScrollingFrame.TopImage = ""
    tabSwitchersScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabSwitchersScrollingFrame.BackgroundTransparency = 1
    tabSwitchersScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    tabSwitchersScrollingFrame.BorderSizePixel = 0
    tabSwitchersScrollingFrame.Size = UDim2.fromScale(1, 1)
    
    local tabSwitchersScrollingFrameUIListLayout = Instance.new("UIListLayout")
    tabSwitchersScrollingFrameUIListLayout.Name = "TabSwitchersScrollingFrameUIListLayout"
    tabSwitchersScrollingFrameUIListLayout.Padding = UDim.new(0, IsMobile and 20 or 17)
    tabSwitchersScrollingFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabSwitchersScrollingFrameUIListLayout.Parent = tabSwitchersScrollingFrame
    
    local tabSwitchersScrollingFrameUIPadding = Instance.new("UIPadding")
    tabSwitchersScrollingFrameUIPadding.Name = "TabSwitchersScrollingFrameUIPadding"
    tabSwitchersScrollingFrameUIPadding.PaddingTop = UDim.new(0, IsMobile and 3 or 2)
    tabSwitchersScrollingFrameUIPadding.Parent = tabSwitchersScrollingFrame
    
    tabSwitchersScrollingFrame.Parent = tabSwitchers
    
    tabSwitchers.Parent = sidebarGroup
    
    sidebarGroup.Parent = sidebar
    
    --// Content Area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.AnchorPoint = Vector2.new(1, 0)
    content.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    content.BackgroundTransparency = 1
    content.BorderColor3 = Color3.fromRGB(0, 0, 0)
    content.BorderSizePixel = 0
    content.Position = UDim2.fromScale(1, 4.69e-08)
    content.Size = UDim2.fromScale(IsMobile and 0.6 or 0.675, 1)
    
    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    topbar.BackgroundTransparency = 1
    topbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
    topbar.BorderSizePixel = 0
    topbar.Size = UDim2.new(1, 0, 0, IsMobile and 70 or 63)
    
    local divider4 = Instance.new("Frame")
    divider4.Name = "Divider"
    divider4.AnchorPoint = Vector2.new(0, 1)
    divider4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider4.BackgroundTransparency = 0.9
    divider4.BorderColor3 = Color3.fromRGB(0, 0, 0)
    divider4.BorderSizePixel = 0
    divider4.Position = UDim2.fromScale(0, 1)
    divider4.Size = UDim2.new(1, 0, 0, 1)
    divider4.Parent = topbar
    
    local elements = Instance.new("Frame")
    elements.Name = "Elements"
    elements.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    elements.BackgroundTransparency = 1
    elements.BorderColor3 = Color3.fromRGB(0, 0, 0)
    elements.BorderSizePixel = 0
    elements.Size = UDim2.fromScale(1, 1)
    
    local uIPadding2 = Instance.new("UIPadding")
    uIPadding2.Name = "UIPadding"
    uIPadding2.PaddingLeft = UDim.new(0, IsMobile and 25 or 20)
    uIPadding2.PaddingRight = UDim.new(0, IsMobile and 25 or 20)
    uIPadding2.Parent = elements
    
    local moveIcon = Instance.new("ImageButton")
    moveIcon.Name = "MoveIcon"
    moveIcon.Image = assets.moveIcon
    moveIcon.ImageTransparency = 0.5
    moveIcon.AnchorPoint = Vector2.new(1, 0.5)
    moveIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    moveIcon.BackgroundTransparency = 1
    moveIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    moveIcon.BorderSizePixel = 0
    moveIcon.Position = UDim2.fromScale(1, 0.5)
    moveIcon.Size = IsMobile and UDim2.fromOffset(20, 20) or UDim2.fromOffset(15, 15)
    moveIcon.Parent = elements
    moveIcon.Visible = not Settings.DragStyle or Settings.DragStyle == 1
    
    local interact = Instance.new("TextButton")
    interact.Name = "Interact"
    interact.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
    interact.Text = ""
    interact.TextColor3 = Color3.fromRGB(0, 0, 0)
    interact.TextSize = 14
    interact.AnchorPoint = Vector2.new(0.5, 0.5)
    interact.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    interact.BackgroundTransparency = 1
    interact.BorderColor3 = Color3.fromRGB(0, 0, 0)
    interact.BorderSizePixel = 0
    interact.Position = UDim2.fromScale(0.5, 0.5)
    interact.Size = IsMobile and UDim2.fromOffset(40, 40) or UDim2.fromOffset(30, 30)
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
    currentTab.FontFace = Font.new(
        assets.interFont,
        Enum.FontWeight.SemiBold,
        Enum.FontStyle.Normal
    )
    currentTab.RichText = true
    currentTab.Text = "Tab"
    currentTab.RichText = true
    currentTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    currentTab.TextSize = IsMobile and 17 or 15
    currentTab.TextTransparency = 0.5
    currentTab.TextTruncate = Enum.TextTruncate.SplitWord
    currentTab.TextXAlignment = Enum.TextXAlignment.Left
    currentTab.TextYAlignment = Enum.TextYAlignment.Top
    currentTab.AnchorPoint = Vector2.new(0, 0.5)
    currentTab.AutomaticSize = Enum.AutomaticSize.Y
    currentTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    currentTab.BackgroundTransparency = 1
    currentTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    currentTab.BorderSizePixel = 0
    currentTab.Position = UDim2.fromScale(0, 0.5)
    currentTab.Size = UDim2.fromScale(0.9, 0)
    currentTab.Parent = elements
    
    elements.Parent = topbar
    
    topbar.Parent = content
    
    content.Parent = base
    
    --// Global Settings
    local globalSettings = Instance.new("Frame")
    globalSettings.Name = "GlobalSettings"
    globalSettings.AutomaticSize = Enum.AutomaticSize.XY
    globalSettings.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    globalSettings.BorderColor3 = Color3.fromRGB(0, 0, 0)
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
    globalSettingsUICorner.CornerRadius = UDim.new(0, IsMobile and 12 or 10)
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
    base.Parent = starlightGui
    
    --// Window Functions
    function WindowFunctions:UpdateTitle(NewTitle)
        title.Text = NewTitle
    end
    
    function WindowFunctions:UpdateSubtitle(NewSubtitle)
        subtitle.Text = NewSubtitle
    end
    
    --// Notification System
    function WindowFunctions:CreateNotification(NotificationSettings)
        local notification = Instance.new("Frame")
        notification.Name = "Notification"
        notification.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        notification.BackgroundTransparency = 0.05
        notification.BorderSizePixel = 0
        notification.Size = UDim2.fromOffset(300, 80)
        notification.Position = UDim2.fromScale(1, -0.1)
        notification.AnchorPoint = Vector2.new(1, 0)
        notification.Parent = notifications
        
        local notifCorner = Instance.new("UICorner")
        notifCorner.CornerRadius = UDim.new(0, IsMobile and 12 or 8)
        notifCorner.Parent = notification
        
        local notifStroke = Instance.new("UIStroke")
        notifStroke.Color = Color3.fromRGB(255, 255, 255)
        notifStroke.Transparency = 0.9
        notifStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        notifStroke.Parent = notification
        
        local notifTitle = Instance.new("TextLabel")
        notifTitle.Name = "Title"
        notifTitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        notifTitle.Text = NotificationSettings.Title
        notifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        notifTitle.TextSize = IsMobile and 16 or 14
        notifTitle.TextTransparency = 0.2
        notifTitle.BackgroundTransparency = 1
        notifTitle.Position = UDim2.fromOffset(15, 10)
        notifTitle.Size = UDim2.new(1, -30, 0, 20)
        notifTitle.Parent = notification
        
        local notifText = Instance.new("TextLabel")
        notifText.Name = "Text"
        notifText.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        notifText.Text = NotificationSettings.Text
        notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
        notifText.TextSize = IsMobile and 14 or 12
        notifText.TextTransparency = 0.5
        notifText.TextWrapped = true
        notifText.BackgroundTransparency = 1
        notifText.Position = UDim2.fromOffset(15, 35)
        notifText.Size = UDim2.new(1, -30, 1, -45)
        notifText.Parent = notification
        
        Tween(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -20, 0, 20)
        }):Play()
        
        task.delay(NotificationSettings.Duration or 3, function()
            Tween(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 20, 0, 20)
            }):Play()
            
            task.wait(0.3)
            notification:Destroy()
        end)
    end
    
    --// Global Settings Toggle
    local hovering
    local toggled = globalSettingsUIScale.Scale == 1 and true or false
    local function toggle()
        if not toggled then
            local intween = Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                Scale = 1
            })
            intween:Play()
            intween:Wait()
            toggled = true
        elseif toggled then
            local outtween = Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                Scale = 0
            })
            outtween:Play()
            outtween:Wait()
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
    
    --// Blur Effect System
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
    
    local DrawQuad; do
        local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
        local sz = 0.2
        
        local function DrawTriangle(v1, v2, v3, p0, p1)
            local s1 = (v1 - v2).magnitude
            local s2 = (v2 - v3).magnitude
            local s3 = (v3 - v1).magnitude
            local smax = max(s1, s2, s3)
            local A, B, C
            if s1 == smax then
                A, B, C = v1, v2, v3
            elseif s2 == smax then
                A, B, C = v2, v3, v1
            elseif s3 == smax then
                A, B, C = v3, v1, v2
            end
            
            local para = ( (B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z ) / (A-B).magnitude
            local perp = sqrt((C-A).magnitude^2 - para*para)
            local dif_para = (A - B).magnitude - para
            
            local st = CFrame.new(B, A)
            local za = CFrame.Angles(pi/2,0,0)
            
            local cf0 = st
            
            local Top_Look = (cf0 * za).lookVector
            local Mid_Point = A + CFrame.new(A, B).lookVector * para
            local Needed_Look = CFrame.new(Mid_Point, C).lookVector
            local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.z*Needed_Look.z
            
            local ac = CFrame.Angles(0, 0, acos(dot))
            
            cf0 = cf0 * ac
            if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
                cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
            end
            cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))
            
            local cf1 = st * ac * CFrame.Angles(0, pi, 0)
            if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
                cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
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
                p0.Size = Vector3.new(sz, sz, sz)
                p0.Name = HS:GenerateGUID(true)
                local mesh = Instance.new('SpecialMesh', p0)
                mesh.MeshType = 2
                mesh.Name = wedgeguid
            end
            p0[wedgeguid].Scale = Vector3.new(0, perp/sz, para/sz)
            p0.CFrame = cf0
            
            if not p1 then
                p1 = p0:clone()
            end
            p1[wedgeguid].Scale = Vector3.new(0, perp/sz, dif_para/sz)
            p1.CFrame = cf1
            
            return p0, p1
        end
        
        function DrawQuad(v1, v2, v3, v4, parts)
            parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
            parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
        end
    end
    
    if binds[frame] then
        return binds[frame].parts
    end
    
    local parts = {}
    
    local parents = {}
    do
        local function add(child)
            if child:IsA'GuiObject' then
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
    
    --// Global Setting Function
    function WindowFunctions:GlobalSetting(Settings)
        hasGlobalSetting = true
        local GlobalSettingFunctions = {}
        local globalSetting = Instance.new("TextButton")
        globalSetting.Name = "GlobalSetting"
        globalSetting.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
        globalSetting.Text = ""
        globalSetting.TextColor3 = Color3.fromRGB(0, 0, 0)
        globalSetting.TextSize = 14
        globalSetting.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        globalSetting.BackgroundTransparency = 1
        globalSetting.BorderColor3 = Color3.fromRGB(0, 0, 0)
        globalSetting.BorderSizePixel = 0
        globalSetting.Size = UDim2.fromOffset(200, IsMobile and 35 or 30)
        
        local globalSettingToggleUIPadding = Instance.new("UIPadding")
        globalSettingToggleUIPadding.Name = "GlobalSettingToggleUIPadding"
        globalSettingToggleUIPadding.PaddingLeft = UDim.new(0, IsMobile and 18 or 15)
        globalSettingToggleUIPadding.Parent = globalSetting
        
        local settingName = Instance.new("TextLabel")
        settingName.Name = "SettingName"
        settingName.FontFace = Font.new(
            assets.interFont,
            Enum.FontWeight.Medium,
            Enum.FontStyle.Normal
        )
        settingName.Text = Settings.Name
        settingName.RichText = true
        settingName.TextColor3 = Color3.fromRGB(255, 255, 255)
        settingName.TextSize = IsMobile and 15 or 13
        settingName.TextTransparency = 0.5
        settingName.TextTruncate = Enum.TextTruncate.SplitWord
        settingName.TextXAlignment = Enum.TextXAlignment.Left
        settingName.TextYAlignment = Enum.TextYAlignment.Top
        settingName.AnchorPoint = Vector2.new(0, 0.5)
        settingName.AutomaticSize = Enum.AutomaticSize.Y
        settingName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        settingName.BackgroundTransparency = 1
        settingName.BorderColor3 = Color3.fromRGB(0, 0, 0)
        settingName.BorderSizePixel = 0
        settingName.Position = UDim2.fromScale(1.3e-07, 0.5)
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
        checkmark.FontFace = Font.new(
            assets.interFont,
            Enum.FontWeight.Medium,
            Enum.FontStyle.Normal
        )
        checkmark.Text = "✓"
        checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
        checkmark.TextSize = IsMobile and 15 or 13
        checkmark.TextTransparency = 1
        checkmark.TextXAlignment = Enum.TextXAlignment.Left
        checkmark.TextYAlignment = Enum.TextYAlignment.Top
        checkmark.AnchorPoint = Vector2.new(0, 0.5)
        checkmark.AutomaticSize = Enum.AutomaticSize.Y
        checkmark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        checkmark.BackgroundTransparency = 1
        checkmark.BorderColor3 = Color3.fromRGB(0, 0, 0)
        checkmark.BorderSizePixel = 0
        checkmark.LayoutOrder = -1
        checkmark.Position = UDim2.fromScale(1.3e-07, 0.5)
        checkmark.Size = UDim2.fromOffset(-10, 0)
        checkmark.Parent = globalSetting
        
        globalSetting.Parent = globalSettings
        
        local tweensettings = {
            duration = 0.2,
            easingStyle = Enum.EasingStyle.Quint,
            transparencyIn = 0.2,
            transparencyOut = 0.5,
            checkSizeIncrease = IsMobile and 14 or 12,
            checkSizeDecrease = -IsMobile and 16 or -13,
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
            task.spawn(function()
                if Settings.Callback then
                    Settings.Callback(toggled)
                end
            end)
        end
        
        return GlobalSettingFunctions
    end
    
    --// Tab Functions
    function WindowFunctions:Tab(Settings)
        local TabFunctions = {}
        tabIndex += 1
        
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "TabButton"
        tabButton.AutoButtonColor = false
        tabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.BackgroundTransparency = 1
        tabButton.BorderSizePixel = 0
        tabButton.Size = UDim2.new(1, -21, 0, IsMobile and 50 or 40)
        tabButton.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        tabButton.Text = Settings.Name
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.TextSize = IsMobile and 18 or 16
        tabButton.TextTransparency = 0.4
        tabButton.LayoutOrder = tabIndex
        tabButton.Parent = tabSwitchersScrollingFrame
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, IsMobile and 10 or 8)
        tabCorner.Parent = tabButton
        
        local tabStroke = Instance.new("UIStroke")
        tabStroke.Color = Color3.fromRGB(255, 255, 255)
        tabStroke.Transparency = 1
        tabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        tabStroke.Parent = tabButton
        
        local tabContent = Instance.new("Frame")
        tabContent.Name = "TabContent_" .. Settings.Name
        tabContent.BackgroundTransparency = 1
        tabContent.Size = UDim2.fromScale(1, 1)
        tabContent.Visible = false
        tabContent.Parent = content
        
        local contentScrolling = Instance.new("ScrollingFrame")
        contentScrolling.Name = "ContentScrolling"
        contentScrolling.BackgroundTransparency = 1
        contentScrolling.Size = UDim2.fromScale(1, 1)
        contentScrolling.CanvasSize = UDim2.new()
        contentScrolling.ScrollBarThickness = IsMobile and 4 or 2
        contentScrolling.ScrollBarImageTransparency = 0.5
        contentScrolling.Parent = tabContent
        
        local leftColumn = Instance.new("Frame")
        leftColumn.Name = "LeftColumn"
        leftColumn.BackgroundTransparency = 1
        leftColumn.Size = UDim2.new(0.5, -5, 1, 0)
        leftColumn.Parent = contentScrolling
        
        local rightColumn = Instance.new("Frame")
        rightColumn.Name = "RightColumn"
        rightColumn.BackgroundTransparency = 1
        rightColumn.Size = UDim2.new(0.5, -5, 1, 0)
        rightColumn.Position = UDim2.fromScale(0.5, 0)
        rightColumn.Parent = contentScrolling
        
        local leftLayout = Instance.new("UIListLayout")
        leftLayout.Padding = UDim.new(0, IsMobile and 15 or 10)
        leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        leftLayout.Parent = leftColumn
        
        local rightLayout = leftLayout:Clone()
        rightLayout.Parent = rightColumn
        
        --// Tab Activation
        function TabFunctions:Activate()
            if currentTabInstance then
                currentTabInstance.Visible = false
                for _, btn in ipairs(tabSwitchersScrollingFrame:GetChildren()) do
                    if btn:IsA("TextButton") then
                        Tween(btn, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                            TextTransparency = 0.4,
                            BackgroundTransparency = 1
                        }):Play()
                        Tween(btn:FindFirstChild("UIStroke"), TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                            Transparency = 1
                        }):Play()
                    end
                end
            end
            
            currentTabInstance = tabContent
            tabContent.Visible = true
            
            Tween(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                TextTransparency = 0,
                BackgroundTransparency = 0.8
            }):Play()
            Tween(tabStroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                Transparency = 0.9
            }):Play()
            
            currentTab.Text = Settings.Name
        end
        
        tabButton.MouseButton1Click:Connect(function()
            TabFunctions:Activate()
        end)
        
        if tabIndex == 1 then
            TabFunctions:Activate()
        end
        
        --// Quick Menu Integration
        if quickMenu and IsMobile then
            quickMenu:AddItem(Settings.Name, function()
                TabFunctions:Activate()
            end)
        end
        
        --// Section Functions
        function TabFunctions:Section(Settings)
            local SectionFunctions = {}
            local section = Instance.new("Frame")
            section.Name = "Section"
            section.AutomaticSize = Enum.AutomaticSize.Y
            section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            section.BackgroundTransparency = 0.98
            section.BorderColor3 = Color3.fromRGB(0, 0, 0)
            section.BorderSizePixel = 0
            section.Position = UDim2.fromScale(0, 6.78e-08)
            section.Size = UDim2.fromScale(1, 0)
            section.Parent = Settings.Side == "Left" and leftColumn or rightColumn
            
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
            sectionUIListLayout.Padding = UDim.new(0, IsMobile and 12 or 10)
            sectionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionUIListLayout.Parent = section
            
            local sectionUIPadding = Instance.new("UIPadding")
            sectionUIPadding.Name = "SectionUIPadding"
            sectionUIPadding.PaddingBottom = UDim.new(0, IsMobile and 22 or 20)
            sectionUIPadding.PaddingLeft = UDim.new(0, IsMobile and 22 or 20)
            sectionUIPadding.PaddingRight = UDim.new(0, IsMobile and 20 or 18)
            sectionUIPadding.PaddingTop = UDim.new(0, IsMobile and 22 or 22)
            sectionUIPadding.Parent = section
            
            function SectionFunctions:Button(ButtonSettings)
                local ButtonFunctions = {}
                local button = Instance.new("Frame")
                button.Name = "Button"
                button.AutomaticSize = Enum.AutomaticSize.Y
                button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                button.BackgroundTransparency = 1
                button.BorderColor3 = Color3.fromRGB(0, 0, 0)
                button.BorderSizePixel = 0
                button.Size = UDim2.new(1, 0, 0, IsMobile and 45 or 38)
                button.Parent = section
                
                local buttonInteract = Instance.new("TextButton")
                buttonInteract.Name = "ButtonInteract"
                buttonInteract.FontFace = Font.new(
                    assets.interFont,
                    Enum.FontWeight.Medium,
                    Enum.FontStyle.Normal
                )
                buttonInteract.RichText = true
                buttonInteract.TextColor3 = Color3.fromRGB(255, 255, 255)
                buttonInteract.TextSize = IsMobile and 15 or 13
                buttonInteract.TextTransparency = 0.5
                buttonInteract.TextTruncate = Enum.TextTruncate.AtEnd
                buttonInteract.TextXAlignment = Enum.TextXAlignment.Left
                buttonInteract.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                buttonInteract.BackgroundTransparency = 1
                buttonInteract.BorderColor3 = Color3.fromRGB(0, 0, 0)
                buttonInteract.BorderSizePixel = 0
                buttonInteract.Size = UDim2.fromScale(1, 1)
                buttonInteract.Parent = button
                buttonInteract.Text = ButtonSettings.Name
                
                local buttonImage = Instance.new("ImageLabel")
                buttonImage.Name = "ButtonImage"
                buttonImage.Image = assets.buttonImage
                buttonImage.ImageTransparency = 0.5
                buttonImage.AnchorPoint = Vector2.new(1, 0.5)
                buttonImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                buttonImage.BackgroundTransparency = 1
                buttonImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
                buttonImage.BorderSizePixel = 0
                buttonImage.Position = UDim2.fromScale(1, 0.5)
                buttonImage.Size = IsMobile and UDim2.fromOffset(18, 18) or UDim2.fromOffset(15, 15)
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
                    if ButtonSettings.Callback then
                        ButtonSettings.Callback()
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
            
            function SectionFunctions:Toggle(ToggleSettings)
                local ToggleFunctions = {}
                local toggle = Instance.new("Frame")
                toggle.Name = "Toggle"
                toggle.AutomaticSize = Enum.AutomaticSize.Y
                toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                toggle.BackgroundTransparency = 1
                toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                toggle.BorderSizePixel = 0
                toggle.Size = UDim2.new(1, 0, 0, IsMobile and 45 or 38)
                toggle.Parent = section
                
                local toggleName = Instance.new("TextLabel")
                toggleName.Name = "ToggleName"
                toggleName.FontFace = Font.new(
                    assets.interFont,
                    Enum.FontWeight.Medium,
                    Enum.FontStyle.Normal
                )
                toggleName.Text = ToggleSettings.Name
                toggleName.RichText = true
                toggleName.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleName.TextSize = IsMobile and 15 or 13
                toggleName.TextTransparency = 0.5
                toggleName.TextTruncate = Enum.TextTruncate.AtEnd
                toggleName.TextXAlignment = Enum.TextXAlignment.Left
                toggleName.TextYAlignment = Enum.TextYAlignment.Top
                toggleName.AnchorPoint = Vector2.new(0, 0.5)
                toggleName.AutomaticSize = Enum.AutomaticSize.XY
                toggleName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleName.BackgroundTransparency = 1
                toggleName.BorderColor3 = Color3.fromRGB(0, 0, 0)
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
                toggle1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggle1.BackgroundTransparency = 1
                toggle1.BorderColor3 = Color3.fromRGB(0, 0, 0)
                toggle1.BorderSizePixel = 0
                toggle1.Position = UDim2.fromScale(1, 0.5)
                toggle1.Size = IsMobile and UDim2.fromOffset(50, 25) or UDim2.fromOffset(41, 21)
                
                local toggleUIPadding = Instance.new("UIPadding")
                toggleUIPadding.Name = "ToggleUIPadding"
                toggleUIPadding.PaddingBottom = UDim.new(0, IsMobile and 2 or 1)
                toggleUIPadding.PaddingLeft = UDim.new(0, -IsMobile and 3 or -2)
                toggleUIPadding.PaddingRight = UDim.new(0, IsMobile and 4 or 3)
                toggleUIPadding.PaddingTop = UDim.new(0, IsMobile and 2 or 1)
                toggleUIPadding.Parent = toggle1
                
                local togglerHead = Instance.new("ImageLabel")
                togglerHead.Name = "TogglerHead"
                togglerHead.Image = assets.togglerHead
                togglerHead.ImageColor3 = Color3.fromRGB(91, 91, 91)
                togglerHead.AnchorPoint = Vector2.new(1, 0.5)
                togglerHead.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                togglerHead.BackgroundTransparency = 1
                togglerHead.BorderColor3 = Color3.fromRGB(0, 0, 0)
                togglerHead.BorderSizePixel = 0
                togglerHead.Position = UDim2.fromScale(0.5, 0.5)
                togglerHead.Size = IsMobile and UDim2.fromOffset(18, 18) or UDim2.fromOffset(15, 15)
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
                        Tween(toggle1, TweenSettings.Info, {
                            ImageColor3 = TweenSettings.EnabledColors.Toggle
                        }):Play()
                        
                        Tween(togglerHead, TweenSettings.Info, {
                            ImageColor3 = TweenSettings.EnabledColors.ToggleHead
                        }):Play()
                        
                        Tween(togglerHead, TweenSettings.Info, {
                            Position = TweenSettings.EnabledPosition
                        }):Play()
                    else
                        Tween(toggle1, TweenSettings.Info, {
                            ImageColor3 = TweenSettings.DisabledColors.Toggle
                        }):Play()
                        
                        Tween(togglerHead, TweenSettings.Info, {
                            ImageColor3 = TweenSettings.DisabledColors.ToggleHead
                        }):Play()
                        
                        Tween(togglerHead, TweenSettings.Info, {
                            Position = TweenSettings.DisabledPosition
                        }):Play()
                    end
                    
                    ToggleFunctions.State = State
                end
                
                local togglebool = ToggleSettings.Default
                ToggleState(togglebool)
                
                local function Toggle()
                    togglebool = not togglebool
                    ToggleState(togglebool)
                    if ToggleSettings.Callback then
                        ToggleSettings.Callback(togglebool)
                    end
                end
                
                toggle1.MouseButton1Click:Connect(Toggle)
                
                function ToggleFunctions:Toggle()
                    Toggle()
                end
                
                function ToggleFunctions:UpdateState(State)
                    togglebool = State
                    ToggleState(togglebool)
                    if ToggleSettings.Callback then
                        ToggleSettings.Callback(togglebool)
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
            
            function SectionFunctions:Slider(SliderSettings)
                local SliderFunctions = {}
                local slider = Instance.new("Frame")
                slider.Name = "Slider"
                slider.AutomaticSize = Enum.AutomaticSize.Y
                slider.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                slider.BackgroundTransparency = 1
                slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
                slider.BorderSizePixel = 0
                slider.Size = UDim2.new(1, 0, 0, IsMobile and 45 or 38)
                slider.Parent = section
                
                local sliderName = Instance.new("TextLabel")
                sliderName.Name = "SliderName"
                sliderName.FontFace = Font.new(
                    assets.interFont,
                    Enum.FontWeight.Medium,
                    Enum.FontStyle.Normal
                )
                sliderName.Text = SliderSettings.Name
                sliderName.RichText = true
                sliderName.TextColor3 = Color3.fromRGB(255, 255, 255)
                sliderName.TextSize = IsMobile and 15 or 13
                sliderName.TextTransparency = 0.5
                sliderName.TextTruncate = Enum.TextTruncate.AtEnd
                sliderName.TextXAlignment = Enum.TextXAlignment.Left
                sliderName.TextYAlignment = Enum.TextYAlignment.Top
                sliderName.AnchorPoint = Vector2.new(0, 0.5)
                sliderName.AutomaticSize = Enum.AutomaticSize.XY
                sliderName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderName.BackgroundTransparency = 1
                sliderName.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderName.BorderSizePixel = 0
                sliderName.Position = UDim2.fromScale(1.3e-07, 0.5)
                sliderName.Parent = slider
                
                local sliderElements = Instance.new("Frame")
                sliderElements.Name = "SliderElements"
                sliderElements.AnchorPoint = Vector2.new(1, 0)
                sliderElements.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderElements.BackgroundTransparency = 1
                sliderElements.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderElements.BorderSizePixel = 0
                sliderElements.Position = UDim2.fromScale(1, 0)
                sliderElements.Size = UDim2.fromScale(1, 1)
                
                local sliderValue = Instance.new("TextBox")
                sliderValue.Name = "SliderValue"
                sliderValue.FontFace = Font.new(
                    assets.interFont,
                    Enum.FontWeight.Medium,
                    Enum.FontStyle.Normal
                )
                sliderValue.Text = "100%"
                sliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
                sliderValue.TextSize = IsMobile and 14 or 12
                sliderValue.TextTransparency = 0.4
                sliderValue.TextTruncate = Enum.TextTruncate.AtEnd
                sliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderValue.BackgroundTransparency = 0.95
                sliderValue.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderValue.BorderSizePixel = 0
                sliderValue.LayoutOrder = 1
                sliderValue.Position = UDim2.fromScale(-0.0789, 0.171)
                sliderValue.Size = UDim2.fromOffset(IsMobile and 50 or 41, IsMobile and 25 or 21)
                
                local sliderValueUICorner = Instance.new("UICorner")
                sliderValueUICorner.Name = "SliderValueUICorner"
                sliderValueUICorner.CornerRadius = UDim.new(0, IsMobile and 5 or 4)
                sliderValueUICorner.Parent = sliderValue
                
                local sliderValueUIStroke = Instance.new("UIStroke")
                sliderValueUIStroke.Name = "SliderValueUIStroke"
                sliderValueUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                sliderValueUIStroke.Color = Color3.fromRGB(255, 255, 255)
                sliderValueUIStroke.Transparency = 0.9
                sliderValueUIStroke.Parent = sliderValue
                
                local sliderValueUIPadding = Instance.new("UIPadding")
                sliderValueUIPadding.Name = "SliderValueUIPadding"
                sliderValueUIPadding.PaddingLeft = UDim.new(0, IsMobile and 3 or 2)
                sliderValueUIPadding.PaddingRight = UDim.new(0, IsMobile and 3 or 2)
                sliderValueUIPadding.Parent = sliderValue
                
                sliderValue.Parent = sliderElements
                
                local sliderElementsUIListLayout = Instance.new("UIListLayout")
                sliderElementsUIListLayout.Name = "SliderElementsUIListLayout"
                sliderElementsUIListLayout.Padding = UDim.new(0, IsMobile and 25 or 20)
                sliderElementsUIListLayout.FillDirection = Enum.FillDirection.Horizontal
                sliderElementsUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                sliderElementsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                sliderElementsUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                sliderElementsUIListLayout.Parent = sliderElements
                
                local sliderBar = Instance.new("ImageLabel")
                sliderBar.Name = "SliderBar"
                sliderBar.Image = "rbxassetid://18772615246"
                sliderBar.ImageColor3 = Color3.fromRGB(87, 86, 86)
                sliderBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderBar.BackgroundTransparency = 1
                sliderBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderBar.BorderSizePixel = 0
                sliderBar.Position = UDim2.fromScale(0.219, 0.457)
                sliderBar.Size = IsMobile and UDim2.fromOffset(150, 4) or UDim2.fromOffset(123, 3)
                
                local sliderHead = Instance.new("ImageButton")
                sliderHead.Name = "SliderHead"
                sliderHead.Image = "rbxassetid://18772834246"
                sliderHead.AnchorPoint = Vector2.new(0.5, 0.5)
                sliderHead.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderHead.BackgroundTransparency = 1
                sliderHead.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderHead.BorderSizePixel = 0
                sliderHead.Position = UDim2.fromScale(1, 0.5)
                sliderHead.Size = IsMobile and UDim2.fromOffset(15, 15) or UDim2.fromOffset(12, 12)
                sliderHead.Parent = sliderBar
                
                sliderBar.Parent = sliderElements
                
                local sliderElementsUIPadding = Instance.new("UIPadding")
                sliderElementsUIPadding.Name = "SliderElementsUIPadding"
                sliderElementsUIPadding.PaddingTop = UDim.new(0, IsMobile and 4 or 3)
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
                        local percentage = (sliderValue - SliderSettings.Minimum) / (SliderSettings.Maximum - SliderSettings.Minimum) * 100
                        return tostring(math.round(percentage)) .. "%"
                    end,
                    Value = function(sliderValue)
                        return tostring(sliderValue)
                    end
                }
                
                local ValueDisplayMethod = DisplayMethods[SliderSettings.DisplayMethod]
                local finalValue
                
                local function SetValue(val, ignorecallback)
                    local posXScale
                    
                    if typeof(val) == "Instance" then
                        local input = val
                        posXScale = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                    else
                        local value = val
                        posXScale = (value - SliderSettings.Minimum) / (SliderSettings.Maximum - SliderSettings.Minimum)
                    end
                    
                    local pos = UDim2.new(posXScale, 0, 0.5, 0)
                    sliderHead.Position = pos
                    
                    finalValue = posXScale * (SliderSettings.Maximum - SliderSettings.Minimum) + SliderSettings.Minimum
                    sliderValue.Text = ValueDisplayMethod(finalValue)
                    
                    if not ignorecallback then
                        task.spawn(function()
                            if SliderSettings.Callback then
                                SliderSettings.Callback(finalValue)
                            end
                        end)
                    end
                    
                    SliderFunctions.Value = finalValue
                end
                
                SetValue(SliderSettings.Default, true)
                
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
                    local value, isPercent = inputText:match("^%-?%d+%.?%d*(%%?)$")
                    
                    if value then
                        value = tonumber(value)
                        isPercent = isPercent == "%"
                        
                        if isPercent then
                            value = SliderSettings.Minimum + (value / 100) * (SliderSettings.Maximum - SliderSettings.Minimum)
                        end
                        
                        local newValue = math.clamp(value, SliderSettings.Minimum, SliderSettings.Maximum)
                        SetValue(newValue)
                    else
                        sliderValue.Text = ValueDisplayMethod(sliderValue)
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
                    sliderName = Name
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
            
            function SectionFunctions:Input(InputSettings)
                local InputFunctions = {}
                local input = Instance.new("Frame")
                input.Name = "Input"
                input.AutomaticSize = Enum.AutomaticSize.Y
                input.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                input.BackgroundTransparency = 1
                input.BorderColor3 = Color3.fromRGB(0, 0, 0)
                input.BorderSizePixel = 0
                input.Size = UDim2.new(1, 0, 0, IsMobile and 45 or 38)
                input.Parent = section
                
                local inputName = Instance.new("TextLabel")
                inputName.Name = "InputName"
                inputName.FontFace = Font.new(
                    assets.interFont,
                    Enum.FontWeight.Medium,
                    Enum.FontStyle.Normal
                )
                inputName.Text = InputSettings.Name
                inputName.RichText = true
                inputName.TextColor3 = Color3.fromRGB(255, 255, 255)
                inputName.TextSize = IsMobile and 15 or 13
                inputName.TextTransparency = 0.5
                inputName.TextTruncate = Enum.TextTruncate.AtEnd
                inputName.TextXAlignment = Enum.TextXAlignment.Left
                inputName.TextYAlignment = Enum.TextYAlignment.Top
                inputName.AnchorPoint = Vector2.new(0, 0.5)
                inputName.AutomaticSize = Enum.AutomaticSize.XY
                inputName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                inputName.BackgroundTransparency = 1
                inputName.BorderColor3 = Color3.fromRGB(0, 0, 0)
                inputName.BorderSizePixel = 0
                inputName.Position = UDim2.fromScale(0, 0.5)
                inputName.Parent = input
                
                local inputBox = Instance.new("TextBox")
                inputBox.Name = "InputBox"
                inputBox.FontFace = Font.new(
                    assets.interFont,
                    Enum.FontWeight.Medium,
                    Enum.FontStyle.Normal
                )
                inputBox.Text = "Hello world!"
                inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                inputBox.TextSize = IsMobile and 14 or 12
                inputBox.TextTransparency = 0.4
                inputBox.AnchorPoint = Vector2.new(1, 0.5)
                inputBox.AutomaticSize = Enum.AutomaticSize.X
                inputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                inputBox.BackgroundTransparency = 0.95
                inputBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                inputBox.BorderSizePixel = 0
                inputBox.ClipsDescendants = true
                inputBox.LayoutOrder = 1
                inputBox.Position = UDim2.fromScale(1, 0.5)
                inputBox.Size = UDim2.fromOffset(IsMobile and 25 or 21, IsMobile and 25 or 21)
                
                local inputBoxUICorner = Instance.new("UICorner")
                inputBoxUICorner.Name = "InputBoxUICorner"
                inputBoxUICorner.CornerRadius = UDim.new(0, IsMobile and 6 or 4)
                inputBoxUICorner.Parent = inputBox
                
                local inputBoxUIStroke = Instance.new("UIStroke")
                inputBoxUIStroke.Name = "InputBoxUIStroke"
                inputBoxUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                inputBoxUIStroke.Color = Color3.fromRGB(255, 255, 255)
                inputBoxUIStroke.Transparency = 0.9
                inputBoxUIStroke.Parent = inputBox
                
                local inputBoxUIPadding = Instance.new("UIPadding")
                inputBoxUIPadding.Name = "InputBoxUIPadding"
                inputBoxUIPadding.PaddingLeft = UDim.new(0, IsMobile and 6 or 5)
                inputBoxUIPadding.PaddingRight = UDim.new(0, IsMobile and 6 or 5)
                inputBoxUIPadding.Parent = inputBox
                
                local inputBoxUISizeConstraint = Instance.new("UISizeConstraint")
                inputBoxUISizeConstraint.Name = "InputBoxUISizeConstraint"
                inputBoxUISizeConstraint.Parent = inputBox
                
                inputBox.Parent = input
                
                local Input = input
                local InputBox = inputBox
                local InputName = inputName
                local Constraint = inputBoxUISizeConstraint
                
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
                
                local AcceptedCharacters = CharacterSubs[InputSettings.AcceptedCharacters] or CharacterSubs.All
                
                InputBox.AutomaticSize = Enum.AutomaticSize.X
                
                local function checkSize()
                    local nameWidth = InputName.AbsoluteSize.X
                    local totalWidth = Input.AbsoluteSize.X
                    
                    local maxWidth = totalWidth - nameWidth - 20
                    Constraint.MaxSize = Vector2.new(maxWidth, 9e9)
                end
                
                checkSize()
                InputName:GetPropertyChangedSignal("AbsoluteSize"):Connect(checkSize)
                
                InputBox.FocusLost:Connect(function()
                    local inputText = InputBox.Text
                    local filteredText = AcceptedCharacters(inputText)
                    InputBox.Text = filteredText
                    task.spawn(function()
                        if InputSettings.Callback then
                            InputSettings.Callback(filteredText)
                        end
                    end)
                end)
                InputBox.Text = InputSettings.Default or ""
                InputBox.PlaceholderText = InputSettings.Placeholder or ""
                
                InputBox:GetPropertyChangedSignal("Text"):Connect(function()
                    InputBox.Text = AcceptedCharacters(InputBox.Text)
                    if InputSettings.onChanged then
                        InputSettings.onChanged(InputBox.Text)
                    end
                    InputFunctions.Text = InputBox.Text
                end)
                
                function InputFunctions:UpdateName(Name)
                    inputName.Text = Name
                end
                
                function InputFunctions:SetVisibility(State)
                    input.Visible = State
                end
                
                function InputFunctions:GetInput()
                    return InputBox.Text
                end
                
                function InputFunctions:UpdatePlaceholder(Placeholder)
                    inputBox.PlaceholderText = Placeholder
                end
                
                function InputFunctions:UpdateText(Text)
                    inputBox.Text = Text
                end
                
                return InputFunctions
            end
            
            function SectionFunctions:Keybind(KeybindSettings)
                local KeybindFunctions = {}
                local keybind = Instance.new("Frame")
                keybind.Name = "Keybind"
                keybind.AutomaticSize = Enum.AutomaticSize.Y
                keybind.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                keybind.BackgroundTransparency = 1
                keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
                keybind.BorderSizePixel = 0
                keybind.Size = UDim2.new(1, 0, 0, IsMobile and 45 or 38)
                keybind.Parent = section
                
                local keybindName = Instance.new("TextLabel")
                keybindName.Name = "KeybindName"
                keybindName.FontFace = Font.new(
                    assets.interFont,
                    Enum.FontWeight.Medium,
                    Enum.FontStyle.Normal
                )
                keybindName.Text = KeybindSettings.Name
                keybindName.RichText = true
                keybindName.TextColor3 = Color3.fromRGB(255, 255, 255)
                keybindName.TextSize = IsMobile and 15 or 13
                keybindName.TextTransparency = 0.5
                keybindName.TextTruncate = Enum.TextTruncate.AtEnd
                keybindName.TextXAlignment = Enum.TextXAlignment.Left
                keybindName.TextYAlignment = Enum.TextYAlignment.Top
                keybindName.AnchorPoint = Vector2.new(0, 0.5)
                keybindName.AutomaticSize = Enum.AutomaticSize.XY
                keybindName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                keybindName.BackgroundTransparency = 1
                keybindName.BorderColor3 = Color3.fromRGB(0, 0, 0)
                keybindName.BorderSizePixel = 0
                keybindName.Position = UDim2.fromScale(0, 0.5)
                keybindName.Parent = keybind
                
                local binderBox = Instance.new("TextBox")
                binderBox.Name = "BinderBox"
                binderBox.CursorPosition = -1
                binderBox.FontFace = Font.new(
                    assets.interFont,
                    Enum.FontWeight.Medium,
                    Enum.FontStyle.Normal
                )
                binderBox.PlaceholderText = "..."
                binderBox.Text = ""
                binderBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                binderBox.TextSize = IsMobile and 14 or 12
                binderBox.TextTransparency = 0.4
                binderBox.AnchorPoint = Vector2.new(1, 0.5)
                binderBox.AutomaticSize = Enum.AutomaticSize.X
                binderBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                binderBox.BackgroundTransparency = 0.95
                binderBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                binderBox.BorderSizePixel = 0
                binderBox.ClipsDescendants = true
                binderBox.LayoutOrder = 1
                binderBox.Position = UDim2.fromScale(1, 0.5)
                binderBox.Size = UDim2.fromOffset(IsMobile and 25 or 21, IsMobile and 25 or 21)
                
                local binderBoxUICorner = Instance.new("UICorner")
                binderBoxUICorner.Name = "BinderBoxUICorner"
                binderBoxUICorner.CornerRadius = UDim.new(0, IsMobile and 6 or 4)
                binderBoxUICorner.Parent = binderBox
                
                local binderBoxUIStroke = Instance.new("UIStroke")
                binderBoxUIStroke.Name = "BinderBoxUIStroke"
                binderBoxUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                binderBoxUIStroke.Color = Color3.fromRGB(255, 255, 255)
                binderBoxUIStroke.Transparency = 0.9
                binderBoxUIStroke.Parent = binderBox
                
                local binderBoxUIPadding = Instance.new("UIPadding")
                binderBoxUIPadding.Name = "BinderBoxUIPadding"
                binderBoxUIPadding.PaddingLeft = UDim.new(0, IsMobile and 6 or 5)
                binderBoxUIPadding.PaddingRight = UDim.new(0, IsMobile and 6 or 5)
                binderBoxUIPadding.Parent = binderBox
                
                local binderBoxUISizeConstraint = Instance.new("UISizeConstraint")
                binderBoxUISizeConstraint.Name = "BinderBoxUISizeConstraint"
                binderBoxUISizeConstraint.Parent = binderBox
                
                binderBox.Parent = keybind
                
                local focused
                local binded = KeybindSettings.Default
                if binded then
                    binderBox.Text = binded.Name
                end
                
                -- Register keybind with quick menu
                RegisterKeybind(binded and binded.Name or "None", function()
                    if KeybindSettings.Callback then
                        KeybindSettings.Callback(binded)
                    end
                end, KeybindSettings.Name)
                
                binderBox.Focused:Connect(function()
                    focused = true
                end)
                binderBox.FocusLost:Connect(function()
                    focused = false
                end)
                
                UserInputService.InputEnded:Connect(function(inp)
                    if starlightGui ~= nil then
                        if focused and inp.KeyCode.Name ~= "Unknown" then
                            binded = inp.KeyCode
                            KeybindFunctions.Bind = binded
                            binderBox.Text = inp.KeyCode.Name
                            binderBox:ReleaseFocus()
                            
                            -- Update keybind registration
                            for i, bind in ipairs(keybinds) do
                                if bind.Name == KeybindSettings.Name then
                                    bind.Key = inp.KeyCode.Name
                                    break
                                end
                            end
                            
                            if KeybindSettings.onBinded then
                                KeybindSettings.onBinded(binded)
                            end
                        elseif inp.KeyCode == binded then
                            if KeybindSettings.Callback then
                                KeybindSettings.Callback(binded)
                            end
                        end
                    end
                end)
                
                function KeybindFunctions:Bind(Key)
                    binded = Key
                    binderBox.Text = Key.Name
                    
                    -- Update keybind registration
                    for i, bind in ipairs(keybinds) do
                        if bind.Name == KeybindSettings.Name then
                            bind.Key = Key.Name
                            break
                        end
                    end
                end
                
                function KeybindFunctions:Unbind()
                    binded = nil
                    binderBox.Text = ""
                    
                    -- Update keybind registration
                    for i, bind in ipairs(keybinds) do
                        if bind.Name == KeybindSettings.Name then
                            bind.Key = "None"
                            break
                        end
                    end
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
            
            function SectionFunctions:Dropdown(DropdownSettings)
                local DropdownFunctions = {}
                local Selected = {}
                local OptionObjs = {}
                
                local dropdown = Instance.new("Frame")
                dropdown.Name = "Dropdown"
                dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdown.BackgroundTransparency = 0.985
                dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdown.BorderSizePixel = 0
                dropdown.Size = UDim2.new(1, 0, 0, IsMobile and 45 or 38)
                dropdown.Parent = section
                dropdown.ClipsDescendants = true
                
                local dropdownUIPadding = Instance.new("UIPadding")
                dropdownUIPadding.Name = "DropdownUIPadding"
                dropdownUIPadding.PaddingLeft = UDim.new(0, IsMobile and 18 or 15)
                dropdownUIPadding.PaddingRight = UDim.new(0, IsMobile and 18 or 15)
                dropdownUIPadding.Parent = dropdown
                
                local interact = Instance.new("TextButton")
                interact.Name = "Interact"
                interact.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
                interact.Text = ""
                interact.TextColor3 = Color3.fromRGB(0, 0, 0)
                interact.TextSize = 14
                interact.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                interact.BackgroundTransparency = 1
                interact.BorderColor3 = Color3.fromRGB(0, 0, 0)
                interact.BorderSizePixel = 0
                interact.Size = UDim2.new(1, 0, 0, IsMobile and 45 or 38)
                interact.Parent = dropdown
                
                local dropdownName = Instance.new("TextLabel")
                dropdownName.Name = "DropdownName"
                dropdownName.FontFace = Font.new(
                    assets.interFont,
                    Enum.FontWeight.Medium,
                    Enum.FontStyle.Normal
                )
                dropdownName.Text = DropdownSettings.Name
                dropdownName.RichText = true
                dropdownName.TextColor3 = Color3.fromRGB(255, 255, 255)
                dropdownName.TextSize = IsMobile and 15 or 13
                dropdownName.TextTransparency = 0.5
                dropdownName.TextTruncate = Enum.TextTruncate.SplitWord
                dropdownName.TextXAlignment = Enum.TextXAlignment.Left
                dropdownName.AutomaticSize = Enum.AutomaticSize.Y
                dropdownName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdownName.BackgroundTransparency = 1
                dropdownName.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdownName.BorderSizePixel = 0
                dropdownName.Size = UDim2.new(1, -20, 0, IsMobile and 45 or 38)
                dropdownName.Parent = dropdown
                
                local dropdownUIStroke = Instance.new("UIStroke")
                dropdownUIStroke.Name = "DropdownUIStroke"
                dropdownUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                dropdownUIStroke.Color = Color3.fromRGB(255, 255, 255)
                dropdownUIStroke.Transparency = 0.95
                dropdownUIStroke.Parent = dropdown
                
                local dropdownUICorner = Instance.new("UICorner")
                dropdownUICorner.Name = "DropdownUICorner"
                dropdownUICorner.CornerRadius = UDim.new(0, IsMobile and 8 or 6)
                dropdownUICorner.Parent = dropdown
                
                local dropdownImage = Instance.new("ImageLabel")
                dropdownImage.Name = "DropdownImage"
                dropdownImage.Image = assets.dropdownArrow
                dropdownImage.ImageTransparency = 0.5
                dropdownImage.AnchorPoint = Vector2.new(1, 0)
                dropdownImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdownImage.BackgroundTransparency = 1
                dropdownImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdownImage.BorderSizePixel = 0
                dropdownImage.Position = UDim2.new(1, 0, 0, IsMobile and 15 or 12)
                dropdownImage.Size = IsMobile and UDim2.fromOffset(18, 18) or UDim2.fromOffset(14, 14)
                dropdownImage.Parent = dropdown
                
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Name = "DropdownFrame"
                dropdownFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdownFrame.BackgroundTransparency = 1
                dropdownFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdownFrame.BorderSizePixel = 0
                dropdownFrame.ClipsDescendants = true
                dropdownFrame.Size = UDim2.fromScale(1, 1)
                dropdownFrame.Visible = false
                dropdownFrame.AutomaticSize = Enum.AutomaticSize.Y
                
                local dropdownFrameUIPadding = Instance.new("UIPadding")
                dropdownFrameUIPadding.Name = "DropdownFrameUIPadding"
                dropdownFrameUIPadding.PaddingTop = UDim.new(0, IsMobile and 45 or 38)
                dropdownFrameUIPadding.PaddingBottom = UDim.new(0, IsMobile and 12 or 10)
                dropdownFrameUIPadding.Parent = dropdownFrame
                
                local dropdownFrameUIListLayout = Instance.new("UIListLayout")
                dropdownFrameUIListLayout.Name = "DropdownFrameUIListLayout"
                dropdownFrameUIListLayout.Padding = UDim.new(0, IsMobile and 6 or 5)
                dropdownFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                dropdownFrameUIListLayout.Parent = dropdownFrame
                
                local search = Instance.new("Frame")
                search.Name = "Search"
                search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                search.BackgroundTransparency = 0.95
                search.BorderColor3 = Color3.fromRGB(0, 0, 0)
                search.BorderSizePixel = 0
                search.LayoutOrder = -1
                search.Size = UDim2.new(1, 0, 0, IsMobile and 35 or 30)
                search.Parent = dropdownFrame
                search.Visible = DropdownSettings.Search
                
                local sectionUICorner = Instance.new("UICorner")
                sectionUICorner.Name = "SectionUICorner"
                sectionUICorner.Parent = search
                
                local searchIcon = Instance.new("ImageLabel")
                searchIcon.Name = "SearchIcon"
                searchIcon.Image = assets.searchIcon
                searchIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
                searchIcon.AnchorPoint = Vector2.new(0, 0.5)
                searchIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                searchIcon.BackgroundTransparency = 1
                searchIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
                searchIcon.BorderSizePixel = 0
                searchIcon.Position = UDim2.fromScale(0, 0.5)
                searchIcon.Size = IsMobile and UDim2.fromOffset(15, 15) or UDim2.fromOffset(12, 12)
                searchIcon.Parent = search
                
                local uIPadding = Instance.new("UIPadding")
                uIPadding.Name = "UIPadding"
                uIPadding.PaddingLeft = UDim.new(0, IsMobile and 18 or 15)
                uIPadding.Parent = search
                
                local searchBox = Instance.new("TextBox")
                searchBox.Name = "SearchBox"
                searchBox.CursorPosition = -1
                searchBox.FontFace = Font.new(
                    assets.interFont,
                    Enum.FontWeight.Medium,
                    Enum.FontStyle.Normal
                )
                searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
                searchBox.PlaceholderText = "Search..."
                searchBox.Text = ""
                searchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
                searchBox.TextSize = IsMobile and 16 or 14
                searchBox.TextXAlignment = Enum.TextXAlignment.Left
                searchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                searchBox.BackgroundTransparency = 1
                searchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                searchBox.BorderSizePixel = 0
                searchBox.Size = UDim2.fromScale(1, 1)
                
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
                uIPadding1.PaddingLeft = UDim.new(0, IsMobile and 23 or 18)
                uIPadding1.Parent = searchBox
                
                searchBox.Parent = search
                
                local tweensettings = {
                    duration = 0.2,
                    easingStyle = Enum.EasingStyle.Quint,
                    transparencyIn = 0.2,
                    transparencyOut = 0.5,
                    checkSizeIncrease = IsMobile and 14 or 12,
                    checkSizeDecrease = -IsMobile and 16 or -13,
                    waitTime = 1
                }
                
                local function Toggle(optionName, State)
                    local option = OptionObjs[optionName]
                    
                    if not option then return end
                    
                    local checkmark = option.Checkmark
                    local optionNameLabel = option.NameLabel
                    
                    if State then
                        if DropdownSettings.Multi then
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
                        if DropdownSettings.Multi then
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
                    
                    if DropdownSettings.Required and #Selected == 0 and not State then
                        return
                    end
                    
                    if #Selected > 0 then
                        dropdownName.Text = DropdownSettings.Name .. " • " .. table.concat(Selected, ", ")
                    else
                        dropdownName.Text = DropdownSettings.Name
                    end
                end
                
                local dropped = false
                local db = false
                
                local function ToggleDropdown()
                    if db then return end
                    db = true
                    local defaultDropdownSize = IsMobile and 45 or 38
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
                    option.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
                    option.Text = ""
                    option.TextColor3 = Color3.fromRGB(0, 0, 0)
                    option.TextSize = 14
                    option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    option.BackgroundTransparency = 1
                    option.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    option.BorderSizePixel = 0
                    option.Size = UDim2.new(1, 0, 0, IsMobile and 35 or 30)
                    
                    local optionUIPadding = Instance.new("UIPadding")
                    optionUIPadding.Name = "OptionUIPadding"
                    optionUIPadding.PaddingLeft = UDim.new(0, IsMobile and 18 or 15)
                    optionUIPadding.Parent = option
                    
                    local optionName = Instance.new("TextLabel")
                    optionName.Name = "OptionName"
                    optionName.FontFace = Font.new(
                        assets.interFont,
                        Enum.FontWeight.Medium,
                        Enum.FontStyle.Normal
                    )
                    optionName.Text = v
                    optionName.RichText = true
                    optionName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    optionName.TextSize = IsMobile and 15 or 13
                    optionName.TextTransparency = 0.5
                    optionName.TextTruncate = Enum.TextTruncate.AtEnd
                    optionName.TextXAlignment = Enum.TextXAlignment.Left
                    optionName.TextYAlignment = Enum.TextYAlignment.Top
                    optionName.AnchorPoint = Vector2.new(0, 0.5)
                    optionName.AutomaticSize = Enum.AutomaticSize.XY
                    optionName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    optionName.BackgroundTransparency = 1
                    optionName.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    optionName.BorderSizePixel = 0
                    optionName.Position = UDim2.fromScale(0, 0.5)
                    optionName.Size = UDim2.fromScale(1, 0)
                    optionName.Parent = option
                    
                    local checkmark = Instance.new("TextLabel")
                    checkmark.Name = "Checkmark"
                    checkmark.FontFace = Font.new(
                        assets.interFont,
                        Enum.FontWeight.Medium,
                        Enum.FontStyle.Normal
                    )
                    checkmark.Text = "✓"
                    checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
                    checkmark.TextSize = IsMobile and 15 or 13
                    checkmark.TextTransparency = 1
                    checkmark.TextTruncate = Enum.TextTruncate.AtEnd
                    checkmark.TextXAlignment = Enum.TextXAlignment.Left
                    checkmark.TextYAlignment = Enum.TextYAlignment.Top
                    checkmark.AnchorPoint = Vector2.new(0, 0.5)
                    checkmark.AutomaticSize = Enum.AutomaticSize.Y
                    checkmark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    checkmark.BackgroundTransparency = 1
                    checkmark.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    checkmark.BorderSizePixel = 0
                    checkmark.LayoutOrder = -1
                    checkmark.Position = UDim2.fromScale(0, 0.5)
                    checkmark.Size = UDim2.new(checkmark.Size.X.Scale, -IsMobile and 16 or -13, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
                    checkmark.Parent = option
                    
                    if DropdownSettings.Default then
                        if DropdownSettings.Multi then
                            if table.find(DropdownSettings.Default, v) then
                                Toggle(v, true)
                            end
                        else
                            if DropdownSettings.Default == v then
                                Toggle(v, true)
                            end
                        end
                    end
                    
                    option.MouseButton1Click:Connect(function()
                        Toggle(v, not (DropdownSettings.Multi and table.find(Selected, v) or Selected[1] == v))
                        if DropdownSettings.Callback then
                            DropdownSettings.Callback(DropdownSettings.Multi and Selected or Selected[1])
                        end
                    end)
                    
                    option.Parent = dropdownFrame
                    OptionObjs[v] = {Button = option, Checkmark = checkmark, NameLabel = optionName}
                end
                
                for i, v in ipairs(DropdownSettings.Content) do
                    addOption(i, v)
                end
                
                dropdownFrame.Parent = dropdown
                
                function DropdownFunctions:UpdateOption(Option, NewName)
                    local option = OptionObjs[Option]
                    if option then
                        option.NameLabel.Text = NewName
                        OptionObjs[NewName] = option
                        OptionObjs[Option] = nil
                    end
                end
                
                function DropdownFunctions:AddOption(Option)
                    addOption(#DropdownSettings.Content + 1, Option)
                    table.insert(DropdownSettings.Content, Option)
                end
                
                function DropdownFunctions:RemoveOption(Option)
                    local option = OptionObjs[Option]
                    if option then
                        option.Button:Destroy()
                        OptionObjs[Option] = nil
                        local idx = table.find(DropdownSettings.Content, Option)
                        if idx then
                            table.remove(DropdownSettings.Content, idx)
                        end
                    end
                end
                
                function DropdownFunctions:SetOptions(Options)
                    DropdownSettings.Content = Options
                    Selected = {}
                    for _, v in pairs(OptionObjs) do
                        v.Button:Destroy()
                    end
                    OptionObjs = {}
                    for i, v in ipairs(Options) do
                        addOption(i, v)
                    end
                end
                
                function DropdownFunctions:Clear()
                    DropdownSettings.Content = {}
                    Selected = {}
                    for _, v in pairs(OptionObjs) do
                        v.Button:Destroy()
                    end
                    OptionObjs = {}
                end
                
                function DropdownFunctions:GetOptions()
                    return DropdownSettings.Content
                end
                
                function DropdownFunctions:GetSelected()
                    return DropdownSettings.Multi and Selected or Selected[1]
                end
                
                function DropdownFunctions:UpdateName(Name)
                    dropdownName.Text = Name
                end
                
                function DropdownFunctions:SetVisibility(State)
                    dropdown.Visible = State
                end
                
                return DropdownFunctions
            end
            
            return SectionFunctions
        end
        
        return TabFunctions
    end
    
    --// Cleanup
    starlightGui.AncestryChanged:Connect(function()
        if not starlightGui.Parent then
            if quickMenu then
                quickMenu.Gui:Destroy()
            end
            if currentKeybindConnection then
                currentKeybindConnection:Disconnect()
            end
        end
    end)
    
    --// Window Control Functions
    exit.MouseButton1Click:Connect(function()
        starlightGui:Destroy()
    end)
    
    minimize.MouseButton1Click:Connect(function()
        base.Visible = not base.Visible
        if quickMenu then
            quickMenu.Gui.Enabled = base.Visible
        end
    end)
    
    return WindowFunctions
end

getgenv().StarLight = StarLight
return StarLight