local SimpleKavo = {}
local TweenService = game:GetService("TweenService") or error("TweenService not available")
local UserInputService = game:GetService("UserInputService") or error("UserInputService not available")
local RunService = game:GetService("RunService") or error("RunService not available")

local KEYBIND_FILE = "keybind.txt"
local DEFAULT_KEYBIND = Enum.KeyCode.F1

local function saveKeybind(keyCode)
	local ok, err = pcall(writefile, KEYBIND_FILE, keyCode.Name)
	if not ok then
		warn("[SimpleKavo] Could not save keybind: " .. tostring(err))
	end
end

local function loadKeybind()
	local ok, data = pcall(readfile, KEYBIND_FILE)
	if ok and type(data) == "string" and data ~= "" then
		local key = Enum.KeyCode[data:match("^%s*(.-)%s*$")]
		if key then return key end
	end
	return DEFAULT_KEYBIND
end

local Themes = {
	DarkTheme = {
		Primary       = Color3.fromRGB(255, 255, 255),
		Secondary     = Color3.fromRGB(255, 255, 255),
		Window1       = Color3.fromRGB(0, 0, 0),
		Window2       = Color3.fromRGB(0, 0, 0),
		Window3       = Color3.fromRGB(0, 0, 0),
		Button1       = Color3.fromRGB(20, 20, 22),
		Button2       = Color3.fromRGB(78, 78, 78),
		Button3       = Color3.fromRGB(110, 110, 110),
		Stroke        = Color3.fromRGB(45, 45, 48),
		StrokeHover   = Color3.fromRGB(75, 75, 78),
		TextPrimary   = Color3.fromRGB(255, 255, 255),
		TextDim       = Color3.fromRGB(140, 140, 145),
		SchemeColor   = Color3.fromRGB(188, 188, 188),
	},
	HalloweenTheme = {
		Primary       = Color3.fromRGB(245, 73, 39),
		Secondary     = Color3.fromRGB(233, 150, 38),
		Window1       = Color3.fromRGB(14, 10, 8),
		Window2       = Color3.fromRGB(8, 6, 4),
		Window3       = Color3.fromRGB(11, 8, 6),
		Button1       = Color3.fromRGB(18, 12, 9),
		Button2       = Color3.fromRGB(26, 18, 13),
		Button3       = Color3.fromRGB(38, 26, 19),
		Stroke        = Color3.fromRGB(55, 35, 25),
		StrokeHover   = Color3.fromRGB(90, 55, 35),
		TextPrimary   = Color3.fromRGB(255, 255, 255),
		TextDim       = Color3.fromRGB(160, 120, 100),
		SchemeColor   = Color3.fromRGB(245, 73, 39),
	},
	BloodTheme = {
		Primary       = Color3.fromRGB(227, 27, 27),
		Secondary     = Color3.fromRGB(180, 10, 60),
		Window1       = Color3.fromRGB(11, 5, 5),
		Window2       = Color3.fromRGB(6, 2, 2),
		Window3       = Color3.fromRGB(9, 4, 4),
		Button1       = Color3.fromRGB(16, 8, 8),
		Button2       = Color3.fromRGB(24, 12, 12),
		Button3       = Color3.fromRGB(36, 18, 18),
		Stroke        = Color3.fromRGB(55, 20, 20),
		StrokeHover   = Color3.fromRGB(90, 30, 30),
		TextPrimary   = Color3.fromRGB(255, 255, 255),
		TextDim       = Color3.fromRGB(160, 100, 100),
		SchemeColor   = Color3.fromRGB(227, 27, 27),
	},
	DefaultTheme = {
		Primary       = Color3.fromRGB(91, 77, 249),
		Secondary     = Color3.fromRGB(130, 76, 247),
		Window1       = Color3.fromRGB(20, 20, 23),
		Window2       = Color3.fromRGB(12, 12, 15),
		Window3       = Color3.fromRGB(15, 15, 18),
		Button1       = Color3.fromRGB(18, 18, 21),
		Button2       = Color3.fromRGB(28, 28, 31),
		Button3       = Color3.fromRGB(42, 42, 45),
		Stroke        = Color3.fromRGB(50, 50, 53),
		StrokeHover   = Color3.fromRGB(80, 80, 84),
		TextPrimary   = Color3.fromRGB(255, 255, 255),
		TextDim       = Color3.fromRGB(130, 130, 138),
		SchemeColor   = Color3.fromRGB(91, 77, 249),
	},
}

local function Tween(object, properties, duration, style)
	local easingStyle = style == 2 and Enum.EasingStyle.Linear or Enum.EasingStyle.Exponential
	local tweenInfo = TweenInfo.new(duration or 0.2, easingStyle, Enum.EasingDirection.Out)
	local t = TweenService:Create(object, tweenInfo, properties)
	t:Play()
	return t
end

local function StringToKeyCode(str)
	if typeof(str) == "EnumItem" then return str end
	if type(str) ~= "string" then return Enum.KeyCode.Unknown end
	local alias = {
		["ALT"] = "LeftAlt", ["CTRL"] = "LeftControl",
		["CONTROL"] = "LeftControl", ["SHIFT"] = "LeftShift",
	}
	local upper = string.upper(str)
	if alias[upper] then str = alias[upper] end
	return Enum.KeyCode[str] or Enum.KeyCode.Unknown
end

local function polarToCart(r, theta)
	return r * math.cos(theta), r * math.sin(theta)
end

local function cartToPolar(x, y)
	return math.sqrt((x^2) + (y^2)), math.atan2(y, x)
end

function SimpleKavo:DraggingEnabled(frame, parent)
	parent = parent or frame
	local dragging = false
	local dragInput, mousePos, framePos
	local targetPos
	local aCon

	local function startDrag(input)
		dragging = true
		mousePos = input.Position
		framePos = parent.Position
		targetPos = parent.Position

		aCon = RunService.RenderStepped:Connect(function(dt)
			parent.Position = parent.Position:lerp(targetPos, 1 - 1e-12 ^ dt)
		end)

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if aCon then aCon:Disconnect() end
				Tween(parent, { Position = targetPos }, 0.2, 2)
			end
		end)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			startDrag(input)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging and
			(input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - mousePos
			targetPos = UDim2.new(
				framePos.X.Scale, framePos.X.Offset + delta.X,
				framePos.Y.Scale, framePos.Y.Offset + delta.Y
			)
		end
	end)
end

local function CreatePickerWindow(T, pickerName, initialColor, screenGui, onColorChanged)
	local hue, sat, val = initialColor:ToHSV()
	local red, green, blue = initialColor.R * 255, initialColor.G * 255, initialColor.B * 255
	local chromaEnabled = false
	local chromaCon = nil
	local chromaSpeed = 0.1
	local pickerMoving = false

	local PickerGui = Instance.new("Frame")
	PickerGui.Name = "ColorPickerWindow"
	PickerGui.BackgroundColor3 = T.Window2
	PickerGui.BorderSizePixel = 0
	PickerGui.Size = UDim2.fromOffset(300, 300)
	PickerGui.Position = UDim2.fromOffset(200, 150)
	PickerGui.ZIndex = 500
	PickerGui.Parent = screenGui

	local PickerScale = Instance.new("UIScale")
	PickerScale.Scale = 1
	PickerScale.Parent = PickerGui

	local PickerStroke = Instance.new("UIStroke")
	PickerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	PickerStroke.Color = T.Stroke
	PickerStroke.LineJoinMode = Enum.LineJoinMode.Round
	PickerStroke.Thickness = 1
	PickerStroke.Parent = PickerGui

	local PickerShadow = Instance.new("ImageLabel")
	PickerShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	PickerShadow.BackgroundTransparency = 1
	PickerShadow.BorderSizePixel = 0
	PickerShadow.Image = "rbxassetid://7331400934"
	PickerShadow.ImageColor3 = Color3.fromRGB(0, 0, 5)
	PickerShadow.Position = UDim2.fromScale(0.5, 0.5)
	PickerShadow.ScaleType = Enum.ScaleType.Slice
	PickerShadow.Size = UDim2.new(1, 50, 1, 50)
	PickerShadow.SliceCenter = Rect.new(40, 40, 260, 260)
	PickerShadow.ZIndex = 499
	PickerShadow.Parent = PickerGui

	local PickerTrim = Instance.new("Frame")
	PickerTrim.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	PickerTrim.BorderSizePixel = 0
	PickerTrim.Position = UDim2.fromOffset(0, -1)
	PickerTrim.Size = UDim2.new(1, 0, 0, 1)
	PickerTrim.ZIndex = 510
	PickerTrim.Parent = PickerGui

	local PickerTrimGrad = Instance.new("UIGradient")
	PickerTrimGrad.Color = ColorSequence.new(T.Primary, T.Secondary)
	PickerTrimGrad.Parent = PickerTrim

	local PickerHeader = Instance.new("Frame")
	PickerHeader.Name = "Header"
	PickerHeader.BackgroundColor3 = T.Window1
	PickerHeader.BorderSizePixel = 0
	PickerHeader.Size = UDim2.new(1, 0, 0, 26)
	PickerHeader.ZIndex = 501
	PickerHeader.ClipsDescendants = true
	PickerHeader.Parent = PickerGui

	local PickerHeaderStroke = Instance.new("UIStroke")
	PickerHeaderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	PickerHeaderStroke.Color = T.Stroke
	PickerHeaderStroke.LineJoinMode = Enum.LineJoinMode.Round
	PickerHeaderStroke.Thickness = 1
	PickerHeaderStroke.Parent = PickerHeader

	local PickerIcon = Instance.new("ImageLabel")
	PickerIcon.BackgroundTransparency = 1
	PickerIcon.BorderSizePixel = 0
	PickerIcon.Image = "rbxassetid://9658988382"
	PickerIcon.ImageColor3 = T.Primary
	PickerIcon.Position = UDim2.fromOffset(2, 2)
	PickerIcon.Size = UDim2.fromOffset(22, 22)
	PickerIcon.ZIndex = 502
	PickerIcon.Parent = PickerHeader

	local PickerTitle = Instance.new("TextLabel")
	PickerTitle.BackgroundTransparency = 1
	PickerTitle.Font = Enum.Font.RobotoCondensed
	PickerTitle.Position = UDim2.fromOffset(24, 0)
	PickerTitle.Size = UDim2.new(1, -50, 1, 0)
	PickerTitle.Text = pickerName
	PickerTitle.TextColor3 = T.TextPrimary
	PickerTitle.TextSize = 17
	PickerTitle.TextXAlignment = Enum.TextXAlignment.Left
	PickerTitle.TextYAlignment = Enum.TextYAlignment.Center
	PickerTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	PickerTitle.TextStrokeTransparency = 0.8
	PickerTitle.ZIndex = 502
	PickerTitle.Parent = PickerHeader

	local PickerTitlePad = Instance.new("UIPadding")
	PickerTitlePad.PaddingLeft = UDim.new(0, 4)
	PickerTitlePad.Parent = PickerTitle

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.AnchorPoint = Vector2.new(1, 0)
	CloseBtn.AutoButtonColor = false
	CloseBtn.BackgroundColor3 = T.Button1
	CloseBtn.BorderSizePixel = 0
	CloseBtn.Position = UDim2.new(1, -3, 0, 2)
	CloseBtn.Size = UDim2.fromOffset(20, 20)
	CloseBtn.Text = ""
	CloseBtn.ZIndex = 502
	CloseBtn.Parent = PickerHeader

	local CloseBtnCorner = Instance.new("UICorner")
	CloseBtnCorner.CornerRadius = UDim.new(0, 2)
	CloseBtnCorner.Parent = CloseBtn

	local CloseBtnStroke = Instance.new("UIStroke")
	CloseBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	CloseBtnStroke.Color = T.Stroke
	CloseBtnStroke.LineJoinMode = Enum.LineJoinMode.Round
	CloseBtnStroke.Thickness = 1
	CloseBtnStroke.Parent = CloseBtn

	local CloseBtnIcon = Instance.new("ImageLabel")
	CloseBtnIcon.BackgroundTransparency = 1
	CloseBtnIcon.BorderSizePixel = 0
	CloseBtnIcon.Image = "rbxassetid://9801460300"
	CloseBtnIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	CloseBtnIcon.Size = UDim2.fromScale(1, 1)
	CloseBtnIcon.ZIndex = 502
	CloseBtnIcon.Parent = CloseBtn

	local CloseBtnIconGrad = Instance.new("UIGradient")
	CloseBtnIconGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
	CloseBtnIconGrad.Rotation = 90
	CloseBtnIconGrad.Parent = CloseBtnIcon

	local Region = Instance.new("Frame")
	Region.BackgroundColor3 = T.Window2
	Region.BorderSizePixel = 0
	Region.ClipsDescendants = true
	Region.Position = UDim2.fromOffset(0, 27)
	Region.Size = UDim2.new(1, 0, 1, -27)
	Region.ZIndex = 501
	Region.Parent = PickerGui

	local RegionStroke = Instance.new("UIStroke")
	RegionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	RegionStroke.Color = T.Stroke
	RegionStroke.LineJoinMode = Enum.LineJoinMode.Round
	RegionStroke.Thickness = 1
	RegionStroke.Parent = Region

	local PickerRegion = Instance.new("Frame")
	PickerRegion.BackgroundColor3 = T.Window2
	PickerRegion.BorderSizePixel = 0
	PickerRegion.ClipsDescendants = true
	PickerRegion.Position = UDim2.fromOffset(2, 2)
	PickerRegion.Size = UDim2.new(1, -4, 0.75, -4)
	PickerRegion.ZIndex = 502
	PickerRegion.Parent = Region

	local PickerRegionStroke = Instance.new("UIStroke")
	PickerRegionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	PickerRegionStroke.Color = T.Stroke
	PickerRegionStroke.LineJoinMode = Enum.LineJoinMode.Round
	PickerRegionStroke.Thickness = 1
	PickerRegionStroke.Parent = PickerRegion

	local ColorWheel = Instance.new("ImageLabel")
	ColorWheel.AnchorPoint = Vector2.new(0.5, 0.5)
	ColorWheel.BackgroundTransparency = 1
	ColorWheel.Image = "rbxassetid://9801454501"
	ColorWheel.Position = UDim2.fromScale(0.5, 0.5)
	ColorWheel.Size = UDim2.fromScale(0.7, 0.7)
	ColorWheel.SizeConstraint = Enum.SizeConstraint.RelativeYY
	ColorWheel.ZIndex = 504
	ColorWheel.Parent = PickerRegion

	local WheelOutline = Instance.new("Frame")
	WheelOutline.BackgroundColor3 = T.Stroke
	WheelOutline.BorderSizePixel = 0
	WheelOutline.Position = UDim2.fromOffset(1, 1)
	WheelOutline.Size = UDim2.new(1, -2, 1, -2)
	WheelOutline.SizeConstraint = Enum.SizeConstraint.RelativeYY
	WheelOutline.ZIndex = 503
	WheelOutline.Parent = ColorWheel

	local WheelOutlineCorner = Instance.new("UICorner")
	WheelOutlineCorner.CornerRadius = UDim.new(1, 0)
	WheelOutlineCorner.Parent = WheelOutline

	local WheelOutlineStroke = Instance.new("UIStroke")
	WheelOutlineStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	WheelOutlineStroke.Color = T.Stroke
	WheelOutlineStroke.LineJoinMode = Enum.LineJoinMode.Round
	WheelOutlineStroke.Thickness = 2
	WheelOutlineStroke.Parent = WheelOutline

	local PickerCursor = Instance.new("Frame")
	PickerCursor.AnchorPoint = Vector2.new(0.5, 0.5)
	PickerCursor.BackgroundTransparency = 1
	PickerCursor.Size = UDim2.fromOffset(8, 8)
	PickerCursor.ZIndex = 506
	PickerCursor.Parent = ColorWheel

	do
		local radius = sat / 2
		local theta = (hue * (math.pi * 2)) - (math.pi * 2)
		local cx, cy = radius * math.cos(theta), radius * math.sin(theta)
		PickerCursor.Position = UDim2.fromScale(cx + 0.5, cy + 0.5)
	end

	local PickerCursorCorner = Instance.new("UICorner")
	PickerCursorCorner.CornerRadius = UDim.new(1, 0)
	PickerCursorCorner.Parent = PickerCursor

	local PickerCursorStroke = Instance.new("UIStroke")
	PickerCursorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	PickerCursorStroke.Color = Color3.fromRGB(255, 255, 255)
	PickerCursorStroke.LineJoinMode = Enum.LineJoinMode.Round
	PickerCursorStroke.Thickness = 1
	PickerCursorStroke.Parent = PickerCursor

	local PickerCursorOuter = Instance.new("Frame")
	PickerCursorOuter.BackgroundTransparency = 1
	PickerCursorOuter.Position = UDim2.fromOffset(-1, -1)
	PickerCursorOuter.Size = UDim2.fromOffset(10, 10)
	PickerCursorOuter.ZIndex = 506
	PickerCursorOuter.Parent = PickerCursor

	local PickerCursorOuterCorner = Instance.new("UICorner")
	PickerCursorOuterCorner.CornerRadius = UDim.new(1, 0)
	PickerCursorOuterCorner.Parent = PickerCursorOuter

	local PickerCursorOuterStroke = Instance.new("UIStroke")
	PickerCursorOuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	PickerCursorOuterStroke.Color = Color3.fromRGB(0, 0, 5)
	PickerCursorOuterStroke.LineJoinMode = Enum.LineJoinMode.Round
	PickerCursorOuterStroke.Thickness = 1
	PickerCursorOuterStroke.Parent = PickerCursorOuter

	local ValSlider = Instance.new("Frame")
	ValSlider.AnchorPoint = Vector2.new(0.5, 1)
	ValSlider.BackgroundTransparency = 1
	ValSlider.Position = UDim2.fromScale(0.5, 1)
	ValSlider.Size = UDim2.new(0.8, 0, 0, 24)
	ValSlider.ZIndex = 503
	ValSlider.Parent = PickerRegion

	local ValSliderContainer = Instance.new("Frame")
	ValSliderContainer.BackgroundColor3 = Color3.fromHSV(hue, sat, 1)
	ValSliderContainer.Position = UDim2.fromOffset(3, 6)
	ValSliderContainer.Size = UDim2.new(1, -6, 0, 12)
	ValSliderContainer.ZIndex = 503
	ValSliderContainer.Parent = ValSlider

	local ValSliderContainerCorner = Instance.new("UICorner")
	ValSliderContainerCorner.CornerRadius = UDim.new(0, 2)
	ValSliderContainerCorner.Parent = ValSliderContainer

	local ValSliderContainerStroke = Instance.new("UIStroke")
	ValSliderContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ValSliderContainerStroke.Color = T.Stroke
	ValSliderContainerStroke.LineJoinMode = Enum.LineJoinMode.Round
	ValSliderContainerStroke.Thickness = 1
	ValSliderContainerStroke.Parent = ValSliderContainer

	local ValGradientFrame = Instance.new("Frame")
	ValGradientFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ValGradientFrame.BorderSizePixel = 0
	ValGradientFrame.Size = UDim2.fromScale(1, 1)
	ValGradientFrame.ZIndex = 504
	ValGradientFrame.Parent = ValSliderContainer

	local ValGradient = Instance.new("UIGradient")
	ValGradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
	ValGradient.Rotation = 180
	ValGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	ValGradient.Parent = ValGradientFrame

	local ValGradientCorner = Instance.new("UICorner")
	ValGradientCorner.CornerRadius = UDim.new(0, 2)
	ValGradientCorner.Parent = ValGradientFrame

	local ValCursor = Instance.new("Frame")
	ValCursor.AnchorPoint = Vector2.new(0.5, 0)
	ValCursor.BackgroundTransparency = 1
	ValCursor.Position = UDim2.fromScale(val, 0)
	ValCursor.Size = UDim2.fromOffset(4, 12)
	ValCursor.ZIndex = 504
	ValCursor.Parent = ValSliderContainer

	local ValCursorCorner = Instance.new("UICorner")
	ValCursorCorner.CornerRadius = UDim.new(0, 2)
	ValCursorCorner.Parent = ValCursor

	local ValCursorStroke = Instance.new("UIStroke")
	ValCursorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ValCursorStroke.Color = Color3.fromRGB(255, 255, 255)
	ValCursorStroke.LineJoinMode = Enum.LineJoinMode.Round
	ValCursorStroke.Thickness = 1
	ValCursorStroke.Parent = ValCursor

	local ValCursorOuter = Instance.new("Frame")
	ValCursorOuter.AnchorPoint = Vector2.new(0.5, 0.5)
	ValCursorOuter.BackgroundTransparency = 1
	ValCursorOuter.Position = UDim2.fromScale(0.5, 0.5)
	ValCursorOuter.Size = UDim2.new(1, 2, 1, 2)
	ValCursorOuter.ZIndex = 504
	ValCursorOuter.Parent = ValCursor

	local ValCursorOuterCorner = Instance.new("UICorner")
	ValCursorOuterCorner.CornerRadius = UDim.new(0, 2)
	ValCursorOuterCorner.Parent = ValCursorOuter

	local ValCursorOuterStroke = Instance.new("UIStroke")
	ValCursorOuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ValCursorOuterStroke.Color = Color3.fromRGB(0, 0, 5)
	ValCursorOuterStroke.LineJoinMode = Enum.LineJoinMode.Round
	ValCursorOuterStroke.Thickness = 1
	ValCursorOuterStroke.Parent = ValCursorOuter

	local ChromaBtn = Instance.new("TextButton")
	ChromaBtn.Active = true
	ChromaBtn.AnchorPoint = Vector2.new(0, 1)
	ChromaBtn.AutoButtonColor = false
	ChromaBtn.BackgroundColor3 = T.Button1
	ChromaBtn.Position = UDim2.new(0, 8, 1, -4)
	ChromaBtn.Size = UDim2.fromOffset(16, 16)
	ChromaBtn.Text = ""
	ChromaBtn.ZIndex = 503
	ChromaBtn.Parent = PickerRegion

	local ChromaBtnCorner = Instance.new("UICorner")
	ChromaBtnCorner.CornerRadius = UDim.new(0, 2)
	ChromaBtnCorner.Parent = ChromaBtn

	local ChromaBtnStroke = Instance.new("UIStroke")
	ChromaBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ChromaBtnStroke.Color = T.Stroke
	ChromaBtnStroke.LineJoinMode = Enum.LineJoinMode.Round
	ChromaBtnStroke.Thickness = 1
	ChromaBtnStroke.Parent = ChromaBtn

	local ChromaBtnIcon = Instance.new("ImageLabel")
	ChromaBtnIcon.BackgroundTransparency = 1
	ChromaBtnIcon.BorderSizePixel = 0
	ChromaBtnIcon.Image = "rbxassetid://9841673199"
	ChromaBtnIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	ChromaBtnIcon.Rotation = 0
	ChromaBtnIcon.Size = UDim2.fromScale(1, 1)
	ChromaBtnIcon.ZIndex = 503
	ChromaBtnIcon.Parent = ChromaBtn

	local InputRegion = Instance.new("Frame")
	InputRegion.BackgroundColor3 = T.Window2
	InputRegion.BorderSizePixel = 0
	InputRegion.ClipsDescendants = true
	InputRegion.Position = UDim2.new(0, 2, 0.75, 2)
	InputRegion.Size = UDim2.new(1, -4, 0.25, -4)
	InputRegion.ZIndex = 502
	InputRegion.Parent = Region

	local InputRegionStroke = Instance.new("UIStroke")
	InputRegionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	InputRegionStroke.Color = T.Stroke
	InputRegionStroke.LineJoinMode = Enum.LineJoinMode.Round
	InputRegionStroke.Thickness = 1
	InputRegionStroke.Parent = InputRegion

	local function makeRGBSlider(yOffset, labelText, initVal)
		local SliderFrame = Instance.new("Frame")
		SliderFrame.BackgroundTransparency = 1
		SliderFrame.Position = UDim2.fromOffset(0, yOffset)
		SliderFrame.Size = UDim2.new(1, 0, 0, 24)
		SliderFrame.ZIndex = 503
		SliderFrame.Parent = InputRegion

		local Container = Instance.new("Frame")
		Container.BackgroundColor3 = T.Button1
		Container.Position = UDim2.fromOffset(3, 6)
		Container.Size = UDim2.new(1, -6, 0, 12)
		Container.ZIndex = 503
		Container.Parent = SliderFrame

		local ContainerCorner = Instance.new("UICorner")
		ContainerCorner.CornerRadius = UDim.new(0, 2)
		ContainerCorner.Parent = Container

		local ContainerStroke = Instance.new("UIStroke")
		ContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		ContainerStroke.Color = T.Stroke
		ContainerStroke.LineJoinMode = Enum.LineJoinMode.Round
		ContainerStroke.Thickness = 1
		ContainerStroke.Parent = Container

		local Fill = Instance.new("Frame")
		Fill.BackgroundColor3 = T.Primary
		Fill.BackgroundTransparency = 0.6
		Fill.BorderSizePixel = 0
		Fill.Size = UDim2.fromScale(initVal / 255, 1)
		Fill.ZIndex = 504
		Fill.Parent = Container

		local FillCorner = Instance.new("UICorner")
		FillCorner.CornerRadius = UDim.new(0, 2)
		FillCorner.Parent = Fill

		local FillGrad = Instance.new("UIGradient")
		FillGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
		FillGrad.Rotation = 90
		FillGrad.Parent = Fill

		local TitleLabel = Instance.new("TextLabel")
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.Font = Enum.Font.SourceSans
		TitleLabel.Size = UDim2.new(1, 0, 1, -1)
		TitleLabel.Text = labelText
		TitleLabel.TextColor3 = T.TextPrimary
		TitleLabel.TextSize = 14
		TitleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		TitleLabel.TextStrokeTransparency = 0.8
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
		TitleLabel.ZIndex = 504
		TitleLabel.Parent = SliderFrame

		local TitlePad = Instance.new("UIPadding")
		TitlePad.PaddingLeft = UDim.new(0, 6)
		TitlePad.Parent = TitleLabel

		local ValLabel = Instance.new("TextLabel")
		ValLabel.BackgroundTransparency = 1
		ValLabel.Font = Enum.Font.SourceSans
		ValLabel.Size = UDim2.new(1, 0, 1, -1)
		ValLabel.Text = tostring(math.floor(initVal))
		ValLabel.TextColor3 = T.TextPrimary
		ValLabel.TextSize = 14
		ValLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		ValLabel.TextStrokeTransparency = 0.8
		ValLabel.TextXAlignment = Enum.TextXAlignment.Right
		ValLabel.TextYAlignment = Enum.TextYAlignment.Center
		ValLabel.ZIndex = 504
		ValLabel.Parent = SliderFrame

		local ValPad = Instance.new("UIPadding")
		ValPad.PaddingRight = UDim.new(0, 6)
		ValPad.Parent = ValLabel

		return Container, Fill, ValLabel
	end

	local redContainer, redFill, redVal = makeRGBSlider(-1, "red", red)
	local greenContainer, greenFill, greenVal = makeRGBSlider(19, "green", green)
	local blueContainer, blueFill, blueVal = makeRGBSlider(39, "blue", blue)

	local function displayHSV(moveCursor)
		local color = Color3.fromHSV(hue, sat, val)
		red = color.R * 255
		green = color.G * 255
		blue = color.B * 255

		ValSliderContainer.BackgroundColor3 = Color3.fromHSV(hue, sat, 1)
		Tween(redFill, { Size = UDim2.fromScale(red / 255, 1) }, 0.3, 1)
		Tween(greenFill, { Size = UDim2.fromScale(green / 255, 1) }, 0.3, 1)
		Tween(blueFill, { Size = UDim2.fromScale(blue / 255, 1) }, 0.3, 1)

		redVal.Text = tostring(math.floor(red))
		greenVal.Text = tostring(math.floor(green))
		blueVal.Text = tostring(math.floor(blue))

		if moveCursor then
			local radius = sat / 2
			local theta = (hue * (math.pi * 2)) - (math.pi * 2)
			local cx, cy = radius * math.cos(theta), radius * math.sin(theta)
			Tween(ValCursor, { Position = UDim2.fromScale(val, 0) }, 0.3, 1)
			Tween(PickerCursor, { Position = UDim2.fromScale(cx + 0.5, cy + 0.5) }, 0.3, 1)
		end

		if onColorChanged then
			onColorChanged(color)
		end
	end

	local function displayRGB()
		local color = Color3.fromRGB(red, green, blue)
		hue, sat, val = color:ToHSV()

		local radius = sat / 2
		local theta = (hue * (math.pi * 2)) - (math.pi * 2)
		local cx, cy = radius * math.cos(theta), radius * math.sin(theta)

		ValSliderContainer.BackgroundColor3 = Color3.fromHSV(hue, sat, 1)
		Tween(ValCursor, { Position = UDim2.fromScale(val, 0) }, 0.3, 1)
		Tween(PickerCursor, { Position = UDim2.fromScale(cx + 0.5, cy + 0.5) }, 0.3, 1)

		if onColorChanged then
			onColorChanged(color)
		end
	end

	local function setupRGBSlider(container, fill, valLabel, getChannel, setChannel)
		local dcon, acon
		local targetSize

		container.InputBegan:Connect(function(io)
			if io.UserInputType == Enum.UserInputType.MouseButton1 then
				local containerPos = container.AbsolutePosition
				local containerWidth = container.AbsoluteSize.X
				local rawValue = math.clamp((io.Position.X - containerPos.X) / containerWidth, 0, 1)
				local newVal = math.floor(rawValue * 255)
				targetSize = UDim2.fromScale(rawValue, 1)
				valLabel.Text = tostring(newVal)
				setChannel(newVal)
				displayRGB()

				acon = RunService.RenderStepped:Connect(function(dt)
					fill.Size = fill.Size:lerp(targetSize, 1 - 1e-12 ^ dt)
				end)

				dcon = UserInputService.InputChanged:Connect(function(io2)
					if io2.UserInputType == Enum.UserInputType.MouseMovement then
						local rv = math.clamp((io2.Position.X - containerPos.X) / containerWidth, 0, 1)
						local nv = math.floor(rv * 255)
						targetSize = UDim2.fromScale(rv, 1)
						valLabel.Text = tostring(nv)
						setChannel(nv)
						displayRGB()
					end
				end)
			end
		end)

		container.InputEnded:Connect(function(io)
			if io.UserInputType == Enum.UserInputType.MouseButton1 then
				if dcon then dcon:Disconnect() end
				if acon then acon:Disconnect() end
				Tween(fill, { Size = targetSize }, 0.2, 1)
			end
		end)

		container.MouseEnter:Connect(function()
			Tween(container, { BackgroundColor3 = T.Button2 }, 0.2, 1)
			Tween(container:FindFirstChildOfClass("UIStroke"), { Color = T.StrokeHover }, 0.2, 1)
		end)
		container.MouseLeave:Connect(function()
			Tween(container, { BackgroundColor3 = T.Button1 }, 0.2, 1)
			Tween(container:FindFirstChildOfClass("UIStroke"), { Color = T.Stroke }, 0.2, 1)
		end)
	end

	setupRGBSlider(redContainer, redFill, redVal,
		function() return red end,
		function(v) red = v end)
	setupRGBSlider(greenContainer, greenFill, greenVal,
		function() return green end,
		function(v) green = v end)
	setupRGBSlider(blueContainer, blueFill, blueVal,
		function() return blue end,
		function(v) blue = v end)

	do
		local dcon, acon
		local targetPos

		ValSliderContainer.InputBegan:Connect(function(io)
			if io.UserInputType == Enum.UserInputType.MouseButton1 then
				local containerPos = ValSliderContainer.AbsolutePosition
				local containerWidth = ValSliderContainer.AbsoluteSize.X
				local rawValue = math.clamp((io.Position.X - containerPos.X) / containerWidth, 0, 1)
				targetPos = UDim2.fromScale(rawValue, 0)
				val = rawValue
				displayHSV(false)

				acon = RunService.RenderStepped:Connect(function(dt)
					ValCursor.Position = ValCursor.Position:lerp(targetPos, 1 - 1e-12 ^ dt)
				end)

				dcon = UserInputService.InputChanged:Connect(function(io2)
					if io2.UserInputType == Enum.UserInputType.MouseMovement then
						local rv = math.clamp((io2.Position.X - containerPos.X) / containerWidth, 0, 1)
						val = rv
						displayHSV(false)
					end
				end)
			end
		end)

		ValSliderContainer.InputEnded:Connect(function(io)
			if io.UserInputType == Enum.UserInputType.MouseButton1 then
				if dcon then dcon:Disconnect() end
				if acon then acon:Disconnect() end
				Tween(ValCursor, { Position = targetPos }, 0.2, 1)
			end
		end)

		ValSliderContainer.MouseEnter:Connect(function()
			Tween(ValSliderContainerStroke, { Color = T.StrokeHover }, 0.2, 1)
			Tween(ValCursorStroke, { Color = T.Primary }, 0.2, 1)
		end)
		ValSliderContainer.MouseLeave:Connect(function()
			Tween(ValSliderContainerStroke, { Color = T.Stroke }, 0.2, 1)
			Tween(ValCursorStroke, { Color = Color3.fromRGB(255, 255, 255) }, 0.2, 1)
		end)
	end

	do
		local dcon, acon
		local targetPos
		local center = Vector2.new(0.5, 0.5)

		ColorWheel.InputBegan:Connect(function(io)
			if io.UserInputType == Enum.UserInputType.MouseButton1 then
				pickerMoving = true
				local pickerPos = ColorWheel.AbsolutePosition
				local pickerWidth = ColorWheel.AbsoluteSize.X

				local function computePos(position)
					local x = (position.X - pickerPos.X) / pickerWidth
					local y = (position.Y - pickerPos.Y) / pickerWidth
					local radius, theta = cartToPolar(x - 0.5, y - 0.5)
					local centerMag = (Vector2.new(x, y) - center).Magnitude
					if centerMag > 0.5 then
						x, y = polarToCart(radius - (centerMag - 0.5), theta)
						x += 0.5
						y += 0.5
						centerMag = (Vector2.new(x, y) - center).Magnitude
					end
					return x, y, ((theta / math.pi + 2) / 2) % 1, math.clamp(centerMag * 2, 0, 1)
				end

				local x, y, h, s = computePos(io.Position)
				targetPos = UDim2.fromScale(x, y)
				hue = h
				sat = s
				displayHSV(false)

				if acon then acon:Disconnect() end
				acon = RunService.RenderStepped:Connect(function(dt)
					PickerCursor.Position = PickerCursor.Position:lerp(targetPos, 1 - 1e-12 ^ dt)
				end)

				if dcon then dcon:Disconnect() end
				dcon = UserInputService.InputChanged:Connect(function(io2)
					if io2.UserInputType == Enum.UserInputType.MouseMovement then
						local x2, y2, h2, s2 = computePos(io2.Position)
						targetPos = UDim2.fromScale(x2, y2)
						hue = h2
						sat = s2
						displayHSV(false)
					end
				end)
			end
		end)

		ColorWheel.InputEnded:Connect(function(io)
			if io.UserInputType == Enum.UserInputType.MouseButton1 then
				pickerMoving = false
				if dcon then dcon:Disconnect() end
				if acon then acon:Disconnect() end
				Tween(PickerCursor, { Position = targetPos }, 0.2, 1)
			end
		end)
	end

	ChromaBtn.MouseButton1Click:Connect(function()
		chromaEnabled = not chromaEnabled
		if chromaEnabled then
			Tween(ChromaBtn, { BackgroundColor3 = T.Button2 }, 0.2, 1)
			Tween(ChromaBtnIcon, { Rotation = 360 }, 0.5, 1)
			ChromaBtnIcon.Image = "rbxassetid://9840988620"
			if chromaCon then chromaCon:Disconnect() end
			chromaCon = RunService.RenderStepped:Connect(function(dt)
				if pickerMoving then return end
				dt = dt * chromaSpeed
				hue = (hue + dt) % 1
				displayHSV(true)
			end)
		else
			Tween(ChromaBtn, { BackgroundColor3 = T.Button1 }, 0.2, 1)
			Tween(ChromaBtnIcon, { Rotation = 0 }, 0.5, 1)
			ChromaBtnIcon.Image = "rbxassetid://9841673199"
			if chromaCon then chromaCon:Disconnect() end
			chromaCon = nil
		end
	end)

	ChromaBtn.MouseEnter:Connect(function()
		if chromaEnabled then
			Tween(ChromaBtn, { BackgroundColor3 = T.Button3 }, 0.2, 1)
		else
			Tween(ChromaBtn, { BackgroundColor3 = T.Button2 }, 0.2, 1)
		end
		Tween(ChromaBtnStroke, { Color = T.StrokeHover }, 0.2, 1)
	end)
	ChromaBtn.MouseLeave:Connect(function()
		if chromaEnabled then
			Tween(ChromaBtn, { BackgroundColor3 = T.Button2 }, 0.2, 1)
		else
			Tween(ChromaBtn, { BackgroundColor3 = T.Button1 }, 0.2, 1)
		end
		Tween(ChromaBtnStroke, { Color = T.Stroke }, 0.2, 1)
	end)

	CloseBtn.MouseEnter:Connect(function()
		Tween(CloseBtn, { BackgroundColor3 = T.Button2 }, 0.2, 1)
		Tween(CloseBtnStroke, { Color = T.StrokeHover }, 0.2, 1)
	end)
	CloseBtn.MouseLeave:Connect(function()
		Tween(CloseBtn, { BackgroundColor3 = T.Button1 }, 0.2, 1)
		Tween(CloseBtnStroke, { Color = T.Stroke }, 0.2, 1)
	end)

	SimpleKavo:DraggingEnabled(PickerHeader, PickerGui)

	local pickerObj = {}
	pickerObj.guiRef = PickerGui

	pickerObj.destroy = function()
		if chromaCon then chromaCon:Disconnect() end
		local animCon
		task.spawn(function()
			local backgroundTransparency = {}
			local imageTransparency = {}
			local textTransparency = {}
			local transparency = {}
			local s = {
				Frame = { backgroundTransparency },
				ImageLabel = { backgroundTransparency, imageTransparency },
				ImageButton = { backgroundTransparency, imageTransparency },
				TextLabel = { backgroundTransparency, textTransparency },
				TextButton = { backgroundTransparency, textTransparency },
				UIStroke = { transparency },
			}
			local d = PickerGui:GetDescendants()
			table.insert(d, PickerGui)
			for _, v in ipairs(d) do
				local a = s[v.ClassName]
				if a then for i = 1, #a do table.insert(a[i], v) end end
			end
			for _, v in ipairs(transparency) do v.Transparency = 1 end
			animCon = RunService.RenderStepped:Connect(function(dt)
				dt = dt * 8
				for _, v in ipairs(backgroundTransparency) do v.BackgroundTransparency += dt end
				for _, v in ipairs(imageTransparency) do v.ImageTransparency += dt end
				for _, v in ipairs(textTransparency) do v.TextTransparency += dt end
			end)
		end)
		Tween(PickerScale, { Scale = 0.6 }, 0.5, 1).Completed:Wait()
		if animCon then animCon:Disconnect() end
		PickerGui:Destroy()
	end

	CloseBtn.MouseButton1Click:Connect(function()
		pickerObj.destroy()
	end)

	task.spawn(function()
		PickerGui.Size = UDim2.fromOffset(300, 30)
		Tween(PickerGui, { Size = UDim2.fromOffset(300, 300) }, 0.5, 1)
	end)

	pickerObj.getColor = function()
		return Color3.fromHSV(hue, sat, val)
	end

	pickerObj.setColor = function(color)
		hue, sat, val = color:ToHSV()
		displayHSV(true)
	end

	return pickerObj
end

function SimpleKavo.CreateLib(title, themeName)
	local T = Themes[themeName] or Themes.DefaultTheme

	local toggleKey = loadKeybind()
	local listeningForKey = false

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "Meow" .. tostring(math.random(10000, 99999))
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	ScreenGui.DisplayOrder = 2147483647
	local ok, err = pcall(function()
		local parent = (gethui and gethui())
			or (syn and syn.protect_gui and game:GetService("CoreGui"))
			or game:GetService("CoreGui")

		ScreenGui.Parent = parent

		if syn and syn.protect_gui then
			syn.protect_gui(ScreenGui)
		end
	end)

	if not ok then
		local ok2 = pcall(function()
			ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
		end)
		if not ok2 then
			warn("Failed to parent ScreenGui: " .. tostring(err))
			return
		end
	end

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Parent = ScreenGui
	Main.BackgroundColor3 = T.Window2
	Main.BackgroundTransparency = 0
	Main.Position = UDim2.new(0.3, 0, 0.3, 0)
	Main.Size = UDim2.new(0, 600, 0, 460)
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = false
	Main.ZIndex = 5

	local MainScale = Instance.new("UIScale")
	MainScale.Scale = 1
	MainScale.Name = "Scale"
	MainScale.Parent = Main

	local MainStroke = Instance.new("UIStroke")
	MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	MainStroke.Color = T.Stroke
	MainStroke.LineJoinMode = Enum.LineJoinMode.Round
	MainStroke.Thickness = 1
	MainStroke.Name = "Stroke"
	MainStroke.Parent = Main

	local MainShadow = Instance.new("ImageLabel")
	MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	MainShadow.BackgroundTransparency = 1
	MainShadow.BorderSizePixel = 0
	MainShadow.Image = "rbxassetid://7331400934"
	MainShadow.ImageColor3 = Color3.fromRGB(0, 0, 5)
	MainShadow.Name = "Shadow"
	MainShadow.Position = UDim2.fromScale(0.5, 0.5)
	MainShadow.ScaleType = Enum.ScaleType.Slice
	MainShadow.Size = UDim2.new(1, 60, 1, 60)
	MainShadow.SliceCenter = Rect.new(40, 40, 260, 260)
	MainShadow.ZIndex = 4
	MainShadow.Parent = Main

	local TrimLine = Instance.new("Frame")
	TrimLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TrimLine.BackgroundTransparency = 0
	TrimLine.BorderSizePixel = 0
	TrimLine.Name = "Trim"
	TrimLine.Position = UDim2.fromOffset(0, -1)
	TrimLine.Size = UDim2.new(1, 0, 0, 1)
	TrimLine.ZIndex = 64
	TrimLine.Parent = Main

	local TrimGradient = Instance.new("UIGradient")
	TrimGradient.Color = ColorSequence.new(T.Primary, T.Secondary)
	TrimGradient.Enabled = true
	TrimGradient.Rotation = 0
	TrimGradient.Parent = TrimLine

	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.Parent = Main
	Header.BackgroundColor3 = T.Window1
	Header.BackgroundTransparency = 0
	Header.BorderSizePixel = 0
	Header.Size = UDim2.new(1, 0, 0, 28)
	Header.ZIndex = 50
	Header.ClipsDescendants = true

	local HeaderStroke = Instance.new("UIStroke")
	HeaderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	HeaderStroke.Color = T.Stroke
	HeaderStroke.LineJoinMode = Enum.LineJoinMode.Round
	HeaderStroke.Thickness = 1
	HeaderStroke.Parent = Header

	local HeaderFade = Instance.new("Frame")
	HeaderFade.BackgroundColor3 = T.Window1
	HeaderFade.BackgroundTransparency = 1
	HeaderFade.BorderSizePixel = 0
	HeaderFade.Name = "Fade"
	HeaderFade.Size = UDim2.new(1, 4, 1, 4)
	HeaderFade.Position = UDim2.fromOffset(-2, -2)
	HeaderFade.Visible = false
	HeaderFade.ZIndex = 60
	HeaderFade.Parent = Header

	local Title = Instance.new("TextLabel")
	Title.Parent = Header
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.fromOffset(28, 0)
	Title.Size = UDim2.new(1, -120, 1, 0)
	Title.Font = Enum.Font.RobotoCondensed
	Title.Text = title
	Title.TextColor3 = T.TextPrimary
	Title.TextSize = 17
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextYAlignment = Enum.TextYAlignment.Center
	Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	Title.TextStrokeTransparency = 0.8
	Title.ZIndex = 52

	local TitlePad = Instance.new("UIPadding")
	TitlePad.PaddingLeft = UDim.new(0, 4)
	TitlePad.Parent = Title

	local WindowIcon = Instance.new("ImageLabel")
	WindowIcon.BackgroundTransparency = 1
	WindowIcon.BorderSizePixel = 0
	WindowIcon.Image = "rbxassetid://10152328589"
	WindowIcon.ImageColor3 = T.Primary
	WindowIcon.Name = "Icon"
	WindowIcon.Position = UDim2.fromOffset(2, 2)
	WindowIcon.Size = UDim2.fromOffset(22, 22)
	WindowIcon.ZIndex = 52
	WindowIcon.Parent = Header

	local KeybindBtn = Instance.new("TextButton")
	KeybindBtn.Name = "KeybindBtn"
	KeybindBtn.Parent = Header
	KeybindBtn.BackgroundColor3 = T.Button1
	KeybindBtn.BackgroundTransparency = 0
	KeybindBtn.AnchorPoint = Vector2.new(1, 0.5)
	KeybindBtn.Position = UDim2.new(1, -32, 0.5, 0)
	KeybindBtn.Size = UDim2.new(0, 64, 0, 16)
	KeybindBtn.Font = Enum.Font.SourceSans
	KeybindBtn.Text = "[" .. toggleKey.Name .. "]"
	KeybindBtn.TextColor3 = T.TextDim
	KeybindBtn.TextSize = 13
	KeybindBtn.AutoButtonColor = false
	KeybindBtn.ZIndex = 52

	local KeybindBtnCorner = Instance.new("UICorner")
	KeybindBtnCorner.CornerRadius = UDim.new(0, 2)
	KeybindBtnCorner.Parent = KeybindBtn

	local KeybindBtnStroke = Instance.new("UIStroke")
	KeybindBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	KeybindBtnStroke.Color = T.Stroke
	KeybindBtnStroke.LineJoinMode = Enum.LineJoinMode.Round
	KeybindBtnStroke.Thickness = 1
	KeybindBtnStroke.Parent = KeybindBtn

	local Close = Instance.new("TextButton")
	Close.Parent = Header
	Close.BackgroundColor3 = T.Button1
	Close.BackgroundTransparency = 0
	Close.AnchorPoint = Vector2.new(1, 0.5)
	Close.Position = UDim2.new(1, -4, 0.5, 0)
	Close.Size = UDim2.fromOffset(18, 18)
	Close.Text = ""
	Close.AutoButtonColor = false
	Close.ZIndex = 52

	local CloseCorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(0, 2)
	CloseCorner.Parent = Close

	local CloseStroke = Instance.new("UIStroke")
	CloseStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	CloseStroke.Color = T.Stroke
	CloseStroke.LineJoinMode = Enum.LineJoinMode.Round
	CloseStroke.Thickness = 1
	CloseStroke.Parent = Close

	local CloseIcon = Instance.new("ImageLabel")
	CloseIcon.Active = false
	CloseIcon.BackgroundTransparency = 1
	CloseIcon.BorderSizePixel = 0
	CloseIcon.Image = "rbxassetid://9801460300"
	CloseIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	CloseIcon.Name = "Icon"
	CloseIcon.Size = UDim2.fromScale(1, 1)
	CloseIcon.ZIndex = 52
	CloseIcon.Parent = Close

	local CloseIconGradient = Instance.new("UIGradient")
	CloseIconGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
	CloseIconGradient.Rotation = 90
	CloseIconGradient.Parent = CloseIcon

	Close.MouseEnter:Connect(function()
		Tween(Close, { BackgroundColor3 = T.Button2 }, 0.2, 2)
		Tween(CloseStroke, { Color = T.StrokeHover }, 0.2, 2)
	end)
	Close.MouseLeave:Connect(function()
		Tween(Close, { BackgroundColor3 = T.Button1 }, 0.2, 2)
		Tween(CloseStroke, { Color = T.Stroke }, 0.2, 2)
	end)
	Close.MouseButton1Click:Connect(function()
		local animCon
		task.spawn(function()
			local backgroundTransparency = {}
			local imageTransparency = {}
			local textTransparency = {}
			local transparency = {}
			local s = {
				Frame = { backgroundTransparency },
				ImageLabel = { backgroundTransparency, imageTransparency },
				ImageButton = { backgroundTransparency, imageTransparency },
				TextLabel = { backgroundTransparency, textTransparency },
				TextButton = { backgroundTransparency, textTransparency },
				UIStroke = { transparency },
			}
			local d = Main:GetDescendants()
			table.insert(d, Main)
			for _, v in ipairs(d) do
				local a = s[v.ClassName]
				if a then for i = 1, #a do table.insert(a[i], v) end end
			end
			for _, v in ipairs(transparency) do v.Transparency = 1 end
			animCon = RunService.RenderStepped:Connect(function(dt)
				dt = dt * 8
				for _, v in ipairs(backgroundTransparency) do v.BackgroundTransparency = v.BackgroundTransparency + dt end
				for _, v in ipairs(imageTransparency) do v.ImageTransparency = v.ImageTransparency + dt end
				for _, v in ipairs(textTransparency) do v.TextTransparency = v.TextTransparency + dt end
			end)
		end)
		Tween(MainScale, { Scale = 0.6 }, 0.5, 2).Completed:Wait()
		if animCon then animCon:Disconnect() end
		ScreenGui:Destroy()
	end)

	KeybindBtn.MouseEnter:Connect(function()
		if not listeningForKey then
			Tween(KeybindBtn, { BackgroundColor3 = T.Button2 }, 0.2, 2)
			Tween(KeybindBtnStroke, { Color = T.StrokeHover }, 0.2, 2)
		end
	end)
	KeybindBtn.MouseLeave:Connect(function()
		if not listeningForKey then
			Tween(KeybindBtn, { BackgroundColor3 = T.Button1 }, 0.2, 2)
			Tween(KeybindBtnStroke, { Color = T.Stroke }, 0.2, 2)
		end
	end)
	KeybindBtn.MouseButton1Click:Connect(function()
		if listeningForKey then return end
		listeningForKey = true
		KeybindBtn.Text = "..."
		Tween(KeybindBtn, {
			BackgroundColor3 = T.SchemeColor,
			TextColor3 = T.TextPrimary,
		}, 0.15, 2)
	end)

	local SideBar = Instance.new("Frame")
	SideBar.Name = "SideBar"
	SideBar.Parent = Main
	SideBar.BackgroundColor3 = T.Window3
	SideBar.BackgroundTransparency = 0
	SideBar.BorderSizePixel = 0
	SideBar.Position = UDim2.fromOffset(0, 28)
	SideBar.Size = UDim2.new(0, 125, 1, -28)
	SideBar.ZIndex = 50

	local SideBarStroke = Instance.new("UIStroke")
	SideBarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	SideBarStroke.Color = T.Stroke
	SideBarStroke.LineJoinMode = Enum.LineJoinMode.Round
	SideBarStroke.Thickness = 1
	SideBarStroke.Parent = SideBar

	local TabMenu = Instance.new("ScrollingFrame")
	TabMenu.Name = "TabMenu"
	TabMenu.Parent = SideBar
	TabMenu.AutomaticCanvasSize = Enum.AutomaticSize.Y
	TabMenu.BackgroundTransparency = 1
	TabMenu.BorderSizePixel = 0
	TabMenu.BottomImage = "rbxassetid://9416839567"
	TabMenu.CanvasSize = UDim2.fromOffset(0, 0)
	TabMenu.MidImage = "rbxassetid://9416839567"
	TabMenu.Position = UDim2.fromOffset(1, 1)
	TabMenu.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
	TabMenu.ScrollBarImageTransparency = 0.9
	TabMenu.ScrollBarThickness = 1
	TabMenu.ScrollingDirection = Enum.ScrollingDirection.Y
	TabMenu.Size = UDim2.new(1, -2, 1, -2)
	TabMenu.TopImage = "rbxassetid://9416839567"
	TabMenu.ZIndex = 51

	local TabMenuLayout = Instance.new("UIListLayout")
	TabMenuLayout.FillDirection = Enum.FillDirection.Vertical
	TabMenuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	TabMenuLayout.Padding = UDim.new(0, 6)
	TabMenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabMenuLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	TabMenuLayout.Parent = TabMenu

	local TabMenuPadding = Instance.new("UIPadding")
	TabMenuPadding.PaddingTop = UDim.new(0, 5)
	TabMenuPadding.Parent = TabMenu

	local Notification = Instance.new("Frame")
	Notification.Name = "Notification"
	Notification.Parent = Main
	Notification.BackgroundColor3 = T.Window3
	Notification.BorderSizePixel = 0
	Notification.Position = UDim2.fromOffset(0, 0)
	Notification.Size = UDim2.new(0, 0, 0, 28)
	Notification.AutomaticSize = Enum.AutomaticSize.X
	Notification.ZIndex = 100
	Notification.Visible = false

	local NotifCorner = Instance.new("UICorner")
	NotifCorner.CornerRadius = UDim.new(0, 4)
	NotifCorner.Parent = Notification

	local NotifStroke = Instance.new("UIStroke")
	NotifStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	NotifStroke.Color = T.Stroke
	NotifStroke.Thickness = 1
	NotifStroke.Parent = Notification

	local NotifLabel = Instance.new("TextLabel")
	NotifLabel.Name = "Label"
	NotifLabel.Parent = Notification
	NotifLabel.BackgroundTransparency = 1
	NotifLabel.Size = UDim2.new(0, 0, 1, 0)
	NotifLabel.AutomaticSize = Enum.AutomaticSize.X
	NotifLabel.Position = UDim2.fromOffset(6, 0)
	NotifLabel.Font = Enum.Font.SourceSans
	NotifLabel.Text = ""
	NotifLabel.TextColor3 = T.TextPrimary
	NotifLabel.TextSize = 14
	NotifLabel.TextXAlignment = Enum.TextXAlignment.Left
	NotifLabel.ZIndex = 101

	local NotifPad = Instance.new("UIPadding")
	NotifPad.PaddingRight = UDim.new(0, 6)
	NotifPad.Parent = Notification

	local notifTask = nil

	local function ShowNotification(text, duration)
		duration = duration or 3
		if notifTask then task.cancel(notifTask) end
		NotifLabel.Text = text
		local width = math.clamp(#text * 7 + 20, 80, 400)
		Notification.Size = UDim2.new(0, width, 0, 28)
		Notification.Position = UDim2.fromOffset(132, 22)
		Notification.BackgroundTransparency = 0
		Notification.Visible = true
		Tween(Notification, { Position = UDim2.fromOffset(132, 32) }, 0.25, 2)
		notifTask = task.delay(duration, function()
			Tween(Notification, { BackgroundTransparency = 1 }, 0.4, 2)
			task.wait(0.4)
			Notification.Visible = false
			Notification.BackgroundTransparency = 0
			notifTask = nil
		end)
	end

	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Parent = Main
	Content.BackgroundColor3 = T.Window2
	Content.BackgroundTransparency = 0
	Content.BorderSizePixel = 0
	Content.Position = UDim2.fromOffset(126, 28)
	Content.Size = UDim2.new(1, -126, 1, -28)
	Content.ZIndex = 30
	Content.ClipsDescendants = true

	local ContentStroke = Instance.new("UIStroke")
	ContentStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ContentStroke.Color = T.Stroke
	ContentStroke.LineJoinMode = Enum.LineJoinMode.Round
	ContentStroke.Thickness = 1
	ContentStroke.Parent = Content

	local Minimized = false

	local MobileToggle
	if UserInputService.TouchEnabled then
		MobileToggle = Instance.new("ImageButton")
		MobileToggle.Name = "MobileToggle"
		MobileToggle.Parent = ScreenGui
		MobileToggle.BackgroundColor3 = T.Button1
		MobileToggle.BorderSizePixel = 0
		MobileToggle.AnchorPoint = Vector2.new(0, 1)
		MobileToggle.Position = UDim2.new(0, 20, 1, -20)
		MobileToggle.Size = UDim2.fromOffset(50, 50)
		MobileToggle.Image = "rbxassetid://124090121529164"
		MobileToggle.ImageColor3 = T.Primary
		MobileToggle.ScaleType = Enum.ScaleType.Fit
		MobileToggle.AutoButtonColor = false
		MobileToggle.ZIndex = 1000

		local MobileToggleCorner = Instance.new("UICorner")
		MobileToggleCorner.CornerRadius = UDim.new(0, 8)
		MobileToggleCorner.Parent = MobileToggle

		local MobileToggleStroke = Instance.new("UIStroke")
		MobileToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		MobileToggleStroke.Color = T.Stroke
		MobileToggleStroke.LineJoinMode = Enum.LineJoinMode.Round
		MobileToggleStroke.Thickness = 1
		MobileToggleStroke.Parent = MobileToggle

		MobileToggle.MouseButton1Click:Connect(function()
			Minimized = not Minimized
			Main.Visible = not Minimized
			Tween(MobileToggleStroke, { Color = T.StrokeHover }, 0.15, 2)
			task.delay(0.15, function()
				Tween(MobileToggleStroke, { Color = T.Stroke }, 0.15, 2)
			end)
		end)

		SimpleKavo:DraggingEnabled(MobileToggle)
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if listeningForKey then
			if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
			local ignored = {
				Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift,
				Enum.KeyCode.LeftControl, Enum.KeyCode.RightControl,
				Enum.KeyCode.LeftAlt, Enum.KeyCode.RightAlt,
				Enum.KeyCode.Unknown,
			}
			local keyCode = input.KeyCode
			local isIgnored = false
			for _, k in ipairs(ignored) do
				if keyCode == k then isIgnored = true break end
			end
			if isIgnored then return end
			toggleKey = keyCode
			listeningForKey = false
			KeybindBtn.Text = "[" .. keyCode.Name .. "]"
			Tween(KeybindBtn, {
				BackgroundColor3 = T.Button1,
				TextColor3 = T.TextDim,
			}, 0.15, 2)
			saveKeybind(keyCode)
			return
		end
		if gameProcessed then return end
		if input.KeyCode == toggleKey then
			Minimized = not Minimized
			if Minimized then
				Main.Visible = false
			else
				Main.Visible = true
			end
		end
	end)

	SimpleKavo:DraggingEnabled(Header, Main)

	task.spawn(function()
		Main.Size = UDim2.fromOffset(500, 30)
		Tween(Main, { Size = UDim2.new(0, 500, 0, 370) }, 0.5, 2)
		HeaderFade.BackgroundTransparency = 0
		HeaderFade.Visible = true
		Tween(HeaderFade, { BackgroundTransparency = 1 }, 2, 2).Completed:Wait()
		HeaderFade.Visible = false
	end)

	local tabsOrder = {}
	local currentTab = nil

	local function updateTheme(newThemeName)
		if not Themes[newThemeName] then
			warn("[SimpleKavo] Tema '" .. tostring(newThemeName) .. "' não encontrado!")
			return
		end
		local newT = Themes[newThemeName]
		Main.BackgroundColor3 = newT.Window2
		Header.BackgroundColor3 = newT.Window1
		SideBar.BackgroundColor3 = newT.Window3
		Content.BackgroundColor3 = newT.Window2
		Title.TextColor3 = newT.TextPrimary
		WindowIcon.ImageColor3 = newT.Primary
		TrimGradient.Color = ColorSequence.new(newT.Primary, newT.Secondary)
		KeybindBtn.TextColor3 = newT.TextDim
		KeybindBtn.BackgroundColor3 = newT.Button1
		MainStroke.Color = newT.Stroke
		HeaderStroke.Color = newT.Stroke
		SideBarStroke.Color = newT.Stroke
		ContentStroke.Color = newT.Stroke

		for _, tabData in ipairs(tabsOrder) do
			tabData.button.BackgroundColor3 = newT.Button1
			tabData.button.TextColor3 = newT.TextPrimary
			if tabData.stroke then tabData.stroke.Color = newT.Stroke end
			if currentTab == tabData.button then
				tabData.button.BackgroundColor3 = newT.Button3
				tabData.button.TextColor3 = newT.Primary
				if tabData.stroke then tabData.stroke.Color = newT.StrokeHover end
			end
		end

		T = newT
	end

	function SimpleKavo:AddTab(name)
		local TabButton = Instance.new("TextButton")
		TabButton.Name = name
		TabButton.Parent = TabMenu
		TabButton.BackgroundColor3 = T.Button1
		TabButton.BackgroundTransparency = 0
		TabButton.BorderSizePixel = 0
		TabButton.Size = UDim2.new(1, -8, 0, 18)
		TabButton.Font = Enum.Font.SourceSans
		TabButton.Text = name
		TabButton.TextColor3 = T.TextPrimary
		TabButton.TextSize = 15
		TabButton.AutoButtonColor = false
		TabButton.LayoutOrder = #tabsOrder + 1
		TabButton.ZIndex = 52

		local TabButtonCorner = Instance.new("UICorner")
		TabButtonCorner.CornerRadius = UDim.new(0, 2)
		TabButtonCorner.Parent = TabButton

		local TabButtonStroke = Instance.new("UIStroke")
		TabButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		TabButtonStroke.Color = T.Stroke
		TabButtonStroke.LineJoinMode = Enum.LineJoinMode.Round
		TabButtonStroke.Thickness = 1
		TabButtonStroke.Parent = TabButton

		local TabContent = Instance.new("ScrollingFrame")
		TabContent.Name = name .. "_Content"
		TabContent.Parent = Content
		TabContent.BackgroundTransparency = 1
		TabContent.BorderSizePixel = 0
		TabContent.Size = UDim2.fromScale(1, 1)
		TabContent.Position = UDim2.fromOffset(1, 1)
		TabContent.Visible = false
		TabContent.ScrollBarThickness = 1
		TabContent.ScrollBarImageColor3 = T.Primary
		TabContent.ScrollBarImageTransparency = 0.9
		TabContent.BottomImage = "rbxassetid://9416839567"
		TabContent.MidImage = "rbxassetid://9416839567"
		TabContent.TopImage = "rbxassetid://9416839567"
		TabContent.CanvasSize = UDim2.fromOffset(0, 0)
		TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
		TabContent.ZIndex = 31

		local TabContentLayout = Instance.new("UIListLayout")
		TabContentLayout.Parent = TabContent
		TabContentLayout.Padding = UDim.new(0, 4)
		TabContentLayout.FillDirection = Enum.FillDirection.Vertical
		TabContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		TabContentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local TabContentPadding = Instance.new("UIPadding")
		TabContentPadding.PaddingTop = UDim.new(0, 4)
		TabContentPadding.Parent = TabContent

		table.insert(tabsOrder, { button = TabButton, content = TabContent, stroke = TabButtonStroke })

		local function activateTab()
			for _, tab in ipairs(tabsOrder) do
				tab.content.Visible = false
				Tween(tab.button, { BackgroundColor3 = T.Button1, TextColor3 = T.TextPrimary }, 0.2, 2)
				if tab.stroke then Tween(tab.stroke, { Color = T.Stroke }, 0.2, 2) end
			end
			TabContent.Visible = true
			Tween(TabButton, { BackgroundColor3 = T.Button3, TextColor3 = T.Primary }, 0.2, 2)
			Tween(TabButtonStroke, { Color = T.StrokeHover }, 0.2, 2)
			currentTab = TabButton
		end

		TabButton.MouseEnter:Connect(function()
			if currentTab ~= TabButton then
				Tween(TabButton, { BackgroundColor3 = T.Button2 }, 0.2, 2)
				Tween(TabButtonStroke, { Color = T.StrokeHover }, 0.2, 2)
			end
		end)
		TabButton.MouseLeave:Connect(function()
			if currentTab ~= TabButton then
				Tween(TabButton, { BackgroundColor3 = T.Button1 }, 0.2, 2)
				Tween(TabButtonStroke, { Color = T.Stroke }, 0.2, 2)
			end
		end)
		TabButton.MouseButton1Click:Connect(activateTab)

		if #tabsOrder == 1 then activateTab() end

		local TabFunctions = {}

		function TabFunctions:NewSection(sectionName, columns)
			local SectionFrame = Instance.new("Frame")
			SectionFrame.Name = sectionName .. "_Section"
			SectionFrame.Parent = TabContent
			SectionFrame.BackgroundColor3 = T.Window2
			SectionFrame.BorderSizePixel = 0
			SectionFrame.Size = UDim2.new(0.95, 0, 0, 0)
			SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
			SectionFrame.ZIndex = 32

			local SectionFrameStroke = Instance.new("UIStroke")
			SectionFrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			SectionFrameStroke.Color = T.Stroke
			SectionFrameStroke.LineJoinMode = Enum.LineJoinMode.Round
			SectionFrameStroke.Thickness = 1
			SectionFrameStroke.Parent = SectionFrame

			local SectionTitleBar = Instance.new("Frame")
			SectionTitleBar.Name = "TitleBar"
			SectionTitleBar.Parent = SectionFrame
			SectionTitleBar.BackgroundColor3 = T.Window3
			SectionTitleBar.BorderSizePixel = 0
			SectionTitleBar.Size = UDim2.new(1, 0, 0, 16)
			SectionTitleBar.ZIndex = 33

			local SectionTitleBarStroke = Instance.new("UIStroke")
			SectionTitleBarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			SectionTitleBarStroke.Color = T.Stroke
			SectionTitleBarStroke.LineJoinMode = Enum.LineJoinMode.Round
			SectionTitleBarStroke.Thickness = 1
			SectionTitleBarStroke.Parent = SectionTitleBar

			local SectionTrim = Instance.new("Frame")
			SectionTrim.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionTrim.BackgroundTransparency = 0
			SectionTrim.BorderSizePixel = 0
			SectionTrim.Name = "Trim"
			SectionTrim.Position = UDim2.fromOffset(-1, -2)
			SectionTrim.Size = UDim2.new(1, 2, 0, 1)
			SectionTrim.ZIndex = 33
			SectionTrim.Parent = SectionTitleBar

			local SectionTrimGrad = Instance.new("UIGradient")
			SectionTrimGrad.Color = ColorSequence.new(T.Primary, T.Secondary)
			SectionTrimGrad.Parent = SectionTrim

			local SectionLabel = Instance.new("TextLabel")
			SectionLabel.Name = "Label"
			SectionLabel.Parent = SectionTitleBar
			SectionLabel.BackgroundTransparency = 1
			SectionLabel.Size = UDim2.fromScale(1, 1)
			SectionLabel.Font = Enum.Font.SourceSans
			SectionLabel.Text = sectionName
			SectionLabel.TextColor3 = T.TextPrimary
			SectionLabel.TextSize = 14
			SectionLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			SectionLabel.TextStrokeTransparency = 0.8
			SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
			SectionLabel.TextYAlignment = Enum.TextYAlignment.Center
			SectionLabel.ZIndex = 35

			local SectionLabelPad = Instance.new("UIPadding")
			SectionLabelPad.PaddingLeft = UDim.new(0, 5)
			SectionLabelPad.Parent = SectionLabel

			local SectionContent = Instance.new("Frame")
			SectionContent.Name = "Content"
			SectionContent.Parent = SectionFrame
			SectionContent.BackgroundTransparency = 1
			SectionContent.BorderSizePixel = 0
			SectionContent.Position = UDim2.fromOffset(0, 17)
			SectionContent.Size = UDim2.new(1, 0, 0, 0)
			SectionContent.AutomaticSize = Enum.AutomaticSize.Y
			SectionContent.ZIndex = 33

			local SectionList = Instance.new("UIListLayout")
			SectionList.Parent = SectionContent
			SectionList.Padding = UDim.new(0, 4)
			SectionList.SortOrder = Enum.SortOrder.LayoutOrder
			SectionList.FillDirection = columns and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
			SectionList.HorizontalAlignment = Enum.HorizontalAlignment.Center
			SectionList.VerticalAlignment = Enum.VerticalAlignment.Top

			local SectionPad = Instance.new("UIPadding")
			SectionPad.PaddingTop = UDim.new(0, 3)
			SectionPad.PaddingBottom = UDim.new(0, 3)
			SectionPad.Parent = SectionContent

			local function makeSectionAPI(parent)
				local m = {}

				function m:NewButton(btnName, description, callback)
				local elementOrder = #parent:GetChildren()

				local ControlFrame = Instance.new("Frame")
				ControlFrame.BackgroundTransparency = 1
				ControlFrame.Name = btnName .. "_Control"
				ControlFrame.Size = UDim2.new(1, 0, 0, 20)
				ControlFrame.ZIndex = 34
				ControlFrame.LayoutOrder = elementOrder
				ControlFrame.Parent = parent

				local ClickSensor = Instance.new("TextButton")
				ClickSensor.BackgroundTransparency = 1
				ClickSensor.Name = "ClickSensor"
				ClickSensor.Size = UDim2.fromScale(1, 1)
				ClickSensor.Text = ""
				ClickSensor.ZIndex = 34
				ClickSensor.Parent = ControlFrame

				local BtnLabel = Instance.new("TextLabel")
				BtnLabel.BackgroundTransparency = 1
				BtnLabel.Font = Enum.Font.SourceSans
				BtnLabel.Name = "Label"
				BtnLabel.Size = UDim2.fromScale(1, 1)
				BtnLabel.Text = btnName
				BtnLabel.TextColor3 = T.TextPrimary
				BtnLabel.TextSize = 14
				BtnLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				BtnLabel.TextStrokeTransparency = 0.8
				BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
				BtnLabel.ZIndex = 35
				BtnLabel.Parent = ClickSensor

				local BtnLabelPad = Instance.new("UIPadding")
				BtnLabelPad.PaddingLeft = UDim.new(0, 6)
				BtnLabelPad.Parent = BtnLabel

				local BtnFrame = Instance.new("Frame")
				BtnFrame.AnchorPoint = Vector2.new(1, 0.5)
				BtnFrame.BackgroundColor3 = T.Button1
				BtnFrame.Name = "Button"
				BtnFrame.Position = UDim2.new(1, -3, 0.5, 0)
				BtnFrame.Size = UDim2.fromOffset(16, 16)
				BtnFrame.ZIndex = 35
				BtnFrame.Parent = ClickSensor

				local BtnCorner = Instance.new("UICorner")
				BtnCorner.CornerRadius = UDim.new(0, 2)
				BtnCorner.Parent = BtnFrame

				local BtnStroke = Instance.new("UIStroke")
				BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				BtnStroke.Color = T.Stroke
				BtnStroke.LineJoinMode = Enum.LineJoinMode.Round
				BtnStroke.Thickness = 1
				BtnStroke.Parent = BtnFrame

				local BtnIcon = Instance.new("ImageLabel")
				BtnIcon.Active = false
				BtnIcon.BackgroundTransparency = 1
				BtnIcon.BorderSizePixel = 0
				BtnIcon.Image = "rbxassetid://9801455339"
				BtnIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
				BtnIcon.Name = "Icon"
				BtnIcon.Rotation = 360
				BtnIcon.Size = UDim2.fromScale(1, 1)
				BtnIcon.ZIndex = 35
				BtnIcon.Parent = BtnFrame

				local BtnIconGrad = Instance.new("UIGradient")
				BtnIconGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
				BtnIconGrad.Rotation = 90
				BtnIconGrad.Parent = BtnIcon

				if description then
					local DescLabel = Instance.new("TextLabel")
					DescLabel.Name = "Description"
					DescLabel.Parent = ControlFrame
					DescLabel.BackgroundTransparency = 1
					DescLabel.Position = UDim2.new(0, 6, 0, 20)
					DescLabel.Size = UDim2.new(1, -20, 0, 12)
					DescLabel.Font = Enum.Font.SourceSans
					DescLabel.Text = description
					DescLabel.TextColor3 = T.TextDim
					DescLabel.TextSize = 12
					DescLabel.TextXAlignment = Enum.TextXAlignment.Left
					DescLabel.ZIndex = 35
					ControlFrame.Size = UDim2.new(1, 0, 0, 32)
				end

				ClickSensor.MouseEnter:Connect(function()
					Tween(BtnFrame, { BackgroundColor3 = T.Button2 }, 0.2, 2)
					Tween(BtnStroke, { Color = T.StrokeHover }, 0.2, 2)
				end)
				ClickSensor.MouseLeave:Connect(function()
					Tween(BtnFrame, { BackgroundColor3 = T.Button1 }, 0.2, 2)
					Tween(BtnStroke, { Color = T.Stroke }, 0.2, 2)
				end)
				local confirmPending = false
				local confirmTask = nil
				ClickSensor.MouseButton1Click:Connect(function()
					if confirmPending then
						if confirmTask then task.cancel(confirmTask) end
						confirmPending = false
						BtnFrame.BackgroundColor3 = T.Button3
						Tween(BtnFrame, { BackgroundColor3 = T.Button1 }, 1, 2)
						BtnIcon.ImageColor3 = T.Primary
						Tween(BtnIcon, { ImageColor3 = Color3.fromRGB(255, 255, 255) }, 1, 2)
						if callback then callback() end
					else
						confirmPending = true
						BtnFrame.BackgroundColor3 = T.Button2
						ShowNotification("Click again to confirm: " .. btnName, 4)
						confirmTask = task.delay(4, function()
							confirmPending = false
							Tween(BtnFrame, { BackgroundColor3 = T.Button1 }, 0.3, 2)
							confirmTask = nil
						end)
					end
				end)

				return ClickSensor
			end

			function m:NewToggle(toggleName, description, callback, defaultState)
				local elementOrder = #parent:GetChildren()

				local ControlFrame = Instance.new("Frame")
				ControlFrame.BackgroundTransparency = 1
				ControlFrame.Name = toggleName .. "_Control"
				ControlFrame.Size = UDim2.new(1, 0, 0, description and 32 or 20)
				ControlFrame.ZIndex = 34
				ControlFrame.LayoutOrder = elementOrder
				ControlFrame.Parent = parent

				local BackToggle = Instance.new("TextButton")
				BackToggle.BackgroundTransparency = 1
				BackToggle.Name = "BackToggle"
				BackToggle.Size = UDim2.fromScale(1, 1)
				BackToggle.Text = ""
				BackToggle.ZIndex = 34
				BackToggle.Parent = ControlFrame

				local TogLabel = Instance.new("TextLabel")
				TogLabel.BackgroundTransparency = 1
				TogLabel.Font = Enum.Font.SourceSans
				TogLabel.Name = "Label"
				TogLabel.Size = UDim2.fromScale(1, 1)
				TogLabel.Text = toggleName
				TogLabel.TextColor3 = T.TextPrimary
				TogLabel.TextSize = 14
				TogLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				TogLabel.TextStrokeTransparency = 0.8
				TogLabel.TextXAlignment = Enum.TextXAlignment.Left
				TogLabel.ZIndex = 35
				TogLabel.Parent = BackToggle

				local TogLabelPad = Instance.new("UIPadding")
				TogLabelPad.PaddingLeft = UDim.new(0, 6)
				TogLabelPad.Parent = TogLabel

				local TogFrame = Instance.new("Frame")
				TogFrame.AnchorPoint = Vector2.new(1, 0.5)
				TogFrame.BackgroundColor3 = T.Button1
				TogFrame.Name = "Toggle"
				TogFrame.Position = UDim2.new(1, -3, 0.5, 0)
				TogFrame.Size = UDim2.fromOffset(16, 16)
				TogFrame.ZIndex = 35
				TogFrame.Parent = BackToggle

				local TogCorner = Instance.new("UICorner")
				TogCorner.CornerRadius = UDim.new(0, 2)
				TogCorner.Parent = TogFrame

				local TogStroke = Instance.new("UIStroke")
				TogStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				TogStroke.Color = T.Stroke
				TogStroke.LineJoinMode = Enum.LineJoinMode.Round
				TogStroke.Thickness = 1
				TogStroke.Parent = TogFrame

				local TogIcon = Instance.new("ImageLabel")
				TogIcon.Active = false
				TogIcon.BackgroundTransparency = 1
				TogIcon.BorderSizePixel = 0
				TogIcon.Image = "rbxassetid://9801456486"
				TogIcon.ImageColor3 = T.Secondary
				TogIcon.Name = "Icon"
				TogIcon.Rotation = 360
				TogIcon.Size = UDim2.fromScale(1, 1)
				TogIcon.ZIndex = 35
				TogIcon.Parent = TogFrame

				local TogIconGrad = Instance.new("UIGradient")
				TogIconGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
				TogIconGrad.Rotation = 90
				TogIconGrad.Parent = TogIcon

				if description then
					local DescLabel = Instance.new("TextLabel")
					DescLabel.Name = "Description"
					DescLabel.Parent = ControlFrame
					DescLabel.BackgroundTransparency = 1
					DescLabel.Position = UDim2.new(0, 6, 0, 20)
					DescLabel.Size = UDim2.new(1, -30, 0, 12)
					DescLabel.Font = Enum.Font.SourceSans
					DescLabel.Text = description
					DescLabel.TextColor3 = T.TextDim
					DescLabel.TextSize = 12
					DescLabel.TextXAlignment = Enum.TextXAlignment.Left
					DescLabel.ZIndex = 35
				end

				local State = defaultState == true
				local focused = false

				local function UpdateToggleVisual(state)
					if state then
						TogIcon.Image = "rbxassetid://9801457539"
						Tween(TogIcon, { Rotation = 0, ImageColor3 = T.Primary }, 0.3, 2)
						if focused then
							Tween(TogFrame, { BackgroundColor3 = T.Button3 }, 0.2, 2)
						else
							Tween(TogFrame, { BackgroundColor3 = T.Button2 }, 0.2, 2)
						end
					else
						TogIcon.Image = "rbxassetid://9801456486"
						Tween(TogIcon, { Rotation = 360, ImageColor3 = T.Secondary }, 0.3, 2)
						if focused then
							Tween(TogFrame, { BackgroundColor3 = T.Button2 }, 0.2, 2)
						else
							Tween(TogFrame, { BackgroundColor3 = T.Button1 }, 0.2, 2)
						end
					end
				end
				UpdateToggleVisual(State)

				BackToggle.MouseEnter:Connect(function()
					focused = true
					if State then
						Tween(TogFrame, { BackgroundColor3 = T.Button3 }, 0.2, 2)
					else
						Tween(TogFrame, { BackgroundColor3 = T.Button2 }, 0.2, 2)
					end
					Tween(TogStroke, { Color = T.StrokeHover }, 0.2, 2)
				end)
				BackToggle.MouseLeave:Connect(function()
					focused = false
					if State then
						Tween(TogFrame, { BackgroundColor3 = T.Button2 }, 0.2, 2)
					else
						Tween(TogFrame, { BackgroundColor3 = T.Button1 }, 0.2, 2)
					end
					Tween(TogStroke, { Color = T.Stroke }, 0.2, 2)
				end)
				BackToggle.MouseButton1Click:Connect(function()
					State = not State
					UpdateToggleVisual(State)
					if callback then callback(State) end
				end)

				local toggleObj = { Frame = ControlFrame }
				function toggleObj:Set(value)
					if State == value then return end
					State = value
					UpdateToggleVisual(State)
					if callback then callback(State) end
				end
				function toggleObj:Get()
					return State
				end
				return toggleObj
			end

			function m:NewSlider(sliderName, min, max, default, callback)
				local elementOrder = #parent:GetChildren()

				local ControlFrame = Instance.new("Frame")
				ControlFrame.BackgroundTransparency = 1
				ControlFrame.Name = sliderName .. "_Control"
				ControlFrame.Size = UDim2.new(1, 0, 0, 20)
				ControlFrame.ZIndex = 34
				ControlFrame.LayoutOrder = elementOrder
				ControlFrame.Parent = parent

				local SliderContainer = Instance.new("Frame")
				SliderContainer.BackgroundColor3 = T.Button1
				SliderContainer.Name = "SliderContainer"
				SliderContainer.Position = UDim2.fromOffset(3, 2)
				SliderContainer.Size = UDim2.new(1, -6, 0, 16)
				SliderContainer.ZIndex = 35
				SliderContainer.Parent = ControlFrame

				local SliderContainerCorner = Instance.new("UICorner")
				SliderContainerCorner.CornerRadius = UDim.new(0, 2)
				SliderContainerCorner.Parent = SliderContainer

				local SliderContainerStroke = Instance.new("UIStroke")
				SliderContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				SliderContainerStroke.Color = T.Stroke
				SliderContainerStroke.LineJoinMode = Enum.LineJoinMode.Round
				SliderContainerStroke.Thickness = 1
				SliderContainerStroke.Parent = SliderContainer

				local SliderFill = Instance.new("Frame")
				SliderFill.Active = false
				SliderFill.BackgroundColor3 = T.Primary
				SliderFill.BackgroundTransparency = 0.6
				SliderFill.BorderSizePixel = 0
				SliderFill.Name = "Fill"
				SliderFill.Size = UDim2.fromScale(math.clamp((default - min) / (max - min), 0, 1), 1)
				SliderFill.ZIndex = 36
				SliderFill.Parent = SliderContainer

				local SliderFillCorner = Instance.new("UICorner")
				SliderFillCorner.CornerRadius = UDim.new(0, 2)
				SliderFillCorner.Parent = SliderFill

				local SliderFillGrad = Instance.new("UIGradient")
				SliderFillGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
				SliderFillGrad.Rotation = 90
				SliderFillGrad.Parent = SliderFill

				local SliderLabel = Instance.new("TextLabel")
				SliderLabel.BackgroundTransparency = 1
				SliderLabel.Font = Enum.Font.SourceSans
				SliderLabel.Name = "Label"
				SliderLabel.Size = UDim2.fromScale(1, 1)
				SliderLabel.Text = sliderName
				SliderLabel.TextColor3 = T.TextPrimary
				SliderLabel.TextSize = 14
				SliderLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				SliderLabel.TextStrokeTransparency = 0.8
				SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
				SliderLabel.ZIndex = 37
				SliderLabel.Parent = ControlFrame

				local SliderLabelPad = Instance.new("UIPadding")
				SliderLabelPad.PaddingLeft = UDim.new(0, 6)
				SliderLabelPad.Parent = SliderLabel

				local SliderVal = Instance.new("TextLabel")
				SliderVal.BackgroundTransparency = 1
				SliderVal.Font = Enum.Font.SourceSans
				SliderVal.Name = "Value"
				SliderVal.Size = UDim2.fromScale(1, 1)
				SliderVal.Text = tostring(math.floor(default))
				SliderVal.TextColor3 = T.TextPrimary
				SliderVal.TextSize = 14
				SliderVal.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				SliderVal.TextStrokeTransparency = 0.8
				SliderVal.TextXAlignment = Enum.TextXAlignment.Right
				SliderVal.ZIndex = 37
				SliderVal.Parent = ControlFrame

				local SliderValPad = Instance.new("UIPadding")
				SliderValPad.PaddingRight = UDim.new(0, 6)
				SliderValPad.Parent = SliderVal

				if callback then callback(default) end

				local dragging = false
				local targetSize = SliderFill.Size
				local aCon

				SliderContainer.MouseEnter:Connect(function()
					Tween(SliderContainer, { BackgroundColor3 = T.Button2 }, 0.2, 2)
					Tween(SliderContainerStroke, { Color = T.StrokeHover }, 0.2, 2)
				end)
				SliderContainer.MouseLeave:Connect(function()
					Tween(SliderContainer, { BackgroundColor3 = T.Button1 }, 0.2, 2)
					Tween(SliderContainerStroke, { Color = T.Stroke }, 0.2, 2)
				end)

				local function UpdateSlider(value)
					local percent = math.clamp((value - min) / (max - min), 0, 1)
					targetSize = UDim2.fromScale(percent, 1)
					SliderVal.Text = tostring(math.floor(value))
					if callback then callback(value) end
				end

				SliderContainer.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						local sliderPos = SliderContainer.AbsolutePosition
						local sliderWidth = SliderContainer.AbsoluteSize.X
						local rawValue = math.clamp((input.Position.X - sliderPos.X) / sliderWidth, 0, 1)
						local value = min + (max - min) * rawValue
						UpdateSlider(value)
						aCon = RunService.RenderStepped:Connect(function(dt)
							SliderFill.Size = SliderFill.Size:lerp(targetSize, 1 - 1e-12 ^ dt)
						end)
					end
				end)
				SliderContainer.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
						if aCon then aCon:Disconnect() end
						Tween(SliderFill, { Size = targetSize }, 0.2, 2)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						local sliderPos = SliderContainer.AbsolutePosition
						local sliderWidth = SliderContainer.AbsoluteSize.X
						local rawValue = math.clamp((input.Position.X - sliderPos.X) / sliderWidth, 0, 1)
						local value = min + (max - min) * rawValue
						UpdateSlider(value)
					end
				end)

				local sliderObj = { Frame = ControlFrame }
				function sliderObj:Set(value)
					value = math.clamp(value, min, max)
					local percent = (value - min) / (max - min)
					SliderFill.Size = UDim2.fromScale(percent, 1)
					SliderVal.Text = tostring(math.floor(value))
					if callback then callback(value) end
				end
				function sliderObj:Get()
					local pct = SliderFill.Size.X.Scale
					return min + (max - min) * pct
				end
				return sliderObj
			end

			function m:NewSliderFloat(sliderName, min, max, default, decimals, callback)
				if type(decimals) == "function" then
					callback = decimals
					decimals = 2
				end
				decimals = decimals or 2
				local fmt = "%." .. tostring(math.clamp(math.floor(decimals), 0, 10)) .. "f"
				local elementOrder = #parent:GetChildren()

				local ControlFrame = Instance.new("Frame")
				ControlFrame.BackgroundTransparency = 1
				ControlFrame.Name = sliderName .. "_Control"
				ControlFrame.Size = UDim2.new(1, 0, 0, 20)
				ControlFrame.ZIndex = 34
				ControlFrame.LayoutOrder = elementOrder
				ControlFrame.Parent = parent

				local SliderContainer = Instance.new("Frame")
				SliderContainer.BackgroundColor3 = T.Button1
				SliderContainer.Name = "SliderContainer"
				SliderContainer.Position = UDim2.fromOffset(3, 2)
				SliderContainer.Size = UDim2.new(1, -6, 0, 16)
				SliderContainer.ZIndex = 35
				SliderContainer.Parent = ControlFrame

				local SliderContainerCorner = Instance.new("UICorner")
				SliderContainerCorner.CornerRadius = UDim.new(0, 2)
				SliderContainerCorner.Parent = SliderContainer

				local SliderContainerStroke = Instance.new("UIStroke")
				SliderContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				SliderContainerStroke.Color = T.Stroke
				SliderContainerStroke.LineJoinMode = Enum.LineJoinMode.Round
				SliderContainerStroke.Thickness = 1
				SliderContainerStroke.Parent = SliderContainer

				local SliderFill = Instance.new("Frame")
				SliderFill.Active = false
				SliderFill.BackgroundColor3 = T.Primary
				SliderFill.BackgroundTransparency = 0.6
				SliderFill.BorderSizePixel = 0
				SliderFill.Name = "Fill"
				SliderFill.Size = UDim2.fromScale(math.clamp((default - min) / (max - min), 0, 1), 1)
				SliderFill.ZIndex = 36
				SliderFill.Parent = SliderContainer

				local SliderFillCorner = Instance.new("UICorner")
				SliderFillCorner.CornerRadius = UDim.new(0, 2)
				SliderFillCorner.Parent = SliderFill

				local SliderFillGrad = Instance.new("UIGradient")
				SliderFillGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
				SliderFillGrad.Rotation = 90
				SliderFillGrad.Parent = SliderFill

				local SliderLabel = Instance.new("TextLabel")
				SliderLabel.BackgroundTransparency = 1
				SliderLabel.Font = Enum.Font.SourceSans
				SliderLabel.Name = "Label"
				SliderLabel.Size = UDim2.fromScale(1, 1)
				SliderLabel.Text = sliderName
				SliderLabel.TextColor3 = T.TextPrimary
				SliderLabel.TextSize = 14
				SliderLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				SliderLabel.TextStrokeTransparency = 0.8
				SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
				SliderLabel.ZIndex = 37
				SliderLabel.Parent = ControlFrame

				local SliderLabelPad = Instance.new("UIPadding")
				SliderLabelPad.PaddingLeft = UDim.new(0, 6)
				SliderLabelPad.Parent = SliderLabel

				local SliderVal = Instance.new("TextLabel")
				SliderVal.BackgroundTransparency = 1
				SliderVal.Font = Enum.Font.SourceSans
				SliderVal.Name = "Value"
				SliderVal.Size = UDim2.fromScale(1, 1)
				SliderVal.Text = string.format(fmt, default)
				SliderVal.TextColor3 = T.TextPrimary
				SliderVal.TextSize = 14
				SliderVal.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				SliderVal.TextStrokeTransparency = 0.8
				SliderVal.TextXAlignment = Enum.TextXAlignment.Right
				SliderVal.ZIndex = 37
				SliderVal.Parent = ControlFrame

				local SliderValPad = Instance.new("UIPadding")
				SliderValPad.PaddingRight = UDim.new(0, 6)
				SliderValPad.Parent = SliderVal

				if callback then callback(default) end

				local dragging = false
				local targetSize = SliderFill.Size
				local aCon

				SliderContainer.MouseEnter:Connect(function()
					Tween(SliderContainer, { BackgroundColor3 = T.Button2 }, 0.2, 2)
					Tween(SliderContainerStroke, { Color = T.StrokeHover }, 0.2, 2)
				end)
				SliderContainer.MouseLeave:Connect(function()
					Tween(SliderContainer, { BackgroundColor3 = T.Button1 }, 0.2, 2)
					Tween(SliderContainerStroke, { Color = T.Stroke }, 0.2, 2)
				end)

				local function UpdateSlider(value)
					local percent = math.clamp((value - min) / (max - min), 0, 1)
					targetSize = UDim2.fromScale(percent, 1)
					SliderVal.Text = string.format(fmt, value)
					if callback then callback(value) end
				end

				SliderContainer.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						local pos = input.Position.X - SliderContainer.AbsolutePosition.X
						local rawValue = math.clamp(pos / SliderContainer.AbsoluteSize.X, 0, 1)
						UpdateSlider(min + (max - min) * rawValue)
						aCon = RunService.RenderStepped:Connect(function(dt)
							SliderFill.Size = SliderFill.Size:lerp(targetSize, 1 - 1e-12 ^ dt)
						end)
					end
				end)
				SliderContainer.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
						if aCon then aCon:Disconnect() end
						Tween(SliderFill, { Size = targetSize }, 0.2, 2)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						local pos = input.Position.X - SliderContainer.AbsolutePosition.X
						local rawValue = math.clamp(pos / SliderContainer.AbsoluteSize.X, 0, 1)
						UpdateSlider(min + (max - min) * rawValue)
					end
				end)

				local sliderObj = { Frame = ControlFrame }
				function sliderObj:Set(value)
					value = math.clamp(value, min, max)
					SliderFill.Size = UDim2.fromScale((value - min) / (max - min), 1)
					SliderVal.Text = string.format(fmt, value)
					if callback then callback(value) end
				end
				function sliderObj:Get()
					return min + (max - min) * SliderFill.Size.X.Scale
				end
				return sliderObj
			end

			function m:NewDropdown(dropName, options, defaultOption, callback)
				local elementOrder = #parent:GetChildren()
				local isOpen = false
				local selectedOption = defaultOption or (options and options[1]) or "Select"

				local DropFrame = Instance.new("Frame")
				DropFrame.Name = dropName .. "_Dropdown"
				DropFrame.BackgroundTransparency = 1
				DropFrame.Size = UDim2.new(1, 0, 0, 20)
				DropFrame.ClipsDescendants = true
				DropFrame.LayoutOrder = elementOrder
				DropFrame.ZIndex = 34
				DropFrame.Parent = parent

				local MainButton = Instance.new("TextButton")
				MainButton.Name = "MainButton"
				MainButton.Parent = DropFrame
				MainButton.BackgroundColor3 = T.Button1
				MainButton.Size = UDim2.new(1, -6, 0, 16)
				MainButton.Position = UDim2.fromOffset(3, 2)
				MainButton.Font = Enum.Font.SourceSans
				MainButton.Text = ""
				MainButton.AutoButtonColor = false
				MainButton.ZIndex = 35

				local MainBtnCorner = Instance.new("UICorner")
				MainBtnCorner.CornerRadius = UDim.new(0, 2)
				MainBtnCorner.Parent = MainButton

				local MainBtnStroke = Instance.new("UIStroke")
				MainBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				MainBtnStroke.Color = T.Stroke
				MainBtnStroke.LineJoinMode = Enum.LineJoinMode.Round
				MainBtnStroke.Thickness = 1
				MainBtnStroke.Parent = MainButton

				local MainBtnLabel = Instance.new("TextLabel")
				MainBtnLabel.BackgroundTransparency = 1
				MainBtnLabel.Font = Enum.Font.SourceSans
				MainBtnLabel.Name = "Label"
				MainBtnLabel.Size = UDim2.fromScale(1, 1)
				MainBtnLabel.Text = dropName .. ": " .. tostring(selectedOption)
				MainBtnLabel.TextColor3 = T.TextPrimary
				MainBtnLabel.TextSize = 14
				MainBtnLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				MainBtnLabel.TextStrokeTransparency = 0.8
				MainBtnLabel.TextXAlignment = Enum.TextXAlignment.Left
				MainBtnLabel.ZIndex = 36
				MainBtnLabel.Parent = MainButton

				local MainBtnLabelPad = Instance.new("UIPadding")
				MainBtnLabelPad.PaddingLeft = UDim.new(0, 6)
				MainBtnLabelPad.Parent = MainBtnLabel

				local ArrowIcon = Instance.new("ImageLabel")
				ArrowIcon.AnchorPoint = Vector2.new(1, 0.5)
				ArrowIcon.BackgroundTransparency = 1
				ArrowIcon.Image = "rbxassetid://9801473013"
				ArrowIcon.ImageColor3 = T.Secondary
				ArrowIcon.Name = "Arrow"
				ArrowIcon.Position = UDim2.fromScale(1, 0.5)
				ArrowIcon.Rotation = 0
				ArrowIcon.Size = UDim2.fromOffset(16, 16)
				ArrowIcon.ZIndex = 36
				ArrowIcon.Parent = MainButton

				local ArrowIconGrad = Instance.new("UIGradient")
				ArrowIconGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
				ArrowIconGrad.Rotation = 90
				ArrowIconGrad.Parent = ArrowIcon

				local OptionsFrame = Instance.new("Frame")
				OptionsFrame.Name = "OptionsFrame"
				OptionsFrame.Parent = DropFrame
				OptionsFrame.BackgroundColor3 = T.Window3
				OptionsFrame.BackgroundTransparency = 0
				OptionsFrame.BorderSizePixel = 0
				OptionsFrame.Position = UDim2.fromOffset(3, 22)
				OptionsFrame.Size = UDim2.new(1, -6, 0, 0)
				OptionsFrame.Visible = false
				OptionsFrame.ClipsDescendants = true
				OptionsFrame.ZIndex = 36

				local OptionsFrameStroke = Instance.new("UIStroke")
				OptionsFrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				OptionsFrameStroke.Color = T.Stroke
				OptionsFrameStroke.LineJoinMode = Enum.LineJoinMode.Round
				OptionsFrameStroke.Thickness = 1
				OptionsFrameStroke.Parent = OptionsFrame

				local OptionsList = Instance.new("UIListLayout")
				OptionsList.Parent = OptionsFrame
				OptionsList.Padding = UDim.new(0, 4)
				OptionsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
				OptionsList.VerticalAlignment = Enum.VerticalAlignment.Top
				OptionsList.SortOrder = Enum.SortOrder.LayoutOrder

				local OptionsListPad = Instance.new("UIPadding")
				OptionsListPad.PaddingTop = UDim.new(0, 4)
				OptionsListPad.Parent = OptionsFrame

				local function createOptions()
					for _, child in ipairs(OptionsFrame:GetChildren()) do
						if child:IsA("TextButton") then child:Destroy() end
					end
					if not options or #options == 0 then return end
					for i, option in ipairs(options) do
						local OptButton = Instance.new("TextButton")
						OptButton.Name = tostring(option)
						OptButton.Parent = OptionsFrame
						OptButton.BackgroundColor3 = T.Button1
						OptButton.Size = UDim2.new(1, -6, 0, 16)
						OptButton.Font = Enum.Font.SourceSans
						OptButton.Text = tostring(option)
						OptButton.TextColor3 = T.TextPrimary
						OptButton.TextSize = 14
						OptButton.AutoButtonColor = false
						OptButton.ZIndex = 37
						OptButton.LayoutOrder = i

						local OptCorner = Instance.new("UICorner")
						OptCorner.CornerRadius = UDim.new(0, 2)
						OptCorner.Parent = OptButton

						local OptStroke = Instance.new("UIStroke")
						OptStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						OptStroke.Color = T.Stroke
						OptStroke.LineJoinMode = Enum.LineJoinMode.Round
						OptStroke.Thickness = 1
						OptStroke.Parent = OptButton

						OptButton.MouseEnter:Connect(function()
							Tween(OptButton, { BackgroundColor3 = T.Button2 }, 0.2, 2)
							Tween(OptStroke, { Color = T.StrokeHover }, 0.2, 2)
						end)
						OptButton.MouseLeave:Connect(function()
							Tween(OptButton, { BackgroundColor3 = T.Button1 }, 0.2, 2)
							Tween(OptStroke, { Color = T.Stroke }, 0.2, 2)
						end)
						OptButton.MouseButton1Click:Connect(function()
							selectedOption = option
							MainBtnLabel.Text = dropName .. ": " .. tostring(selectedOption)
							isOpen = false
							Tween(ArrowIcon, { Rotation = 0, ImageColor3 = T.Secondary }, 0.2, 2)
							Tween(OptionsFrame, { Size = UDim2.new(1, -6, 0, 0) }, 0.2, 2)
							Tween(DropFrame, { Size = UDim2.new(1, 0, 0, 20) }, 0.2, 2)
							task.delay(0.21, function()
								if not isOpen then OptionsFrame.Visible = false end
							end)
							if callback then callback(option) end
						end)
					end
				end
				createOptions()

				local function toggleDropdown()
					isOpen = not isOpen
					Tween(ArrowIcon, { Rotation = isOpen and 180 or 0, ImageColor3 = isOpen and T.Primary or T.Secondary }, 0.2, 2)
					if isOpen then
						local optionCount = #options > 0 and #options or 1
						local totalHeight = optionCount * 20 + (optionCount - 1) * 4 + 8
						OptionsFrame.Visible = true
						Tween(DropFrame, { Size = UDim2.new(1, 0, 0, 20 + totalHeight + 6) }, 0.2, 2)
						Tween(OptionsFrame, { Size = UDim2.new(1, -6, 0, totalHeight) }, 0.2, 2)
					else
						Tween(DropFrame, { Size = UDim2.new(1, 0, 0, 20) }, 0.2, 2)
						Tween(OptionsFrame, { Size = UDim2.new(1, -6, 0, 0) }, 0.2, 2)
						task.delay(0.21, function()
							if not isOpen then OptionsFrame.Visible = false end
						end)
					end
				end

				MainButton.MouseEnter:Connect(function()
					if not isOpen then
						Tween(MainButton, { BackgroundColor3 = T.Button2 }, 0.2, 2)
						Tween(MainBtnStroke, { Color = T.StrokeHover }, 0.2, 2)
					end
				end)
				MainButton.MouseLeave:Connect(function()
					if not isOpen then
						Tween(MainButton, { BackgroundColor3 = T.Button1 }, 0.2, 2)
						Tween(MainBtnStroke, { Color = T.Stroke }, 0.2, 2)
					end
				end)
				MainButton.MouseButton1Click:Connect(toggleDropdown)

				local dropdownConnection
				dropdownConnection = UserInputService.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
						local pos = input.Position
						local framePos = DropFrame.AbsolutePosition
						local frameSize = DropFrame.AbsoluteSize
						if not (pos.X >= framePos.X and pos.X <= framePos.X + frameSize.X and
								pos.Y >= framePos.Y and pos.Y <= framePos.Y + frameSize.Y) then
							if isOpen then toggleDropdown() end
						end
					end
				end)
				DropFrame.Destroying:Connect(function()
					dropdownConnection:Disconnect()
				end)

				local dropdownMethods = {}
				function dropdownMethods:Set(newOption)
					if table.find(options, newOption) then
						selectedOption = newOption
						MainBtnLabel.Text = dropName .. ": " .. tostring(selectedOption)
					end
				end
				function dropdownMethods:Get()
					return selectedOption
				end
				function dropdownMethods:Update(newOptions, newDefault)
					options = newOptions or options
					selectedOption = newDefault or selectedOption or (options and options[1]) or "Select"
					MainBtnLabel.Text = dropName .. ": " .. tostring(selectedOption)
					createOptions()
					if isOpen then toggleDropdown() end
				end
				dropdownMethods.Frame = DropFrame
				return dropdownMethods
			end

			function m:NewColorPicker(pickerName, defaultColor, callback)
				local elementOrder = #parent:GetChildren()
				local currentColor = defaultColor or Color3.fromRGB(255, 255, 255)
				local pickerWindowObj = nil
				local pickerOpening = false

				local ControlFrame = Instance.new("Frame")
				ControlFrame.BackgroundTransparency = 1
				ControlFrame.Name = pickerName .. "_Control"
				ControlFrame.Size = UDim2.new(1, 0, 0, 20)
				ControlFrame.ZIndex = 34
				ControlFrame.LayoutOrder = elementOrder
				ControlFrame.Parent = parent

				local ClickSensor = Instance.new("TextButton")
				ClickSensor.BackgroundTransparency = 1
				ClickSensor.Name = "ClickSensor"
				ClickSensor.Size = UDim2.fromScale(1, 1)
				ClickSensor.Text = ""
				ClickSensor.ZIndex = 34
				ClickSensor.Parent = ControlFrame

				local PickerLabel = Instance.new("TextLabel")
				PickerLabel.BackgroundTransparency = 1
				PickerLabel.Font = Enum.Font.SourceSans
				PickerLabel.Name = "Label"
				PickerLabel.Size = UDim2.fromScale(1, 1)
				PickerLabel.Text = pickerName
				PickerLabel.TextColor3 = T.TextPrimary
				PickerLabel.TextSize = 14
				PickerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				PickerLabel.TextStrokeTransparency = 0.8
				PickerLabel.TextXAlignment = Enum.TextXAlignment.Left
				PickerLabel.ZIndex = 35
				PickerLabel.Parent = ClickSensor

				local PickerLabelPad = Instance.new("UIPadding")
				PickerLabelPad.PaddingLeft = UDim.new(0, 6)
				PickerLabelPad.Parent = PickerLabel

				local ColorDisplay = Instance.new("Frame")
				ColorDisplay.AnchorPoint = Vector2.new(1, 0.5)
				ColorDisplay.BackgroundColor3 = T.Button1
				ColorDisplay.Name = "ColorDisplay"
				ColorDisplay.Position = UDim2.new(1, -3, 0.5, 0)
				ColorDisplay.Size = UDim2.fromOffset(16, 16)
				ColorDisplay.ZIndex = 35
				ColorDisplay.Parent = ClickSensor

				local ColorDisplayCorner = Instance.new("UICorner")
				ColorDisplayCorner.CornerRadius = UDim.new(1, 0)
				ColorDisplayCorner.Parent = ColorDisplay

				local ColorDisplayStroke = Instance.new("UIStroke")
				ColorDisplayStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				ColorDisplayStroke.Color = T.Stroke
				ColorDisplayStroke.LineJoinMode = Enum.LineJoinMode.Round
				ColorDisplayStroke.Thickness = 1
				ColorDisplayStroke.Parent = ColorDisplay

				local ColorInner = Instance.new("Frame")
				ColorInner.BorderSizePixel = 0
				ColorInner.BackgroundColor3 = currentColor
				ColorInner.Name = "ColorInner"
				ColorInner.Position = UDim2.fromOffset(2, 2)
				ColorInner.Size = UDim2.fromOffset(12, 12)
				ColorInner.ZIndex = 35
				ColorInner.Parent = ColorDisplay

				local ColorInnerCorner = Instance.new("UICorner")
				ColorInnerCorner.CornerRadius = UDim.new(1, 0)
				ColorInnerCorner.Parent = ColorInner

				local ColorInnerGrad = Instance.new("UIGradient")
				ColorInnerGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
				ColorInnerGrad.Rotation = 90
				ColorInnerGrad.Parent = ColorInner

				ClickSensor.MouseEnter:Connect(function()
					Tween(ColorDisplay, { BackgroundColor3 = T.Button2 }, 0.2, 2)
					Tween(ColorDisplayStroke, { Color = T.StrokeHover }, 0.2, 2)
				end)
				ClickSensor.MouseLeave:Connect(function()
					Tween(ColorDisplay, { BackgroundColor3 = T.Button1 }, 0.2, 2)
					Tween(ColorDisplayStroke, { Color = T.Stroke }, 0.2, 2)
				end)

				ClickSensor.MouseButton1Click:Connect(function()
					if pickerOpening then return end
					if pickerWindowObj then
						pickerOpening = true
						pickerWindowObj.destroy()
						pickerWindowObj = nil
						task.delay(0.1, function()
							pickerOpening = false
						end)
					else
						pickerOpening = true
						local libPos = Main.AbsolutePosition
						local libSize = Main.AbsoluteSize
						local centerX = libPos.X + (libSize.X / 2) - 150
						local centerY = libPos.Y + (libSize.Y / 2) - 150
						pickerWindowObj = CreatePickerWindow(T, pickerName, currentColor, ScreenGui, function(color)
							currentColor = color
							ColorInner.BackgroundColor3 = color
							if callback then callback(color) end
						end)
						if pickerWindowObj and pickerWindowObj.guiRef then
							pickerWindowObj.guiRef.Position = UDim2.fromOffset(
								math.clamp(centerX, 50, 1200),
								math.clamp(centerY, 50, 700)
							)
						end
						task.delay(0.1, function()
							pickerOpening = false
						end)
					end
				end)

				local pickerObj = { Frame = ControlFrame }
				function pickerObj:Set(color)
					if typeof(color) ~= "Color3" then return end
					currentColor = color
					ColorInner.BackgroundColor3 = color
					if pickerWindowObj then
						pickerWindowObj.setColor(color)
					end
					if callback then callback(color) end
				end
				function pickerObj:Get()
					return currentColor
				end
				return pickerObj
			end

			function m:NewToggleDropdown(tdName, options, defaultStates, callback)
				local elementOrder = #parent:GetChildren()
				local isOpen = false

				local normOptions = {}
				for _, opt in ipairs(options) do
					if type(opt) == "string" then
						table.insert(normOptions, { name = opt, type = "toggle" })
					elseif type(opt) == "table" and type(opt.name) == "string" then
						table.insert(normOptions, {
							name = opt.name,
							type = opt.type or "toggle",
							min = opt.min,
							max = opt.max,
							default = opt.default,
							decimals = (type(opt.decimals) == "number") and opt.decimals or 2,
							defaultColor = opt.defaultColor,
						})
					end
				end

				local allStates = {}
				for _, opt in ipairs(normOptions) do
					local t = opt.type
					local hasToggle = (t == "toggle" or t == "toggleslider" or t == "togglesliderf")
					local hasSlider = (t == "slider" or t == "sliderf" or t == "toggleslider" or t == "togglesliderf")
					local isKeybind = (t == "keybind")
					local isColorPicker = (t == "colorpicker")
					local isButton = (t == "button")
					local initKey = nil
					if isKeybind then
						local defRaw = opt.default
						initKey = defRaw ~= nil and StringToKeyCode(defRaw) or Enum.KeyCode.Unknown
					end
					allStates[opt.name] = {
						toggleValue = hasToggle and ((defaultStates and defaultStates[opt.name] == true) or false) or nil,
						sliderValue = hasSlider and (opt.default or opt.min or 0) or nil,
						keybindValue = isKeybind and initKey or nil,
						colorValue = isColorPicker and (opt.defaultColor or Color3.fromRGB(255, 255, 255)) or nil,
						isButton = isButton or false,
					}
				end

				local DropFrame = Instance.new("Frame")
				DropFrame.Name = tdName .. "_ToggleDropdown"
				DropFrame.BackgroundTransparency = 1
				DropFrame.Size = UDim2.new(1, 0, 0, 20)
				DropFrame.ClipsDescendants = true
				DropFrame.LayoutOrder = elementOrder
				DropFrame.ZIndex = 34
				DropFrame.Parent = parent

				local MainButton = Instance.new("TextButton")
				MainButton.Name = "MainButton"
				MainButton.Parent = DropFrame
				MainButton.BackgroundColor3 = T.Button1
				MainButton.Size = UDim2.new(1, -6, 0, 16)
				MainButton.Position = UDim2.fromOffset(3, 2)
				MainButton.Font = Enum.Font.SourceSans
				MainButton.Text = ""
				MainButton.AutoButtonColor = false
				MainButton.ZIndex = 35

				local MainBtnCorner = Instance.new("UICorner")
				MainBtnCorner.CornerRadius = UDim.new(0, 2)
				MainBtnCorner.Parent = MainButton

				local MainBtnStroke = Instance.new("UIStroke")
				MainBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				MainBtnStroke.Color = T.Stroke
				MainBtnStroke.LineJoinMode = Enum.LineJoinMode.Round
				MainBtnStroke.Thickness = 1
				MainBtnStroke.Parent = MainButton

				local MainBtnLabel = Instance.new("TextLabel")
				MainBtnLabel.BackgroundTransparency = 1
				MainBtnLabel.Font = Enum.Font.SourceSans
				MainBtnLabel.Name = "Label"
				MainBtnLabel.Size = UDim2.fromScale(1, 1)
				MainBtnLabel.Text = tdName
				MainBtnLabel.TextColor3 = T.TextPrimary
				MainBtnLabel.TextSize = 14
				MainBtnLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				MainBtnLabel.TextStrokeTransparency = 0.8
				MainBtnLabel.TextXAlignment = Enum.TextXAlignment.Left
				MainBtnLabel.ZIndex = 36
				MainBtnLabel.Parent = MainButton

				local MainBtnLabelPad = Instance.new("UIPadding")
				MainBtnLabelPad.PaddingLeft = UDim.new(0, 6)
				MainBtnLabelPad.Parent = MainBtnLabel

				local ArrowIcon = Instance.new("ImageLabel")
				ArrowIcon.AnchorPoint = Vector2.new(1, 0.5)
				ArrowIcon.BackgroundTransparency = 1
				ArrowIcon.Image = "rbxassetid://9801473013"
				ArrowIcon.ImageColor3 = T.Secondary
				ArrowIcon.Name = "Arrow"
				ArrowIcon.Position = UDim2.fromScale(1, 0.5)
				ArrowIcon.Rotation = 0
				ArrowIcon.Size = UDim2.fromOffset(16, 16)
				ArrowIcon.ZIndex = 36
				ArrowIcon.Parent = MainButton

				local ArrowIconGrad = Instance.new("UIGradient")
				ArrowIconGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
				ArrowIconGrad.Rotation = 90
				ArrowIconGrad.Parent = ArrowIcon

				local OptionsFrame = Instance.new("Frame")
				OptionsFrame.Name = "OptionsFrame"
				OptionsFrame.Parent = DropFrame
				OptionsFrame.BackgroundColor3 = T.Window3
				OptionsFrame.BackgroundTransparency = 0
				OptionsFrame.BorderSizePixel = 0
				OptionsFrame.Position = UDim2.fromOffset(3, 22)
				OptionsFrame.Size = UDim2.new(1, -6, 0, 0)
				OptionsFrame.Visible = false
				OptionsFrame.ClipsDescendants = true
				OptionsFrame.ZIndex = 36

				local OptionsFrameStroke = Instance.new("UIStroke")
				OptionsFrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				OptionsFrameStroke.Color = T.Stroke
				OptionsFrameStroke.LineJoinMode = Enum.LineJoinMode.Round
				OptionsFrameStroke.Thickness = 1
				OptionsFrameStroke.Parent = OptionsFrame

				local OptionsList = Instance.new("UIListLayout")
				OptionsList.Parent = OptionsFrame
				OptionsList.Padding = UDim.new(0, 0)
				OptionsList.HorizontalAlignment = Enum.HorizontalAlignment.Left
				OptionsList.SortOrder = Enum.SortOrder.LayoutOrder

				local TOGGLE_ROW_H   = 24
				local SLIDER_ONLY_H  = 40
				local SLIDER_EXTRA_H = 26
				local KEYBIND_ROW_H  = 28
				local COLOR_ROW_H    = 24
				local BUTTON_ROW_H   = 24

				local rows = {}
				local totalOptionsHeight = 0
				local keybindInputConns = {}
				local colorPickerWindows = {}
				local colorPickerOpening = {}

				for i, opt in ipairs(normOptions) do
					local t = opt.type
					local hasToggle = (t == "toggle" or t == "toggleslider" or t == "togglesliderf")
					local hasSlider = (t == "slider" or t == "sliderf" or t == "toggleslider" or t == "togglesliderf")
					local isKeybind = (t == "keybind")
					local isColorPicker = (t == "colorpicker")
					local isButton = (t == "button")
					local isFloat   = (t == "sliderf" or t == "togglesliderf")
					local decimals  = math.clamp(math.floor(opt.decimals or 0), 0, 10)
					local fmt       = "%." .. tostring(decimals) .. "f"

					local rowH
					if isColorPicker then
						rowH = COLOR_ROW_H
					elseif isKeybind then
						rowH = KEYBIND_ROW_H
					elseif isButton then
						rowH = BUTTON_ROW_H
					elseif hasToggle and hasSlider then
						rowH = TOGGLE_ROW_H + SLIDER_EXTRA_H
					elseif hasSlider then
						rowH = SLIDER_ONLY_H
					else
						rowH = TOGGLE_ROW_H
					end
					totalOptionsHeight = totalOptionsHeight + rowH

					local Row = Instance.new("Frame")
					Row.Name = opt.name .. "_Row"
					Row.Parent = OptionsFrame
					Row.BackgroundTransparency = 1
					Row.Size = UDim2.new(1, 0, 0, rowH)
					Row.LayoutOrder = i
					Row.ZIndex = 37

					if i > 1 then
						local Sep = Instance.new("Frame")
						Sep.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						Sep.BackgroundTransparency = 0.9
						Sep.BorderSizePixel = 0
						Sep.Size = UDim2.new(1, -12, 0, 1)
						Sep.Position = UDim2.fromOffset(6, 0)
						Sep.ZIndex = 37
						Sep.Parent = Row
					end

					if isButton then
						local ControlFrame = Instance.new("Frame")
						ControlFrame.BackgroundTransparency = 1
						ControlFrame.Name = opt.name .. "_Control"
						ControlFrame.Size = UDim2.new(1, 0, 0, 20)
						ControlFrame.ZIndex = 38
						ControlFrame.Parent = Row

						local ClickSensor = Instance.new("TextButton")
						ClickSensor.BackgroundTransparency = 1
						ClickSensor.Name = "ClickSensor"
						ClickSensor.Size = UDim2.fromScale(1, 1)
						ClickSensor.Text = ""
						ClickSensor.ZIndex = 38
						ClickSensor.Parent = ControlFrame

						local BtnLabel = Instance.new("TextLabel")
						BtnLabel.BackgroundTransparency = 1
						BtnLabel.Font = Enum.Font.SourceSans
						BtnLabel.Name = "Label"
						BtnLabel.Size = UDim2.fromScale(1, 1)
						BtnLabel.Text = opt.name
						BtnLabel.TextColor3 = T.TextPrimary
						BtnLabel.TextSize = 14
						BtnLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
						BtnLabel.TextStrokeTransparency = 0.8
						BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
						BtnLabel.ZIndex = 39
						BtnLabel.Parent = ClickSensor

						local BtnLabelPad = Instance.new("UIPadding")
						BtnLabelPad.PaddingLeft = UDim.new(0, 6)
						BtnLabelPad.Parent = BtnLabel

						local BtnFrame = Instance.new("Frame")
						BtnFrame.AnchorPoint = Vector2.new(1, 0.5)
						BtnFrame.BackgroundColor3 = T.Button1
						BtnFrame.Name = "Button"
						BtnFrame.Position = UDim2.new(1, -3, 0.5, 0)
						BtnFrame.Size = UDim2.fromOffset(16, 16)
						BtnFrame.ZIndex = 39
						BtnFrame.Parent = ClickSensor

						local BtnCorner = Instance.new("UICorner")
						BtnCorner.CornerRadius = UDim.new(0, 2)
						BtnCorner.Parent = BtnFrame

						local BtnStroke = Instance.new("UIStroke")
						BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						BtnStroke.Color = T.Stroke
						BtnStroke.LineJoinMode = Enum.LineJoinMode.Round
						BtnStroke.Thickness = 1
						BtnStroke.Parent = BtnFrame

						local BtnIcon = Instance.new("ImageLabel")
						BtnIcon.Active = false
						BtnIcon.BackgroundTransparency = 1
						BtnIcon.BorderSizePixel = 0
						BtnIcon.Image = "rbxassetid://9801455339"
						BtnIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
						BtnIcon.Name = "Icon"
						BtnIcon.Rotation = 360
						BtnIcon.Size = UDim2.fromScale(1, 1)
						BtnIcon.ZIndex = 39
						BtnIcon.Parent = BtnFrame

						local BtnIconGrad = Instance.new("UIGradient")
						BtnIconGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
						BtnIconGrad.Rotation = 90
						BtnIconGrad.Parent = BtnIcon

						ClickSensor.MouseEnter:Connect(function()
							Tween(BtnFrame, { BackgroundColor3 = T.Button2 }, 0.2, 2)
							Tween(BtnStroke, { Color = T.StrokeHover }, 0.2, 2)
						end)
						ClickSensor.MouseLeave:Connect(function()
							Tween(BtnFrame, { BackgroundColor3 = T.Button1 }, 0.2, 2)
							Tween(BtnStroke, { Color = T.Stroke }, 0.2, 2)
						end)
						ClickSensor.MouseButton1Click:Connect(function()
							if BtnFrame.BackgroundColor3 ~= T.Button3 then
								BtnFrame.BackgroundColor3 = T.Button3
								Tween(BtnFrame, { BackgroundColor3 = T.Button1 }, 1, 2)
							end
							BtnIcon.ImageColor3 = T.Primary
							Tween(BtnIcon, { ImageColor3 = Color3.fromRGB(255, 255, 255) }, 1, 2)
							if callback then
								callback(opt.name, nil, nil, allStates)
							end
						end)

						rows[opt.name] = rows[opt.name] or {}
						rows[opt.name].btnClick = ClickSensor
						rows[opt.name].row = Row

					elseif isColorPicker then
						local initColor = allStates[opt.name].colorValue
						local cpWindowObj = nil
						colorPickerOpening[opt.name] = false

						local CPLabel = Instance.new("TextLabel")
						CPLabel.BackgroundTransparency = 1
						CPLabel.Font = Enum.Font.SourceSans
						CPLabel.Name = "Label"
						CPLabel.Position = UDim2.fromOffset(8, 0)
						CPLabel.Size = UDim2.new(1, -50, 1, 0)
						CPLabel.Text = opt.name
						CPLabel.TextColor3 = T.TextPrimary
						CPLabel.TextSize = 14
						CPLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
						CPLabel.TextStrokeTransparency = 0.8
						CPLabel.TextXAlignment = Enum.TextXAlignment.Left
						CPLabel.ZIndex = 38
						CPLabel.Parent = Row

						local CPDisplay = Instance.new("TextButton")
						CPDisplay.AnchorPoint = Vector2.new(1, 0.5)
						CPDisplay.BackgroundColor3 = T.Button1
						CPDisplay.Name = "ColorDisplay"
						CPDisplay.Position = UDim2.new(1, -6, 0.5, 0)
						CPDisplay.Size = UDim2.fromOffset(16, 16)
						CPDisplay.Text = ""
						CPDisplay.AutoButtonColor = false
						CPDisplay.ZIndex = 38
						CPDisplay.Parent = Row

						local CPDisplayCorner = Instance.new("UICorner")
						CPDisplayCorner.CornerRadius = UDim.new(1, 0)
						CPDisplayCorner.Parent = CPDisplay

						local CPDisplayStroke = Instance.new("UIStroke")
						CPDisplayStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						CPDisplayStroke.Color = T.Stroke
						CPDisplayStroke.LineJoinMode = Enum.LineJoinMode.Round
						CPDisplayStroke.Thickness = 1
						CPDisplayStroke.Parent = CPDisplay

						local CPInner = Instance.new("Frame")
						CPInner.BorderSizePixel = 0
						CPInner.BackgroundColor3 = initColor
						CPInner.Position = UDim2.fromOffset(2, 2)
						CPInner.Size = UDim2.fromOffset(12, 12)
						CPInner.ZIndex = 38
						CPInner.Parent = CPDisplay

						local CPInnerCorner = Instance.new("UICorner")
						CPInnerCorner.CornerRadius = UDim.new(1, 0)
						CPInnerCorner.Parent = CPInner

						local CPInnerGrad = Instance.new("UIGradient")
						CPInnerGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
						CPInnerGrad.Rotation = 90
						CPInnerGrad.Parent = CPInner

						CPDisplay.MouseEnter:Connect(function()
							Tween(CPDisplay, { BackgroundColor3 = T.Button2 }, 0.2, 2)
							Tween(CPDisplayStroke, { Color = T.StrokeHover }, 0.2, 2)
						end)
						CPDisplay.MouseLeave:Connect(function()
							Tween(CPDisplay, { BackgroundColor3 = T.Button1 }, 0.2, 2)
							Tween(CPDisplayStroke, { Color = T.Stroke }, 0.2, 2)
						end)

						local optName = opt.name
						CPDisplay.MouseButton1Click:Connect(function()
							if colorPickerOpening[optName] then return end
							if cpWindowObj then
								colorPickerOpening[optName] = true
								cpWindowObj.destroy()
								cpWindowObj = nil
								colorPickerWindows[optName] = nil
								task.delay(0.1, function()
									colorPickerOpening[optName] = false
								end)
							else
								colorPickerOpening[optName] = true
								local libPos = Main.AbsolutePosition
								local libSize = Main.AbsoluteSize
								local centerX = libPos.X + (libSize.X / 2) - 150
								local centerY = libPos.Y + (libSize.Y / 2) - 150
								cpWindowObj = CreatePickerWindow(T, optName, allStates[optName].colorValue, ScreenGui, function(color)
									allStates[optName].colorValue = color
									CPInner.BackgroundColor3 = color
									if callback then
										callback(optName, nil, nil, allStates)
									end
								end)
								if cpWindowObj and cpWindowObj.guiRef then
									cpWindowObj.guiRef.Position = UDim2.fromOffset(
										math.clamp(centerX, 50, 1200),
										math.clamp(centerY, 50, 700)
									)
								end
								colorPickerWindows[optName] = cpWindowObj
								task.delay(0.1, function()
									colorPickerOpening[optName] = false
								end)
							end
						end)

						rows[opt.name] = rows[opt.name] or {}
						rows[opt.name].cpInner = CPInner
						rows[opt.name].getCPWindow = function() return cpWindowObj end
						rows[opt.name].row = Row

					elseif hasToggle then
						local RowLabel = Instance.new("TextLabel")
						RowLabel.BackgroundTransparency = 1
						RowLabel.Font = Enum.Font.SourceSans
						RowLabel.Name = "Label"
						RowLabel.Position = UDim2.fromOffset(8, 0)
						RowLabel.Size = UDim2.new(1, -50, 0, TOGGLE_ROW_H)
						RowLabel.Text = opt.name
						RowLabel.TextColor3 = T.TextPrimary
						RowLabel.TextSize = 14
						RowLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
						RowLabel.TextStrokeTransparency = 0.8
						RowLabel.TextXAlignment = Enum.TextXAlignment.Left
						RowLabel.ZIndex = 38
						RowLabel.Parent = Row

						local TogBtn = Instance.new("TextButton")
						TogBtn.AnchorPoint = Vector2.new(1, 0)
						TogBtn.BackgroundColor3 = T.Button1
						TogBtn.Name = "Toggle"
						TogBtn.Position = UDim2.new(1, -6, 0, 4)
						TogBtn.Size = UDim2.fromOffset(16, 16)
						TogBtn.Text = ""
						TogBtn.AutoButtonColor = false
						TogBtn.ZIndex = 38
						TogBtn.Parent = Row

						local TBCorner = Instance.new("UICorner")
						TBCorner.CornerRadius = UDim.new(0, 2)
						TBCorner.Parent = TogBtn

						local TBStroke = Instance.new("UIStroke")
						TBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						TBStroke.Color = T.Stroke
						TBStroke.LineJoinMode = Enum.LineJoinMode.Round
						TBStroke.Thickness = 1
						TBStroke.Parent = TogBtn

						local TBIcon = Instance.new("ImageLabel")
						TBIcon.Active = false
						TBIcon.BackgroundTransparency = 1
						TBIcon.BorderSizePixel = 0
						TBIcon.Image = "rbxassetid://9801456486"
						TBIcon.ImageColor3 = T.Secondary
						TBIcon.Name = "Icon"
						TBIcon.Rotation = 360
						TBIcon.Size = UDim2.fromScale(1, 1)
						TBIcon.ZIndex = 38
						TBIcon.Parent = TogBtn

						local TBIconGrad = Instance.new("UIGradient")
						TBIconGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
						TBIconGrad.Rotation = 90
						TBIconGrad.Parent = TBIcon

						local function updateToggleVisual(state)
							if state then
								TBIcon.Image = "rbxassetid://9801457539"
								Tween(TBIcon, { Rotation = 0, ImageColor3 = T.Primary }, 0.3, 2)
								Tween(TogBtn, { BackgroundColor3 = T.Button2 }, 0.2, 2)
							else
								TBIcon.Image = "rbxassetid://9801456486"
								Tween(TBIcon, { Rotation = 360, ImageColor3 = T.Secondary }, 0.3, 2)
								Tween(TogBtn, { BackgroundColor3 = T.Button1 }, 0.2, 2)
							end
						end
						updateToggleVisual(allStates[opt.name].toggleValue)

						TogBtn.MouseButton1Click:Connect(function()
							allStates[opt.name].toggleValue = not allStates[opt.name].toggleValue
							updateToggleVisual(allStates[opt.name].toggleValue)
							if callback then
								callback(opt.name, allStates[opt.name].toggleValue, allStates[opt.name].sliderValue, allStates)
							end
						end)

						rows[opt.name] = rows[opt.name] or {}
						rows[opt.name].toggleBtn = TogBtn
						rows[opt.name].updateToggleVisual = updateToggleVisual
					end

					if hasSlider then
						local sliderMin     = opt.min or 0
						local sliderMax     = opt.max or 100
						local sliderDefault = allStates[opt.name].sliderValue
						local sliderDragging = false
						local sliderYOffset  = hasToggle and TOGGLE_ROW_H or 6

						local SliderText = Instance.new("TextLabel")
						SliderText.BackgroundTransparency = 1
						SliderText.Font = Enum.Font.SourceSans
						SliderText.TextColor3 = T.TextDim
						SliderText.TextSize = 12
						SliderText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
						SliderText.TextStrokeTransparency = 0.8
						SliderText.ZIndex = 38
						SliderText.Parent = Row

						if hasToggle then
							SliderText.Text = isFloat and string.format(fmt, sliderDefault) or tostring(math.floor(sliderDefault))
							SliderText.TextXAlignment = Enum.TextXAlignment.Right
							SliderText.Position = UDim2.new(0, 8, 0, sliderYOffset)
							SliderText.Size = UDim2.new(1, -16, 0, 12)
						else
							SliderText.Text = opt.name .. ": " .. (isFloat and string.format(fmt, sliderDefault) or tostring(math.floor(sliderDefault)))
							SliderText.TextXAlignment = Enum.TextXAlignment.Left
							SliderText.Position = UDim2.new(0, 8, 0, sliderYOffset)
							SliderText.Size = UDim2.new(1, -16, 0, 14)
						end

						local barYOffset = sliderYOffset + (hasToggle and 12 or 16)

						local SliderBar = Instance.new("Frame")
						SliderBar.BackgroundColor3 = T.Button1
						SliderBar.Name = "Bar"
						SliderBar.Position = UDim2.new(0, 8, 0, barYOffset)
						SliderBar.Size = UDim2.new(1, -16, 0, 6)
						SliderBar.ZIndex = 38
						SliderBar.Parent = Row

						local SliderBarCorner = Instance.new("UICorner")
						SliderBarCorner.CornerRadius = UDim.new(0, 2)
						SliderBarCorner.Parent = SliderBar

						local SliderBarStroke = Instance.new("UIStroke")
						SliderBarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						SliderBarStroke.Color = T.Stroke
						SliderBarStroke.LineJoinMode = Enum.LineJoinMode.Round
						SliderBarStroke.Thickness = 1
						SliderBarStroke.Parent = SliderBar

						local initPercent = math.clamp((sliderDefault - sliderMin) / (sliderMax - sliderMin), 0, 1)
						local SliderFill = Instance.new("Frame")
						SliderFill.BackgroundColor3 = T.Primary
						SliderFill.BackgroundTransparency = 0.6
						SliderFill.Name = "Fill"
						SliderFill.Size = UDim2.fromScale(initPercent, 1)
						SliderFill.ZIndex = 39
						SliderFill.Parent = SliderBar

						local SliderFillCorner = Instance.new("UICorner")
						SliderFillCorner.CornerRadius = UDim.new(0, 2)
						SliderFillCorner.Parent = SliderFill

						local SliderFillGrad = Instance.new("UIGradient")
						SliderFillGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
						SliderFillGrad.Rotation = 90
						SliderFillGrad.Parent = SliderFill

						local sliderTarget = SliderFill.Size
						local sliderACon

						local function updateSliderVisual(value)
							local pct = math.clamp((value - sliderMin) / (sliderMax - sliderMin), 0, 1)
							sliderTarget = UDim2.fromScale(pct, 1)
							if hasToggle then
								SliderText.Text = isFloat and string.format(fmt, value) or tostring(math.floor(value))
							else
								SliderText.Text = opt.name .. ": " .. (isFloat and string.format(fmt, value) or tostring(math.floor(value)))
							end
							allStates[opt.name].sliderValue = value
							if callback then
								callback(opt.name, allStates[opt.name].toggleValue, value, allStates)
							end
						end

						SliderBar.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								sliderDragging = true
								local pos = input.Position.X - SliderBar.AbsolutePosition.X
								local pct = math.clamp(pos / SliderBar.AbsoluteSize.X, 0, 1)
								updateSliderVisual(sliderMin + (sliderMax - sliderMin) * pct)
								sliderACon = RunService.RenderStepped:Connect(function(dt)
									SliderFill.Size = SliderFill.Size:lerp(sliderTarget, 1 - 1e-12 ^ dt)
								end)
							end
						end)
						SliderBar.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								sliderDragging = false
								if sliderACon then sliderACon:Disconnect() end
								Tween(SliderFill, { Size = sliderTarget }, 0.2, 2)
							end
						end)
						UserInputService.InputChanged:Connect(function(input)
							if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
								local pos = input.Position.X - SliderBar.AbsolutePosition.X
								local pct = math.clamp(pos / SliderBar.AbsoluteSize.X, 0, 1)
								updateSliderVisual(sliderMin + (sliderMax - sliderMin) * pct)
							end
						end)

						rows[opt.name] = rows[opt.name] or {}
						rows[opt.name].sliderFill = SliderFill
						rows[opt.name].sliderText = SliderText
						rows[opt.name].updateSliderVisual = updateSliderVisual
						rows[opt.name].sliderMin = sliderMin
						rows[opt.name].sliderMax = sliderMax
					end

					if isKeybind then
						local currentKey = allStates[opt.name].keybindValue
						local listeningKB = false

						local KBLabel = Instance.new("TextLabel")
						KBLabel.BackgroundTransparency = 1
						KBLabel.Font = Enum.Font.SourceSans
						KBLabel.Name = "Label"
						KBLabel.Position = UDim2.fromOffset(8, 0)
						KBLabel.Size = UDim2.new(0.55, 0, 1, 0)
						KBLabel.Text = opt.name
						KBLabel.TextColor3 = T.TextPrimary
						KBLabel.TextSize = 14
						KBLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
						KBLabel.TextStrokeTransparency = 0.8
						KBLabel.TextXAlignment = Enum.TextXAlignment.Left
						KBLabel.ZIndex = 38
						KBLabel.Parent = Row

						local KBButton = Instance.new("TextButton")
						KBButton.AnchorPoint = Vector2.new(1, 0.5)
						KBButton.BackgroundColor3 = T.Button1
						KBButton.Name = "KeybindButton"
						KBButton.Position = UDim2.new(1, -6, 0.5, 0)
						KBButton.Size = UDim2.new(0, 72, 0, 16)
						KBButton.Font = Enum.Font.SourceSans
						KBButton.Text = (currentKey and currentKey ~= Enum.KeyCode.Unknown) and currentKey.Name or "[None]"
						KBButton.TextColor3 = T.TextDim
						KBButton.TextSize = 13
						KBButton.AutoButtonColor = false
						KBButton.ZIndex = 38
						KBButton.Parent = Row

						local KBCorner = Instance.new("UICorner")
						KBCorner.CornerRadius = UDim.new(0, 2)
						KBCorner.Parent = KBButton

						local KBStroke = Instance.new("UIStroke")
						KBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						KBStroke.Color = T.Stroke
						KBStroke.LineJoinMode = Enum.LineJoinMode.Round
						KBStroke.Thickness = 1
						KBStroke.Parent = KBButton

						KBButton.MouseEnter:Connect(function()
							if not listeningKB then
								Tween(KBButton, { BackgroundColor3 = T.Button2 }, 0.2, 2)
								Tween(KBStroke, { Color = T.StrokeHover }, 0.2, 2)
							end
						end)
						KBButton.MouseLeave:Connect(function()
							if not listeningKB then
								Tween(KBButton, { BackgroundColor3 = T.Button1 }, 0.2, 2)
								Tween(KBStroke, { Color = T.Stroke }, 0.2, 2)
							end
						end)
						KBButton.MouseButton1Click:Connect(function()
							if listeningKB then return end
							listeningKB = true
							KBButton.Text = "..."
							Tween(KBButton, { BackgroundColor3 = T.Button3, TextColor3 = T.Primary }, 0.15, 2)
						end)

						local kbConn
						kbConn = UserInputService.InputBegan:Connect(function(input)
							if not listeningKB then return end
							if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
							local ignoredKB = {
								Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift,
								Enum.KeyCode.LeftControl, Enum.KeyCode.RightControl,
								Enum.KeyCode.LeftAlt, Enum.KeyCode.RightAlt,
								Enum.KeyCode.Unknown,
							}
							local skip = false
							for _, k in ipairs(ignoredKB) do
								if input.KeyCode == k then skip = true break end
							end
							if skip then return end
							currentKey = input.KeyCode
							allStates[opt.name].keybindValue = currentKey
							listeningKB = false
							KBButton.Text = currentKey.Name
							Tween(KBButton, { BackgroundColor3 = T.Button1, TextColor3 = T.TextDim }, 0.15, 2)
							if callback then
								callback(opt.name, currentKey, nil, allStates)
							end
						end)
						table.insert(keybindInputConns, kbConn)

						rows[opt.name] = rows[opt.name] or {}
						rows[opt.name].kbButton = KBButton
						rows[opt.name].getCurrentKey = function() return currentKey end
						rows[opt.name].setKey = function(newKey)
							currentKey = newKey
							allStates[opt.name].keybindValue = newKey
							KBButton.Text = (newKey and newKey ~= Enum.KeyCode.Unknown) and newKey.Name or "[None]"
						end
					end

					rows[opt.name] = rows[opt.name] or {}
					rows[opt.name].row = Row
				end

				local function toggleOpen()
					isOpen = not isOpen
					Tween(ArrowIcon, { Rotation = isOpen and 180 or 0, ImageColor3 = isOpen and T.Primary or T.Secondary }, 0.2, 2)
					if isOpen then
						OptionsFrame.Visible = true
						Tween(DropFrame, { Size = UDim2.new(1, 0, 0, 20 + 6 + totalOptionsHeight) }, 0.2, 2)
						Tween(OptionsFrame, { Size = UDim2.new(1, -6, 0, totalOptionsHeight) }, 0.2, 2)
					else
						Tween(DropFrame, { Size = UDim2.new(1, 0, 0, 20) }, 0.2, 2)
						Tween(OptionsFrame, { Size = UDim2.new(1, -6, 0, 0) }, 0.2, 2)
						task.delay(0.21, function()
							if not isOpen then OptionsFrame.Visible = false end
						end)
					end
				end

				MainButton.MouseEnter:Connect(function()
					if not isOpen then
						Tween(MainButton, { BackgroundColor3 = T.Button2 }, 0.2, 2)
						Tween(MainBtnStroke, { Color = T.StrokeHover }, 0.2, 2)
					end
				end)
				MainButton.MouseLeave:Connect(function()
					if not isOpen then
						Tween(MainButton, { BackgroundColor3 = T.Button1 }, 0.2, 2)
						Tween(MainBtnStroke, { Color = T.Stroke }, 0.2, 2)
					end
				end)
				MainButton.MouseButton1Click:Connect(toggleOpen)

				local outsideConn
				outsideConn = UserInputService.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
						local pos = input.Position
						local fp = DropFrame.AbsolutePosition
						local fs = DropFrame.AbsoluteSize
						local shouldClose = true

						for _, cpw in pairs(colorPickerWindows) do
							if cpw and cpw.guiRef and cpw.guiRef.Parent then
								local cpPos = cpw.guiRef.AbsolutePosition
								local cpSize = cpw.guiRef.AbsoluteSize
								if pos.X >= cpPos.X and pos.X <= cpPos.X + cpSize.X and
								   pos.Y >= cpPos.Y and pos.Y <= cpPos.Y + cpSize.Y then
									shouldClose = false
									break
								end
							end
						end

						if shouldClose and not (pos.X >= fp.X and pos.X <= fp.X + fs.X and
								pos.Y >= fp.Y and pos.Y <= fp.Y + fs.Y) then
							toggleOpen()
						end
					end
				end)

				DropFrame.Destroying:Connect(function()
					outsideConn:Disconnect()
					for _, c in ipairs(keybindInputConns) do c:Disconnect() end
					for _, cpw in pairs(colorPickerWindows) do
						if cpw then pcall(cpw.destroy) end
					end
				end)

				local methods = {}
				methods.Frame = DropFrame

				function methods:SetToggle(optName, value)
					if allStates[optName] == nil or allStates[optName].toggleValue == nil then return end
					allStates[optName].toggleValue = value
					if rows[optName] and rows[optName].updateToggleVisual then
						rows[optName].updateToggleVisual(value)
					end
					if callback then
						callback(optName, value, allStates[optName].sliderValue, allStates)
					end
				end

				function methods:SetSlider(optName, value)
					if allStates[optName] == nil or allStates[optName].sliderValue == nil then return end
					local r = rows[optName]
					if not r then return end
					value = math.clamp(value, r.sliderMin, r.sliderMax)
					if r.updateSliderVisual then r.updateSliderVisual(value) end
				end

				function methods:SetKeybind(optName, keyValue)
					if allStates[optName] == nil or allStates[optName].keybindValue == nil then return end
					local newKey = StringToKeyCode(keyValue)
					local r = rows[optName]
					if r and r.setKey then r.setKey(newKey) end
					if callback then callback(optName, newKey, nil, allStates) end
				end

				function methods:SetColor(optName, color)
					if allStates[optName] == nil or allStates[optName].colorValue == nil then return end
					if typeof(color) ~= "Color3" then return end
					allStates[optName].colorValue = color
					local r = rows[optName]
					if r and r.cpInner then r.cpInner.BackgroundColor3 = color end
					local cpw = colorPickerWindows[optName]
					if cpw then cpw.setColor(color) end
					if callback then callback(optName, nil, nil, allStates) end
				end

				function methods:GetToggle(optName)
					if allStates[optName] then return allStates[optName].toggleValue end
				end

				function methods:GetSlider(optName)
					if allStates[optName] then return allStates[optName].sliderValue end
				end

				function methods:GetKeybind(optName)
					if allStates[optName] then return allStates[optName].keybindValue end
				end

				function methods:GetColor(optName)
					if allStates[optName] then return allStates[optName].colorValue end
				end

				function methods:GetAll()
					local copy = {}
					for k, v in pairs(allStates) do
						copy[k] = {
							toggleValue = v.toggleValue,
							sliderValue = v.sliderValue,
							keybindValue = v.keybindValue,
							colorValue = v.colorValue,
						}
					end
					return copy
				end

				function methods:Set(optName, value)
					self:SetToggle(optName, value)
				end
				function methods:Get(optName)
					if optName then return allStates[optName] and allStates[optName].toggleValue end
					local copy = {}
					for k, v in pairs(allStates) do copy[k] = v.toggleValue end
					return copy
				end

				return methods
			end

			function m:NewTextBox(tbName, placeholder, callback)
				local elementOrder = #parent:GetChildren()

				local ControlFrame = Instance.new("Frame")
				ControlFrame.BackgroundTransparency = 1
				ControlFrame.Name = tbName .. "_Control"
				ControlFrame.Size = UDim2.new(1, 0, 0, 20)
				ControlFrame.ZIndex = 34
				ControlFrame.LayoutOrder = elementOrder
				ControlFrame.Parent = parent

				local TextBox = Instance.new("TextBox")
				TextBox.Name = "Input"
				TextBox.Parent = ControlFrame
				TextBox.BackgroundColor3 = T.Window1
				TextBox.BackgroundTransparency = 0
				TextBox.Position = UDim2.fromOffset(3, 2)
				TextBox.Size = UDim2.new(1, -6, 0, 16)
				TextBox.Font = Enum.Font.SourceSans
				TextBox.PlaceholderText = placeholder or "..."
				TextBox.PlaceholderColor3 = T.TextDim
				TextBox.Text = ""
				TextBox.TextColor3 = T.TextPrimary
				TextBox.TextSize = 14
				TextBox.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				TextBox.TextStrokeTransparency = 0.8
				TextBox.TextXAlignment = Enum.TextXAlignment.Left
				TextBox.TextTruncate = Enum.TextTruncate.AtEnd
				TextBox.ClearTextOnFocus = false
				TextBox.ZIndex = 35

				local TBCorner = Instance.new("UICorner")
				TBCorner.CornerRadius = UDim.new(0, 2)
				TBCorner.Parent = TextBox

				local TBStroke = Instance.new("UIStroke")
				TBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				TBStroke.Color = T.Stroke
				TBStroke.LineJoinMode = Enum.LineJoinMode.Round
				TBStroke.Thickness = 1
				TBStroke.Parent = TextBox

				local TBPad = Instance.new("UIPadding")
				TBPad.PaddingLeft = UDim.new(0, 5)
				TBPad.Parent = TextBox

				TextBox.Focused:Connect(function()
					Tween(TextBox, { BackgroundColor3 = T.Button3, TextColor3 = T.Primary }, 0.2, 2)
					Tween(TBStroke, { Color = T.StrokeHover }, 0.2, 2)
				end)
				TextBox.FocusLost:Connect(function(enterPressed)
					Tween(TextBox, { BackgroundColor3 = T.Window1, TextColor3 = T.TextPrimary }, 0.2, 2)
					Tween(TBStroke, { Color = T.Stroke }, 0.2, 2)
					if enterPressed and callback then
						callback(TextBox.Text)
					end
				end)

				local methods = {}
				function methods:Set(newText)
					TextBox.Text = tostring(newText)
					if callback then callback(TextBox.Text) end
				end
				function methods:Get()
					return TextBox.Text
				end
				methods.Frame = ControlFrame
				return methods
			end

			function m:NewKeybind(kbName, defaultKey, callback)
				local elementOrder = #parent:GetChildren()
				local currentKey = StringToKeyCode(defaultKey)
				local listening = false
				local focused = false

				local ControlFrame = Instance.new("Frame")
				ControlFrame.BackgroundTransparency = 1
				ControlFrame.Name = kbName .. "_Control"
				ControlFrame.Size = UDim2.new(1, 0, 0, 20)
				ControlFrame.ZIndex = 34
				ControlFrame.LayoutOrder = elementOrder
				ControlFrame.Parent = parent

				local BackButton = Instance.new("TextButton")
				BackButton.BackgroundTransparency = 1
				BackButton.Name = "Back"
				BackButton.Size = UDim2.fromScale(1, 1)
				BackButton.Text = ""
				BackButton.ZIndex = 34
				BackButton.Parent = ControlFrame

				local KBLabel = Instance.new("TextLabel")
				KBLabel.BackgroundTransparency = 1
				KBLabel.Font = Enum.Font.SourceSans
				KBLabel.Name = "Label"
				KBLabel.Size = UDim2.fromScale(1, 1)
				KBLabel.Text = kbName
				KBLabel.TextColor3 = T.TextPrimary
				KBLabel.TextSize = 14
				KBLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				KBLabel.TextStrokeTransparency = 0.8
				KBLabel.TextXAlignment = Enum.TextXAlignment.Left
				KBLabel.ZIndex = 35
				KBLabel.Parent = BackButton

				local KBLabelPad = Instance.new("UIPadding")
				KBLabelPad.PaddingLeft = UDim.new(0, 6)
				KBLabelPad.Parent = KBLabel

				local KBDisplay = Instance.new("TextLabel")
				KBDisplay.AnchorPoint = Vector2.new(1, 0.5)
				KBDisplay.BackgroundTransparency = 1
				KBDisplay.Font = Enum.Font.SourceSans
				KBDisplay.Name = "Hotkey"
				KBDisplay.Position = UDim2.new(1, -3, 0.5, 0)
				KBDisplay.Size = UDim2.fromOffset(80, 16)
				KBDisplay.Text = ("[%s]"):format(currentKey.Name ~= "Unknown" and currentKey.Name or "None")
				KBDisplay.TextColor3 = T.TextDim
				KBDisplay.TextSize = 13
				KBDisplay.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				KBDisplay.TextStrokeTransparency = 0.8
				KBDisplay.TextXAlignment = Enum.TextXAlignment.Right
				KBDisplay.ZIndex = 35
				KBDisplay.Parent = BackButton

				BackButton.MouseEnter:Connect(function()
					focused = true
					if listening then
						Tween(KBDisplay, { TextColor3 = T.Primary }, 0.2, 2)
					else
						Tween(KBDisplay, { TextColor3 = T.TextPrimary }, 0.2, 2)
					end
				end)
				BackButton.MouseLeave:Connect(function()
					focused = false
					if not listening then
						Tween(KBDisplay, { TextColor3 = T.TextDim }, 0.2, 2)
					end
				end)
				BackButton.MouseButton1Click:Connect(function()
					listening = true
					KBDisplay.Text = "..."
					Tween(KBDisplay, { TextColor3 = T.Primary }, 0.2, 2)
				end)

				local inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if listening and not gameProcessed then
						if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
						local newKey = input.KeyCode
						if newKey == Enum.KeyCode.Unknown then return end
						currentKey = newKey
						KBDisplay.Text = ("[%s]"):format(newKey.Name)
						Tween(KBDisplay, { TextColor3 = focused and T.TextPrimary or T.TextDim }, 0.2, 2)
						listening = false
						if callback then callback(currentKey) end
					elseif not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
						if callback and not listening then callback(currentKey) end
					end
				end)

				ControlFrame.AncestryChanged:Connect(function(_, parent)
					if not parent and inputConnection then
						inputConnection:Disconnect()
					end
				end)

				local keybindObject = {}
				keybindObject.Frame = ControlFrame
				function keybindObject:Set(newKey)
					currentKey = StringToKeyCode(newKey)
					KBDisplay.Text = ("[%s]"):format(currentKey.Name ~= "Unknown" and currentKey.Name or "None")
					if callback then callback(currentKey) end
				end
				function keybindObject:Get()
					return currentKey
				end
				return keybindObject
			end

				return m
			end

			local SectionFunctions = makeSectionAPI(SectionContent)

			if columns then
				local LeftFrame = Instance.new("Frame")
				LeftFrame.Name = "Left"
				LeftFrame.Parent = SectionContent
				LeftFrame.BackgroundTransparency = 1
				LeftFrame.Size = UDim2.new(0.5, -2, 0, 0)
				LeftFrame.AutomaticSize = Enum.AutomaticSize.Y
				LeftFrame.ZIndex = 33

				do
					local colList = Instance.new("UIListLayout")
					colList.Parent = LeftFrame
					colList.Padding = UDim.new(0, 4)
					colList.SortOrder = Enum.SortOrder.LayoutOrder
					colList.FillDirection = Enum.FillDirection.Vertical
					colList.HorizontalAlignment = Enum.HorizontalAlignment.Center
				end

				local RightFrame = Instance.new("Frame")
				RightFrame.Name = "Right"
				RightFrame.Parent = SectionContent
				RightFrame.BackgroundTransparency = 1
				RightFrame.Size = UDim2.new(0.5, -2, 0, 0)
				RightFrame.AutomaticSize = Enum.AutomaticSize.Y
				RightFrame.ZIndex = 33

				do
					local colList = Instance.new("UIListLayout")
					colList.Parent = RightFrame
					colList.Padding = UDim.new(0, 4)
					colList.SortOrder = Enum.SortOrder.LayoutOrder
					colList.FillDirection = Enum.FillDirection.Vertical
					colList.HorizontalAlignment = Enum.HorizontalAlignment.Center
				end

				SectionFunctions.Left = makeSectionAPI(LeftFrame)
				SectionFunctions.Right = makeSectionAPI(RightFrame)
			end

			return SectionFunctions
		end

		return TabFunctions
	end

	return {
		AddTab = SimpleKavo.AddTab,
		ToggleUI = function()
			ScreenGui.Enabled = not ScreenGui.Enabled
		end,
		Destroy = function()
			ScreenGui:Destroy()
		end,
		Minimize = function()
			Minimized = not Minimized
			if Minimized then
				Main.Visible = false
			else
				Main.Visible = true
			end
		end,
		ChangeTheme = updateTheme,
		Notify = ShowNotification,
	}
end

return SimpleKavo
