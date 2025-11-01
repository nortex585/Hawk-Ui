-- SpaceUI Library v1.0 | by nortex585
-- GitHub: https://github.com/nortex585/Space-UI

local SpaceUI = {}
SpaceUI.__index = SpaceUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

function SpaceUI.new(config)
	local self = setmetatable({}, SpaceUI)
	config = config or {}

	self.Title = config.Title or "Space Hub"
	self.Size = config.Size or UDim2.fromOffset(520, 330)
	self.Position = config.Position or UDim2.fromScale(0.5, 0.5)
	self.Icon = config.Icon or "rbxassetid://88106479644374"

	-- ScreenGui
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "SpaceUI"
	self.ScreenGui.IgnoreGuiInset = true
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.Parent = pg

	-- Window
	self.Window = Instance.new("Frame")
	self.Window.Size = self.Size
	self.Window.Position = self.Position
	self.Window.AnchorPoint = Vector2.new(0.5, 0.5)
	self.Window.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
	self.Window.Parent = self.ScreenGui

	local stroke = Instance.new("UIStroke", self.Window)
	stroke.Thickness = 1.5
	stroke.Transparency = 0.35
	stroke.Color = Color3.fromRGB(60, 60, 66)
	self.Stroke = stroke

	-- Topbar
	self.Topbar = Instance.new("Frame", self.Window)
	self.Topbar.Size = UDim2.new(1, 0, 0, 34)
	self.Topbar.BackgroundColor3 = Color3.fromRGB(28, 28, 32)

	-- Logo
	self.Logo = Instance.new("ImageLabel", self.Topbar)
	self.Logo.Size = UDim2.fromOffset(24, 24)
	self.Logo.Position = UDim2.fromOffset(8, 5)
	self.Logo.BackgroundTransparency = 1
	self.Logo.Image = self.Icon

	-- Title
	self.TitleLabel = Instance.new("TextLabel", self.Topbar)
	self.TitleLabel.Text = self.Title
	self.TitleLabel.Font = Enum.Font.GothamBold
	self.TitleLabel.TextSize = 16
	self.TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
	self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.TitleLabel.Position = UDim2.fromOffset(40, 0)
	self.TitleLabel.Size = UDim2.new(1, -52, 1, 0)
	self.TitleLabel.BackgroundTransparency = 1

	-- Buttons
	self.BtnContainer = Instance.new("Frame", self.Topbar)
	self.BtnContainer.BackgroundTransparency = 1
	self.BtnContainer.Size = UDim2.fromOffset(80, 34)
	self.BtnContainer.Position = UDim2.new(1, -84, 0, 0)

	self.MinimizeBtn = self:_makeTopButton("–", UDim2.fromOffset(4, 5))
	self.CloseBtn = self:_makeTopButton("x", UDim2.fromOffset(44, 5))

	-- Body
	self.Body = Instance.new("Frame", self.Window)
	self.Body.Size = UDim2.new(1, 0, 1, -34)
	self.Body.Position = UDim2.fromOffset(0, 34)
	self.Body.BackgroundTransparency = 1

	-- Sidebar
	self.Sidebar = Instance.new("Frame", self.Body)
	self.Sidebar.Size = UDim2.new(0, 140, 1, 0)
	self.Sidebar.BackgroundColor3 = Color3.fromRGB(28, 28, 32)

	local menuLayout = Instance.new("UIListLayout", self.Sidebar)
	menuLayout.Padding = UDim.new(0, 5)
	menuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	menuLayout.SortOrder = Enum.SortOrder.LayoutOrder

	-- Content
	self.Content = Instance.new("Frame", self.Body)
	self.Content.Size = UDim2.new(1, -148, 1, -16)
	self.Content.Position = UDim2.fromOffset(148, 8)
	self.Content.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	Instance.new("UICorner", self.Content).CornerRadius = UDim.new(0, 10)

	self.Pages = {}
	self.CurrentPage = nil

	self:_enableDrag()
	self:_setupMinimize()

	return self
end

function SpaceUI:_makeTopButton(text, pos)
	local btn = Instance.new("TextButton", self.BtnContainer)
	btn.Size = UDim2.fromOffset(36, 24)
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(220, 220, 225)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

function SpaceUI:_enableDrag()
	local dragging = false
	local dragStart, startPos

	self.Topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = self.Window.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			self.Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

function SpaceUI:_setupMinimize()
	self.MinimizeBtn.MouseButton1Click:Connect(function()
		self.Minimized = not (self.Minimized or false)
		self.Body.Visible = not self.Minimized
		self.Window.BackgroundTransparency = self.Minimized and 1 or 0
		self.Stroke.Thickness = self.Minimized and 0 or 1.5

		if self.Minimized and not self.RestoreBtn then
			self.RestoreBtn = Instance.new("ImageButton")
			self.RestoreBtn.Size = UDim2.fromOffset(40, 40)
			self.RestoreBtn.Position = UDim2.fromScale(0, 0)
			self.RestoreBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
			self.RestoreBtn.Image = self.Icon
			self.RestoreBtn.Visible = true
			self.RestoreBtn.Parent = self.ScreenGui
			Instance.new("UICorner", self.RestoreBtn).CornerRadius = UDim.new(0, 6)

			self.RestoreBtn.MouseButton1Click:Connect(function()
				self.Minimized = false
				self.Body.Visible = true
				self.Window.BackgroundTransparency = 0
				self.Stroke.Thickness = 1.5
				if self.RestoreBtn then
					self.RestoreBtn:Destroy()
					self.RestoreBtn = nil
				end
			end)
		elseif not self.Minimized and self.RestoreBtn then
			self.RestoreBtn:Destroy()
			self.RestoreBtn = nil
		end
	end)

	self.CloseBtn.MouseButton1Click:Connect(function()
		self.ScreenGui:Destroy()
	end)
end

function SpaceUI:AddPage(name)
	local page = Instance.new("Frame", self.Content)
	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.Visible = false
	self.Pages[name] = page

	local btn = Instance.new("TextButton", self.Sidebar)
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
	btn.Text = name
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(230, 230, 235)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	btn.MouseButton1Click:Connect(function()
		self:SwitchPage(name)
	end)

	return page
end

function SpaceUI:SwitchPage(name)
	if self.CurrentPage then
		self.Pages[self.CurrentPage].Visible = false
	end
	if self.Pages[name] then
		self.Pages[name].Visible = true
		self.CurrentPage = name
	end
end

function SpaceUI:CreateButton(parent, text, callback)
	local row = Instance.new("TextButton", parent)
	row.Size = UDim2.new(1, -20, 0, 40)
	row.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
	row.Text = ""
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

	local lbl = Instance.new("TextLabel", row)
	lbl.Text = text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 15
	lbl.TextColor3 = Color3.fromRGB(230, 230, 235)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Position = UDim2.fromOffset(12, 0)
	lbl.Size = UDim2.new(1, -60, 1, 0)
	lbl.BackgroundTransparency = 1

	local dot = Instance.new("Frame", row)
	dot.Size = UDim2.fromOffset(12, 12)
	dot.Position = UDim2.new(1, -22, 0.5, -6)
	dot.BackgroundColor3 = Color3.fromRGB(54, 54, 62)
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

	row.MouseButton1Click:Connect(function()
		if callback then callback() end
		TweenService:Create(dot, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(90, 180, 120)}):Play()
		task.delay(0.25, function()
			TweenService:Create(dot, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(54, 54, 62)}):Play()
		end)
	end)

	return row
end

function SpaceUI:CreateScrollingFrame(parent)
	local scroll = Instance.new("ScrollingFrame", parent)
	scroll.Size = UDim2.fromScale(1, 1)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 6
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

	local layout = Instance.new("UIListLayout", scroll)
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 12)
	end)

	return scroll
end

return SpaceUI
