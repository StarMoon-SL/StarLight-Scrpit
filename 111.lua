-- MacUI Adaptive - 设备自适应UI框架
-- 基于MacLib设计风格，支持PC、Mobile、Console多设备

local MacUIAdaptive = {
    Options = {},
    DeviceType = "Unknown",
    DeviceConfig = {},
    Folder = "MacUIAdaptive",
    GetService = function(service)
        return cloneref and cloneref(game:GetService(service)) or game:GetService(service)
    end
}

--// 服务
local TweenService = MacUIAdaptive.GetService("TweenService")
local RunService = MacUIAdaptive.GetService("RunService")
local HttpService = MacUIAdaptive.GetService("HttpService")
local UserInputService = MacUIAdaptive.GetService("UserInputService")
local Players = MacUIAdaptive.GetService("Players")
local ContentProvider = MacUIAdaptive.GetService("ContentProvider")
local GuiService = MacUIAdaptive.GetService("GuiService")

--// 变量
local isStudio = RunService:IsStudio()
local LocalPlayer = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isConsole = GuiService:IsTenFootInterface()
local isPC = not isMobile and not isConsole

-- 设备检测
function MacUIAdaptive:DetectDevice()
    if isConsole then
        self.DeviceType = "Console"
    elseif isMobile then
        self.DeviceType = "Mobile"
    else
        self.DeviceType = "PC"
    end
    
    -- 设备特定配置
    self.DeviceConfig = {
        PC = {
            SidebarWidth = 0.325,
            FontSize = {
                Title = 18,
                Subtitle = 12,
                Tab = 16,
                Element = 13
            },
            Padding = {
                Left = 20,
                Right = 20,
                Top = 10
            },
            DragStyle = 1, -- 1=拖动图标, 2=全窗口拖动
            ShowTooltips = true,
            BlurEnabled = true,
            ResizeEnabled = true
        },
        Mobile = {
            SidebarWidth = 0.4,
            FontSize = {
                Title = 20,
                Subtitle = 14,
                Tab = 18,
                Element = 15
            },
            Padding = {
                Left = 15,
                Right = 15,
                Top = 15
            },
            DragStyle = 2, -- 全窗口拖动更便于触摸
            ShowTooltips = false,
            BlurEnabled = false, -- 移动设备性能考虑
            ResizeEnabled = false,
            TouchPadding = 10 -- 增大触摸区域
        },
        Console = {
            SidebarWidth = 0.3,
            FontSize = {
                Title = 24,
                Subtitle = 16,
                Tab = 20,
                Element = 17
            },
            Padding = {
                Left = 25,
                Right = 25,
                Top = 20
            },
            DragStyle = 0, -- 控制台不支持拖动
            ShowTooltips = true,
            BlurEnabled = true,
            ResizeEnabled = false,
            UseGamepadNavigation = true
        }
    }
    
    return self.DeviceType, self.DeviceConfig[self.DeviceType]
end

--// 资源
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
    mobileMenu = "rbxassetid://3926305904", -- 移动端菜单图标
    consoleHint = "rbxassetid://3944663492" -- 控制台提示图标
}

--// 获取GUI父级
local function GetGui()
    local newGui = Instance.new("ScreenGui")
    newGui.ScreenInsets = Enum.ScreenInsets.None
    newGui.ResetOnSpawn = false
    newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    newGui.DisplayOrder = 2147483647
    
    local parent = RunService:IsStudio() and LocalPlayer:FindFirstChild("PlayerGui") 
        or (gethui and gethui()) 
        or (cloneref and cloneref(MacUIAdaptive.GetService("CoreGui")) or MacUIAdaptive.GetService("CoreGui"))
    
    newGui.Parent = parent
    return newGui
end

--// 创建UI
function MacUIAdaptive:Window(Settings)
    -- 检测设备
    local deviceType, deviceConfig = self:DetectDevice()
    print(string.format("[MacUI Adaptive] 检测到设备: %s", deviceType))
    
    local Window = {Settings = Settings}
    local macGui = GetGui()
    
    -- 主窗口
    local base = Instance.new("Frame")
    base.Name = "Base"
    base.AnchorPoint = Vector2.new(0.5, 0.5)
    base.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    base.BackgroundTransparency = deviceConfig.BlurEnabled and 0.05 or 0
    base.BorderSizePixel = 0
    base.Position = UDim2.fromScale(0.5, 0.5)
    base.Size = Settings.Size or (deviceType == "Mobile" and UDim2.fromOffset(400, 600) or UDim2.fromOffset(868, 650))
    
    local baseUICorner = Instance.new("UICorner")
    baseUICorner.CornerRadius = UDim.new(0, 10)
    baseUICorner.Parent = base
    
    local baseUIStroke = Instance.new("UIStroke")
    baseUIStroke.Color = Color3.fromRGB(255, 255, 255)
    baseUIStroke.Transparency = 0.9
    baseUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    baseUIStroke.Parent = base
    
    -- 缩放适配
    local baseUIScale = Instance.new("UIScale")
    baseUIScale.Parent = base
    
    if deviceType == "Mobile" then
        baseUIScale.Scale = 1.1
    elseif deviceType == "Console" then
        baseUIScale.Scale = 1.3
    end
    
    -- 侧边栏
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundTransparency = 1
    sidebar.BorderSizePixel = 0
    sidebar.Size = UDim2.new(deviceConfig.ResizeEnabled and 0.325 or deviceConfig.SidebarWidth, 0, 1, 0)
    
    local sidebarDivider = Instance.new("Frame")
    sidebarDivider.Name = "Divider"
    sidebarDivider.AnchorPoint = Vector2.new(1, 0)
    sidebarDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sidebarDivider.BackgroundTransparency = 0.9
    sidebarDivider.BorderSizePixel = 0
    sidebarDivider.Position = UDim2.fromScale(1, 0)
    sidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    sidebarDivider.Parent = sidebar
    
    -- 设备特定交互
    if deviceConfig.ResizeEnabled then
        local resizeHandle = Instance.new("TextButton")
        resizeHandle.Name = "ResizeHandle"
        resizeHandle.BackgroundTransparency = 1
        resizeHandle.Size = UDim2.new(0, 6, 1, 0)
        resizeHandle.Position = UDim2.fromScale(0.5, 0)
        resizeHandle.Text = ""
        resizeHandle.Parent = sidebarDivider
        
        -- 拖动调整大小逻辑（略）
    end
    
    -- 窗口控制按钮
    local windowControls = Instance.new("Frame")
    windowControls.Name = "WindowControls"
    windowControls.BackgroundTransparency = 1
    windowControls.Size = UDim2.new(1, 0, 0, 31)
    
    local controls = Instance.new("Frame")
    controls.BackgroundTransparency = 1
    controls.Size = UDim2.fromScale(1, 1)
    
    local controlListLayout = Instance.new("UIListLayout")
    controlListLayout.Padding = UDim.new(0, 5)
    controlListLayout.FillDirection = Enum.FillDirection.Horizontal
    controlListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    controlListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    controlListLayout.Parent = controls
    
    local controlPadding = Instance.new("UIPadding")
    controlPadding.PaddingLeft = UDim.new(0, 11)
    controlPadding.Parent = controls
    
    -- 关闭按钮
    local exitButton = Instance.new("TextButton")
    exitButton.Name = "Exit"
    exitButton.BackgroundColor3 = Color3.fromRGB(250, 93, 86)
    exitButton.AutoButtonColor = false
    exitButton.Size = UDim2.fromOffset(8, 8)
    exitButton.Text = ""
    
    local exitCorner = Instance.new("UICorner")
    exitCorner.CornerRadius = UDim.new(1, 0)
    exitCorner.Parent = exitButton
    
    exitButton.Parent = controls
    
    -- 最小化按钮
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "Minimize"
    minimizeButton.BackgroundColor3 = Color3.fromRGB(252, 190, 57)
    minimizeButton.AutoButtonColor = false
    minimizeButton.Size = UDim2.fromOffset(8, 8)
    minimizeButton.LayoutOrder = 1
    minimizeButton.Text = ""
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(1, 0)
    minimizeCorner.Parent = minimizeButton
    
    minimizeButton.Parent = controls
    
    controls.Parent = windowControls
    windowControls.Parent = sidebar
    
    -- 信息区域
    local information = Instance.new("Frame")
    information.Name = "Information"
    information.BackgroundTransparency = 1
    information.Position = UDim2.fromOffset(0, 31)
    information.Size = UDim2.new(1, 0, 0, 60)
    
    local infoDivider = Instance.new("Frame")
    infoDivider.Name = "Divider"
    infoDivider.AnchorPoint = Vector2.new(0, 1)
    infoDivider.BackgroundTransparency = 0.9
    infoDivider.Size = UDim2.new(1, 0, 0, 1)
    infoDivider.Position = UDim2.fromScale(0, 1)
    infoDivider.Parent = information
    
    -- 标题
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold)
    title.Text = Settings.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = deviceConfig.FontSize.Title
    title.TextTransparency = 0.1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -20, 0, 0)
    title.AutomaticSize = Enum.AutomaticSize.Y
    title.Parent = information
    
    -- 副标题
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium)
    subtitle.Text = Settings.Subtitle or ""
    subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    subtitle.TextSize = deviceConfig.FontSize.Subtitle
    subtitle.TextTransparency = 0.7
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.BackgroundTransparency = 1
    subtitle.Size = UDim2.new(1, -20, 0, 0)
    subtitle.AutomaticSize = Enum.AutomaticSize.Y
    subtitle.Position = UDim2.fromScale(0, 1)
    subtitle.Parent = information
    
    -- 设备特定全局设置按钮
    local globalSettingsButton = Instance.new("ImageButton")
    globalSettingsButton.Name = "GlobalSettingsButton"
    globalSettingsButton.Image = assets.globe
    globalSettingsButton.ImageTransparency = 0.5
    globalSettingsButton.AnchorPoint = Vector2.new(1, 0.5)
    globalSettingsButton.BackgroundTransparency = 1
    globalSettingsButton.Position = UDim2.fromScale(1, 0.5)
    globalSettingsButton.Size = UDim2.fromOffset(16, 16)
    globalSettingsButton.Parent = information
    
    information.Parent = sidebar
    
    -- 用户信息显示（仅PC和Console）
    if deviceType ~= "Mobile" then
        local userInfo = Instance.new("Frame")
        userInfo.Name = "UserInfo"
        userInfo.AnchorPoint = Vector2.new(0, 1)
        userInfo.BackgroundTransparency = 1
        userInfo.Position = UDim2.fromScale(0, 1)
        userInfo.Size = UDim2.new(1, 0, 0, 107)
        
        local headshot, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, 
            Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size48x48)
        
        local headshotImage = Instance.new("ImageLabel")
        headshotImage.Name = "Headshot"
        headshotImage.Image = isReady and headshot or ""
        headshotImage.BackgroundTransparency = 1
        headshotImage.Size = UDim2.fromOffset(32, 32)
        
        local headshotCorner = Instance.new("UICorner")
        headshotCorner.CornerRadius = UDim.new(1, 0)
        headshotCorner.Parent = headshotImage
        
        local headshotStroke = Instance.new("UIStroke")
        headshotStroke.Transparency = 0.9
        headshotStroke.Color = Color3.fromRGB(255, 255, 255)
        headshotStroke.Parent = headshotImage
        
        headshotImage.Parent = userInfo
        userInfo.Parent = sidebar
    end
    
    -- 标签切换器
    local tabSwitchers = Instance.new("ScrollingFrame")
    tabSwitchers.Name = "TabSwitchers"
    tabSwitchers.BackgroundTransparency = 1
    tabSwitchers.Size = UDim2.new(1, 0, 1, -107)
    tabSwitchers.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabSwitchers.ScrollBarThickness = deviceType == "Mobile" and 4 or 1
    tabSwitchers.ScrollBarImageTransparency = 0.8
    tabSwitchers.BottomImage = ""
    tabSwitchers.TopImage = ""
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.Padding = UDim.new(0, 17)
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Parent = tabSwitchers
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 2)
    tabPadding.Parent = tabSwitchers
    
    tabSwitchers.Parent = sidebar
    
    -- 内容区域
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.AnchorPoint = Vector2.new(1, 0)
    content.BackgroundTransparency = 1
    content.Position = UDim2.fromScale(1, 0)
    content.Size = UDim2.new(0, base.AbsoluteSize.X - sidebar.AbsoluteSize.X, 1, 0)
    
    -- 顶部栏
    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.BackgroundTransparency = 1
    topbar.Size = UDim2.new(1, 0, 0, 63)
    
    local topbarDivider = Instance.new("Frame")
    topbarDivider.Name = "Divider"
    topbarDivider.AnchorPoint = Vector2.new(0, 1)
    topbarDivider.BackgroundTransparency = 0.9
    topbarDivider.Size = UDim2.new(1, 0, 0, 1)
    topbarDivider.Position = UDim2.fromScale(0, 1)
    topbarDivider.Parent = topbar
    
    -- 当前标签显示
    local currentTabLabel = Instance.new("TextLabel")
    currentTabLabel.Name = "CurrentTab"
    currentTabLabel.FontFace = Font.new(assets.interFont)
    currentTabLabel.Text = ""
    currentTabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    currentTabLabel.TextSize = deviceConfig.FontSize.Tab
    currentTabLabel.TextTransparency = 0.5
    currentTabLabel.TextXAlignment = Enum.TextXAlignment.Left
    currentTabLabel.BackgroundTransparency = 1
    currentTabLabel.Size = UDim2.fromScale(0.9, 0)
    currentTabLabel.AutomaticSize = Enum.AutomaticSize.Y
    currentTabLabel.Parent = topbar
    
    -- 拖动/移动图标
    if deviceConfig.DragStyle > 0 then
        local moveIcon = Instance.new("ImageButton")
        moveIcon.Name = "MoveIcon"
        moveIcon.Image = assets.transform
        moveIcon.ImageTransparency = 0.7
        moveIcon.AnchorPoint = Vector2.new(1, 0.5)
        moveIcon.BackgroundTransparency = 1
        moveIcon.Position = UDim2.fromScale(1, 0.5)
        moveIcon.Size = deviceType == "Mobile" and UDim2.fromOffset(20, 20) or UDim2.fromOffset(15, 15)
        
        if deviceType == "Mobile" then
            local touchPadding = Instance.new("UIPadding")
            touchPadding.PaddingTop = UDim.new(0, deviceConfig.TouchPadding)
            touchPadding.PaddingBottom = UDim.new(0, deviceConfig.TouchPadding)
            touchPadding.PaddingLeft = UDim.new(0, deviceConfig.TouchPadding)
            touchPadding.PaddingRight = UDim.new(0, deviceConfig.TouchPadding)
            touchPadding.Parent = moveIcon
        end
        
        -- 拖动逻辑
        local dragInput, dragStart, startPos
        local dragging = false
        
        local dragArea = Instance.new("TextButton")
        dragArea.BackgroundTransparency = 1
        dragArea.Text = ""
        dragArea.Size = UDim2.fromOffset(40, 40)
        dragArea.AnchorPoint = Vector2.new(0.5, 0.5)
        dragArea.Position = UDim2.fromScale(0.5, 0.5)
        dragArea.Parent = moveIcon
        
        dragArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = base.Position
            end
        end)
        
        dragArea.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                            input.UserInputType == Enum.UserInputType.Touch) then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                base.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
        
        dragArea.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        moveIcon.Parent = topbar
    end
    
    topbar.Parent = content
    
    -- 元素区域
    local elements = Instance.new("Frame")
    elements.Name = "Elements"
    elements.BackgroundTransparency = 1
    elements.Position = UDim2.fromOffset(0, 63)
    elements.Size = UDim2.new(1, 0, 1, -63)
    
    local elementsScrolling = Instance.new("ScrollingFrame")
    elementsScrolling.Name = "ElementsScrolling"
    elementsScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
    elementsScrolling.ScrollBarThickness = deviceType == "Mobile" and 5 or 3
    elementsScrolling.ScrollBarImageTransparency = 0.5
    elementsScrolling.BackgroundTransparency = 1
    elementsScrolling.Size = UDim2.fromScale(1, 1)
    elementsScrolling.BottomImage = ""
    elementsScrolling.TopImage = ""
    
    local elementsPadding = Instance.new("UIPadding")
    elementsPadding.PaddingLeft = UDim.new(0, deviceConfig.Padding.Left)
    elementsPadding.PaddingRight = UDim.new(0, deviceConfig.Padding.Right)
    elementsPadding.PaddingTop = UDim.new(0, deviceConfig.Padding.Top)
    elementsPadding.PaddingBottom = UDim.new(0, deviceConfig.Padding.Top)
    elementsPadding.Parent = elementsScrolling
    
    local elementsLayout = Instance.new("UIListLayout")
    elementsLayout.Padding = UDim.new(0, 15)
    elementsLayout.FillDirection = Enum.FillDirection.Horizontal
    elementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    elementsLayout.Parent = elementsScrolling
    
    -- 左右列
    local leftColumn = Instance.new("Frame")
    leftColumn.Name = "Left"
    leftColumn.BackgroundTransparency = 1
    leftColumn.AutomaticSize = Enum.AutomaticSize.Y
    leftColumn.Size = UDim2.new(0.5, -10, 0, 0)
    
    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Padding = UDim.new(0, 15)
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Parent = leftColumn
    
    local rightColumn = Instance.new("Frame")
    rightColumn.Name = "Right"
    rightColumn.BackgroundTransparency = 1
    rightColumn.AutomaticSize = Enum.AutomaticSize.Y
    rightColumn.Size = UDim2.new(0.5, -10, 0, 0)
    rightColumn.LayoutOrder = 1
    
    local rightLayout = Instance.new("UIListLayout")
    rightLayout.Padding = UDim.new(0, 15)
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Parent = rightColumn
    
    leftColumn.Parent = elementsScrolling
    rightColumn.Parent = elementsScrolling
    
    elementsScrolling.Parent = elements
    elements.Parent = content
    
    -- 构建层级
    sidebar.Parent = base
    content.Parent = base
    base.Parent = macGui
    
    --// 窗口函数
    function Window:UpdateTitle(newTitle)
        title.Text = newTitle
    end
    
    function Window:UpdateSubtitle(newSubtitle)
        subtitle.Text = newSubtitle
    end
    
    --// 标签函数
    function Window:Tab(tabSettings)
        local Tab = {Settings = tabSettings}
        
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "TabButton"
        tabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.BackgroundTransparency = 1
        tabButton.Size = UDim2.new(1, -21, 0, 40)
        tabButton.Text = ""
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.Parent = tabButton
        
        local tabStroke = Instance.new("UIStroke")
        tabStroke.Transparency = 1
        tabStroke.Color = Color3.fromRGB(255, 255, 255)
        tabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        tabStroke.Parent = tabButton
        
        local tabPadding = Instance.new("UIPadding")
        tabPadding.PaddingLeft = UDim.new(0, 24)
        tabPadding.PaddingRight = UDim.new(0, 35)
        tabPadding.PaddingTop = UDim.new(0, 1)
        tabPadding.Parent = tabButton
        
        -- 标签图标
        if tabSettings.Image then
            local tabImage = Instance.new("ImageLabel")
            tabImage.Name = "TabImage"
            tabImage.Image = tabSettings.Image
            tabImage.ImageTransparency = 0.5
            tabImage.BackgroundTransparency = 1
            tabImage.Size = UDim2.fromOffset(18, 18)
            tabImage.Parent = tabButton
        end
        
        -- 标签名称
        local tabName = Instance.new("TextLabel")
        tabName.Name = "TabName"
        tabName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium)
        tabName.Text = tabSettings.Name
        tabName.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabName.TextSize = deviceConfig.FontSize.Tab
        tabName.TextTransparency = 0.5
        tabName.TextXAlignment = Enum.TextXAlignment.Left
        tabName.BackgroundTransparency = 1
        tabName.Size = UDim2.fromScale(1, 0)
        tabName.AutomaticSize = Enum.AutomaticSize.Y
        tabName.LayoutOrder = 1
        tabName.Parent = tabButton
        
        tabButton.Parent = tabSwitchers
        
        -- 内容区域
        local tabContent = Instance.new("Frame")
        tabContent.Name = "TabContent"
        tabContent.BackgroundTransparency = 1
        tabContent.Size = UDim2.fromScale(1, 1)
        tabContent.Visible = false
        
        -- 激活标签
        local function activateTab()
            for _, otherTab in pairs(tabSwitchers:GetChildren()) do
                if otherTab:IsA("TextButton") then
                    otherTab.TabName.TextTransparency = 0.5
                    if otherTab:FindFirstChild("TabImage") then
                        otherTab.TabImage.ImageTransparency = 0.5
                    end
                    otherTab.UIStroke.Transparency = 1
                end
            end
            
            tabName.TextTransparency = 0
            if tabButton:FindFirstChild("TabImage") then
                tabButton.TabImage.ImageTransparency = 0
            end
            tabStroke.Transparency = 0.8
            
            for _, otherContent in pairs(elementsScrolling:GetChildren()) do
                if otherContent:IsA("Frame") and otherContent.Name ~= "Left" and otherContent.Name ~= "Right" then
                    otherContent.Visible = false
                end
            end
            
            tabContent.Visible = true
            currentTabLabel.Text = tabSettings.Name
        end
        
        tabButton.MouseButton1Click:Connect(activateTab)
        
        --// 组件函数
        function Tab:Section(sectionSettings)
            local Section = {Settings = sectionSettings}
            
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = "Section"
            sectionFrame.BackgroundTransparency = 0.98
            sectionFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            sectionFrame.Size = UDim2.fromScale(1, 0)
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.Parent = sectionFrame
            
            local sectionStroke = Instance.new("UIStroke")
            sectionStroke.Transparency = 0.95
            sectionStroke.Color = Color3.fromRGB(255, 255, 255)
            sectionStroke.Parent = sectionFrame
            
            local sectionPadding = Instance.new("UIPadding")
            sectionPadding.PaddingTop = UDim.new(0, 22)
            sectionPadding.PaddingBottom = UDim.new(0, 20)
            sectionPadding.PaddingLeft = UDim.new(0, 20)
            sectionPadding.PaddingRight = UDim.new(0, 18)
            sectionPadding.Parent = sectionFrame
            
            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.Padding = UDim.new(0, 10)
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Parent = sectionFrame
            
            sectionFrame.Parent = sectionSettings.Side == "Left" and leftColumn or rightColumn
            
            --// 按钮
            function Section:Button(buttonSettings, flag)
                local Button = {Settings = buttonSettings}
                
                local buttonFrame = Instance.new("Frame")
                buttonFrame.Name = "Button"
                buttonFrame.BackgroundTransparency = 1
                buttonFrame.AutomaticSize = Enum.AutomaticSize.Y
                buttonFrame.Size = UDim2.new(1, 0, 0, 38)
                
                local buttonInteract = Instance.new("TextButton")
                buttonInteract.Name = "ButtonInteract"
                buttonInteract.FontFace = Font.new(assets.interFont)
                buttonInteract.Text = buttonSettings.Name
                buttonInteract.TextColor3 = Color3.fromRGB(255, 255, 255)
                buttonInteract.TextSize = deviceConfig.FontSize.Element
                buttonInteract.TextTransparency = 0.5
                buttonInteract.TextXAlignment = Enum.TextXAlignment.Left
                buttonInteract.BackgroundTransparency = 1
                buttonInteract.Size = UDim2.fromScale(1, 1)
                buttonInteract.Parent = buttonFrame
                
                local buttonImage = Instance.new("ImageLabel")
                buttonImage.Name = "ButtonImage"
                buttonImage.Image = assets.buttonImage
                buttonImage.ImageTransparency = 0.5
                buttonImage.AnchorPoint = Vector2.new(1, 0.5)
                buttonImage.BackgroundTransparency = 1
                buttonImage.Position = UDim2.fromScale(1, 0.5)
                buttonImage.Size = UDim2.fromOffset(15, 15)
                buttonImage.Parent = buttonFrame
                
                -- 悬停效果
                buttonInteract.MouseEnter:Connect(function()
                    TweenService:Create(buttonInteract, TweenInfo.new(0.2), {
                        TextTransparency = 0.3
                    }):Play()
                    TweenService:Create(buttonImage, TweenInfo.new(0.2), {
                        ImageTransparency = 0.3
                    }):Play()
                end)
                
                buttonInteract.MouseLeave:Connect(function()
                    TweenService:Create(buttonInteract, TweenInfo.new(0.2), {
                        TextTransparency = 0.5
                    }):Play()
                    TweenService:Create(buttonImage, TweenInfo.new(0.2), {
                        ImageTransparency = 0.5
                    }):Play()
                end)
                
                buttonInteract.MouseButton1Click:Connect(function()
                    if buttonSettings.Callback then
                        buttonSettings.Callback()
                    end
                end)
                
                buttonFrame.Parent = sectionFrame
                
                if flag then
                    MacUIAdaptive.Options[flag] = Button
                end
                
                return Button
            end
            
            --// 开关
            function Section:Toggle(toggleSettings, flag)
                local Toggle = {Settings = toggleSettings, Value = toggleSettings.Default}
                
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = "Toggle"
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.AutomaticSize = Enum.AutomaticSize.Y
                toggleFrame.Size = UDim2.new(1, 0, 0, 38)
                
                local toggleName = Instance.new("TextLabel")
                toggleName.Name = "ToggleName"
                toggleName.FontFace = Font.new(assets.interFont)
                toggleName.Text = toggleSettings.Name
                toggleName.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleName.TextSize = deviceConfig.FontSize.Element
                toggleName.TextTransparency = 0.5
                toggleName.TextXAlignment = Enum.TextXAlignment.Left
                toggleName.BackgroundTransparency = 1
                toggleName.Size = UDim2.new(1, -50, 0, 0)
                toggleName.AutomaticSize = Enum.AutomaticSize.Y
                toggleName.Parent = toggleFrame
                
                local toggleButton = Instance.new("ImageButton")
                toggleButton.Name = "Toggle"
                toggleButton.Image = assets.toggleBackground
                toggleButton.ImageColor3 = toggleSettings.Default and Color3.fromRGB(119, 174, 94) or Color3.fromRGB(87, 86, 86)
                toggleButton.ImageTransparency = 0.5
                toggleButton.AutoButtonColor = false
                toggleButton.AnchorPoint = Vector2.new(1, 0.5)
                toggleButton.BackgroundTransparency = 1
                toggleButton.Position = UDim2.fromScale(1, 0.5)
                toggleButton.Size = UDim2.fromOffset(41, 21)
                
                local togglePadding = Instance.new("UIPadding")
                togglePadding.PaddingBottom = UDim.new(0, 1)
                togglePadding.PaddingLeft = UDim.new(0, -2)
                togglePadding.PaddingRight = UDim.new(0, 3)
                togglePadding.PaddingTop = UDim.new(0, 1)
                togglePadding.Parent = toggleButton
                
                local toggleHead = Instance.new("ImageLabel")
                toggleHead.Name = "ToggleHead"
                toggleHead.Image = assets.togglerHead
                toggleHead.ImageColor3 = Color3.fromRGB(255, 255, 255)
                toggleHead.ImageTransparency = 0.8
                toggleHead.AnchorPoint = Vector2.new(1, 0.5)
                toggleHead.BackgroundTransparency = 1
                toggleHead.Position = UDim2.new(toggleSettings.Default and 1 or 0.5, 0, 0.5, 0)
                toggleHead.Size = UDim2.fromOffset(15, 15)
                toggleHead.ZIndex = 2
                toggleHead.Parent = toggleButton
                
                toggleButton.Parent = toggleFrame
                
                local function setState(state)
                    Toggle.Value = state
                    TweenService:Create(toggleButton, TweenInfo.new(0.15), {
                        ImageColor3 = state and Color3.fromRGB(119, 174, 94) or Color3.fromRGB(87, 86, 86)
                    }):Play()
                    TweenService:Create(toggleHead, TweenInfo.new(0.15), {
                        Position = UDim2.new(state and 1 or 0.5, 0, 0.5, 0)
                    }):Play()
                end
                
                toggleButton.MouseButton1Click:Connect(function()
                    setState(not Toggle.Value)
                    if toggleSettings.Callback then
                        toggleSettings.Callback(Toggle.Value)
                    end
                end)
                
                toggleFrame.Parent = sectionFrame
                
                if flag then
                    MacUIAdaptive.Options[flag] = Toggle
                end
                
                return Toggle
            end
            
            return Section
        end
        
        -- 默认激活第一个标签
        if #tabSwitchers:GetChildren() == 1 then
            activateTab()
        end
        
        return Tab
    end
    
    -- 返回窗口对象
    return Window
end

--// 初始化
MacUIAdaptive:DetectDevice()

return MacUIAdaptive