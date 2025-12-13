-- MacLib Enhanced - Fixed Device Detection & UI Structure
-- Complete rewrite with proper device detection and guaranteed UI rendering

local MacLib = {}

--// Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

--// CRITICAL: Device Detection MUST run first
local Device = {
    IsMobile = false,
    IsConsole = false,
    IsPC = false,
    Executor = "Unknown",
    HardwareId = nil,
    IsStudio = RunService:IsStudio(),
    Platform = "Unknown",
    Initialized = false
}

-- Correct device detection logic for Roblox
local function DetectDevice()
    -- Detect platform type accurately
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
    -- Mobile detection: Touch enabled AND (gyro OR accelerometer) AND no keyboard
    elseif touchEnabled and (gyroscopeEnabled or accelerometerEnabled) and not keyboardEnabled then
        Device.IsMobile = true
        Device.IsPC = false
        Device.IsConsole = false
        Device.Platform = "Mobile"
    -- PC detection: Has keyboard or mouse
    elseif keyboardEnabled or mouseEnabled then
        Device.IsPC = true
        Device.IsMobile = false
        Device.IsConsole = false
        Device.Platform = "PC"
    else
        -- Fallback based on screen size
        local viewportSize = workspace.CurrentCamera.ViewportSize
        if viewportSize.Y < 600 then
            Device.IsMobile = true
            Device.Platform = "Mobile Fallback"
        else
            Device.IsPC = true
            Device.Platform = "PC Fallback"
        end
    end
    
    -- Executor detection
    if identifyexecutor then
        local success, execName = pcall(identifyexecutor)
        if success then
            Device.Executor = execName or "Unknown"
        end
    end
    
    -- Hardware ID with fallback
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
    
    Device.Initialized = true
    
    -- Debug output
    warn(string.format("[MacLib] Platform: %s | Mobile: %s | PC: %s | Console: %s", 
        Device.Platform, tostring(Device.IsMobile), tostring(Device.IsPC), tostring(Device.IsConsole)))
end

-- Execute detection IMMEDIATELY
DetectDevice()

--// Device-aware UI Sizing - FIXED
local function GetDeviceAdjustedSize()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    
    if Device.IsMobile then
        -- Mobile: Use 90% of screen with minimum touch target sizes
        return UDim2.fromOffset(
            math.floor(math.min(900, viewportSize.X * 0.92)),
            math.floor(math.min(680, viewportSize.Y * 0.88))
        )
    elseif Device.IsConsole then
        -- Console: Larger for TV viewing
        return UDim2.fromOffset(
            math.floor(math.min(950, viewportSize.X * 0.95)),
            math.floor(math.min(720, viewportSize.Y * 0.90))
        )
    else
        -- PC: Original size
        return UDim2.fromOffset(868, 650)
    end
end

--// Assets
local assets = {
    interFont = "rbxassetid://12187365364",
    buttonImage = "rbxassetid://10709791437",
    searchIcon = "rbxassetid://86737463322606"
}

--// Utility Functions
local function Tween(instance, tweeninfo, propertytable)
    return TweenService:Create(instance, tweeninfo, propertytable)
end

--// Keybind Manager
local KeybindManager = {
    Keybinds = {},
    KeybindList = nil,
    Active = true
}

function KeybindManager:NewKeybind(name, key, callback, description)
    if not name or not key or not callback then return nil end
    
    -- Remove existing
    for i, k in ipairs(self.Keybinds) do
        if k.Name == name then
            table.remove(self.Keybinds, i)
            break
        end
    end
    
    local keybind = {
        Name = name,
        Key = key,
        Callback = callback,
        Description = description or name,
        Enabled = true
    }
    
    table.insert(self.Keybinds, keybind)
    return keybind
end

function KeybindManager:RemoveKeybind(name)
    for i, k in ipairs(self.Keybinds) do
        if k.Name == name then
            table.remove(self.Keybinds, i)
            return true
        end
    end
    return false
end

function KeybindManager:UpdateKeybindList()
    if not self.KeybindList then return end
    
    -- Clear existing
    for _, child in pairs(self.KeybindList:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    -- Add header
    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.FontFace = Font.new(assets.interFont, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    header.Text = "Active Keybinds"
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextSize = 13
    header.TextTransparency = 0.2
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 20)
    header.Parent = self.KeybindList
    
    -- Add entries
    local yOffset = 20
    for _, keybind in ipairs(self.Keybinds) do
        if keybind.Key and keybind.Enabled then
            local label = Instance.new("TextLabel")
            label.Name = "KeybindEntry"
            label.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
            label.Text = string.format("[%s] %s", keybind.Key.Name, keybind.Description)
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 11
            label.TextTransparency = 0.6
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 18)
            label.Position = UDim2.fromOffset(0, yOffset)
            label.Parent = self.KeybindList
            
            yOffset = yOffset + 18
        end
    end
    
    self.KeybindList.CanvasSize = UDim2.fromOffset(0, yOffset + 5)
end

--// MAIN WINDOW FUNCTION
function MacLib:Window(Settings)
    Settings = Settings or {}
    Settings.Title = Settings.Title or "MacLib Window"
    Settings.Subtitle = Settings.Subtitle or "Enhanced UI Library"
    Settings.Size = Settings.Size or GetDeviceAdjustedSize() -- Use device size
    
    local WindowFunctions = {}
    local tabs = {}
    local currentTab = nil
    
    -- ScreenGui
    local macLib = Instance.new("ScreenGui")
    macLib.Name = "MacLib"
    macLib.ResetOnSpawn = false
    macLib.DisplayOrder = 100
    macLib.IgnoreGuiInset = true
    macLib.ScreenInsets = Enum.ScreenInsets.None
    macLib.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    macLib.Parent = (Device.IsStudio and Players.LocalPlayer.PlayerGui) or game:GetService("CoreGui")
    
    -- Main Frame
    local base = Instance.new("Frame")
    base.Name = "Base"
    base.AnchorPoint = Vector2.new(0.5, 0.5)
    base.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    base.BackgroundTransparency = 0.05
    base.BorderSizePixel = 0
    base.Position = UDim2.fromScale(0.5, 0.5)
    base.Size = Settings.Size -- Apply device-adjusted size
    base.Parent = macLib
    
    -- CRITICAL: Apply device scale
    local baseUIScale = Instance.new("UIScale")
    baseUIScale.Name = "BaseUIScale"
    baseUIScale.Scale = Device.IsMobile and 1.1 or 1
    baseUIScale.Parent = base
    
    -- Corner
    local baseUICorner = Instance.new("UICorner")
    baseUICorner.CornerRadius = UDim.new(0, 10)
    baseUICorner.Parent = base
    
    -- Stroke
    local baseUIStroke = Instance.new("UIStroke")
    baseUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    baseUIStroke.Color = Color3.fromRGB(255, 255, 255)
    baseUIStroke.Transparency = 0.9
    baseUIStroke.Parent = base
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundTransparency = 1
    sidebar.Size = UDim2.fromScale(0.325, 1)
    sidebar.Parent = base
    
    local divider = Instance.new("Frame")
    divider.AnchorPoint = Vector2.new(1, 0)
    divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider.BackgroundTransparency = 0.9
    divider.Position = UDim2.fromScale(1, 0)
    divider.Size = UDim2.new(0, 1, 1, 0)
    divider.Parent = sidebar
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 60)
    header.Position = UDim2.fromOffset(0, 10)
    header.Parent = sidebar
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    title.Text = Settings.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = Device.IsMobile and 22 or 20
    title.TextTransparency = 0.2
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -30, 0, 0)
    title.Position = UDim2.fromOffset(20, 0)
    title.Parent = header
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    subtitle.Text = Settings.Subtitle
    subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    subtitle.TextSize = Device.IsMobile and 13 or 12
    subtitle.TextTransparency = 0.6
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.BackgroundTransparency = 1
    subtitle.Size = UDim2.new(1, -30, 0, 0)
    subtitle.Position = UDim2.fromOffset(20, 25)
    subtitle.Parent = header
    
    -- Tab Container
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Name = "TabContainer"
    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0
    tabContainer.Position = UDim2.fromOffset(0, 80)
    tabContainer.Size = UDim2.new(1, 0, 1, -187)
    tabContainer.CanvasSize = UDim2.new()
    tabContainer.ScrollBarThickness = Device.IsMobile and 3 or 1
    tabContainer.ScrollBarImageTransparency = 0.8
    tabContainer.Parent = sidebar
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.Padding = UDim.new(0, 10)
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Parent = tabContainer
    
    -- Keybind List
    local keybindList = Instance.new("ScrollingFrame")
    keybindList.Name = "KeybindList"
    keybindList.BackgroundTransparency = 1
    keybindList.BorderSizePixel = 0
    keybindList.Position = UDim2.fromScale(0, 1)
    keybindList.Size = UDim2.new(1, 0, 0, 80)
    keybindList.AnchorPoint = Vector2.new(0, 1)
    keybindList.CanvasSize = UDim2.new()
    keybindList.ScrollBarThickness = 2
    keybindList.Visible = false
    keybindList.Parent = sidebar
    
    KeybindManager.KeybindList = keybindList
    
    local keybindToggle = Instance.new("ImageButton")
    keybindToggle.Name = "KeybindToggle"
    keybindToggle.Image = assets.buttonImage
    keybindToggle.ImageTransparency = 0.5
    keybindToggle.AnchorPoint = Vector2.new(1, 0.5)
    keybindToggle.BackgroundTransparency = 1
    keybindToggle.Position = UDim2.fromScale(0.9, 0.5)
    keybindToggle.Size = UDim2.fromOffset(20, 20)
    keybindToggle.Parent = header
    
    keybindToggle.MouseButton1Click:Connect(function()
        keybindList.Visible = not keybindList.Visible
        if keybindList.Visible then
            KeybindManager:UpdateKeybindList()
        end
    end)
    
    -- User Info
    local userInfo = Instance.new("Frame")
    userInfo.Name = "UserInfo"
    userInfo.AnchorPoint = Vector2.new(0, 1)
    userInfo.BackgroundTransparency = 1
    userInfo.Position = UDim2.fromScale(0, 1)
    userInfo.Size = UDim2.new(1, 0, 0, 107)
    userInfo.Parent = sidebar
    
    local userInfoPadding = Instance.new("UIPadding")
    userInfoPadding.PaddingLeft = UDim.new(0, 20)
    userInfoPadding.PaddingRight = UDim.new(0, 20)
    userInfoPadding.Parent = userInfo
    
    local userInfoLayout = Instance.new("UIListLayout")
    userInfoLayout.FillDirection = Enum.FillDirection.Horizontal
    userInfoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    userInfoLayout.Padding = UDim.new(0, 10)
    userInfoLayout.Parent = userInfo
    
    local userId = Players.LocalPlayer.UserId
    local headshotImage = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size48x48)
    
    local headshot = Instance.new("ImageLabel")
    headshot.Name = "Headshot"
    headshot.BackgroundTransparency = 1
    headshot.Size = Device.IsMobile and UDim2.fromOffset(36, 36) or UDim2.fromOffset(32, 32)
    headshot.Image = headshotImage
    headshot.Parent = userInfo
    
    local headshotCorner = Instance.new("UICorner")
    headshotCorner.CornerRadius = UDim.new(1, 0)
    headshotCorner.Parent = headshot
    
    local names = Instance.new("Frame")
    names.Name = "Names"
    names.BackgroundTransparency = 1
    names.Size = UDim2.new(1, -42, 0, 32)
    names.Parent = userInfo
    
    local namesLayout = Instance.new("UIListLayout")
    namesLayout.Padding = UDim.new(0, 2)
    namesLayout.Parent = names
    
    local displayName = Instance.new("TextLabel")
    displayName.Name = "DisplayName"
    displayName.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    displayName.Text = Players.LocalPlayer.DisplayName
    displayName.TextColor3 = Color3.fromRGB(255, 255, 255)
    displayName.TextSize = 13
    displayName.TextTransparency = 0.2
    displayName.TextXAlignment = Enum.TextXAlignment.Left
    displayName.BackgroundTransparency = 1
    displayName.Size = UDim2.fromScale(1, 0)
    displayName.Parent = names
    
    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    username.Text = "@" .. Players.LocalPlayer.Name
    username.TextColor3 = Color3.fromRGB(255, 255, 255)
    username.TextSize = 12
    username.TextTransparency = 0.5
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.BackgroundTransparency = 1
    username.Size = UDim2.fromScale(1, 0)
    username.Parent = names
    
    -- Content Area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.AnchorPoint = Vector2.new(1, 0)
    content.BackgroundTransparency = 1
    content.Position = UDim2.fromScale(1, 0)
    content.Size = UDim2.fromScale(0.675, 1)
    content.Parent = base
    
    local contentHeader = Instance.new("Frame")
    contentHeader.Name = "ContentHeader"
    contentHeader.BackgroundTransparency = 1
    contentHeader.Size = UDim2.new(1, 0, 0, 63)
    contentHeader.Parent = content
    
    local currentTabLabel = Instance.new("TextLabel")
    currentTabLabel.Name = "CurrentTabLabel"
    currentTabLabel.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    currentTabLabel.Text = "Select a Tab"
    currentTabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    currentTabLabel.TextSize = 15
    currentTabLabel.TextTransparency = 0.4
    currentTabLabel.TextXAlignment = Enum.TextXAlignment.Left
    currentTabLabel.BackgroundTransparency = 1
    currentTabLabel.Position = UDim2.fromOffset(20, 0)
    currentTabLabel.Size = UDim2.new(1, -40, 1, 0)
    currentTabLabel.Parent = contentHeader
    
    -- Dragging
    local dragButton = Instance.new("TextButton")
    dragButton.Name = "DragButton"
    dragButton.Text = ""
    dragButton.BackgroundTransparency = 1
    dragButton.Size = UDim2.fromOffset(40, 40)
    dragButton.Position = UDim2.fromScale(1, 0.5)
    dragButton.AnchorPoint = Vector2.new(1, 0.5)
    dragButton.Parent = contentHeader
    
    local dragging = false
    local dragStart
    local startPos
    
    dragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = base.Position
            
            -- Visual feedback
            Tween(base, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
                BackgroundTransparency = 0.1
            }):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            Tween(base, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
                BackgroundTransparency = 0.05
            }):Play()
        end
    end)
    
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.BackgroundTransparency = 1
    contentArea.Position = UDim2.fromOffset(0, 63)
    contentArea.Size = UDim2.new(1, 0, 1, -63)
    contentArea.Parent = content
    
    -- TAB CREATION FUNCTION
    WindowFunctions.Tab = function(TabSettings)
        TabSettings = TabSettings or {}
        TabSettings.Name = TabSettings.Name or "Tab " .. (#tabs + 1)
        
        local TabFunctions = {}
        
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "TabButton"
        tabButton.Text = ""
        tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        tabButton.BackgroundTransparency = 0.5
        tabButton.BorderSizePixel = 0
        tabButton.Size = UDim2.new(1, -20, 0, 40)
        tabButton.LayoutOrder = #tabs
        tabButton.Parent = tabContainer
        
        local tabButtonCorner = Instance.new("UICorner")
        tabButtonCorner.CornerRadius = UDim.new(0, 6)
        tabButtonCorner.Parent = tabButton
        
        local tabButtonStroke = Instance.new("UIStroke")
        tabButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        tabButtonStroke.Color = Color3.fromRGB(255, 255, 255)
        tabButtonStroke.Transparency = 0.7
        tabButtonStroke.Parent = tabButton
        
        local tabButtonLabel = Instance.new("TextLabel")
        tabButtonLabel.Name = "TabLabel"
        tabButtonLabel.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        tabButtonLabel.Text = TabSettings.Name
        tabButtonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButtonLabel.TextSize = 14
        tabButtonLabel.TextTransparency = 0.4
        tabButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabButtonLabel.BackgroundTransparency = 1
        tabButtonLabel.Size = UDim2.new(1, -20, 1, 0)
        tabButtonLabel.Position = UDim2.fromOffset(10, 0)
        tabButtonLabel.Parent = tabButton
        
        -- Create tab content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = "TabContent"
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.CanvasSize = UDim2.new()
        tabContent.ScrollBarThickness = Device.IsMobile and 4 or 2
        tabContent.ScrollBarImageTransparency = 0.7
        tabContent.Visible = false
        tabContent.Parent = contentArea
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingBottom = UDim.new(0, 15)
        contentPadding.PaddingLeft = UDim.new(0, 15)
        contentPadding.PaddingRight = UDim.new(0, 15)
        contentPadding.PaddingTop = UDim.new(0, 10)
        contentPadding.Parent = tabContent
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 15)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = tabContent
        
        -- Store tab
        tabs[TabSettings.Name] = {
            Button = tabButton,
            Content = tabContent,
            Label = tabButtonLabel,
            Stroke = tabButtonStroke
        }
        
        -- Tab switching logic
        tabButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                -- Deactivate all tabs
                for _, tab in pairs(tabs) do
                    tab.Content.Visible = false
                    Tween(tab.Stroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                        Transparency = 0.7
                    }):Play()
                    Tween(tab.Label, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                        TextTransparency = 0.4
                    }):Play()
                end
                
                -- Activate this tab
                currentTab = tabContent
                tabContent.Visible = true
                currentTabLabel.Text = TabSettings.Name
                
                Tween(tabButtonStroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                    Transparency = 0.3
                }):Play()
                Tween(tabButtonLabel, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                    TextTransparency = 0.1
                }):Play()
                
                -- Update keybind list
                KeybindManager:UpdateKeybindList()
            end
        end)
        
        -- Auto-select first tab
        if #tabs == 1 then
            tabButton.InputBegan:Invoke({UserInputType = Enum.UserInputType.MouseButton1, Position = Vector2.new(0,0)})
        end
        
        -- Section Function
        TabFunctions.Section = function(SectionSettings)
            local SectionFunctions = {}
            
            SectionSettings.Side = SectionSettings.Side or "Left"
            
            local section = Instance.new("Frame")
            section.Name = "Section"
            section.AutomaticSize = Enum.AutomaticSize.Y
            section.BackgroundTransparency = 0.98
            section.BorderSizePixel = 0
            section.Size = UDim2.fromScale(1, 0)
            section.Parent = tabContent
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.Parent = section
            
            local sectionStroke = Instance.new("UIStroke")
            sectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            sectionStroke.Color = Color3.fromRGB(255, 255, 255)
            sectionStroke.Transparency = 0.95
            sectionStroke.Parent = section
            
            local sectionPadding = Instance.new("UIPadding")
            sectionPadding.PaddingBottom = UDim.new(0, 20)
            sectionPadding.PaddingLeft = UDim.new(0, 20)
            sectionPadding.PaddingRight = UDim.new(0, 18)
            sectionPadding.PaddingTop = UDim.new(0, 22)
            sectionPadding.Parent = section
            
            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.Padding = UDim.new(0, 15)
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Parent = section
            
            -- Button Component
            SectionFunctions.Button = function(ButtonSettings)
                ButtonSettings.Name = ButtonSettings.Name or "Button"
                
                local button = Instance.new("Frame")
                button.Name = "Button"
                button.AutomaticSize = Enum.AutomaticSize.Y
                button.BackgroundTransparency = 1
                button.BorderSizePixel = 0
                button.Size = UDim2.new(1, 0, 0, Device.IsMobile and 48 or 40)
                button.Parent = section
                
                local buttonInteract = Instance.new("TextButton")
                buttonInteract.Name = "ButtonInteract"
                buttonInteract.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                buttonInteract.Text = ButtonSettings.Name
                buttonInteract.TextColor3 = Color3.fromRGB(255, 255, 255)
                buttonInteract.TextSize = Device.IsMobile and 16 or 14
                buttonInteract.TextTransparency = 0.5
                buttonInteract.TextTruncate = Enum.TextTruncate.AtEnd
                buttonInteract.TextXAlignment = Enum.TextXAlignment.Left
                buttonInteract.BackgroundTransparency = 1
                buttonInteract.BorderSizePixel = 0
                buttonInteract.Size = UDim2.fromScale(1, 1)
                buttonInteract.Parent = button
                
                local buttonImage = Instance.new("ImageLabel")
                buttonImage.Name = "ButtonImage"
                buttonImage.Image = assets.buttonImage
                buttonImage.ImageTransparency = 0.5
                buttonImage.AnchorPoint = Vector2.new(1, 0.5)
                buttonImage.BackgroundTransparency = 1
                buttonImage.BorderSizePixel = 0
                buttonImage.Position = UDim2.fromScale(1, 0.5)
                buttonImage.Size = UDim2.fromOffset(16, 16)
                buttonImage.Parent = button
                
                local function Callback()
                    if ButtonSettings.Callback then
                        task.spawn(ButtonSettings.Callback)
                    end
                end
                
                buttonInteract.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Callback()
                        Tween(buttonImage, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
                            ImageTransparency = 0.2
                        }):Play()
                    end
                end)
                
                buttonInteract.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Tween(buttonImage, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
                            ImageTransparency = 0.5
                        }):Play()
                    end
                end)
                
                -- Keybind
                if ButtonSettings.Keybind then
                    KeybindManager:NewKeybind(ButtonSettings.Name, ButtonSettings.Keybind, Callback)
                end
                
                return {
                    UpdateName = function(NewName) buttonInteract.Text = NewName end,
                    SetVisibility = function(State) button.Visible = State end
                }
            end
            
            -- Toggle Component
            SectionFunctions.Toggle = function(ToggleSettings)
                ToggleSettings.Name = ToggleSettings.Name or "Toggle"
                ToggleSettings.Default = ToggleSettings.Default or false
                
                local toggle = Instance.new("Frame")
                toggle.Name = "Toggle"
                toggle.AutomaticSize = Enum.AutomaticSize.Y
                toggle.BackgroundTransparency = 1
                toggle.BorderSizePixel = 0
                toggle.Size = UDim2.new(1, 0, 0, Device.IsMobile and 48 or 40)
                toggle.Parent = section
                
                local toggleName = Instance.new("TextLabel")
                toggleName.Name = "ToggleName"
                toggleName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                toggleName.Text = ToggleSettings.Name
                toggleName.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleName.TextSize = Device.IsMobile and 16 or 14
                toggleName.TextTransparency = 0.5
                toggleName.TextTruncate = Enum.TextTruncate.AtEnd
                toggleName.TextXAlignment = Enum.TextXAlignment.Left
                toggleName.BackgroundTransparency = 1
                toggleName.Position = UDim2.fromOffset(0, 0)
                toggleName.Size = UDim2.new(1, -55, 0, 0)
                toggleName.Parent = toggle
                
                local toggleButton = Instance.new("TextButton")
                toggleButton.Name = "ToggleButton"
                toggleButton.Text = ""
                toggleButton.BackgroundColor3 = ToggleSettings.Default and Color3.fromRGB(87, 86, 86) or Color3.fromRGB(61, 61, 61)
                toggleButton.BorderSizePixel = 0
                toggleButton.Size = UDim2.fromOffset(45, 24)
                toggleButton.Position = UDim2.fromScale(1, 0.5)
                toggleButton.AnchorPoint = Vector2.new(1, 0.5)
                toggleButton.Parent = toggle
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(1, 0)
                toggleCorner.Parent = toggleButton
                
                local toggleHead = Instance.new("Frame")
                toggleHead.Name = "ToggleHead"
                toggleHead.BackgroundColor3 = ToggleSettings.Default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(91, 91, 91)
                toggleHead.BorderSizePixel = 0
                toggleHead.Size = UDim2.fromOffset(20, 20)
                toggleHead.Position = ToggleSettings.Default and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                toggleHead.AnchorPoint = Vector2.new(1, 0.5)
                toggleHead.Parent = toggleButton
                
                local headCorner = Instance.new("UICorner")
                headCorner.CornerRadius = UDim.new(1, 0)
                headCorner.Parent = toggleHead
                
                local toggleState = ToggleSettings.Default
                
                local function SetState(State)
                    toggleState = State
                    if State then
                        Tween(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                            BackgroundColor3 = Color3.fromRGB(87, 86, 86)
                        }):Play()
                        Tween(toggleHead, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Position = UDim2.new(1, -2, 0.5, 0)
                        }):Play()
                    else
                        Tween(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                            BackgroundColor3 = Color3.fromRGB(61, 61, 61)
                        }):Play()
                        Tween(toggleHead, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                            BackgroundColor3 = Color3.fromRGB(91, 91, 91),
                            Position = UDim2.new(0, 2, 0.5, 0)
                        }):Play()
                    end
                end
                
                local function Toggle()
                    SetState(not toggleState)
                    if ToggleSettings.Callback then
                        ToggleSettings.Callback(toggleState)
                    end
                end
                
                toggleButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Toggle()
                    end
                end)
                
                if ToggleSettings.Keybind then
                    KeybindManager:NewKeybind(ToggleSettings.Name, ToggleSettings.Keybind, Toggle)
                end
                
                return {
                    Toggle = function() Toggle() end,
                    GetState = function() return toggleState end,
                    SetState = SetState,
                    UpdateName = function(NewName) toggleName.Text = NewName end
                }
            end
            
            -- Slider Component
            SectionFunctions.Slider = function(SliderSettings)
                SliderSettings.Name = SliderSettings.Name or "Slider"
                SliderSettings.Min = SliderSettings.Min or 0
                SliderSettings.Max = SliderSettings.Max or 100
                SliderSettings.Default = SliderSettings.Default or SliderSettings.Min
                
                local slider = Instance.new("Frame")
                slider.Name = "Slider"
                slider.AutomaticSize = Enum.AutomaticSize.Y
                slider.BackgroundTransparency = 1
                slider.BorderSizePixel = 0
                slider.Size = UDim2.new(1, 0, 0, Device.IsMobile and 56 or 48)
                slider.Parent = section
                
                local sliderName = Instance.new("TextLabel")
                sliderName.Name = "SliderName"
                sliderName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                sliderName.Text = SliderSettings.Name
                sliderName.TextColor3 = Color3.fromRGB(255, 255, 255)
                sliderName.TextSize = Device.IsMobile and 16 or 14
                sliderName.TextTransparency = 0.5
                sliderName.TextTruncate = Enum.TextTruncate.AtEnd
                sliderName.TextXAlignment = Enum.TextXAlignment.Left
                sliderName.BackgroundTransparency = 1
                sliderName.Size = UDim2.new(1, -100, 0, 0)
                sliderName.Position = UDim2.fromOffset(0, 0)
                sliderName.Parent = slider
                
                local sliderValue = Instance.new("TextBox")
                sliderValue.Name = "SliderValue"
                sliderValue.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                sliderValue.Text = tostring(SliderSettings.Default)
                sliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
                sliderValue.TextSize = Device.IsMobile and 14 or 12
                sliderValue.TextTransparency = 0.4
                sliderValue.BackgroundTransparency = 0.95
                sliderValue.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                sliderValue.BorderSizePixel = 0
                sliderValue.Size = UDim2.fromOffset(60, 24)
                sliderValue.Position = UDim2.fromScale(1, 0)
                sliderValue.AnchorPoint = Vector2.new(1, 0)
                sliderValue.Parent = slider
                
                local valueCorner = Instance.new("UICorner")
                valueCorner.CornerRadius = UDim.new(0, 4)
                valueCorner.Parent = sliderValue
                
                local valueStroke = Instance.new("UIStroke")
                valueStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                valueStroke.Color = Color3.fromRGB(255, 255, 255)
                valueStroke.Transparency = 0.9
                valueStroke.Parent = sliderValue
                
                local sliderBar = Instance.new("Frame")
                sliderBar.Name = "SliderBar"
                sliderBar.BackgroundColor3 = Color3.fromRGB(87, 86, 86)
                sliderBar.BorderSizePixel = 0
                sliderBar.Size = UDim2.new(1, -100, 0, 4)
                sliderBar.Position = UDim2.fromOffset(0, 28)
                sliderBar.Parent = slider
                
                local sliderBarCorner = Instance.new("UICorner")
                sliderBarCorner.CornerRadius = UDim.new(1, 0)
                sliderBarCorner.Parent = sliderBar
                
                local sliderHead = Instance.new("ImageButton")
                sliderHead.Name = "SliderHead"
                sliderHead.Image = "rbxassetid://18772834246"
                sliderHead.AnchorPoint = Vector2.new(0.5, 0.5)
                sliderHead.BackgroundTransparency = 1
                sliderHead.BorderSizePixel = 0
                sliderHead.Size = UDim2.fromOffset(18, 18)
                sliderHead.Position = UDim2.fromScale(0, 0.5)
                sliderHead.Parent = sliderBar
                
                local sliderDragging = false
                local currentValue = SliderSettings.Default
                
                local function UpdateValue(newValue, silent)
                    newValue = math.clamp(newValue, SliderSettings.Min, SliderSettings.Max)
                    currentValue = newValue
                    
                    local percentage = (newValue - SliderSettings.Min) / (SliderSettings.Max - SliderSettings.Min)
                    sliderHead.Position = UDim2.fromScale(percentage, 0.5)
                    sliderValue.Text = tostring(math.round(newValue * 10) / 10)
                    
                    if not silent and SliderSettings.Callback then
                        SliderSettings.Callback(newValue)
                    end
                end
                
                UpdateValue(SliderSettings.Default, true)
                
                local function SetValueFromInput(input)
                    local relativeX = (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
                    local newValue = SliderSettings.Min + relativeX * (SliderSettings.Max - SliderSettings.Min)
                    UpdateValue(newValue)
                end
                
                sliderHead.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliderDragging = true
                        SetValueFromInput(input)
                    end
                end)
                
                sliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliderDragging = true
                        SetValueFromInput(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        SetValueFromInput(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        sliderDragging = false
                    end
                end)
                
                sliderValue.FocusLost:Connect(function()
                    local num = tonumber(sliderValue.Text)
                    if num then
                        UpdateValue(num)
                    else
                        sliderValue.Text = tostring(currentValue)
                    end
                end)
                
                if SliderSettings.Keybind then
                    KeybindManager:NewKeybind(SliderSettings.Name, SliderSettings.Keybind, function()
                        local mid = (SliderSettings.Min + SliderSettings.Max) / 2
                        UpdateValue(currentValue > mid and SliderSettings.Min or SliderSettings.Max)
                    end)
                end
                
                return {
                    UpdateName = function(NewName) sliderName.Text = NewName end,
                    GetValue = function() return currentValue end,
                    SetValue = UpdateValue
                }
            end
            
            -- Input Component
            SectionFunctions.Input = function(InputSettings)
                InputSettings.Name = InputSettings.Name or "Input"
                InputSettings.Default = InputSettings.Default or ""
                InputSettings.Placeholder = InputSettings.Placeholder or ""
                
                local input = Instance.new("Frame")
                input.Name = "Input"
                input.AutomaticSize = Enum.AutomaticSize.Y
                input.BackgroundTransparency = 1
                input.BorderSizePixel = 0
                input.Size = UDim2.new(1, 0, 0, Device.IsMobile and 48 or 40)
                input.Parent = section
                
                local inputName = Instance.new("TextLabel")
                inputName.Name = "InputName"
                inputName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                inputName.Text = InputSettings.Name
                inputName.TextColor3 = Color3.fromRGB(255, 255, 255)
                inputName.TextSize = Device.IsMobile and 16 or 14
                inputName.TextTransparency = 0.5
                inputName.TextTruncate = Enum.TextTruncate.AtEnd
                inputName.TextXAlignment = Enum.TextXAlignment.Left
                inputName.BackgroundTransparency = 1
                inputName.Size = UDim2.new(1, -100, 0, 0)
                inputName.Position = UDim2.fromOffset(0, 0)
                inputName.Parent = input
                
                local inputBox = Instance.new("TextBox")
                inputBox.Name = "InputBox"
                inputBox.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                inputBox.Text = InputSettings.Default
                inputBox.PlaceholderText = InputSettings.Placeholder
                inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                inputBox.TextSize = Device.IsMobile and 14 or 12
                inputBox.TextTransparency = 0.4
                inputBox.BackgroundTransparency = 0.95
                inputBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                inputBox.BorderSizePixel = 0
                inputBox.Size = UDim2.fromOffset(120, 24)
                inputBox.Position = UDim2.fromScale(1, 0)
                inputBox.AnchorPoint = Vector2.new(1, 0)
                inputBox.Parent = input
                
                local boxCorner = Instance.new("UICorner")
                boxCorner.CornerRadius = UDim.new(0, 4)
                boxCorner.Parent = inputBox
                
                local boxStroke = Instance.new("UIStroke")
                boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                boxStroke.Color = Color3.fromRGB(255, 255, 255)
                boxStroke.Transparency = 0.9
                boxStroke.Parent = inputBox
                
                local CharacterSubs = {
                    All = function(v) return v end,
                    Numeric = function(v) return v:gsub("[^%d%.%-]", "") end,
                    Alphabetic = function(v) return v:gsub("[^%a%s]", "") end,
                }
                
                local filter = CharacterSubs[InputSettings.AcceptedCharacters] or CharacterSubs.All
                
                inputBox.FocusLost:Connect(function()
                    local filtered = filter(inputBox.Text)
                    inputBox.Text = filtered
                    if InputSettings.Callback then
                        InputSettings.Callback(filtered)
                    end
                end)
                
                inputBox:GetPropertyChangedSignal("Text"):Connect(function()
                    inputBox.Text = filter(inputBox.Text)
                    if InputSettings.onChanged then
                        InputSettings.onChanged(inputBox.Text)
                    end
                end)
                
                if InputSettings.Keybind then
                    KeybindManager:NewKeybind(InputSettings.Name, InputSettings.Keybind, function()
                        inputBox:CaptureFocus()
                    end)
                end
                
                return {
                    UpdateName = function(NewName) inputName.Text = NewName end,
                    GetText = function() return inputBox.Text end,
                    SetText = function(Text) inputBox.Text = Text end
                }
            end
            
            -- Dropdown Component
            SectionFunctions.Dropdown = function(DropdownSettings)
                DropdownSettings.Name = DropdownSettings.Name or "Dropdown"
                DropdownSettings.Options = DropdownSettings.Options or {}
                DropdownSettings.Default = DropdownSettings.Default or nil
                DropdownSettings.Multi = DropdownSettings.Multi or false
                DropdownSettings.Search = DropdownSettings.Search or false
                
                local dropdown = Instance.new("Frame")
                dropdown.Name = "Dropdown"
                dropdown.BackgroundTransparency = 0.98
                dropdown.BorderSizePixel = 0
                dropdown.ClipsDescendants = true
                dropdown.Size = UDim2.new(1, 0, 0, Device.IsMobile and 52 or 44)
                dropdown.Parent = section
                
                local dropdownStroke = Instance.new("UIStroke")
                dropdownStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                dropdownStroke.Color = Color3.fromRGB(255, 255, 255)
                dropdownStroke.Transparency = 0.95
                dropdownStroke.Parent = dropdown
                
                local dropdownCorner = Instance.new("UICorner")
                dropdownCorner.CornerRadius = UDim.new(0, 6)
                dropdownCorner.Parent = dropdown
                
                local dropdownPadding = Instance.new("UIPadding")
                dropdownPadding.PaddingLeft = UDim.new(0, 15)
                dropdownPadding.PaddingRight = UDim.new(0, 15)
                dropdownPadding.Parent = dropdown
                
                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Text = ""
                dropdownButton.BackgroundTransparency = 1
                dropdownButton.Size = UDim2.new(1, 0, 0, Device.IsMobile and 52 or 44)
                dropdownButton.Parent = dropdown
                
                local dropdownName = Instance.new("TextLabel")
                dropdownName.Name = "DropdownName"
                dropdownName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                dropdownName.Text = DropdownSettings.Name
                dropdownName.TextColor3 = Color3.fromRGB(255, 255, 255)
                dropdownName.TextSize = Device.IsMobile and 16 or 14
                dropdownName.TextTransparency = 0.5
                dropdownName.TextTruncate = Enum.TextTruncate.AtEnd
                dropdownName.TextXAlignment = Enum.TextXAlignment.Left
                dropdownName.BackgroundTransparency = 1
                dropdownName.Size = UDim2.new(1, -25, 1, 0)
                dropdownName.Parent = dropdownButton
                
                local dropdownArrow = Instance.new("ImageLabel")
                dropdownArrow.Name = "DropdownArrow"
                dropdownArrow.Image = "rbxassetid://18865373378"
                dropdownArrow.ImageTransparency = 0.5
                dropdownArrow.AnchorPoint = Vector2.new(1, 0.5)
                dropdownArrow.BackgroundTransparency = 1
                dropdownArrow.Size = UDim2.fromOffset(16, 16)
                dropdownArrow.Position = UDim2.new(1, 0, 0.5, 0)
                dropdownArrow.Parent = dropdownButton
                
                local optionContainer = Instance.new("Frame")
                optionContainer.Name = "OptionContainer"
                optionContainer.BackgroundTransparency = 1
                optionContainer.BorderSizePixel = 0
                optionContainer.ClipsDescendants = true
                optionContainer.Size = UDim2.fromScale(1, 1)
                optionContainer.Visible = false
                optionContainer.Parent = dropdown
                
                local optionPadding = Instance.new("UIPadding")
                optionPadding.PaddingTop = UDim.new(0, Device.IsMobile and 56 or 48)
                optionPadding.Parent = optionContainer
                
                local optionList = Instance.new("UIListLayout")
                optionList.Padding = UDim.new(0, 5)
                optionList.SortOrder = Enum.SortOrder.LayoutOrder
                optionList.Parent = optionContainer
                
                local options = {}
                local selected = DropdownSettings.Multi and {} or nil
                
                local function UpdateSelection()
                    if DropdownSettings.Multi then
                        if #selected > 0 then
                            dropdownName.Text = DropdownSettings.Name .. " • " .. table.concat(selected, ", ")
                        else
                            dropdownName.Text = DropdownSettings.Name
                        end
                    else
                        if selected then
                            dropdownName.Text = DropdownSettings.Name .. " • " .. tostring(selected)
                        else
                            dropdownName.Text = DropdownSettings.Name
                        end
                    end
                end
                
                local function Toggle()
                    optionContainer.Visible = not optionContainer.Visible
                    local targetSize = optionContainer.Visible and (Device.IsMobile and 56 or 48) + (#options * 30) + 20 or Device.IsMobile and 56 or 48
                    Tween(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                        Size = UDim2.new(1, 0, 0, targetSize)
                    }):Play()
                end
                
                dropdownButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Toggle()
                    end
                end)
                
                for i, optionValue in ipairs(DropdownSettings.Options) do
                    local option = Instance.new("TextButton")
                    option.Name = "Option"
                    option.Text = ""
                    option.BackgroundTransparency = 1
                    option.Size = UDim2.new(1, 0, 0, 30)
                    option.Parent = optionContainer
                    
                    local optionLabel = Instance.new("TextLabel")
                    optionLabel.Name = "OptionLabel"
                    optionLabel.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    optionLabel.Text = tostring(optionValue)
                    optionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    optionLabel.TextSize = Device.IsMobile and 15 or 13
                    optionLabel.TextTransparency = 0.5
                    optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                    optionLabel.BackgroundTransparency = 1
                    optionLabel.Size = UDim2.new(1, -25, 1, 0)
                    optionLabel.Position = UDim2.fromOffset(10, 0)
                    optionLabel.Parent = option
                    
                    local optionCheck = Instance.new("TextLabel")
                    optionCheck.Name = "Check"
                    optionCheck.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    optionCheck.Text = "✓"
                    optionCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
                    optionCheck.TextSize = 13
                    optionCheck.TextTransparency = 1
                    optionCheck.BackgroundTransparency = 1
                    optionCheck.Size = UDim2.fromOffset(20, 20)
                    optionCheck.Position = UDim2.new(1, -5, 0.5, 0)
                    optionCheck.AnchorPoint = Vector2.new(1, 0.5)
                    optionCheck.Parent = option
                    
                    option.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            if DropdownSettings.Multi then
                                if table.find(selected, optionValue) then
                                    table.remove(selected, table.find(selected, optionValue))
                                    Tween(optionCheck, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
                                        TextTransparency = 1
                                    }):Play()
                                else
                                    table.insert(selected, optionValue)
                                    Tween(optionCheck, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
                                        TextTransparency = 0
                                    }):Play()
                                end
                            else
                                selected = optionValue
                                for _, opt in pairs(options) do
                                    Tween(opt.Check, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
                                        TextTransparency = 1
                                    }):Play()
                                end
                                Tween(optionCheck, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
                                    TextTransparency = 0
                                }):Play()
                                task.wait(0.1)
                                Toggle()
                            end
                            UpdateSelection()
                            if DropdownSettings.Callback then
                                DropdownSettings.Callback(DropdownSettings.Multi and selected or optionValue)
                            end
                        end
                    end)
                    
                    table.insert(options, {Button = option, Label = optionLabel, Check = optionCheck, Value = optionValue})
                    
                    -- Set default
                    if DropdownSettings.Default then
                        if DropdownSettings.Multi then
                            if table.find(DropdownSettings.Default, optionValue) then
                                option.InputBegan:Invoke({UserInputType = Enum.UserInputType.MouseButton1, Position = Vector2.new(0,0)})
                            end
                        else
                            if DropdownSettings.Default == optionValue then
                                option.InputBegan:Invoke({UserInputType = Enum.UserInputType.MouseButton1, Position = Vector2.new(0,0)})
                            end
                        end
                    end
                end
                
                UpdateSelection()
                
                return {
                    UpdateName = function(NewName) dropdownName.Text = NewName end,
                    GetValue = function() return DropdownSettings.Multi and selected or selected end
                }
            end
            
            -- Colorpicker Component
            SectionFunctions.Colorpicker = function(ColorpickerSettings)
                ColorpickerSettings.Name = ColorpickerSettings.Name or "Colorpicker"
                ColorpickerSettings.Default = ColorpickerSettings.Default or Color3.fromRGB(255, 0, 0)
                
                local colorpicker = Instance.new("Frame")
                colorpicker.Name = "Colorpicker"
                colorpicker.AutomaticSize = Enum.AutomaticSize.Y
                colorpicker.BackgroundTransparency = 1
                colorpicker.BorderSizePixel = 0
                colorpicker.Size = UDim2.new(1, 0, 0, Device.IsMobile and 48 or 40)
                colorpicker.Parent = section
                
                local colorpickerName = Instance.new("TextLabel")
                colorpickerName.Name = "ColorpickerName"
                colorpickerName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                colorpickerName.Text = ColorpickerSettings.Name
                colorpickerName.TextColor3 = Color3.fromRGB(255, 255, 255)
                colorpickerName.TextSize = Device.IsMobile and 16 or 14
                colorpickerName.TextTransparency = 0.5
                colorpickerName.TextTruncate = Enum.TextTruncate.AtEnd
                colorpickerName.TextXAlignment = Enum.TextXAlignment.Left
                colorpickerName.BackgroundTransparency = 1
                colorpickerName.Position = UDim2.fromOffset(0, 0)
                colorpickerName.Size = UDim2.new(1, -45, 1, 0)
                colorpickerName.Parent = colorpicker
                
                local colorDisplay = Instance.new("Frame")
                colorDisplay.Name = "ColorDisplay"
                colorDisplay.BackgroundColor3 = ColorpickerSettings.Default
                colorDisplay.BorderSizePixel = 0
                colorDisplay.Size = UDim2.fromOffset(Device.IsMobile and 28 or 24, Device.IsMobile and 28 or 24)
                colorDisplay.Position = UDim2.new(1, 0, 0.5, 0)
                colorDisplay.AnchorPoint = Vector2.new(1, 0.5)
                colorDisplay.Parent = colorpicker
                
                local displayCorner = Instance.new("UICorner")
                displayCorner.CornerRadius = UDim.new(0, 6)
                displayCorner.Parent = colorDisplay
                
                local displayButton = Instance.new("TextButton")
                displayButton.Text = ""
                displayButton.BackgroundTransparency = 1
                displayButton.Size = UDim2.fromScale(1, 1)
                displayButton.Parent = colorDisplay
                
                displayButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        -- Simulate color picker open
                        if ColorpickerSettings.Callback then
                            ColorpickerSettings.Callback(colorDisplay.BackgroundColor3)
                        end
                    end
                end)
                
                return {
                    UpdateName = function(NewName) colorpickerName.Text = NewName end,
                    SetColor = function(Color) colorDisplay.BackgroundColor3 = Color end,
                    GetColor = function() return colorDisplay.BackgroundColor3 end
                }
            end
            
            return SectionFunctions
        end
        
        return TabFunctions
    end
    
    -- CRITICAL: Auto-create first tab if user doesn't create one
    task.spawn(function()
        wait(0.1)
        if #tabs == 0 then
            warn("[MacLib] No tabs created, auto-creating default tab")
            WindowFunctions:Tab({Name = "Main"})
        end
    end)
    
    -- Global functions
    WindowFunctions.GetKeybindManager = function()
        return KeybindManager
    end
    
    WindowFunctions.GetDeviceInfo = function()
        return Device
    end
    
    WindowFunctions.Destroy = function()
        if macLib then
            macLib:Destroy()
        end
        KeybindManager:SetActive(false)
    end
    
    return WindowFunctions
end

return MacLib
