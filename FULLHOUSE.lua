loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
loadstring(game:HttpGet('https://raw.githubusercontent.com/gssuxc-crypto/skoziebaniychiter/refs/heads/main/SdotEdotC.lua'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local playerGui = player:WaitForChild("PlayerGui")

pcall(function()
	if character:FindFirstChild("HideClient") then
		character.HideClient:Destroy()
	end
end)

humanoid:SetAttribute("StaminaDrainMulti", 0)
humanoid:SetAttribute("StaminaChargeMulti", 1.3)

humanoid:GetAttributeChangedSignal("StaminaChargeMulti"):Connect(function()
	if humanoid:GetAttribute("StaminaChargeMulti") ~= 1.3 then
		humanoid:SetAttribute("StaminaChargeMulti", 1.3)
	end
end)

local shadowGui = Instance.new("ScreenGui")
shadowGui.Name = "ShadowWarning"
shadowGui.Parent = playerGui

local shadowText = Instance.new("TextLabel")
shadowText.Size = UDim2.new(0.5, 0, 0.2, 0)
shadowText.Position = UDim2.new(0.25, 0, 0.4, 0)
shadowText.BackgroundTransparency = 1
shadowText.TextColor3 = Color3.fromRGB(255, 0, 0)
shadowText.TextScaled = true
shadowText.Font = Enum.Font.GothamBlack
shadowText.Visible = false
shadowText.Parent = shadowGui

local function showShadow()
	shadowText.Text = "SHA2!!!!!"
	shadowText.Visible = true
	shadowText.TextTransparency = 1

	for i = 1, 10 do
		shadowText.TextTransparency -= 0.1
		task.wait(0.03)
	end

	task.delay(3, function()
		for i = 1, 10 do
			shadowText.TextTransparency += 0.1
			task.wait(0.03)
		end
		shadowText.Visible = false
	end)
end

local joinGui = Instance.new("ScreenGui")
joinGui.Name = "JoinNotification"
joinGui.Parent = playerGui

local joinText = Instance.new("TextLabel")
joinText.Size = UDim2.new(1, 0, 0, 50)
joinText.Position = UDim2.new(0, 0, 0, -60)
joinText.BackgroundTransparency = 0.3
joinText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
joinText.TextColor3 = Color3.fromRGB(255, 255, 255)
joinText.TextScaled = true
joinText.Font = Enum.Font.GothamBold
joinText.Visible = false
joinText.Parent = joinGui

local function showJoinMessage(plr)
	joinText.Text = plr.Name .. " joined the game"
	joinText.Visible = true
	joinText:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.5, true)

	task.delay(20, function()
		joinText:TweenPosition(UDim2.new(0, 0, 0, -60), "In", "Quad", 0.5, true)
		task.wait(0.5)
		joinText.Visible = false
	end)
end

Players.PlayerAdded:Connect(function(plr)
	if plr ~= player then
		showJoinMessage(plr)
	end
end)

workspace:WaitForChild("SpawnedEntities").ChildAdded:Connect(function(child)
	if child.Name == "SHA_M7" then
		pcall(function()
			child.Center.Global.Scary:Destroy()
		end)

		for _, s in ipairs(child.Center:GetChildren()) do
			if s:IsA("Sound") then
				s:Destroy()
			end
		end

		child.Center.ChildAdded:Connect(function(s)
			if s:IsA("Sound") then
				s:Destroy()
			end
		end)

		child.Center.Global.ChildAdded:Connect(function(s)
			if s:IsA("Sound") then
				s:Destroy()
			end
		end)
	end

	if child.Name == "Shadow2" then
		showShadow()
	end
end)
