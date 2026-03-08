--[[
    C.D.T OPTIFINE - V8 VEHICLE FLY EDITION
    - Tamaño ajustado (Escala 1.05x en PC, 1.15x Celular).
    - TP Menu, Menú Invisible (Ghost Perfecto), Menú de Vuelo (Superman).
    - GLOBAL CHAT SMART (Discord Scroll).
    - NUEVO: VEHICLE FLY (Vuelo en vehículos con controles táctiles, Pitch, Anti-Lock y FwF).
    - Consola Inteligente y comandos.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ==================================================================
-- CONFIGURACIÓN DEL CHAT GLOBAL (NGROK)
-- ==================================================================
local URL_NGROK = "https://garnett-waterborne-overoffensively.ngrok-free.dev" 

-- ==================================================================
-- COLORES PARA TEXTOS DE LA CONSOLA Y BORDES
-- ==================================================================
local tPurple = Color3.fromRGB(170, 85, 255)
local tWhite = Color3.fromRGB(255, 255, 255)
local tGreen = Color3.fromRGB(0, 255, 136)
local tOrange = Color3.fromRGB(255, 150, 0)
local tCyan = Color3.fromRGB(0, 200, 255)
local tYellow = Color3.fromRGB(255, 220, 0)
local tRed = Color3.fromRGB(255, 60, 60)
local borderDark = Color3.fromRGB(45, 45, 45)

-- ==================================================================
-- FUNCIÓN DE ESCALADO RESPONSIVE
-- ==================================================================
local function ApplyResponsiveScale(frame)
    local scaleObj = Instance.new("UIScale", frame)
    local function UpdateScale()
        local vs = Workspace.CurrentCamera.ViewportSize
        if vs.X < 850 then
            scaleObj.Scale = 1.15 
        else
            scaleObj.Scale = 1.05 
        end
    end
    Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
    UpdateScale()
end

-- ==================================================================
-- 0. SISTEMA ANTI-DUPLICACIÓN
-- ==================================================================
local existingGui = nil
pcall(function() existingGui = CoreGui:FindFirstChild("CDT_Optifine_Fluid") or gethui():FindFirstChild("CDT_Optifine_Fluid") end)

if existingGui then
    local NotifGui = Instance.new("ScreenGui"); NotifGui.Name = "CDT_Notification"
    pcall(function() NotifGui.Parent = gethui() end)
    if not NotifGui.Parent then NotifGui.Parent = CoreGui end

    local NotifFrame = Instance.new("Frame", NotifGui)
    NotifFrame.Size = UDim2.new(0, 250, 0, 40); NotifFrame.Position = UDim2.new(0.5, -125, 0, -50)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); NotifFrame.BorderSizePixel = 0
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", NotifFrame).Color = tGreen

    local NotifText = Instance.new("TextLabel", NotifFrame)
    NotifText.Size = UDim2.new(1, 0, 1, 0); NotifText.BackgroundTransparency = 1
    NotifText.Text = "⚠️ EL MENÚ YA ESTÁ ABIERTO"
    NotifText.TextColor3 = tWhite; NotifText.Font = Enum.Font.GothamBold; NotifText.TextSize = 13

    ApplyResponsiveScale(NotifFrame)

    TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -125, 0, 20)}):Play()
    task.wait(3)
    TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -125, 0, -50)}):Play()
    task.wait(0.5); NotifGui:Destroy()
    return
end

-- ==================================================================
-- 1. CONSTRUCTOR DE INTERFAZ PRINCIPAL (C.D.T OPTIFINE)
-- ==================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CDT_Optifine_Fluid"; ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = gethui() end)
if not ScreenGui.Parent then ScreenGui.Parent = CoreGui end

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 320, 0, 350); Main.Position = UDim2.new(1, -340, 1, -370) 
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.BorderSizePixel = 0; Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", Main).Color = borderDark
ApplyResponsiveScale(Main)

local FullUI = Instance.new("CanvasGroup", Main)
FullUI.Size = UDim2.new(1, 0, 1, 0); FullUI.BackgroundTransparency = 1; FullUI.BorderSizePixel = 0

local TopBar = Instance.new("Frame", FullUI); TopBar.Size = UDim2.new(1, 0, 0, 35); TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TopBar.BorderSizePixel = 0; Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)
local Fix = Instance.new("Frame", TopBar); Fix.Size = UDim2.new(1, 0, 0, 5); Fix.Position = UDim2.new(0, 0, 1, -5); Fix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); Fix.BorderSizePixel = 0
local Title = Instance.new("TextLabel", TopBar); Title.Size = UDim2.new(1, -60, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0); Title.BackgroundTransparency = 1; Title.Text = "C.D.T OPTIFINE // SYSTEM"; Title.TextColor3 = tWhite; Title.Font = Enum.Font.GothamBold; Title.TextSize = 12; Title.TextXAlignment = Enum.TextXAlignment.Left
local MinBtn = Instance.new("TextButton", TopBar); MinBtn.Size = UDim2.new(0, 35, 1, 0); MinBtn.Position = UDim2.new(1, -35, 0, 0); MinBtn.BackgroundTransparency = 1; MinBtn.Text = "—"; MinBtn.TextColor3 = tGreen; MinBtn.Font = Enum.Font.GothamBlack; MinBtn.TextSize = 14

local Console = Instance.new("ScrollingFrame", FullUI)
Console.Size = UDim2.new(1, -20, 1, -95); Console.Position = UDim2.new(0, 10, 0, 40); Console.BackgroundTransparency = 1; Console.BorderSizePixel = 0; Console.ScrollBarThickness = 2; Console.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
local UIList = Instance.new("UIListLayout", Console); UIList.Padding = UDim.new(0, 4); UIList.SortOrder = Enum.SortOrder.LayoutOrder

local CmdBox = Instance.new("TextBox", FullUI)
CmdBox.Size = UDim2.new(1, -20, 0, 35); CmdBox.Position = UDim2.new(0, 10, 1, -45); CmdBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10); CmdBox.TextColor3 = tWhite; CmdBox.PlaceholderText = "> Escribe un comando aquí..."; CmdBox.Font = Enum.Font.Gotham; CmdBox.TextSize = 13; CmdBox.TextXAlignment = Enum.TextXAlignment.Left; CmdBox.ClearTextOnFocus = false; Instance.new("UICorner", CmdBox).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", CmdBox).Color = Color3.fromRGB(40, 40, 40)
local UIPad = Instance.new("UIPadding", CmdBox); UIPad.PaddingLeft = UDim.new(0, 10)

local MiniUI = Instance.new("CanvasGroup", Main)
MiniUI.Size = UDim2.new(1, 0, 1, 0); MiniUI.BackgroundTransparency = 1; MiniUI.BorderSizePixel = 0; MiniUI.GroupTransparency = 1; MiniUI.Visible = false
local MiniLabel = Instance.new("TextLabel", MiniUI); MiniLabel.Size = UDim2.new(1, -40, 1, 0); MiniLabel.Position = UDim2.new(0, 15, 0, 0); MiniLabel.BackgroundTransparency = 1; MiniLabel.Text = "C.D.T TERMINAL"; MiniLabel.TextColor3 = tWhite; MiniLabel.Font = Enum.Font.GothamBold; MiniLabel.TextSize = 12; MiniLabel.TextXAlignment = Enum.TextXAlignment.Left
local Dot = Instance.new("Frame", MiniUI); Dot.Size = UDim2.new(0, 6, 0, 6); Dot.Position = UDim2.new(0, 140, 0.5, -3); Dot.BackgroundColor3 = tGreen; Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
local MaxBtn = Instance.new("TextButton", MiniUI); MaxBtn.Size = UDim2.new(0, 35, 1, 0); MaxBtn.Position = UDim2.new(1, -35, 0, 0); MaxBtn.BackgroundTransparency = 1; MaxBtn.Text = "⤢"; MaxBtn.TextColor3 = tGreen; MaxBtn.Font = Enum.Font.GothamBlack; MaxBtn.TextSize = 18

local function MakeDraggable(dragArea, targetFrame)
    local dragging, dragInput, dragStart, startPos
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = targetFrame.Position end
    end)
    dragArea.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

MakeDraggable(TopBar, Main); MakeDraggable(MiniLabel, Main)

local isMinimized = false
local function ToggleMenu()
    if isMinimized then
        isMinimized = false; FullUI.Visible = true
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 320, 0, 350)}):Play()
        TweenService:Create(MiniUI, TweenInfo.new(0.2), {GroupTransparency = 1}):Play()
        TweenService:Create(FullUI, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.1), {GroupTransparency = 0}):Play()
        task.wait(0.2); MiniUI.Visible = false
    else
        isMinimized = true; MiniUI.Visible = true
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 190, 0, 35)}):Play()
        TweenService:Create(FullUI, TweenInfo.new(0.2), {GroupTransparency = 1}):Play()
        TweenService:Create(MiniUI, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.1), {GroupTransparency = 0}):Play()
        task.wait(0.2); FullUI.Visible = false
    end
end
MinBtn.MouseButton1Click:Connect(ToggleMenu); MaxBtn.MouseButton1Click:Connect(ToggleMenu)

-- ==================================================================
-- 2. INTERFAZ TP MENU 
-- ==================================================================
local TPMain = Instance.new("Frame", ScreenGui); TPMain.Size = UDim2.new(0, 260, 0, 380); TPMain.Position = UDim2.new(0.5, -130, 0.5, -190); TPMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); TPMain.BorderSizePixel = 0; TPMain.ClipsDescendants = true; TPMain.Visible = false; Instance.new("UICorner", TPMain).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", TPMain).Color = borderDark
local TPTopBar = Instance.new("Frame", TPMain); TPTopBar.Size = UDim2.new(1, 0, 0, 35); TPTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TPTopBar.BorderSizePixel = 0; Instance.new("UICorner", TPTopBar).CornerRadius = UDim.new(0, 6)
local TPFix = Instance.new("Frame", TPTopBar); TPFix.Size = UDim2.new(1, 0, 0, 5); TPFix.Position = UDim2.new(0, 0, 1, -5); TPFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TPFix.BorderSizePixel = 0
local TPTitle = Instance.new("TextLabel", TPTopBar); TPTitle.Size = UDim2.new(1, -70, 1, 0); TPTitle.Position = UDim2.new(0, 15, 0, 0); TPTitle.BackgroundTransparency = 1; TPTitle.Text = "TP MENU"; TPTitle.TextColor3 = tWhite; TPTitle.Font = Enum.Font.GothamBold; TPTitle.TextSize = 13; TPTitle.TextXAlignment = Enum.TextXAlignment.Left
local TPMinBtn = Instance.new("TextButton", TPTopBar); TPMinBtn.Size = UDim2.new(0, 35, 1, 0); TPMinBtn.Position = UDim2.new(1, -70, 0, 0); TPMinBtn.BackgroundTransparency = 1; TPMinBtn.Text = "—"; TPMinBtn.TextColor3 = tYellow; TPMinBtn.Font = Enum.Font.GothamBlack; TPMinBtn.TextSize = 14
local TPCloseBtn = Instance.new("TextButton", TPTopBar); TPCloseBtn.Size = UDim2.new(0, 35, 1, 0); TPCloseBtn.Position = UDim2.new(1, -35, 0, 0); TPCloseBtn.BackgroundTransparency = 1; TPCloseBtn.Text = "X"; TPCloseBtn.TextColor3 = tRed; TPCloseBtn.Font = Enum.Font.GothamBlack; TPCloseBtn.TextSize = 12
local TPSearchBox = Instance.new("TextBox", TPMain); TPSearchBox.Size = UDim2.new(1, -10, 0, 35); TPSearchBox.Position = UDim2.new(0, 5, 0, 40); TPSearchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TPSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255); TPSearchBox.PlaceholderText = "🔍 Buscar jugador..."; TPSearchBox.Font = Enum.Font.Gotham; TPSearchBox.TextSize = 13; TPSearchBox.ClearTextOnFocus = false; Instance.new("UICorner", TPSearchBox).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", TPSearchBox).Color = Color3.fromRGB(50, 50, 50)
local TPScroll = Instance.new("ScrollingFrame", TPMain); TPScroll.Size = UDim2.new(1, -10, 1, -85); TPScroll.Position = UDim2.new(0, 5, 0, 80); TPScroll.BackgroundTransparency = 1; TPScroll.BorderSizePixel = 0; TPScroll.ScrollBarThickness = 2; TPScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
local TPListLayout = Instance.new("UIListLayout", TPScroll); TPListLayout.Padding = UDim.new(0, 5)

ApplyResponsiveScale(TPMain)
MakeDraggable(TPTopBar, TPMain)

local tpMinimized = false
TPMinBtn.MouseButton1Click:Connect(function()
    tpMinimized = not tpMinimized
    TweenService:Create(TPMain, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = tpMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 380)}):Play()
    TPMinBtn.Text = tpMinimized and "+" or "—"
    TPFix.Visible = not tpMinimized
end)
TPCloseBtn.MouseButton1Click:Connect(function() TPMain.Visible = false end)

local function RefreshTPMenu(filterText)
    filterText = filterText and string.lower(filterText) or ""
    for _, child in pairs(TPScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if filterText == "" or string.find(string.lower(plr.Name), filterText) or string.find(string.lower(plr.DisplayName), filterText) then
                local Card = Instance.new("Frame", TPScroll); Card.Size = UDim2.new(1, -5, 0, 40); Card.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
                local Avatar = Instance.new("ImageLabel", Card); Avatar.Size = UDim2.new(0, 30, 0, 30); Avatar.Position = UDim2.new(0, 5, 0, 5); Avatar.BackgroundTransparency = 1; Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
                task.spawn(function() Avatar.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)
                local NameLbl = Instance.new("TextLabel", Card); NameLbl.Size = UDim2.new(1, -100, 1, 0); NameLbl.Position = UDim2.new(0, 45, 0, 0); NameLbl.BackgroundTransparency = 1; NameLbl.Text = plr.DisplayName; NameLbl.TextColor3 = tWhite; NameLbl.Font = Enum.Font.GothamMedium; NameLbl.TextSize = 13; NameLbl.TextXAlignment = Enum.TextXAlignment.Left
                local TpBtn = Instance.new("TextButton", Card); TpBtn.Size = UDim2.new(0, 40, 0, 26); TpBtn.Position = UDim2.new(1, -45, 0.5, -13); TpBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136); TpBtn.Text = "TP"; TpBtn.TextColor3 = Color3.fromRGB(10, 10, 10); TpBtn.Font = Enum.Font.GothamBold; TpBtn.TextSize = 12; Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 4)
                
                TpBtn.MouseButton1Click:Connect(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    end
                end)
            end
        end
    end
    TPScroll.CanvasSize = UDim2.new(0, 0, 0, TPListLayout.AbsoluteContentSize.Y + 10)
end
TPSearchBox:GetPropertyChangedSignal("Text"):Connect(function() RefreshTPMenu(TPSearchBox.Text) end)

-- ==================================================================
-- 3. INTERFAZ INVISIBLE MENU (GHOST MODE PERFECTO + TOOLS)
-- ==================================================================
local InvMain = Instance.new("Frame", ScreenGui); InvMain.Size = UDim2.new(0, 260, 0, 100); InvMain.Position = UDim2.new(0.5, -310, 0.5, -120); InvMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); InvMain.BorderSizePixel = 0; InvMain.ClipsDescendants = true; InvMain.Visible = false; Instance.new("UICorner", InvMain).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", InvMain).Color = borderDark
local InvTopBar = Instance.new("Frame", InvMain); InvTopBar.Size = UDim2.new(1, 0, 0, 35); InvTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); InvTopBar.BorderSizePixel = 0; Instance.new("UICorner", InvTopBar).CornerRadius = UDim.new(0, 6)
local InvFix = Instance.new("Frame", InvTopBar); InvFix.Size = UDim2.new(1, 0, 0, 5); InvFix.Position = UDim2.new(0, 0, 1, -5); InvFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); InvFix.BorderSizePixel = 0
local InvTitle = Instance.new("TextLabel", InvTopBar); InvTitle.Size = UDim2.new(1, -70, 1, 0); InvTitle.Position = UDim2.new(0, 15, 0, 0); InvTitle.BackgroundTransparency = 1; InvTitle.Text = "INVISIBILITY"; InvTitle.TextColor3 = tWhite; InvTitle.Font = Enum.Font.GothamBold; InvTitle.TextSize = 13; InvTitle.TextXAlignment = Enum.TextXAlignment.Left
local InvMinBtn = Instance.new("TextButton", InvTopBar); InvMinBtn.Size = UDim2.new(0, 35, 1, 0); InvMinBtn.Position = UDim2.new(1, -70, 0, 0); InvMinBtn.BackgroundTransparency = 1; InvMinBtn.Text = "—"; InvMinBtn.TextColor3 = tGreen; InvMinBtn.Font = Enum.Font.GothamBlack; InvMinBtn.TextSize = 14
local InvCloseBtn = Instance.new("TextButton", InvTopBar); InvCloseBtn.Size = UDim2.new(0, 35, 1, 0); InvCloseBtn.Position = UDim2.new(1, -35, 0, 0); InvCloseBtn.BackgroundTransparency = 1; InvCloseBtn.Text = "X"; InvCloseBtn.TextColor3 = tRed; InvCloseBtn.Font = Enum.Font.GothamBlack; InvCloseBtn.TextSize = 12
local InvToggleBtn = Instance.new("TextButton", InvMain); InvToggleBtn.Size = UDim2.new(1, -75, 0, 45); InvToggleBtn.Position = UDim2.new(0, 10, 0, 45); InvToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); InvToggleBtn.Text = "INVISIBILIDAD: OFF"; InvToggleBtn.TextColor3 = tWhite; InvToggleBtn.Font = Enum.Font.GothamBold; InvToggleBtn.TextSize = 12; Instance.new("UICorner", InvToggleBtn).CornerRadius = UDim.new(0, 6)
local InvKeyBtn = Instance.new("TextButton", InvMain); InvKeyBtn.Size = UDim2.new(0, 50, 0, 45); InvKeyBtn.Position = UDim2.new(1, -60, 0, 45); InvKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); InvKeyBtn.Text = "KEY"; InvKeyBtn.TextColor3 = tWhite; InvKeyBtn.Font = Enum.Font.GothamBold; InvKeyBtn.TextSize = 11; Instance.new("UICorner", InvKeyBtn).CornerRadius = UDim.new(0, 6)

ApplyResponsiveScale(InvMain)
MakeDraggable(InvTopBar, InvMain)

local invMinimized = false
InvMinBtn.MouseButton1Click:Connect(function()
    invMinimized = not invMinimized
    TweenService:Create(InvMain, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = invMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 100)}):Play()
    InvMinBtn.Text = invMinimized and "+" or "—"
    InvFix.Visible = not invMinimized
end)

local DEPTH = 70 
local CLONE_TRANSPARENCY = 0.5 
local PLATFORM_SIZE = 500 
local isGhostActive = false
local ghostModel = nil
local safetyPlatform = nil
local controlsConnection = nil
local activationConn = nil
local activationEndConn = nil
local toolSyncConnAdded = nil
local toolSyncConnRemoved = nil
local currentVisualTool = nil
local animTracks = {Idle = nil, Walk = nil, Sit = nil}
local currentAnim = nil
local invKeybind = nil
local isInvBinding = false
local isAttacking = false 

if getgenv().PhysicalGhostCon then getgenv().PhysicalGhostCon:Disconnect() end
if getgenv().GhostPlatform then getgenv().GhostPlatform:Destroy() end
if getgenv().GhostModel then getgenv().GhostModel:Destroy() end
getgenv().GhostActive = false

local function getAnimID(scriptName, childName)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Animate") then
        local animScript = char.Animate
        if animScript:FindFirstChild(scriptName) then
            local value = animScript[scriptName]:FindFirstChild(childName)
            if value and value:IsA("Animation") then return value.AnimationId end
        end
    end
    if scriptName == "idle" then return "http://www.roblox.com/asset/?id=507766388" 
    elseif scriptName == "sit" then return "http://www.roblox.com/asset/?id=2506281703"
    else return "http://www.roblox.com/asset/?id=507777826" end
end

local function setRealCharTransparency(visible)
    local char = LocalPlayer.Character
    if not char then return end
    local trans = visible and 0 or 1
    for _, v in pairs(char:GetDescendants()) do
        if (v:IsA("BasePart") and v.Name ~= "HumanoidRootPart") or v:IsA("Decal") then v.Transparency = trans
        elseif v:IsA("BasePart") then v.Transparency = 1 end
    end
end

local function createSafetyPlatform()
    local p = Instance.new("Part")
    p.Name = "SafeZone_Floor"
    p.Size = Vector3.new(50, 4, 50)
    p.Anchored = true; p.Transparency = 1; p.CanCollide = true
    p.Parent = Workspace
    return p
end

local function createVisualTool(realTool, ghostModel)
    if currentVisualTool then currentVisualTool:Destroy() end
    local visual = realTool:Clone()
    visual.Name = "Visual_" .. realTool.Name
    visual.Parent = ghostModel
    
    for _, v in pairs(visual:GetDescendants()) do
        if v:IsA("BasePart") then v.Transparency = 0; v.CanCollide = false; v.Massless = true
        elseif v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Sound") then v:Destroy() end
    end
    
    local handle = visual:FindFirstChild("Handle") or visual:FindFirstChildOfClass("BasePart")
    local rightHand = ghostModel:FindFirstChild("RightHand", true) or ghostModel:FindFirstChild("Right Arm", true)
    if handle and rightHand then
        handle.CFrame = rightHand.CFrame * realTool.Grip
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = rightHand; weld.Part1 = handle; weld.Parent = rightHand
    end
    currentVisualTool = visual
end

local function createPhysicalGhost(original)
    original.Archivable = true
    local clone = original:Clone()
    clone.Name = "Clone_Active"
    clone.Parent = Workspace
    
    for _, v in pairs(clone:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = 0.5; v.Anchored = false; v.CanCollide = true
            if v.Name == "HumanoidRootPart" then v.Transparency = 1; v.CanCollide = false end
        elseif v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Sound") then v:Destroy() end
    end
    
    for _, child in pairs(clone:GetChildren()) do if child:IsA("Tool") then child:Destroy() end end
    
    local ghostHum = clone:FindFirstChild("Humanoid")
    if ghostHum then
        ghostHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        ghostHum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        local animator = ghostHum:FindFirstChild("Animator") or Instance.new("Animator", ghostHum)
        local animIdle = Instance.new("Animation"); animIdle.AnimationId = getAnimID("idle", "Animation1")
        local animWalk = Instance.new("Animation"); animWalk.AnimationId = getAnimID("run", "RunAnim")
        local animSit = Instance.new("Animation"); animSit.AnimationId = getAnimID("sit", "Animation1")
        animTracks.Idle = animator:LoadAnimation(animIdle)
        animTracks.Walk = animator:LoadAnimation(animWalk)
        animTracks.Sit = animator:LoadAnimation(animSit)
        for _, track in pairs(animTracks) do if track then track.Looped = true end end
        animTracks.Idle:Play(); currentAnim = "Idle"
    end
    
    return clone
end

local function updateGhostAnim(isMoving, isSitting)
    if isSitting then
        if currentAnim ~= "Sit" then
            if animTracks.Idle then animTracks.Idle:Stop(0.1) end
            if animTracks.Walk then animTracks.Walk:Stop(0.1) end
            if animTracks.Sit then animTracks.Sit:Play(0.1) end
            currentAnim = "Sit"
        end
    elseif isMoving then
        if currentAnim ~= "Walk" then
            if animTracks.Idle then animTracks.Idle:Stop(0.1) end
            if animTracks.Sit then animTracks.Sit:Stop(0.1) end
            if animTracks.Walk then animTracks.Walk:Play(0.1) end
            currentAnim = "Walk"
        end
    else
        if currentAnim ~= "Idle" then
            if animTracks.Walk then animTracks.Walk:Stop(0.1) end
            if animTracks.Sit then animTracks.Sit:Stop(0.1) end
            if animTracks.Idle then animTracks.Idle:Play(0.1) end
            currentAnim = "Idle"
        end
    end
end

local function startControls()
    if controlsConnection then controlsConnection:Disconnect() end
    if activationConn then activationConn:Disconnect() end
    if activationEndConn then activationEndConn:Disconnect() end
    local ghostCollidable = true
    
    controlsConnection = RunService.RenderStepped:Connect(function()
        if not ghostModel or not isGhostActive then return end
        local ghostHum = ghostModel:FindFirstChild("Humanoid")
        local char = LocalPlayer.Character
        local realHum = char and char:FindFirstChild("Humanoid")
        local realRoot = char and char.PrimaryPart
        local ghostRoot = ghostModel.PrimaryPart
        if not ghostHum or not char or not realHum or not realRoot or not ghostRoot then return end
        
        local moveVec = Vector3.new(0,0,0)
        local camCF = Workspace.CurrentCamera.CFrame
        local look = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
        local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
        local isMovingInput = false
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + look; isMovingInput = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - look; isMovingInput = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + right; isMovingInput = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - right; isMovingInput = true end
        
        local isSitting = realHum.Sit
        if isSitting then
            ghostRoot.CFrame = realRoot.CFrame
        else
            if moveVec.Magnitude > 0 then ghostHum:Move(moveVec, false) else ghostHum:Move(Vector3.new(0,0,0), false) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then ghostHum.Jump = true end
            
            if not isAttacking then
                if safetyPlatform then safetyPlatform.CFrame = ghostRoot.CFrame * CFrame.new(0, -48, 0) end
                realRoot.CFrame = ghostRoot.CFrame * CFrame.new(0, -45, 0)
                realRoot.AssemblyLinearVelocity = Vector3.zero
            else
                realRoot.CFrame = ghostRoot.CFrame
            end
        end
        
        local targetCollidable = not isSitting
        if targetCollidable ~= ghostCollidable then
            ghostCollidable = targetCollidable
            for _, v in pairs(ghostModel:GetDescendants()) do if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.CanCollide = ghostCollidable end end
        end
        
        local isMoving = isMovingInput and not isSitting
        updateGhostAnim(isMoving, isSitting)
    end)
    
    activationConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then isAttacking = true end
        local char = LocalPlayer.Character
        if not char or not isGhostActive then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            if input.UserInputType == Enum.UserInputType.MouseButton1 then tool:Activate() 
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then pcall(function() tool:Activate() end) end
        end
    end)

    activationEndConn = UserInputService.InputEnded:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then isAttacking = false end
    end)
    
    getgenv().PhysicalGhostCon = controlsConnection
end

local function ToggleGhost()
    isGhostActive = not isGhostActive
    getgenv().GhostActive = isGhostActive
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local realHum = char:FindFirstChild("Humanoid")
    if not root or not realHum then return end
    local camera = Workspace.CurrentCamera
    
    if isGhostActive then
        local startCF = root.CFrame
        safetyPlatform = createSafetyPlatform()
        getgenv().GhostPlatform = safetyPlatform
        ghostModel = createPhysicalGhost(char)
        ghostModel.HumanoidRootPart.CFrame = startCF
        getgenv().GhostModel = ghostModel
        
        local currentTool = char:FindFirstChildOfClass("Tool")
        if currentTool then createVisualTool(currentTool, ghostModel) end
        
        setRealCharTransparency(false)
        Workspace.CurrentCamera.CameraSubject = ghostModel:FindFirstChild("Humanoid")
        
        toolSyncConnAdded = char.ChildAdded:Connect(function(child) if child:IsA("Tool") then createVisualTool(child, ghostModel) end end)
        toolSyncConnRemoved = char.ChildRemoved:Connect(function(child) if child:IsA("Tool") and currentVisualTool then currentVisualTool:Destroy(); currentVisualTool = nil end end)
        
        startControls() 
        InvToggleBtn.BackgroundColor3 = tGreen; InvToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10); InvToggleBtn.Text = "INVISIBILIDAD: ON"
    else
        if controlsConnection then controlsConnection:Disconnect() end
        if activationConn then activationConn:Disconnect() end
        if activationEndConn then activationEndConn:Disconnect() end
        if toolSyncConnAdded then toolSyncConnAdded:Disconnect(); toolSyncConnAdded = nil end
        if toolSyncConnRemoved then toolSyncConnRemoved:Disconnect(); toolSyncConnRemoved = nil end
        if animTracks.Walk then animTracks.Walk:Stop() end
        if animTracks.Idle then animTracks.Idle:Stop() end
        if animTracks.Sit then animTracks.Sit:Stop() end
        if currentVisualTool then currentVisualTool:Destroy(); currentVisualTool = nil end
        
        Workspace.CurrentCamera.CameraSubject = realHum
        if ghostModel and ghostModel.PrimaryPart then char:SetPrimaryPartCFrame(ghostModel.PrimaryPart.CFrame) end
        setRealCharTransparency(true)
        
        local ghostHum = ghostModel and ghostModel:FindFirstChild("Humanoid")
        if ghostHum then
            local seat = ghostHum.SeatPart
            if seat then seat:Sit(realHum) else realHum.Sit = ghostHum.Sit end
        end
        
        if ghostModel then ghostModel:Destroy() end
        if safetyPlatform then safetyPlatform:Destroy() end
        ghostModel = nil; safetyPlatform = nil; animTracks = {Idle = nil, Walk = nil, Sit = nil}; currentAnim = nil
        isAttacking = false
        
        InvToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); InvToggleBtn.TextColor3 = tWhite; InvToggleBtn.Text = "INVISIBILIDAD: OFF"
    end
end
InvToggleBtn.MouseButton1Click:Connect(ToggleGhost)

InvKeyBtn.MouseButton1Click:Connect(function()
    if invKeybind ~= nil then invKeybind = nil; InvKeyBtn.Text = "KEY"; InvKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isInvBinding = false
    else isInvBinding = true; InvKeyBtn.Text = "..."; InvKeyBtn.BackgroundColor3 = tOrange end
end)

InvCloseBtn.MouseButton1Click:Connect(function() 
    if isGhostActive then ToggleGhost() end
    invKeybind = nil; InvKeyBtn.Text = "KEY"; InvKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isInvBinding = false
    InvMain.Visible = false 
end)

LocalPlayer.CharacterAdded:Connect(function()
    if isGhostActive then ToggleGhost() end 
end)

-- ==================================================================
-- 4. INTERFAZ Y LÓGICA DEL MENÚ FLY (SUPERMAN FLY)
-- ==================================================================
local FlyMain = Instance.new("Frame", ScreenGui); FlyMain.Size = UDim2.new(0, 260, 0, 145); FlyMain.Position = UDim2.new(0.5, 50, 0.5, -120); FlyMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); FlyMain.BorderSizePixel = 0; FlyMain.ClipsDescendants = true; FlyMain.Visible = false; Instance.new("UICorner", FlyMain).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", FlyMain).Color = borderDark
local FlyTopBar = Instance.new("Frame", FlyMain); FlyTopBar.Size = UDim2.new(1, 0, 0, 35); FlyTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); FlyTopBar.BorderSizePixel = 0; Instance.new("UICorner", FlyTopBar).CornerRadius = UDim.new(0, 6)
local FlyFix = Instance.new("Frame", FlyTopBar); FlyFix.Size = UDim2.new(1, 0, 0, 5); FlyFix.Position = UDim2.new(0, 0, 1, -5); FlyFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); FlyFix.BorderSizePixel = 0
local FlyTitle = Instance.new("TextLabel", FlyTopBar); FlyTitle.Size = UDim2.new(1, -70, 1, 0); FlyTitle.Position = UDim2.new(0, 15, 0, 0); FlyTitle.BackgroundTransparency = 1; FlyTitle.Text = "FLIGHT MODE"; FlyTitle.TextColor3 = tWhite; FlyTitle.Font = Enum.Font.GothamBold; FlyTitle.TextSize = 13; FlyTitle.TextXAlignment = Enum.TextXAlignment.Left
local FlyMinBtn = Instance.new("TextButton", FlyTopBar); FlyMinBtn.Size = UDim2.new(0, 35, 1, 0); FlyMinBtn.Position = UDim2.new(1, -70, 0, 0); FlyMinBtn.BackgroundTransparency = 1; FlyMinBtn.Text = "—"; FlyMinBtn.TextColor3 = tGreen; FlyMinBtn.Font = Enum.Font.GothamBlack; FlyMinBtn.TextSize = 14
local FlyCloseBtn = Instance.new("TextButton", FlyTopBar); FlyCloseBtn.Size = UDim2.new(0, 35, 1, 0); FlyCloseBtn.Position = UDim2.new(1, -35, 0, 0); FlyCloseBtn.BackgroundTransparency = 1; FlyCloseBtn.Text = "X"; FlyCloseBtn.TextColor3 = tRed; FlyCloseBtn.Font = Enum.Font.GothamBlack; FlyCloseBtn.TextSize = 12

local FlyToggleBtn = Instance.new("TextButton", FlyMain); FlyToggleBtn.Size = UDim2.new(1, -75, 0, 45); FlyToggleBtn.Position = UDim2.new(0, 10, 0, 45); FlyToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); FlyToggleBtn.Text = "VUELO: OFF"; FlyToggleBtn.TextColor3 = tWhite; FlyToggleBtn.Font = Enum.Font.GothamBold; FlyToggleBtn.TextSize = 12; Instance.new("UICorner", FlyToggleBtn).CornerRadius = UDim.new(0, 6)
local FlyKeyBtn = Instance.new("TextButton", FlyMain); FlyKeyBtn.Size = UDim2.new(0, 50, 0, 45); FlyKeyBtn.Position = UDim2.new(1, -60, 0, 45); FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FlyKeyBtn.Text = "KEY"; FlyKeyBtn.TextColor3 = tWhite; FlyKeyBtn.Font = Enum.Font.GothamBold; FlyKeyBtn.TextSize = 11; Instance.new("UICorner", FlyKeyBtn).CornerRadius = UDim.new(0, 6)

local FlySpeedMinus = Instance.new("TextButton", FlyMain); FlySpeedMinus.Size = UDim2.new(0, 40, 0, 35); FlySpeedMinus.Position = UDim2.new(0, 10, 0, 100); FlySpeedMinus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FlySpeedMinus.Text = "-"; FlySpeedMinus.TextColor3 = tWhite; FlySpeedMinus.Font = Enum.Font.GothamBold; Instance.new("UICorner", FlySpeedMinus)
local FlySpeedDisplay = Instance.new("TextBox", FlyMain); FlySpeedDisplay.Size = UDim2.new(1, -110, 0, 35); FlySpeedDisplay.Position = UDim2.new(0, 55, 0, 100); FlySpeedDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 25); FlySpeedDisplay.Text = "SPEED: 90"; FlySpeedDisplay.TextColor3 = tWhite; FlySpeedDisplay.Font = Enum.Font.GothamSemibold; FlySpeedDisplay.TextSize = 13; FlySpeedDisplay.ClearTextOnFocus = true; Instance.new("UICorner", FlySpeedDisplay); Instance.new("UIStroke", FlySpeedDisplay).Color = Color3.fromRGB(50, 50, 50)
local FlySpeedPlus = Instance.new("TextButton", FlyMain); FlySpeedPlus.Size = UDim2.new(0, 40, 0, 35); FlySpeedPlus.Position = UDim2.new(1, -50, 0, 100); FlySpeedPlus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FlySpeedPlus.Text = "+"; FlySpeedPlus.TextColor3 = tWhite; FlySpeedPlus.Font = Enum.Font.GothamBold; Instance.new("UICorner", FlySpeedPlus)

ApplyResponsiveScale(FlyMain)
MakeDraggable(FlyTopBar, FlyMain)

local flyMinimized = false
FlyMinBtn.MouseButton1Click:Connect(function()
    flyMinimized = not flyMinimized
    TweenService:Create(FlyMain, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = flyMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 145)}):Play()
    FlyMinBtn.Text = flyMinimized and "+" or "—"
    FlyFix.Visible = not flyMinimized
end)

local isFlying = false; local flySpeed = 90; local flySmoothness = 0.15; local flyKeybind = nil; local isFlyBinding = false; local flyLoop = nil
local BodyVel, BodyGyro; local OriginalRightC0, OriginalLeftC0

FlySpeedMinus.MouseButton1Click:Connect(function() flySpeed = math.max(10, flySpeed - 10); FlySpeedDisplay.Text = "SPEED: " .. flySpeed end)
FlySpeedPlus.MouseButton1Click:Connect(function() flySpeed = flySpeed + 10; FlySpeedDisplay.Text = "SPEED: " .. flySpeed end)
FlySpeedDisplay.FocusLost:Connect(function()
    local num = tonumber(FlySpeedDisplay.Text:match("%d+"))
    if num then flySpeed = num end; FlySpeedDisplay.Text = "SPEED: " .. flySpeed
end)

local function GetMotor6D()
    local char = LocalPlayer.Character; if not char then return nil, nil end
    local Torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"); if not Torso then return nil, nil end
    local RS = Torso:FindFirstChild("Right Shoulder") or char:FindFirstChild("RightShoulder", true)
    local LS = Torso:FindFirstChild("Left Shoulder") or char:FindFirstChild("LeftShoulder", true)
    return RS, LS
end

local function ToggleFly()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    isFlying = not isFlying
    if isFlying then
        FlyToggleBtn.BackgroundColor3 = tCyan; FlyToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10); FlyToggleBtn.Text = "VUELO: ON"

        BodyVel = Instance.new("BodyVelocity", hrp); BodyVel.Name = "AK_FlyVel"; BodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9); BodyVel.Velocity = Vector3.new(0, 0, 0)
        BodyGyro = Instance.new("BodyGyro", hrp); BodyGyro.Name = "AK_FlyGyro"; BodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9); BodyGyro.P = 20000; BodyGyro.CFrame = hrp.CFrame

        hum.PlatformStand = true
        
        local RS, LS = GetMotor6D()
        if RS then OriginalRightC0 = RS.C0 end; if LS then OriginalLeftC0 = LS.C0 end

        flyLoop = RunService.RenderStepped:Connect(function()
            if not isFlying or not hrp then return end
            local rs, ls = GetMotor6D()
            local CamCF = Workspace.CurrentCamera.CFrame
            local MoveVector = Vector3.new(0, 0, 0)

            local W = UserInputService:IsKeyDown(Enum.KeyCode.W); local S = UserInputService:IsKeyDown(Enum.KeyCode.S)
            local A = UserInputService:IsKeyDown(Enum.KeyCode.A); local D = UserInputService:IsKeyDown(Enum.KeyCode.D)
            local Space = UserInputService:IsKeyDown(Enum.KeyCode.Space); local LCtrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)

            if W then MoveVector = MoveVector + CamCF.LookVector end; if S then MoveVector = MoveVector - CamCF.LookVector end
            if A then MoveVector = MoveVector - CamCF.RightVector end; if D then MoveVector = MoveVector + CamCF.RightVector end
            if Space then MoveVector = MoveVector + Vector3.new(0, 1, 0) end; if LCtrl then MoveVector = MoveVector - Vector3.new(0, 1, 0) end

            if MoveVector.Magnitude > 0 then BodyVel.Velocity = MoveVector.Unit * flySpeed else BodyVel.Velocity = Vector3.new(0, 0, 0) end

            if W then
                local TargetRotation = CFrame.lookAt(hrp.Position, hrp.Position + MoveVector) * CFrame.Angles(math.rad(-90), 0, 0)
                BodyGyro.CFrame = BodyGyro.CFrame:Lerp(TargetRotation, flySmoothness)
                if rs and ls then
                    rs.C0 = rs.C0:Lerp(CFrame.new(1, 0.5, 0) * CFrame.Angles(math.rad(175), 0, 0), flySmoothness)
                    ls.C0 = ls.C0:Lerp(CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, 0, math.rad(10)), flySmoothness)
                end
            else
                local CamLook = Vector3.new(CamCF.LookVector.X, 0, CamCF.LookVector.Z)
                if CamLook.Magnitude > 0 then BodyGyro.CFrame = BodyGyro.CFrame:Lerp(CFrame.lookAt(hrp.Position, hrp.Position + CamLook), flySmoothness) end
                if rs and ls then
                    rs.C0 = rs.C0:Lerp(CFrame.new(1, 0.5, 0) * CFrame.Angles(math.rad(-10), 0, math.rad(15)), flySmoothness)
                    ls.C0 = ls.C0:Lerp(CFrame.new(-1, 0.5, 0) * CFrame.Angles(math.rad(-10), 0, math.rad(-15)), flySmoothness)
                end
            end
        end)
    else
        FlyToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); FlyToggleBtn.TextColor3 = tWhite; FlyToggleBtn.Text = "VUELO: OFF"
        if flyLoop then flyLoop:Disconnect() flyLoop = nil end
        if BodyVel then BodyVel:Destroy() BodyVel = nil end; if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
        if hrp:FindFirstChild("AK_FlyGyro") then hrp.AK_FlyGyro:Destroy() end; if hrp:FindFirstChild("AK_FlyVel") then hrp.AK_FlyVel:Destroy() end
        hum.PlatformStand = false
        local RS, LS = GetMotor6D()
        if RS and OriginalRightC0 then RS.C0 = OriginalRightC0 end; if LS and OriginalLeftC0 then LS.C0 = OriginalLeftC0 end
    end
end
FlyToggleBtn.MouseButton1Click:Connect(ToggleFly)

FlyKeyBtn.MouseButton1Click:Connect(function()
    if flyKeybind ~= nil then flyKeybind = nil; FlyKeyBtn.Text = "KEY"; FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isFlyBinding = false
    else isFlyBinding = true; FlyKeyBtn.Text = "..."; FlyKeyBtn.BackgroundColor3 = tOrange end
end)

FlyCloseBtn.MouseButton1Click:Connect(function() 
    if isFlying then ToggleFly() end
    flyKeybind = nil; FlyKeyBtn.Text = "KEY"; FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isFlyBinding = false; FlyMain.Visible = false 
end)

LocalPlayer.CharacterAdded:Connect(function() if isFlying then ToggleFly() end end)

-- ==================================================================
-- 5. VEHICLE FLY (CON CONTROLES MÓVILES, FwF, PITCH Y A-L)
-- ==================================================================
local VFlyMain = Instance.new("Frame", ScreenGui); VFlyMain.Size = UDim2.new(0, 260, 0, 185); VFlyMain.Position = UDim2.new(0.5, 320, 0.5, -120); VFlyMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); VFlyMain.BorderSizePixel = 0; VFlyMain.ClipsDescendants = true; VFlyMain.Visible = false; Instance.new("UICorner", VFlyMain).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", VFlyMain).Color = borderDark
local VFlyTopBar = Instance.new("Frame", VFlyMain); VFlyTopBar.Size = UDim2.new(1, 0, 0, 35); VFlyTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); VFlyTopBar.BorderSizePixel = 0; Instance.new("UICorner", VFlyTopBar).CornerRadius = UDim.new(0, 6)
local VFlyFix = Instance.new("Frame", VFlyTopBar); VFlyFix.Size = UDim2.new(1, 0, 0, 5); VFlyFix.Position = UDim2.new(0, 0, 1, -5); VFlyFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); VFlyFix.BorderSizePixel = 0
local VFlyTitle = Instance.new("TextLabel", VFlyTopBar); VFlyTitle.Size = UDim2.new(1, -70, 1, 0); VFlyTitle.Position = UDim2.new(0, 15, 0, 0); VFlyTitle.BackgroundTransparency = 1; VFlyTitle.Text = "VEHICLE FLY"; VFlyTitle.TextColor3 = tWhite; VFlyTitle.Font = Enum.Font.GothamBold; VFlyTitle.TextSize = 13; VFlyTitle.TextXAlignment = Enum.TextXAlignment.Left
local VFlyMinBtn = Instance.new("TextButton", VFlyTopBar); VFlyMinBtn.Size = UDim2.new(0, 35, 1, 0); VFlyMinBtn.Position = UDim2.new(1, -70, 0, 0); VFlyMinBtn.BackgroundTransparency = 1; VFlyMinBtn.Text = "—"; VFlyMinBtn.TextColor3 = tGreen; VFlyMinBtn.Font = Enum.Font.GothamBlack; VFlyMinBtn.TextSize = 14
local VFlyCloseBtn = Instance.new("TextButton", VFlyTopBar); VFlyCloseBtn.Size = UDim2.new(0, 35, 1, 0); VFlyCloseBtn.Position = UDim2.new(1, -35, 0, 0); VFlyCloseBtn.BackgroundTransparency = 1; VFlyCloseBtn.Text = "X"; VFlyCloseBtn.TextColor3 = tRed; VFlyCloseBtn.Font = Enum.Font.GothamBlack; VFlyCloseBtn.TextSize = 12

-- Botones principales
local VFlyToggleBtn = Instance.new("TextButton", VFlyMain); VFlyToggleBtn.Size = UDim2.new(1, -20, 0, 30); VFlyToggleBtn.Position = UDim2.new(0, 10, 0, 45); VFlyToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); VFlyToggleBtn.Text = "V-FLY: OFF"; VFlyToggleBtn.TextColor3 = tWhite; VFlyToggleBtn.Font = Enum.Font.GothamBold; VFlyToggleBtn.TextSize = 12; Instance.new("UICorner", VFlyToggleBtn).CornerRadius = UDim.new(0, 4)
local FwFBtn = Instance.new("TextButton", VFlyMain); FwFBtn.Size = UDim2.new(0.48, 0, 0, 25); FwFBtn.Position = UDim2.new(0, 10, 0, 80); FwFBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FwFBtn.Text = "FwF: OFF"; FwFBtn.TextColor3 = tWhite; FwFBtn.Font = Enum.Font.GothamBold; FwFBtn.TextSize = 11; Instance.new("UICorner", FwFBtn).CornerRadius = UDim.new(0, 4)
local CtrlBtn = Instance.new("TextButton", VFlyMain); CtrlBtn.Size = UDim2.new(0.48, 0, 0, 25); CtrlBtn.Position = UDim2.new(0.52, -10, 0, 80); CtrlBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); CtrlBtn.Text = "CTRLS: OFF"; CtrlBtn.TextColor3 = tWhite; CtrlBtn.Font = Enum.Font.GothamBold; CtrlBtn.TextSize = 11; Instance.new("UICorner", CtrlBtn).CornerRadius = UDim.new(0, 4)
local PitchBtn = Instance.new("TextButton", VFlyMain); PitchBtn.Size = UDim2.new(0.48, 0, 0, 25); PitchBtn.Position = UDim2.new(0, 10, 0, 110); PitchBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); PitchBtn.Text = "PITCH: OFF"; PitchBtn.TextColor3 = tWhite; PitchBtn.Font = Enum.Font.GothamBold; PitchBtn.TextSize = 11; Instance.new("UICorner", PitchBtn).CornerRadius = UDim.new(0, 4)
local ALBtn = Instance.new("TextButton", VFlyMain); ALBtn.Size = UDim2.new(0.48, 0, 0, 25); ALBtn.Position = UDim2.new(0.52, -10, 0, 110); ALBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); ALBtn.Text = "A-L: OFF"; ALBtn.TextColor3 = tWhite; ALBtn.Font = Enum.Font.GothamBold; ALBtn.TextSize = 11; Instance.new("UICorner", ALBtn).CornerRadius = UDim.new(0, 4)

local VFlySpeedMinus = Instance.new("TextButton", VFlyMain); VFlySpeedMinus.Size = UDim2.new(0, 40, 0, 30); VFlySpeedMinus.Position = UDim2.new(0, 10, 0, 140); VFlySpeedMinus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); VFlySpeedMinus.Text = "-"; VFlySpeedMinus.TextColor3 = tWhite; VFlySpeedMinus.Font = Enum.Font.GothamBold; Instance.new("UICorner", VFlySpeedMinus)
local VFlySpeedDisplay = Instance.new("TextBox", VFlyMain); VFlySpeedDisplay.Size = UDim2.new(1, -110, 0, 30); VFlySpeedDisplay.Position = UDim2.new(0, 55, 0, 140); VFlySpeedDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 25); VFlySpeedDisplay.Text = "SPEED: 1"; VFlySpeedDisplay.TextColor3 = tWhite; VFlySpeedDisplay.Font = Enum.Font.GothamSemibold; VFlySpeedDisplay.TextSize = 13; VFlySpeedDisplay.ClearTextOnFocus = true; Instance.new("UICorner", VFlySpeedDisplay); Instance.new("UIStroke", VFlySpeedDisplay).Color = Color3.fromRGB(50, 50, 50)
local VFlySpeedPlus = Instance.new("TextButton", VFlyMain); VFlySpeedPlus.Size = UDim2.new(0, 40, 0, 30); VFlySpeedPlus.Position = UDim2.new(1, -50, 0, 140); VFlySpeedPlus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); VFlySpeedPlus.Text = "+"; VFlySpeedPlus.TextColor3 = tWhite; VFlySpeedPlus.Font = Enum.Font.GothamBold; Instance.new("UICorner", VFlySpeedPlus)

-- Controles Flotantes
local CtrlGui = Instance.new("ScreenGui", CoreGui); CtrlGui.Name = "CDT_VFly_Controls"; CtrlGui.Enabled = false
local CtrlLeft = Instance.new("Frame", CtrlGui); CtrlLeft.Size = UDim2.new(0, 120, 0, 120); CtrlLeft.Position = UDim2.new(0.05, 0, 0.6, 0); CtrlLeft.BackgroundTransparency = 1
local CtrlRight = Instance.new("Frame", CtrlGui); CtrlRight.Size = UDim2.new(0, 120, 0, 120); CtrlRight.Position = UDim2.new(0.85, -120, 0.6, 0); CtrlRight.BackgroundTransparency = 1

local function createDirBtn(parent, text, pos)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 45, 0, 45); btn.Position = pos; btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); btn.BackgroundTransparency = 0.3; btn.Text = text; btn.TextColor3 = tWhite; btn.Font = Enum.Font.GothamBold; btn.TextSize = 18; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", btn).Color = borderDark
    return btn
end

local BtnUp = createDirBtn(CtrlLeft, "↑", UDim2.new(0.5, -22, 0, 0))
local BtnDown = createDirBtn(CtrlLeft, "↓", UDim2.new(0.5, -22, 1, -45))
local BtnRotL = createDirBtn(CtrlLeft, "↶", UDim2.new(0, 0, 0.5, -22))
local BtnRotR = createDirBtn(CtrlLeft, "↷", UDim2.new(1, -45, 0.5, -22))

local BtnFwd = createDirBtn(CtrlRight, "W", UDim2.new(0.5, -22, 0, 0))
local BtnBwd = createDirBtn(CtrlRight, "S", UDim2.new(0.5, -22, 1, -45))
local BtnLeft = createDirBtn(CtrlRight, "A", UDim2.new(0, 0, 0.5, -22))
local BtnRight = createDirBtn(CtrlRight, "D", UDim2.new(1, -45, 0.5, -22))

ApplyResponsiveScale(VFlyMain)
MakeDraggable(VFlyTopBar, VFlyMain)

local vflyMinimized = false
VFlyMinBtn.MouseButton1Click:Connect(function()
    vflyMinimized = not vflyMinimized
    TweenService:Create(VFlyMain, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = vflyMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 185)}):Play()
    VFlyMinBtn.Text = vflyMinimized and "+" or "—"
    VFlyFix.Visible = not vflyMinimized
end)
VFlyCloseBtn.MouseButton1Click:Connect(function() VFlyMain.Visible = false end)

-- Lógica Interna VFly
local isVFlying = false; local vFlySpeed = 1; local fwfEnabled = false; local vFlyCtrlEnabled = false; local vFlyPitch = false; local vFlyAL = false
local vFlyMoveDir = {}; local VVelocityHandler = nil; local VGyroHandler = nil; local seatConn = nil; local unseatConn = nil; local vFlyLoop = nil
local vFwdVel = 100; local vSideVel = 100; local vUpVel = 50; local vRotSpeed = 5

VFlySpeedMinus.MouseButton1Click:Connect(function() vFlySpeed = math.max(1, vFlySpeed - 1); VFlySpeedDisplay.Text = "SPEED: " .. vFlySpeed end)
VFlySpeedPlus.MouseButton1Click:Connect(function() vFlySpeed = vFlySpeed + 1; VFlySpeedDisplay.Text = "SPEED: " .. vFlySpeed end)
VFlySpeedDisplay.FocusLost:Connect(function()
    local num = tonumber(VFlySpeedDisplay.Text:match("%d+"))
    if num then vFlySpeed = math.max(1, num) end; VFlySpeedDisplay.Text = "SPEED: " .. vFlySpeed
end)

local function VFlySetup(char)
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if char.HumanoidRootPart:FindFirstChild("VFlyVel") then char.HumanoidRootPart.VFlyVel:Destroy() end
    if char.HumanoidRootPart:FindFirstChild("VFlyGyro") then char.HumanoidRootPart.VFlyGyro:Destroy() end
    
    VVelocityHandler = Instance.new("BodyVelocity", char.HumanoidRootPart)
    VVelocityHandler.Name = "VFlyVel"; VVelocityHandler.MaxForce = Vector3.new(9e9, 9e9, 9e9); VVelocityHandler.Velocity = Vector3.new()
    VGyroHandler = Instance.new("BodyGyro", char.HumanoidRootPart)
    VGyroHandler.Name = "VFlyGyro"; VGyroHandler.MaxTorque = Vector3.new(9e9, 9e9, 9e9); VGyroHandler.P = 1000; VGyroHandler.D = 50; VGyroHandler.CFrame = char.HumanoidRootPart.CFrame
end

local function VFlyDisable()
    if VVelocityHandler then VVelocityHandler:Destroy(); VVelocityHandler = nil end
    if VGyroHandler then VGyroHandler:Destroy(); VGyroHandler = nil end
end

local function AddDir(dir) table.insert(vFlyMoveDir, dir) end
local function RemDir(dir)
    for i = #vFlyMoveDir, 1, -1 do if vFlyMoveDir[i] == dir then table.remove(vFlyMoveDir, i) end end
end

-- Conectar UI de Movimiento
BtnFwd.MouseButton1Down:Connect(function() AddDir("fwd"); BtnFwd.UIStroke.Color = tPurple end)
BtnFwd.MouseButton1Up:Connect(function() RemDir("fwd"); BtnFwd.UIStroke.Color = borderDark end)
BtnBwd.MouseButton1Down:Connect(function() AddDir("bwd"); BtnBwd.UIStroke.Color = tPurple end)
BtnBwd.MouseButton1Up:Connect(function() RemDir("bwd"); BtnBwd.UIStroke.Color = borderDark end)
BtnLeft.MouseButton1Down:Connect(function() AddDir("left"); BtnLeft.UIStroke.Color = tPurple end)
BtnLeft.MouseButton1Up:Connect(function() RemDir("left"); BtnLeft.UIStroke.Color = borderDark end)
BtnRight.MouseButton1Down:Connect(function() AddDir("right"); BtnRight.UIStroke.Color = tPurple end)
BtnRight.MouseButton1Up:Connect(function() RemDir("right"); BtnRight.UIStroke.Color = borderDark end)
BtnUp.MouseButton1Down:Connect(function() AddDir("up"); BtnUp.UIStroke.Color = tPurple end)
BtnUp.MouseButton1Up:Connect(function() RemDir("up"); BtnUp.UIStroke.Color = borderDark end)
BtnDown.MouseButton1Down:Connect(function() AddDir("down"); BtnDown.UIStroke.Color = tPurple end)
BtnDown.MouseButton1Up:Connect(function() RemDir("down"); BtnDown.UIStroke.Color = borderDark end)
BtnRotL.MouseButton1Down:Connect(function() AddDir("rotL"); BtnRotL.UIStroke.Color = tPurple end)
BtnRotL.MouseButton1Up:Connect(function() RemDir("rotL"); BtnRotL.UIStroke.Color = borderDark end)
BtnRotR.MouseButton1Down:Connect(function() AddDir("rotR"); BtnRotR.UIStroke.Color = tPurple end)
BtnRotR.MouseButton1Up:Connect(function() RemDir("rotR"); BtnRotR.UIStroke.Color = borderDark end)

-- PC Controls support for VFly
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not isVFlying then return end
    if input.KeyCode == Enum.KeyCode.W then AddDir("fwd")
    elseif input.KeyCode == Enum.KeyCode.S then AddDir("bwd")
    elseif input.KeyCode == Enum.KeyCode.A then AddDir("left")
    elseif input.KeyCode == Enum.KeyCode.D then AddDir("right")
    elseif input.KeyCode == Enum.KeyCode.Space then AddDir("up")
    elseif input.KeyCode == Enum.KeyCode.LeftControl then AddDir("down")
    elseif input.KeyCode == Enum.KeyCode.Q then AddDir("rotL")
    elseif input.KeyCode == Enum.KeyCode.E then AddDir("rotR") end
end)
UserInputService.InputEnded:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.W then RemDir("fwd")
    elseif input.KeyCode == Enum.KeyCode.S then RemDir("bwd")
    elseif input.KeyCode == Enum.KeyCode.A then RemDir("left")
    elseif input.KeyCode == Enum.KeyCode.D then RemDir("right")
    elseif input.KeyCode == Enum.KeyCode.Space then RemDir("up")
    elseif input.KeyCode == Enum.KeyCode.LeftControl then RemDir("down")
    elseif input.KeyCode == Enum.KeyCode.Q then RemDir("rotL")
    elseif input.KeyCode == Enum.KeyCode.E then RemDir("rotR") end
end)

local function VFlyLoop()
    local char = LocalPlayer.Character; if not char then return end
    local hum = char:FindFirstChild("Humanoid"); if not hum then return end
    if isVFlying and (hum.SeatPart or fwfEnabled) then
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root or not VVelocityHandler then return end
        
        local gyro = root:FindFirstChild("VFlyGyro")
        local vel = Vector3.new()
        
        local function getMoveCF()
            if vFlyPitch and gyro then return gyro.CFrame
            elseif gyro then
                local lv = gyro.CFrame.LookVector
                return CFrame.new(gyro.Parent.Position, gyro.Parent.Position + Vector3.new(lv.X, 0, lv.Z))
            end
            return root.CFrame
        end
        local moveCF = getMoveCF()
        
        for _, d in ipairs(vFlyMoveDir) do
            if d == "fwd" then vel += moveCF.LookVector * vFwdVel
            elseif d == "bwd" then vel += -moveCF.LookVector * vFwdVel
            elseif d == "left" then vel += moveCF.RightVector * -vSideVel
            elseif d == "right" then vel += moveCF.RightVector * vSideVel
            elseif d == "up" then vel += Vector3.new(0, vUpVel, 0)
            elseif d == "down" then vel += Vector3.new(0, -vUpVel, 0)
            elseif d == "rotL" and gyro then gyro.CFrame *= CFrame.Angles(0, math.rad(-vRotSpeed), 0)
            elseif d == "rotR" and gyro then gyro.CFrame *= CFrame.Angles(0, math.rad(vRotSpeed), 0) end
        end
        
        if #vFlyMoveDir > 0 then
            if vFlyAL and hum.SeatPart then
                local sFwd = hum.SeatPart.CFrame.LookVector; local sRight = hum.SeatPart.CFrame.RightVector; local sUp = hum.SeatPart.CFrame.UpVector
                local sVel = Vector3.new()
                for _, d in ipairs(vFlyMoveDir) do
                    if d == "fwd" then sVel += sFwd * vFwdVel elseif d == "bwd" then sVel += -sFwd * vFwdVel
                    elseif d == "left" then sVel += -sRight * vSideVel elseif d == "right" then sVel += sRight * vSideVel
                    elseif d == "up" then sVel += sUp * vUpVel elseif d == "down" then sVel += -sUp * vUpVel end
                end
                VVelocityHandler.Velocity = sVel * vFlySpeed
            else
                VVelocityHandler.Velocity = vel * vFlySpeed
            end
        else
            VVelocityHandler.Velocity = Vector3.new()
        end
        
        if not vFlyAL and gyro then
            local cam = Workspace.CurrentCamera
            if vFlyPitch then gyro.CFrame = cam.CFrame
            else
                local flatLv = cam.CFrame.LookVector * Vector3.new(1,0,1)
                gyro.CFrame = CFrame.new(gyro.Parent.Position, gyro.Parent.Position + flatLv)
            end
        end
    else
        if VVelocityHandler then VVelocityHandler.Velocity = Vector3.new() end
    end
end

VFlyToggleBtn.MouseButton1Click:Connect(function()
    isVFlying = not isVFlying
    local char = LocalPlayer.Character; local hum = char and char:FindFirstChild("Humanoid")
    if isVFlying then
        VFlyToggleBtn.BackgroundColor3 = tPurple; VFlyToggleBtn.Text = "V-FLY: ON"
        if fwfEnabled then VFlySetup(char)
        elseif hum then
            if seatConn then seatConn:Disconnect() end; if unseatConn then unseatConn:Disconnect() end
            if hum.SeatPart then VFlySetup(char)
            else seatConn = hum:GetPropertyChangedSignal("SeatPart"):Connect(function() if hum.SeatPart then VFlySetup(char) end end) end
            unseatConn = hum:GetPropertyChangedSignal("SeatPart"):Connect(function() if not hum.SeatPart then VFlyDisable() end end)
        end
        if not vFlyLoop then vFlyLoop = RunService.RenderStepped:Connect(VFlyLoop) end
    else
        VFlyToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); VFlyToggleBtn.Text = "V-FLY: OFF"
        VFlyDisable()
        if seatConn then seatConn:Disconnect(); seatConn = nil end
        if unseatConn then unseatConn:Disconnect(); unseatConn = nil end
        if vFlyLoop then vFlyLoop:Disconnect(); vFlyLoop = nil end
        vFlyMoveDir = {}
    end
end)

FwFBtn.MouseButton1Click:Connect(function()
    fwfEnabled = not fwfEnabled
    if fwfEnabled then FwFBtn.BackgroundColor3 = tCyan; FwFBtn.TextColor3 = Color3.fromRGB(10,10,10); FwFBtn.Text = "FwF: ON"
    else FwFBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); FwFBtn.TextColor3 = tWhite; FwFBtn.Text = "FwF: OFF" end
    if isVFlying and not fwfEnabled then
        local char = LocalPlayer.Character; local hum = char and char:FindFirstChild("Humanoid")
        if hum and not hum.SeatPart then VFlyDisable() end
    end
end)

CtrlBtn.MouseButton1Click:Connect(function()
    vFlyCtrlEnabled = not vFlyCtrlEnabled
    if vFlyCtrlEnabled then CtrlBtn.BackgroundColor3 = tPurple; CtrlBtn.Text = "CTRLS: ON"; CtrlGui.Enabled = true
    else CtrlBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); CtrlBtn.Text = "CTRLS: OFF"; CtrlGui.Enabled = false end
end)

PitchBtn.MouseButton1Click:Connect(function()
    if vFlyAL then PitchBtn.Text = "PITCH: OFF"; vFlyPitch = false return end
    vFlyPitch = not vFlyPitch
    if vFlyPitch then PitchBtn.BackgroundColor3 = tGreen; PitchBtn.TextColor3 = Color3.fromRGB(10,10,10); PitchBtn.Text = "PITCH: ON"
    else PitchBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); PitchBtn.TextColor3 = tWhite; PitchBtn.Text = "PITCH: OFF" end
end)

ALBtn.MouseButton1Click:Connect(function()
    vFlyAL = not vFlyAL
    if vFlyAL then 
        ALBtn.BackgroundColor3 = tOrange; ALBtn.TextColor3 = Color3.fromRGB(10,10,10); ALBtn.Text = "A-L: ON"
        if vFlyPitch then vFlyPitch = false; PitchBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); PitchBtn.TextColor3 = tWhite; PitchBtn.Text = "PITCH: OFF" end
    else ALBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); ALBtn.TextColor3 = tWhite; ALBtn.Text = "A-L: OFF" end
end)

-- ==================================================================
-- 6. CHAT GLOBAL SMART SCROLL (ESTÉTICA C.D.T OPTIFINE)
-- ==================================================================
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local setclipboard = setclipboard or toclipboard or set_clipboard

local ChatMain = Instance.new("Frame", ScreenGui)
ChatMain.Size = UDim2.new(0, 380, 0, 270); ChatMain.Position = UDim2.new(0.05, 0, 0.6, 0); ChatMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); ChatMain.BorderSizePixel = 0; ChatMain.ClipsDescendants = true; ChatMain.Visible = false
Instance.new("UICorner", ChatMain).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", ChatMain).Color = borderDark
ApplyResponsiveScale(ChatMain)

local ChatTopBar = Instance.new("Frame", ChatMain); ChatTopBar.Size = UDim2.new(1, 0, 0, 35); ChatTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); ChatTopBar.BorderSizePixel = 0; Instance.new("UICorner", ChatTopBar).CornerRadius = UDim.new(0, 6)
local ChatFix = Instance.new("Frame", ChatTopBar); ChatFix.Size = UDim2.new(1, 0, 0, 5); ChatFix.Position = UDim2.new(0, 0, 1, -5); ChatFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); ChatFix.BorderSizePixel = 0
local ChatTitle = Instance.new("TextLabel", ChatTopBar); ChatTitle.Size = UDim2.new(1, -70, 1, 0); ChatTitle.Position = UDim2.new(0, 15, 0, 0); ChatTitle.BackgroundTransparency = 1; ChatTitle.Text = "GLOBAL CHAT"; ChatTitle.TextColor3 = tWhite; ChatTitle.Font = Enum.Font.GothamBold; ChatTitle.TextSize = 12; ChatTitle.TextXAlignment = Enum.TextXAlignment.Left
local ChatMinBtn = Instance.new("TextButton", ChatTopBar); ChatMinBtn.Size = UDim2.new(0, 35, 1, 0); ChatMinBtn.Position = UDim2.new(1, -70, 0, 0); ChatMinBtn.BackgroundTransparency = 1; ChatMinBtn.Text = "—"; ChatMinBtn.TextColor3 = tGreen; ChatMinBtn.Font = Enum.Font.GothamBlack; ChatMinBtn.TextSize = 14
local ChatCloseBtn = Instance.new("TextButton", ChatTopBar); ChatCloseBtn.Size = UDim2.new(0, 35, 1, 0); ChatCloseBtn.Position = UDim2.new(1, -35, 0, 0); ChatCloseBtn.BackgroundTransparency = 1; ChatCloseBtn.Text = "X"; ChatCloseBtn.TextColor3 = tRed; ChatCloseBtn.Font = Enum.Font.GothamBlack; ChatCloseBtn.TextSize = 12

local ChatScroll = Instance.new("ScrollingFrame", ChatMain); ChatScroll.Position = UDim2.new(0, 5, 0, 45); ChatScroll.Size = UDim2.new(1, -10, 0, 175); ChatScroll.BackgroundTransparency = 1; ChatScroll.ScrollBarThickness = 2; ChatScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
local ChatLayout = Instance.new("UIListLayout", ChatScroll); ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder; ChatLayout.Padding = UDim.new(0, 4)

local NewMsgBtn = Instance.new("TextButton", ChatMain)
NewMsgBtn.Name = "NewMsgBtn"; NewMsgBtn.Text = "⬇ Nuevos Mensajes"
NewMsgBtn.Size = UDim2.new(0, 150, 0, 25); NewMsgBtn.Position = UDim2.new(0.5, -75, 1, -70)
NewMsgBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22); NewMsgBtn.TextColor3 = tYellow; NewMsgBtn.Font = Enum.Font.GothamBold; NewMsgBtn.Visible = false; NewMsgBtn.ZIndex = 5; NewMsgBtn.TextSize = 12
Instance.new("UICorner", NewMsgBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", NewMsgBtn).Color = borderDark

local ChatBox = Instance.new("TextBox", ChatMain); ChatBox.Position = UDim2.new(0, 5, 1, -40); ChatBox.Size = UDim2.new(0.68, 0, 0, 35); ChatBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10); ChatBox.TextColor3 = tWhite; ChatBox.PlaceholderText = "Escribe un mensaje..."; ChatBox.Font = Enum.Font.Gotham; ChatBox.TextSize = 13; ChatBox.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", ChatBox).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", ChatBox).Color = Color3.fromRGB(40, 40, 40); Instance.new("UIPadding", ChatBox).PaddingLeft = UDim.new(0, 10)
local ChatSendBtn = Instance.new("TextButton", ChatMain); ChatSendBtn.Position = UDim2.new(0.71, 0, 1, -40); ChatSendBtn.Size = UDim2.new(0.27, 0, 0, 35); ChatSendBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22); ChatSendBtn.TextColor3 = tGreen; ChatSendBtn.Text = "ENVIAR"; ChatSendBtn.Font = Enum.Font.GothamBold; ChatSendBtn.TextSize = 12; Instance.new("UICorner", ChatSendBtn).CornerRadius = UDim.new(0, 4)

MakeDraggable(ChatTopBar, ChatMain)

local chatMinimized = false
ChatMinBtn.MouseButton1Click:Connect(function()
    chatMinimized = not chatMinimized
    TweenService:Create(ChatMain, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = chatMinimized and UDim2.new(0, 380, 0, 35) or UDim2.new(0, 380, 0, 270)}):Play()
    ChatMinBtn.Text = chatMinimized and "+" or "—"
    ChatFix.Visible = not chatMinimized
    if chatMinimized then NewMsgBtn.Visible = false end
end)
ChatCloseBtn.MouseButton1Click:Connect(function() ChatMain.Visible = false end)

local function GetUserColor(username)
    local hash = 0
    for i = 1, #username do hash = hash + string.byte(username, i) end
    math.randomseed(hash)
    local r = math.random(100, 255); local g = math.random(100, 255); local b = math.random(100, 255)
    math.randomseed(tick())
    return string.format("#%02X%02X%02X", r, g, b)
end

local function OpenProfile(username)
    local s, id = pcall(function() return Players:GetUserIdFromNameAsync(username) end)
    if s and id then
        local s2 = pcall(function() StarterGui:SetCore("PromptProfile", id) end)
        if not s2 and setclipboard then 
            setclipboard("https://www.roblox.com/users/"..id.."/profile") 
            StarterGui:SetCore("SendNotification", {Title="Perfil", Text="Link copiado al portapapeles.", Duration=2})
        end
    end
end

local function CrearFilaMensaje(usuario, mensaje)
    local Row = Instance.new("Frame", ChatScroll)
    Row.Size = UDim2.new(1, 0, 0, 0); Row.AutomaticSize = Enum.AutomaticSize.Y; Row.BackgroundTransparency = 1
    
    local RowLayout = Instance.new("UIListLayout", Row)
    RowLayout.FillDirection = Enum.FillDirection.Horizontal; RowLayout.VerticalAlignment = Enum.VerticalAlignment.Center; RowLayout.Padding = UDim.new(0, 6)

    local pad = Instance.new("Frame", Row); pad.BackgroundTransparency = 1; pad.Size = UDim2.new(0, 2, 0, 20)

    local NameBtn = Instance.new("TextButton", Row)
    NameBtn.Text = usuario .. ":"
    NameBtn.TextColor3 = Color3.fromHex(GetUserColor(usuario))
    NameBtn.BackgroundTransparency = 1; NameBtn.Font = Enum.Font.GothamBold; NameBtn.TextSize = 13; NameBtn.AutomaticSize = Enum.AutomaticSize.XY
    NameBtn.MouseButton1Click:Connect(function() OpenProfile(usuario) end)

    local MsgLbl = Instance.new("TextLabel", Row)
    MsgLbl.Text = mensaje
    MsgLbl.TextColor3 = tWhite; MsgLbl.BackgroundTransparency = 1; MsgLbl.Font = Enum.Font.Gotham; MsgLbl.TextSize = 13; MsgLbl.TextXAlignment = Enum.TextXAlignment.Left; MsgLbl.TextWrapped = true; MsgLbl.AutomaticSize = Enum.AutomaticSize.XY; MsgLbl.Size = UDim2.new(0, 0, 0, 0)
    if mensaje:lower():find("http") or mensaje:lower():find("www") then MsgLbl.TextColor3 = tCyan end

    local CopyBtn = Instance.new("TextButton", Row)
    CopyBtn.Text = "📋"; CopyBtn.BackgroundTransparency = 1; CopyBtn.Size = UDim2.new(0, 20, 0, 20); CopyBtn.TextSize = 13; CopyBtn.TextColor3 = tYellow
    CopyBtn.MouseButton1Click:Connect(function()
        if setclipboard then 
            setclipboard(mensaje)
            CopyBtn.Text = "✔️"; CopyBtn.TextColor3 = tGreen
            task.wait(1); CopyBtn.Text = "📋"; CopyBtn.TextColor3 = tYellow
        end
    end)
end

local isUpdatingChat = false
local lastMsgCount = 0
local forceScrollBottom = false

NewMsgBtn.MouseButton1Click:Connect(function()
    TweenService:Create(ChatScroll, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CanvasPosition = Vector2.new(0, ChatScroll.CanvasSize.Y.Offset)}):Play()
    NewMsgBtn.Visible = false
end)

ChatScroll.Changed:Connect(function(prop)
    if prop == "CanvasPosition" or prop == "CanvasSize" then
        local maxScroll = math.max(0, ChatScroll.CanvasSize.Y.Offset - ChatScroll.AbsoluteWindowSize.Y)
        if (maxScroll - ChatScroll.CanvasPosition.Y) <= 40 then
            NewMsgBtn.Visible = false
        end
    end
end)

local function ActualizarChat()
    if isUpdatingChat or not request then return end
    isUpdatingChat = true

    local s, r = pcall(function() return request({Url = URL_NGROK .. "/leer", Method = "GET", Headers = {["ngrok-skip-browser-warning"] = "true"}}) end)

    if s and r.StatusCode == 200 then
        local data = HttpService:JSONDecode(r.Body)
        local hayNuevos = #data > lastMsgCount
        
        local maxScroll = math.max(0, ChatScroll.CanvasSize.Y.Offset - ChatScroll.AbsoluteWindowSize.Y)
        local currentScroll = ChatScroll.CanvasPosition.Y
        local wasAtBottom = (maxScroll - currentScroll) <= 40
        
        if lastMsgCount == 0 or forceScrollBottom then 
            wasAtBottom = true 
            forceScrollBottom = false
        end

        if hayNuevos then
            for _, v in pairs(ChatScroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
            for _, m in pairs(data) do CrearFilaMensaje(m.u, m.m) end
            
            task.defer(function()
                ChatScroll.CanvasSize = UDim2.new(0, 0, 0, ChatLayout.AbsoluteContentSize.Y)
                if wasAtBottom then
                    ChatScroll.CanvasPosition = Vector2.new(0, ChatScroll.CanvasSize.Y.Offset)
                    NewMsgBtn.Visible = false
                else
                    NewMsgBtn.Visible = true
                end
            end)
        end
        lastMsgCount = #data
    end
    isUpdatingChat = false
end

local sending = false
local function SendMessage()
    if sending or ChatBox.Text == "" or not request then return end
    sending = true
    local txt = ChatBox.Text; ChatBox.Text = "" 
    local payload = HttpService:JSONEncode({usuario = LocalPlayer.Name, texto = txt})

    task.spawn(function()
        local s, r = pcall(function() request({Url = URL_NGROK .. "/enviar", Method = "POST", Headers = {["Content-Type"]="application/json", ["ngrok-skip-browser-warning"]="true"}, Body = payload}) end)
        sending = false
        if s then 
            forceScrollBottom = true
            ActualizarChat() 
        else
            ChatBox.Text = txt
        end
    end)
end

ChatSendBtn.MouseButton1Click:Connect(SendMessage)
ChatBox.FocusLost:Connect(function(enter) if enter then SendMessage() end end)

task.spawn(function()
    while task.wait(2) do if ChatMain.Visible and not chatMinimized then ActualizarChat() end end
end)

-- ==================================================================
-- 7. SISTEMA GLOBAL DE TECLAS Y COMANDOS (CON AUTOCOMPLETADO)
-- ==================================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if isInvBinding and input.UserInputType == Enum.UserInputType.Keyboard then invKeybind = input.KeyCode; InvKeyBtn.Text = input.KeyCode.Name; InvKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isInvBinding = false; return end
    if isFlyBinding and input.UserInputType == Enum.UserInputType.Keyboard then flyKeybind = input.KeyCode; FlyKeyBtn.Text = input.KeyCode.Name; FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isFlyBinding = false; return end
    
    if not gp then
        if input.KeyCode == Enum.KeyCode.Insert then ToggleMenu() end
        if invKeybind and input.KeyCode == invKeybind then ToggleGhost() end
        if flyKeybind and input.KeyCode == flyKeybind then ToggleFly() end
    end
end)

local function LogMessage(text, color)
    local lbl = Instance.new("TextLabel", Console)
    lbl.Size = UDim2.new(1, 0, 0, 20); lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. text; lbl.TextColor3 = color or tWhite
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextWrapped = true
    Console.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
    Console.CanvasPosition = Vector2.new(0, Console.CanvasSize.Y.Offset)
end

LogMessage("Terminal C.D.T Optifine cargada.", tGreen)

local function GetPlayer(nameString)
    nameString = string.lower(nameString)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then 
            if string.lower(string.sub(p.Name, 1, #nameString)) == nameString or string.lower(string.sub(p.DisplayName, 1, #nameString)) == nameString then return p end
        end
    end
    return nil
end

local Comandos = {}
local function AddCmd(cmd, desc, action) Comandos[cmd] = {Desc = desc, Accion = action} end

AddCmd("cmds", "Lista de comandos", function()
    LogMessage("--- COMANDOS DISPONIBLES ---", tYellow)
    for c, info in pairs(Comandos) do LogMessage(c .. " : " .. info.Desc, tCyan) end
end)

AddCmd("to", "TP a jugador (Ej: to juan)", function(args)
    if args[1] then
        local target = GetPlayer(args[1])
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            LogMessage("Teletransportado a " .. target.DisplayName, tPurple)
        else
            LogMessage("Jugador no encontrado.", tRed)
        end
    end
end)

AddCmd("tpmenu", "Abre la lista de TP visual", function() TPSearchBox.Text = ""; RefreshTPMenu(); TPMain.Visible = true; LogMessage("TP Menu abierto.", tOrange) end)
AddCmd("invisible", "Abre el panel de Invisibilidad", function() InvMain.Visible = true; LogMessage("Menú Invisible abierto.", tPurple) end)
AddCmd("fly", "Abre el panel de Vuelo", function() FlyMain.Visible = true; LogMessage("Menú de Vuelo abierto.", tYellow) end)
AddCmd("vfly", "Abre el panel de Vehicle Fly", function() VFlyMain.Visible = true; LogMessage("Menú de Vehicle Fly abierto.", tPurple) end)
AddCmd("chat", "Abre el chat global", function() ChatMain.Visible = true; ActualizarChat(); LogMessage("Chat Global conectado.", tGreen) end)

AddCmd("speed", "Cambia la velocidad", function(args)
    if args[1] and tonumber(args[1]) then
        LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(args[1])
        LogMessage("Velocidad -> " .. args[1], tGreen)
    end
end)

AddCmd("destroy", "Cierra y elimina el panel completo de forma segura", function()
    if isGhostActive then ToggleGhost() end
    if isFlying then ToggleFly() end
    if isVFlying then VFlyDisable() end
    LogMessage("Cerrando C.D.T Optifine...", tPurple)
    task.wait(0.5)
    ScreenGui:Destroy()
end)

local SuggestFrame = Instance.new("ScrollingFrame", FullUI)
SuggestFrame.Size = UDim2.new(1, -20, 0, 0); SuggestFrame.Position = UDim2.new(0, 10, 1, -45); SuggestFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); SuggestFrame.BorderSizePixel = 0; SuggestFrame.Visible = false; SuggestFrame.ScrollBarThickness = 2; SuggestFrame.ZIndex = 10
Instance.new("UICorner", SuggestFrame).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", SuggestFrame).Color = Color3.fromRGB(50, 50, 50)
local SuggestList = Instance.new("UIListLayout", SuggestFrame); SuggestList.Padding = UDim.new(0, 2)

local function UpdateSuggestions()
    local text = string.lower(CmdBox.Text)
    for _, child in pairs(SuggestFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    
    if text == "" then SuggestFrame.Visible = false return end

    local args = string.split(text, " "); local currentCmd = args[1]; local suggestions = {}

    if #args == 1 then
        for cmd, info in pairs(Comandos) do
            if string.sub(cmd, 1, #currentCmd) == currentCmd then table.insert(suggestions, {Display = cmd .. " - " .. info.Desc, Fill = cmd .. " "}) end
        end
    elseif #args == 2 and (currentCmd == "to") then
        local currentArg = args[2]
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local pName = string.lower(p.Name); local dName = string.lower(p.DisplayName)
                if string.sub(pName, 1, #currentArg) == currentArg or string.sub(dName, 1, #currentArg) == currentArg then
                    table.insert(suggestions, {Display = p.DisplayName .. " (@" .. p.Name .. ")", Fill = currentCmd .. " " .. p.Name})
                end
            end
        end
    end

    if #suggestions > 0 then
        SuggestFrame.Visible = true; local ySize = 0
        for _, sug in ipairs(suggestions) do
            local btn = Instance.new("TextButton", SuggestFrame)
            btn.Size = UDim2.new(1, -5, 0, 22); btn.BackgroundTransparency = 1; btn.Text = "  " .. sug.Display; btn.TextColor3 = tWhite; btn.Font = Enum.Font.Gotham; btn.TextSize = 13; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.ZIndex = 11
            btn:SetAttribute("Fill", sug.Fill)
            
            btn.MouseEnter:Connect(function() btn.TextColor3 = tPurple end) 
            btn.MouseLeave:Connect(function() btn.TextColor3 = tWhite end)
            btn.MouseButton1Click:Connect(function() CmdBox.Text = sug.Fill; CmdBox:CaptureFocus(); SuggestFrame.Visible = false end)
            ySize = ySize + 24
        end
        local frameHeight = math.min(ySize, 100)
        SuggestFrame.CanvasSize = UDim2.new(0, 0, 0, ySize)
        SuggestFrame.Size = UDim2.new(1, -20, 0, frameHeight)
        SuggestFrame.Position = UDim2.new(0, 10, 1, -45 - frameHeight - 5)
    else
        SuggestFrame.Visible = false
    end
end

CmdBox:GetPropertyChangedSignal("Text"):Connect(UpdateSuggestions)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Tab and CmdBox:IsFocused() and SuggestFrame.Visible then
        for _, child in ipairs(SuggestFrame:GetChildren()) do
            if child:IsA("TextButton") then
                local fill = child:GetAttribute("Fill")
                if fill then task.defer(function() CmdBox.Text = fill; CmdBox:CaptureFocus(); CmdBox.CursorPosition = #fill + 1 end); SuggestFrame.Visible = false break end
            end
        end
    end
end)
CmdBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and CmdBox.Text ~= "" then
        local input = string.lower(CmdBox.Text); CmdBox.Text = ""; SuggestFrame.Visible = false
        LogMessage("> " .. input, tWhite)
        local split = string.split(input, " "); local cmd = split[1]; table.remove(split, 1)
        if Comandos[cmd] then pcall(function() Comandos[cmd].Accion(split) end) else LogMessage("Error: Comando desconocido.", tOrange) end
    end
end)
