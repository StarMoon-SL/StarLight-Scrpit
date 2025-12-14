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

local getgenv = getgenv or function()
 return shared
end
local setclipboard = setclipboard or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
 return CoreGui
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}

local Library = {
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
 CornerRadius = 4,

 IsLightTheme = false,
 Scheme = {
 BackgroundColor = Color3.fromRGB(15, 15, 15),
 MainColor = Color3.fromRGB(25, 25, 25),
 AccentColor = Color3.fromRGB(150, 100, 255),
 OutlineColor = Color3.fromRGB(255, 255, 255),
 FontColor = Color3.fromRGB(255, 255, 255),
 Font = Font.fromEnum(Enum.Font.Code),

 Red = Color3.fromRGB(255, 50, 50),
 Dark = Color3.new(0, 0, 0),
 White = Color3.new(1, 1, 1),
 },

 Registry = {},
 DPIRegistry = {},
}

local ObsidianImageManager = {
 Assets = {
 TransparencyTexture = {
 RobloxId = 139785960036434,
 Path = "Obsidian/assets/TransparencyTexture.png",

 Id = nil
 },

 SaturationMap = {
 RobloxId = 4155801252,
 Path = "Obsidian/assets/SaturationMap.png",

 Id = nil
 }
 }
}
do
 local BaseURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"

 local function RecursiveCreatePath(Path: string, IsFile: boolean?)
 if not isfolder or not makefolder then return end

 local Segments = Path:split("/")
 local TraversedPath = ""

 if IsFile then
 table.remove(Segments, #Segments)
 end

 for _, Segment in ipairs(Segments) do
 if not isfolder(TraversedPath .. Segment) then
 makefolder(TraversedPath .. Segment)
 end

 TraversedPath = TraversedPath .. Segment .. "/"
 end

 return TraversedPath
 end

 function ObsidianImageManager.GetAsset(AssetName: string)
 if not ObsidianImageManager.Assets[AssetName] then
 return nil
 end

 local AssetData = ObsidianImageManager.Assets[AssetName]
 if AssetData.Id then
 return AssetData.Id
 end

 local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)

 if getcustomasset then
 local Success, NewID = pcall(getcustomasset, AssetData.Path)

 if Success and NewID then
 AssetID = NewID
 end
 end

 AssetData.Id = AssetID
 return AssetID
 end

 function ObsidianImageManager.DownloadAsset(AssetPath: string)
 if not getcustomasset or not writefile or not isfile then
 return
 end

 RecursiveCreatePath(AssetPath, true)

 if isfile(AssetPath) then
 return
 end

 local URLPath = AssetPath:gsub("Obsidian/", "")
 writefile(AssetPath, game:HttpGet(BaseURL .. URLPath))
 end

 for _, Data in ObsidianImageManager.Assets do
 ObsidianImageManager.DownloadAsset(Data.Path)
 end
end

if RunService:IsStudio() then
 if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
 Library.IsMobile = true
 Library.MinSize = Vector2.new(480, 240)
 else
 Library.IsMobile = false
 Library.MinSize = Vector2.new(480, 360)
 end
else
 pcall(function()
 Library.DevicePlatform = UserInputService:GetPlatform()
 end)
 Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
 Library.MinSize = Library.IsMobile and Vector2.new(480, 240) or Vector2.new(480, 360)
end

local Templates = {
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
 FontFace = "Font",
 RichText = true,
 TextColor3 = "FontColor",
 },
 TextButton = {
 AutoButtonColor = false,
 BorderSizePixel = 0,
 FontFace = "Font",
 RichText = true,
 TextColor3 = "FontColor",
 },
 TextBox = {
 BorderSizePixel = 0,
 FontFace = "Font",
 PlaceholderColor3 = function()
 local H, S, V = Library.Scheme.FontColor:ToHSV()
 return Color3.fromHSV(H, S, V / 2)
 end,
 Text = "",
 TextColor3 = "FontColor",
 },
 UIListLayout = {
 SortOrder = Enum.SortOrder.LayoutOrder,
 },
 UIStroke = {
 ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
 },

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
 CornerRadius = 4,
 NotifySide = "Right",
 ShowCustomCursor = true,
 Font = Enum.Font.Code,
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

local function ApplyDPIScale(Dimension, ExtraOffset)
 if typeof(Dimension) == "UDim" then
 return UDim.new(Dimension.Scale, Dimension.Offset * Library.DPIScale)
 end

 if ExtraOffset then
 return UDim2.new(
 Dimension.X.Scale,
 (Dimension.X.Offset * Library.DPIScale) + (ExtraOffset[1] * Library.DPIScale),
 Dimension.Y.Scale,
 (Dimension.Y.Offset * Library.DPIScale) + (ExtraOffset[2] * Library.DPIScale)
 )
 end

 return UDim2.new(
 Dimension.X.Scale,
 Dimension.X.Offset * Library.DPIScale,
 Dimension.Y.Scale,
 Dimension.Y.Offset * Library.DPIScale
 )
end
local function ApplyTextScale(TextSize)
 return TextSize * Library.DPIScale
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
 and Library.IsRobloxFocused
end
local function IsHoverInput(Input: InputObject)
 return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
 and Input.UserInputState == Enum.UserInputState.Change
end
local function IsDragInput(Input: InputObject, IncludeM2: boolean?)
 return IsMouseInput(Input, IncludeM2)
 and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change)
 and Library.IsRobloxFocused
end

local function GetTableSize(Table: { [any]: any })
 local Size = 0

 for _, _ in pairs(Table) do
 Size += 1
 end

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

function Library:UpdateKeybindFrame()
 if not Library.KeybindFrame then
 return
 end

 local XSize = 0
 for _, KeybindToggle in pairs(Library.KeybindToggles) do
 if not KeybindToggle.Holder.Visible then
 continue
 end

 local FullSize = KeybindToggle.Label.Size.X.Offset + KeybindToggle.Label.Position.X.Offset
 if FullSize > XSize then
 XSize = FullSize
 end
 end

 Library.KeybindFrame.Size = UDim2.fromOffset(XSize + 18 * Library.DPIScale, 0)
end
function Library:UpdateDependencyBoxes()
 for _, Depbox in pairs(Library.DependencyBoxes) do
 Depbox:Update(true)
 end

 if Library.Searching then
 Library:UpdateSearch(Library.SearchText)
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

function Library:UpdateSearch(SearchText)
 Library.SearchText = SearchText

 if Library.LastSearchTab then
 for _, Groupbox in pairs(Library.LastSearchTab.Groupboxes) do
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

 for _, Tabbox in pairs(Library.LastSearchTab.Tabboxes) do
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

 for _, DepGroupbox in pairs(Library.LastSearchTab.DependencyGroupboxes) do
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
 if Trim(Search) == "" or Library.ActiveTab.IsKeyTab then
 Library.Searching = false
 Library.LastSearchTab = nil
 return
 end

 Library.Searching = true

 for _, Groupbox in pairs(Library.ActiveTab.Groupboxes) do
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

 for _, Tabbox in pairs(Library.ActiveTab.Tabboxes) do
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

 for _, DepGroupbox in pairs(Library.ActiveTab.DependencyGroupboxes) do
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

 Library.LastSearchTab = Library.ActiveTab
end

function Library:AddToRegistry(Instance, Properties)
 Library.Registry[Instance] = Properties
end

function Library:RemoveFromRegistry(Instance)
 Library.Registry[Instance] = nil
end

function Library:UpdateColorsUsingRegistry()
 for Instance, Properties in pairs(Library.Registry) do
 for Property, ColorIdx in pairs(Properties) do
 if typeof(ColorIdx) == "string" then
 Instance[Property] = Library.Scheme[ColorIdx]
 elseif typeof(ColorIdx) == "function" then
 Instance[Property] = ColorIdx()
 end
 end
 end
end

function Library:UpdateDPI(Instance, Properties)
 if not Library.DPIRegistry[Instance] then
 return
 end

 for Property, Value in pairs(Properties) do
 Library.DPIRegistry[Instance][Property] = Value and Value or nil
 end
end

function Library:SetDPIScale(DPIScale: number)
 Library.DPIScale = DPIScale / 100
 Library.MinSize *= Library.DPIScale

 for Instance, Properties in pairs(Library.DPIRegistry) do
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

 for _, Tab in pairs(Library.Tabs) do
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

 Library:UpdateKeybindFrame()
 for _, Notification in pairs(Library.Notifications) do
 Notification:Resize()
 end
end

function Library:GiveSignal(Connection: RBXScriptConnection)
 table.insert(Library.Signals, Connection)
 return Connection
end

function IsValidCustomIcon(Icon: string)
 return typeof(Icon) == "string" and (Icon:match("rbxasset") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

local FetchIcons, Icons = pcall(function()
 return loadstring(
 game:HttpGet("https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua")
 )()
end)
function Library:GetIcon(IconName: string)
 if not FetchIcons then
 return
 end
 local Success, Icon = pcall(Icons.GetAsset, IconName)
 if not Success then
 return
 end
 return Icon
end

function Library:GetCustomIcon(IconName: string)
 if not IsValidCustomIcon(IconName) then
 return Library:GetIcon(IconName)
 else
 return {
 Url = IconName,
 ImageRectOffset = Vector2.zero,
 ImageRectSize = Vector2.zero,
 Custom = true
 }
 end
end

function Library:Validate(Table: { [string]: any }, Template: { [string]: any }): { [string]: any }
 if typeof(Table) ~= "table" then
 return Template
 end

 for k, v in pairs(Template) do
 if typeof(k) == "number" then
 continue
 end

 if typeof(v) == "table" then
 Table[k] = Library:Validate(Table[k], v)
 elseif Table[k] == nil then
 Table[k] = v
 end
 end

 return Table
end

local function FillInstance(Table: { [string]: any }, Instance: GuiObject)
 local ThemeProperties = Library.Registry[Instance] or {}
 local DPIProperties = Library.DPIRegistry[Instance] or {}

 local DPIExclude = DPIProperties["DPIExclude"] or Table["DPIExclude"] or {}
 local DPIOffset = DPIProperties["DPIOffset"] or Table["DPIOffset"] or {}

 for k, v in pairs(Table) do
 if k == "DPIExclude" or k == "DPIOffset" then
 continue
 elseif ThemeProperties[k] then
 ThemeProperties[k] = nil
 elseif k ~= "Text" and (Library.Scheme[v] or typeof(v) == "function") then
 ThemeProperties[k] = v
 Instance[k] = Library.Scheme[v] or v()
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
 Library.Registry[Instance] = ThemeProperties
 end
 if GetTableSize(DPIProperties) > 0 then
 DPIProperties["DPIExclude"] = DPIExclude
 DPIProperties["DPIOffset"] = DPIOffset
 Library.DPIRegistry[Instance] = DPIProperties
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

local function SafeParentUI(Instance: Instance, Parent: Instance | () -> Instance)
 local success, _error = pcall(function()
 if not Parent then
 Parent = CoreGui
 end

 local DestinationParent
 if typeof(Parent) == "function" then
 DestinationParent = Parent()
 else
 DestinationParent = Parent
 end

 Instance.Parent = DestinationParent
 end)

 if not (success and Instance.Parent) then
 Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math.huge)
 end
end

local function ParentUI(UI: Instance, SkipHiddenUI: boolean?)
 if SkipHiddenUI then
 SafeParentUI(UI, CoreGui)
 return
 end

 pcall(protectgui, UI)
 SafeParentUI(UI, gethui)
end

local ScreenGui = New("ScreenGui", {
 Name = "Obsidian",
 DisplayOrder = 999,
 ResetOnSpawn = false,
})
ParentUI(ScreenGui)
Library.ScreenGui = ScreenGui
ScreenGui.DescendantRemoving:Connect(function(Instance)
 Library:RemoveFromRegistry(Instance)
 Library.DPIRegistry[Instance] = nil
end)

local ModalScreenGui = New("ScreenGui", {
 Name = "ObsidanModal",
 DisplayOrder = 999,
 ResetOnSpawn = false,
})
ParentUI(ModalScreenGui, true)

local ModalElement = New("TextButton", {
 BackgroundTransparency = 1,
 Modal = false,
 Size = UDim2.fromScale(0, 0),
 Text = "",
 ZIndex = -999,
 Parent = ModalScreenGui,
})

local Cursor
do
 Cursor = New("Frame", {
 AnchorPoint = Vector2.new(0.5, 0.5),
 BackgroundColor3 = "White",
 Size = UDim2.fromOffset(9, 1),
 Visible = false,
 ZIndex = 999,
 Parent = ScreenGui,
 })
 New("Frame", {
 AnchorPoint = Vector2.new(0.5, 0.5),
 BackgroundColor3 = "Dark",
 Position = UDim2.fromScale(0.5, 0.5),
 Size = UDim2.new(1, 2, 1, 2),
 ZIndex = 998,
 Parent = Cursor,
 })

 local CursorV = New("Frame", {
 AnchorPoint = Vector2.new(0.5, 0.5),
 BackgroundColor3 = "White",
 Position = UDim2.fromScale(0.5, 0.5),
 Size = UDim2.fromOffset(1, 9),
 Parent = Cursor,
 })
 New("Frame", {
 AnchorPoint = Vector2.new(0.5, 0.5),
 BackgroundColor3 = "Dark",
 Position = UDim2.fromScale(0.5, 0.5),
 Size = UDim2.new(1, 2, 1, 2),
 ZIndex = 998,
 Parent = CursorV,
 })
end

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

function Library:GetBetterColor(Color: Color3, Add: number): Color3
 Add = Add * (Library.IsLightTheme and -4 or 2)
 return Color3.fromRGB(
 math.clamp(Color.R * 255 + Add, 0, 255),
 math.clamp(Color.G * 255 + Add, 0, 255),
 math.clamp(Color.B * 255 + Add, 0, 255)
 )
end

function Library:GetDarkerColor(Color: Color3): Color3
 local H, S, V = Color:ToHSV()
 return Color3.fromHSV(H, S, V / 2)
end

function Library:GetKeyString(KeyCode: Enum.KeyCode)
 if KeyCode.EnumType == Enum.KeyCode and KeyCode.Value > 33 and KeyCode.Value < 127 then
 return string.char(KeyCode.Value)
 end

 return KeyCode.Name
end

function Library:GetTextBounds(Text: string, Font: Font, Size: number, Width: number?): (number, number)
 local Params = Instance.new("GetTextBoundsParams")
 Params.Text = Text
 Params.RichText = true
 Params.Font = Font
 Params.Size = Size
 Params.Width = Width or workspace.CurrentCamera.ViewportSize.X - 32

 local Bounds = TextService:GetTextBoundsAsync(Params)
 return Bounds.X, Bounds.Y
end

function Library:MouseIsOverFrame(Frame: GuiObject, Mouse: Vector2): boolean
 local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
 return Mouse.X >= AbsPos.X
 and Mouse.X <= AbsPos.X + AbsSize.X
 and Mouse.Y >= AbsPos.Y
 and Mouse.Y <= AbsPos.Y + AbsSize.Y
end

function Library:SafeCallback(Func: (...any) -> ...any, ...: any)
 if not (Func and typeof(Func) == "function") then
 return
 end

 local Result = table.pack(xpcall(Func, function(Error)
 task.defer(error, debug.traceback(Error, 2))
 if Library.NotifyOnError then
 Library:Notify(Error)
 end

 return Error
 end, ...))

 if not Result[1] then
 return nil
 end

 return table.unpack(Result, 2, Result.n)
end

function Library:MakeDraggable(UI: GuiObject, DragFrame: GuiObject, IgnoreToggled: boolean?, IsMainWindow: boolean?)
 local StartPos
 local FramePos
 local Dragging = false
 local Changed
 DragFrame.InputBegan:Connect(function(Input: InputObject)
 if not IsClickInput(Input) or IsMainWindow and Library.CantDragForced then
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
 Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
 if
 (not IgnoreToggled and not Library.Toggled)
 or (IsMainWindow and Library.CantDragForced)
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
 UI.Position =
 UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
 end
 end))
end

function Library:MakeResizable(UI: GuiObject, DragFrame: GuiObject, Callback: () -> ()?)
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
 Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
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
 math.clamp(FrameSize.X.Offset + Delta.X, Library.MinSize.X, math.huge),
 FrameSize.Y.Scale,
 math.clamp(FrameSize.Y.Offset + Delta.Y, Library.MinSize.Y, math.huge)
 )
 if Callback then
 Library:SafeCallback(Callback)
 end
 end
 end))
end

function Library:MakeCover(Holder: GuiObject, Place: string)
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

function Library:MakeLine(Frame: GuiObject, Info)
 local Line = New("Frame", {
 AnchorPoint = Info.AnchorPoint or Vector2.zero,
 BackgroundColor3 = "OutlineColor",
 Position = Info.Position,
 Size = Info.Size,
 Parent = Frame,
 })

 return Line
end

function Library:MakeOutline(Frame: GuiObject, Corner: number?, ZIndex: number?)
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

function Library:AddDraggableButton(Text: string, Func)
 local Table = {}

 local Button = New("TextButton", {
 BackgroundColor3 = "BackgroundColor",
 Position = UDim2.fromOffset(6, 6),
 TextSize = 16,
 ZIndex = 10,
 Parent = ScreenGui,

 DPIExclude = {
 Position = true,
 },
 })
 New("UICorner", {
 CornerRadius = UDim.new(0, Library.CornerRadius - 1),
 Parent = Button,
 })
 Library:MakeOutline(Button, Library.CornerRadius, 9)

 Table.Button = Button
 Button.MouseButton1Click:Connect(function()
 Library:SafeCallback(Func, Table)
 end)
 Library:MakeDraggable(Button, Button, true)

 function Table:SetText(NewText: string)
 local X, Y = Library:GetTextBounds(NewText, Library.Scheme.Font, 16)

 Button.Text = NewText
 Button.Size = UDim2.fromOffset(X * Library.DPIScale * 2, Y * Library.DPIScale * 2)
 Library:UpdateDPI(Button, {
 Size = UDim2.fromOffset(X * 2, Y * 2),
 })
 end
 Table:SetText(Text)

 return Table
end

function Library:AddDraggableMenu(Name: string)
 local Background = Library:MakeOutline(ScreenGui, Library.CornerRadius, 10)
 Background.AutomaticSize = Enum.AutomaticSize.Y
 Background.Position = UDim2.fromOffset(6, 6)
 Background.Size = UDim2.fromOffset(0, 0)
 Library:UpdateDPI(Background, {
 Position = false,
 Size = false,
 })

 local Holder = New("Frame", {
 BackgroundColor3 = "BackgroundColor",
 Position = UDim2.fromOffset(2, 2),
 Size = UDim2.new(1, -4, 1, -4),
 Parent = Background,
 })
 New("UICorner", {
 CornerRadius = UDim.new(0, Library.CornerRadius - 1),
 Parent = Holder,
 })
 Library:MakeLine(Holder, {
 Position = UDim2.fromOffset(0, 34),
 Size = UDim2.new(1, 0, 0, 1),
 })

 local Label = New("TextLabel", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 34),
 Text = Name,
 TextSize = 15,
 TextXAlignment = Enum.TextXAlignment.Left,
 Parent = Holder,
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

 Library:MakeDraggable(Background, Label, true)
 return Background, Container
end

do
 local WatermarkBackground = Library:MakeOutline(ScreenGui, Library.CornerRadius, 10)
 WatermarkBackground.AutomaticSize = Enum.AutomaticSize.Y
 WatermarkBackground.Position = UDim2.fromOffset(6, 6)
 WatermarkBackground.Size = UDim2.fromOffset(0, 0)
 WatermarkBackground.Visible = false

 Library:UpdateDPI(WatermarkBackground, {
 Position = false,
 Size = false,
 })

 local Holder = New("Frame", {
 BackgroundColor3 = "BackgroundColor",
 Position = UDim2.fromOffset(2, 2),
 Size = UDim2.new(1, -4, 1, -4),
 Parent = WatermarkBackground,
 })
 New("UICorner", {
 CornerRadius = UDim.new(0, Library.CornerRadius - 1),
 Parent = Holder,
 })

 local WatermarkLabel = New("TextLabel", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 32),
 Position = UDim2.fromOffset(0, -8 * Library.DPIScale + 7),
 Text = "",
 TextSize = 15,
 TextXAlignment = Enum.TextXAlignment.Left,
 Parent = Holder,
 })
 New("UIPadding", {
 PaddingLeft = UDim.new(0, 12),
 PaddingRight = UDim.new(0, 12),
 Parent = WatermarkLabel,
 })

 Library:MakeDraggable(WatermarkBackground, WatermarkLabel, true)

 local function ResizeWatermark()
 local X, Y = Library:GetTextBounds(WatermarkLabel.Text, Library.Scheme.Font, 15)
 WatermarkBackground.Size = UDim2.fromOffset((12 + X + 12 + 4) * Library.DPIScale, Y * Library.DPIScale * 2 + 4)
 Library:UpdateDPI(WatermarkBackground, {
 Size = UDim2.fromOffset(12 + X + 12 + 4, Y * 2 + 4),
 })
 end

 function Library:SetWatermarkVisibility(Visible: boolean)
 WatermarkBackground.Visible = Visible
 if Visible then
 ResizeWatermark()
 end
 end

 function Library:SetWatermark(Text: string)
 WatermarkLabel.Text = Text
 ResizeWatermark()
 end
end

local CurrentMenu
function Library:AddContextMenu(
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
 BackgroundColor3 = "BackgroundColor",
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
 CanvasSize = UDim2.fromOffset(0, 0),
 ScrollBarImageColor3 = "OutlineColor",
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
 else
 Menu = New("Frame", {
 BackgroundColor3 = "BackgroundColor",
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 Size = typeof(Size) == "function" and Size() or Size,
 Visible = false,
 ZIndex = 10,
 Parent = ScreenGui,

 DPIExclude = {
 Position = true,
 },
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
 Library:SafeCallback(ActiveCallback, true)
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
 Library:SafeCallback(ActiveCallback, false)
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

Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
 if IsClickInput(Input, true) then
 local Location = Input.Position

 if
 CurrentMenu
 and not (
 Library:MouseIsOverFrame(CurrentMenu.Menu, Location)
 or Library:MouseIsOverFrame(CurrentMenu.Holder, Location)
 )
 then
 CurrentMenu:Close()
 end
 end
end))

local TooltipLabel = New("TextLabel", {
 BackgroundColor3 = "BackgroundColor",
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 TextSize = 14,
 TextWrapped = true,
 Visible = false,
 ZIndex = 20,
 Parent = ScreenGui,
})
TooltipLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
 local X, Y = Library:GetTextBounds(
 TooltipLabel.Text,
 TooltipLabel.FontFace,
 TooltipLabel.TextSize,
 workspace.CurrentCamera.ViewportSize.X - TooltipLabel.AbsolutePosition.X - 4
 )

 TooltipLabel.Size = UDim2.fromOffset(X + 8 * Library.DPIScale, Y + 4 * Library.DPIScale)
 Library:UpdateDPI(TooltipLabel, {
 Size = UDim2.fromOffset(X, Y),
 DPIOffset = {
 Size = { 8, 4 },
 },
 })
end)

local CurrentHoverInstance
function Library:AddTooltip(InfoStr: string, DisabledInfoStr: string, HoverInstance: GuiObject)
 local TooltipTable = {
 Disabled = false,
 Hovering = false,
 Signals = {},
 }

 local function DoHover()
 if
 CurrentHoverInstance == HoverInstance
 or (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
 or (TooltipTable.Disabled and typeof(DisabledInfoStr) ~= "string")
 or (not TooltipTable.Disabled and typeof(InfoStr) ~= "string")
 then
 return
 end
 CurrentHoverInstance = HoverInstance

 TooltipLabel.Text = TooltipTable.Disabled and DisabledInfoStr or InfoStr
 TooltipLabel.Visible = true

 while
 Library.Toggled
 and Library:MouseIsOverFrame(HoverInstance, Mouse)
 and not (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
 do
 TooltipLabel.Position = UDim2.fromOffset(
 Mouse.X + (Library.ShowCustomCursor and 8 or 14),
 Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
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

function Library:OnUnload(Callback)
 table.insert(Library.UnloadSignals, Callback)
end

function Library:Unload()
 for Index = #Library.Signals, 1, -1 do
 local Connection = table.remove(Library.Signals, Index)
 Connection:Disconnect()
 end

 for _, Callback in pairs(Library.UnloadSignals) do
 Library:SafeCallback(Callback)
 end

 Library.Unloaded = true
 ScreenGui:Destroy()
 ModalScreenGui:Destroy()
 getgenv().Library = nil
end

local CheckIcon = Library:GetIcon("check")
local ArrowIcon = Library:GetIcon("chevron-up")
local ResizeIcon = Library:GetIcon("move-diagonal-2")
local KeyIcon = Library:GetIcon("key")

local BaseAddons = {}
do
 local Funcs = {}

 function Funcs:AddKeyPicker(Idx, Info)
 Info = Library:Validate(Info, Templates.KeyPicker)

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
 BackgroundColor3 = "MainColor",
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 Size = UDim2.fromOffset(18, 18),
 Text = KeyPicker.Value,
 TextSize = 14,
 Parent = ToggleLabel,
 })

 local KeybindsToggle = { Normal = KeyPicker.Mode ~= "Toggle" }; do
 local Holder = New("TextButton", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 16),
 Text = "",
 Visible = not Info.NoUI,
 Parent = Library.KeybindContainer,
 })

 local Label = New("TextLabel", {
 BackgroundTransparency = 1,
 Size = UDim2.fromScale(1, 1),
 Text = "",
 TextSize = 14,
 TextTransparency = 0.5,
 Parent = Holder,

 DPIExclude = {
 Size = true,
 },
 })

 local Checkbox = New("Frame", {
 BackgroundColor3 = "MainColor",
 Size = UDim2.fromOffset(14, 14),
 SizeConstraint = Enum.SizeConstraint.RelativeYY,
 Parent = Holder,
 })
 New("UICorner", {
 CornerRadius = UDim.new(0, Library.CornerRadius / 2),
 Parent = Checkbox,
 })
 New("UIStroke", {
 Color = "OutlineColor",
 Parent = Checkbox,
 })

 local CheckImage = New("ImageLabel", {
 Image = CheckIcon and CheckIcon.Url or "",
 ImageColor3 = "FontColor",
 ImageRectOffset = CheckIcon and CheckIcon.ImageRectOffset or Vector2.zero,
 ImageRectSize = CheckIcon and CheckIcon.ImageRectSize or Vector2.zero,
 ImageTransparency = 1,
 Position = UDim2.fromOffset(2, 2),
 Size = UDim2.new(1, -4, 1, -4),
 Parent = Checkbox,
 })

 function KeybindsToggle:Display(State)
 Label.TextTransparency = State and 0 or 0.5
 CheckImage.ImageTransparency = State and 0 or 1
 end

 function KeybindsToggle:SetText(Text)
 local X = Library:GetTextBounds(Text, Label.FontFace, Label.TextSize)
 Label.Text = Text
 Label.Size = UDim2.new(0, X, 1, 0)
 end

 function KeybindsToggle:SetVisibility(Visibility)
 Holder.Visible = Visibility
 end

 function KeybindsToggle:SetNormal(Normal)
 KeybindsToggle.Normal = Normal

 Holder.Active = not Normal
 Label.Position = Normal and UDim2.fromOffset(0, 0) or UDim2.fromOffset(22 * Library.DPIScale, 0)
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
 table.insert(Library.KeybindToggles, KeybindsToggle)
 end

 local MenuTable = Library:AddContextMenu(Picker, UDim2.fromOffset(62, 0), function()
 return { Picker.AbsoluteSize.X + 1.5, 0.5 }
 end, 1)
 KeyPicker.Menu = MenuTable

 local ModeButtons = {}
 for _, Mode in pairs(Info.Modes) do
 local ModeButton = {}

 local Button = New("TextButton", {
 BackgroundColor3 = "MainColor",
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 21),
 Text = Mode,
 TextSize = 14,
 TextTransparency = 0.5,
 Parent = MenuTable.Menu,
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
 if Library.Unloaded then
 return
 end

 local X, Y =
 Library:GetTextBounds(KeyPicker.Value, Picker.FontFace, Picker.TextSize, ToggleLabel.AbsoluteSize.X)
 Picker.Text = KeyPicker.Value
 Picker.Size = UDim2.fromOffset(X + 9 * Library.DPIScale, Y + 4 * Library.DPIScale)
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
 local ShowToggle = Library.ShowToggleFrameInKeybinds and KeyPicker.Mode == "Toggle"

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

 Library:UpdateKeybindFrame()
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

 Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
 Library:SafeCallback(KeyPicker.Changed, KeyPicker.Toggled)

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
 Picker.Size = UDim2.fromOffset(29 * Library.DPIScale, 18 * Library.DPIScale)

 local Input = UserInputService.InputBegan:Wait()
 local Key = "Unknown"

 if SpecialKeys[Input.UserInputType] ~= nil then
 Key = SpecialKeys[Input.UserInputType];

 elseif Input.UserInputType == Enum.UserInputType.Keyboard then
 Key = Input.KeyCode == Enum.KeyCode.Escape and "None" or Input.KeyCode.Name
 end

 KeyPicker.Value = Key
 KeyPicker:Update()

 Library:SafeCallback(
 KeyPicker.ChangedCallback,
 Input.KeyCode == Enum.KeyCode.Unknown and Input.UserInputType or Input.KeyCode
 )
 Library:SafeCallback(
 KeyPicker.Changed,
 Input.KeyCode == Enum.KeyCode.Unknown and Input.UserInputType or Input.KeyCode
 )

 RunService.RenderStepped:Wait()
 Picking = false
 end)
 Picker.MouseButton2Click:Connect(MenuTable.Toggle)

 Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
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
 SpecialKeys[Input.UserInputType] == Key or
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

 Library:GiveSignal(UserInputService.InputEnded:Connect(function()
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
 Info = Library:Validate(Info, Templates.ColorPicker)

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

 local Holder = New("TextButton", {
 BackgroundColor3 = ColorPicker.Value,
 BorderColor3 = Library:GetDarkerColor(ColorPicker.Value),
 BorderSizePixel = 1,
 Size = UDim2.fromOffset(18, 18),
 Text = "",
 Parent = ToggleLabel,
 })

 local HolderTransparency = New("ImageLabel", {
 Image = ObsidianImageManager.GetAsset("TransparencyTexture"),
 ImageTransparency = (1 - ColorPicker.Transparency),
 ScaleType = Enum.ScaleType.Tile,
 Size = UDim2.fromScale(1, 1),
 TileSize = UDim2.fromOffset(9, 9),
 Parent = Holder,
 })

 local ColorMenu = Library:AddContextMenu(
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
 TextXAlignment = Enum.TextXAlignment.Left,
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

 local SatVipMap = New("ImageButton", {
 BackgroundColor3 = ColorPicker.Value,
 Image = ObsidianImageManager.GetAsset("SaturationMap"),
 Size = UDim2.fromOffset(200, 200),
 Parent = ColorHolder,
 })

 local SatVibCursor = New("Frame", {
 AnchorPoint = Vector2.new(0.5, 0.5),
 BackgroundColor3 = "White",
 Size = UDim2.fromOffset(6, 6),
 Parent = SatVipMap,
 })
 New("UICorner", {
 CornerRadius = UDim.new(1, 0),
 Parent = SatVibCursor,
 })
 New("UIStroke", {
 Color = "Dark",
 Parent = SatVibCursor,
 })

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
 BackgroundColor3 = "White",
 BorderColor3 = "Dark",
 BorderSizePixel = 1,
 Position = UDim2.fromScale(0.5, ColorPicker.Hue),
 Size = UDim2.new(1, 2, 0, 1),
 Parent = HueSelector,
 })

 local TransparencySelector, TransparencyColor, TransparencyCursor
 if Info.Transparency then
 TransparencySelector = New("ImageButton", {
 Image = ObsidianImageManager.GetAsset("TransparencyTexture"),
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
 BackgroundColor3 = "White",
 BorderColor3 = "Dark",
 BorderSizePixel = 1,
 Position = UDim2.fromScale(0.5, ColorPicker.Transparency),
 Size = UDim2.new(1, 2, 0, 1),
 Parent = TransparencySelector,
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
 BackgroundColor3 = "MainColor",
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 ClearTextOnFocus = false,
 Size = UDim2.fromScale(1, 1),
 Text = "#??????",
 TextSize = 14,
 Parent = InfoHolder,
 })

 local RgbBox = New("TextBox", {
 BackgroundColor3 = "MainColor",
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 ClearTextOnFocus = false,
 Size = UDim2.fromScale(1, 1),
 Text = "?, ?, ?",
 TextSize = 14,
 Parent = InfoHolder,
 })

 local ContextMenu = Library:AddContextMenu(Holder, UDim2.fromOffset(93, 0), function()
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
 Parent = ContextMenu.Menu,
 })

 Button.MouseButton1Click:Connect(function()
 Library:SafeCallback(Func)
 ContextMenu:Close()
 end)
 end

 CreateButton("Copy color", function()
 Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }
 end)

 CreateButton("Paste color", function()
 ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
 end)

 if setclipboard then
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
 end

 function ColorPicker:SetHSVFromRGB(Color)
 ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
 end

 function ColorPicker:Display()
 if Library.Unloaded then
 return
 end

 ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)

 Holder.BackgroundColor3 = ColorPicker.Value
 Holder.BorderColor3 = Library:GetDarkerColor(ColorPicker.Value)
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

 Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
 Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
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
 BackgroundColor3 = "MainColor",
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 Size = UDim2.new(1, 0, 0, 2),
 Parent = Container,
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
 TextWrapped = Label.DoesWrap,
 TextXAlignment = Groupbox.IsKeyTab and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
 Parent = Container,
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
 Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
 TextLabel.Size = UDim2.new(1, 0, 0, Y + 4 * Library.DPIScale)
 end

 Groupbox:Resize()
 end

 if Label.DoesWrap then
 local _, Y =
 Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
 TextLabel.Size = UDim2.new(1, 0, 0, Y + 4 * Library.DPIScale)
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
 Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
 TextLabel.Size = UDim2.new(1, 0, 0, Y + 4 * Library.DPIScale)

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
 BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor",
 Size = UDim2.fromScale(1, 1),
 Text = Button.Text,
 TextSize = 14,
 TextTransparency = 0.4,
 Visible = Button.Visible,
 Parent = Holder,
 })

 local Stroke = New("UIStroke", {
 Color = "OutlineColor",
 Transparency = Button.Disabled and 0.5 or 0,
 Parent = Base,
 })

 return Base, Stroke
 end

 local function InitEvents(Button)
 Button.Base.MouseEnter:Connect(function()
 if Button.Disabled then
 return
 end

 Button.Tween = TweenService:Create(Button.Base, Library.TweenInfo, {
 TextTransparency = 0,
 })
 Button.Tween:Play()
 end)
 Button.Base.MouseLeave:Connect(function()
 if Button.Disabled then
 return
 end

 Button.Tween = TweenService:Create(Button.Base, Library.TweenInfo, {
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
 Button.Base.TextColor3 = Library.Scheme.AccentColor
 Library.Registry[Button.Base].TextColor3 = "AccentColor"

 local Clicked = WaitForEvent(Button.Base.MouseButton1Click, 0.5)

 Button.Base.Text = Button.Text
 Button.Base.TextColor3 = Button.Risky and Library.Scheme.Red or Library.Scheme.FontColor
 Library.Registry[Button.Base].TextColor3 = Button.Risky and "Red" or "FontColor"

 if Clicked then
 Library:SafeCallback(Button.Func)
 end

 RunService.RenderStepped:Wait()
 Button.Locked = false
 return
 end

 Library:SafeCallback(Button.Func)
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
 if Library.Unloaded then
 return
 end

 StopTween(SubButton.Tween)

 SubButton.Base.BackgroundColor3 = SubButton.Disabled and Library.Scheme.BackgroundColor
 or Library.Scheme.MainColor
 SubButton.Base.TextTransparency = SubButton.Disabled and 0.8 or 0.4
 SubButton.Stroke.Transparency = SubButton.Disabled and 0.5 or 0

 Library.Registry[SubButton.Base].BackgroundColor3 = SubButton.Disabled and "BackgroundColor"
 or "MainColor"
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
 Library:AddTooltip(SubButton.Tooltip, SubButton.DisabledTooltip, SubButton.Base)
 SubButton.TooltipTable.Disabled = SubButton.Disabled
 end

 if SubButton.Risky then
 SubButton.Base.TextColor3 = Library.Scheme.Red
 Library.Registry[SubButton.Base].TextColor3 = "Red"
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
 if Library.Unloaded then
 return
 end

 StopTween(Button.Tween)

 Button.Base.BackgroundColor3 = Button.Disabled and Library.Scheme.BackgroundColor
 or Library.Scheme.MainColor
 Button.Base.TextTransparency = Button.Disabled and 0.8 or 0.4
 Button.Stroke.Transparency = Button.Disabled and 0.5 or 0

 Library.Registry[Button.Base].BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor"
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
 Button.TooltipTable = Library:AddTooltip(Button.Tooltip, Button.DisabledTooltip, Button.Base)
 Button.TooltipTable.Disabled = Button.Disabled
 end

 if Button.Risky then
 Button.Base.TextColor3 = Library.Scheme.Red
 Library.Registry[Button.Base].TextColor3 = "Red"
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

 function Funcs:AddCheckbox(Idx, Info)
 Info = Library:Validate(Info, Templates.Toggle)

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
 Position = UDim2.fromOffset(26, 0),
 Size = UDim2.new(1, -26, 1, 0),
 Text = Toggle.Text,
 TextSize = 14,
 TextTransparency = 0.4,
 TextXAlignment = Enum.TextXAlignment.Left,
 Parent = Button,
 })

 New("UIListLayout", {
 FillDirection = Enum.FillDirection.Horizontal,
 HorizontalAlignment = Enum.HorizontalAlignment.Right,
 Padding = UDim.new(0, 6),
 Parent = Label,
 })

 local Checkbox = New("Frame", {
 BackgroundColor3 = "MainColor",
 Size = UDim2.fromScale(1, 1),
 SizeConstraint = Enum.SizeConstraint.RelativeYY,
 Parent = Button,
 })
 New("UICorner", {
 CornerRadius = UDim.new(0, Library.CornerRadius / 2),
 Parent = Checkbox,
 })

 local CheckboxStroke = New("UIStroke", {
 Color = "OutlineColor",
 Parent = Checkbox,
 })

 local CheckImage = New("ImageLabel", {
 Image = CheckIcon and CheckIcon.Url or "",
 ImageColor3 = "FontColor",
 ImageRectOffset = CheckIcon and CheckIcon.ImageRectOffset or Vector2.zero,
 ImageRectSize = CheckIcon and CheckIcon.ImageRectSize or Vector2.zero,
 ImageTransparency = 1,
 Position = UDim2.fromOffset(2, 2),
 Size = UDim2.new(1, -4, 1, -4),
 Parent = Checkbox,
 })

 function Toggle:UpdateColors()
 Toggle:Display()
 end

 function Toggle:Display()
 if Library.Unloaded then
 return
 end

 CheckboxStroke.Transparency = Toggle.Disabled and 0.5 or 0

 if Toggle.Disabled then
 Label.TextTransparency = 0.8
 CheckImage.ImageTransparency = Toggle.Value and 0.8 or 1

 Checkbox.BackgroundColor3 = Library.Scheme.BackgroundColor
 Library.Registry[Checkbox].BackgroundColor3 = "BackgroundColor"

 return
 end

 TweenService:Create(Label, Library.TweenInfo, {
 TextTransparency = Toggle.Value and 0 or 0.4,
 }):Play()
 TweenService:Create(CheckImage, Library.TweenInfo, {
 ImageTransparency = Toggle.Value and 0 or 1,
 }):Play()

 Checkbox.BackgroundColor3 = Library.Scheme.MainColor
 Library.Registry[Checkbox].BackgroundColor3 = "MainColor"
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

 Library:SafeCallback(Toggle.Callback, Toggle.Value)
 Library:SafeCallback(Toggle.Changed, Toggle.Value)
 Library:UpdateDependencyBoxes()
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
 Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
 Toggle.TooltipTable.Disabled = Toggle.Disabled
 end

 if Toggle.Risky then
 Label.TextColor3 = Library.Scheme.Red
 Library.Registry[Label].TextColor3 = "Red"
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

 function Funcs:AddToggle(Idx, Info)
 if Library.ForceCheckbox then
 return Funcs.AddCheckbox(self, Idx, Info)
 end

 Info = Library:Validate(Info, Templates.Toggle)

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
 TextTransparency = 0.4,
 TextXAlignment = Enum.TextXAlignment.Left,
 Parent = Button,
 })

 New("UIListLayout", {
 FillDirection = Enum.FillDirection.Horizontal,
 HorizontalAlignment = Enum.HorizontalAlignment.Right,
 Padding = UDim.new(0, 6),
 Parent = Label,
 })

 local Switch = New("Frame", {
 AnchorPoint = Vector2.new(1, 0),
 BackgroundColor3 = "MainColor",
 Position = UDim2.fromScale(1, 0),
 Size = UDim2.fromOffset(32, 18),
 Parent = Button,
 })
 New("UICorner", {
 CornerRadius = UDim.new(1, 0),
 Parent = Switch,
 })
 New("UIPadding", {
 PaddingBottom = UDim.new(0, 2),
 PaddingLeft = UDim.new(0, 2),
 PaddingRight = UDim.new(0, 2),
 PaddingTop = UDim.new(0, 2),
 Parent = Switch,
 })
 local SwitchStroke = New("UIStroke", {
 Color = "OutlineColor",
 Parent = Switch,
 })

 local Ball = New("Frame", {
 BackgroundColor3 = "FontColor",
 Size = UDim2.fromScale(1, 1),
 SizeConstraint = Enum.SizeConstraint.RelativeYY,
 Parent = Switch,
 })
 New("UICorner", {
 CornerRadius = UDim.new(1, 0),
 Parent = Ball,
 })

 function Toggle:UpdateColors()
 Toggle:Display()
 end

 function Toggle:Display()
 if Library.Unloaded then
 return
 end

 local Offset = Toggle.Value and 1 or 0

 Switch.BackgroundTransparency = Toggle.Disabled and 0.75 or 0
 SwitchStroke.Transparency = Toggle.Disabled and 0.75 or 0

 Switch.BackgroundColor3 = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.MainColor
 SwitchStroke.Color = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.OutlineColor

 Library.Registry[Switch].BackgroundColor3 = Toggle.Value and "AccentColor" or "MainColor"
 Library.Registry[SwitchStroke].Color = Toggle.Value and "AccentColor" or "OutlineColor"

 if Toggle.Disabled then
 Label.TextTransparency = 0.8
 Ball.AnchorPoint = Vector2.new(Offset, 0)
 Ball.Position = UDim2.fromScale(Offset, 0)

 Ball.BackgroundColor3 = Library:GetDarkerColor(Library.Scheme.FontColor)
 Library.Registry[Ball].BackgroundColor3 = function()
 return Library:GetDarkerColor(Library.Scheme.FontColor)
 end

 return
 end

 TweenService:Create(Label, Library.TweenInfo, {
 TextTransparency = Toggle.Value and 0 or 0.4,
 }):Play()
 TweenService:Create(Ball, Library.TweenInfo, {
 AnchorPoint = Vector2.new(Offset, 0),
 Position = UDim2.fromScale(Offset, 0),
 }):Play()

 Ball.BackgroundColor3 = Library.Scheme.FontColor
 Library.Registry[Ball].BackgroundColor3 = "FontColor"
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

 Library:SafeCallback(Toggle.Callback, Toggle.Value)
 Library:SafeCallback(Toggle.Changed, Toggle.Value)
 Library:UpdateDependencyBoxes()
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
 Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
 Toggle.TooltipTable.Disabled = Toggle.Disabled
 end

 if Toggle.Risky then
 Label.TextColor3 = Library.Scheme.Red
 Library.Registry[Label].TextColor3 = "Red"
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

 function Funcs:AddInput(Idx, Info)
 Info = Library:Validate(Info, Templates.Input)

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
 TextXAlignment = Enum.TextXAlignment.Left,
 Parent = Holder,
 })

 local Box = New("TextBox", {
 AnchorPoint = Vector2.new(0, 1),
 BackgroundColor3 = "MainColor",
 BackgroundTransparency = 0.95,
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus,
 PlaceholderText = Input.Placeholder,
 Position = UDim2.fromScale(0, 1),
 Size = UDim2.new(1, 0, 0, 21),
 Text = Input.Value,
 TextEditable = not Input.Disabled,
 TextScaled = true,
 TextXAlignment = Enum.TextXAlignment.Left,
 Parent = Holder,
 })

 New("UIPadding", {
 PaddingBottom = UDim.new(0, 3),
 PaddingLeft = UDim.new(0, 8),
 PaddingRight = UDim.new(0, 8),
 PaddingTop = UDim.new(0, 4),
 Parent = Box,
 })

 function Input:UpdateColors()
 if Library.Unloaded then
 return
 end

 Label.TextTransparency = Input.Disabled and 0.8 or 0
 Box.TextTransparency = Input.Disabled and 0.8 or 0
 end

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
 Library:SafeCallback(Input.Callback, Input.Value)
 Library:SafeCallback(Input.Changed, Input.Value)
 end
 end

 function Input:SetDisabled(Disabled: boolean)
 Input.Disabled = Disabled

 if Input.TooltipTable then
 Input.TooltipTable.Disabled = Input.Disabled
 end

 Box.ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus
 Box.TextEditable = not Input.Disabled
 Input:UpdateColors()
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
 Input.TooltipTable = Library:AddTooltip(Input.Tooltip, Input.DisabledTooltip, Box)
 Input.TooltipTable.Disabled = Input.Disabled
 end

 Groupbox:Resize()

 Input.Holder = Holder
 table.insert(Groupbox.Elements, Input)

 Options[Idx] = Input

 return Input
 end

 function Funcs:AddSlider(Idx, Info)
 Info = Library:Validate(Info, Templates.Slider)

 local Groupbox = self
 local Container = Groupbox.Container

 local Slider = {
 Text = Info.Text,
 Value = Info.Default,
 Min = Info.Min,
 Max = Info.Max,

 Prefix = Info.Prefix,
 Suffix = Info.Suffix,
 Compact = Info.Compact,
 Rounding = Info.Rounding,

 Tooltip = Info.Tooltip,
 DisabledTooltip = Info.DisabledTooltip,
 TooltipTable = nil,

 Callback = Info.Callback,
 Changed = Info.Changed,

 Disabled = Info.Disabled,
 Visible = Info.Visible,

 Type = "Slider",
 }

 local Holder = New("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, Info.Compact and 13 or 31),
 Visible = Slider.Visible,
 Parent = Container,
 })

 local SliderLabel
 if not Info.Compact then
 SliderLabel = New("TextLabel", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 14),
 Text = Slider.Text,
 TextSize = 14,
 TextXAlignment = Enum.TextXAlignment.Left,
 Parent = Holder,
 })
 end

 local Bar = New("TextButton", {
 Active = not Slider.Disabled,
 AnchorPoint = Vector2.new(0, 1),
 BackgroundColor3 = "MainColor",
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 Position = UDim2.fromScale(0, 1),
 Size = UDim2.new(1, 0, 0, 13),
 Text = "",
 Parent = Holder,
 })

 local DisplayLabel = New("TextLabel", {
 BackgroundTransparency = 1,
 Size = UDim2.fromScale(1, 1),
 Text = "",
 TextSize = 14,
 ZIndex = 2,
 Parent = Bar,
 })
 New("UIStroke", {
 ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
 Color = "Dark",
 LineJoinMode = Enum.LineJoinMode.Miter,
 Parent = DisplayLabel,
 })

 local Fill = New("Frame", {
 BackgroundColor3 = "AccentColor",
 Size = UDim2.fromScale(0.5, 1),
 Parent = Bar,

 DPIExclude = {
 Size = true,
 },
 })

 function Slider:UpdateColors()
 if Library.Unloaded then
 return
 end

 if SliderLabel then
 SliderLabel.TextTransparency = Slider.Disabled and 0.8 or 0
 end
 DisplayLabel.TextTransparency = Slider.Disabled and 0.8 or 0

 Fill.BackgroundColor3 = Slider.Disabled and Library.Scheme.OutlineColor or Library.Scheme.AccentColor
 Library.Registry[Fill].BackgroundColor3 = Slider.Disabled and "OutlineColor" or "AccentColor"
 end

 function Slider:Display()
 if Library.Unloaded then
 return
 end

 local CustomDisplayText = nil
 if Info.FormatDisplayValue then
 CustomDisplayText = Info.FormatDisplayValue(Slider, Slider.Value)
 end

 if CustomDisplayText then
 DisplayLabel.Text = tostring(CustomDisplayText)
 else
 if Info.Compact then
 DisplayLabel.Text = string.format("%s: %s%s%s", Slider.Text, Slider.Prefix, Slider.Value, Slider.Suffix)
 elseif Info.HideMax then
 DisplayLabel.Text = string.format("%s%s%s", Slider.Prefix, Slider.Value, Slider.Suffix)
 else
 DisplayLabel.Text = string.format(
 "%s%s%s/%s%s%s",
 Slider.Prefix,
 Slider.Value,
 Slider.Suffix,
 Slider.Prefix,
 Slider.Max,
 Slider.Suffix
 )
 end
 end

 local X = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
 Fill.Size = UDim2.fromScale(X, 1)
 end

 function Slider:OnChanged(Func)
 Slider.Changed = Func
 end

 function Slider:SetMax(Value)
 assert(Value > Slider.Min, "Max value cannot be less than the current min value.")

 Slider.Value = math.clamp(Slider.Value, Slider.Min, Value)
 Slider.Max = Value
 Slider:Display()
 end

 function Slider:SetMin(Value)
 assert(Value < Slider.Max, "Min value cannot be greater than the current max value.")

 Slider.Value = math.clamp(Slider.Value, Value, Slider.Max)
 Slider.Min = Value
 Slider:Display()
 end

 function Slider:SetValue(Str)
 if Slider.Disabled then
 return
 end

 local Num = tonumber(Str)
 if not Num then
 return
 end

 Num = math.clamp(Num, Slider.Min, Slider.Max)

 Slider.Value = Num
 Slider:Display()

 Library:SafeCallback(Slider.Callback, Slider.Value)
 Library:SafeCallback(Slider.Changed, Slider.Value)
 end

 function Slider:SetDisabled(Disabled: boolean)
 Slider.Disabled = Disabled

 if Slider.TooltipTable then
 Slider.TooltipTable.Disabled = Slider.Disabled
 end

 Bar.Active = not Slider.Disabled
 Slider:UpdateColors()
 end

 function Slider:SetVisible(Visible: boolean)
 Slider.Visible = Visible

 Holder.Visible = Slider.Visible
 Groupbox:Resize()
 end

 function Slider:SetText(Text: string)
 Slider.Text = Text
 if SliderLabel then
 SliderLabel.Text = Text
 return
 end
 Slider:Display()
 end

 function Slider:SetPrefix(Prefix: string)
 Slider.Prefix = Prefix
 Slider:Display()
 end

 function Slider:SetSuffix(Suffix: string)
 Slider.Suffix = Suffix
 Slider:Display()
 end

 Bar.InputBegan:Connect(function(Input: InputObject)
 if not IsClickInput(Input) or Slider.Disabled then
 return
 end

 for _, Side in pairs(Library.ActiveTab.Sides) do
 Side.ScrollingEnabled = false
 end

 while IsDragInput(Input) do
 local Location = Mouse.X
 local Scale = math.clamp((Location - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)

 local OldValue = Slider.Value
 Slider.Value = Round(Slider.Min + ((Slider.Max - Slider.Min) * Scale), Slider.Rounding)

 Slider:Display()
 if Slider.Value ~= OldValue then
 Library:SafeCallback(Slider.Callback, Slider.Value)
 Library:SafeCallback(Slider.Changed, Slider.Value)
 end

 RunService.RenderStepped:Wait()
 end

 for _, Side in pairs(Library.ActiveTab.Sides) do
 Side.ScrollingEnabled = true
 end
 end)

 if typeof(Slider.Tooltip) == "string" or typeof(Slider.DisabledTooltip) == "string" then
 Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Bar)
 Slider.TooltipTable.Disabled = Slider.Disabled
 end

 Slider:UpdateColors()
 Slider:Display()
 Groupbox:Resize()

 Slider.Holder = Holder
 table.insert(Groupbox.Elements, Slider)

 Options[Idx] = Slider

 return Slider
 end

 function Funcs:AddDropdown(Idx, Info)
 Info = Library:Validate(Info, Templates.Dropdown)

 local Groupbox = self
 local Container = Groupbox.Container

 if Info.SpecialType == "Player" then
 Info.Values = GetPlayers(Info.ExcludeLocalPlayer)
 Info.AllowNull = true
 elseif Info.SpecialType == "Team" then
 Info.Values = GetTeams()
 Info.AllowNull = true
 end
 local Dropdown = {
 Text = typeof(Info.Text) == "string" and Info.Text or nil,
 Value = Info.Multi and {} or nil,
 Values = Info.Values,
 DisabledValues = Info.DisabledValues,
 Multi = Info.Multi,

 SpecialType = Info.SpecialType,
 ExcludeLocalPlayer = Info.ExcludeLocalPlayer,

 Tooltip = Info.Tooltip,
 DisabledTooltip = Info.DisabledTooltip,
 TooltipTable = nil,

 Callback = Info.Callback,
 Changed = Info.Changed,

 Disabled = Info.Disabled,
 Visible = Info.Visible,

 Type = "Dropdown",
 }

 local Holder = New("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, Dropdown.Text and 39 or 21),
 Visible = Dropdown.Visible,
 Parent = Container,
 })

 local Label = New("TextLabel", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 14),
 Text = Dropdown.Text,
 TextSize = 14,
 TextXAlignment = Enum.TextXAlignment.Left,
 Visible = not not Info.Text,
 Parent = Holder,
 })

 local Display = New("TextButton", {
 Active = not Dropdown.Disabled,
 AnchorPoint = Vector2.new(0, 1),
 BackgroundColor3 = "MainColor",
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 Position = UDim2.fromScale(0, 1),
 Size = UDim2.new(1, 0, 0, 21),
 Text = "---",
 TextSize = 14,
 TextXAlignment = Enum.TextXAlignment.Left,
 Parent = Holder,
 })

 New("UIPadding", {
 PaddingLeft = UDim.new(0, 8),
 PaddingRight = UDim.new(0, 4),
 Parent = Display,
 })

 local ArrowImage = New("ImageLabel", {
 AnchorPoint = Vector2.new(1, 0.5),
 Image = ArrowIcon and ArrowIcon.Url or "",
 ImageColor3 = "FontColor",
 ImageRectOffset = ArrowIcon and ArrowIcon.ImageRectOffset or Vector2.zero,
 ImageRectSize = ArrowIcon and ArrowIcon.ImageRectSize or Vector2.zero,
 ImageTransparency = 0.5,
 Position = UDim2.fromScale(1, 0.5),
 Size = UDim2.fromOffset(16, 16),
 Parent = Display,
 })

 local SearchBox
 if Info.Searchable then
 SearchBox = New("TextBox", {
 BackgroundTransparency = 1,
 PlaceholderText = "Search...",
 Position = UDim2.fromOffset(-8, 0),
 Size = UDim2.new(1, -12, 1, 0),
 TextSize = 14,
 TextXAlignment = Enum.TextXAlignment.Left,
 Visible = false,
 Parent = Display,
 })
 New("UIPadding", {
 PaddingLeft = UDim.new(0, 8),
 Parent = SearchBox,
 })
 end

 local MenuTable = Library:AddContextMenu(
 Display,
 function()
 return UDim2.fromOffset(Display.AbsoluteSize.X, 0)
 end,
 function()
 return { 0.5, Display.AbsoluteSize.Y + 1.5 }
 end,
 2,
 function(Active: boolean)
 Display.TextTransparency = (Active and SearchBox) and 1 or 0
 ArrowImage.ImageTransparency = Active and 0 or 0.5
 ArrowImage.Rotation = Active and 180 or 0
 if SearchBox then
 SearchBox.Text = ""
 SearchBox.Visible = Active
 end
 end
 )
 Dropdown.Menu = MenuTable
 Library:UpdateDPI(MenuTable.Menu, {
 Position = false,
 Size = false,
 })

 function Dropdown:RecalculateListSize(Count)
 local Y = math.clamp(
 (Count or GetTableSize(Dropdown.Values)) * (21 * Library.DPIScale),
 0,
 Info.MaxVisibleDropdownItems * (21 * Library.DPIScale)
 )

 MenuTable:SetSize(function()
 return UDim2.fromOffset(Display.AbsoluteSize.X, Y)
 end)
 end

 function Dropdown:UpdateColors()
 if Library.Unloaded then
 return
 end

 Label.TextTransparency = Dropdown.Disabled and 0.8 or 0
 Display.TextTransparency = Dropdown.Disabled and 0.8 or 0
 ArrowImage.ImageTransparency = Dropdown.Disabled and 0.8 or MenuTable.Active and 0 or 0.5
 end

 function Dropdown:Display()
 if Library.Unloaded then
 return
 end

 local Str = ""

 if Info.Multi then
 for _, Value in pairs(Dropdown.Values) do
 if Dropdown.Value[Value] then
 Str = Str
 .. (Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(Value)) or tostring(Value))
 .. ", "
 end
 end

 Str = Str:sub(1, #Str - 2)
 else
 Str = Dropdown.Value and tostring(Dropdown.Value) or ""
 if Str ~= "" and Info.FormatDisplayValue then
 Str = tostring(Info.FormatDisplayValue(Str))
 end
 end

 if #Str > 25 then
 Str = Str:sub(1, 22) .. "..."
 end

 Display.Text = (Str == "" and "---" or Str)
 end

 function Dropdown:OnChanged(Func)
 Dropdown.Changed = Func
 end

 function Dropdown:GetActiveValues()
 if Info.Multi then
 local Table = {}

 for Value, _ in pairs(Dropdown.Value) do
 table.insert(Table, Value)
 end

 return Table
 end

 return Dropdown.Value and 1 or 0
 end

 local Buttons = {}
 function Dropdown:BuildDropdownList()
 local Values = Dropdown.Values
 local DisabledValues = Dropdown.DisabledValues

 for Button, _ in pairs(Buttons) do
 Button:Destroy()
 end
 table.clear(Buttons)

 local Count = 0
 for _, Value in pairs(Values) do
 if SearchBox and not tostring(Value):lower():match(SearchBox.Text:lower()) then
 continue
 end

 Count += 1
 local IsDisabled = table.find(DisabledValues, Value)
 local Table = {}

 local Button = New("TextButton", {
 BackgroundColor3 = "MainColor",
 BackgroundTransparency = 1,
 LayoutOrder = IsDisabled and 1 or 0,
 Size = UDim2.new(1, 0, 0, 21),
 Text = tostring(Value),
 TextSize = 14,
 TextTransparency = 0.5,
 TextXAlignment = Enum.TextXAlignment.Left,
 Parent = MenuTable.Menu,
 })
 New("UIPadding", {
 PaddingLeft = UDim.new(0, 7),
 PaddingRight = UDim.new(0, 7),
 Parent = Button,
 })

 local Selected
 if Info.Multi then
 Selected = Dropdown.Value[Value]
 else
 Selected = Dropdown.Value == Value
 end

 function Table:UpdateButton()
 if Info.Multi then
 Selected = Dropdown.Value[Value]
 else
 Selected = Dropdown.Value == Value
 end

 Button.BackgroundTransparency = Selected and 0 or 1
 Button.TextTransparency = IsDisabled and 0.8 or Selected and 0 or 0.5
 end

 if not IsDisabled then
 Button.MouseButton1Click:Connect(function()
 local Try = not Selected

 if not (Dropdown:GetActiveValues() == 1 and not Try and not Info.AllowNull) then
 Selected = Try
 if Info.Multi then
 Dropdown.Value[Value] = Selected and true or nil
 else
 Dropdown.Value = Selected and Value or nil
 end

 for _, OtherButton in pairs(Buttons) do
 OtherButton:UpdateButton()
 end
 end

 Table:UpdateButton()
 Dropdown:Display()

 Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
 Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
 Library:UpdateDependencyBoxes()
 end)
 end

 Table:UpdateButton()
 Dropdown:Display()

 Buttons[Button] = Table
 end

 Dropdown:RecalculateListSize(Count)
 end

 function Dropdown:SetValue(Value)
 if Info.Multi then
 local Table = {}

 for Val, Active in pairs(Value or {}) do
 if Active and table.find(Dropdown.Values, Val) then
 Table[Val] = true
 end
 end

 Dropdown.Value = Table
 else
 if table.find(Dropdown.Values, Value) then
 Dropdown.Value = Value
 elseif not Value then
 Dropdown.Value = nil
 end
 end

 Dropdown:Display()
 for _, Button in pairs(Buttons) do
 Button:UpdateButton()
 end

 if not Dropdown.Disabled then
 Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
 Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
 end
 end

 function Dropdown:SetDisabled(Disabled: boolean)
 Dropdown.Disabled = Disabled

 if Dropdown.TooltipTable then
 Dropdown.TooltipTable.Disabled = Dropdown.Disabled
 end

 Display.Active = not Dropdown.Disabled
 Dropdown:UpdateColors()
 end

 function Dropdown:SetVisible(Visible: boolean)
 Dropdown.Visible = Visible

 Holder.Visible = Dropdown.Visible
 Groupbox:Resize()
 end

 function Dropdown:SetText(Text: string)
 if not Info.Text then
 return
 end

 Dropdown.Text = Text
 Label.Text = Text

 Dropdown:RecalculateListSize()
 end

 function Dropdown:BuildFromValues(Values)
 Dropdown.Values = Values

 Dropdown:BuildDropdownList()
 end

 Display.MouseButton1Click:Connect(MenuTable.Toggle)

 if typeof(Dropdown.Tooltip) == "string" or typeof(Dropdown.DisabledTooltip) == "string" then
 Dropdown.TooltipTable = Library:AddTooltip(Dropdown.Tooltip, Dropdown.DisabledTooltip, Display)
 Dropdown.TooltipTable.Disabled = Dropdown.Disabled
 end

 Dropdown:BuildDropdownList()
 Groupbox:Resize()

 Dropdown.Holder = Holder
 table.insert(Groupbox.Elements, Dropdown)

 Options[Idx] = Dropdown

 return Dropdown
 end

 BaseGroupbox.__index = Funcs
end

function Library:CreateWindow(Settings)
 Settings = Library:Validate(Settings, Templates.Window)

 Library.ToggleKeybind = Settings.ToggleKeybind
 Library.NotifySide = Settings.NotifySide
 Library.ShowCustomCursor = Settings.ShowCustomCursor
 Library.ForceCheckbox = Settings.ForceCheckbox

 local AutoShow = Settings.AutoShow

 local Window = {
 Tabs = {},
 DependencyGroupboxes = {},
 }

 local Outer = New("Frame", {
 BackgroundColor3 = "BackgroundColor",
 BackgroundTransparency = 0.05,
 Position = Settings.Position,
 Size = Settings.Size,
 Parent = ScreenGui,
 })
 Library:UpdateDPI(Outer, {
 Position = Settings.Center and false or true,
 Size = true,
 })

 local Main = New("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.fromScale(1, 1),
 Parent = Outer,
 })
 New("UICorner", {
 CornerRadius = UDim.new(0, Settings.CornerRadius),
 Parent = Main,
 })
 local Outline = New("UIStroke", {
 ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
 Color = "OutlineColor",
 Transparency = 0.9,
 Parent = Main,
 })

 local Divider = New("Frame", {
 BackgroundColor3 = "OutlineColor",
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 Size = UDim2.new(1, 0, 0, 1),
 Parent = Main,
 })

 local TitleBar = New("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 38),
 Parent = Main,
 })

 local Icon = New("ImageLabel", {
 Size = Settings.IconSize,
 Position = UDim2.fromOffset(12, 0),
 AnchorPoint = Vector2.new(0, 0.5),
 Parent = TitleBar,
 }, {
 DPIExclude = {
 Position = true,
 }
 })

 local Title = New("TextLabel", {
 BackgroundTransparency = 1,
 Position = Icon.Image and UDim2.fromOffset(42, 0) or UDim2.fromOffset(14, 0),
 Size = UDim2.new(1, Icon.Image and -54 or -94, 1, 0),
 Text = Settings.Title,
 TextSize = 16,
 TextXAlignment = Enum.TextXAlignment.Left,
 Parent = TitleBar,
 })

 local SubTitle = New("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(14, 0),
 Size = UDim2.new(1, -54, 1, 0),
 Text = Settings.Footer,
 TextSize = 12,
 TextTransparency = 0.5,
 TextXAlignment = Enum.TextXAlignment.Left,
 Parent = TitleBar,
 })

 local Resize = New("ImageButton", {
 AnchorPoint = Vector2.new(1, 1),
 BackgroundTransparency = 1,
 Image = ResizeIcon and ResizeIcon.Url or "",
 ImageTransparency = 0.5,
 Position = UDim2.fromScale(1, 1),
 Size = UDim2.fromOffset(20, 20),
 Rotation = 90,
 Parent = Main,
 })
 local ResizePadding = New("UIPadding", {
 PaddingTop = UDim.new(0, 6),
 PaddingLeft = UDim.new(0, 6),
 Parent = Resize,
 })

 local KeybindButton = New("TextButton", {
 AnchorPoint = Vector2.new(1, 0),
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(Settings.Resizable and -24 or -14, 0),
 Size = UDim2.fromOffset(20, 20),
 Image = KeyIcon and KeyIcon.Url or "",
 ImageColor3 = "FontColor",
 ImageRectOffset = KeyIcon and KeyIcon.ImageRectOffset or Vector2.zero,
 ImageRectSize = KeyIcon and KeyIcon.ImageRectSize or Vector2.zero,
 ImageTransparency = 0.5,
 Parent = TitleBar,
 })

 local SearchBar = New("TextBox", {
 BackgroundColor3 = "MainColor",
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 Position = UDim2.fromOffset(12, 0),
 Size = Settings.SearchbarSize,
 Text = "",
 TextSize = 14,
 Visible = false,
 Parent = TitleBar,
 })
 New("UIPadding", {
 PaddingLeft = UDim.new(0, 8),
 PaddingRight = UDim.new(0, 8),
 Parent = SearchBar,
 })

 local InnerMain = New("Frame", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(0, 39),
 Size = UDim2.new(1, 0, 1, -39),
 Parent = Main,
 })

 local TabArea = New("Frame", {
 BackgroundTransparency = 1,
 Visible = false,
 Size = UDim2.new(1, 0, 0, 28),
 Parent = InnerMain,
 })
 local TabListLayout = New("UIListLayout", {
 FillDirection = Enum.FillDirection.Horizontal,
 Parent = TabArea,
 })

 local TabContainer = New("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 1, Settings.Resizable and -8 or 0),
 Parent = InnerMain,
 })

 Library.KeybindFrame = New("Frame", {
 BackgroundColor3 = "BackgroundColor",
 BackgroundTransparency = 0.98,
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 Position = UDim2.new(1, 4, 0, 0),
 Size = UDim2.fromOffset(0, 0),
 Visible = false,
 ZIndex = 4,
 Parent = InnerMain,
 })
 New("UICorner", {
 CornerRadius = UDim.new(0, Library.CornerRadius - 1),
 Parent = Library.KeybindFrame,
 })
 New("UIStroke", {
 Color = "OutlineColor",
 Transparency = 0.9,
 Parent = Library.KeybindFrame,
 })
 Library.KeybindContainer = New("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.fromScale(1, 1),
 Parent = Library.KeybindFrame,
 })
 New("UIListLayout", {
 Padding = UDim.new(0, 0),
 Parent = Library.KeybindContainer,
 })
 New("UIPadding", {
 PaddingBottom = UDim.new(0, 6),
 PaddingLeft = UDim.new(0, 6),
 PaddingRight = UDim.new(0, 6),
 PaddingTop = UDim.new(0, 6),
 Parent = Library.KeybindContainer,
 })

 local LeftSide, RightSide
 local SidebarToggle

 if Settings.MobileButtonsSide == "Top" then
 local ButtonContainer = New("Frame", {
 BackgroundTransparency = 1,
 Visible = false,
 Size = UDim2.new(1, 0, 0, 30),
 Parent = TabContainer,
 })
 New("UIListLayout", {
 FillDirection = Enum.FillDirection.Horizontal,
 Padding = UDim.new(0, 5),
 Parent = ButtonContainer,
 })

 SidebarToggle = ButtonContainer
 else
 local ButtonSide = New("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.fromOffset(30, 170),
 Parent = TabContainer,
 })
 New("UIListLayout", {
 Padding = UDim.new(0, 5),
 SortOrder = Enum.SortOrder.LayoutOrder,
 Parent = ButtonSide,
 })

 SidebarToggle = ButtonSide
 end

 local LeftSideButton = New("TextButton", {
 BackgroundColor3 = "MainColor",
 BackgroundTransparency = 0.95,
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 Size = UDim2.fromOffset(30, 30),
 Text = "<",
 TextSize = 18,
 Parent = SidebarToggle,
 })
 New("UICorner", {
 CornerRadius = UDim.new(0, Library.CornerRadius - 1),
 Parent = LeftSideButton,
 })

 local RightSideButton = New("TextButton", {
 BackgroundColor3 = "MainColor",
 BackgroundTransparency = 0.95,
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 Size = UDim2.fromOffset(30, 30),
 Text = ">",
 TextSize = 18,
 LayoutOrder = 1,
 Parent = SidebarToggle,
 })
 New("UICorner", {
 CornerRadius = UDim.new(0, Library.CornerRadius - 1),
 Parent = RightSideButton,
 })

 TabContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
 local Size = TabContainer.AbsoluteSize
 local IsMobileUI = (Library.IsMobile and Size.Y <= 240 or Size.X <= 480)

 if Settings.MobileButtonsSide == "Top" then
 SidebarToggle.Visible = IsMobileUI
 else
 LeftSideButton.Visible = IsMobileUI
 RightSideButton.Visible = IsMobileUI
 end
 end)

 local LeftSideContainer = New("ScrollingFrame", {
 AutomaticCanvasSize = Enum.AutomaticSize.Y,
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 BottomImage = "",
 Position = UDim2.fromOffset(0, 0),
 ScrollBarImageTransparency = 1,
 ScrollBarThickness = 0,
 Size = UDim2.new(0.5, -2, 1, Settings.MobileButtonsSide == "Top" and -35 or 0),
 TopImage = "",
 Visible = false,
 Parent = TabContainer,
 })

 local RightSideContainer = New("ScrollingFrame", {
 AutomaticCanvasSize = Enum.AutomaticSize.Y,
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 BottomImage = "",
 Position = UDim2.fromScale(0.5, 0),
 ScrollBarImageTransparency = 1,
 ScrollBarThickness = 0,
 Size = UDim2.new(0.5, -2, 1, Settings.MobileButtonsSide == "Top" and -35 or 0),
 TopImage = "",
 Visible = false,
 Parent = TabContainer,
 })

 New("UIListLayout", {
 Padding = UDim.new(0, 5),
 Parent = LeftSideContainer,
 })

 New("UIListLayout", {
 Padding = UDim.new(0, 5),
 Parent = RightSideContainer,
 })

 LeftSide = LeftSideContainer
 RightSide = RightSideContainer

 function Window:InitializeTabMenu(Tab)
 Tab.Container = New("Frame", {
 BackgroundTransparency = 1,
 Parent = TabContainer,
 })

 Tab.Side = "Left"
 Tab.Groupboxes = {}
 Tab.Tabboxes = {}
 Tab.DependencyGroupboxes = {}
 Tab.Sides = {
 Tab:CreateSide("Left", LeftSideContainer),
 Tab:CreateSide("Right", RightSideContainer),
 }

 Tab:Show(0)

 local TabButton = New("TextButton", {
 BackgroundColor3 = "MainColor",
 BackgroundTransparency = 1,
 Size = UDim2.new(0, 70, 1, 0),
 Text = Tab.Name,
 TextSize = 14,
 TextTransparency = 0.5,
 Parent = TabArea,
 })

 local function Resize()
 for _, Side in pairs(Tab.Sides) do
 Side:Resize()
 end
 end

 function Tab:Show(TweenTime)
 if Library.ActiveTab == Tab then
 return
 end

 if Library.ActiveTab then
 Library.ActiveTab:Hide()
 end

 Library.ActiveTab = Tab
 if not Library.Searching then
 Library.LastSearchTab = Tab
 end

 for _, ActiveTab in pairs(Library.Tabs) do
 if ActiveTab.IsKeyTab then
 continue
 end

 ActiveTab:Display()
 end

 Tab.Container.Visible = true
 TabButton.BackgroundTransparency = 0
 TabButton.TextTransparency = 0

 if TweenTime and TweenTime > 0 then
 for _, Side in pairs(Tab.Sides) do
 Side.ScrollingEnabled = false
 end

 TweenService:Create(TabButton, TweenInfo.new(TweenTime, Enum.EasingStyle.Quad), {
 BackgroundTransparency = 0,
 }):Play()

 task.wait(TweenTime)

 for _, Side in pairs(Tab.Sides) do
 Side.ScrollingEnabled = true
 end
 else
 TabButton.BackgroundTransparency = 0
 TabButton.TextTransparency = 0
 end

 TabButton.ZIndex = 2

 Tab:Resize()
 end

 function Tab:Hide()
 Tab.Container.Visible = false
 TabButton.BackgroundTransparency = 1
 TabButton.TextTransparency = 0.5
 TabButton.ZIndex = 1
 end

 function Tab:Display()
 if Tab.Disabled then
 TabButton.TextTransparency = 0.8
 else
 TabButton.TextTransparency = (Tab ~= Library.ActiveTab) and 0.5 or 0
 end
 TabButton.BackgroundTransparency = (Tab ~= Library.ActiveTab) and 1 or 0
 end

 function Tab:Resize()
 local TabAreaSize = TabArea.AbsoluteSize

 if TabAreaSize.X > 0 then
 local LeftSize = LeftSideContainer.UIListLayout.AbsoluteContentSize
 local RightSize = RightSideContainer.UIListLayout.AbsoluteContentSize

 LeftSideContainer.CanvasSize = UDim2.fromOffset(LeftSize.X, LeftSize.Y)
 RightSideContainer.CanvasSize = UDim2.fromOffset(RightSize.X, RightSize.Y)
 end

 if Library.Searching then
 Library:UpdateSearch(Library.SearchText)
 end
 end

 function Tab:SetSide(SideName)
 if Tab.Side == SideName then
 return
 end

 Tab.Side = SideName

 if Tab.Container then
 Tab.Container.Parent =
 (SideName == "Left" and LeftSideContainer) or (SideName == "Right" and RightSideContainer)
 end

 if Tab.IsKeyTab then
 Tab.Container.Parent = TabContainer
 end

 Tab:Resize()
 end

 function Tab:CreateSide(Name, SideHolder)
 local Side = {
 Name = Name,
 }

 function Side:Resize()
 Tab:Resize()
 end

 Side.ScrollingEnabled = true

 local GroupboxHolder = New("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.fromScale(1, 0),
 Parent = SideHolder,
 })

 New("UIListLayout", {
 Padding = UDim.new(0, 5),
 Parent = GroupboxHolder,
 })

 New("UIPadding", {
 PaddingBottom = UDim.new(0, 0),
 PaddingLeft = UDim.new(0, 0),
 PaddingRight = UDim.new(0, 0),
 PaddingTop = UDim.new(0, 5),
 Parent = GroupboxHolder,
 })

 function Side:AddGroupbox(Idx, Info)
 Info = Library:Validate(Info, {
 Text = "No Groupbox",
 Side = 1,
 })

 local Groupbox = {
 Text = Info.Text,
 Side = Info.Side,

 DependencyBoxes = {},
 Elements = {},
 }

 local GroupboxHolder = New("Frame", {
 BackgroundTransparency = 1,
 Parent = GroupboxHolder,
 })

 local Background = New("Frame", {
 BackgroundColor3 = "BackgroundColor",
 BackgroundTransparency = 0.98,
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 Parent = GroupboxHolder,
 })
 New("UICorner", {
 CornerRadius = UDim.new(0, Library.CornerRadius - 1),
 Parent = Background,
 })

 local Container = New("Frame", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(0, 20),
 Size = UDim2.new(1, 0, 1, -20),
 Parent = Background,
 })
 New("UIListLayout", {
 Parent = Container,
 })
 New("UIPadding", {
 PaddingBottom = UDim.new(0, 1),
 PaddingLeft = UDim.new(0, 6),
 PaddingRight = UDim.new(0, 6),
 PaddingTop = UDim.new(0, 1),
 Parent = Container,
 })

 local Header = New("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(0, 2),
 Size = UDim2.new(1, 0, 0, 18),
 Text = Groupbox.Text,
 TextSize = 15,
 TextTransparency = 0.1,
 Parent = Background,
 })
 New("UIPadding", {
 PaddingLeft = UDim.new(0, 8),
 PaddingRight = UDim.new(0, 8),
 Parent = Header,
 })

 function Groupbox:Resize()
 local Size = Container.UIListLayout.AbsoluteContentSize

 Background.Size = UDim2.new(1, 0, 0, Size.Y + 20)
 end

 Groupbox.Container = Container
 Groupbox.Holder = GroupboxHolder
 Groupbox.Label = Header
 Groupbox.Background = Background

 setmetatable(Groupbox, BaseGroupbox)

 Tab.Groupboxes[Idx] = Groupbox
 table.insert(Tab.DependencyGroupboxes, Groupbox)

 return Groupbox
 end

 Side.GroupboxHolder = GroupboxHolder

 return Side
 end

 TabButton.InputBegan:Connect(function(Input: InputObject)
 if not IsClickInput(Input) then
 return
 end

 Tab:Show()
 end)

 Tab:Display()

 Tab:SetSide("Left")
 Tab:Resize()

 Tab.Button = TabButton

 table.insert(Library.Tabs, Tab)

 return Tab
 end

 function Window:AddTab(Idx, Info)
 local Tab = {
 Name = Info.Text,
 Disabled = Info.Disabled or false,
 IsKeyTab = false,
 }

 return Window:InitializeTabMenu(Tab)
 end

 function Window:AddKeybinds()
 local Tab = {
 Name = "Keybinds",
 Disabled = false,
 IsKeyTab = true,
 }

 return Window:InitializeTabMenu(Tab)
 end

 function Window:SetWindowTitle(Title)
 Settings.Title = Title
 Title.Text = Title
 end

 function Window:SetWindowIcon(Icon)
 if not Icon then
 Icon.Size = UDim2.fromOffset(0, 0)
 else
 Icon.Size = Settings.IconSize
 Icon.Image = Icon
 Icon.ImageRectOffset = Vector2.zero
 Icon.ImageRectSize = Vector2.zero
 end
 end

 function Window:SelectTab(Tab)
 Tab:Show()
 end

 function Window:Show(TweenTime)
 if not Library.Toggled and Library.Unloaded then
 Library.Toggled = true
 end

 Library.Toggled = true
 Outer.Visible = true
 TweenService:Create(Outer, Library.TweenInfo, {
 BackgroundTransparency = 0.05,
 }):Play()

 TweenService:Create(Outline, Library.TweenInfo, {
 Transparency = 0.9,
 }):Play()
 task.wait(Library.TweenInfo.Time)
 Library:UpdateDependencyBoxes()
 end

 function Window:Hide(TweenTime)
 Library.Toggled = false
 TweenService:Create(Outer, Library.TweenInfo, {
 BackgroundTransparency = 1,
 }):Play()

 TweenService:Create(Outline, Library.TweenInfo, {
 Transparency = 1,
 }):Play()
 task.wait(Library.TweenInfo.Time)
 Outer.Visible = false
 end

 function Window:SetWindowPosition(Position)
 Outer.Position = Position
 end

 function Window:SetWindowSize(Size)
 Outer.Size = Size
 end

 function Window:Unload()
 Library:Unload()
 end

 local SidebarContainer = New("Frame", {
 AnchorPoint = Vector2.new(1, 0),
 BackgroundTransparency = 1,
 Size = UDim2.fromScale(1, 1),
 Parent = TabContainer,
 })

 local SidebarContainerListLayout = New("UIListLayout", {
 SortOrder = Enum.SortOrder.LayoutOrder,
 Parent = SidebarContainer,
 })

 local SidebarHolder = New("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.fromScale(1, 1),
 Parent = SidebarContainer,
 })

 local Sidebar = New("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.fromScale(1, 1),
 Parent = SidebarHolder,
 })
 New("UIListLayout", {
 Padding = UDim.new(0, 5),
 Parent = Sidebar,
 })

 local SidebarDivider = New("Frame", {
 BackgroundColor3 = "OutlineColor",
 BorderSizePixel = 0,
 Size = UDim2.new(0, 1, 1, 0),
 Parent = SidebarHolder,
 })

 local SidebarSearch = New("TextBox", {
 BackgroundColor3 = "MainColor",
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 Position = UDim2.fromOffset(8, 0),
 Size = UDim2.new(1, -16, 0, 24),
 Text = "",
 TextSize = 14,
 Visible = false,
 Parent = Sidebar,
 })
 New("UIPadding", {
 PaddingLeft = UDim.new(0, 8),
 PaddingRight = UDim.new(0, 8),
 Parent = SidebarSearch,
 })

 local SidebarButton = New("TextButton", {
 BackgroundColor3 = "MainColor",
 BackgroundTransparency = 0.95,
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 Size = UDim2.new(1, -2, 0, 34),
 Text = "Menu",
 TextSize = 16,
 Parent = Sidebar,
 })
 New("UICorner", {
 CornerRadius = UDim.new(0, Library.CornerRadius - 1),
 Parent = SidebarButton,
 })

 function Window:SetSidebarVisibility(Visible)
 SidebarContainer.Visible = Visible
 end

 function Window:SetSidebarWidth(Width)
 SidebarHolder.Size = UDim2.fromOffset(Width, SidebarHolder.AbsoluteSize.Y)
 end

 if Settings.Center and not Library.IsMobile then
 Outer.Position = UDim2.fromOffset(
 (workspace.CurrentCamera.ViewportSize.X - 720) / 2,
 (workspace.CurrentCamera.ViewportSize.Y - 600) / 2
 )
 end

 Library:MakeDraggable(Outer, TitleBar)

 if Settings.Resizable then
 Library:MakeResizable(Outer, Resize, function()
 for _, Tab in pairs(Library.Tabs) do
 Tab:Resize()
 end
 end)
 end

 local SearchDebounce
 SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
 if SearchDebounce then
 SearchDebounce:Disconnect()
 SearchDebounce = nil
 end

 SearchDebounce = task.delay(0.2, function()
 Library:UpdateSearch(SearchBar.Text)
 end)
 end)

 KeybindButton.MouseButton1Click:Connect(function()
 Library.KeybindFrame.Visible = not Library.KeybindFrame.Visible
 Library:UpdateKeybindFrame()
 end)

 function SearchBar:Focus()
 SearchBar:CaptureFocus()
 end

 function Window:SetSearchbarVisibility(Visible)
 SearchBar.Visible = Visible
 end

 function Window:SetSidebarSearchVisibility(Visible)
 SidebarSearch.Visible = Visible
 end

 local Sidebar = {
 Visible = false,
 }

 function Sidebar:Show()
 Sidebar.Visible = true
 LeftSideContainer.Visible = false
 RightSideContainer.Visible = false
 TabArea.Visible = false
 TabContainer.Visible = false
 SidebarContainer.Visible = true
 end

 function Sidebar:Hide()
 Sidebar.Visible = false
 LeftSideContainer.Visible = true
 RightSideContainer.Visible = true
 TabArea.Visible = true
 TabContainer.Visible = true
 SidebarContainer.Visible = false
 end

 SidebarButton.MouseButton1Click:Connect(function()
 if Sidebar.Visible then
 Sidebar:Hide()
 else
 Sidebar:Show()
 end
 end)

 function Library:AddToRegistry(Instance, Properties)
 Library.Registry[Instance] = Properties
 end

 function Library:UpdateDependencyBoxes()
 for _, Depbox in pairs(Library.DependencyBoxes) do
 Depbox:Update(true)
 end

 if Library.Searching then
 Library:UpdateSearch(Library.SearchText)
 end
 end

 function Library:UpdateSearch(SearchText)
 Library.SearchText = SearchText

 if Library.LastSearchTab then
 for _, Groupbox in pairs(Library.LastSearchTab.Groupboxes) do
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

 for _, Tabbox in pairs(Library.LastSearchTab.Tabboxes) do
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

 for _, DepGroupbox in pairs(Library.LastSearchTab.DependencyGroupboxes) do
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
 if Trim(Search) == "" or Library.ActiveTab.IsKeyTab then
 Library.Searching = false
 Library.LastSearchTab = nil
 return
 end

 Library.Searching = true

 for _, Groupbox in pairs(Library.ActiveTab.Groupboxes) do
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

 for _, Tabbox in pairs(Library.ActiveTab.Tabboxes) do
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

 for _, DepGroupbox in pairs(Library.ActiveTab.DependencyGroupboxes) do
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

 Library.LastSearchTab = Library.ActiveTab
 end

 function Library:UpdateKeybindFrame()
 if not Library.KeybindFrame then
 return
 end

 local XSize = 0
 for _, KeybindToggle in pairs(Library.KeybindToggles) do
 if not KeybindToggle.Holder.Visible then
 continue
 end

 local FullSize = KeybindToggle.Label.Size.X.Offset + KeybindToggle.Label.Position.X.Offset
 if FullSize > XSize then
 XSize = FullSize
 end
 end

 Library.KeybindFrame.Size = UDim2.fromOffset(XSize + 18 * Library.DPIScale, 0)
 end

 local LastMousePosition = Vector2.zero
 Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
 if Input.UserInputType == Enum.UserInputType.MouseMovement then
 LastMousePosition = Input.Position
 end
 end))

 Library:GiveSignal(RunService.RenderStepped:Connect(function()
 if not Library.ShowCustomCursor then
 Cursor.Visible = false
 return
 end

 if not (Library.Toggled and ScreenGui and ScreenGui.Parent) then
 Cursor.Visible = false
 return
 end

 Cursor.Visible = true
 Cursor.Position = UDim2.fromOffset(LastMousePosition.X, LastMousePosition.Y)
 end))

 Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
 if Input.KeyCode == Library.ToggleKeybind then
 Library.Toggled = not Library.Toggled

 if Library.Toggled then
 Window:Show()
 else
 Window:Hide()
 end
 end
 end))

 if Settings.Center and Library.IsMobile then
 Library.CantDragForced = true
 else
 Library:MakeDraggable(Outer, TitleBar, false, true)
 end

 Outer:GetPropertyChangedSignal("Position"):Connect(function()
 local Position = Outer.Position

 if Position.X.Offset < 0 then
 Outer.Position = UDim2.fromOffset(6, Position.Y.Offset)
 elseif Position.Y.Offset < 0 then
 Outer.Position = UDim2.fromOffset(Position.X.Offset, 6)
 end
 end)

 if AutoShow then
 Window:Show()
 end

 getgenv().Library = Library

 return Window
end

function Library:SaveConfig()
 writefile("Obsidian/config.json", HttpService:JSONEncode(Library:GetConfig()))
end

function Library:LoadConfig()
 local Path = "Obsidian/config.json"
 if not isfile or not isfile(Path) then
 return
 end

 local Data = HttpService:JSONDecode(readfile(Path))
 Library:SetConfig(Data)
end

function Library:GetConfig()
 local Data = {}

 for Idx, Option in pairs(Options) do
 if Option.IgnoreConfig then
 continue
 end

 if Option.Type == "Toggle" then
 Data[Idx] = Option.Value
 elseif Option.Type == "Slider" then
 Data[Idx] = Option.Value
 elseif Option.Type == "Dropdown" then
 if Option.Multi then
 local Values = {}

 for Value, Active in pairs(Option.Value) do
 if Active then
 table.insert(Values, Value)
 end
 end

 Data[Idx] = Values
 else
 Data[Idx] = Option.Value
 end
 elseif Option.Type == "Input" then
 Data[Idx] = Option.Value
 elseif Option.Type == "KeyPicker" then
 Data[Idx] = { Option.Value, Option.Mode }
 elseif Option.Type == "ColorPicker" then
 Data[Idx] = { Option.Value, Option.Transparency }
 end
 end

 return Data
end

function Library:SetConfig(Data)
 for Idx, Value in pairs(Data) do
 local Option = Options[Idx]
 if not Option then
 continue
 end

 Option:SetValue(Value)
 end
end

function Library:Notify(Text, Time)
 local Notification = {}

 local NotificationBackground = New("Frame", {
 AnchorPoint = Vector2.new(1, 0),
 BackgroundColor3 = "BackgroundColor",
 BackgroundTransparency = 0.98,
 BorderColor3 = "OutlineColor",
 BorderSizePixel = 1,
 Size = UDim2.fromOffset(300, 0),
 Parent = NotificationArea,
 })
 New("UICorner", {
 CornerRadius = UDim.new(0, Library.CornerRadius - 1),
 Parent = NotificationBackground,
 })
 New("UIStroke", {
 Color = "OutlineColor",
 Transparency = 0.9,
 Parent = NotificationBackground,
 })

 local NotificationContainer = New("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.fromScale(1, 1),
 Parent = NotificationBackground,
 })
 New("UIPadding", {
 PaddingBottom = UDim.new(0, 10),
 PaddingLeft = UDim.new(0, 10),
 PaddingRight = UDim.new(0, 10),
 PaddingTop = UDim.new(0, 10),
 Parent = NotificationContainer,
 })

 local NotificationLabel = New("TextLabel", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 18),
 Text = Text,
 TextSize = 15,
 TextWrapped = true,
 Parent = NotificationContainer,
 })

 function Notification:Resize()
 local X, Y = Library:GetTextBounds(NotificationLabel.Text, NotificationLabel.FontFace, 15, 280)
 NotificationLabel.Size = UDim2.new(1, 0, 0, Y)
 NotificationBackground.Size = UDim2.fromOffset(300, Y + 20)
 end

 Notification:Resize()

 table.insert(Library.Notifications, Notification)

 NotificationBackground.Position = UDim2.new(1, 320, 0, 0)

 local TweenIn = TweenService:Create(NotificationBackground, Library.NotifyTweenInfo, {
 Position = UDim2.new(1, -6, 0, 6) + UDim2.fromOffset(0, (NotificationBackground.AbsoluteSize.Y + 6) * (#Library.Notifications - 1)),
 })

 TweenIn:Play()

 local LeftAmount = Time or 5

 TweenIn.Completed:Connect(function()
 local TweenOut

 local Connection
 Connection = task.spawn(function()
 while LeftAmount > 0 and not Library.Unloaded do
 local Delta = task.wait(0.1)
 LeftAmount -= Delta
 end

 if not Library.Unloaded then
 TweenOut = TweenService:Create(NotificationBackground, Library.NotifyTweenInfo, {
 Position = UDim2.new(1, 320, 0, 6),
 })

 TweenOut:Play()
 TweenOut.Completed:Connect(function()
 NotificationBackground:Destroy()
 for Index, OtherNotification in pairs(Library.Notifications) do
 if OtherNotification == Notification then
 table.remove(Library.Notifications, Index)
 break
 end
 end

 for Index, OtherNotification in pairs(Library.Notifications) do
 TweenService:Create(OtherNotification.Background, Library.NotifyTweenInfo, {
 Position = UDim2.new(1, -6, 0, 6) + UDim2.fromOffset(0, (OtherNotification.Background.AbsoluteSize.Y + 6) * (Index - 1)),
 }):Play()
 end
 end)
 end
 end)

 function Notification:Hide()
 if TweenOut then
 return
 end

 if Connection then
 task.cancel(Connection)
 end

 LeftAmount = 0
 end

 Notification.Background = NotificationBackground
 Notification.Container = NotificationContainer
 Notification.Label = NotificationLabel

 return Notification
end

return Library