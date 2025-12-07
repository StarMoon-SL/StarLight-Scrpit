--!nocheck
--!nolint UnknownGlobal
--[[

		 ▄▄▄▄███▄▄▄▄      ▄████████         ▄████████    ▄████████    ▄███████▄
		▄██▀▀▀███▀▀▀██▄   ███    ███        ███    ███   ███    ███   ███    ███
		███   ███   ███   ███    █▀         ███    █▀    ███    █▀    ███    ███
		███   ███   ███   ███              ▄███▄▄▄       ███          ███    ███
		███   ███   ███ ▀███████████      ▀▀███▀▀▀     ▀███████████ ▀█████████▀
		███   ███   ███          ███        ███    █▄           ███   ███
		███   ███   ███    ▄█    ███        ███    ███    ▄█    ███   ███
		▀█   ███   █▀   ▄████████▀         ██████████  ▄████████▀   ▄████▀
									v2.0 (StarLight Extended)

						 Based on mstudio45's ESP v2.0.3
						 Extended by StarMoon
--]]

--// Executor Variables \\--
local cloneref = getgenv().cloneref or function(inst) return inst; end
local getui;

--// Services \\--
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Debris = cloneref(game:GetService("Debris"))

-- // Variables // --
local tablefreeze = function(provided_table)
	local proxy = {}
	local data = table.clone(provided_table)

	local mt = {
		__index = function(_, key)
			return data[key]
		end,

		__newindex = function(_, key, value)
			-- nope --
		end
	}

	return setmetatable(proxy, mt)
end

local V2 = Vector2.new
local V3 = Vector3.new

--// Functions \\--
local function GetPivot(Instance)
	if Instance.ClassName == "Bone" then
		return Instance.TransformedWorldCFrame
	elseif Instance.ClassName == "Attachment" then
		return Instance.WorldCFrame
	elseif Instance.ClassName == "Camera" then
		return Instance.CFrame
	else
		return Instance:GetPivot()
	end
end

local function RandomString(length)
	length = tonumber(length) or math.random(10, 20)

	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end

	return table.concat(array)
end

function SafeCallback(Func, ...)
    if not (Func and typeof(Func) == "function") then
        return
    end

    local Result = table.pack(xpcall(Func, function(Error)
        task.defer(error, debug.traceback(Error, 2))
        return Error
    end, ...))

    if not Result[1] then
        return nil
    end

    return table.unpack(Result, 2, Result.n)
end

local function GetModelBoundingBox(Model)
    if not Model or not Model:IsA("Model") then return nil end
    
    local min, max = nil, nil
    
    for _, part in ipairs(Model:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            local position = part.Position
            local size = part.Size
            
            local cornerMin = position - size / 2
            local cornerMax = position + size / 2
            
            if not min then
                min, max = cornerMin, cornerMax
            else
                min = V3(math.min(min.X, cornerMin.X), math.min(min.Y, cornerMin.Y), math.min(min.Z, cornerMin.Z))
                max = V3(math.max(max.X, cornerMax.X), math.max(max.Y, cornerMax.Y), math.max(max.Z, cornerMax.Z))
            end
        end
    end
    
    if not min then return nil end
    
    return {
        Min = min,
        Max = max,
        Center = (min + max) / 2
    }
end

-- // Instances // --
local InstancesLib = {
	Create = function(instanceType, properties)
		assert(typeof(instanceType) == "string", "Argument #1 must be a string.")
		assert(typeof(properties) == "table", "Argument #2 must be a table.")

		local instance = Instance.new(instanceType)
		for name, val in pairs(properties) do
			if name == "Parent" then
				continue -- Parenting is expensive, do last.
			end

			instance[name] = val
		end

		if properties["Parent"] ~= nil then
			instance["Parent"] = properties["Parent"]
		end

		return instance
	end,

	TryGetProperty = function(instance, propertyName)
		assert(typeof(instance) == "Instance", "Argument #1 must be an Instance.")
		assert(typeof(propertyName) == "string", "Argument #2 must be a string.")

		local success, property = pcall(function()
			return instance[propertyName]
		end)

		return if success then property else nil;
	end,

	FindPrimaryPart = function(instance)
		if typeof(instance) ~= "Instance" then
			return nil
		end

		return (instance:IsA("Model") and instance.PrimaryPart or nil)
			or instance:FindFirstChildWhichIsA("BasePart")
			or instance:FindFirstChildWhichIsA("UnionOperation")
			or instance;
	end,

	DistanceFrom = function(inst, from)
		if not (inst and from) then
			return 9e9;
		end

		local position = if typeof(inst) == "Instance" then GetPivot(inst).Position else inst;
		local fromPosition = if typeof(from) == "Instance" then GetPivot(from).Position else from;

		return (fromPosition - position).Magnitude;
	end
}

--// HiddenUI test \\--
do
	local testGui = Instance.new("ScreenGui")
	local successful = pcall(function()
		testGui.Parent = CoreGui;
	end)

	if not successful then
		getui = function() return Players.LocalPlayer.PlayerGui; end;
	else
		getui = function() return CoreGui end;
	end

	testGui:Destroy()
end

--// GUI \\--
local ActiveFolder = InstancesLib.Create("Folder", {
	Parent = getui(),
	Name = RandomString()
})

local StorageFolder = InstancesLib.Create("Folder", {
	Parent = if typeof(game) == "userdata" then Players.Parent else game,
	Name = RandomString()
})

local MainGUI = InstancesLib.Create("ScreenGui", {
	Parent = getui(),
	Name = RandomString(),
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ClipToDeviceSafeArea = false,
	DisplayOrder = 999999
})

local BillboardGUI = InstancesLib.Create("ScreenGui", {
	Parent = getui(),
	Name = RandomString(),
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ClipToDeviceSafeArea = false,
	DisplayOrder = 999999
})

-- // Library // --
local Library = {
	Destroyed = false,

	-- // Storages // --
	ActiveFolder = ActiveFolder,
	StorageFolder = StorageFolder,
	MainGUI = MainGUI,
	BillboardGUI = BillboardGUI,

	-- // Connections // --
	Connections = {},

	-- // ESP // --
	ESP = {},

	-- // Global Config (Extended) // --
	GlobalConfig = {
		IgnoreCharacter = false,
		Rainbow = false,

		Billboards = true,
		Highlighters = true,
		Distance = true,
		Tracers = true,
		Arrows = true,

		Box2D = true,
		HealthBar = true,
		CenterDot = false, -- New Feature Toggle

		Font = Enum.Font.RobotoCondensed
	},

	-- // Rainbow Variables // --
	RainbowHueSetup = 0,
	RainbowHue = 0,
	RainbowStep = 0,
	RainbowColor = Color3.new()
}

-- // Player Variables // --
local character;
local rootPart;
local camera = workspace.CurrentCamera;

local function worldToViewport(...)
	camera = (camera or workspace.CurrentCamera);
	if camera == nil then
		return Vector2.new(0, 0), false;
	end

	return camera:WorldToViewportPoint(...);
end

local function UpdatePlayerVariables(newCharacter, force)
	if force ~= true and Library.GlobalConfig.IgnoreCharacter == true then
		return;
	end;

	character = newCharacter or Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait();
	rootPart =
		character:WaitForChild("HumanoidRootPart", 2.5)
		or character:WaitForChild("UpperTorso", 2.5)
		or character:WaitForChild("Torso", 2.5)
		or character.PrimaryPart
		or character:WaitForChild("Head", 2.5);
end
task.spawn(UpdatePlayerVariables, nil, true);

--// Library Functions \\--
function Library:Clear()
	if Library.Destroyed == true then
		return
	end

	for _, ESP in pairs(Library.ESP) do
		if not ESP then continue end
		ESP:Destroy()
	end
end

function Library:Destroy()
	if Library.Destroyed == true then
		return
	end

	-- // Destroy Library // --
	Library:Clear();
	Library.Destroyed = true;

	-- // Destroy Folders // --
	ActiveFolder:Destroy();
	StorageFolder:Destroy();
	MainGUI:Destroy();
	BillboardGUI:Destroy();
	
	--// Clear connections \\--
	for _, connection in Library.Connections do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end
	table.clear(Library.Connections)

	-- // Clear getgenv // --
	getgenv().mstudio45_ESP = nil;
end

--// Type Checks \\--
local AllowedTracerFrom = {
	top = true,
	bottom = true,
	center = true,
	mouse = true,
}

local AllowedESPType = {
	text = true,
	sphereadornment = true,
	cylinderadornment = true,
	adornment = true,
	selectionbox = true,
	highlight = true,
}

--// ESP Instances \\--
function TracerCreate(espSettings, instanceName)
	if Library.Destroyed == true then
		return
	end

	if not espSettings then
		espSettings = {}
	end

	if espSettings.Enabled ~= true then
		return
	end

	-- // Fix Settings // --
	espSettings.Color = typeof(espSettings.Color) == "Color3" and espSettings.Color or Color3.new()
	espSettings.Thickness = typeof(espSettings.Thickness) == "number" and espSettings.Thickness or 2
	espSettings.Transparency = typeof(espSettings.Transparency) == "number" and espSettings.Transparency or 0
	espSettings.From = string.lower(typeof(espSettings.From) == "string" and espSettings.From or "bottom")
	if AllowedTracerFrom[espSettings.From] == nil then
		espSettings.From = "bottom"
	end

	-- // Create Path2D // --
	local Path2D = InstancesLib.Create("Path2D", {
		Parent = MainGUI,
		Name = if typeof(instanceName) == "string" then instanceName else "Tracer",
		Closed = true,

		-- // Settings // --
		Color3 = espSettings.Color,
		Thickness = espSettings.Thickness,
		Transparency = espSettings.Transparency,
	})

	local function UpdateTracer(from, to)
		Path2D:SetControlPoints({
			Path2DControlPoint.new(UDim2.fromOffset(from.X, from.Y)),
			Path2DControlPoint.new(UDim2.fromOffset(to.X, to.Y))
		})
	end

	--// Data Table \\--
	local data = {
		From = typeof(espSettings.From) ~= "Vector2" and UDim2.fromOffset(0, 0) or UDim2.fromOffset(espSettings.From.X, espSettings.From.Y),
		To = typeof(espSettings.To) ~= "Vector2" and UDim2.fromOffset(0, 0) or UDim2.fromOffset(espSettings.To.X, espSettings.To.Y),

		Visible = true,
		Color3 = espSettings.Color,
		Thickness = espSettings.Thickness,
		Transparency = espSettings.Transparency,
	}
	UpdateTracer(data.From, data.To);

	--// Tracer Metatable \\--
	local proxy = {}
	local Tracer = {
		__newindex = function(table, key, value)
			if not Path2D then
				return
			end

			if key == "From" then
				assert(typeof(value) == "Vector2", tostring(key) .. "; expected Vector2, got " .. typeof(value))
				UpdateTracer(value, data.To)

			elseif key == "To" then
				assert(typeof(value) == "Vector2", tostring(key) .. "; expected Vector2, got " .. typeof(value))
				UpdateTracer(data.From, value)

			elseif key == "Transparency" or key == "Thickness" then
				assert(typeof(value) == "number", tostring(key) .. "; expected number, got " .. typeof(value))
				Path2D[key] = value

			elseif key == "Color3" then
				assert(typeof(value) == "Color3", tostring(key) .. "; expected Color3, got " .. typeof(value))
				Path2D.Color3 = value

			elseif key == "Visible" then
				assert(typeof(value) == "boolean", tostring(key) .. "; expected boolean, got " .. typeof(value))

				Path2D.Parent = if value then MainGUI else StorageFolder;
			end

			data[key] = value
		end,

		__index = function(table, key)
			if not Path2D then
				return nil
			end

			if key == "Destroy" or key == "Delete" then
				return function()
					Path2D:SetControlPoints({ });
					Path2D:Destroy();

					Path2D = nil;
				end
			end

			return data[key]
		end,
	}

	return setmetatable(proxy, Tracer)
end

function Library:Add(espSettings)
	if Library.Destroyed == true then
		return
	end

	assert(typeof(espSettings) == "table", "espSettings; expected table, got " .. typeof(espSettings))
	assert(
		typeof(espSettings.Model) == "Instance",
		"espSettings.Model; expected Instance, got " .. typeof(espSettings.Model)
	)

	-- // Fix ESPType // --
	if not espSettings.ESPType then
		espSettings.ESPType = "Highlight"
	end
	assert(
		typeof(espSettings.ESPType) == "string",
		"espSettings.ESPType; expected string, got " .. typeof(espSettings.ESPType)
	)

	espSettings.ESPType = string.lower(espSettings.ESPType)
	assert(AllowedESPType[espSettings.ESPType] == true, "espSettings.ESPType; invalid ESPType")

	-- // Fix Settings (Extended) // --
	espSettings.Name = if typeof(espSettings.Name) == "string" then espSettings.Name else espSettings.Model.Name;
	espSettings.TextModel = if typeof(espSettings.TextModel) == "Instance" then espSettings.TextModel else InstancesLib.FindPrimaryPart(espSettings.Model) or espSettings.Model;

	espSettings.Visible = if typeof(espSettings.Visible) == "boolean" then espSettings.Visible else true;
	espSettings.Color = if typeof(espSettings.Color) == "Color3" then espSettings.Color else Color3.new();
	espSettings.MaxDistance = if typeof(espSettings.MaxDistance) == "number" then espSettings.MaxDistance else 5000;
	
	-- Billboard/Text Settings
	espSettings.StudsOffset = if typeof(espSettings.StudsOffset) == "Vector3" then espSettings.StudsOffset else Vector3.new(0, 2, 0); -- Adjusted default
	espSettings.TextSize = if typeof(espSettings.TextSize) == "number" then espSettings.TextSize else 16;
	
	-- Highlighter Settings
	espSettings.Thickness = if typeof(espSettings.Thickness) == "number" then espSettings.Thickness else 0.1;
	espSettings.Transparency = if typeof(espSettings.Transparency) == "number" then espSettings.Transparency else 0.65;
	espSettings.SurfaceColor = if typeof(espSettings.SurfaceColor) == "Color3" then espSettings.SurfaceColor else Color3.new();
	espSettings.FillColor = if typeof(espSettings.FillColor) == "Color3" then espSettings.FillColor else Color3.new();
	espSettings.OutlineColor = if typeof(espSettings.OutlineColor) == "Color3" then espSettings.OutlineColor else Color3.new(1, 1, 1);
	espSettings.FillTransparency = if typeof(espSettings.FillTransparency) == "number" then espSettings.FillTransparency else 0.65;
	espSettings.OutlineTransparency = if typeof(espSettings.OutlineTransparency) == "number" then espSettings.OutlineTransparency else 0;
	
	-- Tracer/Arrow Settings
	espSettings.Tracer = if typeof(espSettings.Tracer) == "table" then espSettings.Tracer else { Enabled = false };
	espSettings.Arrow = if typeof(espSettings.Arrow) == "table" then espSettings.Arrow else { Enabled = false };

	-- New Custom Settings
	espSettings.Box2D = espSettings.Box2D or { Enabled = false, Color = Color3.new(1, 1, 1), Thickness = 2, Style = "Full" };
	espSettings.HealthBar = espSettings.HealthBar or { Enabled = false, Color = Color3.new(0, 1, 0), Background = Color3.new(0, 0, 0) };
	espSettings.CenterDot = espSettings.CenterDot or { Enabled = false, Color = Color3.new(0, 1, 1), Size = 6, VisibleThroughWalls = true, Offset = V3(0, 0, 0) };


	--// ESP Data \\--
	local ESP = {
		Index = RandomString(),
		OriginalSettings = tablefreeze(espSettings),
		CurrentSettings = espSettings,

		Hidden = false,
		Deleted = false,
		Connections = {}
	}

	-- // Create Billboard (Name/Distance) // --
	local Billboard = InstancesLib.Create("BillboardGui", {
		Parent = BillboardGUI,
		Name = ESP.Index,

		Enabled = true,
		ResetOnSpawn = false,
		AlwaysOnTop = true,
		Size = UDim2.new(0, 200, 0, 50),

		-- // Settings // --
		Adornee = ESP.CurrentSettings.TextModel,
		StudsOffset = ESP.CurrentSettings.StudsOffset,
	})

	local BillboardText = InstancesLib.Create("TextLabel", {
		Parent = Billboard,

		Size = UDim2.new(0, 200, 0, 50),
		Font = Library.GlobalConfig.Font,
		TextWrap = true,
		TextWrapped = true,
		RichText = true,
		TextStrokeTransparency = 0,
		BackgroundTransparency = 1,

		-- // Settings // --
		Text = ESP.CurrentSettings.Name,
		TextColor3 = ESP.CurrentSettings.Color,
		TextSize = ESP.CurrentSettings.TextSize,
	})

	InstancesLib.Create("UIStroke", { Parent = BillboardText })
	
	-- // 2D Screen Visuals Container (Box2D, HealthBar) // --
	local ScreenFrame = InstancesLib.Create("Frame", {
	    Parent = MainGUI,
	    Name = ESP.Index .. "_2D",
	    BackgroundTransparency = 1,
	    Size = UDim2.fromOffset(100, 100),
	    ZIndex = 2,
	    Visible = false
	})
	
	-- Health Bar Instances
	local HealthBarContainer = InstancesLib.Create("Frame", {
        Size = UDim2.new(0, 6, 1, 0),
        Position = UDim2.new(1, 4, 0, 0), 
        BackgroundTransparency = 1,
        ZIndex = 3
    }, ScreenFrame)

    local HealthBarBackground = InstancesLib.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = ESP.CurrentSettings.HealthBar.Background,
        BorderSizePixel = 1,
        BorderColor3 = Color3.new(0, 0, 0),
    }, HealthBarContainer)
    
    local HealthBar = InstancesLib.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = ESP.CurrentSettings.HealthBar.Color,
        AnchorPoint = V2(0, 1) -- Fills up from bottom
    }, HealthBarBackground)
	
	-- // Center Dot ESP // --
    local DotBillboard = InstancesLib.Create("BillboardGui", {
        Parent = BillboardGUI,
        Name = ESP.Index .. "_Dot",
        Adornee = ESP.CurrentSettings.TextModel, -- Adorn to the TextModel (usually root part)
        Size = UDim2.fromOffset(50, 50),
        StudsOffset = ESP.CurrentSettings.CenterDot.Offset,
        AlwaysOnTop = ESP.CurrentSettings.CenterDot.VisibleThroughWalls,
        Enabled = false
    })

    local DotFrame = InstancesLib.Create("Frame", {
        Parent = DotBillboard,
        Size = UDim2.fromOffset(ESP.CurrentSettings.CenterDot.Size, ESP.CurrentSettings.CenterDot.Size),
        AnchorPoint = V2(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = ESP.CurrentSettings.CenterDot.Color,
        BorderSizePixel = 0
    })

    InstancesLib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }, DotFrame)

	-- // Create Highlighter (Supports all 6 types) // --
	local Highlighter, IsAdornment = nil, not not string.match(string.lower(ESP.OriginalSettings.ESPType), "adornment")

	if IsAdornment then
		local _, ModelSize = nil, nil
		if ESP.CurrentSettings.Model:IsA("Model") then
			_, ModelSize = ESP.CurrentSettings.Model:GetBoundingBox()
		else
			if not InstancesLib.TryGetProperty(ESP.CurrentSettings.Model, "Size") then
				local prim = InstancesLib.FindPrimaryPart(ESP.CurrentSettings.Model)
				if not InstancesLib.TryGetProperty(prim, "Size") then
					-- Fallback to Highlight if size can't be found
					espSettings.ESPType = "highlight"
					return Library:Add(espSettings)
				end

				ModelSize = prim.Size
			else
				ModelSize = ESP.CurrentSettings.Model.Size
			end
		end

		if ESP.OriginalSettings.ESPType == "sphereadornment" then
			Highlighter = InstancesLib.Create("SphereHandleAdornment", {
				Parent = ActiveFolder,
				Name = ESP.Index,
				Adornee = ESP.CurrentSettings.Model,
				AlwaysOnTop = true,
				ZIndex = 10,
				Radius = (ModelSize.X + ModelSize.Y + ModelSize.Z) / 3 * 0.75, -- Adjusted for better fit
				CFrame = CFrame.new() * CFrame.Angles(math.rad(90), 0, 0),
				Color3 = ESP.CurrentSettings.Color,
				Transparency = ESP.CurrentSettings.Transparency,
			})
		elseif ESP.OriginalSettings.ESPType == "cylinderadornment" then
			Highlighter = InstancesLib.Create("CylinderHandleAdornment", {
				Parent = ActiveFolder,
				Name = ESP.Index,
				Adornee = ESP.CurrentSettings.Model,
				AlwaysOnTop = true,
				ZIndex = 10,
				Height = ModelSize.Y * 2,
				Radius = (ModelSize.X + ModelSize.Z) / 2 * 1.085,
				CFrame = CFrame.new() * CFrame.Angles(math.rad(90), 0, 0),
				Color3 = ESP.CurrentSettings.Color,
				Transparency = ESP.CurrentSettings.Transparency,
			})
		else -- Default BoxHandleAdornment ("adornment")
			Highlighter = InstancesLib.Create("BoxHandleAdornment", {
				Parent = ActiveFolder,
				Name = ESP.Index,
				Adornee = ESP.CurrentSettings.Model,
				AlwaysOnTop = true,
				ZIndex = 10,
				Size = ModelSize,
				Color3 = ESP.CurrentSettings.Color,
				Transparency = ESP.CurrentSettings.Transparency,
			})
		end
	elseif ESP.OriginalSettings.ESPType == "selectionbox" then
		Highlighter = InstancesLib.Create("SelectionBox", {
			Parent = ActiveFolder,
			Name = ESP.Index,
			Adornee = ESP.CurrentSettings.Model,
			Color3 = ESP.CurrentSettings.Color, -- BorderColor in original
			LineThickness = ESP.CurrentSettings.Thickness,
			SurfaceColor3 = ESP.CurrentSettings.SurfaceColor,
			SurfaceTransparency = ESP.CurrentSettings.Transparency,
		})
	elseif ESP.OriginalSettings.ESPType == "highlight" then
		Highlighter = InstancesLib.Create("Highlight", {
			Parent = ActiveFolder,
			Name = ESP.Index,
			Adornee = ESP.CurrentSettings.Model,
			FillColor = ESP.CurrentSettings.FillColor,
			OutlineColor = ESP.CurrentSettings.OutlineColor,
			FillTransparency = ESP.CurrentSettings.FillTransparency, -- User requested transparency control
			OutlineTransparency = ESP.CurrentSettings.OutlineTransparency,
		})
	end

	-- // Create Tracer and Arrow // --
	local Tracer = if typeof(ESP.OriginalSettings.Tracer) == "table" then TracerCreate(ESP.CurrentSettings.Tracer, ESP.Index) else nil;
	local Arrow = nil;

	if typeof(ESP.OriginalSettings.Arrow) == "table" then
		Arrow = InstancesLib.Create("ImageLabel", {
			Parent = MainGUI,
			Name = ESP.Index,

			Size = UDim2.new(0, 48, 0, 48),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,

			AnchorPoint = Vector2.new(0.5, 0.5),

			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Image = "http://www.roblox.com/asset/?id=16368985219",
			ImageColor3 = ESP.CurrentSettings.Color,
		});
		ESP.CurrentSettings.Arrow.CenterOffset = if typeof(ESP.CurrentSettings.Arrow.CenterOffset) == "number" then ESP.CurrentSettings.Arrow.CenterOffset else 300;
	end

	-- // Setup Delete Handler // --
	function ESP:Destroy()
		if ESP.Deleted == true then
			return;
		end

		-- // Clear from ESP // --
		ESP.Deleted = true

		if table.find(Library.ESP, ESP.Index) then
			table.remove(Library.ESP, table.find(Library.ESP, ESP.Index))
		end
		Library.ESP[ESP.Index] = nil

		--// Delete ESP Instances \\--
		if Billboard then Billboard:Destroy() end
		if Highlighter then Highlighter:Destroy() end
		if Tracer then Tracer:Destroy() end
		if Arrow then Arrow:Destroy() end
		if ScreenFrame then ScreenFrame:Destroy() end
		if DotBillboard then DotBillboard:Destroy() end

		--// Clear connections \\--
		for _, connection in ESP.Connections do
			if connection and connection.Connected then
				connection:Disconnect()
			end
		end
		table.clear(ESP.Connections)
		
		--// OnDestroy \\--
		if ESP.OriginalSettings.OnDestroy then
			SafeCallback(ESP.OriginalSettings.OnDestroy.Fire, ESP.OriginalSettings.OnDestroy)
		end

		if ESP.OriginalSettings.OnDestroyFunc then
			SafeCallback(ESP.OriginalSettings.OnDestroyFunc)
		end

		ESP.Render = function(...) end
	end

	-- // Setup Update Handler // --
	local function Show(forceShow)
		if not (ESP and ESP.Deleted ~= true) then return end
		if forceShow ~= true and not ESP.Hidden then
			return
		end

		ESP.Hidden = false;
		--// Apply to Instances \\--
		Billboard.Enabled = true;

		if Highlighter then
			Highlighter.Adornee = ESP.CurrentSettings.Model;
			Highlighter.Parent = ActiveFolder;
		end

		if Tracer then
			Tracer.Visible = true;
		end

		if Arrow then
			Arrow.Visible = true;
		end
		
		if DotBillboard and ESP.CurrentSettings.CenterDot.Enabled then
		    DotBillboard.Enabled = true
		end
	end

	local function Hide(forceHide)
		if not (ESP and ESP.Deleted ~= true) then return end
		if forceHide ~= true and ESP.Hidden then
			return
		end

		ESP.Hidden = true

		--// Apply to Instances \\--
		Billboard.Enabled = false;
		if Highlighter then
			Highlighter.Adornee = nil;
			Highlighter.Parent = StorageFolder;
		end

		if Tracer then
			Tracer.Visible = false;
		end

		if Arrow then
			Arrow.Visible = false;
		end
		
		if ScreenFrame then
		    ScreenFrame.Visible = false
		end
		
		if DotBillboard then
		    DotBillboard.Enabled = false
		end
	end

	function ESP:Show(force)
		ESP.CurrentSettings.Visible = true
		Show(force);
	end

	function ESP:Hide(force)
		if not (ESP and ESP.CurrentSettings and ESP.Deleted ~= true) then return end

		ESP.CurrentSettings.Visible = false
		Hide(force);
	end

	function ESP:ToggleVisibility(force)
		ESP.CurrentSettings.Visible = not ESP.CurrentSettings.Visible
		if ESP.CurrentSettings.Visible then
			Show(force);
		else
			Hide(force);
		end
	end

	function ESP:Render()
		--// Check if ESP is valid // --
		if not ESP then return end

		local ESPSettings = ESP.CurrentSettings
		if ESP.Deleted == true or not ESPSettings then return end
		
		-- // Early exit conditions // --
		if not (ESPSettings.Visible and camera and (if Library.GlobalConfig.IgnoreCharacter == true then true else rootPart)) then
			Hide()
			return
		end

		-- // Check Distance // --
		if not ESPSettings.ModelRoot then
			ESPSettings.ModelRoot = InstancesLib.FindPrimaryPart(ESPSettings.Model)
		end

		local modelRoot = ESPSettings.ModelRoot or ESPSettings.Model
		local distanceFromPlayer = InstancesLib.DistanceFrom(modelRoot, rootPart or camera)

		if distanceFromPlayer > ESPSettings.MaxDistance then
			Hide()
			return
		end

		-- // Get Screen Information // --
		local rootScreenPos, isOnScreen = worldToViewport(GetPivot(modelRoot).Position)
		local rainbowColor = Library.GlobalConfig.Rainbow and Library.RainbowColor or nil
		
		--// Before Update Callback \\--
		if ESPSettings.BeforeUpdate then
			SafeCallback(ESPSettings.BeforeUpdate, ESP)
		end

		-- // Update Arrow (only requires distance check) // --
		if Arrow then
			Arrow.Visible = Library.GlobalConfig.Arrows == true and ESPSettings.Arrow.Enabled == true and (isOnScreen ~= true);
			if Arrow.Visible then
				local screenSize = camera.ViewportSize
				local centerPos = Vector2.new(screenSize.X / 2, screenSize.Y / 2)

				local partPos = Vector2.new(rootScreenPos.X, rootScreenPos.Y);
				local IsInverted = rootScreenPos.Z <= 0;
				local invert = (IsInverted and -1 or 1);

				local direction = (partPos - centerPos);
				local arctan = math.atan2(direction.Y, direction.X);
				local angle = math.deg(arctan) + 90;
				local distance = (ESPSettings.Arrow.CenterOffset * 0.001) * screenSize.Y;
				
				Arrow.Rotation = angle + 180 * (IsInverted and 0 or 1);
				Arrow.Position = UDim2.new(
					0,
					centerPos.X + (distance * math.cos(arctan) * invert),
					0,
					centerPos.Y + (distance * math.sin(arctan) * invert)
				);
				Arrow.ImageColor3 = rainbowColor or ESPSettings.Arrow.Color;
			end
		end

		if isOnScreen == false then
			Hide()
			return
		else Show() end
		
		-- // Bounding Box Calculation for 2D Visuals // --
        local Box = GetModelBoundingBox(ESPSettings.Model)
        local MinX, MaxX = math.huge, -math.huge
        local MinY, MaxY = math.huge, -math.huge
        local BBoxValid = false
        
        if Box then
            local corners = {
                V3(Box.Min.X, Box.Min.Y, Box.Min.Z), V3(Box.Min.X, Box.Min.Y, Box.Max.Z),
                V3(Box.Min.X, Box.Max.Y, Box.Min.Z), V3(Box.Min.X, Box.Max.Y, Box.Max.Z),
                V3(Box.Max.X, Box.Min.Y, Box.Min.Z), V3(Box.Max.X, Box.Min.Y, Box.Max.Z),
                V3(Box.Max.X, Box.Max.Y, Box.Min.Z), V3(Box.Max.X, Box.Max.Y, Box.Max.Z)
            }
            
            for _, worldCorner in ipairs(corners) do
                local screenPos, onScreen = worldToViewport(worldCorner)
                if onScreen and screenPos.Z > 0 then
                    MinX = math.min(MinX, screenPos.X)
                    MaxX = math.max(MaxX, screenPos.X)
                    MinY = math.min(MinY, screenPos.Y)
                    MaxY = math.max(MaxY, screenPos.Y)
                end
            end
            
            BBoxValid = MinX < MaxX and MinY < MaxY
        end

        -- // Update Screen Visuals (Box2D, HealthBar) // --
        ScreenFrame.Visible = (Library.GlobalConfig.Box2D and ESPSettings.Box2D.Enabled) or (Library.GlobalConfig.HealthBar and ESPSettings.HealthBar.Enabled)
        
        if ScreenFrame.Visible and BBoxValid then
            local FramePos = V2(MinX, MinY)
            local FrameSize = V2(MaxX - MinX, MaxY - MinY)
            
            ScreenFrame.Position = UDim2.fromOffset(FramePos.X, FramePos.Y)
            ScreenFrame.Size = UDim2.fromOffset(FrameSize.X, FrameSize.Y)
            
            -- Box2D Drawing (Dynamic Frame for Box)
            local ExistingBox = ScreenFrame:FindFirstChild("ESP_BOX_VISUALS")
            if ExistingBox then Debris:AddItem(ExistingBox, 0) end
            
            if Library.GlobalConfig.Box2D and ESPSettings.Box2D.Enabled then
                local BoxColor = rainbowColor or ESPSettings.Box2D.Color
                local T = ESPSettings.Box2D.Thickness
                
                local BoxFrame = InstancesLib.Create("Frame", {
                    Name = "ESP_BOX_VISUALS",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = T,
                    BorderColor3 = BoxColor,
                    ZIndex = 2
                }, ScreenFrame)
                
                if ESPSettings.Box2D.Style == "Corner" then
                    BoxFrame.BorderSizePixel = 0
                    local L = FrameSize.X * 0.25 

                    -- Top Left Corners
                    InstancesLib.Create("Frame", { Size = UDim2.new(0, T, 0, L), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = BoxColor, ZIndex = 3 }, BoxFrame)
                    InstancesLib.Create("Frame", { Size = UDim2.new(0, L, 0, T), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = BoxColor, ZIndex = 3 }, BoxFrame)
                    
                    -- Top Right Corners
                    InstancesLib.Create("Frame", { Size = UDim2.new(0, T, 0, L), Position = UDim2.new(1, -T, 0, 0), BackgroundColor3 = BoxColor, ZIndex = 3 }, BoxFrame)
                    InstancesLib.Create("Frame", { Size = UDim2.new(0, L, 0, T), Position = UDim2.new(1, -L, 0, 0), BackgroundColor3 = BoxColor, ZIndex = 3 }, BoxFrame)
                    
                    -- Bottom Left Corners
                    InstancesLib.Create("Frame", { Size = UDim2.new(0, T, 0, L), Position = UDim2.new(0, 0, 1, -L), BackgroundColor3 = BoxColor, ZIndex = 3 }, BoxFrame)
                    InstancesLib.Create("Frame", { Size = UDim2.new(0, L, 0, T), Position = UDim2.new(0, 0, 1, -T), BackgroundColor3 = BoxColor, ZIndex = 3 }, BoxFrame)

                    -- Bottom Right Corners
                    InstancesLib.Create("Frame", { Size = UDim2.new(0, T, 0, L), Position = UDim2.new(1, -T, 1, -L), BackgroundColor3 = BoxColor, ZIndex = 3 }, BoxFrame)
                    InstancesLib.Create("Frame", { Size = UDim2.new(0, L, 0, T), Position = UDim2.new(1, -L, 1, -T), BackgroundColor3 = BoxColor, ZIndex = 3 }, BoxFrame)
                end
            end
            
            -- Health Bar Update
            local Humanoid = ESPSettings.Model:FindFirstChildOfClass("Humanoid")
            HealthBarContainer.Visible = Library.GlobalConfig.HealthBar and ESPSettings.HealthBar.Enabled and Humanoid ~= nil
            if HealthBarContainer.Visible and Humanoid then
                local HealthRatio = Humanoid.Health / Humanoid.MaxHealth
                HealthBar.Size = UDim2.new(1, 0, HealthRatio, 0)
                HealthBar.BackgroundColor3 = rainbowColor or Color3.fromHSV(HealthRatio * 0.35, 1, 1) -- Dynamic Health Color
            end
        else
            ScreenFrame.Visible = false
        end

		-- // Update Tracer // --
		if Tracer then
			Tracer.Visible = Library.GlobalConfig.Tracers == true and ESPSettings.Tracer.Enabled == true;
			if Tracer.Visible then
				-- // Position // --
				local fromPos
				if ESPSettings.Tracer.From == "mouse" then
					local mousePos = UserInputService:GetMouseLocation()
					fromPos = Vector2.new(mousePos.X, mousePos.Y);
				elseif ESPSettings.Tracer.From == "top" then
					fromPos = Vector2.new(camera.ViewportSize.X / 2, 0);
				elseif ESPSettings.Tracer.From == "center" then
					fromPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
				else
					fromPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y);
				end

				Tracer.From = fromPos;
				Tracer.To = Vector2.new(rootScreenPos.X, rootScreenPos.Y);

				-- // Visuals // --
				Tracer.Transparency = ESPSettings.Tracer.Transparency;
				Tracer.Thickness = ESPSettings.Tracer.Thickness;
				Tracer.Color3 = rainbowColor or ESPSettings.Tracer.Color;
			end
		end

		-- // Update Billboard (Text) // --
		if Billboard then
			Billboard.Enabled = Library.GlobalConfig.Billboards == true;
			if Billboard.Enabled then
				if Library.GlobalConfig.Distance then
					BillboardText.Text = string.format(
						'%s\n<font size="%d">[%s]</font>',
						ESPSettings.Name,
						ESPSettings.TextSize - 3,
						math.floor(distanceFromPlayer)
					);
				else
					BillboardText.Text = ESPSettings.Name;
				end

				BillboardText.Font = Library.GlobalConfig.Font;
				BillboardText.TextColor3 = rainbowColor or ESPSettings.Color;
				BillboardText.TextSize = ESPSettings.TextSize;
			end
		end
		
		-- // Update Center Dot // --
		if DotBillboard then
		    local DotVis = Library.GlobalConfig.CenterDot and ESPSettings.CenterDot.Enabled and ESPSettings.TextModel.Parent ~= nil
		    DotBillboard.Enabled = DotVis
		    if DotVis then
		        DotBillboard.AlwaysOnTop = ESPSettings.CenterDot.VisibleThroughWalls
		        DotBillboard.StudsOffset = ESPSettings.CenterDot.Offset
		        DotFrame.BackgroundColor3 = rainbowColor or ESPSettings.CenterDot.Color
		        DotFrame.Size = UDim2.fromOffset(ESPSettings.CenterDot.Size, ESPSettings.CenterDot.Size)
		    end
		end

		-- // Update Highlighter // --
		if Highlighter then
			Highlighter.Parent = if Library.GlobalConfig.Highlighters == true then ActiveFolder else StorageFolder;
			Highlighter.Adornee = if Library.GlobalConfig.Highlighters == true then ESPSettings.Model else nil;
			
			if Highlighter.Adornee then
				local color = rainbowColor or ESPSettings.Color
				
				if IsAdornment then
					Highlighter.Color3 = color;
					Highlighter.Transparency = ESPSettings.Transparency
				elseif ESP.OriginalSettings.ESPType == "selectionbox" then
					Highlighter.Color3 = color;
					Highlighter.LineThickness = ESPSettings.Thickness;
					Highlighter.SurfaceColor3 = ESPSettings.SurfaceColor;
					Highlighter.SurfaceTransparency = ESPSettings.Transparency;
				else -- Highlight
					Highlighter.FillColor = rainbowColor or ESPSettings.FillColor;
					Highlighter.OutlineColor = rainbowColor or ESPSettings.OutlineColor;
					Highlighter.FillTransparency = ESPSettings.FillTransparency;
					Highlighter.OutlineTransparency = ESPSettings.OutlineTransparency;
				end
			end
		end

		--// After Update Callback \\--
		if ESPSettings.AfterUpdate then
			SafeCallback(ESPSettings.AfterUpdate, ESP)
		end
	end

	if not ESP.OriginalSettings.Visible then
		Hide()
	end

	Library.ESP[ESP.Index] = ESP
	return ESP
end

-- // Update Player Variables // --
table.insert(Library.Connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	camera = workspace.CurrentCamera;
end))
table.insert(Library.Connections, Players.LocalPlayer.CharacterAdded:Connect(UpdatePlayerVariables))

-- // Rainbow Handler // --
table.insert(Library.Connections, RunService.RenderStepped:Connect(function(Delta)
	--//  Only update rainbow if it's enabled // --
	if not Library.GlobalConfig.Rainbow then
		return
	end
	
	Library.RainbowStep = Library.RainbowStep + Delta

	if Library.RainbowStep >= (1 / 60) then
		Library.RainbowStep = 0

		Library.RainbowHueSetup = Library.RainbowHueSetup + (1 / 400)
		if Library.RainbowHueSetup > 1 then
			Library.RainbowHueSetup = 0
		end

		Library.RainbowHue = Library.RainbowHueSetup
		Library.RainbowColor = Color3.fromHSV(Library.RainbowHue, 0.8, 1)
	end
end))

-- // Main Handler // --
table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
	for Index, ESP in Library.ESP do
		if not ESP then 
			Library.ESP[Index] = nil
			continue 
		end

		if 
			ESP.Deleted == true 
			or 
			not (ESP.CurrentSettings and (ESP.CurrentSettings.Model and ESP.CurrentSettings.Model.Parent)) 
		then
			ESP:Destroy()
			continue
		end

		-- // Render ESP // --
		pcall(ESP.Render, ESP)
	end
end))

getgenv().mstudio45_ESP = Library
getgenv().StarLightESPLibrary = Library -- For easier access
return Library