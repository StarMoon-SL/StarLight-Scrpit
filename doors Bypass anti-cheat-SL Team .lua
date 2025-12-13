-- StarLight UI Library
-- Complete modern cross-platform UI framework for Roblox
-- Based on MacLib with full device detection, mobile support, and context menus

local StarLight = {
    -- Core properties
    Registry = {};
    RegistryMap = {};
    OpenedFrames = {};
    Signals = {};
    Toggled = false;
    ToggleKeybind = nil;
    IsMobile = false;
    DevicePlatform = Enum.Platform.None;
    CanDrag = true;
    CantDragForced = false;
    UnloadSignals = {};
    HudRegistry = {};
    
    -- Mac-inspired color palette
    MainColor = Color3.fromRGB(245, 245, 247);
    BackgroundColor = Color3.fromRGB(255, 255, 255);
    AccentColor = Color3.fromRGB(0, 122, 255);
    DisabledAccentColor = Color3.fromRGB(142, 142, 142);
    OutlineColor = Color3.fromRGB(210, 210, 215);
    DisabledOutlineColor = Color3.fromRGB(220, 220, 225);
    FontColor = Color3.fromRGB(30, 30, 30);
    DisabledTextColor = Color3.fromRGB(160, 160, 165);
    Black = Color3.new(0, 0, 0);
    White = Color3.new(1, 1, 1);
    Font = Enum.Font.Gotham;
    ShowCustomCursor = false;
    MinSize = Vector2.new(550, 300);
    
    -- Context menu settings
    ShowToggleFrameInKeybinds = true;
    KeybindContainer = nil;
    KeybindFrame = nil;
}

-- Service references with cloneref support
local cloneref = cloneref or clonereference or function(instance) return instance end
local InputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

-- Platform detection
if RunService:IsStudio() then
    StarLight.IsMobile = InputService.TouchEnabled and not InputService.MouseEnabled
else
    pcall(function() StarLight.DevicePlatform = InputService:GetPlatform() end)
    StarLight.IsMobile = (StarLight.DevicePlatform == Enum.Platform.Android or StarLight.DevicePlatform == Enum.Platform.IOS)
end

StarLight.MinSize = StarLight.IsMobile and Vector2.new(550, 200) or Vector2.new(550, 300)
local DPIScale = StarLight.IsMobile and 0.8 or 1

-- Safe UI parenting
local function SafeParentUI(Instance, Parent)
    local success = pcall(function()
        local targetParent = typeof(Parent) == "function" and Parent() or (Parent or CoreGui)
        Instance.Parent = targetParent
    end)
    if not success or not Instance.Parent then
        Instance.Parent = LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local function ParentUI(UI, SkipHiddenUI)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end
    pcall(protectgui or (syn and syn.protect_gui) or function() end, UI)
    SafeParentUI(UI, gethui or function() return CoreGui end)
end

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false
ParentUI(ScreenGui)
StarLight.ScreenGui = ScreenGui

-- Core utilities
function StarLight:GiveSignal(Connection)
    if Connection and (typeof(Connection) == "RBXScriptConnection" or typeof(Connection) == "RBXScriptSignal") then
        table.insert(self.Signals, Connection)
    end
    return Connection
end

function StarLight:Unload()
    for i = #self.Signals, 1, -1 do
        local conn = table.remove(self.Signals, i)
        if conn and conn.Connected then conn:Disconnect() end
    end
    for _, callback in ipairs(self.UnloadSignals) do
        self:SafeCallback(callback)
    end
    ScreenGui:Destroy()
    self.Unloaded = true
    if getgenv then getgenv().StarLight = nil end
end

function StarLight:OnUnload(Callback)
    table.insert(self.UnloadSignals, Callback)
end

function StarLight:SafeCallback(Func, ...)
    if not (Func and typeof(Func) == "function") then return end
    local results = table.pack(xpcall(Func, function(err)
        task.defer(error, debug.traceback(err, 2))
        return err
    end, ...))
    return results[1] and table.unpack(results, 2, results.n) or nil
end

function StarLight:Create(Class, Properties)
    local instance = typeof(Class) == "string" and Instance.new(Class) or Class
    for prop, val in next, Properties do
        if prop == "Size" or prop == "Position" then
            instance[prop] = UDim2.new(val.X.Scale, val.X.Offset * DPIScale, val.Y.Scale, val.Y.Offset * DPIScale)
        elseif prop == "TextSize" then
            instance[prop] = val * DPIScale
        else
            pcall(function() instance[prop] = val end)
        end
    end
    return instance
end

function StarLight:ApplyTextStroke(Inst)
    Inst.TextStrokeTransparency = 1
    return self:Create("UIStroke", {
        Color = Color3.new(0, 0, 0);
        Thickness = 0.5;
        Transparency = 0.5;
        Parent = Inst;
    })
end

function StarLight:CreateLabel(Properties, IsHud)
    local label = self:Create("TextLabel", {
        BackgroundTransparency = 1;
        Font = self.Font;
        TextColor3 = self.FontColor;
        TextSize = 16;
    })
    self:ApplyTextStroke(label)
    self:AddToRegistry(label, {TextColor3 = "FontColor"}, IsHud)
    return self:Create(label, Properties)
end

function StarLight:AddToRegistry(Instance, Properties, IsHud)
    local data = {Instance = Instance; Properties = Properties; Idx = #self.Registry + 1}
    table.insert(self.Registry, data)
    self.RegistryMap[Instance] = data
    if IsHud then table.insert(self.HudRegistry, data) end
end

function StarLight:RemoveFromRegistry(Instance)
    local data = self.RegistryMap[Instance]
    if data then
        for i = #self.Registry, 1, -1 do
            if self.Registry[i] == data then table.remove(self.Registry, i) end
        end
        for i = #self.HudRegistry, 1, -1 do
            if self.HudRegistry[i] == data then table.remove(self.HudRegistry, i) end
        end
        self.RegistryMap[Instance] = nil
    end
end

function StarLight:UpdateColorsUsingRegistry()
    for _, object in next, self.Registry do
        for prop, colorKey in next, object.Properties do
            if typeof(colorKey) == "string" then
                object.Instance[prop] = self[colorKey]
            elseif typeof(colorKey) == "function" then
                object.Instance[prop] = colorKey()
            end
        end
    end
end

-- Input detection utilities
function StarLight:MouseIsOverFrame(Frame, Input)
    local pos
    if Input then
        pos = Input.Position
    else
        pos = InputService:GetMouseLocation()
        if self.IsMobile and InputService.TouchEnabled then
            local touches = InputService:GetTouches()
            if #touches > 0 then
                pos = touches[1].Position
            end
        end
    end
    local absPos, absSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    return pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y
end

function StarLight:MouseIsOverOpenedFrame(Input)
    local pos
    if Input then
        pos = Input.Position
    else
        pos = InputService:GetMouseLocation()
        if self.IsMobile and InputService.TouchEnabled then
            local touches = InputService:GetTouches()
            if #touches > 0 then
                pos = touches[1].Position
            end
        end
    end
    for frame in next, self.OpenedFrames do
        local absPos, absSize = frame.AbsolutePosition, frame.AbsoluteSize
        if pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y then
            return true
        end
    end
    return false
end

-- Dragging system
function StarLight:MakeDraggable(Instance, Cutoff, IsMainWindow)
    Instance.Active = true
    if not self.IsMobile then
        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if IsMainWindow and self.CantDragForced then return end
                local objPos = Vector2.new(InputService:GetMouseLocation().X - Instance.AbsolutePosition.X, InputService:GetMouseLocation().Y - Instance.AbsolutePosition.Y)
                if objPos.Y > (Cutoff or 40) then return end
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    Instance.Position = UDim2.new(0, InputService:GetMouseLocation().X - objPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X), 0, InputService:GetMouseLocation().Y - objPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y))
                    RunService.RenderStepped:Wait()
                end
            end
        end)
    else
        local dragging, draggingInput, draggingStart, startPosition
        self:GiveSignal(InputService.TouchStarted:Connect(function(Input)
            if IsMainWindow and self.CantDragForced then dragging = false; return end
            if not dragging and self:MouseIsOverFrame(Instance, Input) then
                draggingInput = Input
                draggingStart = Input.Position
                startPosition = Instance.Position
                local offsetPos = Input.Position - draggingStart
                if offsetPos.Y > (Cutoff or 40) then dragging = false; return end
                dragging = true
            end
        end))
        self:GiveSignal(InputService.TouchMoved:Connect(function(Input)
            if IsMainWindow and self.CantDragForced then dragging = false; return end
            if Input == draggingInput and dragging then
                local offsetPos = Input.Position - draggingStart
                Instance.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + offsetPos.X, startPosition.Y.Scale, startPosition.Y.Offset + offsetPos.Y)
            end
        end))
        self:GiveSignal(InputService.TouchEnded:Connect(function(Input)
            if Input == draggingInput then dragging = false end
        end))
    end
end

function StarLight:MakeDraggableUsingParent(Instance, Parent, Cutoff, IsMainWindow)
    Instance.Active = true
    if not self.IsMobile then
        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if IsMainWindow and self.CantDragForced then return end
                local objPos = Vector2.new(InputService:GetMouseLocation().X - Parent.AbsolutePosition.X, InputService:GetMouseLocation().Y - Parent.AbsolutePosition.Y)
                if objPos.Y > (Cutoff or 40) then return end
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    Parent.Position = UDim2.new(0, InputService:GetMouseLocation().X - objPos.X + (Parent.Size.X.Offset * Parent.AnchorPoint.X), 0, InputService:GetMouseLocation().Y - objPos.Y + (Parent.Size.Y.Offset * Parent.AnchorPoint.Y))
                    RunService.RenderStepped:Wait()
                end
            end
        end)
    else
        self:MakeDraggable(Parent, Cutoff, IsMainWindow)
    end
end

-- Highlight utility
function StarLight:OnHighlight(Region, Target, HighlightProps, NormalProps, Condition)
    Region.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            if Condition and not Condition() then return end
            for prop, val in next, HighlightProps do
                Target[prop] = typeof(val) == "string" and self[val] or val
            end
        end
    end)
    Region.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            if Condition and not Condition() then return end
            for prop, val in next, NormalProps do
                Target[prop] = typeof(val) == "string" and self[val] or val
            end
        end
    end)
end

-- Tooltip system
function StarLight:AddToolTip(TooltipText, DisabledTooltip, Parent)
    if not (typeof(TooltipText) == "string" or typeof(DisabledTooltip) == "string") then return nil end
    local tooltip = {
        Text = TooltipText or "";
        DisabledText = DisabledTooltip or TooltipText or "";
        Disabled = false;
        Object = Parent;
        LastMousePos = Vector2.new(0, 0);
    }
    
    local TooltipContainer = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.Black;
        BorderColor3 = StarLight.Black;
        Size = UDim2.new(0, 200, 0, 30);
        Visible = false;
        ZIndex = 100;
        Parent = ScreenGui;
    })
    StarLight:AddToRegistry(TooltipContainer, {BackgroundColor3 = "Black", BorderColor3 = "Black"})
    
    local TooltipInner = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.BackgroundColor;
        BorderColor3 = StarLight.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = TooltipContainer;
    })
    StarLight:AddToRegistry(TooltipInner, {BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor"})
    
    local TooltipLabel = StarLight:CreateLabel({
        Size = UDim2.new(1, -4, 1, -4);
        Text = "";
        TextSize = 13;
        TextWrapped = true;
        TextYAlignment = Enum.TextYAlignment.Top;
        ZIndex = 102;
        Parent = TooltipInner;
    })
    
    function tooltip:Show()
        if self.Disabled then
            TooltipLabel.Text = self.DisabledText or self.Text
        else
            TooltipLabel.Text = self.Text
        end
        TooltipContainer.Size = UDim2.new(0, math.min(TooltipLabel.TextBounds.X + 8, 300), 0, TooltipLabel.TextBounds.Y + 8)
        TooltipContainer.Visible = true
    end
    
    function tooltip:Hide()
        TooltipContainer.Visible = false
    end
    
    function tooltip:UpdatePosition()
        local mousePos = InputService:GetMouseLocation()
        TooltipContainer.Position = UDim2.new(0, mousePos.X + 10, 0, mousePos.Y - 10)
    end
    
    self:GiveSignal(Parent.MouseEnter:Connect(function()
        if StarLight.Unloaded then return end
        tooltip:Show()
    end))
    
    self:GiveSignal(Parent.MouseLeave:Connect(function()
        if StarLight.Unloaded then return end
        tooltip:Hide()
    end))
    
    self:GiveSignal(Parent.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            tooltip:UpdatePosition()
        end
    end))
    
    tooltip.Container = TooltipContainer
    tooltip:Hide()
    
    return tooltip
end

-- Save/Load system placeholder
function StarLight:AttemptSave() end
function StarLight:UpdateDependencyBoxes() end
function StarLight:UpdateDependencyGroupboxes() end
function StarLight:GetDarkerColor(Color) return Color:Lerp(self.Black, 0.2) end

-- Context Menu System
StarLight.ContextMenu = {}
do
    local ContextMenu = StarLight.ContextMenu
    ContextMenu.Options = {}
    ContextMenu.Container = StarLight:Create("Frame", {
        BorderColor3 = StarLight.Black;
        ZIndex = 14;
        Visible = false;
        Parent = ScreenGui;
    })
    ContextMenu.Inner = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.BackgroundColor;
        BorderColor3 = StarLight.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.fromScale(1, 1);
        ZIndex = 15;
        Parent = ContextMenu.Container;
    })
    StarLight:Create("UIListLayout", {
        Name = "Layout";
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = ContextMenu.Inner;
    })
    StarLight:Create("UIPadding", {
        Name = "Padding";
        PaddingLeft = UDim.new(0, 4);
        Parent = ContextMenu.Inner;
    })
    local function updateMenuSize()
        local menuWidth = 60
        for _, child in next, ContextMenu.Inner:GetChildren() do
            if child:IsA("TextLabel") then menuWidth = math.max(menuWidth, child.TextBounds.X) end
        end
        ContextMenu.Container.Size = UDim2.fromOffset(menuWidth + 8, ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4)
    end
    ContextMenu.Inner.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateMenuSize)
    StarLight:AddToRegistry(ContextMenu.Inner, {
        BackgroundColor3 = "BackgroundColor";
        BorderColor3 = "OutlineColor";
    })
    function ContextMenu:Show()
        if StarLight.IsMobile then StarLight.CanDrag = false end
        self.Container.Visible = true
    end
    function ContextMenu:Hide()
        if StarLight.IsMobile then StarLight.CanDrag = true end
        self.Container.Visible = false
    end
    function ContextMenu:AddOption(Text, Callback)
        local button = StarLight:CreateLabel({
            Active = false;
            Size = UDim2.new(1, 0, 0, 15);
            TextSize = 13;
            Text = Text;
            ZIndex = 16;
            Parent = self.Inner;
            TextXAlignment = Enum.TextXAlignment.Left;
        })
        StarLight:OnHighlight(button, button, {TextColor3 = "AccentColor"}, {TextColor3 = "FontColor"})
        button.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                self:Hide()
                StarLight:SafeCallback(Callback)
            end
        end)
    end
end

StarLight:GiveSignal(InputService.InputBegan:Connect(function(Input)
    if StarLight.Unloaded then return end
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        if not StarLight:MouseIsOverFrame(StarLight.ContextMenu.Container) then
            StarLight.ContextMenu:Hide()
        end
    end
end))

-- Base Addons (KeyPicker)
local BaseAddons = {}
BaseAddons.__index = BaseAddons
function BaseAddons:AddKeyPicker(Idx, Info)
    assert(Info.Default, string.format("AddKeyPicker (IDX: %s): Missing default value.", tostring(Idx)))
    local parentObj = self
    local KeyPicker = {
        Value = nil;
        Modifiers = {};
        DisplayValue = nil;
        Toggled = false;
        Mode = Info.Mode or "Toggle";
        Type = "KeyPicker";
        Callback = Info.Callback or function() end;
        ChangedCallback = Info.ChangedCallback or function() end;
        SyncToggleState = Info.SyncToggleState or false;
        NoUI = Info.NoUI or false;
    }
    
    if KeyPicker.Mode == "Press" then
        assert(parentObj.Type == "Label", "KeyPicker with mode 'Press' can only be applied to Labels.")
        KeyPicker.SyncToggleState = false
        Info.Modes = {"Press"}
    end
    if KeyPicker.SyncToggleState then
        Info.Modes = {"Toggle"}
    end
    
    -- Key conversion tables
    local SpecialKeys = {["MB1"] = Enum.UserInputType.MouseButton1, ["MB2"] = Enum.UserInputType.MouseButton2, ["MB3"] = Enum.UserInputType.MouseButton3}
    local SpecialKeysInput = {[Enum.UserInputType.MouseButton1] = "MB1", [Enum.UserInputType.MouseButton2] = "MB2", [Enum.UserInputType.MouseButton3] = "MB3"}
    local Modifiers = {["LAlt"] = Enum.KeyCode.LeftAlt, ["RAlt"] = Enum.KeyCode.RightAlt, ["LCtrl"] = Enum.KeyCode.LeftControl, ["RCtrl"] = Enum.KeyCode.RightControl, ["LShift"] = Enum.KeyCode.LeftShift, ["RShift"] = Enum.KeyCode.RightShift, ["Tab"] = Enum.KeyCode.Tab, ["CapsLock"] = Enum.KeyCode.CapsLock}
    local ModifiersInput = {[Enum.KeyCode.LeftAlt] = "LAlt", [Enum.KeyCode.RightAlt] = "RAlt", [Enum.KeyCode.LeftControl] = "LCtrl", [Enum.KeyCode.RightControl] = "RCtrl", [Enum.KeyCode.LeftShift] = "LShift", [Enum.KeyCode.RightShift] = "RShift", [Enum.KeyCode.Tab] = "Tab", [Enum.KeyCode.CapsLock] = "CapsLock"}
    
    local function GetActiveModifiers()
        local active = {}
        for name, input in Modifiers do
            if InputService:IsKeyDown(input) then table.insert(active, name) end
        end
        return active
    end
    
    local function AreModifiersHeld(required)
        if not (typeof(required) == "table" and #required > 0) then return true end
        local active = GetActiveModifiers()
        for _, name in required do
            if not table.find(active, name) then return false end
        end
        return true
    end
    
    local function ConvertToInputModifiers(modifierNames)
        local inputModifiers = {}
        for _, name in modifierNames do
            table.insert(inputModifiers, Modifiers[name])
        end
        return inputModifiers
    end
    
    local function VerifyModifiers(modifiers)
        if typeof(modifiers) ~= "table" then return {} end
        local valid = {}
        for _, name in modifiers do
            if Modifiers[name] then table.insert(valid, name) end
        end
        return valid
    end
    
    -- UI Elements
    local PickOuter = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.Black;
        BorderColor3 = StarLight.Black;
        Size = UDim2.new(0, 28, 0, 15);
        ZIndex = 6;
        Parent = parentObj.TextLabel or parentObj.Label;
    })
    
    local PickInner = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.BackgroundColor;
        BorderColor3 = StarLight.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 7;
        Parent = PickOuter;
    })
    StarLight:AddToRegistry(PickInner, {BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor"})
    
    local DisplayLabel = StarLight:CreateLabel({
        Size = UDim2.new(1, 0, 1, 0);
        TextSize = 13;
        Text = Info.Default;
        TextWrapped = true;
        ZIndex = 8;
        Parent = PickInner;
    })
    
    -- Mode selection dropdown
    local ModeSelectOuter = StarLight:Create("Frame", {
        BorderColor3 = StarLight.Black;
        BackgroundTransparency = 1;
        Size = UDim2.new(0, 80, 0, 0);
        Visible = false;
        ZIndex = 14;
        Parent = ScreenGui;
    })
    
    local function UpdateMenuPos()
        ModeSelectOuter.Position = UDim2.fromOffset((parentObj.TextLabel or parentObj.Label).AbsolutePosition.X + (parentObj.TextLabel or parentObj.Label).AbsoluteSize.X + 4, (parentObj.TextLabel or parentObj.Label).AbsolutePosition.Y)
    end
    UpdateMenuPos()
    (parentObj.TextLabel or parentObj.Label):GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateMenuPos)
    
    local ModeSelectInner = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.BackgroundColor;
        BorderColor3 = StarLight.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 0, 3);
        ZIndex = 15;
        Parent = ModeSelectOuter;
    })
    StarLight:AddToRegistry(ModeSelectInner, {BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor"})
    
    StarLight:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = ModeSelectInner;
    })
    
    local Modes = Info.Modes or {"Always", "Toggle", "Hold"}
    local ModeButtons = {}
    
    for _, Mode in Modes do
        local ModeButton = {}
        local Label = StarLight:CreateLabel({
            Active = false;
            Size = UDim2.new(1, 0, 0, 15);
            TextSize = 13;
            Text = Mode;
            ZIndex = 16;
            Parent = ModeSelectInner;
        })
        ModeSelectInner.Size = ModeSelectInner.Size + UDim2.new(0, 0, 0, 15)
        ModeSelectOuter.Size = ModeSelectOuter.Size + UDim2.new(0, 0, 0, 18)
        
        function ModeButton:Select()
            for _, btn in ModeButtons do btn:Deselect() end
            KeyPicker.Mode = Mode
            Label.TextColor3 = StarLight.AccentColor
            StarLight.RegistryMap[Label].Properties.TextColor3 = "AccentColor"
            ModeSelectOuter.Visible = false
        end
        
        function ModeButton:Deselect()
            KeyPicker.Mode = nil
            Label.TextColor3 = StarLight.FontColor
            StarLight.RegistryMap[Label].Properties.TextColor3 = "FontColor"
        end
        
        Label.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then ModeButton:Select() end
        end)
        
        if Mode == KeyPicker.Mode then ModeButton:Select() end
        ModeButtons[Mode] = ModeButton
    end
    
    -- Unbind button
    local UnbindInner = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.BackgroundColor;
        BorderColor3 = StarLight.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 0, 0, ModeSelectInner.Size.Y.Offset + 3);
        Size = UDim2.new(1, 0, 0, 18);
        ZIndex = 15;
        Parent = ModeSelectOuter;
    })
    ModeSelectOuter.Size = ModeSelectOuter.Size + UDim2.new(0, 0, 0, 18)
    StarLight:AddToRegistry(UnbindInner, {BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor"})
    
    local UnbindLabel = StarLight:CreateLabel({
        Active = false;
        Size = UDim2.new(1, 0, 0, 15);
        TextSize = 13;
        Text = "Unbind Key";
        ZIndex = 16;
        Parent = UnbindInner;
    })
    
    UnbindLabel.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            KeyPicker:SetValue({nil, KeyPicker.Mode, {}})
            ModeSelectOuter.Visible = false
        end
    end)
    
    -- KeyPicker functions
    function KeyPicker:Display(Text)
        DisplayLabel.Text = Text or self.DisplayValue
        PickOuter.Size = UDim2.new(0, 999999, 0, 18)
        RunService.RenderStepped:Wait()
        PickOuter.Size = UDim2.new(0, math.max(28, DisplayLabel.TextBounds.X + 8), 0, 18)
    end
    
    function KeyPicker:Update()
        self:Display()
        UpdateMenuPos()
    end
    
    function KeyPicker:GetState()
        if self.Mode == "Always" then return true
        elseif self.Mode == "Hold" then
            if self.Value == "None" then return false end
            if not AreModifiersHeld(self.Modifiers) then return false end
            if SpecialKeys[self.Value] then
                return InputService:IsMouseButtonPressed(SpecialKeys[self.Value]) and not InputService:GetFocusedTextBox()
            else
                return InputService:IsKeyDown(Enum.KeyCode[self.Value]) and not InputService:GetFocusedTextBox()
            end
        else
            return self.Toggled
        end
    end
    
    function KeyPicker:SetValue(Data, SkipCallback)
        local Key, Mode, Modifiers = Data[1], Data[2], Data[3]
        local IsKeyValid, UserInputType = pcall(function()
            if Key == "None" or Key == nil then
                return nil
            end
            return SpecialKeys[Key] or Enum.KeyCode[Key]
        end)
        
        self.Value = (Key == nil or Key == "None") and "None" or (IsKeyValid and Key or "Unknown")
        self.Modifiers = VerifyModifiers(typeof(Modifiers) == "table" and Modifiers or self.Modifiers)
        self.DisplayValue = #self.Modifiers > 0 and table.concat(self.Modifiers, " + ") .. " + " .. self.Value or self.Value
        DisplayLabel.Text = self.DisplayValue
        
        if Mode and ModeButtons[Mode] then ModeButtons[Mode]:Select() end
        self:Display()
        self:Update()
        
        if SkipCallback then return end
        local InputModifiers = {}
        for _, name in self.Modifiers do table.insert(InputModifiers, Modifiers[name]) end
        StarLight:SafeCallback(self.ChangedCallback, UserInputType, InputModifiers)
        StarLight:SafeCallback(self.Changed, UserInputType, InputModifiers)
    end
    
    function KeyPicker:OnClick(Callback) self.Clicked = Callback end
    function KeyPicker:OnChanged(Callback) self.Changed = Callback end
    
    function KeyPicker:DoClick()
        if self.Mode == "Press" and self.Toggled and Info.WaitForCallback then return end
        if self.Mode == "Press" then self.Toggled = true end
        
        if parentObj.Type == "Toggle" and self.SyncToggleState then
            parentObj:SetValue(not parentObj.Value)
        end
        
        StarLight:SafeCallback(self.Callback, self.Toggled)
        StarLight:SafeCallback(self.Clicked, self.Toggled)
        
        if self.Mode == "Press" then self.Toggled = false end
    end
    
    function KeyPicker:SetModePickerVisibility(bool) ModeSelectOuter.Visible = bool end
    function KeyPicker:GetModePickerVisibility() return ModeSelectOuter.Visible end
    
    -- Input handling
    PickOuter.InputBegan:Connect(function(PickerInput)
        if PickerInput.UserInputType == Enum.UserInputType.MouseButton1 and not StarLight:MouseIsOverOpenedFrame() then
            local picking = true
            self:Display("...")
            
            local Input
            repeat
                task.wait()
                Input = InputService.InputBegan:Wait()
            until Input.KeyCode ~= Enum.KeyCode.Unknown or Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.MouseButton2
            
            if Input.KeyCode == Enum.KeyCode.Escape then
                picking = false
                self:Update()
                return
            end
            
            local Key = SpecialKeysInput[Input.UserInputType] or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name) or "Unknown"
            local ActiveModifiers = Input.KeyCode ~= Enum.KeyCode.Escape and GetActiveModifiers() or {}
            
            self.Toggled = false
            self:SetValue({Key, self.Mode, ActiveModifiers})
            picking = false
        elseif PickerInput.UserInputType == Enum.UserInputType.MouseButton2 and not StarLight:MouseIsOverOpenedFrame() then
            self:SetModePickerVisibility(not self:GetModePickerVisibility())
        end
    end)
    
    StarLight:GiveSignal(InputService.InputBegan:Connect(function(Input)
        if StarLight.Unloaded or KeyPicker.Value == "Unknown" then return end
        if not InputService:GetFocusedTextBox() then
            local Key = KeyPicker.Value
            local HoldingModifiers = AreModifiersHeld(KeyPicker.Modifiers)
            local HoldingKey = false
            
            if HoldingModifiers then
                if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key then
                    HoldingKey = true
                elseif SpecialKeysInput[Input.UserInputType] == Key then
                    HoldingKey = true
                end
            end
            
            if (KeyPicker.Mode == "Toggle" and HoldingKey) or (KeyPicker.Mode == "Press" and HoldingKey) then
                KeyPicker:DoClick()
            end
            KeyPicker:Update()
        end
        
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local absPos, absSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize
            local mousePos = InputService:GetMouseLocation()
            if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or mousePos.Y < absPos.Y - 20 or mousePos.Y > absPos.Y + absSize.Y then
                KeyPicker:SetModePickerVisibility(false)
            end
        end
    end))
    
    StarLight:GiveSignal(InputService.InputEnded:Connect(function(Input)
        if not KeyPicker.Picking then KeyPicker:Update() end
    end))
    
    self:SetValue({Info.Default, Info.Mode or "Toggle", Info.DefaultModifiers or {}}, true)
    self.DisplayFrame = PickOuter
    self.Default = self.Value
    self.DefaultModifiers = self.Modifiers
    
    if parentObj.Addons then table.insert(parentObj.Addons, KeyPicker) end
    return KeyPicker
end

-- Base Groupbox
local BaseGroupbox = {}
BaseGroupbox.__index = BaseGroupbox
function BaseGroupbox:AddToggle(Idx, Info)
    assert(Info.Text, string.format("AddToggle (IDX: %s): Missing `Text` string.", tostring(Idx)))
    
    local Toggle = {
        Value = Info.Default or false;
        Type = "Toggle";
        Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true;
        Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
        Risky = if typeof(Info.Risky) == "boolean" then Info.Risky else false;
        OriginalText = Info.Text;
        Text = Info.Text;
        Callback = Info.Callback or function() end;
        Addons = {};
    }
    
    local Groupbox = self
    local ToggleContainer = StarLight:Create("Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, -4, 0, 13);
        Visible = Toggle.Visible;
        ZIndex = 5;
        Parent = Groupbox.Container;
    })
    
    local ToggleOuter = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.Black;
        BorderColor3 = StarLight.Black;
        Size = UDim2.new(0, 13, 0, 13);
        Visible = Toggle.Visible;
        ZIndex = 5;
        Parent = ToggleContainer;
    })
    StarLight:AddToRegistry(ToggleOuter, {BorderColor3 = "Black"})
    
    local ToggleInner = StarLight:Create("Frame", {
        BackgroundColor3 = Toggle.Value and StarLight.AccentColor or StarLight.MainColor;
        BorderColor3 = Toggle.Value and StarLight:GetDarkerColor(StarLight.AccentColor) or StarLight.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 6;
        Parent = ToggleOuter;
    })
    StarLight:AddToRegistry(ToggleInner, {
        BackgroundColor3 = Toggle.Value and "AccentColor" or "MainColor";
        BorderColor3 = Toggle.Value and "AccentColorDark" or "OutlineColor";
    })
    
    local ToggleLabel = StarLight:CreateLabel({
        Position = UDim2.new(0, 20, 0, 0);
        Size = UDim2.new(0, 0, 1, 0);
        Text = Toggle.Text;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 5;
        Parent = ToggleContainer;
    })
    
    StarLight:OnHighlight(ToggleOuter, ToggleOuter, {BorderColor3 = "AccentColor"}, {BorderColor3 = "Black"}, function() return not Toggle.Disabled end)
    StarLight:OnHighlight(ToggleLabel, ToggleOuter, {BorderColor3 = "AccentColor"}, {BorderColor3 = "Black"}, function() return not Toggle.Disabled end)
    
    if typeof(Info.Tooltip) == "string" or typeof(Info.DisabledTooltip) == "string" then
        local tooltip = StarLight:AddToolTip(Info.Tooltip, Info.DisabledTooltip, ToggleOuter)
        if tooltip then tooltip.Disabled = Toggle.Disabled end
    end
    
    function Toggle:UpdateColors()
        ToggleInner.BackgroundColor3 = self.Value and StarLight.AccentColor or StarLight.MainColor
        ToggleInner.BorderColor3 = self.Value and StarLight:GetDarkerColor(StarLight.AccentColor) or StarLight.OutlineColor
    end
    
    function Toggle:Display()
        ToggleContainer.Visible = self.Visible
        ToggleOuter.Visible = self.Visible
        Groupbox:Resize()
    end
    
    function Toggle:SetValue(Bool, Force)
        if (not Force and self.Disabled) or self.Value == Bool then return end
        self.Value = Bool
        self:UpdateColors()
        -- Update addons that sync state
        for _, Addon in self.Addons do
            if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                Addon.Toggled = self.Value
                StarLight:SafeCallback(Addon.Callback, Addon.Toggled)
                StarLight:SafeCallback(Addon.Changed, Addon.Toggled)
            end
        end
        StarLight:SafeCallback(self.Callback, self.Value)
        StarLight:SafeCallback(self.Changed, self.Value)
        StarLight:AttemptSave()
    end
    
    function Toggle:SetText(Str)
        self.Text = Str
        ToggleLabel.Text = self.Text
    end
    
    function Toggle:SetVisible(Visibility)
        self.Visible = Visibility
        self:Display()
    end
    
    function Toggle:SetDisabled(Disabled)
        self.Disabled = Disabled
        self:UpdateColors()
    end
    
    function Toggle:OnChanged(Func)
        self.Changed = Func
        StarLight:SafeCallback(Func, self.Value)
    end
    
    ToggleOuter.InputBegan:Connect(function(Input)
        if self.Disabled then return end
        if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not StarLight:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
            self:SetValue(not self.Value)
        end
    end)
    
    Toggle.Label = ToggleLabel
    Toggle.Container = ToggleContainer
    Toggle.DisplayFrame = ToggleOuter
    Toggle.Default = Toggle.Value
    
    Groupbox:Resize()
    table.insert(Groupbox.Elements, Toggle)
    Toggles[Idx] = Toggle
    
    return setmetatable(Toggle, BaseAddons)
end

-- Container management
local BaseGroupboxFuncs = {}
function BaseGroupboxFuncs:Resize()
    if self.ResizeCallback then self:ResizeCallback() end
end

function BaseGroupboxFuncs:AddLabel(Text, DoesWrap)
    local Label = StarLight:CreateLabel({
        Text = tostring(Text);
        TextSize = 13;
        TextWrapped = DoesWrap or false;
        TextYAlignment = Enum.TextYAlignment.Top;
        ZIndex = 5;
        Parent = self.Container;
    })
    self:Resize()
    return Label
end

function BaseGroupboxFuncs:AddButton(Idx, Info)
    assert(Info.Text, string.format("AddButton (IDX: %s): Missing `Text` string.", tostring(Idx)))
    
    local Button = {
        Type = "Button";
        Text = Info.Text;
        Callback = Info.Callback or function() end;
        Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
        Hidden = false;
    }
    
    local ButtonOuter = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.Black;
        BorderColor3 = StarLight.Black;
        Size = UDim2.new(1, -4, 0, 20);
        ZIndex = 5;
        Parent = self.Container;
    })
    StarLight:AddToRegistry(ButtonOuter, {BorderColor3 = "Black"})
    
    local ButtonInner = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.MainColor;
        BorderColor3 = StarLight.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 6;
        Parent = ButtonOuter;
    })
    StarLight:AddToRegistry(ButtonInner, {BackgroundColor3 = "MainColor", BorderColor3 = "OutlineColor"})
    
    local ButtonLabel = StarLight:CreateLabel({
        Size = UDim2.new(1, 0, 1, 0);
        Text = Button.Text;
        TextSize = 13;
        ZIndex = 7;
        Parent = ButtonInner;
    })
    
    StarLight:OnHighlight(ButtonOuter, ButtonInner, {BackgroundColor3 = "AccentColor"}, {BackgroundColor3 = "MainColor"}, function() return not Button.Disabled end)
    
    function Button:Update()
        ButtonOuter.Visible = not self.Hidden
        self.Container:Resize()
    end
    
    function Button:SetText(Str)
        self.Text = Str
        ButtonLabel.Text = self.Text
    end
    
    function Button:SetDisabled(Disabled)
        self.Disabled = Disabled
        ButtonInner.BackgroundColor3 = Disabled and StarLight.DisabledAccentColor or StarLight.MainColor
        ButtonLabel.TextColor3 = Disabled and StarLight.DisabledTextColor or StarLight.FontColor
    end
    
    function Button:SetHidden(Hidden)
        self.Hidden = Hidden
        self:Update()
    end
    
    ButtonOuter.InputBegan:Connect(function(Input)
        if Button.Disabled then return end
        if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not StarLight:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
            StarLight:SafeCallback(Button.Callback)
        end
    end)
    
    Button.Container = ButtonOuter
    self:Resize()
    table.insert(self.Elements, Button)
    
    return Button
end

function BaseGroupboxFuncs:AddSlider(Idx, Info)
    assert(Info.Text, string.format("AddSlider (IDX: %s): Missing `Text` string.", tostring(Idx)))
    assert(Info.Default, string.format("AddSlider (IDX: %s): Missing `Default` number.", tostring(Idx)))
    assert(Info.Min, string.format("AddSlider (IDX: %s): Missing `Min` number.", tostring(Idx)))
    assert(Info.Max, string.format("AddSlider (IDX: %s): Missing `Max` number.", tostring(Idx)))
    
    local Slider = {
        Value = Info.Default;
        Min = Info.Min;
        Max = Info.Max;
        Type = "Slider";
        Callback = Info.Callback or function() end;
        Text = Info.Text;
        Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
        Rounding = Info.Rounding or 1;
        Suffix = Info.Suffix or "";
        Hidden = false;
    }
    
    local SliderContainer = StarLight:Create("Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, -4, 0, 30);
        Visible = not Slider.Hidden;
        ZIndex = 5;
        Parent = self.Container;
    })
    
    local SliderLabel = StarLight:CreateLabel({
        Size = UDim2.new(1, 0, 0, 14);
        Text = Slider.Text;
        TextSize = 13;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 5;
        Parent = SliderContainer;
    })
    
    local SliderOuter = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.Black;
        BorderColor3 = StarLight.Black;
        Position = UDim2.new(0, 0, 1, -12);
        Size = UDim2.new(1, 0, 0, 8);
        ZIndex = 5;
        Parent = SliderContainer;
    })
    StarLight:AddToRegistry(SliderOuter, {BorderColor3 = "Black"})
    
    local SliderInner = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.MainColor;
        BorderColor3 = StarLight.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 6;
        Parent = SliderOuter;
    })
    StarLight:AddToRegistry(SliderInner, {BackgroundColor3 = "MainColor", BorderColor3 = "OutlineColor"})
    
    local SliderFill = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0);
        ZIndex = 7;
        Parent = SliderInner;
    })
    StarLight:AddToRegistry(SliderFill, {BackgroundColor3 = "AccentColor"})
    
    local SliderDrag = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.AccentColor;
        BorderColor3 = StarLight:GetDarkerColor(StarLight.AccentColor);
        Position = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), -4, 0, -4);
        Size = UDim2.new(0, 8, 0, 16);
        ZIndex = 8;
        Parent = SliderOuter;
    })
    StarLight:AddToRegistry(SliderDrag, {
        BackgroundColor3 = "AccentColor";
        BorderColor3 = "AccentColorDark";
    })
    
    local SliderValueLabel = StarLight:CreateLabel({
        Position = UDim2.new(1, -4, 0, 0);
        Size = UDim2.new(0, 0, 0, 14);
        Text = tostring(Slider.Value) .. Slider.Suffix;
        TextSize = 13;
        TextXAlignment = Enum.TextXAlignment.Right;
        ZIndex = 5;
        Parent = SliderContainer;
    })
    
    local Dragging = false
    
    function Slider:Update()
        local percentage = (self.Value - self.Min) / (self.Max - self.Min)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        SliderDrag.Position = UDim2.new(percentage, -4, 0, -4)
        SliderValueLabel.Text = tostring(self.Value) .. self.Suffix
        self.Container:Resize()
    end
    
    function Slider:SetValue(Value, Force)
        if self.Disabled and not Force then return end
        Value = math.clamp(Value, self.Min, self.Max)
        Value = math.floor(Value * (10 ^ self.Rounding) + 0.5) / (10 ^ self.Rounding)
        if self.Value ~= Value then
            self.Value = Value
            self:Update()
            StarLight:SafeCallback(self.Callback, self.Value)
            StarLight:SafeCallback(self.Changed, self.Value)
            StarLight:AttemptSave()
        end
    end
    
    function Slider:SetDisabled(Disabled)
        self.Disabled = Disabled
        SliderInner.BackgroundColor3 = Disabled and StarLight.DisabledAccentColor or StarLight.MainColor
        SliderFill.BackgroundColor3 = Disabled and StarLight.DisabledAccentColor or StarLight.AccentColor
        SliderDrag.BackgroundColor3 = Disabled and StarLight.DisabledAccentColor or StarLight.AccentColor
    end
    
    function Slider:SetHidden(Hidden)
        self.Hidden = Hidden
        SliderContainer.Visible = not Hidden
        self.Container:Resize()
    end
    
    function Slider:OnChanged(Func)
        self.Changed = Func
        StarLight:SafeCallback(Func, self.Value)
    end
    
    local function UpdateFromInput(Position)
        if Slider.Disabled then return end
        local absPos, absSize = SliderOuter.AbsolutePosition.X, SliderOuter.AbsoluteSize.X
        local percentage = math.clamp((Position - absPos) / absSize, 0, 1)
        local value = Slider.Min + (Slider.Max - Slider.Min) * percentage
        Slider:SetValue(value)
    end
    
    SliderDrag.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
        end
    end)
    
    StarLight:GiveSignal(InputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            UpdateFromInput(Input.Position.X)
        end
    end))
    
    StarLight:GiveSignal(InputService.InputEnded:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
            Dragging = false
        end
    end))
    
    SliderInner.InputBegan:Connect(function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not Dragging then
            UpdateFromInput(Input.Position.X)
        end
    end)
    
    Slider:Update()
    self:Resize()
    table.insert(self.Elements, Slider)
    Options[Idx] = Slider
    
    return Slider
end

function BaseGroupboxFuncs:AddDropdown(Idx, Info)
    assert(Info.Text, string.format("AddDropdown (IDX: %s): Missing `Text` string.", tostring(Idx)))
    assert(Info.Values, string.format("AddDropdown (IDX: %s): Missing `Values` table.", tostring(Idx)))
    assert(Info.Default, string.format("AddDropdown (IDX: %s): Missing `Default` value.", tostring(Idx)))
    
    local Dropdown = {
        Value = Info.Default;
        Values = Info.Values;
        Type = "Dropdown";
        Text = Info.Text;
        Callback = Info.Callback or function() end;
        Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
        Multi = Info.Multi or false;
        Addons = {};
        Hidden = false;
    }
    
    local DropdownContainer = StarLight:Create("Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, -4, 0, 34);
        Visible = not Dropdown.Hidden;
        ZIndex = 5;
        Parent = self.Container;
    })
    
    local DropdownLabel = StarLight:CreateLabel({
        Size = UDim2.new(1, 0, 0, 14);
        Text = Dropdown.Text;
        TextSize = 13;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 5;
        Parent = DropdownContainer;
    })
    
    local DropdownOuter = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.Black;
        BorderColor3 = StarLight.Black;
        Position = UDim2.new(0, 0, 1, -20);
        Size = UDim2.new(1, 0, 0, 20);
        ZIndex = 5;
        Parent = DropdownContainer;
    })
    StarLight:AddToRegistry(DropdownOuter, {BorderColor3 = "Black"})
    
    local DropdownInner = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.MainColor;
        BorderColor3 = StarLight.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 6;
        Parent = DropdownOuter;
    })
    StarLight:AddToRegistry(DropdownInner, {BackgroundColor3 = "MainColor", BorderColor3 = "OutlineColor"})
    
    local DropdownValueLabel = StarLight:CreateLabel({
        Size = UDim2.new(1, -20, 1, 0);
        Text = tostring(Dropdown.Value);
        TextSize = 13;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 7;
        Parent = DropdownInner;
    })
    
    local DropdownArrow = StarLight:CreateLabel({
        Position = UDim2.new(1, -15, 0, 0);
        Size = UDim2.new(0, 15, 1, 0);
        Text = "▼";
        TextSize = 13;
        TextWrapped = false;
        ZIndex = 7;
        Parent = DropdownInner;
    })
    
    local DropdownListOuter = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.Black;
        BorderColor3 = StarLight.Black;
        Position = UDim2.new(0, 0, 1, 2);
        Size = UDim2.new(1, 0, 0, 0);
        Visible = false;
        ZIndex = 8;
        Parent = DropdownOuter;
    })
    StarLight:AddToRegistry(DropdownListOuter, {BorderColor3 = "Black"})
    
    local DropdownListInner = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.BackgroundColor;
        BorderColor3 = StarLight.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 9;
        Parent = DropdownListOuter;
    })
    StarLight:AddToRegistry(DropdownListInner, {BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor"})
    
    local DropdownListLayout = StarLight:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = DropdownListInner;
    })
    
    local function UpdateDropdownList()
        local count = 0
        for _, child in next, DropdownListInner:GetChildren() do
            if child:IsA("TextLabel") then
                count = count + 1
            end
        end
        DropdownListOuter.Size = UDim2.new(1, 0, 0, math.min(count * 20, 200))
    end
    
    local SelectedItems = Dropdown.Multi and {} or nil
    
    function Dropdown:Update()
        DropdownValueLabel.Text = Dropdown.Multi and (next(SelectedItems) and table.concat(SelectedItems, ", ") or "None") or tostring(self.Value)
        self.Container:Resize()
    end
    
    function Dropdown:SetValue(Value, Force)
        if self.Disabled and not Force then return end
        if Dropdown.Multi then
            if Value == nil then
                SelectedItems = {}
            else
                SelectedItems = Value
            end
        else
            self.Value = Value
        end
        self:Update()
        StarLight:SafeCallback(self.Callback, self.Value)
        StarLight:SafeCallback(self.Changed, self.Value)
        StarLight:AttemptSave()
    end
    
    function Dropdown:SetDisabled(Disabled)
        self.Disabled = Disabled
        DropdownInner.BackgroundColor3 = Disabled and StarLight.DisabledAccentColor or StarLight.MainColor
        DropdownValueLabel.TextColor3 = Disabled and StarLight.DisabledTextColor or StarLight.FontColor
    end
    
    function Dropdown:SetHidden(Hidden)
        self.Hidden = Hidden
        DropdownContainer.Visible = not Hidden
        self.Container:Resize()
    end
    
    function Dropdown:OnChanged(Func)
        self.Changed = Func
        StarLight:SafeCallback(Func, self.Value)
    end
    
    local function AddItem(Value)
        local ItemLabel = StarLight:CreateLabel({
            Size = UDim2.new(1, 0, 0, 20);
            Text = tostring(Value);
            TextSize = 13;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 10;
            Parent = DropdownListInner;
        })
        ItemLabel.InputBegan:Connect(function(Input)
            if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not Dropdown.Disabled then
                if Dropdown.Multi then
                    if table.find(SelectedItems, Value) then
                        table.remove(SelectedItems, table.find(SelectedItems, Value))
                    else
                        table.insert(SelectedItems, Value)
                    end
                    Dropdown:SetValue(SelectedItems)
                else
                    Dropdown:SetValue(Value)
                    DropdownListOuter.Visible = false
                    StarLight.OpenedFrames[DropdownListOuter] = nil
                end
            end
        end)
    end
    
    for _, Value in Dropdown.Values do
        AddItem(Value)
    end
    
    UpdateDropdownList()
    
    DropdownInner.InputBegan:Connect(function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not Dropdown.Disabled then
            local visible = DropdownListOuter.Visible
            for frame in next, StarLight.OpenedFrames do
                frame.Visible = false
                StarLight.OpenedFrames[frame] = nil
            end
            DropdownListOuter.Visible = not visible
            if not visible then
                StarLight.OpenedFrames[DropdownListOuter] = true
            else
                StarLight.OpenedFrames[DropdownListOuter] = nil
            end
        end
    end)
    
    Dropdown:Update()
    self:Resize()
    table.insert(self.Elements, Dropdown)
    Options[Idx] = Dropdown
    
    return setmetatable(Dropdown, BaseAddons)
end

function BaseGroupboxFuncs:AddColorPicker(Idx, Info)
    assert(Info.Default, string.format("AddColorPicker (IDX: %s): Missing `Default` Color3.", tostring(Idx)))
    
    local ColorPicker = {
        Value = Info.Default;
        Type = "ColorPicker";
        Callback = Info.Callback or function() end;
        Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
        Transparency = Info.Transparency or nil;
        Hidden = false;
    }
    
    local ColorContainer = StarLight:Create("Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, -4, 0, 20);
        Visible = not ColorPicker.Hidden;
        ZIndex = 5;
        Parent = self.Container;
    })
    
    local ColorLabel = StarLight:CreateLabel({
        Size = UDim2.new(1, 0, 0, 14);
        Text = Info.Text or "Color Picker";
        TextSize = 13;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 5;
        Parent = ColorContainer;
    })
    
    local ColorPreviewOuter = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.Black;
        BorderColor3 = StarLight.Black;
        Position = UDim2.new(1, -20, 0, 0);
        Size = UDim2.new(0, 20, 0, 20);
        ZIndex = 5;
        Parent = ColorContainer;
    })
    StarLight:AddToRegistry(ColorPreviewOuter, {BorderColor3 = "Black"})
    
    local ColorPreviewInner = StarLight:Create("Frame", {
        BackgroundColor3 = ColorPicker.Value;
        BorderColor3 = StarLight.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 6;
        Parent = ColorPreviewOuter;
    })
    StarLight:AddToRegistry(ColorPreviewInner, {BorderColor3 = "OutlineColor"})
    
    local ColorPickerWindow = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.BackgroundColor;
        BorderColor3 = StarLight.OutlineColor;
        Position = UDim2.new(1, 4, 0, 0);
        Size = UDim2.new(0, 200, 0, 0);
        Visible = false;
        ZIndex = 10;
        Parent = ColorPreviewOuter;
    })
    StarLight:AddToRegistry(ColorPickerWindow, {BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor"})
    
    local ColorPickerLayout = StarLight:Create("UIListLayout", {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = ColorPickerWindow;
    })
    
    local HueSlider = StarLight:Create("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderColor3 = StarLight.OutlineColor;
        Size = UDim2.new(1, -8, 0, 20);
        Position = UDim2.new(0, 4, 0, 4);
        ZIndex = 11;
        Parent = ColorPickerWindow;
    })
    
    local HueGradient = StarLight:Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.new(1, 1, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.new(0, 1, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
            ColorSequenceKeypoint.new(0.66, Color3.new(0, 0, 1)),
            ColorSequenceKeypoint.new(0.83, Color3.new(1, 0, 1)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0)),
        });
        Parent = HueSlider;
    })
    
    local HueCursor = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.Black;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(0, 2, 1, 0);
        ZIndex = 12;
        Parent = HueSlider;
    })
    
    local SaturationValueBox = StarLight:Create("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderColor3 = StarLight.OutlineColor;
        Size = UDim2.new(1, -8, 0, 150);
        Position = UDim2.new(0, 4, 0, 28);
        ZIndex = 11;
        Parent = ColorPickerWindow;
    })
    
    local SVGradientX = StarLight:Create("UIGradient", {
        Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))});
        Rotation = 0;
        Parent = SaturationValueBox;
    })
    
    local SVGradientY = StarLight:Create("UIGradient", {
        Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))});
        Rotation = -90;
        Parent = SaturationValueBox;
    })
    
    local SVCursor = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.Black;
        BorderColor3 = StarLight.White;
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(0, 4, 0, 4);
        ZIndex = 12;
        Parent = SaturationValueBox;
    })
    
    local function UpdateHueFromPosition(X)
        local hue = math.clamp(X / HueSlider.AbsoluteSize.X, 0, 1)
        local h, s, v = Color3.toHSV(ColorPicker.Value)
        ColorPicker.Value = Color3.fromHSV(hue, s, v)
        ColorPreviewInner.BackgroundColor3 = ColorPicker.Value
        SaturationValueBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        StarLight:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
        StarLight:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
    end
    
    local function UpdateSVFromPosition(X, Y)
        local saturation = math.clamp(X / SaturationValueBox.AbsoluteSize.X, 0, 1)
        local value = 1 - math.clamp(Y / SaturationValueBox.AbsoluteSize.Y, 0, 1)
        local h, s, v = Color3.toHSV(ColorPicker.Value)
        ColorPicker.Value = Color3.fromHSV(h, saturation, value)
        ColorPreviewInner.BackgroundColor3 = ColorPicker.Value
        StarLight:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
        StarLight:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
    end
    
    local function UpdateCursors()
        local h, s, v = Color3.toHSV(ColorPicker.Value)
        HueCursor.Position = UDim2.new(h, 0, 0, 0)
        SVCursor.Position = UDim2.new(s, -2, 1 - v, -2)
    end
    
    function ColorPicker:Update()
        ColorPreviewInner.BackgroundColor3 = self.Value
        self.Container:Resize()
    end
    
    function ColorPicker:SetValue(Color, Force)
        if self.Disabled and not Force then return end
        self.Value = Color
        self:Update()
        UpdateCursors()
        StarLight:SafeCallback(self.Callback, self.Value)
        StarLight:SafeCallback(self.Changed, self.Value)
        StarLight:AttemptSave()
    end
    
    function ColorPicker:OnChanged(Func)
        self.Changed = Func
        StarLight:SafeCallback(Func, self.Value)
    end
    
    ColorPreviewOuter.InputBegan:Connect(function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not ColorPicker.Disabled then
            local visible = ColorPickerWindow.Visible
            for frame in next, StarLight.OpenedFrames do
                frame.Visible = false
                StarLight.OpenedFrames[frame] = nil
            end
            ColorPickerWindow.Visible = not visible
            if not visible then
                StarLight.OpenedFrames[ColorPickerWindow] = true
                ColorPickerWindow.Size = UDim2.new(0, 200, 0, 182)
            else
                StarLight.OpenedFrames[ColorPickerWindow] = nil
                ColorPickerWindow.Size = UDim2.new(0, 200, 0, 0)
            end
        end
    end)
    
    HueSlider.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = InputService.InputChanged:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    UpdateHueFromPosition(Input.Position.X - HueSlider.AbsolutePosition.X)
                end
            end)
            InputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    SaturationValueBox.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = InputService.InputChanged:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    UpdateSVFromPosition(Input.Position.X - SaturationValueBox.AbsolutePosition.X, Input.Position.Y - SaturationValueBox.AbsolutePosition.Y)
                end
            end)
            InputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    UpdateCursors()
    ColorPicker:Update()
    self:Resize()
    table.insert(self.Elements, ColorPicker)
    Options[Idx] = ColorPicker
    
    return ColorPicker
end

function BaseGroupboxFuncs:AddInput(Idx, Info)
    assert(Info.Text, string.format("AddInput (IDX: %s): Missing `Text` string.", tostring(Idx)))
    
    local Input = {
        Value = Info.Default or "";
        Type = "Input";
        Callback = Info.Callback or function() end;
        Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
        Hidden = false;
    }
    
    local InputContainer = StarLight:Create("Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, -4, 0, 34);
        Visible = not Input.Hidden;
        ZIndex = 5;
        Parent = self.Container;
    })
    
    local InputLabel = StarLight:CreateLabel({
        Size = UDim2.new(1, 0, 0, 14);
        Text = Input.Text;
        TextSize = 13;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 5;
        Parent = InputContainer;
    })
    
    local InputBoxOuter = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.Black;
        BorderColor3 = StarLight.Black;
        Position = UDim2.new(0, 0, 1, -20);
        Size = UDim2.new(1, 0, 0, 20);
        ZIndex = 5;
        Parent = InputContainer;
    })
    StarLight:AddToRegistry(InputBoxOuter, {BorderColor3 = "Black"})
    
    local InputBoxInner = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.MainColor;
        BorderColor3 = StarLight.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 6;
        Parent = InputBoxOuter;
    })
    StarLight:AddToRegistry(InputBoxInner, {BackgroundColor3 = "MainColor", BorderColor3 = "OutlineColor"})
    
    local InputBox = StarLight:Create("TextBox", {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, -4, 1, 0);
        Position = UDim2.new(0, 2, 0, 0);
        Font = StarLight.Font;
        Text = Input.Value;
        TextColor3 = StarLight.FontColor;
        TextSize = 13;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 7;
        ClearTextOnFocus = false;
        Parent = InputBoxInner;
    })
    
    function Input:Update()
        InputBox.Text = self.Value
        self.Container:Resize()
    end
    
    function Input:SetValue(Value, Force)
        if self.Disabled and not Force then return end
        self.Value = Value
        self:Update()
        StarLight:SafeCallback(self.Callback, self.Value)
        StarLight:SafeCallback(self.Changed, self.Value)
        StarLight:AttemptSave()
    end
    
    function Input:SetDisabled(Disabled)
        self.Disabled = Disabled
        InputBoxInner.BackgroundColor3 = Disabled and StarLight.DisabledAccentColor or StarLight.MainColor
        InputBox.TextColor3 = Disabled and StarLight.DisabledTextColor or StarLight.FontColor
    end
    
    function Input:SetHidden(Hidden)
        self.Hidden = Hidden
        InputContainer.Visible = not Hidden
        self.Container:Resize()
    end
    
    function Input:OnChanged(Func)
        self.Changed = Func
        StarLight:SafeCallback(Func, self.Value)
    end
    
    InputBox.FocusLost:Connect(function(enterPressed)
        if Input.Disabled then return end
        Input:SetValue(InputBox.Text)
    end)
    
    InputBox.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton2 then
            StarLight.ContextMenu:Show()
            StarLight.ContextMenu.Container.Position = UDim2.new(0, InputBox.AbsolutePosition.X + InputBox.AbsoluteSize.X / 2, 0, InputBox.AbsolutePosition.Y + InputBox.AbsoluteSize.Y)
            StarLight.ContextMenu:AddOption("Copy", function()
                if setclipboard then setclipboard(InputBox.Text) end
            end)
            StarLight.ContextMenu:AddOption("Paste", function()
                if getclipboard then InputBox.Text = getclipboard() end
            end)
            StarLight.ContextMenu:AddOption("Clear", function()
                InputBox.Text = ""
                Input:SetValue("")
            end)
        end
    end)
    
    Input:Update()
    self:Resize()
    table.insert(self.Elements, Input)
    Options[Idx] = Input
    
    return Input
end

function BaseGroupboxFuncs:AddDivider()
    local Divider = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.OutlineColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, -4, 0, 1);
        ZIndex = 5;
        Parent = self.Container;
    })
    StarLight:AddToRegistry(Divider, {BackgroundColor3 = "OutlineColor"})
    self:Resize()
    return Divider
end

function BaseGroupboxFuncs:AddContextMenu(Menu)
    local ContextMenuButton = StarLight:CreateLabel({
        Position = UDim2.new(1, -20, 0, 0);
        Size = UDim2.new(0, 20, 0, 20);
        Text = "⋮";
        TextSize = 18;
        ZIndex = 6;
        Parent = self.Container.Parent;
    })
    
    ContextMenuButton.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            StarLight.ContextMenu:Show()
            StarLight.ContextMenu.Container.Position = UDim2.new(0, ContextMenuButton.AbsolutePosition.X, 0, ContextMenuButton.AbsolutePosition.Y + ContextMenuButton.AbsoluteSize.Y)
            for _, option in Menu do
                StarLight.ContextMenu:AddOption(option.Text, option.Callback)
            end
        end
    end)
    
    return ContextMenuButton
end

-- Tab and Window System
function StarLight:CreateWindow(Info)
    Info = Info or {}
    Info.Name = Info.Name or "StarLight Window"
    Info.Title = Info.Title or Info.Name
    
    local Window = {
        Name = Info.Name;
        Title = Info.Title;
        Opened = false;
        TabCount = 0;
        Tabs = {};
        Elements = {};
        DefaultSize = Info.DefaultSize or StarLight.MinSize;
    }
    
    local WindowOuter = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.Black;
        BorderColor3 = StarLight.Black;
        Position = UDim2.new(0.5, -Window.DefaultSize.X / 2, 0.5, -Window.DefaultSize.Y / 2);
        Size = UDim2.new(0, Window.DefaultSize.X, 0, Window.DefaultSize.Y);
        Visible = false;
        ZIndex = 1;
        Parent = ScreenGui;
    })
    StarLight:AddToRegistry(WindowOuter, {BorderColor3 = "Black"})
    
    local WindowInner = StarLight:Create("Frame", {
        BackgroundColor3 = StarLight.BackgroundColor;
        BorderColor3 = StarLight.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 2;
        Parent = WindowOuter;
    })
    StarLight:AddToRegistry(WindowInner, {BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor"})
    
    local WindowTitle = StarLight:CreateLabel({
        Position = UDim2.new(0, 8, 0, 6);
        Size = UDim2.new(1, -16, 0, 20);
        Text = Window.Title;
        TextSize = 16;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 3;
        Parent = WindowInner;
    })
    
    local WindowClose = StarLight:CreateLabel({
        Position = UDim2.new(1, -24, 0, 4);
        Size = UDim2.new(0, 20, 0, 20);
        Text = "×";
        TextSize = 20;
        ZIndex = 3;
        Parent = WindowInner;
    })
    
    WindowClose.InputBegan:Connect(function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
            Window:Close()
        end
    end)
    
    local WindowTabContainer = StarLight:Create("Frame", {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 4, 0, 32);
        Size = UDim2.new(1, -8, 0, 24);
        ZIndex = 3;
        Parent = WindowInner;
    })
    
    local WindowTabLayout = StarLight:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = UDim.new(0, 4);
        Parent = WindowTabContainer;
    })
    
    local WindowContainer = StarLight:Create("Frame", {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 4, 0, 60);
        Size = UDim2.new(1, -8, 1, -64);
        ZIndex = 3;
        Parent = WindowInner;
    })
    
    StarLight:MakeDraggable(WindowTitle, 30, true)
    
    function Window:Open()
        self.Opened = true
        WindowOuter.Visible = true
        StarLight.Toggled = true
    end
    
    function Window:Close()
        self.Opened = false
        WindowOuter.Visible = false
        StarLight.Toggled = false
        for frame in next, StarLight.OpenedFrames do
            frame.Visible = false
            StarLight.OpenedFrames[frame] = nil
        end
    end
    
    function Window:Toggle()
        if self.Opened then
            self:Close()
        else
            self:Open()
        end
    end
    
    function Window:SetTitle(Title)
        self.Title = Title
        WindowTitle.Text = Title
    end
    
    function Window:CreateTab(Name)
        local Tab = {
            Name = Name;
            Groupboxes = {};
            Elements = {};
        }
        
        self.TabCount = self.TabCount + 1
        
        local TabButton = StarLight:CreateLabel({
            Size = UDim2.new(0, 80, 0, 24);
            Text = Name;
            TextSize = 13;
            ZIndex = 4;
            Parent = WindowTabContainer;
        })
        
        local TabContainer = StarLight:Create("Frame", {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 1, 0);
            Visible = self.TabCount == 1;
            ZIndex = 4;
            Parent = WindowContainer;
        })
        
        if self.TabCount == 1 then
            TabButton.TextColor3 = StarLight.AccentColor
            StarLight:AddToRegistry(TabButton, {TextColor3 = "AccentColor"})
        else
            StarLight:AddToRegistry(TabButton, {TextColor3 = "FontColor"})
        end
        
        local GroupboxLayout = StarLight:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Padding = UDim.new(0, 8);
            Parent = TabContainer;
        })
        
        function Tab:CreateGroupbox(Name, Side)
            Side = Side or 1
            local Groupbox = {
                Name = Name;
                Side = Side;
                Parent = TabContainer;
                Elements = {};
                ResizeCallback = function() end;
            }
            
            local GroupboxOuter = StarLight:Create("Frame", {
                BackgroundTransparency = 1;
                Size = UDim2.new(0.5, Side == 1 and -4 or 0, 1, 0);
                Position = Side == 2 and UDim2.new(0.5, 4, 0, 0) or UDim2.new(0, 0, 0, 0);
                ZIndex = 5;
                Parent = TabContainer;
            })
            
            local GroupboxInner = StarLight:Create("Frame", {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, -8, 1, -8);
                Position = UDim2.new(0, 4, 0, 4);
                ZIndex = 5;
                Parent = GroupboxOuter;
            })
            
            local GroupboxHeader = StarLight:CreateLabel({
                Size = UDim2.new(1, 0, 0, 16);
                Text = Name;
                TextSize = 14;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 5;
                Parent = GroupboxInner;
            })
            
            local GroupboxContent = StarLight:Create("Frame", {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 0, 0, 20);
                Size = UDim2.new(1, 0, 1, -20);
                ZIndex = 5;
                Parent = GroupboxInner;
            })
            
            function Groupbox:Resize()
                local height = 0
                for _, element in self.Elements do
                    if element.Container and element.Container.Visible ~= false then
                        height = height + element.Container.Size.Y.Offset
                    end
                end
                GroupboxOuter.Size = UDim2.new(0.5, self.Side == 1 and -4 or 0, 0, math.max(height + 28, 100))
            end
            
            Groupbox.ResizeCallback = function() Groupbox:Resize() end
            
            function Groupbox:SetHidden(Hidden)
                GroupboxOuter.Visible = not Hidden
                self:Resize()
            end
            
            setmetatable(Groupbox, {__index = BaseGroupboxFuncs})
            
            table.insert(self.Groupboxes, Groupbox)
            table.insert(self.Elements, Groupbox)
            
            return Groupbox
        end
        
        TabButton.InputBegan:Connect(function(Input)
            if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                for _, t in self.Tabs do
                    t.Container.Visible = false
                    StarLight.RegistryMap[t.Button].Properties.TextColor3 = "FontColor"
                end
                TabContainer.Visible = true
                StarLight.RegistryMap[TabButton].Properties.TextColor3 = "AccentColor"
            end
        end)
        
        Tab.Button = TabButton
        Tab.Container = TabContainer
        
        table.insert(self.Tabs, Tab)
        
        return Tab
    end
    
    Window.Holder = WindowOuter
    Window.Container = WindowContainer
    
    StarLight.Window = Window
    
    return Window
end

-- Keybind display system
StarLight.KeybindContainer = StarLight:Create("Frame", {
    BackgroundTransparency = 1;
    Position = UDim2.new(0.5, -110, 0, 10);
    Size = UDim2.new(0, 220, 0, 0);
    ZIndex = 10;
    Parent = ScreenGui;
})

StarLight.KeybindFrame = StarLight:Create("Frame", {
    BackgroundColor3 = StarLight.Black;
    BorderColor3 = StarLight.Black;
    Size = UDim2.new(0, 220, 0, 0);
    Visible = true;
    ZIndex = 10;
    Parent = StarLight.KeybindContainer;
})

StarLight:AddToRegistry(StarLight.KeybindFrame, {BorderColor3 = "Black"})

StarLight.KeybindInner = StarLight:Create("Frame", {
    BackgroundColor3 = StarLight.BackgroundColor;
    BorderColor3 = StarLight.OutlineColor;
    BorderMode = Enum.BorderMode.Inset;
    Size = UDim2.new(1, 0, 1, 0);
    ZIndex = 11;
    Parent = StarLight.KeybindFrame;
})

StarLight:AddToRegistry(StarLight.KeybindInner, {BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor"})

StarLight.KeybindLayout = StarLight:Create("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical;
    SortOrder = Enum.SortOrder.LayoutOrder;
    Parent = StarLight.KeybindInner;
})

StarLight.KeybindPadding = StarLight:Create("UIPadding", {
    PaddingTop = UDim.new(0, 4);
    Parent = StarLight.KeybindInner;
})

-- Toggle keybind
StarLight:GiveSignal(InputService.InputBegan:Connect(function(Input)
    if StarLight.Unloaded then return end
    if Input.KeyCode == Enum.KeyCode.RightShift then
        if StarLight.Window then
            StarLight.Window:Toggle()
        end
    end
    
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        for frame in next, StarLight.OpenedFrames do
            if not StarLight:MouseIsOverFrame(frame) then
                frame.Visible = false
                StarLight.OpenedFrames[frame] = nil
            end
        end
    end
end))

-- Cleanup
StarLight:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(Instance)
    if StarLight.Unloaded then return end
    if StarLight.RegistryMap[Instance] then StarLight:RemoveFromRegistry(Instance) end
end))

-- Return library
return StarLight
