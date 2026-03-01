--[[
    C.D.T OPTIFINE - V5 SUPREME HACKER EDITION
    - Anti-Duplicación Segura.
    - TP Menu (Buscador dinámico, UI Corregida).
    - Menú Invisible (GHOST MODE PERFECTO: Tools visuales, ataques reales, fix sentarse).
    - Menú de Vuelo (Superman Fly).
    - GLOBAL CHAT V2 (Conexión Ngrok, Copiar Links, UI Rediseñada).
    - Consola Inteligente (Autocompletado de comandos y jugadores con TAB).
    - Textos Hacker (Morado, Blanco, Verde, Naranja, Celeste, Amarillo).
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
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
-- COLORES PARA TEXTOS DE LA CONSOLA Y BORDES NEÓN
-- ==================================================================
local tPurple = Color3.fromRGB(170, 85, 255)
local tWhite = Color3.fromRGB(255, 255, 255)
local tGreen = Color3.fromRGB(0, 255, 136)
local tOrange = Color3.fromRGB(255, 150, 0)
local tCyan = Color3.fromRGB(0, 200, 255)
local tYellow = Color3.fromRGB(255, 220, 0)
local tRed = Color3.fromRGB(255, 60, 60)

-- ==================================================================
-- 0. SISTEMA ANTI-DUPLICACIÓN (NOTIFICACIÓN)
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
Instance.new("UIStroke", Main).Color = Color3.fromRGB(45, 45, 45)

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
local Dot = Instance.new("Frame", MiniUI); Dot.Size = UDim2.new(0, 6, 0, 6); Dot.Position = UDim2.new(0, 100, 0.5, -3); Dot.BackgroundColor3 = tGreen; Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
local MaxBtn = Instance.new("TextButton", MiniUI); MaxBtn.Size = UDim2.new(0, 35, 1, 0); MaxBtn.Position = UDim2.new(1, -35, 0, 0); MaxBtn.BackgroundTransparency = 1; MaxBtn.Text = "⤢"; MaxBtn.TextColor3 = tGreen; MaxBtn.Font = Enum.Font.GothamBlack; MaxBtn.TextSize = 18

local function MakeDraggable(dragArea, targetFrame)
    local dragging, dragInput, dragStart, startPos
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = targetFrame.Position end
    end)
    dragArea.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
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
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 160, 0, 35)}):Play()
        TweenService:Create(FullUI, TweenInfo.new(0.2), {GroupTransparency = 1}):Play()
        TweenService:Create(MiniUI, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.1), {GroupTransparency = 0}):Play()
        task.wait(0.2); FullUI.Visible = false
    end
end
MinBtn.MouseButton1Click:Connect(ToggleMenu); MaxBtn.MouseButton1Click:Connect(ToggleMenu)

-- ==================================================================
-- 2. INTERFAZ TP MENU 
-- ==================================================================
local TPMain = Instance.new("Frame", ScreenGui); TPMain.Size = UDim2.new(0, 250, 0, 380); TPMain.Position = UDim2.new(0.5, -125, 0.5, -190); TPMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); TPMain.BorderSizePixel = 0; TPMain.ClipsDescendants = true; TPMain.Visible = false; Instance.new("UICorner", TPMain).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", TPMain).Color = Color3.fromRGB(45, 45, 45)
local TPTopBar = Instance.new("Frame", TPMain); TPTopBar.Size = UDim2.new(1, 0, 0, 35); TPTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TPTopBar.BorderSizePixel = 0; Instance.new("UICorner", TPTopBar).CornerRadius = UDim.new(0, 6)
local TPFix = Instance.new("Frame", TPTopBar); TPFix.Size = UDim2.new(1, 0, 0, 5); TPFix.Position = UDim2.new(0, 0, 1, -5); TPFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TPFix.BorderSizePixel = 0
local TPTitle = Instance.new("TextLabel", TPTopBar); TPTitle.Size = UDim2.new(1, -70, 1, 0); TPTitle.Position = UDim2.new(0, 15, 0, 0); TPTitle.BackgroundTransparency = 1; TPTitle.Text = "TP MENU"; TPTitle.TextColor3 = tWhite; TPTitle.Font = Enum.Font.GothamBold; TPTitle.TextSize = 12; TPTitle.TextXAlignment = Enum.TextXAlignment.Left
local TPMinBtn = Instance.new("TextButton", TPTopBar); TPMinBtn.Size = UDim2.new(0, 35, 1, 0); TPMinBtn.Position = UDim2.new(1, -70, 0, 0); TPMinBtn.BackgroundTransparency = 1; TPMinBtn.Text = "—"; TPMinBtn.TextColor3 = tYellow; TPMinBtn.Font = Enum.Font.GothamBlack; TPMinBtn.TextSize = 14
local TPCloseBtn = Instance.new("TextButton", TPTopBar); TPCloseBtn.Size = UDim2.new(0, 35, 1, 0); TPCloseBtn.Position = UDim2.new(1, -35, 0, 0); TPCloseBtn.BackgroundTransparency = 1; TPCloseBtn.Text = "X"; TPCloseBtn.TextColor3 = tRed; TPCloseBtn.Font = Enum.Font.GothamBlack; TPCloseBtn.TextSize = 12
local TPSearchBox = Instance.new("TextBox", TPMain); TPSearchBox.Size = UDim2.new(1, -10, 0, 30); TPSearchBox.Position = UDim2.new(0, 5, 0, 40); TPSearchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TPSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255); TPSearchBox.PlaceholderText = "🔍 Buscar jugador..."; TPSearchBox.Font = Enum.Font.Gotham; TPSearchBox.TextSize = 12; TPSearchBox.ClearTextOnFocus = false; Instance.new("UICorner", TPSearchBox).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", TPSearchBox).Color = Color3.fromRGB(50, 50, 50)
local TPScroll = Instance.new("ScrollingFrame", TPMain); TPScroll.Size = UDim2.new(1, -10, 1, -80); TPScroll.Position = UDim2.new(0, 5, 0, 75); TPScroll.BackgroundTransparency = 1; TPScroll.BorderSizePixel = 0; TPScroll.ScrollBarThickness = 2; TPScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
local TPListLayout = Instance.new("UIListLayout", TPScroll); TPListLayout.Padding = UDim.new(0, 5)

MakeDraggable(TPTopBar, TPMain)

local tpMinimized = false
TPMinBtn.MouseButton1Click:Connect(function()
    tpMinimized = not tpMinimized
    TweenService:Create(TPMain, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = tpMinimized and UDim2.new(0, 250, 0, 35) or UDim2.new(0, 250, 0, 380)}):Play()
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
                local NameLbl = Instance.new("TextLabel", Card); NameLbl.Size = UDim2.new(1, -100, 1, 0); NameLbl.Position = UDim2.new(0, 45, 0, 0); NameLbl.BackgroundTransparency = 1; NameLbl.Text = plr.DisplayName; NameLbl.TextColor3 = tWhite; NameLbl.Font = Enum.Font.GothamMedium; NameLbl.TextSize = 12; NameLbl.TextXAlignment = Enum.TextXAlignment.Left
                local TpBtn = Instance.new("TextButton", Card); TpBtn.Size = UDim2.new(0, 40, 0, 24); TpBtn.Position = UDim2.new(1, -45, 0.5, -12); TpBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136); TpBtn.Text = "TP"; TpBtn.TextColor3 = Color3.fromRGB(10, 10, 10); TpBtn.Font = Enum.Font.GothamBold; TpBtn.TextSize = 11; Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 4)
                
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
local InvMain = Instance.new("Frame", ScreenGui); InvMain.Size = UDim2.new(0, 250, 0, 95); InvMain.Position = UDim2.new(0.5, -300, 0.5, -120); InvMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); InvMain.BorderSizePixel = 0; InvMain.ClipsDescendants = true; InvMain.Visible = false; Instance.new("UICorner", InvMain).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", InvMain).Color = Color3.fromRGB(45, 45, 45)
local InvTopBar = Instance.new("Frame", InvMain); InvTopBar.Size = UDim2.new(1, 0, 0, 35); InvTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); InvTopBar.BorderSizePixel = 0; Instance.new("UICorner", InvTopBar).CornerRadius = UDim.new(0, 6)
local InvFix = Instance.new("Frame", InvTopBar); InvFix.Size = UDim2.new(1, 0, 0, 5); InvFix.Position = UDim2.new(0, 0, 1, -5); InvFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); InvFix.BorderSizePixel = 0
local InvTitle = Instance.new("TextLabel", InvTopBar); InvTitle.Size = UDim2.new(1, -70, 1, 0); InvTitle.Position = UDim2.new(0, 15, 0, 0); InvTitle.BackgroundTransparency = 1; InvTitle.Text = "INVISIBILITY"; InvTitle.TextColor3 = tWhite; InvTitle.Font = Enum.Font.GothamBold; InvTitle.TextSize = 12; InvTitle.TextXAlignment = Enum.TextXAlignment.Left
local InvMinBtn = Instance.new("TextButton", InvTopBar); InvMinBtn.Size = UDim2.new(0, 35, 1, 0); InvMinBtn.Position = UDim2.new(1, -70, 0, 0); InvMinBtn.BackgroundTransparency = 1; InvMinBtn.Text = "—"; InvMinBtn.TextColor3 = tGreen; InvMinBtn.Font = Enum.Font.GothamBlack; InvMinBtn.TextSize = 14
local InvCloseBtn = Instance.new("TextButton", InvTopBar); InvCloseBtn.Size = UDim2.new(0, 35, 1, 0); InvCloseBtn.Position = UDim2.new(1, -35, 0, 0); InvCloseBtn.BackgroundTransparency = 1; InvCloseBtn.Text = "X"; InvCloseBtn.TextColor3 = tRed; InvCloseBtn.Font = Enum.Font.GothamBlack; InvCloseBtn.TextSize = 12
local InvToggleBtn = Instance.new("TextButton", InvMain); InvToggleBtn.Size = UDim2.new(1, -70, 0, 40); InvToggleBtn.Position = UDim2.new(0, 10, 0, 45); InvToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); InvToggleBtn.Text = "INVISIBILIDAD: OFF"; InvToggleBtn.TextColor3 = tWhite; InvToggleBtn.Font = Enum.Font.GothamBold; InvToggleBtn.TextSize = 12; Instance.new("UICorner", InvToggleBtn).CornerRadius = UDim.new(0, 6)
local InvKeyBtn = Instance.new("TextButton", InvMain); InvKeyBtn.Size = UDim2.new(0, 45, 0, 40); InvKeyBtn.Position = UDim2.new(1, -55, 0, 45); InvKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); InvKeyBtn.Text = "KEY"; InvKeyBtn.TextColor3 = tWhite; InvKeyBtn.Font = Enum.Font.GothamBold; InvKeyBtn.TextSize = 10; Instance.new("UICorner", InvKeyBtn).CornerRadius = UDim.new(0, 6)

MakeDraggable(InvTopBar, InvMain)

local invMinimized = false
InvMinBtn.MouseButton1Click:Connect(function()
    invMinimized = not invMinimized
    TweenService:Create(InvMain, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = invMinimized and UDim2.new(0, 250, 0, 35) or UDim2.new(0, 250, 0, 95)}):Play()
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
local toolSyncConnAdded = nil
local toolSyncConnRemoved = nil
local currentVisualTool = nil
local animTracks = {Idle = nil, Walk = nil, Sit = nil}
local currentAnim = nil
local invKeybind = nil
local isInvBinding = false

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

local function createSafetyPlatform(pos)
    local p = Instance.new("Part")
    p.Name = "SafeZone_Floor"
    p.Size = Vector3.new(PLATFORM_SIZE, 4, PLATFORM_SIZE)
    p.Anchored = true; p.Transparency = 1; p.CanCollide = true
    p.CFrame = CFrame.new(pos - Vector3.new(0, DEPTH, 0))
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
            v.Transparency = CLONE_TRANSPARENCY; v.Anchored = false; v.CanCollide = true
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
    
    for _, v in pairs(clone:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.CanCollide = true end
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
            realRoot.CFrame = ghostRoot.CFrame
            if moveVec.Magnitude > 0 then ghostHum:Move(moveVec, false) else ghostHum:Move(Vector3.new(0,0,0), false) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then ghostHum.Jump = true end
        end
        
        local targetCollidable = not isSitting
        if targetCollidable ~= ghostCollidable then
            ghostCollidable = targetCollidable
            for _, v in pairs(ghostModel:GetDescendants()) do if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.CanCollide = ghostCollidable end end
        end
        
        local isMoving = isMovingInput and not isSitting
        updateGhostAnim(isMoving, isSitting)
        
        local platRoot = safetyPlatform
        if platRoot and (char.PrimaryPart.Position - platRoot.Position).Magnitude > PLATFORM_SIZE / 2 then
             char:SetPrimaryPartCFrame(platRoot.CFrame + Vector3.new(0, 5, 0))
        end
    end)
    
    activationConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local char = LocalPlayer.Character
        if not char or not isGhostActive then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            if input.UserInputType == Enum.UserInputType.MouseButton1 then tool:Activate() 
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then pcall(function() tool:Activate() end) end
        end
    end)
    getgenv().PhysicalGhostCon = controlsConnection
end

local function toggleGhost()
    isGhostActive = not isGhostActive
    getgenv().GhostActive = isGhostActive
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local realHum = char:FindFirstChild("Humanoid")
    if not root or not realHum then return end
    
    if isGhostActive then
        local startCF = root.CFrame
        safetyPlatform = createSafetyPlatform(startCF.Position)
        getgenv().GhostPlatform = safetyPlatform
        ghostModel = createPhysicalGhost(char)
        ghostModel.HumanoidRootPart.CFrame = startCF
        getgenv().GhostModel = ghostModel
        
        local currentTool = char:FindFirstChildOfClass("Tool")
        if currentTool then createVisualTool(currentTool, ghostModel) end
        
        setRealCharTransparency(false)
        Workspace.CurrentCamera.CameraSubject = ghostModel:FindFirstChild("Humanoid")
        char:SetPrimaryPartCFrame(safetyPlatform.CFrame + Vector3.new(0, 5, 0))
        
        toolSyncConnAdded = char.ChildAdded:Connect(function(child) if child:IsA("Tool") then createVisualTool(child, ghostModel) end end)
        toolSyncConnRemoved = char.ChildRemoved:Connect(function(child) if child:IsA("Tool") and currentVisualTool then currentVisualTool:Destroy(); currentVisualTool = nil end end)
        
        startControls() 
        InvToggleBtn.BackgroundColor3 = tGreen; InvToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10); InvToggleBtn.Text = "INVISIBILIDAD: ON"
    else
        if controlsConnection then controlsConnection:Disconnect() end
        if activationConn then activationConn:Disconnect() end
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
        
        InvToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); InvToggleBtn.TextColor3 = tWhite; InvToggleBtn.Text = "INVISIBILIDAD: OFF"
    end
end
InvToggleBtn.MouseButton1Click:Connect(toggleGhost)

InvKeyBtn.MouseButton1Click:Connect(function()
    if invKeybind ~= nil then invKeybind = nil; InvKeyBtn.Text = "KEY"; InvKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isInvBinding = false
    else isInvBinding = true; InvKeyBtn.Text = "..."; InvKeyBtn.BackgroundColor3 = tOrange end
end)

InvCloseBtn.MouseButton1Click:Connect(function() 
    if isGhostActive then toggleGhost() end
    invKeybind = nil; InvKeyBtn.Text = "KEY"; InvKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isInvBinding = false
    InvMain.Visible = false 
end)

LocalPlayer.CharacterAdded:Connect(function()
    if isGhostActive then toggleGhost() end -- Evita bugearse al morir
end)

-- ==================================================================
-- 4. INTERFAZ Y LÓGICA DEL MENÚ FLY (SUPERMAN FLY)
-- ==================================================================
local FlyMain = Instance.new("Frame", ScreenGui); FlyMain.Size = UDim2.new(0, 250, 0, 135); FlyMain.Position = UDim2.new(0.5, 50, 0.5, -120); FlyMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); FlyMain.BorderSizePixel = 0; FlyMain.ClipsDescendants = true; FlyMain.Visible = false; Instance.new("UICorner", FlyMain).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", FlyMain).Color = Color3.fromRGB(45, 45, 45)
local FlyTopBar = Instance.new("Frame", FlyMain); FlyTopBar.Size = UDim2.new(1, 0, 0, 35); FlyTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); FlyTopBar.BorderSizePixel = 0; Instance.new("UICorner", FlyTopBar).CornerRadius = UDim.new(0, 6)
local FlyFix = Instance.new("Frame", FlyTopBar); FlyFix.Size = UDim2.new(1, 0, 0, 5); FlyFix.Position = UDim2.new(0, 0, 1, -5); FlyFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); FlyFix.BorderSizePixel = 0
local FlyTitle = Instance.new("TextLabel", FlyTopBar); FlyTitle.Size = UDim2.new(1, -70, 1, 0); FlyTitle.Position = UDim2.new(0, 15, 0, 0); FlyTitle.BackgroundTransparency = 1; FlyTitle.Text = "FLIGHT MODE"; FlyTitle.TextColor3 = tWhite; FlyTitle.Font = Enum.Font.GothamBold; FlyTitle.TextSize = 12; FlyTitle.TextXAlignment = Enum.TextXAlignment.Left
local FlyMinBtn = Instance.new("TextButton", FlyTopBar); FlyMinBtn.Size = UDim2.new(0, 35, 1, 0); FlyMinBtn.Position = UDim2.new(1, -70, 0, 0); FlyMinBtn.BackgroundTransparency = 1; FlyMinBtn.Text = "—"; FlyMinBtn.TextColor3 = tGreen; FlyMinBtn.Font = Enum.Font.GothamBlack; FlyMinBtn.TextSize = 14
local FlyCloseBtn = Instance.new("TextButton", FlyTopBar); FlyCloseBtn.Size = UDim2.new(0, 35, 1, 0); FlyCloseBtn.Position = UDim2.new(1, -35, 0, 0); FlyCloseBtn.BackgroundTransparency = 1; FlyCloseBtn.Text = "X"; FlyCloseBtn.TextColor3 = tRed; FlyCloseBtn.Font = Enum.Font.GothamBlack; FlyCloseBtn.TextSize = 12

local FlyToggleBtn = Instance.new("TextButton", FlyMain); FlyToggleBtn.Size = UDim2.new(1, -70, 0, 40); FlyToggleBtn.Position = UDim2.new(0, 10, 0, 45); FlyToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); FlyToggleBtn.Text = "VUELO: OFF"; FlyToggleBtn.TextColor3 = tWhite; FlyToggleBtn.Font = Enum.Font.GothamBold; FlyToggleBtn.TextSize = 12; Instance.new("UICorner", FlyToggleBtn).CornerRadius = UDim.new(0, 6)
local FlyKeyBtn = Instance.new("TextButton", FlyMain); FlyKeyBtn.Size = UDim2.new(0, 45, 0, 40); FlyKeyBtn.Position = UDim2.new(1, -55, 0, 45); FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FlyKeyBtn.Text = "KEY"; FlyKeyBtn.TextColor3 = tWhite; FlyKeyBtn.Font = Enum.Font.GothamBold; FlyKeyBtn.TextSize = 10; Instance.new("UICorner", FlyKeyBtn).CornerRadius = UDim.new(0, 6)

local FlySpeedMinus = Instance.new("TextButton", FlyMain); FlySpeedMinus.Size = UDim2.new(0, 40, 0, 30); FlySpeedMinus.Position = UDim2.new(0, 10, 0, 95); FlySpeedMinus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FlySpeedMinus.Text = "-"; FlySpeedMinus.TextColor3 = tWhite; FlySpeedMinus.Font = Enum.Font.GothamBold; Instance.new("UICorner", FlySpeedMinus)
local FlySpeedDisplay = Instance.new("TextLabel", FlyMain); FlySpeedDisplay.Size = UDim2.new(1, -110, 0, 30); FlySpeedDisplay.Position = UDim2.new(0, 55, 0, 95); FlySpeedDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 25); FlySpeedDisplay.Text = "SPEED: 50"; FlySpeedDisplay.TextColor3 = tWhite; FlySpeedDisplay.Font = Enum.Font.GothamSemibold; FlySpeedDisplay.TextSize = 12; Instance.new("UICorner", FlySpeedDisplay); Instance.new("UIStroke", FlySpeedDisplay).Color = Color3.fromRGB(50, 50, 50)
local FlySpeedPlus = Instance.new("TextButton", FlyMain); FlySpeedPlus.Size = UDim2.new(0, 40, 0, 30); FlySpeedPlus.Position = UDim2.new(1, -50, 0, 95); FlySpeedPlus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FlySpeedPlus.Text = "+"; FlySpeedPlus.TextColor3 = tWhite; FlySpeedPlus.Font = Enum.Font.GothamBold; Instance.new("UICorner", FlySpeedPlus)

MakeDraggable(FlyTopBar, FlyMain)

local flyMinimized = false
FlyMinBtn.MouseButton1Click:Connect(function()
    flyMinimized = not flyMinimized
    TweenService:Create(FlyMain, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = flyMinimized and UDim2.new(0, 250, 0, 35) or UDim2.new(0, 250, 0, 135)}):Play()
    FlyMinBtn.Text = flyMinimized and "+" or "—"
    FlyFix.Visible = not flyMinimized
end)

local isFlying = false; local flySpeed = 50; local flyKeybind = nil; local isFlyBinding = false; local flyLoop = nil; local currentFlyAnim = nil

FlySpeedMinus.MouseButton1Click:Connect(function() flySpeed = math.max(10, flySpeed - 10); FlySpeedDisplay.Text = "SPEED: " .. flySpeed end)
FlySpeedPlus.MouseButton1Click:Connect(function() flySpeed = flySpeed + 10; FlySpeedDisplay.Text = "SPEED: " .. flySpeed end)

local function PlayFlyAnim(id)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    
    if not animator then return end
    if char:FindFirstChild("Animate") then char.Animate.Disabled = true end
    if currentFlyAnim then currentFlyAnim:Stop(0.2) end
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:Stop() end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. id
    currentFlyAnim = animator:LoadAnimation(anim)
    currentFlyAnim.Priority = Enum.AnimationPriority.Action
    currentFlyAnim:Play()
end

local function StopFlyAnim()
    if currentFlyAnim then currentFlyAnim:Stop(); currentFlyAnim = nil end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Animate") then char.Animate.Disabled = false end
end

local lastFlyDirection = "none"

local function ToggleFly()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if not hrp or not hum then return end

    isFlying = not isFlying
    if isFlying then
        FlyToggleBtn.BackgroundColor3 = tCyan
        FlyToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
        FlyToggleBtn.Text = "VUELO: ON"

        hum:ChangeState(Enum.HumanoidStateType.Physics)
        hum.PlatformStand = true
        
        local bg = Instance.new("BodyGyro", hrp)
        bg.Name = "AK_FlyGyro"
        bg.P = 90000
        bg.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = hrp.CFrame
        
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name = "AK_FlyVel"
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

        lastFlyDirection = "idle"
        PlayFlyAnim("619542203")

        local camera = Workspace.CurrentCamera
        local ctrl = {f = 0, b = 0, l = 0, r = 0}

        flyLoop = RunService.RenderStepped:Connect(function()
            if not isFlying or not char or not hrp then return end
            
            ctrl.f = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
            ctrl.b = UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or 0
            ctrl.l = UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0
            ctrl.r = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
            local up = UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0
            local down = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and -1 or 0

            local moveDir = Vector3.new(ctrl.l + ctrl.r, up + down, ctrl.f + ctrl.b)

            if moveDir.Magnitude > 0 then
                bv.Velocity = ((camera.CFrame.LookVector * moveDir.Z) + (camera.CFrame.RightVector * moveDir.X) + (camera.CFrame.UpVector * moveDir.Y)) * flySpeed
                bg.CFrame = CFrame.new(hrp.Position, hrp.Position + bv.Velocity) * CFrame.Angles(math.rad(-50), 0, 0)
                
                if lastFlyDirection ~= "moving" then
                    lastFlyDirection = "moving"
                    PlayFlyAnim("137759282507703")
                end
            else
                bv.Velocity = Vector3.new(0, 0, 0)
                bg.CFrame = camera.CFrame * CFrame.Angles(0, 0, 0)
                
                if lastFlyDirection ~= "idle" then
                    lastFlyDirection = "idle"
                    PlayFlyAnim("619542203")
                end
            end
        end)
    else
        FlyToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        FlyToggleBtn.TextColor3 = tWhite
        FlyToggleBtn.Text = "VUELO: OFF"
        
        if flyLoop then flyLoop:Disconnect() flyLoop = nil end
        if hrp:FindFirstChild("AK_FlyGyro") then hrp.AK_FlyGyro:Destroy() end
        if hrp:FindFirstChild("AK_FlyVel") then hrp.AK_FlyVel:Destroy() end
        
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        StopFlyAnim()
    end
end
FlyToggleBtn.MouseButton1Click:Connect(ToggleFly)

FlyKeyBtn.MouseButton1Click:Connect(function()
    if flyKeybind ~= nil then flyKeybind = nil; FlyKeyBtn.Text = "KEY"; FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isFlyBinding = false
    else isFlyBinding = true; FlyKeyBtn.Text = "..."; FlyKeyBtn.BackgroundColor3 = tOrange end
end)

FlyCloseBtn.MouseButton1Click:Connect(function() 
    if isFlying then ToggleFly() end
    flyKeybind = nil; FlyKeyBtn.Text = "KEY"; FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isFlyBinding = false
    FlyMain.Visible = false 
end)

-- ==================================================================
-- 5. CHAT GLOBAL V2 (NGROK CONECTADO)
-- ==================================================================
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local setclipboard = setclipboard or toclipboard or set_clipboard or (Synapse and Synapse.set_clipboard)

local ChatMain = Instance.new("Frame", ScreenGui)
ChatMain.Size = UDim2.new(0, 380, 0, 260); ChatMain.Position = UDim2.new(0.05, 0, 0.6, 0); ChatMain.BackgroundColor3 = Color3.fromRGB(20, 20, 25); ChatMain.BorderSizePixel = 0; ChatMain.ClipsDescendants = true; ChatMain.Visible = false
Instance.new("UICorner", ChatMain).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", ChatMain).Color = tPurple

local ChatTopBar = Instance.new("Frame", ChatMain); ChatTopBar.Size = UDim2.new(1, 0, 0, 35); ChatTopBar.BackgroundColor3 = Color3.fromRGB(30, 25, 45); ChatTopBar.BorderSizePixel = 0; Instance.new("UICorner", ChatTopBar).CornerRadius = UDim.new(0, 6)
local ChatFix = Instance.new("Frame", ChatTopBar); ChatFix.Size = UDim2.new(1, 0, 0, 5); ChatFix.Position = UDim2.new(0, 0, 1, -5); ChatFix.BackgroundColor3 = Color3.fromRGB(30, 25, 45); ChatFix.BorderSizePixel = 0
local ChatTitle = Instance.new("TextLabel", ChatTopBar); ChatTitle.Size = UDim2.new(1, -70, 1, 0); ChatTitle.Position = UDim2.new(0, 15, 0, 0); ChatTitle.BackgroundTransparency = 1; ChatTitle.Text = "GLOBAL CHAT V2"; ChatTitle.TextColor3 = tWhite; ChatTitle.Font = Enum.Font.GothamBold; ChatTitle.TextSize = 12; ChatTitle.TextXAlignment = Enum.TextXAlignment.Left
local ChatMinBtn = Instance.new("TextButton", ChatTopBar); ChatMinBtn.Size = UDim2.new(0, 35, 1, 0); ChatMinBtn.Position = UDim2.new(1, -70, 0, 0); ChatMinBtn.BackgroundTransparency = 1; ChatMinBtn.Text = "—"; ChatMinBtn.TextColor3 = tGreen; ChatMinBtn.Font = Enum.Font.GothamBlack; ChatMinBtn.TextSize = 14
local ChatCloseBtn = Instance.new("TextButton", ChatTopBar); ChatCloseBtn.Size = UDim2.new(0, 35, 1, 0); ChatCloseBtn.Position = UDim2.new(1, -35, 0, 0); ChatCloseBtn.BackgroundTransparency = 1; ChatCloseBtn.Text = "X"; ChatCloseBtn.TextColor3 = tRed; ChatCloseBtn.Font = Enum.Font.GothamBlack; ChatCloseBtn.TextSize = 12

local ChatScroll = Instance.new("ScrollingFrame", ChatMain); ChatScroll.Position = UDim2.new(0, 5, 0, 40); ChatScroll.Size = UDim2.new(1, -10, 0, 175); ChatScroll.BackgroundTransparency = 1; ChatScroll.ScrollBarThickness = 4; ChatScroll.ScrollBarImageColor3 = tPurple
local ChatLayout = Instance.new("UIListLayout", ChatScroll); ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder; ChatLayout.Padding = UDim.new(0, 4)

local ChatBox = Instance.new("TextBox", ChatMain); ChatBox.Position = UDim2.new(0, 5, 0, 220); ChatBox.Size = UDim2.new(0.65, 0, 0, 30); ChatBox.BackgroundColor3 = Color3.fromRGB(10, 10, 15); ChatBox.TextColor3 = tWhite; ChatBox.PlaceholderText = "Escribe un mensaje..."; ChatBox.Font = Enum.Font.Gotham; ChatBox.TextSize = 12; ChatBox.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", ChatBox).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", ChatBox).Color = Color3.fromRGB(40, 40, 60); Instance.new("UIPadding", ChatBox).PaddingLeft = UDim.new(0, 10)
local ChatSendBtn = Instance.new("TextButton", ChatMain); ChatSendBtn.Position = UDim2.new(0.68, 0, 0, 220); ChatSendBtn.Size = UDim2.new(0.30, 0, 0, 30); ChatSendBtn.BackgroundColor3 = tPurple; ChatSendBtn.TextColor3 = tWhite; ChatSendBtn.Text = "ENVIAR"; ChatSendBtn.Font = Enum.Font.GothamBold; ChatSendBtn.TextSize = 11; Instance.new("UICorner", ChatSendBtn).CornerRadius = UDim.new(0, 4)

MakeDraggable(ChatTopBar, ChatMain)

local chatMinimized = false
ChatMinBtn.MouseButton1Click:Connect(function()
    chatMinimized = not chatMinimized
    TweenService:Create(ChatMain, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = chatMinimized and UDim2.new(0, 380, 0, 35) or UDim2.new(0, 380, 0, 260)}):Play()
    ChatMinBtn.Text = chatMinimized and "+" or "—"
    ChatFix.Visible = not chatMinimized
end)
ChatCloseBtn.MouseButton1Click:Connect(function() ChatMain.Visible = false end)

local function CrearFilaMensaje(usuario, mensaje)
    local Fila = Instance.new("Frame", ChatScroll); Fila.Size = UDim2.new(1, 0, 0, 25); Fila.BackgroundTransparency = 1
    local Texto = Instance.new("TextLabel", Fila); Texto.Size = UDim2.new(0.8, 0, 1, 0); Texto.Position = UDim2.new(0, 5, 0, 0); Texto.BackgroundTransparency = 1; Texto.TextColor3 = tWhite; Texto.TextXAlignment = Enum.TextXAlignment.Left; Texto.TextTruncate = Enum.TextTruncate.AtEnd; Texto.Text = "["..usuario.."]: " .. mensaje; Texto.Font = Enum.Font.Gotham; Texto.TextSize = 12
    if string.find(mensaje, "http") then Texto.TextColor3 = tCyan end
    
    local BtnCopia = Instance.new("TextButton", Fila); BtnCopia.Size = UDim2.new(0.18, 0, 0.8, 0); BtnCopia.Position = UDim2.new(0.8, 0, 0.1, 0); BtnCopia.BackgroundColor3 = Color3.fromRGB(40, 40, 50); BtnCopia.TextColor3 = tYellow; BtnCopia.Text = "COPIAR"; BtnCopia.Font = Enum.Font.GothamBold; BtnCopia.TextSize = 9; Instance.new("UICorner", BtnCopia).CornerRadius = UDim.new(0, 4)
    BtnCopia.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(mensaje); BtnCopia.Text = "¡LISTO!"; BtnCopia.TextColor3 = tGreen
            task.wait(1); BtnCopia.Text = "COPIAR"; BtnCopia.TextColor3 = tYellow
        else BtnCopia.Text = "ERROR"; BtnCopia.TextColor3 = tRed end
    end)
end

local function ActualizarChat()
    if not request then return end
    local success, response = pcall(function() return request({Url = URL_NGROK .. "/leer", Method = "GET", Headers = {["ngrok-skip-browser-warning"] = "true"}}) end)
    if success and response.StatusCode == 200 then
        local msgs = HttpService:JSONDecode(response.Body)
        for _, v in pairs(ChatScroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
        for _, m in pairs(msgs) do CrearFilaMensaje(m.u, m.m) end
        ChatScroll.CanvasSize = UDim2.new(0, 0, 0, ChatLayout.AbsoluteContentSize.Y)
    end
end

ChatSendBtn.MouseButton1Click:Connect(function()
    if ChatBox.Text == "" or not request then return end
    local txt = ChatBox.Text; ChatBox.Text = "Enviando..."
    local payload = HttpService:JSONEncode({usuario = LocalPlayer.Name, texto = txt})
    pcall(function() request({Url = URL_NGROK .. "/enviar", Method = "POST", Headers = {["Content-Type"] = "application/json", ["ngrok-skip-browser-warning"] = "true"}, Body = payload}) end)
    ChatBox.Text = ""; task.wait(0.2); ActualizarChat()
end)

task.spawn(function()
    while task.wait(3) do if ChatMain.Visible then ActualizarChat() end end
end)

-- ==================================================================
-- 6. SISTEMA GLOBAL DE TECLAS Y COMANDOS (CON AUTOCOMPLETADO)
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
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextWrapped = true
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

AddCmd("tpmenu", "Abre la lista de TP visual", function()
    TPSearchBox.Text = ""; RefreshTPMenu(); TPMain.Visible = true; LogMessage("TP Menu abierto.", tOrange)
end)

AddCmd("invisible", "Abre el panel de Invisibilidad", function()
    InvMain.Visible = true; LogMessage("Menú Invisible abierto.", tPurple)
end)

AddCmd("fly", "Abre el panel de Vuelo", function()
    FlyMain.Visible = true; LogMessage("Menú de Vuelo abierto.", tYellow)
end)

AddCmd("globalchat", "Abre el chat global", function()
    ChatMain.Visible = true; ActualizarChat(); LogMessage("Chat Global conectado.", tGreen)
end)

AddCmd("speed", "Cambia la velocidad", function(args)
    if args[1] and tonumber(args[1]) then
        LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(args[1])
        LogMessage("Velocidad -> " .. args[1], tGreen)
    end
end)

AddCmd("destroy", "Cierra y elimina el panel completo de forma segura", function()
    if isGhostActive then ToggleGhost() end
    if isFlying then ToggleFly() end
    LogMessage("Cerrando C.D.T Optifine...", tPurple)
    task.wait(0.5)
    ScreenGui:Destroy()
end)

-- LOGICA AUTOCOMPLETADO ESTILO MINECRAFT
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
            btn.Size = UDim2.new(1, -5, 0, 22); btn.BackgroundTransparency = 1; btn.Text = "  " .. sug.Display; btn.TextColor3 = tWhite; btn.Font = Enum.Font.Gotham; btn.TextSize = 11; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.ZIndex = 11
            btn:SetAttribute("Fill", sug.Fill)
            
            btn.MouseEnter:Connect(function() btn.TextColor3 = tPurple end) 
            btn.MouseLeave:Connect(function() btn.TextColor3 = tWhite end)
            btn.MouseButton1Click:Connect(function()
                CmdBox.Text = sug.Fill; CmdBox:CaptureFocus(); SuggestFrame.Visible = false
            end)
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
                if fill then
                    task.defer(function() CmdBox.Text = fill; CmdBox:CaptureFocus(); CmdBox.CursorPosition = #fill + 1 end)
                    SuggestFrame.Visible = false
                    break
                end
            end
        end
    end
end)

CmdBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and CmdBox.Text ~= "" then
        local input = string.lower(CmdBox.Text); CmdBox.Text = ""; SuggestFrame.Visible = false
        LogMessage("> " .. input, tWhite)
        local split = string.split(input, " "); local cmd = split[1]; table.remove(split, 1)

        if Comandos[cmd] then pcall(function() Comandos[cmd].Accion(split) end)
        else LogMessage("Error: Comando desconocido.", tOrange) end
    end
end)
