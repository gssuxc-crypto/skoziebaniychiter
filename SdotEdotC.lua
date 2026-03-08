local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local rooms = workspace:WaitForChild("Rooms")
local spawnedEntities = workspace:WaitForChild("SpawnedEntities")

-- ===================== UI =====================
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

-- Основной текст уведомлений
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.3,0,0.1,0)
label.Position = UDim2.new(0.35,0,0.45,0)
label.BackgroundTransparency = 1
label.TextScaled = true
label.TextColor3 = Color3.fromRGB(255,255,255)
label.Font = Enum.Font.GothamBold
label.Visible = false
label.Parent = gui

local showing = false
local function showText(text)
	if showing then return end
	showing = true
	label.Text = text
	label.Visible = true
	task.delay(2,function()
		label.Visible = false
		showing = false
	end)
end

-- Функция подсветки
local function addHighlight(obj,color)
	if obj:FindFirstChildOfClass("Highlight") then return end
	local hl = Instance.new("Highlight")
	hl.FillColor = color
	hl.OutlineColor = color
	hl.FillTransparency = 0.5
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee = obj
	hl.Parent = obj
end

local function isInsideItemSpawns(obj)
	local parent = obj.Parent
	while parent do
		if parent.Name == "ItemSpawns" then return true end
		parent = parent.Parent
	end
	return false
end

-- ===================== ScrollingFrame для ItemSpawns =====================
local debugFrame = Instance.new("ScrollingFrame")
debugFrame.Size = UDim2.new(0.35,0,0.4,0)
debugFrame.Position = UDim2.new(0,10,0,10)
debugFrame.BackgroundTransparency = 0.3
debugFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
debugFrame.CanvasSize = UDim2.new(0,0,0,0)
debugFrame.ScrollBarThickness = 6
debugFrame.Parent = gui

local debugLayout = Instance.new("UIListLayout")
debugLayout.Parent = debugFrame
debugLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function addDebug(obj)
	local toolAttr = obj:GetAttribute("Tool")
	local text = toolAttr and "["..obj.Name.."]: Tool - \""..toolAttr.."\"" or "["..obj.Name.."]"
	local line = Instance.new("TextLabel")
	line.Size = UDim2.new(1,-6,0,18)
	line.BackgroundTransparency = 1
	line.TextXAlignment = Enum.TextXAlignment.Left
	line.Font = Enum.Font.Code
	line.TextSize = 16
	line.TextColor3 = Color3.fromRGB(255,255,255)
	line.Text = text
	line.Parent = debugFrame
	debugFrame.CanvasSize = UDim2.new(0,0,0,debugLayout.AbsoluteContentSize.Y+10)
	debugFrame.CanvasPosition = Vector2.new(0, debugFrame.CanvasSize.Y.Offset)
end

-- ===================== ScrollingFrame для SpawnedEntities =====================
local entityFrame = Instance.new("ScrollingFrame")
entityFrame.Size = UDim2.new(0.25,0,0.35,0)
entityFrame.Position = UDim2.new(1,-260,0,10)
entityFrame.BackgroundTransparency = 0.3
entityFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
entityFrame.CanvasSize = UDim2.new(0,0,0,0)
entityFrame.ScrollBarThickness = 6
entityFrame.Parent = gui

local entityLayout = Instance.new("UIListLayout")
entityLayout.Parent = entityFrame
entityLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function addEntityText(text,color)
	local line = Instance.new("TextLabel")
	line.Size = UDim2.new(1,-6,0,18)
	line.BackgroundTransparency = 1
	line.TextXAlignment = Enum.TextXAlignment.Left
	line.Font = Enum.Font.Code
	line.TextSize = 16
	line.TextColor3 = color
	line.Text = text
	line.Parent = entityFrame
	task.wait()
	entityFrame.CanvasSize = UDim2.new(0,0,0,entityLayout.AbsoluteContentSize.Y+10)
	entityFrame.CanvasPosition = Vector2.new(0, entityFrame.CanvasSize.Y.Offset)
end

local function trackEntity(model)
	addEntityText(model.Name,Color3.fromRGB(255,0,0))
	model.Destroying:Connect(function()
		addEntityText("[ "..model.Name.." Destroyed ]",Color3.fromRGB(0,255,0))
	end)
end

-- ===================== SpawnedEntities: Beam и Billboard =====================
local beams = {}
local modelBillboards = {}

local function highlightModel(model)
	if not model.PrimaryPart then return end
	if model:FindFirstChild("HighlightGui") then return end
	local gui = Instance.new("BillboardGui")
	gui.Name = "HighlightGui"
	gui.Size = UDim2.new(4,0,4,0)
	gui.Adornee = model.PrimaryPart
	gui.AlwaysOnTop = true
	gui.Parent = model
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,1,0)
	frame.BackgroundColor3 = Color3.fromRGB(255,0,0)
	frame.BackgroundTransparency = 0.5
	frame.BorderSizePixel = 0
	frame.Parent = gui
end

local function createBeam(model)
	if not model.PrimaryPart then return end
	if beams[model] then return end
	local att0 = Instance.new("Attachment")
	att0.Parent = hrp
	local att1 = Instance.new("Attachment")
	att1.Parent = model.PrimaryPart
	local beam = Instance.new("Beam")
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.FaceCamera = true
	beam.Width0 = 0.2
	beam.Width1 = 0.2
	beam.Color = ColorSequence.new(Color3.fromRGB(255,0,0))
	beam.Transparency = NumberSequence.new(0.5)
	beam.Parent = hrp
	beams[model] = {beam = beam, att0 = att0, att1 = att1}
	model.Destroying:Connect(function()
		if beams[model] then
			beams[model].beam:Destroy()
			beams[model].att0:Destroy()
			beams[model].att1:Destroy()
			beams[model] = nil
		end
	end)
end

local function createDistanceBillboard(model)
	if not model.PrimaryPart then return end
	if modelBillboards[model] then return end
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DistanceGui"
	billboard.Size = UDim2.new(0,150,0,50)
	billboard.Adornee = model.PrimaryPart
	billboard.AlwaysOnTop = true
	billboard.Parent = model.PrimaryPart
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1,0,1,0)
	textLabel.BackgroundTransparency = 0.5
	textLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
	textLabel.TextColor3 = Color3.fromRGB(255,0,0)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextStrokeTransparency = 0
	textLabel.Parent = billboard
	modelBillboards[model] = textLabel
	local conn
	conn = RunService.RenderStepped:Connect(function()
		if model.PrimaryPart and hrp then
			local distance = (hrp.Position - model.PrimaryPart.Position).Magnitude
			textLabel.Text = string.format("%s\n%.1f studs", model.Name, distance)
		else
			if billboard then billboard:Destroy() end
			modelBillboards[model] = nil
			if conn then conn:Disconnect() end
		end
	end)
end

local function processModel(model)
	if not model:IsA("Model") then return end
	if not model.PrimaryPart then return end
	highlightModel(model)
	createBeam(model)
	createDistanceBillboard(model)
end

-- ===================== ItemSpawns: обработка =====================
local function processItemSpawn(obj)
	if not obj:IsA("Model") then return end
	if not isInsideItemSpawns(obj) then return end
	addDebug(obj)
	local toolAttr = obj:GetAttribute("Tool")
	if obj.Name == "Bandage" or toolAttr == "Bandage" then
		addHighlight(obj, Color3.fromRGB(0,255,0))
		showText("bandage")
	elseif toolAttr == "Vita-Shot" or toolAttr == "V-Booster" then
		addHighlight(obj, Color3.fromRGB(0,255,0))
		showText("v-shot")
	else
		addHighlight(obj, Color3.fromRGB(170,0,255))
	end
end

-- ===== Обработка существующих объектов =====
for _, obj in ipairs(rooms:GetDescendants()) do processItemSpawn(obj) end
for _, model in ipairs(spawnedEntities:GetChildren()) do
	if model:IsA("Model") then
		processModel(model)
		trackEntity(model)
	end
end

-- ===== Подключение к событиям =====
rooms.DescendantAdded:Connect(processItemSpawn)
spawnedEntities.ChildAdded:Connect(function(model)
	if model:IsA("Model") then
		processModel(model)
		trackEntity(model)
	end
end)
