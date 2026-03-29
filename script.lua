-- ==================================================================
-- 13. REVERSE MODE (FLASHBACK / TIME REWIND) - MOBILE SUPPORT
-- ==================================================================
ReverseMain = Instance.new("Frame", ScreenGui); ReverseMain.Size = UDim2.new(0, 260, 0, 145); ReverseMain.Position = UDim2.new(0, 20, 0, 660); ReverseMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); ReverseMain.BorderSizePixel = 0; ReverseMain.ClipsDescendants = true; ReverseMain.Visible = false; Instance.new("UICorner", ReverseMain).CornerRadius = UDim.new(0, 6); ReverseMainStroke = Instance.new("UIStroke", ReverseMain); ReverseMainStroke.Color = borderDark
ReverseTopBar = Instance.new("Frame", ReverseMain); ReverseTopBar.Size = UDim2.new(1, 0, 0, 35); ReverseTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); ReverseTopBar.BorderSizePixel = 0; Instance.new("UICorner", ReverseTopBar).CornerRadius = UDim.new(0, 6)
ReverseFix = Instance.new("Frame", ReverseTopBar); ReverseFix.Size = UDim2.new(1, 0, 0, 5); ReverseFix.Position = UDim2.new(0, 0, 1, -5); ReverseFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); ReverseFix.BorderSizePixel = 0
ReverseTitle = Instance.new("TextLabel", ReverseTopBar); ReverseTitle.Size = UDim2.new(1, -70, 1, 0); ReverseTitle.Position = UDim2.new(0, 15, 0, 0); ReverseTitle.BackgroundTransparency = 1; ReverseTitle.Text = "REVERSE (FLASHBACK)"; ReverseTitle.TextColor3 = tWhite; ReverseTitle.Font = Enum.Font.GothamBold; ReverseTitle.TextSize = 13; ReverseTitle.TextXAlignment = Enum.TextXAlignment.Left
ReverseMinBtn = Instance.new("TextButton", ReverseTopBar); ReverseMinBtn.Size = UDim2.new(0, 35, 1, 0); ReverseMinBtn.Position = UDim2.new(1, -70, 0, 0); ReverseMinBtn.BackgroundTransparency = 1; ReverseMinBtn.Text = "—"; ReverseMinBtn.TextColor3 = tGreen; ReverseMinBtn.Font = Enum.Font.GothamBlack; ReverseMinBtn.TextSize = 14
ReverseCloseBtn = Instance.new("TextButton", ReverseTopBar); ReverseCloseBtn.Size = UDim2.new(0, 35, 1, 0); ReverseCloseBtn.Position = UDim2.new(1, -35, 0, 0); ReverseCloseBtn.BackgroundTransparency = 1; ReverseCloseBtn.Text = "X"; ReverseCloseBtn.TextColor3 = tRed; ReverseCloseBtn.Font = Enum.Font.GothamBlack; ReverseCloseBtn.TextSize = 12

ReverseToggleBtn = Instance.new("TextButton", ReverseMain); ReverseToggleBtn.Size = UDim2.new(1, -75, 0, 40); ReverseToggleBtn.Position = UDim2.new(0, 10, 0, 45); ReverseToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); ReverseToggleBtn.Text = "SISTEMA: OFF"; ReverseToggleBtn.TextColor3 = tWhite; ReverseToggleBtn.Font = Enum.Font.GothamBold; ReverseToggleBtn.TextSize = 12; Instance.new("UICorner", ReverseToggleBtn).CornerRadius = UDim.new(0, 6)
ReverseKeyBtn = Instance.new("TextButton", ReverseMain); ReverseKeyBtn.Size = UDim2.new(0, 50, 0, 40); ReverseKeyBtn.Position = UDim2.new(1, -60, 0, 45); ReverseKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); ReverseKeyBtn.Text = "KEY"; ReverseKeyBtn.TextColor3 = tWhite; ReverseKeyBtn.Font = Enum.Font.GothamBold; ReverseKeyBtn.TextSize = 11; Instance.new("UICorner", ReverseKeyBtn).CornerRadius = UDim.new(0, 6)

-- BOTÓN PARA MÓVILES (MANTENER PARA REBOBINAR)
ReverseActionBtn = Instance.new("TextButton", ReverseMain); ReverseActionBtn.Size = UDim2.new(1, -20, 0, 45); ReverseActionBtn.Position = UDim2.new(0, 10, 0, 90); ReverseActionBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); ReverseActionBtn.Text = "⏮ MANTENER PARA REBOBINAR"; ReverseActionBtn.TextColor3 = Color3.fromRGB(150, 150, 150); ReverseActionBtn.Font = Enum.Font.GothamBold; ReverseActionBtn.TextSize = 11; ReverseActionBtn.AutoButtonColor = false; Instance.new("UICorner", ReverseActionBtn).CornerRadius = UDim.new(0, 6)

ApplyResponsiveScale(ReverseMain); MakeDraggable(ReverseTopBar, ReverseMain)

local reverseMinimized = false
ReverseMinBtn.MouseButton1Click:Connect(function()
    reverseMinimized = not reverseMinimized; ReverseMain:TweenSize(reverseMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 145), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    ReverseMinBtn.Text = reverseMinimized and "+" or "—"; ReverseFix.Visible = not reverseMinimized
end)

local isReverseActive = false; local reverseKeybind = nil; local isReverseBinding = false; local isMobileRewinding = false
local flashbacklength = 300; local flashbackspeed = 1; local frames = {}
local flashbackName = "CDT_FlashbackSystem"
local flashback = { lastinput = false, canrevert = true }

function flashback:Advance(char, hrp, hum, allowinput)
    if #frames > flashbacklength * 60 then table.remove(frames, 1) end
    if allowinput and not self.canrevert then self.canrevert = true end
    if self.lastinput then hum.PlatformStand = false; self.lastinput = false end
    table.insert(frames, {hrp.CFrame, hrp.Velocity, hum:GetState(), hum.PlatformStand, char:FindFirstChildOfClass("Tool")})
end

function flashback:Revert(char, hrp, hum)
    local num = #frames
    if num == 0 or not self.canrevert then self.canrevert = false; self:Advance(char, hrp, hum); return end
    for i = 1, flashbackspeed do table.remove(frames, num); num = num - 1; if num <= 0 then break end end
    if num <= 0 then return end
    self.lastinput = true; local lastframe = frames[num]; table.remove(frames, num)
    hrp.CFrame = lastframe[1]; hrp.Velocity = -lastframe[2]; hum:ChangeState(lastframe[3]); hum.PlatformStand = lastframe[4]
    local currenttool = char:FindFirstChildOfClass("Tool")
    if lastframe[5] then if not currenttool then hum:EquipTool(lastframe[5]) end else hum:UnequipTools() end
end

local function ToggleReverse()
    isReverseActive = not isReverseActive
    if isReverseActive then
        ReverseToggleBtn.BackgroundColor3 = tCyan; ReverseToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10); ReverseToggleBtn.Text = "SISTEMA: ON"; frames = {}
        ReverseActionBtn.TextColor3 = tWhite; ReverseActionBtn.BackgroundColor3 = tPurple
        RunService:BindToRenderStep(flashbackName, 1, function()
            local char = LocalPlayer.Character; if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            if (reverseKeybind and UserInputService:IsKeyDown(reverseKeybind)) or isMobileRewinding then
                flashback:Revert(char, hrp, hum)
            else
                flashback:Advance(char, hrp, hum, true)
            end
        end)
    else
        ReverseToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); ReverseToggleBtn.TextColor3 = tWhite; ReverseToggleBtn.Text = "SISTEMA: OFF"
        ReverseActionBtn.TextColor3 = Color3.fromRGB(150, 150, 150); ReverseActionBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        isMobileRewinding = false
        RunService:UnbindFromRenderStep(flashbackName); frames = {}
    end
end
ReverseToggleBtn.MouseButton1Click:Connect(ToggleReverse)

-- LÓGICA TOUCH/CLICK PARA EL BOTÓN DE ACCIÓN
ReverseActionBtn.InputBegan:Connect(function(input)
    if not isReverseActive then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isMobileRewinding = true
        ReverseActionBtn.BackgroundColor3 = tCyan
        ReverseActionBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
    end
end)

ReverseActionBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isMobileRewinding = false
        if isReverseActive then
            ReverseActionBtn.BackgroundColor3 = tPurple
            ReverseActionBtn.TextColor3 = tWhite
        end
    end
end)

ReverseCloseBtn.MouseButton1Click:Connect(function() 
    ReverseMain.Visible = false; reverseKeybind = nil; isReverseBinding = false; ReverseKeyBtn.Text = "KEY"; ReverseKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isMobileRewinding = false 
    if isReverseActive then ToggleReverse() end
end)

ReverseKeyBtn.MouseButton1Click:Connect(function()
    if reverseKeybind ~= nil then reverseKeybind = nil; ReverseKeyBtn.Text = "KEY"; ReverseKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isReverseBinding = false
    else isReverseBinding = true; ReverseKeyBtn.Text = "..."; ReverseKeyBtn.BackgroundColor3 = tOrange end
end)
