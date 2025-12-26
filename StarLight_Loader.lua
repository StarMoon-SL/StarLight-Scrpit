local CrystalLib = {
    LocalPlayer = nil,
    DevicePlatform = nil,
    IsMobile = false,
    IsRobloxFocused = true,
    ScreenGui = nil,
    SearchText = "",
    Searching = false,
    GlobalSearch = false,
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
    Labels = {},
    Buttons = {},
    Toggles = {},
    Options = {},
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
    CornerRadius = 10,
    IsLightTheme = false,
    Scheme = {
        BackgroundColor = Color3.fromRGB(15, 15, 15),
        MainColor = Color3.fromRGB(255, 255, 255),
        AccentColor = Color3.fromRGB(255, 255, 255),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        FontColor = Color3.fromRGB(255, 255, 255),
        Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Red = Color3.fromRGB(255, 50, 50),
        Dark = Color3.new(0, 0, 0),
        White = Color3.new(1, 1, 1),
    },
    Registry = {},
    DPIRegistry = {},
}

local BaseURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"

local CrystalImageManager = {}
CrystalImageManager.Assets = {
    TransparencyTexture = {
        RobloxId = 139785960036434,
        Path = "CrystalLib/assets/TransparencyTexture.png",
        URL = BaseURL .. "assets/TransparencyTexture.png",
        Id = nil,
    },
    SaturationMap = {
        RobloxId = 4155801252,
        Path = "CrystalLib/assets/SaturationMap.png",
        URL = BaseURL .. "assets/SaturationMap.png",
        Id = nil,
    }
}

CrystalLib.ImageManager = CrystalImageManager

function CrystalLib:UpdateKeybindFrame()
    if not self.KeybindFrame then return end
    local XSize = 0
    for _, KeybindToggle in pairs(self.KeybindToggles) do
        if not KeybindToggle.Holder.Visible then continue end
        local FullSize = KeybindToggle.Label.Size.X.Offset + KeybindToggle.Label.Position.X.Offset
        if FullSize > XSize then XSize = FullSize end
    end
    self.KeybindFrame.Size = UDim2.fromOffset(XSize + 18 * self.DPIScale, 0)
end

function CrystalLib:UpdateDependencyBoxes()
    for _, Depbox in pairs(self.DependencyBoxes) do Depbox:Update(true) end
    if self.Searching then self:UpdateSearch(self.SearchText) end
end

function CrystalLib:UpdateSearch(SearchText)
    self.SearchText = SearchText
    local TabsToReset = {}
    if self.GlobalSearch then
        for _, Tab in pairs(self.Tabs) do
            if typeof(Tab) == "table" and not Tab.IsKeyTab then table.insert(TabsToReset, Tab) end
        end
    elseif self.LastSearchTab and typeof(self.LastSearchTab) == "table" then
        table.insert(TabsToReset, self.LastSearchTab)
    end
    local function ResetTab(Tab)
        if not Tab then return end
        for _, Groupbox in pairs(Tab.Groupboxes) do
            for _, ElementInfo in pairs(Groupbox.Elements) do
                ElementInfo.Holder.Visible = typeof(ElementInfo.Visible) == "boolean" and ElementInfo.Visible or true
                if ElementInfo.SubButton then
                    ElementInfo.Base.Visible = ElementInfo.Visible
                    ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                end
            end
            for _, Depbox in pairs(Groupbox.DependencyBoxes) do
                if not Depbox.Visible then continue end
                self:RestoreDepbox(Depbox)
            end
            Groupbox:Resize()
            Groupbox.Holder.Visible = true
        end
        for _, Tabbox in pairs(Tab.Tabboxes) do
            for _, SubTab in pairs(Tabbox.Tabs) do
                for _, ElementInfo in pairs(SubTab.Elements) do
                    ElementInfo.Holder.Visible = typeof(ElementInfo.Visible) == "boolean" and ElementInfo.Visible or true
                    if ElementInfo.SubButton then
                        ElementInfo.Base.Visible = ElementInfo.Visible
                        ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                    end
                end
                for _, Depbox in pairs(SubTab.DependencyBoxes) do
                    if not Depbox.Visible then continue end
                    self:RestoreDepbox(Depbox)
                end
                SubTab.ButtonHolder.Visible = true
            end
            if Tabbox.ActiveTab then Tabbox.ActiveTab:Resize() end
            Tabbox.Holder.Visible = true
        end
        for _, DepGroupbox in pairs(Tab.DependencyGroupboxes) do
            if not DepGroupbox.Visible then continue end
            for _, ElementInfo in pairs(DepGroupbox.Elements) do
                ElementInfo.Holder.Visible = typeof(ElementInfo.Visible) == "boolean" and ElementInfo.Visible or true
                if ElementInfo.SubButton then
                    ElementInfo.Base.Visible = ElementInfo.Visible
                    ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                end
            end
            for _, Depbox in pairs(DepGroupbox.DependencyBoxes) do
                if not Depbox.Visible then continue end
                self:RestoreDepbox(Depbox)
            end
            DepGroupbox:Resize()
            DepGroupbox.Holder.Visible = true
        end
    end
    for _, Tab in ipairs(TabsToReset) do ResetTab(Tab) end
    local Search = SearchText:lower()
    if Search:match("^%s*(.-)%s*$") == "" then
        self.Searching = false
        self.LastSearchTab = nil
        return
    end
    if not self.GlobalSearch and self.ActiveTab and self.ActiveTab.IsKeyTab then
        self.Searching = false
        self.LastSearchTab = nil
        return
    end
    self.Searching = true
    local TabsToSearch = {}
    if self.GlobalSearch then
        TabsToSearch = TabsToReset
        if #TabsToSearch == 0 then
            for _, Tab in pairs(self.Tabs) do
                if typeof(Tab) == "table" and not Tab.IsKeyTab then table.insert(TabsToSearch, Tab) end
            end
        end
    elseif self.ActiveTab then
        table.insert(TabsToSearch, self.ActiveTab)
    end
    local function ApplySearchToTab(Tab)
        if not Tab then return end
        local HasVisible = false
        for _, Groupbox in pairs(Tab.Groupboxes) do
            local VisibleElements = 0
            for _, ElementInfo in pairs(Groupbox.Elements) do
                if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                    ElementInfo.Holder.Visible = true
                    VisibleElements += 1
                else
                    ElementInfo.Holder.Visible = false
                    if ElementInfo.SubButton then
                        ElementInfo.Base.Visible = false
                        ElementInfo.SubButton.Base.Visible = false
                    end
                end
            end
            for _, Depbox in pairs(Groupbox.DependencyBoxes) do
                if not Depbox.Visible then continue end
                VisibleElements += self:CheckDepbox(Depbox, Search)
            end
            if VisibleElements > 0 then
                Groupbox:Resize()
                HasVisible = true
            end
            Groupbox.Holder.Visible = VisibleElements > 0
        end
        for _, Tabbox in pairs(Tab.Tabboxes) do
            local VisibleTabs = 0
            local VisibleElements = {}
            for _, SubTab in pairs(Tabbox.Tabs) do
                VisibleElements[SubTab] = 0
                for _, ElementInfo in pairs(SubTab.Elements) do
                    if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                        ElementInfo.Holder.Visible = true
                        VisibleElements[SubTab] += 1
                    else
                        ElementInfo.Holder.Visible = false
                        if ElementInfo.SubButton then
                            ElementInfo.Base.Visible = ElementInfo.Visible
                            ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                        end
                    end
                end
                for _, Depbox in pairs(SubTab.DependencyBoxes) do
                    if not Depbox.Visible then continue end
                    VisibleElements[SubTab] += self:CheckDepbox(Depbox, Search)
                end
            end
            for SubTab, Visible in pairs(VisibleElements) do
                SubTab.ButtonHolder.Visible = Visible > 0
                if Visible > 0 then
                    VisibleTabs += 1
                    HasVisible = true
                    if Tabbox.ActiveTab == SubTab then
                        SubTab:Resize()
                    elseif Tabbox.ActiveTab and VisibleElements[Tabbox.ActiveTab] == 0 then
                        SubTab:Show()
                    end
                end
            end
            Tabbox.Holder.Visible = VisibleTabs > 0
        end
        for _, DepGroupbox in pairs(Tab.DependencyGroupboxes) do
            if not DepGroupbox.Visible then continue end
            local VisibleElements = 0
            for _, ElementInfo in pairs(DepGroupbox.Elements) do
                if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                    ElementInfo.Holder.Visible = true
                    VisibleElements += 1
                else
                    ElementInfo.Holder.Visible = false
                    if ElementInfo.SubButton then
                        ElementInfo.Base.Visible = ElementInfo.Visible
                        ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                    end
                end
            end
            for _, Depbox in pairs(DepGroupbox.DependencyBoxes) do
                if not Depbox.Visible then continue end
                VisibleElements += self:CheckDepbox(Depbox, Search)
            end
            if VisibleElements > 0 then
                DepGroupbox:Resize()
                HasVisible = true
            end
            DepGroupbox.Holder.Visible = VisibleElements > 0
        end
        return HasVisible
    end
    local FirstVisibleTab = nil
    local ActiveHasVisible = false
    for _, Tab in ipairs(TabsToSearch) do
        local HasVisible = ApplySearchToTab(Tab)
        if HasVisible and not FirstVisibleTab then FirstVisibleTab = Tab end
        if Tab == self.ActiveTab then ActiveHasVisible = true end
    end
    if self.GlobalSearch then
        if ActiveHasVisible and self.ActiveTab then
            self.ActiveTab:RefreshSides()
        elseif FirstVisibleTab then
            local SearchMarker = SearchText
            task.defer(function()
                if self.SearchText ~= SearchMarker then return end
                if self.ActiveTab ~= FirstVisibleTab then FirstVisibleTab:Show() end
            end)
        end
        self.LastSearchTab = nil
    else
        self.LastSearchTab = self.ActiveTab
    end
end

function CrystalLib:CheckDepbox(Box, Search)
    local VisibleElements = 0
    for _, ElementInfo in pairs(Box.Elements) do
        if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
            VisibleElements += 1
        end
    end
    for _, Depbox in pairs(Box.DependencyBoxes) do
        if not Depbox.Visible then continue end
        VisibleElements += self:CheckDepbox(Depbox, Search)
    end
    return VisibleElements
end

function CrystalLib:RestoreDepbox(Box)
    for _, ElementInfo in pairs(Box.Elements) do
        ElementInfo.Holder.Visible = typeof(ElementInfo.Visible) == "boolean" and ElementInfo.Visible or true
    end
    Box:Resize()
    Box.Holder.Visible = true
    for _, Depbox in pairs(Box.DependencyBoxes) do
        if not Depbox.Visible then continue end
        self:RestoreDepbox(Depbox)
    end
end

function CrystalLib:AddToRegistry(Instance, Properties)
    self.Registry[Instance] = Properties
end

function CrystalLib:RemoveFromRegistry(Instance)
    self.Registry[Instance] = nil
end

function CrystalLib:UpdateColorsUsingRegistry()
    for Instance, Properties in pairs(self.Registry) do
        for Property, ColorIdx in pairs(Properties) do
            if typeof(ColorIdx) == "string" then
                Instance[Property] = self.Scheme[ColorIdx]
            elseif typeof(ColorIdx) == "function" then
                Instance[Property] = ColorIdx()
            end
        end
    end
end

function CrystalLib:UpdateDPI(Instance, Properties)
    if not self.DPIRegistry[Instance] then return end
    for Property, Value in pairs(Properties) do
        self.DPIRegistry[Instance][Property] = Value and Value or nil
    end
end

function CrystalLib:SetDPIScale(DPIScale)
    self.DPIScale = DPIScale / 100
    self.MinSize *= self.DPIScale
    for Instance, Properties in pairs(self.DPIRegistry) do
        for Property, Value in pairs(Properties) do
            if Property == "DPIExclude" or Property == "DPIOffset" then continue
            elseif Property == "TextSize" then
                Instance[Property] = Value * self.DPIScale
            else
                Instance[Property] = UDim2.new(Value.X.Scale, Value.X.Offset * self.DPIScale, Value.Y.Scale, Value.Y.Offset * self.DPIScale)
            end
        end
    end
    for _, Tab in pairs(self.Tabs) do
        if Tab.IsKeyTab then continue end
        Tab:Resize(true)
        for _, Groupbox in pairs(Tab.Groupboxes) do Groupbox:Resize() end
        for _, Tabbox in pairs(Tab.Tabboxes) do
            for _, SubTab in pairs(Tabbox.Tabs) do SubTab:Resize() end
        end
    end
    for _, Option in pairs(self.Options) do
        if Option.Type == "Dropdown" then Option:RecalculateListSize()
        elseif Option.Type == "KeyPicker" then Option:Update() end
    end
    self:UpdateKeybindFrame()
    for _, Notification in pairs(self.Notifications) do Notification:Resize() end
end

function CrystalLib:GiveSignal(Connection)
    if Connection and (typeof(Connection) == "RBXScriptConnection" or typeof(Connection) == "RBXScriptSignal") then
        table.insert(self.Signals, Connection)
    end
    return Connection
end

function CrystalLib:GetTextBounds(Text, Font, Size, Width)
    local Params = Instance.new("GetTextBoundsParams")
    Params.Text = Text
    Params.RichText = true
    Params.Font = Font
    Params.Size = Size
    Params.Width = Width or workspace.CurrentCamera.ViewportSize.X - 32
    local Bounds = game:GetService("TextService"):GetTextBoundsAsync(Params)
    return Bounds.X, Bounds.Y
end

function CrystalLib:SafeCallback(Func, ...)
    if not (Func and typeof(Func) == "function") then return end
    local Result = table.pack(xpcall(Func, function(Error)
        task.defer(error, debug.traceback(Error, 2))
        if self.NotifyOnError then self:Notify(Error) end
        return Error
    end, ...))
    if not Result[1] then return nil end
    return table.unpack(Result, 2, Result.n)
end

function CrystalLib:MakeDraggable(UI, DragFrame, IgnoreToggled, IsMainWindow)
    local StartPos, FramePos, Dragging, Changed
    DragFrame.InputBegan:Connect(function(Input)
        if not (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) or IsMainWindow and self.CantDragForced then return end
        StartPos = Input.Position
        FramePos = UI.Position
        Dragging = true
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then return end
            Dragging = false
            if Changed and Changed.Connected then Changed:Disconnect() Changed = nil end
        end)
    end)
    self:GiveSignal(game:GetService("UserInputService").InputChanged:Connect(function(Input)
        if (not IgnoreToggled and not self.Toggled) or (IsMainWindow and self.CantDragForced) or not (self.ScreenGui and self.ScreenGui.Parent) then
            Dragging = false
            if Changed and Changed.Connected then Changed:Disconnect() Changed = nil end
            return
        end
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = Input.Position - StartPos
            UI.Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
        end
    end))
end

function CrystalLib:MakeResizable(UI, DragFrame, Callback)
    local StartPos, FrameSize, Dragging, Changed
    DragFrame.InputBegan:Connect(function(Input)
        if not (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then return end
        StartPos = Input.Position
        FrameSize = UI.Size
        Dragging = true
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then return end
            Dragging = false
            if Changed and Changed.Connected then Changed:Disconnect() Changed = nil end
        end)
    end)
    self:GiveSignal(game:GetService("UserInputService").InputChanged:Connect(function(Input)
        if not UI.Visible or not (self.ScreenGui and self.ScreenGui.Parent) then
            Dragging = false
            if Changed and Changed.Connected then Changed:Disconnect() Changed = nil end
            return
        end
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = Input.Position - StartPos
            UI.Size = UDim2.new(FrameSize.X.Scale, math.clamp(FrameSize.X.Offset + Delta.X, self.MinSize.X, math.huge), FrameSize.Y.Scale, math.clamp(FrameSize.Y.Offset + Delta.Y, self.MinSize.Y, math.huge))
            if Callback then self:SafeCallback(Callback) end
        end
    end))
end

function CrystalLib:AddContextMenu(Holder, Size, Offset, List, ActiveCallback)
    local Menu
    if List then
        Menu = Instance.new("ScrollingFrame")
        Menu.AutomaticCanvasSize = List == 2 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
        Menu.AutomaticSize = List == 1 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
        Menu.BackgroundColor3 = self.Scheme.BackgroundColor
        Menu.BackgroundTransparency = 0.05
        Menu.BorderSizePixel = 0
        Menu.BottomImage = ""
        Menu.CanvasSize = UDim2.fromOffset(0, 0)
        Menu.ScrollBarImageTransparency = 0.8
        Menu.ScrollBarThickness = List == 2 and 2 or 0
        Menu.Size = typeof(Size) == "function" and Size() or Size
        Menu.TopImage = ""
        Menu.Visible = false
        Menu.ZIndex = 10
        Menu.Parent = self.ScreenGui
    else
        Menu = Instance.new("Frame")
        Menu.BackgroundColor3 = self.Scheme.BackgroundColor
        Menu.BackgroundTransparency = 0.05
        Menu.BorderSizePixel = 0
        Menu.Size = typeof(Size) == "function" and Size() or Size
        Menu.Visible = false
        Menu.ZIndex = 10
        Menu.Parent = self.ScreenGui
    end
    local Table = {Active = false, Holder = Holder, Menu = Menu, List = nil, Signal = nil, Size = Size}
    if List then
        Table.List = Instance.new("UIListLayout")
        Table.List.Parent = Menu
    end
    function Table:Open()
        if CrystalLib.CurrentMenu == self then return
        elseif CrystalLib.CurrentMenu then CrystalLib.CurrentMenu:Close() end
        CrystalLib.CurrentMenu = self
        self.Active = true
        if typeof(Offset) == "function" then
            Menu.Position = UDim2.fromOffset(math.floor(Holder.AbsolutePosition.X + Offset()[1]), math.floor(Holder.AbsolutePosition.Y + Offset()[2]))
        else
            Menu.Position = UDim2.fromOffset(math.floor(Holder.AbsolutePosition.X + Offset[1]), math.floor(Holder.AbsolutePosition.Y + Offset[2]))
        end
        if typeof(self.Size) == "function" then Menu.Size = self.Size() else Menu.Size = self.Size end
        if typeof(ActiveCallback) == "function" then self:SafeCallback(ActiveCallback, true) end
        Menu.Visible = true
        self.Signal = Holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            if typeof(Offset) == "function" then
                Menu.Position = UDim2.fromOffset(math.floor(Holder.AbsolutePosition.X + Offset()[1]), math.floor(Holder.AbsolutePosition.Y + Offset()[2]))
            else
                Menu.Position = UDim2.fromOffset(math.floor(Holder.AbsolutePosition.X + Offset[1]), math.floor(Holder.AbsolutePosition.Y + Offset[2]))
            end
        end)
    end
    function Table:Close()
        if CrystalLib.CurrentMenu ~= self then return end
        Menu.Visible = false
        if self.Signal then self.Signal:Disconnect() self.Signal = nil end
        self.Active = false
        CrystalLib.CurrentMenu = nil
        if typeof(ActiveCallback) == "function" then self:SafeCallback(ActiveCallback, false) end
    end
    function Table:Toggle()
        if self.Active then self:Close() else self:Open() end
    end
    function Table:SetSize(Size)
        self.Size = Size
        Menu.Size = typeof(Size) == "function" and Size() or Size
    end
    return Table
end

function CrystalLib:Unload()
    for Index = #self.Signals, 1, -1 do
        local Connection = table.remove(self.Signals, Index)
        if Connection and Connection.Connected then Connection:Disconnect() end
    end
    for _, Callback in self.UnloadSignals do self:SafeCallback(Callback) end
    self.Unloaded = true
    self.ScreenGui:Destroy()
    getgenv().CrystalLib = nil
end

function CrystalLib:CreateWindow(Properties)
    local Properties = Properties or {}
    local Window = {
        CrystalLib = self,
        Name = Properties.Name or "CrystalLib Window",
        Size = Properties.Size or UDim2.fromOffset(868, 650),
        Position = Properties.Position or UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0.05,
        Visible = true,
        Draggable = true,
        Resizable = Properties.Resizable ~= false,
        Tabs = {},
        ActiveTab = nil,
        Scaling = 1,
    }
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrystalLib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 100
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ScreenInsets = Enum.ScreenInsets.None
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("CoreGui")
    self.ScreenGui = ScreenGui
    
    local Base = Instance.new("Frame")
    Base.Name = "Base"
    Base.AnchorPoint = Window.AnchorPoint
    Base.BackgroundColor3 = self.Scheme.BackgroundColor
    Base.BackgroundTransparency = Window.BackgroundTransparency
    Base.BorderSizePixel = 0
    Base.Position = Window.Position
    Base.Size = Window.Size
    Base.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, self.CornerRadius)
    UICorner.Parent = Base
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = self.Scheme.OutlineColor
    UIStroke.Transparency = 0.9
    UIStroke.Parent = Base
    
    Window.Base = Base
    
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.Size = UDim2.fromScale(0.325, 1)
    Sidebar.Parent = Base
    
    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Name = "Divider"
    SidebarDivider.AnchorPoint = Vector2.new(1, 0)
    SidebarDivider.BackgroundColor3 = self.Scheme.OutlineColor
    SidebarDivider.BackgroundTransparency = 0.9
    SidebarDivider.BorderSizePixel = 0
    SidebarDivider.Position = UDim2.fromScale(1, 0)
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    SidebarDivider.Parent = Sidebar
    
    local WindowControls = Instance.new("Frame")
    WindowControls.Name = "WindowControls"
    WindowControls.BackgroundTransparency = 1
    WindowControls.BorderSizePixel = 0
    WindowControls.Size = UDim2.new(1, 0, 0, 31)
    WindowControls.Parent = Sidebar
    
    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.BackgroundTransparency = 1
    Controls.BorderSizePixel = 0
    Controls.Size = UDim2.fromScale(1, 1)
    Controls.Parent = WindowControls
    
    local ControlsList = Instance.new("UIListLayout")
    ControlsList.Padding = UDim.new(0, 5)
    ControlsList.FillDirection = Enum.FillDirection.Horizontal
    ControlsList.SortOrder = Enum.SortOrder.LayoutOrder
    ControlsList.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsList.Parent = Controls
    
    local ControlsPadding = Instance.new("UIPadding")
    ControlsPadding.PaddingLeft = UDim.new(0, 11)
    ControlsPadding.Parent = Controls
    
    local function CreateWindowControl(Name, Color, Order, Enabled)
        local Button = Instance.new("TextButton")
        Button.Name = Name
        Button.Text = ""
        Button.AutoButtonColor = false
        Button.BackgroundColor3 = Color
        Button.BorderSizePixel = 0
        Button.LayoutOrder = Order
        Button.Size = Enabled and UDim2.fromOffset(8, 8) or UDim2.fromOffset(7, 7)
        Button.BackgroundTransparency = Enabled and 0 or 1
        Button.Active = Enabled
        Button.Interactable = Enabled
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(1, 0)
        Corner.Parent = Button
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = self.Scheme.OutlineColor
        Stroke.Transparency = 0.9
        Stroke.Parent = Button
        Button.Parent = Controls
        return Button
    end
    
    CreateWindowControl("Exit", Color3.fromRGB(250, 93, 86), 0, true)
    CreateWindowControl("Minimize", Color3.fromRGB(252, 190, 57), 1, true)
    CreateWindowControl("Maximize", Color3.fromRGB(119, 174, 94), 2, false)
    
    local ControlsDivider = Instance.new("Frame")
    ControlsDivider.Name = "Divider"
    ControlsDivider.AnchorPoint = Vector2.new(0, 1)
    ControlsDivider.BackgroundColor3 = self.Scheme.OutlineColor
    ControlsDivider.BackgroundTransparency = 0.9
    ControlsDivider.BorderSizePixel = 0
    ControlsDivider.Position = UDim2.fromScale(0, 1)
    ControlsDivider.Size = UDim2.new(1, 0, 0, 1)
    ControlsDivider.Parent = WindowControls
    
    local Information = Instance.new("Frame")
    Information.Name = "Information"
    Information.BackgroundTransparency = 1
    Information.BorderSizePixel = 0
    Information.Position = UDim2.fromOffset(0, 31)
    Information.Size = UDim2.new(1, 0, 0, 60)
    Information.Parent = Sidebar
    
    local InfoDivider = Instance.new("Frame")
    InfoDivider.Name = "Divider"
    InfoDivider.AnchorPoint = Vector2.new(0, 1)
    InfoDivider.BackgroundColor3 = self.Scheme.OutlineColor
    InfoDivider.BackgroundTransparency = 0.9
    InfoDivider.BorderSizePixel = 0
    InfoDivider.Position = UDim2.fromScale(0, 1)
    InfoDivider.Size = UDim2.new(1, 0, 0, 1)
    InfoDivider.Parent = Information
    
    local InfoHolder = Instance.new("Frame")
    InfoHolder.Name = "InformationHolder"
    InfoHolder.BackgroundTransparency = 1
    InfoHolder.BorderSizePixel = 0
    InfoHolder.Size = UDim2.fromScale(1, 1)
    InfoHolder.Parent = Information
    
    local InfoPadding = Instance.new("UIPadding")
    InfoPadding.PaddingBottom = UDim.new(0, 10)
    InfoPadding.PaddingLeft = UDim.new(0, 23)
    InfoPadding.PaddingRight = UDim.new(0, 22)
    InfoPadding.Parent = InfoHolder
    
    local GlobalSettingsButton = Instance.new("ImageButton")
    GlobalSettingsButton.Name = "GlobalSettingsButton"
    GlobalSettingsButton.Image = "rbxassetid://18767849817"
    GlobalSettingsButton.ImageTransparency = 0.4
    GlobalSettingsButton.AnchorPoint = Vector2.new(1, 0.5)
    GlobalSettingsButton.BackgroundTransparency = 1
    GlobalSettingsButton.BorderSizePixel = 0
    GlobalSettingsButton.Position = UDim2.fromScale(1, 0.5)
    GlobalSettingsButton.Size = UDim2.fromOffset(15, 15)
    GlobalSettingsButton.Parent = InfoHolder
    
    local TitleFrame = Instance.new("Frame")
    TitleFrame.Name = "TitleFrame"
    TitleFrame.BackgroundTransparency = 1
    TitleFrame.BorderSizePixel = 0
    TitleFrame.Size = UDim2.fromScale(1, 1)
    TitleFrame.Parent = InfoHolder
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.FontFace = self.Scheme.Font
    Title.Text = Window.Name
    Title.TextColor3 = self.Scheme.FontColor
    Title.TextSize = 20
    Title.TextTransparency = 0.2
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Top
    Title.AutomaticSize = Enum.AutomaticSize.Y
    Title.BackgroundTransparency = 1
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, -20, 0, 0)
    Title.Parent = TitleFrame
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.FontFace = self.Scheme.Font
    Subtitle.Text = ""
    Subtitle.TextColor3 = self.Scheme.FontColor
    Subtitle.TextSize = 12
    Subtitle.TextTransparency = 0.7
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.TextYAlignment = Enum.TextYAlignment.Top
    Subtitle.AutomaticSize = Enum.AutomaticSize.Y
    Subtitle.BackgroundTransparency = 1
    Subtitle.BorderSizePixel = 0
    Subtitle.LayoutOrder = 1
    Subtitle.Size = UDim2.new(1, -20, 0, 0)
    Subtitle.Parent = TitleFrame
    
    local TitleLayout = Instance.new("UIListLayout")
    TitleLayout.Padding = UDim.new(0, 3)
    TitleLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TitleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TitleLayout.Parent = TitleFrame
    
    local SidebarGroup = Instance.new("Frame")
    SidebarGroup.Name = "SidebarGroup"
    SidebarGroup.BackgroundTransparency = 1
    SidebarGroup.BorderSizePixel = 0
    SidebarGroup.Position = UDim2.fromOffset(0, 91)
    SidebarGroup.Size = UDim2.new(1, 0, 1, -91)
    SidebarGroup.Parent = Sidebar
    
    local UserInfo = Instance.new("Frame")
    UserInfo.Name = "UserInfo"
    UserInfo.AnchorPoint = Vector2.new(0, 1)
    UserInfo.BackgroundTransparency = 1
    UserInfo.BorderSizePixel = 0
    UserInfo.Position = UDim2.fromScale(0, 1)
    UserInfo.Size = UDim2.new(1, 0, 0, 107)
    UserInfo.Parent = SidebarGroup
    
    local UserInfoGroup = Instance.new("Frame")
    UserInfoGroup.Name = "InformationGroup"
    UserInfoGroup.BackgroundTransparency = 1
    UserInfoGroup.BorderSizePixel = 0
    UserInfoGroup.Size = UDim2.fromScale(1, 1)
    UserInfoGroup.Parent = UserInfo
    
    local UserInfoPadding = Instance.new("UIPadding")
    UserInfoPadding.PaddingBottom = UDim.new(0, 17)
    UserInfoPadding.PaddingLeft = UDim.new(0, 25)
    UserInfoPadding.Parent = UserInfoGroup
    
    local UserInfoLayout = Instance.new("UIListLayout")
    UserInfoLayout.FillDirection = Enum.FillDirection.Horizontal
    UserInfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UserInfoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    UserInfoLayout.Parent = UserInfoGroup
    
    local UserId = game.Players.LocalPlayer.UserId
    local ThumbType = Enum.ThumbnailType.AvatarBust
    local ThumbSize = Enum.ThumbnailSize.Size48x48
    local HeadshotImage, IsReady = game.Players:GetUserThumbnailAsync(UserId, ThumbType, ThumbSize)
    
    local Headshot = Instance.new("ImageLabel")
    Headshot.Name = "Headshot"
    Headshot.BackgroundTransparency = 1
    Headshot.BorderSizePixel = 0
    Headshot.Size = UDim2.fromOffset(32, 32)
    Headshot.Image = IsReady and HeadshotImage or "rbxassetid://0"
    Headshot.Parent = UserInfoGroup
    
    local HeadshotCorner = Instance.new("UICorner")
    HeadshotCorner.CornerRadius = UDim.new(1, 0)
    HeadshotCorner.Parent = Headshot
    
    local HeadshotStroke = Instance.new("UIStroke")
    HeadshotStroke.Color = self.Scheme.OutlineColor
    HeadshotStroke.Transparency = 0.9
    HeadshotStroke.Parent = Headshot
    
    local UserAndDisplayFrame = Instance.new("Frame")
    UserAndDisplayFrame.Name = "UserAndDisplayFrame"
    UserAndDisplayFrame.BackgroundTransparency = 1
    UserAndDisplayFrame.BorderSizePixel = 0
    UserAndDisplayFrame.LayoutOrder = 1
    UserAndDisplayFrame.Size = UDim2.new(1, -42, 0, 32)
    UserAndDisplayFrame.Parent = UserInfoGroup
    
    local DisplayName = Instance.new("TextLabel")
    DisplayName.Name = "DisplayName"
    DisplayName.FontFace = self.Scheme.Font
    DisplayName.Text = game.Players.LocalPlayer.DisplayName
    DisplayName.TextColor3 = self.Scheme.FontColor
    DisplayName.TextSize = 13
    DisplayName.TextTransparency = 0.2
    DisplayName.TextXAlignment = Enum.TextXAlignment.Left
    DisplayName.TextYAlignment = Enum.TextYAlignment.Top
    DisplayName.AutomaticSize = Enum.AutomaticSize.XY
    DisplayName.BackgroundTransparency = 1
    DisplayName.BorderSizePixel = 0
    DisplayName.Size = UDim2.fromScale(1, 0)
    DisplayName.Parent = UserAndDisplayFrame
    
    local UserAndDisplayPadding = Instance.new("UIPadding")
    UserAndDisplayPadding.PaddingLeft = UDim.new(0, 8)
    UserAndDisplayPadding.PaddingTop = UDim.new(0, 3)
    UserAndDisplayPadding.Parent = UserAndDisplayFrame
    
    local UserAndDisplayLayout = Instance.new("UIListLayout")
    UserAndDisplayLayout.Padding = UDim.new(0, 1)
    UserAndDisplayLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UserAndDisplayLayout.Parent = UserAndDisplayFrame
    
    local Username = Instance.new("TextLabel")
    Username.Name = "Username"
    Username.FontFace = self.Scheme.Font
    Username.Text = "@" .. game.Players.LocalPlayer.Name
    Username.TextColor3 = self.Scheme.FontColor
    Username.TextSize = 12
    Username.TextTransparency = 0.8
    Username.TextXAlignment = Enum.TextXAlignment.Left
    Username.TextYAlignment = Enum.TextYAlignment.Top
    Username.AutomaticSize = Enum.AutomaticSize.XY
    Username.BackgroundTransparency = 1
    Username.BorderSizePixel = 0
    Username.LayoutOrder = 1
    Username.Size = UDim2.fromScale(1, 0)
    Username.Parent = UserAndDisplayFrame
    
    local SidebarGroupPadding = Instance.new("UIPadding")
    SidebarGroupPadding.PaddingLeft = UDim.new(0, 10)
    SidebarGroupPadding.PaddingRight = UDim.new(0, 10)
    SidebarGroupPadding.PaddingTop = UDim.new(0, 31)
    SidebarGroupPadding.Parent = SidebarGroup
    
    local TabSwitchers = Instance.new("Frame")
    TabSwitchers.Name = "TabSwitchers"
    TabSwitchers.BackgroundTransparency = 1
    TabSwitchers.BorderSizePixel = 0
    TabSwitchers.Size = UDim2.new(1, 0, 1, -107)
    TabSwitchers.Parent = SidebarGroup
    
    local TabSwitchersScroll = Instance.new("ScrollingFrame")
    TabSwitchersScroll.Name = "TabSwitchersScrollingFrame"
    TabSwitchersScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabSwitchersScroll.BottomImage = ""
    TabSwitchersScroll.CanvasSize = UDim2.new()
    TabSwitchersScroll.ScrollBarImageTransparency = 0.8
    TabSwitchersScroll.ScrollBarThickness = 1
    TabSwitchersScroll.TopImage = ""
    TabSwitchersScroll.BackgroundTransparency = 1
    TabSwitchersScroll.BorderSizePixel = 0
    TabSwitchersScroll.Size = UDim2.fromScale(1, 1)
    TabSwitchersScroll.Parent = TabSwitchers
    
    local TabSwitchersLayout = Instance.new("UIListLayout")
    TabSwitchersLayout.Padding = UDim.new(0, 17)
    TabSwitchersLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabSwitchersLayout.Parent = TabSwitchersScroll
    
    local TabSwitchersPadding = Instance.new("UIPadding")
    TabSwitchersPadding.PaddingTop = UDim.new(0, 2)
    TabSwitchersPadding.Parent = TabSwitchersScroll
    
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.AnchorPoint = Vector2.new(1, 0)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.Position = UDim2.fromScale(1, 0)
    Content.Size = UDim2.fromScale(0.675, 1)
    Content.Parent = Base
    
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.BackgroundTransparency = 1
    Topbar.BorderSizePixel = 0
    Topbar.Size = UDim2.new(1, 0, 0, 63)
    Topbar.Parent = Content
    
    local TopbarDivider = Instance.new("Frame")
    TopbarDivider.Name = "Divider"
    TopbarDivider.AnchorPoint = Vector2.new(0, 1)
    TopbarDivider.BackgroundColor3 = self.Scheme.OutlineColor
    TopbarDivider.BackgroundTransparency = 0.9
    TopbarDivider.BorderSizePixel = 0
    TopbarDivider.Position = UDim2.fromScale(0, 1)
    TopbarDivider.Size = UDim2.new(1, 0, 0, 1)
    TopbarDivider.Parent = Topbar
    
    local Elements = Instance.new("Frame")
    Elements.Name = "Elements"
    Elements.BackgroundTransparency = 1
    Elements.BorderSizePixel = 0
    Elements.Size = UDim2.fromScale(1, 1)
    Elements.Parent = Topbar
    
    local ElementsPadding = Instance.new("UIPadding")
    ElementsPadding.PaddingLeft = UDim.new(0, 20)
    ElementsPadding.PaddingRight = UDim.new(0, 20)
    ElementsPadding.Parent = Elements
    
    local MoveIcon = Instance.new("ImageButton")
    MoveIcon.Name = "MoveIcon"
    MoveIcon.Image = "rbxassetid://10734900011"
    MoveIcon.ImageTransparency = 0.5
    MoveIcon.AnchorPoint = Vector2.new(1, 0.5)
    MoveIcon.BackgroundTransparency = 1
    MoveIcon.BorderSizePixel = 0
    MoveIcon.Position = UDim2.fromScale(1, 0.5)
    MoveIcon.Size = UDim2.fromOffset(15, 15)
    MoveIcon.Parent = Elements
    
    local Interact = Instance.new("TextButton")
    Interact.Name = "Interact"
    Interact.Text = ""
    Interact.BackgroundTransparency = 1
    Interact.BorderSizePixel = 0
    Interact.Position = UDim2.fromScale(0.5, 0.5)
    Interact.AnchorPoint = Vector2.new(0.5, 0.5)
    Interact.Size = UDim2.fromOffset(30, 30)
    Interact.Parent = MoveIcon
    
    local CurrentTab = Instance.new("TextLabel")
    CurrentTab.Name = "CurrentTab"
    CurrentTab.FontFace = self.Scheme.Font
    CurrentTab.Text = "Tab"
    CurrentTab.TextColor3 = self.Scheme.FontColor
    CurrentTab.TextSize = 15
    CurrentTab.TextTransparency = 0.5
    CurrentTab.TextXAlignment = Enum.TextXAlignment.Left
    CurrentTab.TextYAlignment = Enum.TextYAlignment.Top
    CurrentTab.AnchorPoint = Vector2.new(0, 0.5)
    CurrentTab.AutomaticSize = Enum.AutomaticSize.Y
    CurrentTab.BackgroundTransparency = 1
    CurrentTab.BorderSizePixel = 0
    CurrentTab.Position = UDim2.fromScale(0, 0.5)
    CurrentTab.Size = UDim2.fromScale(0.9, 0)
    CurrentTab.Parent = Elements
    
    if Window.Draggable then
        local dragging = false
        local dragInput, dragStart, startPos
        local function update(input)
            local delta = input.Position - dragStart
            Base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        Interact.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Base.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        Interact.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                dragInput = input
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == dragInput and dragging then update(input) end
        end)
    end
    
    local ContentElements = Instance.new("Frame")
    ContentElements.Name = "Elements"
    ContentElements.BackgroundTransparency = 1
    ContentElements.BorderSizePixel = 0
    ContentElements.Position = UDim2.fromOffset(0, 63)
    ContentElements.Size = UDim2.new(1, 0, 1, -63)
    ContentElements.Parent = Content
    
    local ContentElementsPadding = Instance.new("UIPadding")
    ContentElementsPadding.PaddingRight = UDim.new(0, 5)
    ContentElementsPadding.PaddingTop = UDim.new(0, 10)
    ContentElementsPadding.Parent = ContentElements
    
    local ContentElementsScrolling = Instance.new("ScrollingFrame")
    ContentElementsScrolling.Name = "ElementsScrolling"
    ContentElementsScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentElementsScrolling.BottomImage = ""
    ContentElementsScrolling.CanvasSize = UDim2.new()
    ContentElementsScrolling.ScrollBarImageTransparency = 0.5
    ContentElementsScrolling.ScrollBarThickness = 1
    ContentElementsScrolling.TopImage = ""
    ContentElementsScrolling.BackgroundTransparency = 1
    ContentElementsScrolling.BorderSizePixel = 0
    ContentElementsScrolling.Size = UDim2.fromScale(1, 1)
    ContentElementsScrolling.Parent = ContentElements
    
    local ContentElementsScrollingPadding = Instance.new("UIPadding")
    ContentElementsScrollingPadding.PaddingBottom = UDim.new(0, 15)
    ContentElementsScrollingPadding.PaddingLeft = UDim.new(0, 11)
    ContentElementsScrollingPadding.PaddingRight = UDim.new(0, 3)
    ContentElementsScrollingPadding.PaddingTop = UDim.new(0, 5)
    ContentElementsScrollingPadding.Parent = ContentElementsScrolling
    
    local ContentElementsScrollingLayout = Instance.new("UIListLayout")
    ContentElementsScrollingLayout.Padding = UDim.new(0, 15)
    ContentElementsScrollingLayout.FillDirection = Enum.FillDirection.Horizontal
    ContentElementsScrollingLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentElementsScrollingLayout.Parent = ContentElementsScrolling
    
    local Left = Instance.new("Frame")
    Left.Name = "Left"
    Left.AutomaticSize = Enum.AutomaticSize.Y
    Left.BackgroundTransparency = 1
    Left.BorderSizePixel = 0
    Left.Position = UDim2.fromScale(0.512, 0)
    Left.Size = UDim2.new(0.5, -10, 0, 0)
    Left.Parent = ContentElementsScrolling
    
    local LeftLayout = Instance.new("UIListLayout")
    LeftLayout.Padding = UDim.new(0, 15)
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LeftLayout.Parent = Left
    
    local Right = Instance.new("Frame")
    Right.Name = "Right"
    Right.AutomaticSize = Enum.AutomaticSize.Y
    Right.BackgroundTransparency = 1
    Right.BorderSizePixel = 0
    Right.LayoutOrder = 1
    Right.Position = UDim2.fromScale(0.512, 0)
    Right.Size = UDim2.new(0.5, -10, 0, 0)
    Right.Parent = ContentElementsScrolling
    
    local RightLayout = Instance.new("UIListLayout")
    RightLayout.Padding = UDim.new(0, 15)
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Parent = Right
    
    function Window:SetTitle(Title)
        Window.Name = Title
        Title.Text = Title
    end
    
    function Window:SetSubtitle(Subtitle)
        Subtitle.Text = Subtitle
    end
    
    function Window:AddTab(Settings)
        local Tab = {
            Window = Window,
            Name = Settings.Name or "Tab",
            Icon = Settings.Icon,
            Groupboxes = {},
            Tabboxes = {},
            DependencyGroupboxes = {},
        }
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TabSwitcher"
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.AnchorPoint = Vector2.new(0.5, 0)
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Position = UDim2.fromScale(0.5, 0)
        TabButton.Size = UDim2.new(1, -21, 0, 40)
        TabButton.Parent = TabSwitchersScroll
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.Parent = TabButton
        
        local TabStroke = Instance.new("UIStroke")
        TabStroke.Color = self.Scheme.OutlineColor
        TabStroke.Transparency = 1
        TabStroke.Parent = TabButton
        
        if Tab.Icon then
            local TabImage = Instance.new("ImageLabel")
            TabImage.Name = "TabImage"
            TabImage.Image = Tab.Icon
            TabImage.ImageTransparency = 0.4
            TabImage.BackgroundTransparency = 1
            TabImage.BorderSizePixel = 0
            TabImage.Size = UDim2.fromOffset(16, 16)
            TabImage.Parent = TabButton
        end
        
        local TabName = Instance.new("TextLabel")
        TabName.Name = "TabSwitcherName"
        TabName.FontFace = self.Scheme.Font
        TabName.Text = Tab.Name
        TabName.TextColor3 = self.Scheme.FontColor
        TabName.TextSize = 16
        TabName.TextTransparency = 0.4
        TabName.TextXAlignment = Enum.TextXAlignment.Left
        TabName.TextYAlignment = Enum.TextYAlignment.Top
        TabName.AutomaticSize = Enum.AutomaticSize.Y
        TabName.BackgroundTransparency = 1
        TabName.BorderSizePixel = 0
        TabName.Size = UDim2.fromScale(1, 0)
        TabName.LayoutOrder = 1
        TabName.Parent = TabButton
        
        local TabPadding = Instance.new("UIPadding")
        TabPadding.PaddingLeft = UDim.new(0, 24)
        TabPadding.PaddingRight = UDim.new(0, 35)
        TabPadding.PaddingTop = UDim.new(0, 1)
        TabPadding.Parent = TabButton
        
        local TabElements = Instance.new("Frame")
        TabElements.Name = "Elements"
        TabElements.BackgroundTransparency = 1
        TabElements.BorderSizePixel = 0
        TabElements.Position = UDim2.fromOffset(0, 63)
        TabElements.Size = UDim2.new(1, 0, 1, -63)
        TabElements.Visible = false
        TabElements.Parent = Content
        
        local TabElementsPadding = Instance.new("UIPadding")
        TabElementsPadding.PaddingRight = UDim.new(0, 5)
        TabElementsPadding.PaddingTop = UDim.new(0, 10)
        TabElementsPadding.Parent = TabElements
        
        local TabElementsScroll = Instance.new("ScrollingFrame")
        TabElementsScroll.Name = "ElementsScrolling"
        TabElementsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabElementsScroll.BottomImage = ""
        TabElementsScroll.CanvasSize = UDim2.new()
        TabElementsScroll.ScrollBarImageTransparency = 0.5
        TabElementsScroll.ScrollBarThickness = 1
        TabElementsScroll.TopImage = ""
        TabElementsScroll.BackgroundTransparency = 1
        TabElementsScroll.BorderSizePixel = 0
        TabElementsScroll.Size = UDim2.fromScale(1, 1)
        TabElementsScroll.Parent = TabElements
        
        local TabElementsScrollPadding = Instance.new("UIPadding")
        TabElementsScrollPadding.PaddingBottom = UDim.new(0, 15)
        TabElementsScrollPadding.PaddingLeft = UDim.new(0, 11)
        TabElementsScrollPadding.PaddingRight = UDim.new(0, 3)
        TabElementsScrollPadding.PaddingTop = UDim.new(0, 5)
        TabElementsScrollPadding.Parent = TabElementsScroll
        
        local TabElementsScrollLayout = Instance.new("UIListLayout")
        TabElementsScrollLayout.Padding = UDim.new(0, 15)
        TabElementsScrollLayout.FillDirection = Enum.FillDirection.Horizontal
        TabElementsScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabElementsScrollLayout.Parent = TabElementsScroll
        
        local TabLeft = Instance.new("Frame")
        TabLeft.Name = "Left"
        TabLeft.AutomaticSize = Enum.AutomaticSize.Y
        TabLeft.BackgroundTransparency = 1
        TabLeft.BorderSizePixel = 0
        TabLeft.Position = UDim2.fromScale(0.512, 0)
        TabLeft.Size = UDim2.new(0.5, -10, 0, 0)
        TabLeft.Parent = TabElementsScroll
        
        local TabLeftLayout = Instance.new("UIListLayout")
        TabLeftLayout.Padding = UDim.new(0, 15)
        TabLeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLeftLayout.Parent = TabLeft
        
        local TabRight = Instance.new("Frame")
        TabRight.Name = "Right"
        TabRight.AutomaticSize = Enum.AutomaticSize.Y
        TabRight.BackgroundTransparency = 1
        TabRight.BorderSizePixel = 0
        TabRight.LayoutOrder = 1
        TabRight.Position = UDim2.fromScale(0.512, 0)
        TabRight.Size = UDim2.new(0.5, -10, 0, 0)
        TabRight.Parent = TabElementsScroll
        
        local TabRightLayout = Instance.new("UIListLayout")
        TabRightLayout.Padding = UDim.new(0, 15)
        TabRightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabRightLayout.Parent = TabRight
        
        function Tab:Show()
            if Window.ActiveTab == Tab then return end
            if Window.ActiveTab then Window.ActiveTab:Hide() end
            Window.ActiveTab = Tab
            TabElements.Visible = true
            CurrentTab.Text = Tab.Name
            TabName.TextTransparency = 0
            TabStroke.Transparency = 0.9
            TabButton.BackgroundTransparency = 0.95
        end
        
        function Tab:Hide()
            TabElements.Visible = false
            TabName.TextTransparency = 0.4
            TabStroke.Transparency = 1
            TabButton.BackgroundTransparency = 1
        end
        
        function Tab:AddGroupbox(Settings)
            local Groupbox = {
                Tab = Tab,
                Name = Settings.Name or "Groupbox",
                Side = Settings.Side or "Left",
                Groupboxes = {},
                DependencyBoxes = {},
                Elements = {},
            }
            
            local Section = Instance.new("Frame")
            Section.Name = "Section"
            Section.AutomaticSize = Enum.AutomaticSize.Y
            Section.BackgroundTransparency = 0.98
            Section.BorderSizePixel = 0
            Section.Size = UDim2.fromScale(1, 0)
            Section.Parent = TabElementsScroll
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.Parent = Section
            
            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = self.Scheme.OutlineColor
            SectionStroke.Transparency = 0.95
            SectionStroke.Parent = Section
            
            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.Padding = UDim.new(0, 10)
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Parent = Section
            
            local SectionPadding = Instance.new("UIPadding")
            SectionPadding.PaddingBottom = UDim.new(0, 20)
            SectionPadding.PaddingLeft = UDim.new(0, 20)
            SectionPadding.PaddingRight = UDim.new(0, 18)
            SectionPadding.PaddingTop = UDim.new(0, 22)
            SectionPadding.Parent = Section
            
            Groupbox.Section = Section
            
            function Groupbox:AddButton(Properties)
                local Button = {
                    Groupbox = Groupbox,
                    Name = Properties.Name or "Button",
                    Callback = Properties.Callback or function() end,
                    Visible = true,
                }
                
                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.Name = "Button"
                ButtonFrame.AutomaticSize = Enum.AutomaticSize.Y
                ButtonFrame.BackgroundTransparency = 1
                ButtonFrame.BorderSizePixel = 0
                ButtonFrame.Size = UDim2.new(1, 0, 0, 38)
                ButtonFrame.Parent = Section
                
                local ButtonInteract = Instance.new("TextButton")
                ButtonInteract.Name = "ButtonInteract"
                ButtonInteract.FontFace = self.Scheme.Font
                ButtonInteract.Text = Button.Name
                ButtonInteract.TextColor3 = self.Scheme.FontColor
                ButtonInteract.TextSize = 13
                ButtonInteract.TextTransparency = 0.5
                ButtonInteract.BackgroundTransparency = 1
                ButtonInteract.BorderSizePixel = 0
                ButtonInteract.Size = UDim2.fromScale(1, 1)
                ButtonInteract.Parent = ButtonFrame
                
                local ButtonImage = Instance.new("ImageLabel")
                ButtonImage.Name = "ButtonImage"
                ButtonImage.Image = "rbxassetid://10709791437"
                ButtonImage.ImageTransparency = 0.5
                ButtonImage.AnchorPoint = Vector2.new(1, 0.5)
                ButtonImage.BackgroundTransparency = 1
                ButtonImage.BorderSizePixel = 0
                ButtonImage.Position = UDim2.fromScale(1, 0.5)
                ButtonImage.Size = UDim2.fromOffset(15, 15)
                ButtonImage.Parent = ButtonFrame
                
                ButtonInteract.MouseEnter:Connect(function()
                    game:GetService("TweenService"):Create(ButtonInteract, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {TextTransparency = 0.3}):Play()
                    game:GetService("TweenService"):Create(ButtonImage, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {ImageTransparency = 0.3}):Play()
                end)
                
                ButtonInteract.MouseLeave:Connect(function()
                    game:GetService("TweenService"):Create(ButtonInteract, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {TextTransparency = 0.5}):Play()
                    game:GetService("TweenService"):Create(ButtonImage, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {ImageTransparency = 0.5}):Play()
                end)
                
                ButtonInteract.MouseButton1Click:Connect(function()
                    if Button.Callback then Button.Callback() end
                end)
                
                function Button:SetName(Name)
                    Button.Name = Name
                    ButtonInteract.Text = Name
                end
                
                function Button:SetVisibility(State)
                    ButtonFrame.Visible = State
                end
                
                return Button
            end
            
            function Groupbox:AddToggle(Properties)
                local Toggle = {
                    Groupbox = Groupbox,
                    Name = Properties.Name or "Toggle",
                    Default = Properties.Default or false,
                    State = Properties.Default or false,
                    Callback = Properties.Callback or function() end,
                    Visible = true,
                }
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = "Toggle"
                ToggleFrame.AutomaticSize = Enum.AutomaticSize.Y
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.BorderSizePixel = 0
                ToggleFrame.Size = UDim2.new(1, 0, 0, 38)
                ToggleFrame.Parent = Section
                
                local ToggleName = Instance.new("TextLabel")
                ToggleName.Name = "ToggleName"
                ToggleName.FontFace = self.Scheme.Font
                ToggleName.Text = Toggle.Name
                ToggleName.TextColor3 = self.Scheme.FontColor
                ToggleName.TextSize = 13
                ToggleName.TextTransparency = 0.5
                ToggleName.TextXAlignment = Enum.TextXAlignment.Left
                ToggleName.TextYAlignment = Enum.TextYAlignment.Top
                ToggleName.AnchorPoint = Vector2.new(0, 0.5)
                ToggleName.AutomaticSize = Enum.AutomaticSize.XY
                ToggleName.BackgroundTransparency = 1
                ToggleName.BorderSizePixel = 0
                ToggleName.Position = UDim2.fromScale(0, 0.5)
                ToggleName.Size = UDim2.new(1, -50, 0, 0)
                ToggleName.Parent = ToggleFrame
                
                local ToggleSwitch = Instance.new("ImageButton")
                ToggleSwitch.Name = "Toggle"
                ToggleSwitch.Image = "rbxassetid://18772190202"
                ToggleSwitch.ImageColor3 = Color3.fromRGB(61, 61, 61)
                ToggleSwitch.AutoButtonColor = false
                ToggleSwitch.AnchorPoint = Vector2.new(1, 0.5)
                ToggleSwitch.BackgroundTransparency = 1
                ToggleSwitch.BorderSizePixel = 0
                ToggleSwitch.Position = UDim2.fromScale(1, 0.5)
                ToggleSwitch.Size = UDim2.fromOffset(41, 21)
                ToggleSwitch.Parent = ToggleFrame
                
                local TogglePadding = Instance.new("UIPadding")
                TogglePadding.PaddingBottom = UDim.new(0, 1)
                TogglePadding.PaddingLeft = UDim.new(0, -2)
                TogglePadding.PaddingRight = UDim.new(0, 3)
                TogglePadding.PaddingTop = UDim.new(0, 1)
                TogglePadding.Parent = ToggleSwitch
                
                local ToggleHead = Instance.new("ImageLabel")
                ToggleHead.Name = "TogglerHead"
                ToggleHead.Image = "rbxassetid://18772309008"
                ToggleHead.ImageColor3 = Color3.fromRGB(91, 91, 91)
                ToggleHead.AnchorPoint = Vector2.new(1, 0.5)
                ToggleHead.BackgroundTransparency = 1
                ToggleHead.BorderSizePixel = 0
                ToggleHead.Position = UDim2.fromScale(0.5, 0.5)
                ToggleHead.Size = UDim2.fromOffset(15, 15)
                ToggleHead.ZIndex = 2
                ToggleHead.Parent = ToggleSwitch
                
                local function SetState(State)
                    Toggle.State = State
                    if State then
                        game:GetService("TweenService"):Create(ToggleSwitch, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {ImageColor3 = Color3.fromRGB(87, 86, 86)}):Play()
                        game:GetService("TweenService"):Create(ToggleHead, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                        game:GetService("TweenService"):Create(ToggleHead, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Position = UDim2.fromScale(1, 0.5)}):Play()
                    else
                        game:GetService("TweenService"):Create(ToggleSwitch, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {ImageColor3 = Color3.fromRGB(61, 61, 61)}):Play()
                        game:GetService("TweenService"):Create(ToggleHead, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {ImageColor3 = Color3.fromRGB(91, 91, 91)}):Play()
                        game:GetService("TweenService"):Create(ToggleHead, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Position = UDim2.fromScale(0.5, 0.5)}):Play()
                    end
                end
                
                SetState(Toggle.State)
                
                ToggleSwitch.MouseButton1Click:Connect(function()
                    Toggle.State = not Toggle.State
                    SetState(Toggle.State)
                    if Toggle.Callback then Toggle.Callback(Toggle.State) end
                end)
                
                function Toggle:SetState(State)
                    Toggle.State = State
                    SetState(State)
                    if Toggle.Callback then Toggle.Callback(State) end
                end
                
                function Toggle:GetState()
                    return Toggle.State
                end
                
                function Toggle:SetName(Name)
                    Toggle.Name = Name
                    ToggleName.Text = Name
                end
                
                function Toggle:SetVisibility(State)
                    ToggleFrame.Visible = State
                end
                
                return Toggle
            end
            
            function Groupbox:AddSlider(Properties)
                local Slider = {
                    Groupbox = Groupbox,
                    Name = Properties.Name or "Slider",
                    Min = Properties.Min or 0,
                    Max = Properties.Max or 100,
                    Value = Properties.Default or 50,
                    DisplayMethod = Properties.DisplayMethod or "Value",
                    Callback = Properties.Callback or function() end,
                    Visible = true,
                }
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = "Slider"
                SliderFrame.AutomaticSize = Enum.AutomaticSize.Y
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Size = UDim2.new(1, 0, 0, 38)
                SliderFrame.Parent = Section
                
                local SliderName = Instance.new("TextLabel")
                SliderName.Name = "SliderName"
                SliderName.FontFace = self.Scheme.Font
                SliderName.Text = Slider.Name
                SliderName.TextColor3 = self.Scheme.FontColor
                SliderName.TextSize = 13
                SliderName.TextTransparency = 0.5
                SliderName.TextXAlignment = Enum.TextXAlignment.Left
                SliderName.TextYAlignment = Enum.TextYAlignment.Top
                SliderName.Anchor Point = Vector2.new(0, 0.5)
                SliderName.AutomaticSize = Enum.AutomaticSize.XY
                SliderName.BackgroundTransparency = 1
                SliderName.BorderSizePixel = 0
                SliderName.Position = UDim2.fromScale(0, 0.5)
                SliderName.Parent = SliderFrame
                
                local SliderElements = Instance.new("Frame")
                SliderElements.Name = "SliderElements"
                SliderElements.AnchorPoint = Vector2.new(1, 0)
                SliderElements.BackgroundTransparency = 1
                SliderElements.BorderSizePixel = 0
                SliderElements.Position = UDim2.fromScale(1, 0)
                SliderElements.Size = UDim2.fromScale(1, 1)
                SliderElements.Parent = SliderFrame
                
                local SliderValue = Instance.new("TextBox")
                SliderValue.Name = "SliderValue"
                SliderValue.FontFace = self.Scheme.Font
                SliderValue.Text = tostring(Slider.Value)
                SliderValue.TextColor3 = self.Scheme.FontColor
                SliderValue.TextSize = 12
                SliderValue.TextTransparency = 0.4
                SliderValue.BackgroundTransparency = 0.95
                SliderValue.BorderSizePixel = 0
                SliderValue.LayoutOrder = 1
                SliderValue.Position = UDim2.fromScale(-0.0789, 0.171)
                SliderValue.Size = UDim2.fromOffset(41, 21)
                SliderValue.Parent = SliderElements
                
                local SliderValueCorner = Instance.new("UICorner")
                SliderValueCorner.CornerRadius = UDim.new(0, 4)
                SliderValueCorner.Parent = SliderValue
                
                local SliderValueStroke = Instance.new("UIStroke")
                SliderValueStroke.Color = self.Scheme.OutlineColor
                SliderValueStroke.Transparency = 0.9
                SliderValueStroke.Parent = SliderValue
                
                local SliderValuePadding = Instance.new("UIPadding")
                SliderValuePadding.PaddingLeft = UDim.new(0, 2)
                SliderValuePadding.PaddingRight = UDim.new(0, 2)
                SliderValuePadding.Parent = SliderValue
                
                local SliderElementsLayout = Instance.new("UIListLayout")
                SliderElementsLayout.Padding = UDim.new(0, 20)
                SliderElementsLayout.FillDirection = Enum.FillDirection.Horizontal
                SliderElementsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                SliderElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                SliderElementsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                SliderElementsLayout.Parent = SliderElements
                
                local SliderBar = Instance.new("ImageLabel")
                SliderBar.Name = "SliderBar"
                SliderBar.Image = "rbxassetid://18772615246"
                SliderBar.ImageColor3 = Color3.fromRGB(87, 86, 86)
                SliderBar.BackgroundTransparency = 1
                SliderBar.BorderSizePixel = 0
                SliderBar.Position = UDim2.fromScale(0.219, 0.457)
                SliderBar.Size = UDim2.fromOffset(123, 3)
                SliderBar.Parent = SliderElements
                
                local SliderHead = Instance.new("ImageButton")
                SliderHead.Name = "SliderHead"
                SliderHead.Image = "rbxassetid://18772834246"
                SliderHead.Anchor Point = Vector2.new(0.5, 0.5)
                SliderHead.BackgroundTransparency = 1
                SliderHead.BorderSizePixel = 0
                SliderHead.Position = UDim2.fromScale((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0.5)
                SliderHead.Size = UDim2.fromOffset(12, 12)
                SliderHead.Parent = SliderBar
                
                local SliderElementsPadding = Instance.new("UIPadding")
                SliderElementsPadding.PaddingTop = UDim.new(0, 3)
                SliderElementsPadding.Parent = SliderElements
                
                local dragging = false
                
                local DisplayMethods = {
                    Hundredths = function(value) return string.format("%.2f", value) end,
                    Tenths = function(value) return string.format("%.1f", value) end,
                    Round = function(value) return tostring(math.round(value)) end,
                    Degrees = function(value) return tostring(math.round(value)) .. "°" end,
                    Percent = function(value) return tostring(math.round((value - Slider.Min) / (Slider.Max - Slider.Min) * 100)) .. "%" end,
                    Value = function(value) return tostring(value) end,
                }
                
                local function SetValue(val, ignorecallback)
                    local posXScale
                    if typeof(val) == "Instance" then
                        local input = val
                        posXScale = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    else
                        local value = val
                        posXScale = (value - Slider.Min) / (Slider.Max - Slider.Min)
                    end
                    SliderHead.Position = UDim2.new(posXScale, 0, 0.5, 0)
                    Slider.Value = posXScale * (Slider.Max - Slider.Min) + Slider.Min
                    SliderValue.Text = DisplayMethods[Slider.DisplayMethod](Slider.Value)
                    if not ignorecallback and Slider.Callback then Slider.Callback(Slider.Value) end
                end
                
                SetValue(Slider.Value, true)
                
                SliderHead.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        SetValue(input)
                    end
                end)
                
                SliderHead.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                SliderValue.FocusLost:Connect(function(enterPressed)
                    local value = tonumber(SliderValue.Text)
                    if value then
                        value = math.clamp(value, Slider.Min, Slider.Max)
                        SetValue(value)
                    else
                        SliderValue.Text = DisplayMethods[Slider.DisplayMethod](Slider.Value)
                    end
                end)
                
                game:GetService("UserInputService").InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        SetValue(input)
                    end
                end)
                
                local function updateSliderBarSize()
                    local padding = SliderElementsLayout.Padding.Offset
                    local sliderValueWidth = SliderValue.AbsoluteSize.X
                    local sliderNameWidth = SliderName.AbsoluteSize.X
                    local totalWidth = SliderElements.AbsoluteSize.X
                    local newBarWidth = totalWidth - (padding + sliderValueWidth + sliderNameWidth + 20)
                    SliderBar.Size = UDim2.new(SliderBar.Size.X.Scale, newBarWidth, SliderBar.Size.Y.Scale, SliderBar.Size.Y.Offset)
                end
                
                updateSliderBarSize()
                SliderName:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSliderBarSize)
                Section:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSliderBarSize)
                
                function Slider:SetValue(Value)
                    SetValue(Value)
                end
                
                function Slider:GetValue()
                    return Slider.Value
                end
                
                function Slider:SetName(Name)
                    Slider.Name = Name
                    SliderName.Text = Name
                end
                
                function Slider:SetVisibility(State)
                    SliderFrame.Visible = State
                end
                
                return Slider
            end
            
            function Groupbox:AddDropdown(Properties)
                local Dropdown = {
                    Groupbox = Groupbox,
                    Name = Properties.Name or "Dropdown",
                    Options = Properties.Options or {},
                    Multi = Properties.Multi or false,
                    Search = Properties.Search or false,
                    Required = Properties.Required or false,
                    Default = Properties.Default,
                    Visible = true,
                    Value = Properties.Multi and {} or nil,
                }
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = "Dropdown"
                DropdownFrame.BackgroundTransparency = 0.985
                DropdownFrame.BorderSizePixel = 0
                DropdownFrame.ClipsDescendants = true
                DropdownFrame.Size = UDim2.new(1, 0, 0, 38)
                DropdownFrame.Parent = Section
                
                local DropdownPadding = Instance.new("UIPadding")
                DropdownPadding.PaddingLeft = UDim.new(0, 15)
                DropdownPadding.PaddingRight = UDim.new(0, 15)
                DropdownPadding.Parent = DropdownFrame
                
                local Interact = Instance.new("TextButton")
                Interact.Name = "Interact"
                Interact.Text = ""
                Interact.BackgroundTransparency = 1
                Interact.BorderSizePixel = 0
                Interact.Size = UDim2.new(1, 0, 0, 38)
                Interact.Parent = DropdownFrame
                
                local DropdownName = Instance.new("TextLabel")
                DropdownName.Name = "DropdownName"
                DropdownName.FontFace = self.Scheme.Font
                DropdownName.Text = Dropdown.Name
                DropdownName.TextColor3 = self.Scheme.FontColor
                DropdownName.TextSize = 13
                DropdownName.TextTransparency = 0.5
                DropdownName.TextXAlignment = Enum.TextXAlignment.Left
                DropdownName.AutomaticSize = Enum.AutomaticSize.Y
                DropdownName.BackgroundTransparency = 1
                DropdownName.BorderSizePixel = 0
                DropdownName.Size = UDim2.new(1, -20, 0, 38)
                DropdownName.Parent = DropdownFrame
                
                local DropdownStroke = Instance.new("UIStroke")
                DropdownStroke.Color = self.Scheme.OutlineColor
                DropdownStroke.Transparency = 0.95
                DropdownStroke.Parent = DropdownFrame
                
                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, 6)
                DropdownCorner.Parent = DropdownFrame
                
                local DropdownImage = Instance.new("ImageLabel")
                DropdownImage.Name = "DropdownImage"
                DropdownImage.Image = "rbxassetid://18865373378"
                DropdownImage.ImageTransparency = 0.5
                DropdownImage.AnchorPoint = Vector2.new(1, 0)
                DropdownImage.BackgroundTransparency = 1
                DropdownImage.BorderSizePixel = 0
                DropdownImage.Position = UDim2.new(1, 0, 0, 12)
                DropdownImage.Size = UDim2.fromOffset(14, 14)
                DropdownImage.Parent = DropdownFrame
                
                local DropdownContent = Instance.new("Frame")
                DropdownContent.Name = "DropdownFrame"
                DropdownContent.BackgroundTransparency = 1
                DropdownContent.BorderSizePixel = 0
                DropdownContent.ClipsDescendants = true
                DropdownContent.Size = UDim2.fromScale(1, 1)
                DropdownContent.Visible = false
                DropdownContent.AutomaticSize = Enum.AutomaticSize.Y
                DropdownContent.Parent = DropdownFrame
                
                local DropdownContentPadding = Instance.new("UIPadding")
                DropdownContentPadding.PaddingBottom = UDim.new(0, 10)
                DropdownContentPadding.PaddingTop = UDim.new(0, 38)
                DropdownContentPadding.Parent = DropdownContent
                
                local DropdownContentLayout = Instance.new("UIListLayout")
                DropdownContentLayout.Padding = UDim.new(0, 5)
                DropdownContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownContentLayout.Parent = DropdownContent
                
                local Search = Instance.new("Frame")
                Search.Name = "Search"
                Search.BackgroundTransparency = 0.95
                Search.BorderSizePixel = 0
                Search.LayoutOrder = -1
                Search.Size = UDim2.new(1, 0, 0, 30)
                Search.Parent = DropdownContent
                Search.Visible = Dropdown.Search
                
                local SearchCorner = Instance.new("UICorner")
                SearchCorner.Parent = Search
                
                local SearchIcon = Instance.new("ImageLabel")
                SearchIcon.Name = "SearchIcon"
                SearchIcon.Image = "rbxassetid://86737463322606"
                SearchIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
                SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
                SearchIcon.BackgroundTransparency = 1
                SearchIcon.BorderSizePixel = 0
                SearchIcon.Position = UDim2.fromScale(0, 0.5)
                SearchIcon.Size = UDim2.fromOffset(12, 12)
                SearchIcon.Parent = Search
                
                local SearchPadding = Instance.new("UIPadding")
                SearchPadding.PaddingLeft = UDim.new(0, 15)
                SearchPadding.Parent = Search
                
                local SearchBox = Instance.new("TextBox")
                SearchBox.Name = "SearchBox"
                SearchBox.FontFace = self.Scheme.Font
                SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
                SearchBox.PlaceholderText = "Search..."
                SearchBox.Text = ""
                SearchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
                SearchBox.TextSize = 14
                SearchBox.TextXAlignment = Enum.TextXAlignment.Left
                SearchBox.BackgroundTransparency = 1
                SearchBox.BorderSizePixel = 0
                SearchBox.Size = UDim2.fromScale(1, 1)
                SearchBox.Parent = Search
                
                local SearchBoxPadding = Instance.new("UIPadding")
                SearchBoxPadding.PaddingLeft = UDim.new(0, 23)
                SearchBoxPadding.Parent = SearchBox
                
                local Selected = {}
                local OptionObjs = {}
                
                local function CalculateDropdownSize()
                    local totalHeight = 0
                    local visibleChildrenCount = 0
                    local padding = DropdownContentPadding.PaddingTop.Offset + DropdownContentPadding.PaddingBottom.Offset
                    for _, v in pairs(DropdownContent:GetChildren()) do
                        if not v:IsA("UIComponent") and v.Visible then
                            totalHeight += v.AbsoluteSize.Y
                            visibleChildrenCount += 1
                        end
                    end
                    local spacing = DropdownContentLayout.Padding.Offset * (visibleChildrenCount - 1)
                    return totalHeight + spacing + padding
                end
                
                local function findOption()
                    local searchTerm = SearchBox.Text:lower()
                    for _, v in pairs(OptionObjs) do
                        local optionText = v.NameLabel.Text:lower()
                        local isVisible = string.find(optionText, searchTerm) ~= nil
                        if v.Button.Visible ~= isVisible then v.Button.Visible = isVisible end
                    end
                    DropdownFrame.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
                end
                
                SearchBox:GetPropertyChangedSignal("Text"):Connect(findOption)
                
                local tweensettings = {duration = 0.2, easingStyle = Enum.EasingStyle.Quint, transparencyIn = 0.2, transparencyOut = 0.5, checkSizeIncrease = 12, checkSizeDecrease = -13, waitTime = 1}
                
                local function ToggleOption(optionName, State)
                    local option = OptionObjs[optionName]
                    if not option then return end
                    local checkmark = option.Checkmark
                    local optionNameLabel = option.NameLabel
                    if State then
                        if Dropdown.Multi then
                            if not table.find(Selected, optionName) then table.insert(Selected, optionName) end
                        else
                            for name, opt in pairs(OptionObjs) do
                                if name ~= optionName then
                                    game:GetService("TweenService"):Create(opt.Checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {Size = UDim2.new(opt.Checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, opt.Checkmark.Size.Y.Scale, opt.Checkmark.Size.Y.Offset)}):Play()
                                    game:GetService("TweenService"):Create(opt.NameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {TextTransparency = tweensettings.transparencyOut}):Play()
                                    opt.Checkmark.TextTransparency = 1
                                end
                            end
                            Selected = {optionName}
                        end
                        game:GetService("TweenService"):Create(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)}):Play()
                        game:GetService("TweenService"):Create(optionNameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {TextTransparency = tweensettings.transparencyIn}):Play()
                        checkmark.TextTransparency = 0
                    else
                        if Dropdown.Multi then
                            local idx = table.find(Selected, optionName)
                            if idx then table.remove(Selected, idx) end
                        else
                            Selected = {}
                        end
                        game:GetService("TweenService"):Create(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)}):Play()
                        game:GetService("TweenService"):Create(optionNameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {TextTransparency = tweensettings.transparencyOut}):Play()
                        checkmark.TextTransparency = 1
                    end
                    if Dropdown.Required and #Selected == 0 and not State then return end
                    DropdownName.Text = #Selected > 0 and Dropdown.Name .. " • " .. table.concat(Selected, ", ") or Dropdown.Name
                end
                
                local dropped = false
                local db = false
                
                local function ToggleDropdown()
                    if db then return end
                    db = true
                    local defaultDropdownSize = 38
                    local isDropdownOpen = not dropped
                    local targetSize = isDropdownOpen and UDim2.new(1, 0, 0, CalculateDropdownSize()) or UDim2.new(1, 0, 0, defaultDropdownSize)
                    local tween = game:GetService("TweenService"):Create(DropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = targetSize})
                    tween:Play()
                    if isDropdownOpen then
                        DropdownContent.Visible = true
                        tween.Completed:Connect(function() db = false end)
                    else
                        tween.Completed:Connect(function()
                            DropdownContent.Visible = false
                            db = false
                        end)
                    end
                    dropped = isDropdownOpen
                end
                
                Interact.MouseButton1Click:Connect(ToggleDropdown)
                
                local function addOption(i, v)
                    local Option = Instance.new("TextButton")
                    Option.Name = "Option"
                    Option.Text = ""
                    Option.BackgroundTransparency = 1
                    Option.BorderSizePixel = 0
                    Option.Size = UDim2.new(1, 0, 0, 30)
                    
                    local OptionPadding = Instance.new("UIPadding")
                    OptionPadding.PaddingLeft = UDim.new(0, 15)
                    OptionPadding.Parent = Option
                    
                    local OptionName = Instance.new("TextLabel")
                    OptionName.Name = "OptionName"
                    OptionName.FontFace = self.Scheme.Font
                    OptionName.Text = v
                    OptionName.TextColor3 = self.Scheme.FontColor
                    OptionName.TextSize = 13
                    OptionName.TextTransparency = 0.5
                    OptionName.TextXAlignment = Enum.TextXAlignment.Left
                    OptionName.TextYAlignment = Enum.TextYAlignment.Top
                    OptionName.AnchorPoint = Vector2.new(0, 0.5)
                    OptionName.AutomaticSize = Enum.AutomaticSize.XY
                    OptionName.BackgroundTransparency = 1
                    OptionName.BorderSizePixel = 0
                    OptionName.Position = UDim2.fromScale(0, 0.5)
                    OptionName.Parent = Option
                    
                    local OptionLayout = Instance.new("UIListLayout")
                    OptionLayout.Padding = UDim.new(0, 10)
                    OptionLayout.FillDirection = Enum.FillDirection.Horizontal
                    OptionLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    OptionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                    OptionLayout.Parent = Option
                    
                    local Checkmark = Instance.new("TextLabel")
                    Checkmark.Name = "Checkmark"
                    Checkmark.FontFace = self.Scheme.Font
                    Checkmark.Text = "✓"
                    Checkmark.TextColor3 = self.Scheme.FontColor
                    Checkmark.TextSize = 13
                    Checkmark.TextTransparency = 1
                    Checkmark.TextXAlignment = Enum.TextXAlignment.Left
                    Checkmark.TextYAlignment = Enum.TextYAlignment.Top
                    Checkmark.Anchor Point = Vector2.new(0, 0.5)
                    Checkmark.AutomaticSize = Enum.AutomaticSize.Y
                    Checkmark.BackgroundTransparency = 1
                    Checkmark.BorderSizePixel = 0
                    Checkmark.LayoutOrder = -1
                    Checkmark.Position = UDim2.fromScale(0, 0.5)
                    Checkmark.Size = UDim2.fromOffset(-10, 0)
                    Checkmark.Parent = Option
                    
                    Option.Parent = DropdownContent
                    
                    OptionObjs[v] = {
                        Index = i,
                        Button = Option,
                        NameLabel = OptionName,
                        Checkmark = Checkmark
                    }
                    
                    local isSelected = false
                    if Dropdown.Default then
                        if Dropdown.Multi then
                            isSelected = table.find(Dropdown.Default, v) and true or false
                        else
                            isSelected = (Dropdown.Default == i) and true or false
                        end
                    end
                    ToggleOption(v, isSelected)
                    
                    Option.MouseButton1Click:Connect(function()
                        local isSelected = table.find(Selected, v) and true or false
                        local newSelected = not isSelected
                        if Dropdown.Required and not newSelected and #Selected <= 1 then return end
                        ToggleOption(v, newSelected)
                        if Dropdown.Multi then
                            if Dropdown.Callback then Dropdown.Callback(Selected) end
                        else
                            if newSelected and Dropdown.Callback then Dropdown.Callback(v) end
                        end
                    end)
                end
                
                for i, v in pairs(Dropdown.Options) do
                    addOption(i, v)
                end
                
                function Dropdown:SetName(New)
                    DropdownName.Text = New
                end
                
                function Dropdown:SetVisibility(State)
                    DropdownFrame.Visible = State
                end
                
                function Dropdown:SetSelection(newSelection)
                    if type(newSelection) == "number" then
                        for option, data in pairs(OptionObjs) do
                            ToggleOption(option, data.Index == newSelection)
                        end
                    elseif type(newSelection) == "table" then
                        for option, data in pairs(OptionObjs) do
                            ToggleOption(option, table.find(newSelection, option) ~= nil)
                        end
                    end
                end
                
                function Dropdown:ClearOptions()
                    for _, optionData in pairs(OptionObjs) do
                        optionData.Button:Destroy()
                    end
                    OptionObjs = {}
                    Selected = {}
                    if dropped then
                        DropdownFrame.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
                    end
                end
                
                function Dropdown:GetOptions()
                    local optionsStatus = {}
                    for option, data in pairs(OptionObjs) do
                        optionsStatus[option] = table.find(Selected, option) and true or false
                    end
                    return optionsStatus
                end
                
                function Dropdown:RemoveOptions(remove)
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
                        DropdownFrame.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
                    end
                end
                
                return Dropdown
            end
            
            function Groupbox:AddInput(Properties)
                local Input = {
                    Groupbox = Groupbox,
                    Name = Properties.Name or "Input",
                    Default = Properties.Default or "Hello world!",
                    Placeholder = Properties.Placeholder or "",
                    AcceptedCharacters = Properties.AcceptedCharacters or "All",
                    Callback = Properties.Callback or function() end,
                    onChanged = Properties.onChanged,
                    Visible = true,
                }
                
                local InputFrame = Instance.new("Frame")
                InputFrame.Name = "Input"
                InputFrame.AutomaticSize = Enum.AutomaticSize.Y
                InputFrame.BackgroundTransparency = 1
                InputFrame.BorderSizePixel = 0
                InputFrame.Size = UDim2.new(1, 0, 0, 38)
                InputFrame.Parent = Section
                
                local InputName = Instance.new("TextLabel")
                InputName.Name = "InputName"
                InputName.FontFace = self.Scheme.Font
                InputName.Text = Input.Name
                InputName.TextColor3 = self.Scheme.FontColor
                InputName.TextSize = 13
                InputName.TextTransparency = 0.5
                InputName.TextXAlignment = Enum.TextXAlignment.Left
                InputName.TextYAlignment = Enum.TextYAlignment.Top
                InputName.AnchorPoint = Vector2.new(0, 0.5)
                InputName.AutomaticSize = Enum.AutomaticSize.XY
                InputName.BackgroundTransparency = 1
                InputName.BorderSizePixel = 0
                InputName.Position = UDim2.fromScale(0, 0.5)
                InputName.Parent = InputFrame
                
                local InputBox = Instance.new("TextBox")
                InputBox.Name = "InputBox"
                InputBox.FontFace = self.Scheme.Font
                InputBox.Text = Input.Default
                InputBox.TextColor3 = self.Scheme.FontColor
                InputBox.TextSize = 12
                InputBox.TextTransparency = 0.4
                InputBox.AnchorPoint = Vector2.new(1, 0.5)
                InputBox.AutomaticSize = Enum.AutomaticSize.X
                InputBox.BackgroundTransparency = 0.95
                InputBox.BorderSizePixel = 0
                InputBox.ClipsDescendants = true
                InputBox.LayoutOrder = 1
                InputBox.Position = UDim2.fromScale(1, 0.5)
                InputBox.Size = UDim2.fromOffset(21, 21)
                
                local InputBoxCorner = Instance.new("UICorner")
                InputBoxCorner.CornerRadius = UDim.new(0, 4)
                InputBoxCorner.Parent = InputBox
                
                local InputBoxStroke = Instance.new("UIStroke")
                InputBoxStroke.Color = self.Scheme.OutlineColor
                InputBoxStroke.Transparency = 0.9
                InputBoxStroke.Parent = InputBox
                
                InputBox.Parent = InputFrame
                
                local InputBoxPadding = Instance.new("UIPadding")
                InputBoxPadding.PaddingLeft = UDim.new(0, 5)
                InputBoxPadding.PaddingRight = UDim.new(0, 5)
                InputBoxPadding.Parent = InputBox
                
                local Constraint = Instance.new("UISizeConstraint")
                Constraint.Parent = InputBox
                
                local CharacterSubs = {
                    All = function(value) return value end,
                    Numeric = function(value) return value:match("^%-?%d*$") and value or value:gsub("[^%d-]", ""):gsub("(%-)", function(match, pos) return pos == 1 and match or "" end) end,
                    Alphabetic = function(value) return value:gsub("[^a-zA-Z ]", "") end,
                }
                
                local AcceptedCharacters = CharacterSubs[Input.AcceptedCharacters] or CharacterSubs.All
                
                local function checkSize()
                    local nameWidth = InputName.AbsoluteSize.X
                    local totalWidth = InputFrame.AbsoluteSize.X
                    local maxWidth = totalWidth - nameWidth - 20
                    Constraint.MaxSize = Vector2.new(maxWidth, 9e9)
                end
                
                checkSize()
                InputName:GetPropertyChangedSignal("AbsoluteSize"):Connect(checkSize)
                
                InputBox.FocusLost:Connect(function()
                    local inputText = InputBox.Text
                    local filteredText = AcceptedCharacters(inputText)
                    InputBox.Text = filteredText
                    if Input.Callback then Input.Callback(filteredText) end
                end)
                
                InputBox:GetPropertyChangedSignal("Text"):Connect(function()
                    InputBox.Text = AcceptedCharacters(InputBox.Text)
                    if Input.onChanged then Input.onChanged(InputBox.Text) end
                end)
                
                function Input:SetName(Name)
                    Input.Name = Name
                    InputName.Text = Name
                end
                
                function Input:SetVisibility(State)
                    InputFrame.Visible = State
                end
                
                function Input:GetInput()
                    return InputBox.Text
                end
                
                function Input:SetText(Text)
                    InputBox.Text = Text
                end
                
                return Input
            end
            
            function Groupbox:AddKeybind(Properties)
                local Keybind = {
                    Groupbox = Groupbox,
                    Name = Properties.Name or "Keybind",
                    Default = Properties.Default,
                    Callback = Properties.Callback,
                    onBinded = Properties.onBinded,
                    Visible = true,
                }
                
                local KeybindFrame = Instance.new("Frame")
                KeybindFrame.Name = "Keybind"
                KeybindFrame.AutomaticSize = Enum.AutomaticSize.Y
                KeybindFrame.BackgroundTransparency = 1
                KeybindFrame.BorderSizePixel = 0
                KeybindFrame.Size = UDim2.new(1, 0, 0, 38)
                KeybindFrame.Parent = Section
                
                local KeybindName = Instance.new("TextLabel")
                KeybindName.Name = "KeybindName"
                KeybindName.FontFace = self.Scheme.Font
                KeybindName.Text = Keybind.Name
                KeybindName.TextColor3 = self.Scheme.FontColor
                KeybindName.TextSize = 13
                KeybindName.TextTransparency = 0.5
                KeybindName.TextXAlignment = Enum.TextXAlignment.Left
                KeybindName.TextYAlignment = Enum.TextYAlignment.Top
                KeybindName.AnchorPoint = Vector2.new(0, 0.5)
                KeybindName.AutomaticSize = Enum.AutomaticSize.XY
                KeybindName.BackgroundTransparency = 1
                KeybindName.BorderSizePixel = 0
                KeybindName.Position = UDim2.fromScale(0, 0.5)
                KeybindName.Parent = KeybindFrame
                
                local BinderBox = Instance.new("TextBox")
                BinderBox.Name = "BinderBox"
                BinderBox.CursorPosition = -1
                BinderBox.FontFace = self.Scheme.Font
                BinderBox.PlaceholderText = "..."
                BinderBox.Text = ""
                BinderBox.TextColor3 = self.Scheme.FontColor
                BinderBox.TextSize = 12
                BinderBox.TextTransparency = 0.4
                BinderBox.AnchorPoint = Vector2.new(1, 0.5)
                BinderBox.AutomaticSize = Enum.AutomaticSize.X
                BinderBox.BackgroundTransparency = 0.95
                BinderBox.BorderSizePixel = 0
                BinderBox.ClipsDescendants = true
                BinderBox.LayoutOrder = 1
                BinderBox.Position = UDim2.fromScale(1, 0.5)
                BinderBox.Size = UDim2.fromOffset(21, 21)
                
                local BinderBoxCorner = Instance.new("UICorner")
                BinderBoxCorner.CornerRadius = UDim.new(0, 4)
                BinderBoxCorner.Parent = BinderBox
                
                local BinderBoxStroke = Instance.new("UIStroke")
                BinderBoxStroke.Color = self.Scheme.OutlineColor
                BinderBoxStroke.Transparency = 0.9
                BinderBoxStroke.Parent = BinderBox
                
                local BinderBoxPadding = Instance.new("UIPadding")
                BinderBoxPadding.PaddingLeft = UDim.new(0, 5)
                BinderBoxPadding.PaddingRight = UDim.new(0, 5)
                BinderBoxPadding.Parent = BinderBox
                
                local Constraint = Instance.new("UISizeConstraint")
                Constraint.Parent = BinderBox
                
                BinderBox.Parent = KeybindFrame
                
                local focused
                local binded = Keybind.Default
                
                if binded then
                    BinderBox.Text = binded.Name
                end
                
                BinderBox.Focused:Connect(function() focused = true end)
                BinderBox.FocusLost:Connect(function() focused = false end)
                
                game:GetService("UserInputService").InputEnded:Connect(function(inp)
                    if focused and inp.KeyCode.Name ~= "Unknown" then
                        binded = inp.KeyCode
                        BinderBox.Text = inp.KeyCode.Name
                        BinderBox:ReleaseFocus()
                        if Keybind.onBinded then Keybind.onBinded(binded) end
                    elseif inp.KeyCode == binded then
                        if Keybind.Callback then Keybind.Callback(binded) end
                    end
                end)
                
                function Keybind:Bind(Key)
                    binded = Key
                    BinderBox.Text = Key.Name
                end
                
                function Keybind:Unbind()
                    binded = nil
                    BinderBox.Text = ""
                end
                
                function Keybind:GetBind()
                    return binded
                end
                
                function Keybind:SetName(Name)
                    Keybind.Name = Name
                    KeybindName.Text = Name
                end
                
                function Keybind:SetVisibility(State)
                    KeybindFrame.Visible = State
                end
                
                return Keybind
            end
            
            return Groupbox
        end
        
        TabButton.MouseButton1Click:Connect(function() Tab:Show() end)
        
        table.insert(self.Tabs, Tab)
        table.insert(Window.Tabs, Tab)
        
        if not Window.ActiveTab then
            Tab:Show()
        end
        
        return Tab
    end
    
    return Window
end

getgenv().CrystalLib = CrystalLib
return CrystalLib