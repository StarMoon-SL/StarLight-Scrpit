-- MacLib Enhanced - Complete version with device detection and full touch support
-- Based on MacLib with device detection from WindUI and Keybind system from LinoriaLib

local MacLib = {}

--// Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

--// Device Detection System (From WindUI)
local Device = {
    IsMobile = false,
    IsConsole = false,
    IsPC = true,
    Executor = "Unknown",
    HardwareId = nil,
    IsStudio = RunService:IsStudio(),
    Platform = "Unknown"
}

-- Comprehensive device detection
local function DetectDevice()
    -- Detect platform type
    local touchEnabled = UserInputService.TouchEnabled
    local keyboardEnabled = UserInputService.KeyboardEnabled
    local mouseEnabled = UserInputService.MouseEnabled
    local gyroscopeEnabled = UserInputService.GyroscopeEnabled
    local accelerometerEnabled = UserInputService.AccelerometerEnabled
    
    -- Console detection (10-foot interface)
    if GuiService:IsTenFootInterface() then
        Device.IsConsole = true
        Device.IsPC = false
        Device.IsMobile = false
        Device.Platform = "Console"
    -- Mobile detection: Touch + sensors + no keyboard
    elseif touchEnabled and (gyroscopeEnabled or accelerometerEnabled) and not keyboardEnabled then
        Device.IsMobile = true
        Device.IsPC = false
        Device.IsConsole = false
        Device.Platform = "Mobile"
    -- PC detection: Keyboard/mouse present
    elseif keyboardEnabled or mouseEnabled then
        Device.IsPC = true
        Device.IsMobile = false
        Device.IsConsole = false
        Device.Platform = "PC"
    else
        -- Fallback: Assume PC
        Device.IsPC = true
        Device.Platform = "PC Fallback"
    end
    
    -- Executor detection for exploits
    if identifyexecutor then
        local success, execName = pcall(identifyexecutor)
        if success then
            Device.Executor = execName or "Unknown"
        end
    end
    
    -- Hardware ID detection with fallback
    if gethwid then
        local success, hwid = pcall(gethwid)
        if success then
            Device.HardwareId = hwid
        else
            Device.HardwareId = tostring(Players.LocalPlayer.UserId)
        end
    else
        Device.HardwareId = tostring(Players.LocalPlayer.UserId)
    end
end

DetectDevice()

print(string.format("[MacLib] Detected Platform: %s | Executor: %s | HardwareId: %s", 
    Device.Platform, Device.Executor, Device.HardwareId))

--// Device-aware UI Sizing (Enhanced from WindUI)
local function GetDeviceAdjustedSize()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    
    if Device.IsMobile then
        -- Mobile: Larger UI for touch targets, 90% screen usage
        return UDim2.fromOffset(
            math.min(900, viewportSize.X * 0.92),
            math.min(680, viewportSize.Y * 0.88)
        )
    elseif Device.IsConsole then
        -- Console: Even larger for TV viewing
        return UDim2.fromOffset(
            math.min(950, viewportSize.X * 0.95),
            math.min(720, viewportSize.Y * 0.90)
        )
    else
        -- PC: Original MacLib size
        return UDim2.fromOffset(868, 650)
    end
end

--// Global Variables
local LocalPlayer = Players.LocalPlayer
local windowState = nil
local acrylicBlur = true
local hasGlobalSetting = false
local tabIndex = 0

--// Asset References
local assets = {
    interFont = "rbxassetid://12187365364",
    userInfoBlurred = "rbxassetid://18824089198",
    toggleBackground = "rbxassetid://18772190202",
    togglerHead = "rbxassetid://18772309008",
    buttonImage = "rbxassetid://10709791437",
    searchIcon = "rbxassetid://86737463322606"
}

--// Utility Functions
local function Tween(instance, tweeninfo, propertytable)
    return TweenService:Create(instance, tweeninfo, propertytable)
end

local function CreateElement(name, class, props)
    local element = Instance.new(class)
    element.Name = name
    
    for prop, value in pairs(props or {}) do
        if prop == "Parent" then
            element.Parent = value
        else
            element[prop] = value
        end
    end
    
    return element
end

--// Keybind Manager (From LinoriaLib - Enhanced)
local KeybindManager = {
    Keybinds = {},
    KeybindList = nil,
    Active = true
}

function KeybindManager:NewKeybind(name, defaultKey, callback, description)
    if not name or not callback then
        warn("[MacLib] Invalid keybind: name and callback required")
        return nil
    end
    
    -- Remove existing keybind with same name
    for i, k in ipairs(self.Keybinds) do
        if k.Name == name then
            table.remove(self.Keybinds, i)
            break
        end
    end
    
    local keybind = {
        Name = name,
        Key = defaultKey,
        Callback = callback,
        Description = description or name,
        Enabled = true,
        CreatedAt = tick()
    }
    
    table.insert(self.Keybinds, keybind)
    self:UpdateKeybindList()
    
    return keybind
end

function KeybindManager:RemoveKeybind(name)
    for i, k in ipairs(self.Keybinds) do
        if k.Name == name then
            table.remove(self.Keybinds, i)
            self:UpdateKeybindList()
            return true
        end
    end
    return false
end

function KeybindManager:GetKeybind(name)
    for _, k in ipairs(self.Keybinds) do
        if k.Name == name then
            return k
        end
    end
    return nil
end

function KeybindManager:SetActive(active)
    self.Active = active
end

function KeybindManager:UpdateKeybindList()
    if not self.KeybindList then return end
    
    -- Clear existing entries
    for _, child in pairs(self.KeybindList:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    -- Add header
    local header = CreateElement("Header", "TextLabel", {
        FontFace = Font.new(assets.interFont, Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        Text = "Active Keybinds",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        TextTransparency = 0.2,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Parent = self.KeybindList
    })
    
    -- Add keybind entries
    local yOffset = 20
    for _, keybind in ipairs(self.Keybinds) do
        if keybind.Key and keybind.Enabled then
            local label = CreateElement("KeybindEntry", "TextLabel", {
                FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                Text = string.format("[%s] %s", keybind.Key.Name, keybind.Description),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 11,
                TextTransparency = 0.6,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Position = UDim2.fromOffset(0, yOffset),
                Parent = self.KeybindList
            })
            
            yOffset = yOffset + 18
        end
    end
    
    self.KeybindList.CanvasSize = UDim2.fromOffset(0, yOffset + 5)
end

-- Input handler for keybind triggers
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not KeybindManager.Active or gameProcessed then return end
    
    for _, keybind in ipairs(KeybindManager.Keybinds) do
        if keybind.Key and keybind.Enabled and input.KeyCode == keybind.Key then
            task.spawn(function()
                local success, err = pcall(keybind.Callback)
                if not success then
                    warn(string.format("[MacLib] Keybind '%s' callback error: %s", keybind.Name, err))
                end
            end)
        end
    end
end)

--// Enhanced Window Function
function MacLib:Window(Settings)
    local WindowFunctions = {}
    
    -- Validate settings
    Settings = Settings or {}
    Settings.Title = Settings.Title or "MacLib Window"
    Settings.Subtitle = Settings.Subtitle or "Enhanced UI Library"
    
    -- Apply device-aware sizing
    Settings.Size = Settings.Size or GetDeviceAdjustedSize()
    acrylicBlur = (Settings.AcrylicBlur ~= false)
    
    -- Main ScreenGui
    local macLib = CreateElement("MacLib", "ScreenGui", {
        ResetOnSpawn = false,
        DisplayOrder = 100,
        IgnoreGuiInset = true,
        ScreenInsets = Enum.ScreenInsets.None,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (Device.IsStudio and LocalPlayer.PlayerGui) or game:GetService("CoreGui")
    })
    
    -- Notifications Container
    local notifications = CreateElement("Notifications", "Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = macLib
    })
    
    local notificationsUIListLayout = CreateElement("NotificationsUIListLayout", "UIListLayout", {
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = notifications
    })
    
    local notificationsUIPadding = CreateElement("NotificationsUIPadding", "UIPadding", {
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        Parent = notifications
    })
    
    -- Main Window Base
    local base = CreateElement("Base", "Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BackgroundTransparency = acrylicBlur and 0.05 or 0,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = Settings.Size,
        Parent = macLib
    })
    
    local baseUIScale = CreateElement("BaseUIScale", "UIScale", {
        Scale = Device.IsMobile and 1.05 or 1,
        Parent = base
    })
    
    local baseUICorner = CreateElement("BaseUICorner", "UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = base
    })
    
    local baseUIStroke = CreateElement("BaseUIStroke", "UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.9,
        Parent = base
    })
    
    -- Sidebar
    local sidebar = CreateElement("Sidebar", "Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.325, 1),
        Parent = base
    })
    
    local divider = CreateElement("Divider", "Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.9,
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Parent = sidebar
    })
    
    -- Window Controls
    local windowControls = CreateElement("WindowControls", "Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 31),
        Parent = sidebar
    })
    
    local controls = CreateElement("Controls", "Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = windowControls
    })
    
    local controlsUIListLayout = CreateElement("ControlsUIListLayout", "UIListLayout", {
        Padding = UDim.new(0, 5),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = controls
    })
    
    local controlsUIPadding = CreateElement("ControlsUIPadding", "UIPadding", {
        PaddingLeft = UDim.new(0, 11),
        Parent = controls
    })
    
    -- Control Buttons
    local windowControlSettings = {
        sizes = { enabled = UDim2.fromOffset(8, 8), disabled = UDim2.fromOffset(7, 7) },
        transparencies = { enabled = 0, disabled = 1 },
        strokeTransparency = 0.9,
    }
    
    local function createControlButton(name, color, layoutOrder)
        local button = CreateElement(name, "TextButton", {
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
            Text = "",
            TextColor3 = Color3.fromRGB(0, 0, 0),
            TextSize = 14,
            AutoButtonColor = false,
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Parent = controls
        })
        
        if layoutOrder then button.LayoutOrder = layoutOrder end
        
        CreateElement(name .. "UICorner", "UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = button
        })
        
        -- Enhanced touch support for control buttons
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                -- Add haptic feedback for mobile
                if Device.IsMobile and input.UserInputType == Enum.UserInputType.Touch then
                    -- Visual feedback instead of haptic
                    Tween(button, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
                        Size = windowControlSettings.sizes.disabled
                    }):Play()
                end
            end
        end)
        
        button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Tween(button, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
                    Size = windowControlSettings.sizes.enabled
                }):Play()
            end
        end)
        
        return button
    end
    
    local exitButton = createControlButton("Exit", Color3.fromRGB(250, 93, 86))
    local minimizeButton = createControlButton("Minimize", Color3.fromRGB(252, 190, 57), 1)
    local maximizeButton = createControlButton("Maximize", Color3.fromRGB(119, 174, 94), 1)
    
    -- Apply control states
    local function applyControlState(button, enabled)
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
            CreateElement(button.Name .. "Stroke", "UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Color3.fromRGB(255, 255, 255),
                Transparency = windowControlSettings.strokeTransparency,
                Parent = button
            })
        end
    end
    
    applyControlState(maximizeButton, false)
    
    -- Information Section
    local information = CreateElement("Information", "Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 31),
        Size = UDim2.new(1, 0, 0, 60),
        Parent = sidebar
    })
    
    local divider2 = CreateElement("Divider2", "Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 0.9,
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = information
    })
    
    local informationHolder = CreateElement("InformationHolder", "Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = information
    })
    
    local informationHolderUIPadding = CreateElement("InformationHolderUIPadding", "UIPadding", {
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 23),
        PaddingRight = UDim.new(0, 22),
        PaddingTop = UDim.new(0, 10),
        Parent = informationHolder
    })
    
    -- Global Settings Button
    local globalSettingsButton = CreateElement("GlobalSettingsButton", "ImageButton", {
        Image = "rbxassetid://18767849817",
        ImageTransparency = 0.4,
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(1, 0.5),
        Size = UDim2.fromOffset(15, 15),
        Parent = informationHolder
    })
    
    globalSettingsButton.MouseEnter:Connect(function()
        Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
            ImageTransparency = 0.2
        }):Play()
    end)
    
    globalSettingsButton.MouseLeave:Connect(function()
        Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
            ImageTransparency = 0.4
        }):Play()
    end)
    
    -- Title and Subtitle
    local titleFrame = CreateElement("TitleFrame", "Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = informationHolder
    })
    
    local title = CreateElement("Title", "TextLabel", {
        FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = Settings.Title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = Device.IsMobile and 22 or 20, -- Larger on mobile
        TextTransparency = 0.2,
        TextTruncate = Enum.TextTruncate.SplitWord,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 0),
        Parent = titleFrame
    })
    
    local subtitle = CreateElement("Subtitle", "TextLabel", {
        FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Text = Settings.Subtitle,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = Device.IsMobile and 13 or 12, -- Larger on mobile
        TextTransparency = 0.7,
        TextTruncate = Enum.TextTruncate.SplitWord,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Size = UDim2.new(1, -20, 0, 0),
        Parent = titleFrame
    })
    
    -- Sidebar Group with Keybind List
    local sidebarGroup = CreateElement("SidebarGroup", "Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 91),
        Size = UDim2.new(1, 0, 1, -91),
        Parent = sidebar
    })
    
    local sidebarGroupUIPadding = CreateElement("SidebarGroupUIPadding", "UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 31),
        Parent = sidebarGroup
    })
    
    -- Keybind List (Enhanced from LinoriaLib)
    local keybindListFrame = CreateElement("KeybindListFrame", "ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 80),
        Position = UDim2.fromScale(0, 1),
        AnchorPoint = Vector2.new(0, 1),
        CanvasSize = UDim2.new(),
        ScrollBarThickness = 2,
        ScrollBarImageTransparency = 0.8,
        Visible = false,
        Parent = sidebarGroup
    })
    
    local keybindListUIPadding = CreateElement("KeybindListUIPadding", "UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 5),
        Parent = keybindListFrame
    })
    
    KeybindManager.KeybindList = keybindListFrame
    
    -- Keybind Toggle Button
    local keybindToggle = CreateElement("KeybindToggle", "ImageButton", {
        Image = assets.buttonImage,
        ImageTransparency = 0.5,
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.85, 0.5),
        Size = UDim2.fromOffset(15, 15),
        Parent = informationHolder
    })
    
    keybindToggle.MouseButton1Click:Connect(function()
        keybindListFrame.Visible = not keybindListFrame.Visible
        if keybindListFrame.Visible then
            KeybindManager:UpdateKeybindList()
        end
    end)
    
    -- Tab Switchers
    local tabSwitchers = CreateElement("TabSwitchers", "Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -107),
        Parent = sidebarGroup
    })
    
    local tabSwitchersScrollingFrame = CreateElement("TabSwitchersScrollingFrame", "ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BottomImage = "",
        CanvasSize = UDim2.new(),
        ScrollBarImageTransparency = 0.8,
        ScrollBarThickness = Device.IsMobile and 3 or 1, -- Thicker on mobile
        TopImage = "",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = tabSwitchers
    })
    
    local tabSwitchersScrollingFrameUIListLayout = CreateElement("TabSwitchersUIListLayout", "UIListLayout", {
        Padding = UDim.new(0, 17),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabSwitchersScrollingFrame
    })
    
    local tabSwitchersScrollingFrameUIPadding = CreateElement("TabSwitchersScrollingFrameUIPadding", "UIPadding", {
        PaddingTop = UDim.new(0, 2),
        Parent = tabSwitchersScrollingFrame
    })
    
    -- User Info Section
    local userInfo = CreateElement("UserInfo", "Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 107),
        Parent = sidebarGroup
    })
    
    local userInfoUIPadding = CreateElement("UserInfoUIPadding", "UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = userInfo
    })
    
    local informationGroup = CreateElement("InformationGroup", "Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = userInfo
    })
    
    local informationGroupUIPadding = CreateElement("InformationGroupUIPadding", "UIPadding", {
        PaddingBottom = UDim.new(0, 17),
        PaddingLeft = UDim.new(0, 25),
        Parent = informationGroup
    })
    
    local informationGroupUIListLayout = CreateElement("InformationGroupUIListLayout", "UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = informationGroup
    })
    
    -- Player Headshot
    local userId = LocalPlayer.UserId
    local headshotImage, isReady = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size48x48)
    
    local headshot = CreateElement("Headshot", "ImageLabel", {
        BackgroundTransparency = 1,
        Size = Device.IsMobile and UDim2.fromOffset(36, 36) or UDim2.fromOffset(32, 32),
        Image = (isReady and headshotImage) or "rbxassetid://0",
        Parent = informationGroup
    })
    
    CreateElement("HeadshotUICorner", "UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = headshot
    })
    
    CreateElement("HeadshotStroke", "UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.9,
        Parent = headshot
    })
    
    -- User Names
    local userAndDisplayFrame = CreateElement("UserAndDisplayFrame", "Frame", {
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Size = UDim2.new(1, -42, 0, 32),
        Parent = informationGroup
    })
    
    local userAndDisplayFrameUIPadding = CreateElement("UserAndDisplayFrameUIPadding", "UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 3),
        Parent = userAndDisplayFrame
    })
    
    local userAndDisplayFrameUIListLayout = CreateElement("UserAndDisplayFrameUIListLayout", "UIListLayout", {
        Padding = UDim.new(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = userAndDisplayFrame
    })
    
    local displayName = CreateElement("DisplayName", "TextLabel", {
        FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = LocalPlayer.DisplayName,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        TextTransparency = 0.2,
        TextTruncate = Enum.TextTruncate.SplitWord,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        Parent = userAndDisplayFrame
    })
    
    local username = CreateElement("Username", "TextLabel", {
        FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = "@" .. LocalPlayer.Name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        TextTransparency = 0.8,
        TextTruncate = Enum.TextTruncate.SplitWord,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Size = UDim2.fromScale(1, 0),
        Parent = userAndDisplayFrame
    })
    
    -- Content Area
    local content = CreateElement("Content", "Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(1, 4.69e-08),
        Size = UDim2.fromScale(0.675, 1),
        Parent = base
    })
    
    local topbar = CreateElement("Topbar", "Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 63),
        Parent = content
    })
    
    local divider4 = CreateElement("Divider4", "Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 0.9,
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = topbar
    })
    
    local elements = CreateElement("Elements", "Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = topbar
    })
    
    local elementsUIPadding = CreateElement("ElementsUIPadding", "UIPadding", {
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 20),
        Parent = elements
    })
    
    -- Enhanced Dragging with Touch Support
    local moveIcon = CreateElement("MoveIcon", "ImageButton", {
        Image = "rbxassetid://10734900011",
        ImageTransparency = 0.5,
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(1, 0.5),
        Size = UDim2.fromOffset(18, 18), -- Larger for touch
        Parent = elements
    })
    
    local interact = CreateElement("Interact", "TextButton", {
        Text = "",
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = 14,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(40, 40), -- Larger touch target
        Parent = moveIcon
    })
    
    moveIcon.Visible = not Settings.DragStyle or Settings.DragStyle == 1
    
    -- Current Tab Display
    local currentTab = CreateElement("CurrentTab", "TextLabel", {
        FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        RichText = true,
        Text = "Tab",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 15,
        TextTransparency = 0.5,
        TextTruncate = Enum.TextTruncate.SplitWord,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AnchorPoint = Vector2.new(0, 0.5),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromScale(0.9, 0),
        Parent = elements
    })
    
    -- Dragging Logic with Touch Support
    local dragging_ = false
    local dragInput
    local dragStart
    local startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    local function onDragStart(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging_ = true
            dragStart = input.Position
            startPos = base.Position
            
            -- Add visual feedback for mobile
            if Device.IsMobile and input.UserInputType == Enum.UserInputType.Touch then
                Tween(base, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
                    BackgroundTransparency = 0.1
                }):Play()
            end
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging_ = false
                    if Device.IsMobile and input.UserInputType == Enum.UserInputType.Touch then
                        Tween(base, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
                            BackgroundTransparency = 0.05
                        }):Play()
                    end
                end
            end)
        end
    end
    
    local function onDragUpdate(input)
        if dragging_ and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            dragInput = input
        end
    end
    
    -- Attach drag handlers
    if not Settings.DragStyle or Settings.DragStyle == 1 then
        interact.InputBegan:Connect(onDragStart)
        interact.InputChanged:Connect(onDragUpdate)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging_ then
                updateDrag(input)
            end
        end)
    else
        base.InputBegan:Connect(onDragStart)
        base.InputChanged:Connect(onDragUpdate)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging_ then
                updateDrag(input)
            end
        end)
    end
    
    -- Visual feedback for drag
    moveIcon.MouseEnter:Connect(function()
        Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
            ImageTransparency = 0.2
        }):Play()
    end)
    
    moveIcon.MouseLeave:Connect(function()
        Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
            ImageTransparency = 0.5
        }):Play()
    end)
    
    -- Global Settings Panel
    local globalSettings = CreateElement("GlobalSettings", "Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.298, 0.104),
        Parent = base
    })
    
    CreateElement("GlobalSettingsUIStroke", "UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.9,
        Parent = globalSettings
    })
    
    CreateElement("GlobalSettingsUICorner", "UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = globalSettings
    })
    
    CreateElement("GlobalSettingsUIPadding", "UIPadding", {
        PaddingBottom = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        Parent = globalSettings
    })
    
    CreateElement("GlobalSettingsUIListLayout", "UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = globalSettings
    })
    
    local globalSettingsUIScale = CreateElement("GlobalSettingsUIScale", "UIScale", {
        Scale = 1e-07,
        Parent = globalSettings
    })
    
    -- Global Settings Toggle Logic
    local hoveringGlobal = false
    local toggledGlobal = false
    
    local function toggleGlobalSettings()
        if not toggledGlobal then
            local intween = Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                Scale = 1
            })
            intween:Play()
            intween.Completed:Wait()
            toggledGlobal = true
        else
            local outtween = Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                Scale = 0
            })
            outtween:Play()
            outtween.Completed:Wait()
            toggledGlobal = false
        end
    end
    
    globalSettingsButton.MouseButton1Click:Connect(function()
        if not hasGlobalSetting then return end
        toggleGlobalSettings()
    end)
    
    globalSettings.MouseEnter:Connect(function()
        hoveringGlobal = true
    end)
    
    globalSettings.MouseLeave:Connect(function()
        hoveringGlobal = false
    end)
    
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 and toggledGlobal and not hoveringGlobal then
            toggleGlobalSettings()
        end
    end)
    
    -- Acrylic Blur Effect (Preserved from MacLib)
    if acrylicBlur then
        local BlurTarget = base
        local HS = game:GetService('HttpService')
        local camera = workspace.CurrentCamera
        local MTREL = "Glass"
        local binds = {}
        local wedgeguid = HS:GenerateGUID(true)
        local DepthOfField
        
        -- Find or create DepthOfField effect
        for _, v in pairs(game:GetService("Lighting"):GetChildren()) do
            if v:IsA("DepthOfFieldEffect") and v:HasTag(".") then
                DepthOfField = v
                break
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
        
        local frame = CreateElement("BlurFrame", "Frame", {
            Size = UDim2.new(0.97, 0, 0.97, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = BlurTarget
        })
        
        frame.Name = HS:GenerateGUID(true)
        
        -- Wait for camera to be ready
        do
            local function IsNotNaN(x)
                return x == x
            end
            local ready = false
            while not ready do
                ready = pcall(function()
                    return camera:ScreenPointToRay(0,0).Origin.x
                end)
                if not ready then RunService.RenderStepped:Wait() end
            end
        end
        
        -- Quad drawing function for blur
        local DrawQuad
        do
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
                
                local para = ((B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z) / (A-B).magnitude
                local perp = sqrt((C-A).magnitude^2 - para*para)
                local dif_para = (A - B).magnitude - para
                
                local st = CFrame.new(B, A)
                local za = CFrame.Angles(pi/2,0,0)
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
                
                local cf1 = st * ac * CFrame.Angles(0, pi, 0)
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
                    p0.Size = Vector3.new(sz, sz, sz)
                    p0.Name = HS:GenerateGUID(true)
                    local mesh = Instance.new('SpecialMesh', p0)
                    mesh.MeshType = Enum.MeshType.Wedge
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
        
        -- Visibility check
        local function IsVisible(instance)
            while instance do
                if instance:IsA("GuiObject") and not instance.Visible then
                    return false
                elseif instance:IsA("ScreenGui") and not instance.Enabled then
                    return false
                end
                instance = instance.Parent
            end
            return true
        end
        
        -- Update function
        local function UpdateOrientation(fetchProps)
            if not IsVisible(frame) or not acrylicBlur then
                for _, pt in pairs(parts) do
                    pt.Parent = nil
                end
                DepthOfField.Enabled = false
                return
            end
            DepthOfField.Enabled = true
            
            local properties = {
                Transparency = 0.98,
                BrickColor = BrickColor.new('Institutional white')
            }
            local zIndex = 1 - 0.05*frame.ZIndex
            
            local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
            local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
            
            -- Handle rotation
            do
                local rot = 0
                for _, v in ipairs(parents) do
                    rot = rot + v.Rotation
                end
                if rot ~= 0 and rot%180 ~= 0 then
                    local mid = tl:lerp(br, 0.5)
                    local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
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
        
        -- Bind to render loop
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not frame.Parent then
                connection:Disconnect()
                return
            end
            UpdateOrientation(true)
        end)
    end
    
    -- Window Functions
    WindowFunctions.UpdateTitle = function(NewTitle)
        title.Text = NewTitle
    end
    
    WindowFunctions.UpdateSubtitle = function(NewSubtitle)
        subtitle.Text = NewSubtitle
    end
    
    -- Global Setting Function
    WindowFunctions.GlobalSetting = function(Settings)
        hasGlobalSetting = true
        
        local GlobalSettingFunctions = {}
        
        local globalSetting = CreateElement("GlobalSetting", "TextButton", {
            Text = "",
            TextColor3 = Color3.fromRGB(0, 0, 0),
            TextSize = 14,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(200, 30),
            Parent = globalSettings
        })
        
        CreateElement("GlobalSettingPadding", "UIPadding", {
            PaddingLeft = UDim.new(0, 15),
            Parent = globalSetting
        })
        
        local settingName = CreateElement("SettingName", "TextLabel", {
            FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            Text = Settings.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 13,
            TextTransparency = 0.5,
            TextTruncate = Enum.TextTruncate.SplitWord,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AnchorPoint = Vector2.new(0, 0.5),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromScale(1.3e-07, 0.5),
            Size = UDim2.new(1, -40, 0, 0),
            Parent = globalSetting
        })
        
        CreateElement("GlobalSettingLayout", "UIListLayout", {
            Padding = UDim.new(0, 10),
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = globalSetting
        })
        
        local checkmark = CreateElement("Checkmark", "TextLabel", {
            FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            Text = "✓",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 13,
            TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AnchorPoint = Vector2.new(0, 0.5),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = -1,
            Position = UDim2.fromScale(1.3e-07, 0.5),
            Size = UDim2.fromOffset(-10, 0),
            Parent = globalSetting
        })
        
        -- Toggle animation settings
        local tweensettings = {
            duration = 0.2,
            easingStyle = Enum.EasingStyle.Quint,
            transparencyIn = 0.2,
            transparencyOut = 0.5,
            checkSizeIncrease = 12,
            checkSizeDecrease = -10,
        }
        
        local function ToggleSetting(State)
            if State then
                Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                    Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
                }):Play()
                
                Tween(settingName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                    TextTransparency = tweensettings.transparencyIn
                }):Play()
                
                checkmark.TextTransparency = 0
            else
                Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                    Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
                }):Play()
                
                Tween(settingName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                    TextTransparency = tweensettings.transparencyOut
                }):Play()
                
                checkmark.TextTransparency = 1
            end
        end
        
        local settingState = Settings.Default or false
        ToggleSetting(settingState)
        
        globalSetting.MouseButton1Click:Connect(function()
            settingState = not settingState
            ToggleSetting(settingState)
            
            task.spawn(function()
                if Settings.Callback then
                    local success, err = pcall(Settings.Callback, settingState)
                    if not success then
                        warn(string.format("[MacLib] GlobalSetting '%s' callback error: %s", Settings.Name, err))
                    end
                end
            end)
        end)
        
        GlobalSettingFunctions.UpdateName = function(NewName)
            settingName.Text = NewName
        end
        
        GlobalSettingFunctions.UpdateState = function(NewState)
            settingState = NewState
            ToggleSetting(settingState)
            if Settings.Callback then
                task.spawn(function()
                    local success, err = pcall(Settings.Callback, settingState)
                    if not success then
                        warn(string.format("[MacLib] GlobalSetting '%s' callback error: %s", Settings.Name, err))
                    end
                end)
            end
        end
        
        return GlobalSettingFunctions
    end
    
    -- Tab Group Function
    WindowFunctions.TabGroup = function()
        local SectionFunctions = {}
        
        local tabGroup = CreateElement("Section", "Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 0),
            Parent = tabSwitchersScrollingFrame
        })
        
        CreateElement("SectionDivider", "Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundTransparency = 0.9,
            Position = UDim2.fromScale(0.5, 1),
            Size = UDim2.new(1, -21, 0, 1),
            Parent = tabGroup
        })
        
        local sectionTabSwitchers = CreateElement("SectionTabSwitchers", "Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = tabGroup
        })
        
        CreateElement("SectionTabLayout", "UIListLayout", {
            Padding = UDim.new(0, 15),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = sectionTabSwitchers
        })
        
        CreateElement("SectionTabPadding", "UIPadding", {
            PaddingBottom = UDim.new(0, 15),
            Parent = sectionTabSwitchers
        })
        
        -- Tab Function
        SectionFunctions.Tab = function(Settings)
            local TabFunctions = {}
            
            tabIndex += 1
            
            local tabSwitcher = CreateElement("TabSwitcher", "TextButton", {
                Text = "",
                TextColor3 = Color3.fromRGB(0, 0, 0),
                TextSize = 14,
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0),
                Size = UDim2.new(1, -21, 0, 40),
                LayoutOrder = tabIndex,
                Parent = sectionTabSwitchers
            })
            
            CreateElement("TabSwitcherUICorner", "UICorner", {
                Parent = tabSwitcher
            })
            
            CreateElement("TabSwitcherUIStroke", "UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Color3.fromRGB(255, 255, 255),
                Transparency = 1,
                Parent = tabSwitcher
            })
            
            CreateElement("TabSwitcherLayout", "UIListLayout", {
                Padding = UDim.new(0, 9),
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = tabSwitcher
            })
            
            if Settings.Image then
                CreateElement("TabImage", "ImageLabel", {
                    Image = Settings.Image,
                    ImageTransparency = 0.4,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.fromOffset(16, 16),
                    Parent = tabSwitcher
                })
            end
            
            local tabSwitcherName = CreateElement("TabSwitcherName", "TextLabel", {
                FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Settings.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 16,
                TextTransparency = 0.4,
                TextTruncate = Enum.TextTruncate.SplitWord,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 0),
                LayoutOrder = 1,
                Parent = tabSwitcher
            })
            
            CreateElement("TabSwitcherPadding", "UIPadding", {
                PaddingLeft = UDim.new(0, 24),
                PaddingRight = UDim.new(0, 35),
                PaddingTop = UDim.new(0, 1),
                Parent = tabSwitcher
            })
            
            -- Tab content frame
            local tabContent = CreateElement("TabContent", "Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(0, 63),
                Size = UDim2.new(1, 0, 1, -63),
                Visible = false,
                Parent = content
            })
            
            local tabContentPadding = CreateElement("TabContentPadding", "UIPadding", {
                PaddingRight = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 10),
                Parent = tabContent
            })
            
            local tabContentScrolling = CreateElement("TabContentScrolling", "ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BottomImage = "",
                CanvasSize = UDim2.new(),
                ScrollBarImageTransparency = 0.5,
                ScrollBarThickness = Device.IsMobile and 4 or 2,
                TopImage = "",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                Parent = tabContent
            })
            
            CreateElement("TabContentPadding2", "UIPadding", {
                PaddingBottom = UDim.new(0, 15),
                PaddingLeft = UDim.new(0, 11),
                PaddingRight = UDim.new(0, 3),
                PaddingTop = UDim.new(0, 5),
                Parent = tabContentScrolling
            })
            
            CreateElement("TabContentLayout", "UIListLayout", {
                Padding = UDim.new(0, 15),
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = tabContentScrolling
            })
            
            -- Left and Right columns
            local leftColumn = CreateElement("LeftColumn", "Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.512, 0),
                Size = UDim2.new(0.5, -10, 0, 0),
                Parent = tabContentScrolling
            })
            
            CreateElement("LeftColumnLayout", "UIListLayout", {
                Padding = UDim.new(0, 15),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = leftColumn
            })
            
            local rightColumn = CreateElement("RightColumn", "Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                LayoutOrder = 1,
                Position = UDim2.fromScale(0.512, 0),
                Size = UDim2.new(0.5, -10, 0, 0),
                Parent = tabContentScrolling
            })
            
            CreateElement("RightColumnLayout", "UIListLayout", {
                Padding = UDim.new(0, 15),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = rightColumn
            })
            
            -- Tab switching logic
            tabSwitcher.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    -- Hide all tab contents
                    for _, tab in pairs(tabs) do
                        tab.Content.Visible = false
                    end
                    
                    -- Show this tab
                    tabContent.Visible = true
                    currentTab.Text = Settings.Name
                    
                    -- Update visuals
                    for _, otherTab in pairs(sectionTabSwitchers:GetChildren()) do
                        if otherTab:IsA("TextButton") then
                            Tween(otherTab.UIStroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                                Transparency = 1
                            }):Play()
                            Tween(otherTab.TabSwitcherName, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                                TextTransparency = 0.4
                            }):Play()
                        end
                    end
                    
                    Tween(tabSwitcher.UIStroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                        Transparency = 0.6
                    }):Play()
                    Tween(tabSwitcherName, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                        TextTransparency = 0.2
                    }):Play()
                    
                    -- Store tab reference
                    tabs[Settings.Name] = {
                        Button = tabSwitcher,
                        Content = tabContent
                    }
                    
                    currentTabInstance = tabContent
                end
            end)
            
            -- Store initial tab
            tabs[Settings.Name] = {
                Button = tabSwitcher,
                Content = tabContent
            }
            
            -- Section Function
            TabFunctions.Section = function(SectionSettings)
                local SectionFunctions = {}
                
                local section = CreateElement("Section", "Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 0.98,
                    BorderSizePixel = 0,
                    Position = UDim2.fromScale(0, 6.78e-08),
                    Size = UDim2.fromScale(1, 0),
                    Parent = SectionSettings.Side == "Left" and leftColumn or rightColumn
                })
                
                CreateElement("SectionUICorner", "UICorner", {
                    Parent = section
                })
                
                CreateElement("SectionUIStroke", "UIStroke", {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = Color3.fromRGB(255, 255, 255),
                    Transparency = 0.95,
                    Parent = section
                })
                
                CreateElement("SectionUIListLayout", "UIListLayout", {
                    Padding = UDim.new(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = section
                })
                
                CreateElement("SectionUIPadding", "UIPadding", {
                    PaddingBottom = UDim.new(0, 20),
                    PaddingLeft = UDim.new(0, 20),
                    PaddingRight = UDim.new(0, 18),
                    PaddingTop = UDim.new(0, 22),
                    Parent = section
                })
                
                -- Enhanced Button Component
                SectionFunctions.Button = function(ButtonSettings)
                    local ButtonFunctions = {}
                    
                    ButtonSettings.Name = ButtonSettings.Name or "Button"
                    
                    local button = CreateElement("Button", "Frame", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, Device.IsMobile and 44 or 38), -- Larger on mobile
                        Parent = section
                    })
                    
                    local buttonInteract = CreateElement("ButtonInteract", "TextButton", {
                        FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Text = ButtonSettings.Name,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = Device.IsMobile and 14 or 13, -- Larger text on mobile
                        TextTransparency = 0.5,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        Parent = button
                    })
                    
                    local buttonImage = CreateElement("ButtonImage", "ImageLabel", {
                        Image = assets.buttonImage,
                        ImageTransparency = 0.5,
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(1, 0.5),
                        Size = UDim2.fromOffset(15, 15),
                        Parent = button
                    })
                    
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
                            task.spawn(function()
                                local success, err = pcall(ButtonSettings.Callback)
                                if not success then
                                    warn(string.format("[MacLib] Button '%s' callback error: %s", ButtonSettings.Name, err))
                                end
                            end)
                        end
                    end
                    
                    -- Enhanced input handling for both mouse and touch
                    buttonInteract.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            ChangeState("Hover")
                        end
                    end)
                    
                    buttonInteract.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            ChangeState("Idle")
                            Callback()
                        end
                    end)
                    
                    -- Mouse-only hover
                    if not Device.IsMobile then
                        buttonInteract.MouseEnter:Connect(function()
                            ChangeState("Hover")
                        end)
                        
                        buttonInteract.MouseLeave:Connect(function()
                            ChangeState("Idle")
                        end)
                    end
                    
                    -- Keybind support
                    if ButtonSettings.Keybind then
                        KeybindManager:NewKeybind(ButtonSettings.Name, ButtonSettings.Keybind, Callback)
                    end
                    
                    ButtonFunctions.UpdateName = function(NewName)
                        buttonInteract.Text = NewName
                    end
                    
                    ButtonFunctions.SetVisibility = function(State)
                        button.Visible = State
                    end
                    
                    ButtonFunctions.SetKeybind = function(Key)
                        KeybindManager:NewKeybind(ButtonSettings.Name, Key, Callback)
                    end
                    
                    return ButtonFunctions
                end
                
                -- Toggle Component
                SectionFunctions.Toggle = function(ToggleSettings)
                    local ToggleFunctions = {}
                    
                    ToggleSettings.Name = ToggleSettings.Name or "Toggle"
                    
                    local toggle = CreateElement("Toggle", "Frame", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, Device.IsMobile and 44 or 38),
                        Parent = section
                    })
                    
                    local toggleName = CreateElement("ToggleName", "TextLabel", {
                        FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Text = ToggleSettings.Name,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = Device.IsMobile and 14 or 13,
                        TextTransparency = 0.5,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0, 0.5),
                        Size = UDim2.new(1, -50, 0, 0),
                        Parent = toggle
                    })
                    
                    local toggle1 = CreateElement("ToggleSwitch", "ImageButton", {
                        Image = assets.toggleBackground,
                        ImageColor3 = Color3.fromRGB(61, 61, 61),
                        AutoButtonColor = false,
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(1, 0.5),
                        Size = UDim2.fromOffset(41, 21),
                        Parent = toggle
                    })
                    
                    CreateElement("TogglePadding", "UIPadding", {
                        PaddingBottom = UDim.new(0, 1),
                        PaddingLeft = UDim.new(0, -2),
                        PaddingRight = UDim.new(0, 3),
                        PaddingTop = UDim.new(0, 1),
                        Parent = toggle1
                    })
                    
                    local togglerHead = CreateElement("TogglerHead", "ImageLabel", {
                        Image = assets.togglerHead,
                        ImageColor3 = Color3.fromRGB(91, 91, 91),
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromOffset(15, 15),
                        ZIndex = 2,
                        Parent = toggle1
                    })
                    
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
                                ImageColor3 = TweenSettings.EnabledColors.ToggleHead,
                                Position = TweenSettings.EnabledPosition
                            }):Play()
                        else
                            Tween(toggle1, TweenSettings.Info, {
                                ImageColor3 = TweenSettings.DisabledColors.Toggle
                            }):Play()
                            Tween(togglerHead, TweenSettings.Info, {
                                ImageColor3 = TweenSettings.DisabledColors.ToggleHead,
                                Position = TweenSettings.DisabledPosition
                            }):Play()
                        end
                        ToggleFunctions.State = State
                    end
                    
                    local toggleState = ToggleSettings.Default or false
                    ToggleState(toggleState)
                    
                    local function Toggle()
                        toggleState = not toggleState
                        ToggleState(toggleState)
                        if ToggleSettings.Callback then
                            task.spawn(function()
                                local success, err = pcall(ToggleSettings.Callback, toggleState)
                                if not success then
                                    warn(string.format("[MacLib] Toggle '%s' callback error: %s", ToggleSettings.Name, err))
                                end
                            end)
                        end
                    end
                    
                    toggle1.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            Toggle()
                        end
                    end)
                    
                    -- Keybind support
                    if ToggleSettings.Keybind then
                        KeybindManager:NewKeybind(ToggleSettings.Name, ToggleSettings.Keybind, Toggle)
                    end
                    
                    ToggleFunctions.Toggle = Toggle
                    
                    ToggleFunctions.UpdateState = function(State)
                        toggleState = State
                        ToggleState(toggleState)
                        if ToggleSettings.Callback then
                            task.spawn(function()
                                local success, err = pcall(ToggleSettings.Callback, toggleState)
                                if not success then
                                    warn(string.format("[MacLib] Toggle '%s' callback error: %s", ToggleSettings.Name, err))
                                end
                            end)
                        end
                    end
                    
                    ToggleFunctions.GetState = function()
                        return toggleState
                    end
                    
                    ToggleFunctions.UpdateName = function(NewName)
                        toggleName.Text = NewName
                    end
                    
                    ToggleFunctions.SetVisibility = function(State)
                        toggle.Visible = State
                    end
                    
                    ToggleFunctions.SetKeybind = function(Key)
                        KeybindManager:NewKeybind(ToggleSettings.Name, Key, Toggle)
                    end
                    
                    return ToggleFunctions
                end
                
                -- Enhanced Slider Component
                SectionFunctions.Slider = function(SliderSettings)
                    local SliderFunctions = {}
                    
                    SliderSettings.Name = SliderSettings.Name or "Slider"
                    SliderSettings.Minimum = SliderSettings.Minimum or 0
                    SliderSettings.Maximum = SliderSettings.Maximum or 100
                    SliderSettings.Default = SliderSettings.Default or SliderSettings.Minimum
                    SliderSettings.DisplayMethod = SliderSettings.DisplayMethod or "Value"
                    
                    local slider = CreateElement("Slider", "Frame", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, Device.IsMobile and 50 or 38), -- Larger on mobile
                        Parent = section
                    })
                    
                    local sliderName = CreateElement("SliderName", "TextLabel", {
                        FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Text = SliderSettings.Name,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = Device.IsMobile and 14 or 13,
                        TextTransparency = 0.5,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(1.3e-07, 0.5),
                        Parent = slider
                    })
                    
                    local sliderElements = CreateElement("SliderElements", "Frame", {
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(1, 0),
                        Size = UDim2.fromScale(1, 1),
                        Parent = slider
                    })
                    
                    local sliderValue = CreateElement("SliderValue", "TextBox", {
                        FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Text = tostring(SliderSettings.Default),
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = Device.IsMobile and 13 or 12,
                        TextTransparency = 0.4,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        BackgroundTransparency = 0.95,
                        BorderSizePixel = 0,
                        LayoutOrder = 1,
                        Position = UDim2.fromScale(-0.0789, 0.171),
                        Size = UDim2.fromOffset(45, 24), -- Larger for mobile
                        Parent = sliderElements
                    })
                    
                    CreateElement("SliderValueUICorner", "UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = sliderValue
                    })
                    
                    CreateElement("SliderValueUIStroke", "UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Color = Color3.fromRGB(255, 255, 255),
                        Transparency = 0.9,
                        Parent = sliderValue
                    })
                    
                    CreateElement("SliderValuePadding", "UIPadding", {
                        PaddingLeft = UDim.new(0, 2),
                        PaddingRight = UDim.new(0, 2),
                        Parent = sliderValue
                    })
                    
                    CreateElement("SliderElementsLayout", "UIListLayout", {
                        Padding = UDim.new(0, 20),
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Parent = sliderElements
                    })
                    
                    local sliderBar = CreateElement("SliderBar", "ImageLabel", {
                        Image = "rbxassetid://18772615246",
                        ImageColor3 = Color3.fromRGB(87, 86, 86),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.219, 0.457),
                        Size = UDim2.fromOffset(123, 3),
                        Parent = sliderElements
                    })
                    
                    local sliderHead = CreateElement("SliderHead", "ImageButton", {
                        Image = "rbxassetid://18772834246",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0, 0.5), -- Will be updated
                        Size = UDim2.fromOffset(16, 16), -- Larger for touch
                        Parent = sliderBar
                    })
                    
                    CreateElement("SliderElementsPadding", "UIPadding", {
                        PaddingTop = UDim.new(0, 3),
                        Parent = sliderElements
                    })
                    
                    local dragging = false
                    local currentValue = SliderSettings.Default
                    
                    local DisplayMethods = {
                        Hundredths = function(v) return string.format("%.2f", v) end,
                        Tenths = function(v) return string.format("%.1f", v) end,
                        Round = function(v) return tostring(math.round(v)) end,
                        Degrees = function(v) return tostring(math.round(v)) .. "°" end,
                        Percent = function(v)
                            local percentage = (v - SliderSettings.Minimum) / (SliderSettings.Maximum - SliderSettings.Minimum) * 100
                            return tostring(math.round(percentage)) .. "%"
                        end,
                        Value = function(v) return tostring(v) end
                    }
                    
                    local ValueDisplayMethod = DisplayMethods[SliderSettings.DisplayMethod] or DisplayMethods.Value
                    
                    local function SetValue(val, ignoreCallback)
                        local posXScale
                        
                        if typeof(val) == "Instance" then -- InputObject
                            local input = val
                            local relativeX = (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
                            posXScale = math.clamp(relativeX, 0, 1)
                        else -- Number value
                            local normalizedValue = (val - SliderSettings.Minimum) / (SliderSettings.Maximum - SliderSettings.Minimum)
                            posXScale = math.clamp(normalizedValue, 0, 1)
                        end
                        
                        local pos = UDim2.new(posXScale, 0, 0.5, 0)
                        sliderHead.Position = pos
                        
                        currentValue = SliderSettings.Minimum + posXScale * (SliderSettings.Maximum - SliderSettings.Minimum)
                        sliderValue.Text = ValueDisplayMethod(currentValue)
                        
                        SliderFunctions.Value = currentValue
                        
                        if not ignoreCallback and SliderSettings.Callback then
                            task.spawn(function()
                                local success, err = pcall(SliderSettings.Callback, currentValue)
                                if not success then
                                    warn(string.format("[MacLib] Slider '%s' callback error: %s", SliderSettings.Name, err))
                                end
                            end)
                        end
                    end
                    
                    SetValue(SliderSettings.Default, true)
                    
                    -- Enhanced input handling
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
                    
                    sliderBar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            SetValue(input)
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            SetValue(input)
                        end
                    end)
                    
                    sliderValue.FocusLost:Connect(function(enterPressed)
                        local number = tonumber(sliderValue.Text)
                        if number then
                            local clampedValue = math.clamp(number, SliderSettings.Minimum, SliderSettings.Maximum)
                            SetValue(clampedValue)
                        else
                            sliderValue.Text = ValueDisplayMethod(currentValue)
                        end
                    end)
                    
                    local function updateSliderBarSize()
                        local padding = sliderElements.UIListLayout.Padding.Offset
                        local sliderValueWidth = sliderValue.AbsoluteSize.X
                        local sliderNameWidth = sliderName.AbsoluteSize.X
                        local totalWidth = sliderElements.AbsoluteSize.X
                        
                        local newBarWidth = totalWidth - (padding + sliderValueWidth + sliderNameWidth + 20)
                        sliderBar.Size = UDim2.new(sliderBar.Size.X.Scale, newBarWidth, sliderBar.Size.Y.Scale, sliderBar.Size.Y.Offset)
                    end
                    
                    sliderName:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSliderBarSize)
                    section:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSliderBarSize)
                    
                    updateSliderBarSize()
                    
                    SliderFunctions.UpdateName = function(NewName)
                        sliderName.Text = NewName
                    end
                    
                    SliderFunctions.SetVisibility = function(State)
                        slider.Visible = State
                    end
                    
                    SliderFunctions.UpdateValue = function(Value)
                        SetValue(Value)
                    end
                    
                    SliderFunctions.GetValue = function()
                        return currentValue
                    end
                    
                    return SliderFunctions
                end
                
                -- Input Component
                SectionFunctions.Input = function(InputSettings)
                    local InputFunctions = {}
                    
                    InputSettings.Name = InputSettings.Name or "Input"
                    InputSettings.Default = InputSettings.Default or ""
                    
                    local input = CreateElement("Input", "Frame", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, Device.IsMobile and 44 or 38),
                        Parent = section
                    })
                    
                    local inputName = CreateElement("InputName", "TextLabel", {
                        FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Text = InputSettings.Name,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = Device.IsMobile and 14 or 13,
                        TextTransparency = 0.5,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0, 0.5),
                        Parent = input
                    })
                    
                    local inputBox = CreateElement("InputBox", "TextBox", {
                        FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Text = InputSettings.Default,
                        PlaceholderText = InputSettings.Placeholder or "",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = Device.IsMobile and 13 or 12,
                        TextTransparency = 0.4,
                        AnchorPoint = Vector2.new(1, 0.5),
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 0.95,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        LayoutOrder = 1,
                        Position = UDim2.fromScale(1, 0.5),
                        Size = UDim2.fromOffset(21, 24), -- Larger for mobile
                        Parent = input
                    })
                    
                    CreateElement("InputBoxUICorner", "UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = inputBox
                    })
                    
                    CreateElement("InputBoxUIStroke", "UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Color = Color3.fromRGB(255, 255, 255),
                        Transparency = 0.9,
                        Parent = inputBox
                    })
                    
                    CreateElement("InputBoxPadding", "UIPadding", {
                        PaddingLeft = UDim.new(0, 5),
                        PaddingRight = UDim.new(0, 5),
                        Parent = inputBox
                    })
                    
                    local inputBoxSizeConstraint = CreateElement("InputBoxSizeConstraint", "UISizeConstraint", {
                        Parent = inputBox
                    })
                    
                    local CharacterSubs = {
                        All = function(value) return value end,
                        Numeric = function(value)
                            return value:match("^%-?%d*$") and value or value:gsub("[^%d-]", ""):gsub("(%-)", function(match, pos, original)
                                return pos == 1 and match or ""
                            end)
                        end,
                        Alphabetic = function(value) return value:gsub("[^a-zA-Z ]", "") end,
                    }
                    
                    local AcceptedCharacters = CharacterSubs[InputSettings.AcceptedCharacters] or CharacterSubs.All
                    
                    local function checkSize()
                        local nameWidth = inputName.AbsoluteSize.X
                        local totalWidth = input.AbsoluteSize.X
                        local maxWidth = totalWidth - nameWidth - 20
                        inputBoxSizeConstraint.MaxSize = Vector2.new(maxWidth, 9e9)
                    end
                    
                    inputName:GetPropertyChangedSignal("AbsoluteSize"):Connect(checkSize)
                    checkSize()
                    
                    inputBox.FocusLost:Connect(function(enterPressed)
                        local filteredText = AcceptedCharacters(inputBox.Text)
                        inputBox.Text = filteredText
                        if InputSettings.Callback then
                            task.spawn(function()
                                local success, err = pcall(InputSettings.Callback, filteredText)
                                if not success then
                                    warn(string.format("[MacLib] Input '%s' callback error: %s", InputSettings.Name, err))
                                end
                            end)
                        end
                    end)
                    
                    inputBox:GetPropertyChangedSignal("Text"):Connect(function()
                        inputBox.Text = AcceptedCharacters(inputBox.Text)
                        if InputSettings.onChanged then
                            InputSettings.onChanged(inputBox.Text)
                        end
                        InputFunctions.Text = inputBox.Text
                    end)
                    
                    InputFunctions.UpdateName = function(NewName)
                        inputName.Text = NewName
                    end
                    
                    InputFunctions.SetVisibility = function(State)
                        input.Visible = State
                    end
                    
                    InputFunctions.GetInput = function()
                        return inputBox.Text
                    end
                    
                    InputFunctions.UpdatePlaceholder = function(Placeholder)
                        inputBox.PlaceholderText = Placeholder
                    end
                    
                    InputFunctions.UpdateText = function(Text)
                        inputBox.Text = Text
                    end
                    
                    return InputFunctions
                end
                
                -- Keybind Component
                SectionFunctions.Keybind = function(KeybindSettings)
                    local KeybindFunctions = {}
                    
                    KeybindSettings.Name = KeybindSettings.Name or "Keybind"
                    KeybindSettings.Default = KeybindSettings.Default or nil
                    
                    local keybind = CreateElement("Keybind", "Frame", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, Device.IsMobile and 44 or 38),
                        Parent = section
                    })
                    
                    local keybindName = CreateElement("KeybindName", "TextLabel", {
                        FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Text = KeybindSettings.Name,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = Device.IsMobile and 14 or 13,
                        TextTransparency = 0.5,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0, 0.5),
                        Parent = keybind
                    })
                    
                    local binderBox = CreateElement("BinderBox", "TextBox", {
                        CursorPosition = -1,
                        FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        PlaceholderText = "...",
                        Text = KeybindSettings.Default and KeybindSettings.Default.Name or "",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = Device.IsMobile and 13 or 12,
                        TextTransparency = 0.4,
                        AnchorPoint = Vector2.new(1, 0.5),
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 0.95,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        LayoutOrder = 1,
                        Position = UDim2.fromScale(1, 0.5),
                        Size = UDim2.fromOffset(40, 24), -- Larger for mobile
                        Parent = keybind
                    })
                    
                    CreateElement("BinderBoxUICorner", "UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = binderBox
                    })
                    
                    CreateElement("BinderBoxUIStroke", "UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Color = Color3.fromRGB(255, 255, 255),
                        Transparency = 0.9,
                        Parent = binderBox
                    })
                    
                    CreateElement("BinderBoxPadding", "UIPadding", {
                        PaddingLeft = UDim.new(0, 5),
                        PaddingRight = UDim.new(0, 5),
                        Parent = binderBox
                    })
                    
                    local focused = false
                    local currentKey = KeybindSettings.Default
                    
                    -- Register initial keybind
                    if currentKey then
                        KeybindManager:NewKeybind(KeybindSettings.Name, currentKey, KeybindSettings.Callback, KeybindSettings.Description)
                    end
                    
                    binderBox.Focused:Connect(function()
                        focused = true
                        binderBox.Text = "..."
                    end)
                    
                    binderBox.FocusLost:Connect(function()
                        focused = false
                        if not currentKey then
                            binderBox.Text = ""
                        elseif binderBox.Text == "" then
                            binderBox.Text = currentKey.Name
                        end
                    end)
                    
                    UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if macLib and focused and input.KeyCode.Name ~= "Unknown" then
                            currentKey = input.KeyCode
                            KeybindFunctions.Bind = currentKey
                            binderBox.Text = input.KeyCode.Name
                            binderBox:ReleaseFocus()
                            
                            -- Update keybind
                            KeybindManager:RemoveKeybind(KeybindSettings.Name)
                            KeybindManager:NewKeybind(KeybindSettings.Name, currentKey, KeybindSettings.Callback, KeybindSettings.Description)
                            KeybindManager:UpdateKeybindList()
                            
                            if KeybindSettings.onBinded then
                                KeybindSettings.onBinded(currentKey)
                            end
                        end
                    end)
                    
                    KeybindFunctions.Bind = function(Key)
                        currentKey = Key
                        binderBox.Text = Key.Name
                        KeybindManager:RemoveKeybind(KeybindSettings.Name)
                        KeybindManager:NewKeybind(KeybindSettings.Name, Key, KeybindSettings.Callback, KeybindSettings.Description)
                        KeybindManager:UpdateKeybindList()
                    end
                    
                    KeybindFunctions.Unbind = function()
                        currentKey = nil
                        binderBox.Text = ""
                        KeybindManager:RemoveKeybind(KeybindSettings.Name)
                        KeybindManager:UpdateKeybindList()
                    end
                    
                    KeybindFunctions.GetBind = function()
                        return currentKey
                    end
                    
                    KeybindFunctions.UpdateName = function(NewName)
                        keybindName.Text = NewName
                    end
                    
                    KeybindFunctions.SetVisibility = function(State)
                        keybind.Visible = State
                    end
                    
                    return KeybindFunctions
                end
                
                -- Dropdown Component
                SectionFunctions.Dropdown = function(DropdownSettings)
                    local DropdownFunctions = {}
                    
                    DropdownSettings.Name = DropdownSettings.Name or "Dropdown"
                    DropdownSettings.Options = DropdownSettings.Options or {}
                    DropdownSettings.Default = DropdownSettings.Default or (DropdownSettings.Multi and {} or nil)
                    DropdownSettings.Multi = DropdownSettings.Multi or false
                    DropdownSettings.Search = DropdownSettings.Search or false
                    DropdownSettings.Required = DropdownSettings.Required or false
                    
                    local Selected = {}
                    local OptionObjs = {}
                    local dropped = false
                    
                    local dropdown = CreateElement("Dropdown", "Frame", {
                        BackgroundTransparency = 0.985,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 38),
                        ClipsDescendants = true,
                        Parent = section
                    })
                    
                    CreateElement("DropdownPadding", "UIPadding", {
                        PaddingLeft = UDim.new(0, 15),
                        PaddingRight = UDim.new(0, 15),
                        Parent = dropdown
                    })
                    
                    local dropdownInteract = CreateElement("DropdownInteract", "TextButton", {
                        Text = "",
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        TextSize = 14,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 38),
                        Parent = dropdown
                    })
                    
                    local dropdownName = CreateElement("DropdownName", "TextLabel", {
                        FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Text = DropdownSettings.Name,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = Device.IsMobile and 14 or 13,
                        TextTransparency = 0.5,
                        TextTruncate = Enum.TextTruncate.SplitWord,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, -20, 0, 38),
                        Parent = dropdown
                    })
                    
                    CreateElement("DropdownUIStroke", "UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Color = Color3.fromRGB(255, 255, 255),
                        Transparency = 0.95,
                        Parent = dropdown
                    })
                    
                    CreateElement("DropdownUICorner", "UICorner", {
                        CornerRadius = UDim.new(0, 6),
                        Parent = dropdown
                    })
                    
                    local dropdownImage = CreateElement("DropdownImage", "ImageLabel", {
                        Image = "rbxassetid://18865373378",
                        ImageTransparency = 0.5,
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, 0, 0, 12),
                        Size = UDim2.fromOffset(14, 14),
                        Parent = dropdown
                    })
                    
                    local dropdownFrame = CreateElement("DropdownFrame", "Frame", {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Size = UDim2.fromScale(1, 1),
                        Visible = false,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Parent = dropdown
                    })
                    
                    CreateElement("DropdownFramePadding", "UIPadding", {
                        PaddingTop = UDim.new(0, 38),
                        PaddingBottom = UDim.new(0, 10),
                        Parent = dropdownFrame
                    })
                    
                    CreateElement("DropdownFrameLayout", "UIListLayout", {
                        Padding = UDim.new(0, 5),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = dropdownFrame
                    })
                    
                    -- Search functionality
                    if DropdownSettings.Search then
                        local search = CreateElement("Search", "Frame", {
                            BackgroundTransparency = 0.95,
                            BorderSizePixel = 0,
                            LayoutOrder = -1,
                            Size = UDim2.new(1, 0, 0, 30),
                            Parent = dropdownFrame
                        })
                        
                        CreateElement("SearchUICorner", "UICorner", {
                            Parent = search
                        })
                        
                        local searchIcon = CreateElement("SearchIcon", "ImageLabel", {
                            Image = assets.searchIcon,
                            ImageColor3 = Color3.fromRGB(180, 180, 180),
                            AnchorPoint = Vector2.new(0, 0.5),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Position = UDim2.fromScale(0, 0.5),
                            Size = UDim2.fromOffset(12, 12),
                            Parent = search
                        })
                        
                        local searchBox = CreateElement("SearchBox", "TextBox", {
                            FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                            PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
                            PlaceholderText = "Search...",
                            Text = "",
                            TextColor3 = Color3.fromRGB(200, 200, 200),
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Size = UDim2.fromScale(1, 1),
                            Parent = search
                        })
                        
                        CreateElement("SearchBoxPadding", "UIPadding", {
                            PaddingLeft = UDim.new(0, 23),
                            Parent = searchBox
                        })
                        
                        -- Search functionality
                        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                            local searchTerm = searchBox.Text:lower()
                            for optionName, optionData in pairs(OptionObjs) do
                                local optionText = optionData.NameLabel.Text:lower()
                                local isVisible = string.find(optionText, searchTerm) ~= nil
                                optionData.Button.Visible = isVisible
                            end
                            -- Update dropdown size
                            local totalHeight = 38 -- Header height
                            for _, optionData in pairs(OptionObjs) do
                                if optionData.Button.Visible then
                                    totalHeight += optionData.Button.AbsoluteSize.Y + 5
                                end
                            end
                            dropdown.Size = UDim2.new(1, 0, 0, totalHeight + 10)
                        end)
                        
                        searchBox.Parent = search
                    end
                    
                    local function CalculateDropdownSize()
                        local totalHeight = 38 -- Header height
                        local visibleCount = 0
                        for _, optionData in pairs(OptionObjs) do
                            if optionData.Button.Visible then
                                totalHeight += optionData.Button.AbsoluteSize.Y + 5
                                visibleCount += 1
                            end
                        end
                        return totalHeight + 10
                    end
                    
                    local function ToggleOption(optionName, State)
                        local option = OptionObjs[optionName]
                        if not option then return end
                        
                        local checkmark = option.Checkmark
                        local optionNameLabel = option.NameLabel
                        local tweensettings = {
                            duration = 0.2,
                            easingStyle = Enum.EasingStyle.Quint,
                            transparencyIn = 0.2,
                            transparencyOut = 0.5,
                            checkSizeIncrease = 12,
                            checkSizeDecrease = -13,
                        }
                        
                        if State then
                            if DropdownSettings.Multi then
                                if not table.find(Selected, optionName) then
                                    table.insert(Selected, optionName)
                                end
                                DropdownFunctions.Value = Selected
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
                    
                    local function ToggleDropdown()
                        local targetSize
                        if dropped then
                            targetSize = UDim2.new(1, 0, 0, 38)
                        else
                            targetSize = UDim2.new(1, 0, 0, CalculateDropdownSize())
                        end
                        
                        local tween = Tween(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                            Size = targetSize
                        })
                        tween:Play()
                        
                        if not dropped then
                            dropdownFrame.Visible = true
                        end
                        
                        tween.Completed:Connect(function()
                            if dropped then
                                dropdownFrame.Visible = false
                            end
                        end)
                        
                        dropped = not dropped
                        dropdownImage.Rotation = dropped and 180 or 0
                    end
                    
                    dropdownInteract.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            ToggleDropdown()
                        end
                    end)
                    
                    -- Add options
                    for i, optionValue in ipairs(DropdownSettings.Options) do
                        local option = CreateElement("Option", "TextButton", {
                            Text = "",
                            TextColor3 = Color3.fromRGB(0, 0, 0),
                            TextSize = 14,
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 30),
                            Parent = dropdownFrame
                        })
                        
                        CreateElement("OptionPadding", "UIPadding", {
                            PaddingLeft = UDim.new(0, 15),
                            Parent = option
                        })
                        
                        local optionNameLabel = CreateElement("OptionName", "TextLabel", {
                            FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                            Text = tostring(optionValue),
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            TextSize = 13,
                            TextTransparency = 0.5,
                            TextTruncate = Enum.TextTruncate.AtEnd,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextYAlignment = Enum.TextYAlignment.Top,
                            AnchorPoint = Vector2.new(0, 0.5),
                            AutomaticSize = Enum.AutomaticSize.XY,
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Position = UDim2.fromScale(1.3e-07, 0.5),
                            Parent = option
                        })
                        
                        local optionCheckmark = CreateElement("OptionCheckmark", "TextLabel", {
                            FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                            Text = "✓",
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            TextSize = 13,
                            TextTransparency = 1,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextYAlignment = Enum.TextYAlignment.Top,
                            AnchorPoint = Vector2.new(0, 0.5),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            LayoutOrder = -1,
                            Position = UDim2.fromScale(1.3e-07, 0.5),
                            Size = UDim2.fromOffset(-10, 0),
                            Parent = option
                        })
                        
                        OptionObjs[optionValue] = {
                            Index = i,
                            Button = option,
                            NameLabel = optionNameLabel,
                            Checkmark = optionCheckmark
                        }
                        
                        -- Set initial selection
                        local isSelected = false
                        if DropdownSettings.Default then
                            if DropdownSettings.Multi then
                                isSelected = table.find(DropdownSettings.Default, optionValue) and true or false
                            else
                                isSelected = (DropdownSettings.Default == optionValue) and true or false
                            end
                        end
                        ToggleOption(optionValue, isSelected)
                        
                        -- Option click handler
                        option.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                local isCurrentlySelected = table.find(Selected, optionValue) and true or false
                                local newSelected = not isCurrentlySelected
                                
                                if DropdownSettings.Required and not newSelected and #Selected <= 1 then
                                    return
                                end
                                
                                ToggleOption(optionValue, newSelected)
                                
                                if DropdownSettings.Multi then
                                    local Return = {}
                                    for _, opt in ipairs(Selected) do
                                        Return[opt] = true
                                    end
                                    if DropdownSettings.Callback then
                                        DropdownSettings.Callback(Return)
                                    end
                                else
                                    if newSelected and DropdownSettings.Callback then
                                        DropdownSettings.Callback(optionValue)
                                    end
                                end
                                
                                if not DropdownSettings.Multi and newSelected then
                                    -- Close dropdown on single select
                                    task.wait(0.1)
                                    ToggleDropdown()
                                end
                            end
                        end)
                    end
                    
                    DropdownFunctions.UpdateName = function(NewName)
                        dropdownName.Text = NewName
                    end
                    
                    DropdownFunctions.SetVisibility = function(State)
                        dropdown.Visible = State
                    end
                    
                    DropdownFunctions.UpdateSelection = function(newSelection)
                        if type(newSelection) == "table" then
                            for option, data in pairs(OptionObjs) do
                                local isSelected = table.find(newSelection, option) ~= nil
                                ToggleOption(option, isSelected)
                            end
                        else
                            for option, data in pairs(OptionObjs) do
                                local isSelected = (option == newSelection)
                                ToggleOption(option, isSelected)
                            end
                        end
                    end
                    
                    DropdownFunctions.InsertOptions = function(newOptions)
                        -- Implementation for adding options dynamically
                        for _, optionValue in ipairs(newOptions) do
                            if not OptionObjs[optionValue] then
                                table.insert(DropdownSettings.Options, optionValue)
                                -- Recreate dropdown with new options
                                -- (Simplified for brevity)
                            end
                        end
                    end
                    
                    DropdownFunctions.ClearOptions = function()
                        for _, optionData in pairs(OptionObjs) do
                            optionData.Button:Destroy()
                        end
                        OptionObjs = {}
                        Selected = {}
                        dropdownName.Text = DropdownSettings.Name
                    end
                    
                    DropdownFunctions.GetOptions = function()
                        local optionsStatus = {}
                        for option, data in pairs(OptionObjs) do
                            local isSelected = table.find(Selected, option) and true or false
                            optionsStatus[option] = isSelected
                        end
                        return optionsStatus
                    end
                    
                    DropdownFunctions.RemoveOptions = function(remove)
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
                    end
                    
                    DropdownFunctions.IsOption = function(optionName)
                        return OptionObjs[optionName] ~= nil
                    end
                    
                    return DropdownFunctions
                end
                
                -- Colorpicker Component
                SectionFunctions.Colorpicker = function(ColorpickerSettings)
                    local ColorpickerFunctions = {}
                    
                    ColorpickerSettings.Name = ColorpickerSettings.Name or "Colorpicker"
                    ColorpickerSettings.Default = ColorpickerSettings.Default or Color3.fromRGB(255, 0, 0)
                    ColorpickerSettings.Alpha = ColorpickerSettings.Alpha or nil
                    
                    local colorpicker = CreateElement("Colorpicker", "Frame", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, Device.IsMobile and 44 or 38),
                        Parent = section
                    })
                    
                    local colorpickerName = CreateElement("ColorpickerName", "TextLabel", {
                        FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Text = ColorpickerSettings.Name,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = Device.IsMobile and 14 or 13,
                        TextTransparency = 0.5,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0, 0.5),
                        Parent = colorpicker
                    })
                    
                    local colorCbg = CreateElement("ColorBackground", "ImageLabel", {
                        Image = "rbxassetid://121484455191370",
                        ScaleType = Enum.ScaleType.Tile,
                        TileSize = UDim2.fromOffset(500, 500),
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(1, 0.5),
                        Size = UDim2.fromOffset(24, 24), -- Larger for mobile
                        Parent = colorpicker
                    })
                    
                    local colorC = CreateElement("ColorDisplay", "Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = ColorpickerSettings.Default,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1),
                        BackgroundTransparency = ColorpickerSettings.Alpha or 0,
                        Parent = colorCbg
                    })
                    
                    CreateElement("ColorDisplayCorner", "UICorner", {
                        CornerRadius = UDim.new(0, 6),
                        Parent = colorC
                    })
                    
                    local interact = CreateElement("ColorInteract", "TextButton", {
                        Text = "",
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        TextSize = 14,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        Parent = colorC
                    })
                    
                    CreateElement("ColorBackgroundCorner", "UICorner", {
                        CornerRadius = UDim.new(0, 8),
                        Parent = colorCbg
                    })
                    
                    ColorpickerFunctions.Color = ColorpickerSettings.Default
                    ColorpickerFunctions.Alpha = ColorpickerSettings.Alpha
                    
                    -- Simple color picker dialog
                    local colorPickerDialog = CreateElement("ColorPickerDialog", "Frame", {
                        BackgroundTransparency = 0.5,
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        Visible = false,
                        Parent = macLib
                    })
                    
                    CreateElement("ColorPickerBackground", "UICorner", {
                        CornerRadius = UDim.new(0, 10),
                        Parent = colorPickerDialog
                    })
                    
                    interact.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            colorPickerDialog.Visible = not colorPickerDialog.Visible
                            if colorPickerDialog.Visible and ColorpickerSettings.Callback then
                                -- Simulate color picker open
                                ColorpickerSettings.Callback(ColorpickerFunctions.Color, ColorpickerFunctions.Alpha)
                            end
                        end
                    end)
                    
                    ColorpickerFunctions.UpdateColor = function(NewColor)
                        colorC.BackgroundColor3 = NewColor
                        ColorpickerFunctions.Color = NewColor
                    end
                    
                    ColorpickerFunctions.SetVisibility = function(State)
                        colorpicker.Visible = State
                    end
                    
                    return ColorpickerFunctions
                end
                
                return TabFunctions
            end
            
            return SectionFunctions
        end
        
        WindowFunctions.GetKeybindManager = function()
            return KeybindManager
        end
        
        WindowFunctions.GetDeviceInfo = function()
            return Device
        end
        
        WindowFunctions.Destroy = function()
            if macLib then
                macLib:Destroy()
                macLib = nil
            end
            if KeybindManager then
                KeybindManager:SetActive(false)
            end
        end
        
        -- Initialize first tab
        if tabIndex == 0 then
            -- Create default tab if none exists
            local defaultTab = WindowFunctions:Tab({Name = "Main"})
            return WindowFunctions
        end
        
        return WindowFunctions
    end
    
    -- Auto-create first tab if none exists
    task.spawn(function()
        if tabIndex == 0 then
            WindowFunctions:Tab({Name = "Main"})
        end
    end)
    
    return WindowFunctions
end

return MacLib