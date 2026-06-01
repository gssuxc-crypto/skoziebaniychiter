local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local rooms = workspace:WaitForChild("Rooms")
local spawnedEntities = workspace:WaitForChild("SpawnedEntities")

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

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

local function addHighlight(obj,color)
	if obj:FindFirstChildOfClass("Highlight") then
		return
	end

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
		if parent.Name == "ItemSpawns" then
			return true
		end

		parent = parent.Parent
	end

	return false
end

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

	local text = toolAttr
		and "["..obj.Name.."]: Tool - \""..toolAttr.."\""
		or "["..obj.Name.."]"

	local line = Instance.new("TextLabel")
	line.Size = UDim2.new(1,-6,0,18)
	line.BackgroundTransparency = 1
	line.TextXAlignment = Enum.TextXAlignment.Left
	line.Font = Enum.Font.Code
	line.TextSize = 16
	line.TextColor3 = Color3.fromRGB(255,255,255)
	line.Text = text
	line.Parent = debugFrame

	debugFrame.CanvasSize =
		UDim2.new(0,0,0,debugLayout.AbsoluteContentSize.Y+10)

	debugFrame.CanvasPosition =
		Vector2.new(0, debugFrame.CanvasSize.Y.Offset)
end

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

	entityFrame.CanvasSize =
		UDim2.new(0,0,0,entityLayout.AbsoluteContentSize.Y+10)

	entityFrame.CanvasPosition =
		Vector2.new(0, entityFrame.CanvasSize.Y.Offset)
end

local function getMainPart(obj)
	if obj:IsA("BasePart") then
		return obj
	end

	if obj:IsA("Model") then
		if obj.PrimaryPart then
			return obj.PrimaryPart
		end

		return obj:FindFirstChildWhichIsA("BasePart")
	end

	return nil
end

local function trackEntity(obj)
	addEntityText(obj.Name, Color3.fromRGB(255,0,0))

	obj.Destroying:Connect(function()
		addEntityText(
			"[ "..obj.Name.." Destroyed ]",
			Color3.fromRGB(0,255,0)
		)
	end)
end

local beams = {}
local entityBillboards = {}

local function highlightEntity(obj)
	local part = getMainPart(obj)
	if not part then return end

	if obj:FindFirstChild("HighlightGui") then
		return
	end

	local gui = Instance.new("BillboardGui")
	gui.Name = "HighlightGui"
	gui.Size = UDim2.new(4,0,4,0)
	gui.Adornee = part
	gui.AlwaysOnTop = true
	gui.Parent = obj

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,1,0)
	frame.BackgroundColor3 = Color3.fromRGB(255,0,0)
	frame.BackgroundTransparency = 0.5
	frame.BorderSizePixel = 0
	frame.Parent = gui
end

local function createBeam(obj)
	local part = getMainPart(obj)
	if not part then return end

	if beams[obj] then
		return
	end

	local att0 = Instance.new("Attachment")
	att0.Parent = hrp

	local att1 = Instance.new("Attachment")
	att1.Parent = part

	local beam = Instance.new("Beam")
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.FaceCamera = true
	beam.Width0 = 0.2
	beam.Width1 = 0.2
	beam.Color = ColorSequence.new(Color3.fromRGB(255,0,0))
	beam.Transparency = NumberSequence.new(0.5)
	beam.Parent = hrp

	beams[obj] = {
		beam = beam,
		att0 = att0,
		att1 = att1
	}

	obj.Destroying:Connect(function()
		if beams[obj] then
			beams[obj].beam:Destroy()
			beams[obj].att0:Destroy()
			beams[obj].att1:Destroy()
			beams[obj] = nil
		end
	end)
end

local function createDistanceBillboard(obj)
	local part = getMainPart(obj)
	if not part then return end

	if entityBillboards[obj] then
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DistanceGui"
	billboard.Size = UDim2.new(0,150,0,50)
	billboard.Adornee = part
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1,0,1,0)
	textLabel.BackgroundTransparency = 0.5
	textLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
	textLabel.TextColor3 = Color3.fromRGB(255,0,0)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextStrokeTransparency = 0
	textLabel.Parent = billboard

	entityBillboards[obj] = textLabel

	local conn
	conn = RunService.RenderStepped:Connect(function()
		local currentPart = getMainPart(obj)

		if currentPart and hrp then
			local distance =
				(hrp.Position - currentPart.Position).Magnitude

			textLabel.Text =
				string.format("%s\n%.1f studs", obj.Name, distance)
		else
			if billboard then
				billboard:Destroy()
			end

			entityBillboards[obj] = nil

			if conn then
				conn:Disconnect()
			end
		end
	end)
end

local function processEntity(obj)
	if not (obj:IsA("Model") or obj:IsA("BasePart")) then
		return
	end

	local part = getMainPart(obj)
	if not part then
		return
	end

	highlightEntity(obj)
	createBeam(obj)
	createDistanceBillboard(obj)
end

local function processItemSpawn(obj)
	if not obj:IsA("Model") then
		return
	end

	if not isInsideItemSpawns(obj) then
		return
	end

	addDebug(obj)

	local toolAttr = obj:GetAttribute("Tool")

	if toolAttr == "Vita-Shot"
		or toolAttr == "V-Booster" then

		addHighlight(obj, Color3.fromRGB(0,255,0))
		showText("VITA")

	else
		addHighlight(obj, Color3.fromRGB(170,0,255))
	end
end

for _, obj in ipairs(rooms:GetDescendants()) do
	processItemSpawn(obj)
end

for _, obj in ipairs(spawnedEntities:GetChildren()) do
	processEntity(obj)
	trackEntity(obj)
end

rooms.DescendantAdded:Connect(processItemSpawn)

spawnedEntities.ChildAdded:Connect(function(obj)
	processEntity(obj)
	trackEntity(obj)
end)
