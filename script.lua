--[[
    C.D.T OPTIFINE - V9.1 MANUAL TRIP EDITION
    - Trip Mode (NUEVO: Un solo toque para caer, te quedas tirado hasta saltar con ESPACIO).
    - Inyección Segura (Bulletproof) y Responsive UI.
    - TP Menu (Buscador dinámico).
    - Map Points (Comando 'mp', Guarda lugares por juego).
    - Menú Invisible (GHOST MODE PERFECTO + KEYBIND).
    - Menú de Vuelo (Noclip Fly).
    - VEHICLE FLY (Lerp Suave).
    - GLOBAL CHAT SMART (Auto-Scroll).
    - Consola Inteligente.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Esperar al jugador de forma segura
repeat task.wait() until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer

-- ==================================================================
-- COLORES GLOBALES
-- ==================================================================
local tPurple = Color3.fromRGB(170, 85, 255)
local tWhite = Color3.fromRGB(255, 255, 255)
local tGreen = Color3.fromRGB(0, 255, 136)
local tOrange = Color3.fromRGB(255, 150, 0)
local tCyan = Color3.fromRGB(0, 200, 255)
local tYellow = Color3.fromRGB(255, 220, 0)
local tRed = Color3.fromRGB(255, 60, 60)
local borderDark = Color3.fromRGB(45, 45, 45)

local URL_NGROK = "https://garnett-waterborne-overoffensively.ngrok-free.dev" 

local function ApplyResponsiveScale(frame)
    local scaleObj = Instance.new("UIScale", frame)
    local function UpdateScale()
        local vs = Workspace.CurrentCamera.ViewportSize
        if vs.X < 850 then scaleObj.Scale = 1.15 else scaleObj.Scale = 1.05 end
    end
    Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
    UpdateScale()
end

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

-- ==================================================================
-- 0. SISTEMA DE INYECCIÓN A PRUEBA DE BALAS
-- ==================================================================
local targetGuiParent = nil
pcall(function() targetGuiParent = gethui() end)
if not targetGuiParent then pcall(function() targetGuiParent = CoreGui end) end
if not targetGuiParent then targetGuiParent = LocalPlayer:WaitForChild("PlayerGui") end

if targetGuiParent:FindFirstChild("CDT_Optifine_Fluid") then
    targetGuiParent:FindFirstChild("CDT_Optifine_Fluid"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CDT_Optifine_Fluid"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false 
ScreenGui.Parent = targetGuiParent

-- ==================================================================
-- 1. CONSOLA PRINCIPAL
-- ==================================================================
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 320, 0, 350); Main.Position = UDim2.new(1, -340, 0, 20); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.BorderSizePixel = 0; Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", Main).Color = borderDark
ApplyResponsiveScale(Main)

local FullUI = Instance.new("Frame", Main); FullUI.Size = UDim2.new(1, 0, 1, 0); FullUI.BackgroundTransparency = 1; FullUI.BorderSizePixel = 0
local TopBar = Instance.new("Frame", FullUI); TopBar.Size = UDim2.new(1, 0, 0, 35); TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TopBar.BorderSizePixel = 0; Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)
local Fix = Instance.new("Frame", TopBar); Fix.Size = UDim2.new(1, 0, 0, 5); Fix.Position = UDim2.new(0, 0, 1, -5); Fix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); Fix.BorderSizePixel = 0
local Title = Instance.new("TextLabel", TopBar); Title.Size = UDim2.new(1, -60, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0); Title.BackgroundTransparency = 1; Title.Text = "C.D.T OPTIFINE // SYSTEM"; Title.TextColor3 = tWhite; Title.Font = Enum.Font.GothamBold; Title.TextSize = 12; Title.TextXAlignment = Enum.TextXAlignment.Left
local MinBtn = Instance.new("TextButton", TopBar); MinBtn.Size = UDim2.new(0, 35, 1, 0); MinBtn.Position = UDim2.new(1, -35, 0, 0); MinBtn.BackgroundTransparency = 1; MinBtn.Text = "—"; MinBtn.TextColor3 = tGreen; MinBtn.Font = Enum.Font.GothamBlack; MinBtn.TextSize = 14

local Console = Instance.new("ScrollingFrame", FullUI)
Console.Size = UDim2.new(1, -20, 1, -95); Console.Position = UDim2.new(0, 10, 0, 40); Console.BackgroundTransparency = 1; Console.BorderSizePixel = 0; Console.ScrollBarThickness = 2; Console.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
local UIList = Instance.new("UIListLayout", Console); UIList.Padding = UDim.new(0, 4); UIList.SortOrder = Enum.SortOrder.LayoutOrder

local CmdBox = Instance.new("TextBox", FullUI)
CmdBox.Size = UDim2.new(1, -20, 0, 35); CmdBox.Position = UDim2.new(0, 10, 1, -45); CmdBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10); CmdBox.TextColor3 = tWhite; CmdBox.Text = ""; CmdBox.PlaceholderText = "> Escribe un comando aquí..."; CmdBox.Font = Enum.Font.Gotham; CmdBox.TextSize = 13; CmdBox.TextXAlignment = Enum.TextXAlignment.Left; CmdBox.ClearTextOnFocus = false; Instance.new("UICorner", CmdBox).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", CmdBox).Color = Color3.fromRGB(40, 40, 40); Instance.new("UIPadding", CmdBox).PaddingLeft = UDim.new(0, 10)

local MiniUI = Instance.new("Frame", Main); MiniUI.Size = UDim2.new(1, 0, 1, 0); MiniUI.BackgroundTransparency = 1; MiniUI.BorderSizePixel = 0; MiniUI.Visible = false
local MiniLabel = Instance.new("TextLabel", MiniUI); MiniLabel.Size = UDim2.new(1, -40, 1, 0); MiniLabel.Position = UDim2.new(0, 15, 0, 0); MiniLabel.BackgroundTransparency = 1; MiniLabel.Text = "C.D.T TERMINAL"; MiniLabel.TextColor3 = tWhite; MiniLabel.Font = Enum.Font.GothamBold; MiniLabel.TextSize = 12; MiniLabel.TextXAlignment = Enum.TextXAlignment.Left
local Dot = Instance.new("Frame", MiniUI); Dot.Size = UDim2.new(0, 6, 0, 6); Dot.Position = UDim2.new(0, 140, 0.5, -3); Dot.BackgroundColor3 = tGreen; Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
local MaxBtn = Instance.new("TextButton", MiniUI); MaxBtn.Size = UDim2.new(0, 35, 1, 0); MaxBtn.Position = UDim2.new(1, -35, 0, 0); MaxBtn.BackgroundTransparency = 1; MaxBtn.Text = "⤢"; MaxBtn.TextColor3 = tGreen; MaxBtn.Font = Enum.Font.GothamBlack; MaxBtn.TextSize = 18

MakeDraggable(TopBar, Main); MakeDraggable(MiniLabel, Main)

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = true; FullUI.Visible = false; MiniUI.Visible = true
    Main:TweenSize(UDim2.new(0, 190, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
end)
MaxBtn.MouseButton1Click:Connect(function()
    isMinimized = false; MiniUI.Visible = false; FullUI.Visible = true
    Main:TweenSize(UDim2.new(0, 320, 0, 350), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
end)

-- ==================================================================
-- 2. MAP POINTS (WAYPOINTS MANAGER)
-- ==================================================================
local fileName = "CDT_Waypoints_" .. tostring(game.PlaceId) .. ".json"
local waypoints = {}

local function SaveWaypoints() if writefile then pcall(function() writefile(fileName, HttpService:JSONEncode(waypoints)) end) end end
local function LoadWaypoints()
    if readfile and isfile and isfile(fileName) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(fileName)) end)
        if success and type(decoded) == "table" then waypoints = decoded end
    end
end
LoadWaypoints()

LocalPlayer.Chatted:Connect(function(msg)
    if string.sub(msg, 1, 1) == "!" then
        local cmd = string.sub(msg, 2)
        for wpName, coords in pairs(waypoints) do
            if string.lower(wpName) == string.lower(cmd) then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = CFrame.new(coords.X, coords.Y, coords.Z) end
                break
            end
        end
    end
end)

local MPMain = Instance.new("Frame", ScreenGui); MPMain.Size = UDim2.new(0, 260, 0, 350); MPMain.Position = UDim2.new(0.5, 150, 0.5, -175); MPMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); MPMain.BorderSizePixel = 0; MPMain.ClipsDescendants = true; MPMain.Visible = false; Instance.new("UICorner", MPMain).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", MPMain).Color = borderDark
local MPTopBar = Instance.new("Frame", MPMain); MPTopBar.Size = UDim2.new(1, 0, 0, 35); MPTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); MPTopBar.BorderSizePixel = 0; Instance.new("UICorner", MPTopBar).CornerRadius = UDim.new(0, 6)
local MPFix = Instance.new("Frame", MPTopBar); MPFix.Size = UDim2.new(1, 0, 0, 5); MPFix.Position = UDim2.new(0, 0, 1, -5); MPFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); MPFix.BorderSizePixel = 0

local MPTitle = Instance.new("TextLabel", MPTopBar); MPTitle.Size = UDim2.new(1, -70, 1, 0); MPTitle.Position = UDim2.new(0, 15, 0, 0); MPTitle.BackgroundTransparency = 1; MPTitle.Text = "MAP: ID " .. tostring(game.PlaceId); MPTitle.TextColor3 = tWhite; MPTitle.Font = Enum.Font.GothamBold; MPTitle.TextSize = 13; MPTitle.TextXAlignment = Enum.TextXAlignment.Left
task.spawn(function() pcall(function() local info = MarketplaceService:GetProductInfo(game.PlaceId); if info and info.Name then MPTitle.Text = "MAP: " .. string.sub(info.Name, 1, 20) end end) end)

local MPMinBtn = Instance.new("TextButton", MPTopBar); MPMinBtn.Size = UDim2.new(0, 35, 1, 0); MPMinBtn.Position = UDim2.new(1, -70, 0, 0); MPMinBtn.BackgroundTransparency = 1; MPMinBtn.Text = "—"; MPMinBtn.TextColor3 = tGreen; MPMinBtn.Font = Enum.Font.GothamBlack; MPMinBtn.TextSize = 14
local MPCloseBtn = Instance.new("TextButton", MPTopBar); MPCloseBtn.Size = UDim2.new(0, 35, 1, 0); MPCloseBtn.Position = UDim2.new(1, -35, 0, 0); MPCloseBtn.BackgroundTransparency = 1; MPCloseBtn.Text = "X"; MPCloseBtn.TextColor3 = tRed; MPCloseBtn.Font = Enum.Font.GothamBlack; MPCloseBtn.TextSize = 12

local MPInput = Instance.new("TextBox", MPMain); MPInput.Size = UDim2.new(1, -85, 0, 30); MPInput.Position = UDim2.new(0, 5, 0, 40); MPInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MPInput.TextColor3 = tWhite; MPInput.Text = ""; MPInput.PlaceholderText = "Nombre del lugar..."; MPInput.Font = Enum.Font.Gotham; MPInput.TextSize = 12; MPInput.ClearTextOnFocus = false; Instance.new("UICorner", MPInput).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", MPInput).Color = Color3.fromRGB(50, 50, 50); Instance.new("UIPadding", MPInput).PaddingLeft = UDim.new(0, 5)
local MPSaveBtn = Instance.new("TextButton", MPMain); MPSaveBtn.Size = UDim2.new(0, 70, 0, 30); MPSaveBtn.Position = UDim2.new(1, -75, 0, 40); MPSaveBtn.BackgroundColor3 = tPurple; MPSaveBtn.TextColor3 = tWhite; MPSaveBtn.Text = "ADD"; MPSaveBtn.Font = Enum.Font.GothamBold; MPSaveBtn.TextSize = 12; Instance.new("UICorner", MPSaveBtn).CornerRadius = UDim.new(0, 4)
local MPScroll = Instance.new("ScrollingFrame", MPMain); MPScroll.Size = UDim2.new(1, -10, 1, -85); MPScroll.Position = UDim2.new(0, 5, 0, 80); MPScroll.BackgroundTransparency = 1; MPScroll.BorderSizePixel = 0; MPScroll.ScrollBarThickness = 2; MPScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
local MPListLayout = Instance.new("UIListLayout", MPScroll); MPListLayout.Padding = UDim.new(0, 5)

local ConfirmPopup = Instance.new("Frame", MPMain); ConfirmPopup.Size = UDim2.new(1, 0, 1, 0); ConfirmPopup.BackgroundColor3 = Color3.fromRGB(15, 15, 20); ConfirmPopup.BackgroundTransparency = 0.2; ConfirmPopup.Visible = false; ConfirmPopup.ZIndex = 10
local ConfirmMsg = Instance.new("TextLabel", ConfirmPopup); ConfirmMsg.Size = UDim2.new(1, -20, 0, 60); ConfirmMsg.Position = UDim2.new(0, 10, 0.5, -60); ConfirmMsg.BackgroundTransparency = 1; ConfirmMsg.TextColor3 = tWhite; ConfirmMsg.Text = "¿Estás seguro?"; ConfirmMsg.Font = Enum.Font.GothamBold; ConfirmMsg.TextSize = 13; ConfirmMsg.TextWrapped = true; ConfirmMsg.ZIndex = 11
local YesBtn = Instance.new("TextButton", ConfirmPopup); YesBtn.Size = UDim2.new(0, 100, 0, 35); YesBtn.Position = UDim2.new(0.5, -110, 0.5, 10); YesBtn.BackgroundColor3 = tGreen; YesBtn.TextColor3 = Color3.fromRGB(10, 10, 10); YesBtn.Text = "SÍ"; YesBtn.Font = Enum.Font.GothamBold; YesBtn.TextSize = 13; YesBtn.ZIndex = 11; Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 4)
local NoBtn = Instance.new("TextButton", ConfirmPopup); NoBtn.Size = UDim2.new(0, 100, 0, 35); NoBtn.Position = UDim2.new(0.5, 10, 0.5, 10); NoBtn.BackgroundColor3 = tRed; NoBtn.TextColor3 = tWhite; NoBtn.Text = "NO"; NoBtn.Font = Enum.Font.GothamBold; NoBtn.TextSize = 13; NoBtn.ZIndex = 11; Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 4)

local accionPendiente = ""; local waypointPendiente = ""
NoBtn.MouseButton1Click:Connect(function() ConfirmPopup.Visible = false; accionPendiente = ""; waypointPendiente = "" end)

ApplyResponsiveScale(MPMain); MakeDraggable(MPTopBar, MPMain)

local mpMinimized = false
MPMinBtn.MouseButton1Click:Connect(function()
    mpMinimized = not mpMinimized; MPMain:TweenSize(mpMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 350), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true); MPMinBtn.Text = mpMinimized and "+" or "—"; MPFix.Visible = not mpMinimized
end)
MPCloseBtn.MouseButton1Click:Connect(function() MPMain.Visible = false end)

local function RefreshMPList()
    for _, child in pairs(MPScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    for wpName, coords in pairs(waypoints) do
        local Item = Instance.new("Frame", MPScroll); Item.Size = UDim2.new(1, -5, 0, 30); Item.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 4)
        local NameBox = Instance.new("TextBox", Item); NameBox.Size = UDim2.new(0, 120, 1, 0); NameBox.Position = UDim2.new(0, 5, 0, 0); NameBox.BackgroundTransparency = 1; NameBox.TextColor3 = tWhite; NameBox.Text = wpName; NameBox.TextXAlignment = Enum.TextXAlignment.Left; NameBox.Font = Enum.Font.Gotham; NameBox.TextSize = 12; NameBox.ClearTextOnFocus = false
        local TpBtn = Instance.new("TextButton", Item); TpBtn.Size = UDim2.new(0, 35, 0, 22); TpBtn.Position = UDim2.new(1, -85, 0.5, -11); TpBtn.BackgroundColor3 = tCyan; TpBtn.TextColor3 = Color3.fromRGB(10,10,10); TpBtn.Text = "TP"; TpBtn.Font = Enum.Font.GothamBold; TpBtn.TextSize = 11; Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 4)
        local UpdBtn = Instance.new("TextButton", Item); UpdBtn.Size = UDim2.new(0, 22, 0, 22); UpdBtn.Position = UDim2.new(1, -45, 0.5, -11); UpdBtn.BackgroundColor3 = tOrange; UpdBtn.TextColor3 = tWhite; UpdBtn.Text = "↺"; UpdBtn.Font = Enum.Font.GothamBold; UpdBtn.TextSize = 14; Instance.new("UICorner", UpdBtn).CornerRadius = UDim.new(0, 4)
        local DelBtn = Instance.new("TextButton", Item); DelBtn.Size = UDim2.new(0, 18, 0, 22); DelBtn.Position = UDim2.new(1, -20, 0.5, -11); DelBtn.BackgroundColor3 = tRed; DelBtn.TextColor3 = tWhite; DelBtn.Text = "X"; DelBtn.Font = Enum.Font.GothamBold; DelBtn.TextSize = 11; Instance.new("UICorner", DelBtn).CornerRadius = UDim.new(0, 4)

        NameBox.FocusLost:Connect(function()
            local newName = NameBox.Text
            if newName ~= "" and newName ~= wpName and not waypoints[newName] then
                waypoints[newName] = waypoints[wpName]; waypoints[wpName] = nil; SaveWaypoints(); RefreshMPList()
            else NameBox.Text = wpName end
        end)
        TpBtn.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character; if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = CFrame.new(coords.X, coords.Y, coords.Z) end
        end)
        
        UpdBtn.MouseButton1Click:Connect(function()
            accionPendiente = "actualizar"; waypointPendiente = wpName
            ConfirmMsg.Text = "¿ACTUALIZAR '" .. wpName .. "' a tu posición actual?"
            ConfirmPopup.Visible = true
        end)
        DelBtn.MouseButton1Click:Connect(function()
            accionPendiente = "eliminar"; waypointPendiente = wpName
            ConfirmMsg.Text = "¿ELIMINAR el punto '" .. wpName .. "'?"
            ConfirmPopup.Visible = true
        end)
    end
    MPScroll.CanvasSize = UDim2.new(0, 0, 0, MPListLayout.AbsoluteContentSize.Y + 5)
end

YesBtn.MouseButton1Click:Connect(function()
    if accionPendiente == "eliminar" then
        waypoints[waypointPendiente] = nil
    elseif accionPendiente == "actualizar" then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            waypoints[waypointPendiente] = {X = pos.X, Y = pos.Y, Z = pos.Z}
        end
    end
    SaveWaypoints(); RefreshMPList(); ConfirmPopup.Visible = false
end)

MPSaveBtn.MouseButton1Click:Connect(function()
    local name = MPInput.Text; if name == "" then name = "Punto " .. tostring(#MPScroll:GetChildren()) end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local p = char.HumanoidRootPart.Position; waypoints[name] = {X=p.X, Y=p.Y, Z=p.Z}
        SaveWaypoints(); MPInput.Text = ""; MPSaveBtn.Text = "✓"; task.wait(1); MPSaveBtn.Text = "ADD"; RefreshMPList()
    end
end)

-- ==================================================================
-- 3. INTERFAZ TP MENU (JUGADORES)
-- ==================================================================
local TPMain = Instance.new("Frame", ScreenGui); TPMain.Size = UDim2.new(0, 260, 0, 380); TPMain.Position = UDim2.new(0.5, -130, 0.5, -190); TPMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); TPMain.BorderSizePixel = 0; TPMain.ClipsDescendants = true; TPMain.Visible = false; Instance.new("UICorner", TPMain).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", TPMain).Color = borderDark
local TPTopBar = Instance.new("Frame", TPMain); TPTopBar.Size = UDim2.new(1, 0, 0, 35); TPTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TPTopBar.BorderSizePixel = 0; Instance.new("UICorner", TPTopBar).CornerRadius = UDim.new(0, 6)
local TPFix = Instance.new("Frame", TPTopBar); TPFix.Size = UDim2.new(1, 0, 0, 5); TPFix.Position = UDim2.new(0, 0, 1, -5); TPFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TPFix.BorderSizePixel = 0
local TPTitle = Instance.new("TextLabel", TPTopBar); TPTitle.Size = UDim2.new(1, -70, 1, 0); TPTitle.Position = UDim2.new(0, 15, 0, 0); TPTitle.BackgroundTransparency = 1; TPTitle.Text = "TP PLAYERS"; TPTitle.TextColor3 = tWhite; TPTitle.Font = Enum.Font.GothamBold; TPTitle.TextSize = 13; TPTitle.TextXAlignment = Enum.TextXAlignment.Left
local TPMinBtn = Instance.new("TextButton", TPTopBar); TPMinBtn.Size = UDim2.new(0, 35, 1, 0); TPMinBtn.Position = UDim2.new(1, -70, 0, 0); TPMinBtn.BackgroundTransparency = 1; TPMinBtn.Text = "—"; TPMinBtn.TextColor3 = tYellow; TPMinBtn.Font = Enum.Font.GothamBlack; TPMinBtn.TextSize = 14
local TPCloseBtn = Instance.new("TextButton", TPTopBar); TPCloseBtn.Size = UDim2.new(0, 35, 1, 0); TPCloseBtn.Position = UDim2.new(1, -35, 0, 0); TPCloseBtn.BackgroundTransparency = 1; TPCloseBtn.Text = "X"; TPCloseBtn.TextColor3 = tRed; TPCloseBtn.Font = Enum.Font.GothamBlack; TPCloseBtn.TextSize = 12
local TPSearchBox = Instance.new("TextBox", TPMain); TPSearchBox.Size = UDim2.new(1, -10, 0, 35); TPSearchBox.Position = UDim2.new(0, 5, 0, 40); TPSearchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TPSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255); TPSearchBox.Text = ""; TPSearchBox.PlaceholderText = "🔍 Buscar jugador..."; TPSearchBox.Font = Enum.Font.Gotham; TPSearchBox.TextSize = 13; TPSearchBox.ClearTextOnFocus = false; Instance.new("UICorner", TPSearchBox).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", TPSearchBox).Color = Color3.fromRGB(50, 50, 50)
local TPScroll = Instance.new("ScrollingFrame", TPMain); TPScroll.Size = UDim2.new(1, -10, 1, -85); TPScroll.Position = UDim2.new(0, 5, 0, 80); TPScroll.BackgroundTransparency = 1; TPScroll.BorderSizePixel = 0; TPScroll.ScrollBarThickness = 2; TPScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
local TPListLayout = Instance.new("UIListLayout", TPScroll); TPListLayout.Padding = UDim.new(0, 5)

ApplyResponsiveScale(TPMain); MakeDraggable(TPTopBar, TPMain)

local tpMinimized = false
TPMinBtn.MouseButton1Click:Connect(function()
    tpMinimized = not tpMinimized; TPMain:TweenSize(tpMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 380), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    TPMinBtn.Text = tpMinimized and "+" or "—"; TPFix.Visible = not tpMinimized
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
                task.spawn(function() pcall(function() Avatar.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end) end)
                local NameLbl = Instance.new("TextLabel", Card); NameLbl.Size = UDim2.new(1, -100, 1, 0); NameLbl.Position = UDim2.new(0, 45, 0, 0); NameLbl.BackgroundTransparency = 1; NameLbl.Text = plr.DisplayName; NameLbl.TextColor3 = tWhite; NameLbl.Font = Enum.Font.GothamMedium; NameLbl.TextSize = 13; NameLbl.TextXAlignment = Enum.TextXAlignment.Left
                local TpBtn = Instance.new("TextButton", Card); TpBtn.Size = UDim2.new(0, 40, 0, 26); TpBtn.Position = UDim2.new(1, -45, 0.5, -13); TpBtn.BackgroundColor3 = tGreen; TpBtn.Text = "TP"; TpBtn.TextColor3 = Color3.fromRGB(10, 10, 10); TpBtn.Font = Enum.Font.GothamBold; TpBtn.TextSize = 12; Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 4)
                TpBtn.MouseButton1Click:Connect(function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end end)
            end
        end
    end
    TPScroll.CanvasSize = UDim2.new(0, 0, 0, TPListLayout.AbsoluteContentSize.Y + 10)
end
TPSearchBox:GetPropertyChangedSignal("Text"):Connect(function() RefreshTPMenu(TPSearchBox.Text) end)

-- ==================================================================
-- 4. INTERFAZ INVISIBLE MENU (GHOST MODE PERFECTO)
-- ==================================================================
local InvMain = Instance.new("Frame", ScreenGui); InvMain.Size = UDim2.new(0, 260, 0, 100); InvMain.Position = UDim2.new(0, 20, 0, 20); InvMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); InvMain.BorderSizePixel = 0; InvMain.ClipsDescendants = true; InvMain.Visible = false; Instance.new("UICorner", InvMain).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", InvMain).Color = borderDark
local InvTopBar = Instance.new("Frame", InvMain); InvTopBar.Size = UDim2.new(1, 0, 0, 35); InvTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); InvTopBar.BorderSizePixel = 0; Instance.new("UICorner", InvTopBar).CornerRadius = UDim.new(0, 6)
local InvFix = Instance.new("Frame", InvTopBar); InvFix.Size = UDim2.new(1, 0, 0, 5); InvFix.Position = UDim2.new(0, 0, 1, -5); InvFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); InvFix.BorderSizePixel = 0
local InvTitle = Instance.new("TextLabel", InvTopBar); InvTitle.Size = UDim2.new(1, -70, 1, 0); InvTitle.Position = UDim2.new(0, 15, 0, 0); InvTitle.BackgroundTransparency = 1; InvTitle.Text = "INVISIBILITY"; InvTitle.TextColor3 = tWhite; InvTitle.Font = Enum.Font.GothamBold; InvTitle.TextSize = 13; InvTitle.TextXAlignment = Enum.TextXAlignment.Left
local InvMinBtn = Instance.new("TextButton", InvTopBar); InvMinBtn.Size = UDim2.new(0, 35, 1, 0); InvMinBtn.Position = UDim2.new(1, -70, 0, 0); InvMinBtn.BackgroundTransparency = 1; InvMinBtn.Text = "—"; InvMinBtn.TextColor3 = tGreen; InvMinBtn.Font = Enum.Font.GothamBlack; InvMinBtn.TextSize = 14
local InvCloseBtn = Instance.new("TextButton", InvTopBar); InvCloseBtn.Size = UDim2.new(0, 35, 1, 0); InvCloseBtn.Position = UDim2.new(1, -35, 0, 0); InvCloseBtn.BackgroundTransparency = 1; InvCloseBtn.Text = "X"; InvCloseBtn.TextColor3 = tRed; InvCloseBtn.Font = Enum.Font.GothamBlack; InvCloseBtn.TextSize = 12
local InvToggleBtn = Instance.new("TextButton", InvMain); InvToggleBtn.Size = UDim2.new(1, -75, 0, 45); InvToggleBtn.Position = UDim2.new(0, 10, 0, 45); InvToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); InvToggleBtn.Text = "INVISIBILIDAD: OFF"; InvToggleBtn.TextColor3 = tWhite; InvToggleBtn.Font = Enum.Font.GothamBold; InvToggleBtn.TextSize = 12; Instance.new("UICorner", InvToggleBtn).CornerRadius = UDim.new(0, 6)
local InvKeyBtn = Instance.new("TextButton", InvMain); InvKeyBtn.Size = UDim2.new(0, 50, 0, 45); InvKeyBtn.Position = UDim2.new(1, -60, 0, 45); InvKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); InvKeyBtn.Text = "KEY"; InvKeyBtn.TextColor3 = tWhite; InvKeyBtn.Font = Enum.Font.GothamBold; InvKeyBtn.TextSize = 11; Instance.new("UICorner", InvKeyBtn).CornerRadius = UDim.new(0, 6)

ApplyResponsiveScale(InvMain); MakeDraggable(InvTopBar, InvMain)

local invMinimized = false
InvMinBtn.MouseButton1Click:Connect(function()
    invMinimized = not invMinimized; InvMain:TweenSize(invMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 100), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    InvMinBtn.Text = invMinimized and "+" or "—"; InvFix.Visible = not invMinimized
end)
InvCloseBtn.MouseButton1Click:Connect(function() InvMain.Visible = false end)

local isGhostActive = false; local ghostModel = nil; local ghostPlatform = nil; local controlsConnection = nil; local activationConn = nil; local activationEndConn = nil; local toolSyncConnAdded = nil; local toolSyncConnRemoved = nil; local currentVisualTool = nil; local animTracks = {Idle=nil, Walk=nil, Sit=nil}; local currentAnim = nil; local invKeybind = nil; local isInvBinding = false; local isAttacking = false 

pcall(function() if getgenv().PhysicalGhostCon then getgenv().PhysicalGhostCon:Disconnect() end; if getgenv().GhostPlatform then getgenv().GhostPlatform:Destroy() end; if getgenv().GhostModel then getgenv().GhostModel:Destroy() end; getgenv().GhostActive = false end)

local function getAnimID(scriptName, childName)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Animate") then
        local animScript = char.Animate
        if animScript:FindFirstChild(scriptName) then local value = animScript[scriptName]:FindFirstChild(childName); if value and value:IsA("Animation") then return value.AnimationId end end
    end
    if scriptName == "idle" then return "http://www.roblox.com/asset/?id=507766388" elseif scriptName == "sit" then return "http://www.roblox.com/asset/?id=2506281703" else return "http://www.roblox.com/asset/?id=507777826" end
end

local function setRealCharTransparency(visible)
    local char = LocalPlayer.Character; if not char then return end
    local trans = visible and 0 or 1
    for _, v in pairs(char:GetDescendants()) do if (v:IsA("BasePart") and v.Name ~= "HumanoidRootPart") or v:IsA("Decal") then v.Transparency = trans elseif v:IsA("BasePart") then v.Transparency = 1 end end
end

local function createSafetyPlatform()
    local p = Instance.new("Part"); p.Name = "SafeZone_Floor"; p.Size = Vector3.new(50, 4, 50); p.Anchored = true; p.Transparency = 1; p.CanCollide = true; p.Parent = Workspace; return p
end

local function createVisualTool(realTool, ghostModel)
    if currentVisualTool then currentVisualTool:Destroy() end
    local visual = realTool:Clone(); visual.Name = "Visual_" .. realTool.Name; visual.Parent = ghostModel
    for _, v in pairs(visual:GetDescendants()) do if v:IsA("BasePart") then v.Transparency = 0; v.CanCollide = false; v.Massless = true elseif v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Sound") then v:Destroy() end end
    local handle = visual:FindFirstChild("Handle") or visual:FindFirstChildOfClass("BasePart")
    local rightHand = ghostModel:FindFirstChild("RightHand", true) or ghostModel:FindFirstChild("Right Arm", true)
    if handle and rightHand then handle.CFrame = rightHand.CFrame * realTool.Grip; local weld = Instance.new("WeldConstraint"); weld.Part0 = rightHand; weld.Part1 = handle; weld.Parent = rightHand end
    currentVisualTool = visual
end

local function createPhysicalGhost(original)
    original.Archivable = true; local clone = original:Clone(); clone.Name = "Clone_Active"; clone.Parent = Workspace
    for _, v in pairs(clone:GetDescendants()) do if v:IsA("BasePart") then v.Transparency = 0.5; v.Anchored = false; v.CanCollide = true; if v.Name == "HumanoidRootPart" then v.Transparency = 1; v.CanCollide = false end elseif v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Sound") then v:Destroy() end end
    for _, child in pairs(clone:GetChildren()) do if child:IsA("Tool") then child:Destroy() end end
    local ghostHum = clone:FindFirstChild("Humanoid")
    if ghostHum then
        ghostHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None; ghostHum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        local animator = ghostHum:FindFirstChild("Animator") or Instance.new("Animator", ghostHum)
        local animIdle = Instance.new("Animation"); animIdle.AnimationId = getAnimID("idle", "Animation1"); local animWalk = Instance.new("Animation"); animWalk.AnimationId = getAnimID("run", "RunAnim"); local animSit = Instance.new("Animation"); animSit.AnimationId = getAnimID("sit", "Animation1")
        animTracks.Idle = animator:LoadAnimation(animIdle); animTracks.Walk = animator:LoadAnimation(animWalk); animTracks.Sit = animator:LoadAnimation(animSit)
        for _, track in pairs(animTracks) do if track then track.Looped = true end end; animTracks.Idle:Play(); currentAnim = "Idle"
    end
    return clone
end

local function updateGhostAnim(isMoving, isSitting)
    if isSitting then if currentAnim ~= "Sit" then if animTracks.Idle then animTracks.Idle:Stop(0.1) end; if animTracks.Walk then animTracks.Walk:Stop(0.1) end; if animTracks.Sit then animTracks.Sit:Play(0.1) end; currentAnim = "Sit" end
    elseif isMoving then if currentAnim ~= "Walk" then if animTracks.Idle then animTracks.Idle:Stop(0.1) end; if animTracks.Sit then animTracks.Sit:Stop(0.1) end; if animTracks.Walk then animTracks.Walk:Play(0.1) end; currentAnim = "Walk" end
    else if currentAnim ~= "Idle" then if animTracks.Walk then animTracks.Walk:Stop(0.1) end; if animTracks.Sit then animTracks.Sit:Stop(0.1) end; if animTracks.Idle then animTracks.Idle:Play(0.1) end; currentAnim = "Idle" end end
end

local function startControls()
    if controlsConnection then controlsConnection:Disconnect() end; if activationConn then activationConn:Disconnect() end; if activationEndConn then activationEndConn:Disconnect() end
    local ghostCollidable = true
    controlsConnection = RunService.RenderStepped:Connect(function()
        if not ghostModel or not isGhostActive then return end
        local ghostHum = ghostModel:FindFirstChild("Humanoid"); local char = LocalPlayer.Character; local realHum = char and char:FindFirstChild("Humanoid"); local realRoot = char and char.PrimaryPart; local ghostRoot = ghostModel.PrimaryPart
        if not ghostHum or not char or not realHum or not realRoot or not ghostRoot then return end
        
        local moveVec = Vector3.new(0,0,0); local camCF = Workspace.CurrentCamera.CFrame; local look = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit; local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit; local isMovingInput = false
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + look; isMovingInput = true end; if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - look; isMovingInput = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + right; isMovingInput = true end; if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - right; isMovingInput = true end
        
        local isSitting = realHum.Sit
        if isSitting then ghostRoot.CFrame = realRoot.CFrame
        else
            if moveVec.Magnitude > 0 then ghostHum:Move(moveVec, false) else ghostHum:Move(Vector3.new(0,0,0), false) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then ghostHum.Jump = true end
            if not isAttacking then
                if ghostPlatform then ghostPlatform.CFrame = ghostRoot.CFrame * CFrame.new(0, -48, 0) end
                realRoot.CFrame = ghostRoot.CFrame * CFrame.new(0, -45, 0); realRoot.AssemblyLinearVelocity = Vector3.zero
            else realRoot.CFrame = ghostRoot.CFrame end
        end
        local targetCollidable = not isSitting
        if targetCollidable ~= ghostCollidable then ghostCollidable = targetCollidable; for _, v in pairs(ghostModel:GetDescendants()) do if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.CanCollide = ghostCollidable end end end
        updateGhostAnim(isMovingInput and not isSitting, isSitting)
    end)
    activationConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end; if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then isAttacking = true end
        local char = LocalPlayer.Character; if not char or not isGhostActive then return end; local tool = char:FindFirstChildOfClass("Tool")
        if tool then if input.UserInputType == Enum.UserInputType.MouseButton1 then tool:Activate() elseif input.UserInputType == Enum.UserInputType.MouseButton2 then pcall(function() tool:Activate() end) end end
    end)
    activationEndConn = UserInputService.InputEnded:Connect(function(input, gpe) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then isAttacking = false end end)
    pcall(function() getgenv().PhysicalGhostCon = controlsConnection end)
end

local function ToggleGhost()
    isGhostActive = not isGhostActive; pcall(function() getgenv().GhostActive = isGhostActive end)
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); local realHum = char:FindFirstChild("Humanoid"); if not root or not realHum then return end
    local camera = Workspace.CurrentCamera
    if isGhostActive then
        local startCF = root.CFrame; ghostPlatform = createSafetyPlatform(); pcall(function() getgenv().GhostPlatform = ghostPlatform end)
        ghostModel = createPhysicalGhost(char); ghostModel.HumanoidRootPart.CFrame = startCF; pcall(function() getgenv().GhostModel = ghostModel end)
        local currentTool = char:FindFirstChildOfClass("Tool"); if currentTool then createVisualTool(currentTool, ghostModel) end
        setRealCharTransparency(false); camera.CameraSubject = ghostModel:FindFirstChild("Humanoid")
        toolSyncConnAdded = char.ChildAdded:Connect(function(child) if child:IsA("Tool") then createVisualTool(child, ghostModel) end end)
        toolSyncConnRemoved = char.ChildRemoved:Connect(function(child) if child:IsA("Tool") and currentVisualTool then currentVisualTool:Destroy(); currentVisualTool = nil end end)
        startControls(); InvToggleBtn.BackgroundColor3 = tGreen; InvToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10); InvToggleBtn.Text = "INVISIBILIDAD: ON"
    else
        if controlsConnection then controlsConnection:Disconnect() end; if activationConn then activationConn:Disconnect() end; if activationEndConn then activationEndConn:Disconnect() end
        if toolSyncConnAdded then toolSyncConnAdded:Disconnect(); toolSyncConnAdded = nil end; if toolSyncConnRemoved then toolSyncConnRemoved:Disconnect(); toolSyncConnRemoved = nil end
        if animTracks.Walk then animTracks.Walk:Stop() end; if animTracks.Idle then animTracks.Idle:Stop() end; if animTracks.Sit then animTracks.Sit:Stop() end
        if currentVisualTool then currentVisualTool:Destroy(); currentVisualTool = nil end
        camera.CameraSubject = realHum; if ghostModel and ghostModel.PrimaryPart then char:SetPrimaryPartCFrame(ghostModel.PrimaryPart.CFrame) end
        setRealCharTransparency(true); local ghostHum = ghostModel and ghostModel:FindFirstChild("Humanoid")
        if ghostHum then local seat = ghostHum.SeatPart; if seat then seat:Sit(realHum) else realHum.Sit = ghostHum.Sit end end
        if ghostModel then ghostModel:Destroy() end; if ghostPlatform then ghostPlatform:Destroy() end
        ghostModel = nil; ghostPlatform = nil; animTracks = {Idle = nil, Walk = nil, Sit = nil}; currentAnim = nil; isAttacking = false
        InvToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); InvToggleBtn.TextColor3 = tWhite; InvToggleBtn.Text = "INVISIBILIDAD: OFF"
    end
end
InvToggleBtn.MouseButton1Click:Connect(ToggleGhost)

InvKeyBtn.MouseButton1Click:Connect(function()
    if invKeybind ~= nil then invKeybind = nil; InvKeyBtn.Text = "KEY"; InvKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isInvBinding = false
    else isInvBinding = true; InvKeyBtn.Text = "..."; InvKeyBtn.BackgroundColor3 = tOrange end
end)

LocalPlayer.CharacterAdded:Connect(function() if isGhostActive then ToggleGhost() end end)

-- ==================================================================
-- 5. INTERFAZ Y LÓGICA DEL MENÚ FLY (NOCLIP FLY AEREO)
-- ==================================================================
local FlyMain = Instance.new("Frame", ScreenGui); FlyMain.Size = UDim2.new(0, 260, 0, 145); FlyMain.Position = UDim2.new(0, 20, 0, 140); FlyMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); FlyMain.BorderSizePixel = 0; FlyMain.ClipsDescendants = true; FlyMain.Visible = false; Instance.new("UICorner", FlyMain).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", FlyMain).Color = borderDark
local FlyTopBar = Instance.new("Frame", FlyMain); FlyTopBar.Size = UDim2.new(1, 0, 0, 35); FlyTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); FlyTopBar.BorderSizePixel = 0; Instance.new("UICorner", FlyTopBar).CornerRadius = UDim.new(0, 6)
local FlyFix = Instance.new("Frame", FlyTopBar); FlyFix.Size = UDim2.new(1, 0, 0, 5); FlyFix.Position = UDim2.new(0, 0, 1, -5); FlyFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); FlyFix.BorderSizePixel = 0
local FlyTitle = Instance.new("TextLabel", FlyTopBar); FlyTitle.Size = UDim2.new(1, -70, 1, 0); FlyTitle.Position = UDim2.new(0, 15, 0, 0); FlyTitle.BackgroundTransparency = 1; FlyTitle.Text = "NOCLIP FLY"; FlyTitle.TextColor3 = tWhite; FlyTitle.Font = Enum.Font.GothamBold; FlyTitle.TextSize = 13; FlyTitle.TextXAlignment = Enum.TextXAlignment.Left
local FlyMinBtn = Instance.new("TextButton", FlyTopBar); FlyMinBtn.Size = UDim2.new(0, 35, 1, 0); FlyMinBtn.Position = UDim2.new(1, -70, 0, 0); FlyMinBtn.BackgroundTransparency = 1; FlyMinBtn.Text = "—"; FlyMinBtn.TextColor3 = tGreen; FlyMinBtn.Font = Enum.Font.GothamBlack; FlyMinBtn.TextSize = 14
local FlyCloseBtn = Instance.new("TextButton", FlyTopBar); FlyCloseBtn.Size = UDim2.new(0, 35, 1, 0); FlyCloseBtn.Position = UDim2.new(1, -35, 0, 0); FlyCloseBtn.BackgroundTransparency = 1; FlyCloseBtn.Text = "X"; FlyCloseBtn.TextColor3 = tRed; FlyCloseBtn.Font = Enum.Font.GothamBlack; FlyCloseBtn.TextSize = 12

local FlyToggleBtn = Instance.new("TextButton", FlyMain); FlyToggleBtn.Size = UDim2.new(1, -75, 0, 45); FlyToggleBtn.Position = UDim2.new(0, 10, 0, 45); FlyToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); FlyToggleBtn.Text = "VUELO: OFF"; FlyToggleBtn.TextColor3 = tWhite; FlyToggleBtn.Font = Enum.Font.GothamBold; FlyToggleBtn.TextSize = 12; Instance.new("UICorner", FlyToggleBtn).CornerRadius = UDim.new(0, 6)
local FlyKeyBtn = Instance.new("TextButton", FlyMain); FlyKeyBtn.Size = UDim2.new(0, 50, 0, 45); FlyKeyBtn.Position = UDim2.new(1, -60, 0, 45); FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FlyKeyBtn.Text = "KEY"; FlyKeyBtn.TextColor3 = tWhite; FlyKeyBtn.Font = Enum.Font.GothamBold; FlyKeyBtn.TextSize = 11; Instance.new("UICorner", FlyKeyBtn).CornerRadius = UDim.new(0, 6)

local FlySpeedMinus = Instance.new("TextButton", FlyMain); FlySpeedMinus.Size = UDim2.new(0, 40, 0, 35); FlySpeedMinus.Position = UDim2.new(0, 10, 0, 100); FlySpeedMinus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FlySpeedMinus.Text = "-"; FlySpeedMinus.TextColor3 = tWhite; FlySpeedMinus.Font = Enum.Font.GothamBold; Instance.new("UICorner", FlySpeedMinus)
local FlySpeedDisplay = Instance.new("TextBox", FlyMain); FlySpeedDisplay.Size = UDim2.new(1, -110, 0, 35); FlySpeedDisplay.Position = UDim2.new(0, 55, 0, 100); FlySpeedDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 25); FlySpeedDisplay.Text = ""; FlySpeedDisplay.PlaceholderText = "SPEED: 100"; FlySpeedDisplay.TextColor3 = tWhite; FlySpeedDisplay.Font = Enum.Font.GothamSemibold; FlySpeedDisplay.TextSize = 14; FlySpeedDisplay.ClearTextOnFocus = true; Instance.new("UICorner", FlySpeedDisplay); Instance.new("UIStroke", FlySpeedDisplay).Color = Color3.fromRGB(50, 50, 50)
local FlySpeedPlus = Instance.new("TextButton", FlyMain); FlySpeedPlus.Size = UDim2.new(0, 40, 0, 35); FlySpeedPlus.Position = UDim2.new(1, -50, 0, 100); FlySpeedPlus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FlySpeedPlus.Text = "+"; FlySpeedPlus.TextColor3 = tWhite; FlySpeedPlus.Font = Enum.Font.GothamBold; Instance.new("UICorner", FlySpeedPlus)

ApplyResponsiveScale(FlyMain); MakeDraggable(FlyTopBar, FlyMain)

local flyMinimized = false
FlyMinBtn.MouseButton1Click:Connect(function()
    flyMinimized = not flyMinimized; FlyMain:TweenSize(flyMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 145), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    FlyMinBtn.Text = flyMinimized and "+" or "—"; FlyFix.Visible = not flyMinimized
end)
FlyCloseBtn.MouseButton1Click:Connect(function() FlyMain.Visible = false end)

local isFlying = false; local flySpeed = 100; local flyKeybind = nil; local isFlyBinding = false; local flyLoop = nil; local flycontrol = {F = 0, R = 0, B = 0, L = 0, U = 0, D = 0}

FlySpeedMinus.MouseButton1Click:Connect(function() flySpeed = math.max(10, flySpeed - 10); FlySpeedDisplay.Text = "SPEED: " .. flySpeed end)
FlySpeedPlus.MouseButton1Click:Connect(function() flySpeed = flySpeed + 10; FlySpeedDisplay.Text = "SPEED: " .. flySpeed end)
FlySpeedDisplay.FocusLost:Connect(function() local num = tonumber(FlySpeedDisplay.Text:match("%d+")); if num then flySpeed = num end; FlySpeedDisplay.Text = "SPEED: " .. flySpeed end)

local function ToggleFly()
    local char = LocalPlayer.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hrp or not hum then return end
    isFlying = not isFlying
    if isFlying then
        FlyToggleBtn.BackgroundColor3 = tCyan; FlyToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10); FlyToggleBtn.Text = "VUELO: ON"
        local bv = Instance.new("BodyVelocity"); local bg = Instance.new("BodyGyro")
        bv.Name = "AK_FlyVel"; bg.Name = "AK_FlyGyro"; bv.MaxForce = Vector3.new(9e4, 9e4, 9e4); bg.MaxTorque = Vector3.new(9e4, 9e4, 9e4); bg.P = 9e4; bg.CFrame = hrp.CFrame; bv.Parent = hrp; bg.Parent = hrp
        flyLoop = RunService.Stepped:Connect(function()
            if not isFlying or not hrp or not hum then return end
            hum.PlatformStand = true
            for _, child in pairs(char:GetDescendants()) do if child:IsA("BasePart") then child.CanCollide = false end end
            local camCF = Workspace.CurrentCamera.CFrame
            bv.Velocity = (camCF.LookVector * ((flycontrol.F - flycontrol.B) * flySpeed)) + (camCF.RightVector * ((flycontrol.R - flycontrol.L) * flySpeed)) + (camCF.UpVector * ((flycontrol.U - flycontrol.D) * flySpeed))
            bg.CFrame = camCF
        end)
    else
        FlyToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); FlyToggleBtn.TextColor3 = tWhite; FlyToggleBtn.Text = "VUELO: OFF"
        if flyLoop then flyLoop:Disconnect() flyLoop = nil end
        if hrp:FindFirstChild("AK_FlyVel") then hrp.AK_FlyVel:Destroy() end; if hrp:FindFirstChild("AK_FlyGyro") then hrp.AK_FlyGyro:Destroy() end
        hum.PlatformStand = false; for _, child in pairs(char:GetDescendants()) do if child:IsA("BasePart") then child.CanCollide = true end end
    end
end
FlyToggleBtn.MouseButton1Click:Connect(ToggleFly)

FlyKeyBtn.MouseButton1Click:Connect(function()
    if flyKeybind ~= nil then flyKeybind = nil; FlyKeyBtn.Text = "KEY"; FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isFlyBinding = false
    else isFlyBinding = true; FlyKeyBtn.Text = "..."; FlyKeyBtn.BackgroundColor3 = tOrange end
end)

LocalPlayer.CharacterAdded:Connect(function() if isFlying then ToggleFly() end end)

-- ==================================================================
-- 6. NOCLIP WALK (ATRAVIESA PAREDES CAMINANDO + ANTI-VACÍO)
-- ==================================================================
local NoclipMain = Instance.new("Frame", ScreenGui); NoclipMain.Size = UDim2.new(0, 260, 0, 100); NoclipMain.Position = UDim2.new(0, 20, 0, 260); NoclipMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); NoclipMain.BorderSizePixel = 0; NoclipMain.ClipsDescendants = true; NoclipMain.Visible = false; Instance.new("UICorner", NoclipMain).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", NoclipMain).Color = borderDark
local NoclipTopBar = Instance.new("Frame", NoclipMain); NoclipTopBar.Size = UDim2.new(1, 0, 0, 35); NoclipTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); NoclipTopBar.BorderSizePixel = 0; Instance.new("UICorner", NoclipTopBar).CornerRadius = UDim.new(0, 6)
local NoclipFix = Instance.new("Frame", NoclipTopBar); NoclipFix.Size = UDim2.new(1, 0, 0, 5); NoclipFix.Position = UDim2.new(0, 0, 1, -5); NoclipFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); NoclipFix.BorderSizePixel = 0
local NoclipTitle = Instance.new("TextLabel", NoclipTopBar); NoclipTitle.Size = UDim2.new(1, -70, 1, 0); NoclipTitle.Position = UDim2.new(0, 15, 0, 0); NoclipTitle.BackgroundTransparency = 1; NoclipTitle.Text = "NOCLIP WALK"; NoclipTitle.TextColor3 = tWhite; NoclipTitle.Font = Enum.Font.GothamBold; NoclipTitle.TextSize = 13; NoclipTitle.TextXAlignment = Enum.TextXAlignment.Left
local NoclipMinBtn = Instance.new("TextButton", NoclipTopBar); NoclipMinBtn.Size = UDim2.new(0, 35, 1, 0); NoclipMinBtn.Position = UDim2.new(1, -70, 0, 0); NoclipMinBtn.BackgroundTransparency = 1; NoclipMinBtn.Text = "—"; NoclipMinBtn.TextColor3 = tGreen; NoclipMinBtn.Font = Enum.Font.GothamBlack; NoclipMinBtn.TextSize = 14
local NoclipCloseBtn = Instance.new("TextButton", NoclipTopBar); NoclipCloseBtn.Size = UDim2.new(0, 35, 1, 0); NoclipCloseBtn.Position = UDim2.new(1, -35, 0, 0); NoclipCloseBtn.BackgroundTransparency = 1; NoclipCloseBtn.Text = "X"; NoclipCloseBtn.TextColor3 = tRed; NoclipCloseBtn.Font = Enum.Font.GothamBlack; NoclipCloseBtn.TextSize = 12

local NoclipToggleBtn = Instance.new("TextButton", NoclipMain); NoclipToggleBtn.Size = UDim2.new(1, -75, 0, 45); NoclipToggleBtn.Position = UDim2.new(0, 10, 0, 45); NoclipToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); NoclipToggleBtn.Text = "NOCLIP: OFF"; NoclipToggleBtn.TextColor3 = tWhite; NoclipToggleBtn.Font = Enum.Font.GothamBold; NoclipToggleBtn.TextSize = 12; Instance.new("UICorner", NoclipToggleBtn).CornerRadius = UDim.new(0, 6)
local NoclipKeyBtn = Instance.new("TextButton", NoclipMain); NoclipKeyBtn.Size = UDim2.new(0, 50, 0, 45); NoclipKeyBtn.Position = UDim2.new(1, -60, 0, 45); NoclipKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); NoclipKeyBtn.Text = "KEY"; NoclipKeyBtn.TextColor3 = tWhite; NoclipKeyBtn.Font = Enum.Font.GothamBold; NoclipKeyBtn.TextSize = 11; Instance.new("UICorner", NoclipKeyBtn).CornerRadius = UDim.new(0, 6)

ApplyResponsiveScale(NoclipMain); MakeDraggable(NoclipTopBar, NoclipMain)

local noclipMinimized = false
NoclipMinBtn.MouseButton1Click:Connect(function()
    noclipMinimized = not noclipMinimized; NoclipMain:TweenSize(noclipMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 100), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    NoclipMinBtn.Text = noclipMinimized and "+" or "—"; NoclipFix.Visible = not noclipMinimized
end)
NoclipCloseBtn.MouseButton1Click:Connect(function() NoclipMain.Visible = false end)

local isNoclipActive = false; local noclipLoop = nil; local noclipFloor = nil; local noclipKeybind = nil; local isNoclipBinding = false

local function ToggleNoclipWalk()
    isNoclipActive = not isNoclipActive; local char = LocalPlayer.Character
    if isNoclipActive then
        NoclipToggleBtn.BackgroundColor3 = tCyan; NoclipToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10); NoclipToggleBtn.Text = "NOCLIP: ON"
        noclipFloor = Instance.new("Part"); noclipFloor.Name = "CDT_AntiVoid"; noclipFloor.Size = Vector3.new(10, 2, 10); noclipFloor.Transparency = 1; noclipFloor.Anchored = true; noclipFloor.CanCollide = true; noclipFloor.Parent = Workspace
        
        noclipLoop = RunService.Stepped:Connect(function()
            local c = LocalPlayer.Character; if not c then return end
            local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            for _, part in pairs(c:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
            
            local limiteVacio = Workspace.FallenPartsDestroyHeight + 100
            if hrp.Position.Y < limiteVacio then noclipFloor.Position = Vector3.new(hrp.Position.X, limiteVacio, hrp.Position.Z)
            else
                local rayParams = RaycastParams.new(); rayParams.FilterDescendantsInstances = {c, noclipFloor}; rayParams.FilterType = Enum.RaycastFilterType.Exclude
                local hit = Workspace:Raycast(hrp.Position, Vector3.new(0, -20, 0), rayParams)
                if hit then noclipFloor.Position = hit.Position + Vector3.new(0, -1, 0) else noclipFloor.Position = Vector3.new(0, 100000, 0) end
            end
        end)
    else
        NoclipToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); NoclipToggleBtn.TextColor3 = tWhite; NoclipToggleBtn.Text = "NOCLIP: OFF"
        if noclipLoop then noclipLoop:Disconnect(); noclipLoop = nil end
        if noclipFloor then noclipFloor:Destroy(); noclipFloor = nil end
        if char then for _, part in pairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = true end end end
    end
end
NoclipToggleBtn.MouseButton1Click:Connect(ToggleNoclipWalk)

NoclipKeyBtn.MouseButton1Click:Connect(function()
    if noclipKeybind ~= nil then noclipKeybind = nil; NoclipKeyBtn.Text = "KEY"; NoclipKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isNoclipBinding = false
    else isNoclipBinding = true; NoclipKeyBtn.Text = "..."; NoclipKeyBtn.BackgroundColor3 = tOrange end
end)

LocalPlayer.CharacterAdded:Connect(function() if isNoclipActive then ToggleNoclipWalk() end end)

-- ==================================================================
-- 7. VEHICLE FLY (ZACH'S SCRIPT LERP)
-- ==================================================================
local VFlyMain = Instance.new("Frame", ScreenGui); VFlyMain.Size = UDim2.new(0, 260, 0, 145); VFlyMain.Position = UDim2.new(0, 20, 0, 380); VFlyMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); VFlyMain.BorderSizePixel = 0; VFlyMain.ClipsDescendants = true; VFlyMain.Visible = false; Instance.new("UICorner", VFlyMain).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", VFlyMain).Color = borderDark
local VFlyTopBar = Instance.new("Frame", VFlyMain); VFlyTopBar.Size = UDim2.new(1, 0, 0, 35); VFlyTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); VFlyTopBar.BorderSizePixel = 0; Instance.new("UICorner", VFlyTopBar).CornerRadius = UDim.new(0, 6)
local VFlyFix = Instance.new("Frame", VFlyTopBar); VFlyFix.Size = UDim2.new(1, 0, 0, 5); VFlyFix.Position = UDim2.new(0, 0, 1, -5); VFlyFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); VFlyFix.BorderSizePixel = 0
local VFlyTitle = Instance.new("TextLabel", VFlyTopBar); VFlyTitle.Size = UDim2.new(1, -70, 1, 0); VFlyTitle.Position = UDim2.new(0, 15, 0, 0); VFlyTitle.BackgroundTransparency = 1; VFlyTitle.Text = "VEHICLE FLY"; VFlyTitle.TextColor3 = tWhite; VFlyTitle.Font = Enum.Font.GothamBold; VFlyTitle.TextSize = 13; VFlyTitle.TextXAlignment = Enum.TextXAlignment.Left
local VFlyMinBtn = Instance.new("TextButton", VFlyTopBar); VFlyMinBtn.Size = UDim2.new(0, 35, 1, 0); VFlyMinBtn.Position = UDim2.new(1, -70, 0, 0); VFlyMinBtn.BackgroundTransparency = 1; VFlyMinBtn.Text = "—"; VFlyMinBtn.TextColor3 = tGreen; VFlyMinBtn.Font = Enum.Font.GothamBlack; VFlyMinBtn.TextSize = 14
local VFlyCloseBtn = Instance.new("TextButton", VFlyTopBar); VFlyCloseBtn.Size = UDim2.new(0, 35, 1, 0); VFlyCloseBtn.Position = UDim2.new(1, -35, 0, 0); VFlyCloseBtn.BackgroundTransparency = 1; VFlyCloseBtn.Text = "X"; VFlyCloseBtn.TextColor3 = tRed; VFlyCloseBtn.Font = Enum.Font.GothamBlack; VFlyCloseBtn.TextSize = 12

local VFlyToggleBtn = Instance.new("TextButton", VFlyMain); VFlyToggleBtn.Size = UDim2.new(1, -75, 0, 45); VFlyToggleBtn.Position = UDim2.new(0, 10, 0, 45); VFlyToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); VFlyToggleBtn.Text = "V-FLY: OFF"; VFlyToggleBtn.TextColor3 = tWhite; VFlyToggleBtn.Font = Enum.Font.GothamBold; VFlyToggleBtn.TextSize = 12; Instance.new("UICorner", VFlyToggleBtn).CornerRadius = UDim.new(0, 6)
local VFlyKeyBtn = Instance.new("TextButton", VFlyMain); VFlyKeyBtn.Size = UDim2.new(0, 50, 0, 45); VFlyKeyBtn.Position = UDim2.new(1, -60, 0, 45); VFlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); VFlyKeyBtn.Text = "KEY"; VFlyKeyBtn.TextColor3 = tWhite; VFlyKeyBtn.Font = Enum.Font.GothamBold; VFlyKeyBtn.TextSize = 11; Instance.new("UICorner", VFlyKeyBtn).CornerRadius = UDim.new(0, 6)

local VFlySpeedMinus = Instance.new("TextButton", VFlyMain); VFlySpeedMinus.Size = UDim2.new(0, 40, 0, 35); VFlySpeedMinus.Position = UDim2.new(0, 10, 0, 100); VFlySpeedMinus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); VFlySpeedMinus.Text = "-"; VFlySpeedMinus.TextColor3 = tWhite; VFlySpeedMinus.Font = Enum.Font.GothamBold; Instance.new("UICorner", VFlySpeedMinus)
local VFlySpeedDisplay = Instance.new("TextBox", VFlyMain); VFlySpeedDisplay.Size = UDim2.new(1, -110, 0, 35); VFlySpeedDisplay.Position = UDim2.new(0, 55, 0, 100); VFlySpeedDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 25); VFlySpeedDisplay.Text = ""; VFlySpeedDisplay.PlaceholderText = "SPEED: 256"; VFlySpeedDisplay.TextColor3 = tWhite; VFlySpeedDisplay.Font = Enum.Font.GothamSemibold; VFlySpeedDisplay.TextSize = 14; VFlySpeedDisplay.ClearTextOnFocus = true; Instance.new("UICorner", VFlySpeedDisplay); Instance.new("UIStroke", VFlySpeedDisplay).Color = Color3.fromRGB(50, 50, 50)
local VFlySpeedPlus = Instance.new("TextButton", VFlyMain); VFlySpeedPlus.Size = UDim2.new(0, 40, 0, 35); VFlySpeedPlus.Position = UDim2.new(1, -50, 0, 100); VFlySpeedPlus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); VFlySpeedPlus.Text = "+"; VFlySpeedPlus.TextColor3 = tWhite; VFlySpeedPlus.Font = Enum.Font.GothamBold; Instance.new("UICorner", VFlySpeedPlus)

ApplyResponsiveScale(VFlyMain); MakeDraggable(VFlyTopBar, VFlyMain)

local vflyMinimized = false
VFlyMinBtn.MouseButton1Click:Connect(function()
    vflyMinimized = not vflyMinimized; VFlyMain:TweenSize(vflyMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 145), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    VFlyMinBtn.Text = vflyMinimized and "+" or "—"; VFlyFix.Visible = not vflyMinimized
end)
VFlyCloseBtn.MouseButton1Click:Connect(function() VFlyMain.Visible = false end)

local isVFlying = false; local vFlySpeedNum = 256; local vFlyAccel = 4; local vFlyTurn = 16; local vFlyMultiplier = 3; local vFlyKeybind = nil; local isVFlyBinding = false; local vFlyConn = nil; local vFlyCurrentVel = Vector3.new(0,0,0)

VFlySpeedMinus.MouseButton1Click:Connect(function() vFlySpeedNum = math.max(1, vFlySpeedNum - 10); VFlySpeedDisplay.Text = "SPEED: " .. vFlySpeedNum end)
VFlySpeedPlus.MouseButton1Click:Connect(function() vFlySpeedNum = vFlySpeedNum + 10; VFlySpeedDisplay.Text = "SPEED: " .. vFlySpeedNum end)
VFlySpeedDisplay.FocusLost:Connect(function() local num = tonumber(VFlySpeedDisplay.Text:match("%d+")); if num then vFlySpeedNum = math.max(1, num) end; VFlySpeedDisplay.Text = "SPEED: " .. vFlySpeedNum end)

local function VFlyLoop(delta)
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local camCF = Workspace.CurrentCamera.CFrame; local baseVel = Vector3.new(0,0,0)
    
    if not UserInputService:GetFocusedTextBox() then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then baseVel += camCF.LookVector * vFlySpeedNum end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then baseVel -= camCF.RightVector * vFlySpeedNum end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then baseVel -= camCF.LookVector * vFlySpeedNum end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then baseVel += camCF.RightVector * vFlySpeedNum end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then baseVel += camCF.UpVector * vFlySpeedNum end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then baseVel *= vFlyMultiplier end
    end
    
    local car = root:GetRootPart(); if car.Anchored then return end
    local hasNet = true; if type(isnetworkowner) == "function" then pcall(function() hasNet = isnetworkowner(car) end) end; if not hasNet then return end
    
    vFlyCurrentVel = vFlyCurrentVel:Lerp(baseVel, math.clamp(delta * vFlyAccel, 0, 1))
    car.Velocity = vFlyCurrentVel + Vector3.new(0, 2, 0)
    if car ~= root then car.RotVelocity = Vector3.new(0,0,0); local flatLv = (vFlyCurrentVel + camCF.LookVector) * Vector3.new(1,0,1); car.CFrame = car.CFrame:Lerp(CFrame.lookAt(car.Position, car.Position + flatLv), math.clamp(delta * vFlyTurn, 0, 1)) end
end

local function ToggleVFly()
    isVFlying = not isVFlying; local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
    if isVFlying then
        VFlyToggleBtn.BackgroundColor3 = tPurple; VFlyToggleBtn.Text = "V-FLY: ON"
        if root then vFlyCurrentVel = root.Velocity end; vFlyConn = RunService.Heartbeat:Connect(VFlyLoop)
    else
        VFlyToggleBtn.BackgroundColor3 = Color.fromRGB(30, 30, 30); VFlyToggleBtn.Text = "V-FLY: OFF"
        if vFlyConn then vFlyConn:Disconnect(); vFlyConn = nil end
    end
end
VFlyToggleBtn.MouseButton1Click:Connect(ToggleVFly)

VFlyKeyBtn.MouseButton1Click:Connect(function()
    if vFlyKeybind ~= nil then vFlyKeybind = nil; VFlyKeyBtn.Text = "KEY"; VFlyKeyBtn.BackgroundColor3 = Color.fromRGB(40, 40, 40); isVFlyBinding = false
    else isVFlyBinding = true; VFlyKeyBtn.Text = "..."; VFlyKeyBtn.BackgroundColor3 = tOrange end
end)

-- ==================================================================
-- 8. TRIP MODE MENU (CAÍDA INFINITA + LEVANTARSE CON ESPACIO)
-- ==================================================================
local TripMain = Instance.new("Frame", ScreenGui); TripMain.Size = UDim2.new(0, 260, 0, 100); TripMain.Position = UDim2.new(0, 20, 0, 540); TripMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); TripMain.BorderSizePixel = 0; TripMain.ClipsDescendants = true; TripMain.Visible = false; Instance.new("UICorner", TripMain).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", TripMain).Color = borderDark
local TripTopBar = Instance.new("Frame", TripMain); TripTopBar.Size = UDim2.new(1, 0, 0, 35); TripTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TripTopBar.BorderSizePixel = 0; Instance.new("UICorner", TripTopBar).CornerRadius = UDim.new(0, 6)
local TripFix = Instance.new("Frame", TripTopBar); TripFix.Size = UDim2.new(1, 0, 0, 5); TripFix.Position = UDim2.new(0, 0, 1, -5); TripFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TripFix.BorderSizePixel = 0
local TripTitle = Instance.new("TextLabel", TripTopBar); TripTitle.Size = UDim2.new(1, -70, 1, 0); TripTitle.Position = UDim2.new(0, 15, 0, 0); TripTitle.BackgroundTransparency = 1; TripTitle.Text = "TRIP MODE"; TripTitle.TextColor3 = tWhite; TripTitle.Font = Enum.Font.GothamBold; TripTitle.TextSize = 13; TripTitle.TextXAlignment = Enum.TextXAlignment.Left
local TripMinBtn = Instance.new("TextButton", TripTopBar); TripMinBtn.Size = UDim2.new(0, 35, 1, 0); TripMinBtn.Position = UDim2.new(1, -70, 0, 0); TripMinBtn.BackgroundTransparency = 1; TripMinBtn.Text = "—"; TripMinBtn.TextColor3 = tGreen; TripMinBtn.Font = Enum.Font.GothamBlack; TripMinBtn.TextSize = 14
local TripCloseBtn = Instance.new("TextButton", TripTopBar); TripCloseBtn.Size = UDim2.new(0, 35, 1, 0); TripCloseBtn.Position = UDim2.new(1, -35, 0, 0); TripCloseBtn.BackgroundTransparency = 1; TripCloseBtn.Text = "X"; TripCloseBtn.TextColor3 = tRed; TripCloseBtn.Font = Enum.Font.GothamBlack; TripCloseBtn.TextSize = 12

local TripToggleBtn = Instance.new("TextButton", TripMain); TripToggleBtn.Size = UDim2.new(1, -75, 0, 45); TripToggleBtn.Position = UDim2.new(0, 10, 0, 45); TripToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TripToggleBtn.Text = "TRIP (CLICK)"; TripToggleBtn.TextColor3 = tWhite; TripToggleBtn.Font = Enum.Font.GothamBold; TripToggleBtn.TextSize = 12; Instance.new("UICorner", TripToggleBtn).CornerRadius = UDim.new(0, 6)
local TripKeyBtn = Instance.new("TextButton", TripMain); TripKeyBtn.Size = UDim2.new(0, 50, 0, 45); TripKeyBtn.Position = UDim2.new(1, -60, 0, 45); TripKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); TripKeyBtn.Text = "KEY"; TripKeyBtn.TextColor3 = tWhite; TripKeyBtn.Font = Enum.Font.GothamBold; TripKeyBtn.TextSize = 11; Instance.new("UICorner", TripKeyBtn).CornerRadius = UDim.new(0, 6)

ApplyResponsiveScale(TripMain); MakeDraggable(TripTopBar, TripMain)

local tripMinimized = false
TripMinBtn.MouseButton1Click:Connect(function()
    tripMinimized = not tripMinimized; TripMain:TweenSize(tripMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 100), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    TripMinBtn.Text = tripMinimized and "+" or "—"; TripFix.Visible = not tripMinimized
end)
TripCloseBtn.MouseButton1Click:Connect(function() TripMain.Visible = false end)

local isTripped = false
local tripKeybind = nil
local isTripBinding = false

local function DoTrip()
    if isTripped then return end
    local char = LocalPlayer.Character; if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    isTripped = true 
    
    TripToggleBtn.BackgroundColor3 = tRed
    TripToggleBtn.TextColor3 = tWhite
    TripToggleBtn.Text = "TRIPPED!"
    
    task.delay(0.5, function()
        if TripToggleBtn then
            TripToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            TripToggleBtn.Text = "TRIP (CLICK)"
        end
    end)

    local currentVelocity = root.AssemblyLinearVelocity
    local speed = currentVelocity.Magnitude

    humanoid.PlatformStand = true
    humanoid.AutoRotate = false

    local impulso = (speed > 5) and (currentVelocity * 1.3) or (root.CFrame.LookVector * 10)
    root.AssemblyLinearVelocity = impulso + Vector3.new(0, 8, 0)
    
    local spin = speed > 5 and 20 or 10
    root.AssemblyAngularVelocity = Vector3.new(math.random(-spin, spin), math.random(-spin, spin), math.random(-spin, spin))

    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.1, 0.1, 1, 1)
        end
    end
end

local function GetUpFromTrip()
    if not isTripped then return end
    isTripped = false
    
    local char = LocalPlayer.Character; if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    humanoid.PlatformStand = false
    humanoid.AutoRotate = true
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    
    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = nil 
        end
    end
end

TripToggleBtn.MouseButton1Click:Connect(DoTrip)

TripKeyBtn.MouseButton1Click:Connect(function()
    if tripKeybind ~= nil then tripKeybind = nil; TripKeyBtn.Text = "KEY"; TripKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isTripBinding = false
    else isTripBinding = true; TripKeyBtn.Text = "..."; TripKeyBtn.BackgroundColor3 = tOrange end
end)


-- ==================================================================
-- 9. CHAT GLOBAL SMART SCROLL
-- ==================================================================
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local setclipboard = setclipboard or toclipboard or set_clipboard

local ChatMain = Instance.new("Frame", ScreenGui)
ChatMain.Size = UDim2.new(0, 380, 0, 270); ChatMain.Position = UDim2.new(0.5, -190, 1, -300); ChatMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); ChatMain.BorderSizePixel = 0; ChatMain.ClipsDescendants = true; ChatMain.Visible = false
Instance.new("UICorner", ChatMain).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", ChatMain).Color = borderDark
ApplyResponsiveScale(ChatMain)

local ChatTopBar = Instance.new("Frame", ChatMain); ChatTopBar.Size = UDim2.new(1, 0, 0, 35); ChatTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); ChatTopBar.BorderSizePixel = 0; Instance.new("UICorner", ChatTopBar).CornerRadius = UDim.new(0, 6)
local ChatFix = Instance.new("Frame", ChatTopBar); ChatFix.Size = UDim2.new(1, 0, 0, 5); ChatFix.Position = UDim2.new(0, 0, 1, -5); ChatFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); ChatFix.BorderSizePixel = 0
local ChatTitle = Instance.new("TextLabel", ChatTopBar); ChatTitle.Size = UDim2.new(1, -70, 1, 0); ChatTitle.Position = UDim2.new(0, 15, 0, 0); ChatTitle.BackgroundTransparency = 1; ChatTitle.Text = "GLOBAL CHAT"; ChatTitle.TextColor3 = tWhite; ChatTitle.Font = Enum.Font.GothamBold; ChatTitle.TextSize = 13; ChatTitle.TextXAlignment = Enum.TextXAlignment.Left
local ChatMinBtn = Instance.new("TextButton", ChatTopBar); ChatMinBtn.Size = UDim2.new(0, 35, 1, 0); ChatMinBtn.Position = UDim2.new(1, -70, 0, 0); ChatMinBtn.BackgroundTransparency = 1; ChatMinBtn.Text = "—"; ChatMinBtn.TextColor3 = tGreen; ChatMinBtn.Font = Enum.Font.GothamBlack; ChatMinBtn.TextSize = 14
local ChatCloseBtn = Instance.new("TextButton", ChatTopBar); ChatCloseBtn.Size = UDim2.new(0, 35, 1, 0); ChatCloseBtn.Position = UDim2.new(1, -35, 0, 0); ChatCloseBtn.BackgroundTransparency = 1; ChatCloseBtn.Text = "X"; ChatCloseBtn.TextColor3 = tRed; ChatCloseBtn.Font = Enum.Font.GothamBlack; ChatCloseBtn.TextSize = 12

local ChatScroll = Instance.new("ScrollingFrame", ChatMain); ChatScroll.Position = UDim2.new(0, 5, 0, 45); ChatScroll.Size = UDim2.new(1, -10, 0, 175); ChatScroll.BackgroundTransparency = 1; ChatScroll.ScrollBarThickness = 2; ChatScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
local ChatLayout = Instance.new("UIListLayout", ChatScroll); ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder; ChatLayout.Padding = UDim.new(0, 4)

local NewMsgBtn = Instance.new("TextButton", ChatMain); NewMsgBtn.Name = "NewMsgBtn"; NewMsgBtn.Text = "⬇ Nuevos Mensajes"; NewMsgBtn.Size = UDim2.new(0, 150, 0, 25); NewMsgBtn.Position = UDim2.new(0.5, -75, 1, -70); NewMsgBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22); NewMsgBtn.TextColor3 = tYellow; NewMsgBtn.Font = Enum.Font.GothamBold; NewMsgBtn.Visible = false; NewMsgBtn.ZIndex = 5; NewMsgBtn.TextSize = 12; Instance.new("UICorner", NewMsgBtn).CornerRadius = UDim.new(1, 0); Instance.new("UIStroke", NewMsgBtn).Color = borderDark

local ChatBox = Instance.new("TextBox", ChatMain); ChatBox.Position = UDim2.new(0, 5, 1, -40); ChatBox.Size = UDim2.new(0.68, 0, 0, 35); ChatBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10); ChatBox.TextColor3 = tWhite; ChatBox.Text = ""; ChatBox.PlaceholderText = "Escribe un mensaje..."; ChatBox.Font = Enum.Font.Gotham; ChatBox.TextSize = 13; ChatBox.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", ChatBox).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", ChatBox).Color = Color3.fromRGB(40, 40, 40); Instance.new("UIPadding", ChatBox).PaddingLeft = UDim.new(0, 10)
local ChatSendBtn = Instance.new("TextButton", ChatMain); ChatSendBtn.Position = UDim2.new(0.71, 0, 1, -40); ChatSendBtn.Size = UDim2.new(0.27, 0, 0, 35); ChatSendBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22); ChatSendBtn.TextColor3 = tGreen; ChatSendBtn.Text = "ENVIAR"; ChatSendBtn.Font = Enum.Font.GothamBold; ChatSendBtn.TextSize = 12; Instance.new("UICorner", ChatSendBtn).CornerRadius = UDim.new(0, 4)

MakeDraggable(ChatTopBar, ChatMain)

local chatMinimized = false
ChatMinBtn.MouseButton1Click:Connect(function()
    chatMinimized = not chatMinimized
    TweenService:Create(ChatMain, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = chatMinimized and UDim2.new(0, 380, 0, 35) or UDim2.new(0, 380, 0, 270)}):Play()
    ChatMinBtn.Text = chatMinimized and "+" or "—"; ChatFix.Visible = not chatMinimized
    if chatMinimized then NewMsgBtn.Visible = false end
end)
ChatCloseBtn.MouseButton1Click:Connect(function() ChatMain.Visible = false end)

local function GetUserColor(username)
    local hash = 0; for i = 1, #username do hash = hash + string.byte(username, i) end; math.randomseed(hash); local r = math.random(100, 255); local g = math.random(100, 255); local b = math.random(100, 255); math.randomseed(tick())
    return Color3.fromRGB(r, g, b)
end

local function OpenProfile(username)
    pcall(function()
        local id = Players:GetUserIdFromNameAsync(username)
        if id and setclipboard then setclipboard("https://www.roblox.com/users/"..id.."/profile"); StarterGui:SetCore("SendNotification", {Title="Perfil", Text="Link copiado.", Duration=2}) end
    end)
end

local function CrearFilaMensaje(usuario, mensaje)
    local Row = Instance.new("Frame", ChatScroll); Row.Size = UDim2.new(1, 0, 0, 0); Row.AutomaticSize = Enum.AutomaticSize.Y; Row.BackgroundTransparency = 1
    local RowLayout = Instance.new("UIListLayout", Row); RowLayout.FillDirection = Enum.FillDirection.Horizontal; RowLayout.VerticalAlignment = Enum.VerticalAlignment.Center; RowLayout.Padding = UDim.new(0, 6)
    local pad = Instance.new("Frame", Row); pad.BackgroundTransparency = 1; pad.Size = UDim2.new(0, 2, 0, 20)

    local NameBtn = Instance.new("TextButton", Row); NameBtn.Text = usuario .. ":"; NameBtn.TextColor3 = GetUserColor(usuario); NameBtn.BackgroundTransparency = 1; NameBtn.Font = Enum.Font.GothamBold; NameBtn.TextSize = 13; NameBtn.AutomaticSize = Enum.AutomaticSize.XY
    NameBtn.MouseButton1Click:Connect(function() pcall(function() local id = Players:GetUserIdFromNameAsync(usuario); if id and setclipboard then setclipboard("https://www.roblox.com/users/"..id.."/profile"); StarterGui:SetCore("SendNotification", {Title="Perfil", Text="Link copiado al portapapeles.", Duration=2}) end end) end)

    local MsgLbl = Instance.new("TextLabel", Row); MsgLbl.Text = mensaje; MsgLbl.TextColor3 = tWhite; MsgLbl.BackgroundTransparency = 1; MsgLbl.Font = Enum.Font.Gotham; MsgLbl.TextSize = 13; MsgLbl.TextXAlignment = Enum.TextXAlignment.Left; MsgLbl.TextWrapped = true; MsgLbl.AutomaticSize = Enum.AutomaticSize.XY; MsgLbl.Size = UDim2.new(0, 0, 0, 0)
    if mensaje:lower():find("http") or mensaje:lower():find("www") then MsgLbl.TextColor3 = tCyan end

    local CopyBtn = Instance.new("TextButton", Row); CopyBtn.Text = "📋"; CopyBtn.BackgroundTransparency = 1; CopyBtn.Size = UDim2.new(0, 20, 0, 20); CopyBtn.TextSize = 13; CopyBtn.TextColor3 = tYellow
    CopyBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard(mensaje); CopyBtn.Text = "✔️"; CopyBtn.TextColor3 = tGreen; task.wait(1); CopyBtn.Text = "📋"; CopyBtn.TextColor3 = tYellow end end)
end

local isUpdatingChat = false; local lastMsgCount = 0; local forceScrollBottom = false
NewMsgBtn.MouseButton1Click:Connect(function() TweenService:Create(ChatScroll, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CanvasPosition = Vector2.new(0, ChatScroll.CanvasSize.Y.Offset)}):Play(); NewMsgBtn.Visible = false end)

ChatScroll.Changed:Connect(function(prop)
    if prop == "CanvasPosition" or prop == "CanvasSize" then
        local maxScroll = math.max(0, ChatScroll.CanvasSize.Y.Offset - ChatScroll.AbsoluteWindowSize.Y)
        if (maxScroll - ChatScroll.CanvasPosition.Y) <= 40 then NewMsgBtn.Visible = false end
    end
end)

local function ActualizarChat()
    if isUpdatingChat or not request then return end
    isUpdatingChat = true
    local s, r = pcall(function() return request({Url = URL_NGROK .. "/leer", Method = "GET", Headers = {["ngrok-skip-browser-warning"] = "true"}}) end)

    if s and r and r.StatusCode == 200 then
        local valid, data = pcall(function() return HttpService:JSONDecode(r.Body) end)
        if valid and data then
            local hayNuevos = #data > lastMsgCount
            local maxScroll = math.max(0, ChatScroll.CanvasSize.Y.Offset - ChatScroll.AbsoluteWindowSize.Y); local currentScroll = ChatScroll.CanvasPosition.Y; local wasAtBottom = (maxScroll - currentScroll) <= 40
            if lastMsgCount == 0 or forceScrollBottom then wasAtBottom = true; forceScrollBottom = false end

            if hayNuevos then
                for _, v in pairs(ChatScroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
                for _, m in pairs(data) do CrearFilaMensaje(m.u, m.m) end
                task.defer(function()
                    ChatScroll.CanvasSize = UDim2.new(0, 0, 0, ChatLayout.AbsoluteContentSize.Y)
                    if wasAtBottom then ChatScroll.CanvasPosition = Vector2.new(0, ChatScroll.CanvasSize.Y.Offset); NewMsgBtn.Visible = false
                    else NewMsgBtn.Visible = true end
                end)
            end
            lastMsgCount = #data
        end
    end
    isUpdatingChat = false
end

local sending = false
local function SendMessage()
    if sending or ChatBox.Text == "" or not request then return end
    sending = true; local txt = ChatBox.Text; ChatBox.Text = "" 
    local payload = HttpService:JSONEncode({usuario = LocalPlayer.Name, texto = txt})
    task.spawn(function()
        local s, r = pcall(function() request({Url = URL_NGROK .. "/enviar", Method = "POST", Headers = {["Content-Type"]="application/json", ["ngrok-skip-browser-warning"]="true"}, Body = payload}) end)
        sending = false; if s then forceScrollBottom = true; ActualizarChat() else ChatBox.Text = txt end
    end)
end

ChatSendBtn.MouseButton1Click:Connect(SendMessage); ChatBox.FocusLost:Connect(function(enter) if enter then SendMessage() end end)
task.spawn(function() while task.wait(2) do if ChatMain.Visible and not chatMinimized then ActualizarChat() end end end)

-- ==================================================================
-- 10. SISTEMA GLOBAL DE TECLAS Y COMANDOS (CON AUTOCOMPLETADO)
-- ==================================================================
local function LogMessage(text, color)
    local lbl = Instance.new("TextLabel", Console)
    lbl.Size = UDim2.new(1, 0, 0, 20); lbl.BackgroundTransparency = 1; lbl.Text = "  " .. text; lbl.TextColor3 = color or tWhite; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextWrapped = true
    Console.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
    Console.CanvasPosition = Vector2.new(0, Console.CanvasSize.Y.Offset)
end
LogMessage("Terminal C.D.T Optifine cargada.", tGreen)

-- Detectar Respawn para apagar módulos y restaurar físicas
LocalPlayer.CharacterAdded:Connect(function() 
    if isGhostActive then ToggleGhost() end
    if isFlying then ToggleFly() end
    if isNoclipActive then ToggleNoclipWalk() end
    isTripped = false
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if isInvBinding and input.UserInputType == Enum.UserInputType.Keyboard then invKeybind = input.KeyCode; InvKeyBtn.Text = input.KeyCode.Name; InvKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isInvBinding = false; return end
    if isFlyBinding and input.UserInputType == Enum.UserInputType.Keyboard then flyKeybind = input.KeyCode; FlyKeyBtn.Text = input.KeyCode.Name; FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isFlyBinding = false; return end
    if isVFlyBinding and input.UserInputType == Enum.UserInputType.Keyboard then vFlyKeybind = input.KeyCode; VFlyKeyBtn.Text = input.KeyCode.Name; VFlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isVFlyBinding = false; return end
    if isNoclipBinding and input.UserInputType == Enum.UserInputType.Keyboard then noclipKeybind = input.KeyCode; NoclipKeyBtn.Text = input.KeyCode.Name; NoclipKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isNoclipBinding = false; return end
    if isTripBinding and input.UserInputType == Enum.UserInputType.Keyboard then tripKeybind = input.KeyCode; TripKeyBtn.Text = input.KeyCode.Name; TripKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isTripBinding = false; return end
    
    if not gp then
        if input.KeyCode == Enum.KeyCode.Insert then ToggleMenu() end
        
        if invKeybind and input.KeyCode == invKeybind then ToggleGhost() end
        if flyKeybind and input.KeyCode == flyKeybind then ToggleFly() end
        if vFlyKeybind and input.KeyCode == vFlyKeybind then ToggleVFly() end
        if noclipKeybind and input.KeyCode == noclipKeybind then ToggleNoclipWalk() end
        
        if tripKeybind and input.KeyCode == tripKeybind then DoTrip() end
        if isTripped and input.KeyCode == Enum.KeyCode.Space then GetUpFromTrip() end
        
        if isFlying then
            if input.KeyCode == Enum.KeyCode.W then flycontrol.F = 1
            elseif input.KeyCode == Enum.KeyCode.S then flycontrol.B = 1
            elseif input.KeyCode == Enum.KeyCode.D then flycontrol.R = 1
            elseif input.KeyCode == Enum.KeyCode.A then flycontrol.L = 1
            elseif input.KeyCode == Enum.KeyCode.Space then flycontrol.U = 1
            elseif input.KeyCode == Enum.KeyCode.Q then flycontrol.D = 1 end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if not gp then
        if isFlying then
            if input.KeyCode == Enum.KeyCode.W then flycontrol.F = 0
            elseif input.KeyCode == Enum.KeyCode.S then flycontrol.B = 0
            elseif input.KeyCode == Enum.KeyCode.D then flycontrol.R = 0
            elseif input.KeyCode == Enum.KeyCode.A then flycontrol.L = 0
            elseif input.KeyCode == Enum.KeyCode.Space then flycontrol.U = 0
            elseif input.KeyCode == Enum.KeyCode.Q then flycontrol.D = 0 end
        end
    end
end)

local function GetPlayer(nameString)
    nameString = string.lower(nameString)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then if string.lower(string.sub(p.Name, 1, #nameString)) == nameString or string.lower(string.sub(p.DisplayName, 1, #nameString)) == nameString then return p end end
    end
    return nil
end

local Comandos = {}
local function AddCmd(cmd, desc, action) Comandos[cmd] = {Desc = desc, Accion = action} end

AddCmd("cmds", "Lista de comandos", function() LogMessage("--- COMANDOS DISPONIBLES ---", tYellow); for c, info in pairs(Comandos) do LogMessage(c .. " : " .. info.Desc, tCyan) end end)
AddCmd("to", "TP a jugador (Ej: to juan)", function(args)
    if args[1] then
        local target = GetPlayer(args[1])
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3); LogMessage("Teletransportado a " .. target.DisplayName, tPurple)
        else LogMessage("Jugador no encontrado.", tRed) end
    end
end)
AddCmd("mp", "Abre la lista de Puntos de Mapa", function() MPInput.Text = ""; RefreshMPList(); MPMain.Visible = true; LogMessage("Map Points abierto.", tPurple) end)
AddCmd("tpmenu", "Abre la lista de TP visual", function() TPSearchBox.Text = ""; RefreshTPMenu(); TPMain.Visible = true; LogMessage("TP Menu abierto.", tOrange) end)
AddCmd("invisible", "Abre el panel de Invisibilidad", function() InvMain.Visible = true; LogMessage("Menú Invisible abierto.", tPurple) end)
AddCmd("fly", "Abre el panel de Vuelo Noclip", function() FlyMain.Visible = true; LogMessage("Menú de Vuelo abierto.", tYellow) end)
AddCmd("vfly", "Abre el panel de Vehicle Fly", function() VFlyMain.Visible = true; LogMessage("Menú de Vehicle Fly abierto.", tPurple) end)
AddCmd("noclip", "Abre el panel de Noclip Walk", function() NoclipMain.Visible = true; LogMessage("Menú de Noclip Walk abierto.", tCyan) end)
AddCmd("trip", "Abre el panel de Trip Mode", function() TripMain.Visible = true; LogMessage("Menú Trip abierto.", tGreen) end)
AddCmd("chat", "Abre el chat global", function() ChatMain.Visible = true; ActualizarChat(); LogMessage("Chat Global conectado.", tGreen) end)
AddCmd("speed", "Cambia la velocidad", function(args)
    if args[1] and tonumber(args[1]) then LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(args[1]); LogMessage("Velocidad -> " .. args[1], tGreen) end
end)
AddCmd("destroy", "Cierra y elimina el panel completo", function()
    if isGhostActive then ToggleGhost() end; if isFlying then ToggleFly() end; if isVFlying then ToggleVFly() end; if isNoclipActive then ToggleNoclipWalk() end; if isTripped then GetUpFromTrip() end
    LogMessage("Cerrando C.D.T Optifine...", tPurple); task.wait(0.5); ScreenGui:Destroy()
end)

local SuggestFrame = Instance.new("ScrollingFrame", FullUI); SuggestFrame.Size = UDim2.new(1, -20, 0, 0); SuggestFrame.Position = UDim2.new(0, 10, 1, -45); SuggestFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); SuggestFrame.BorderSizePixel = 0; SuggestFrame.Visible = false; SuggestFrame.ScrollBarThickness = 2; SuggestFrame.ZIndex = 10; Instance.new("UICorner", SuggestFrame).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", SuggestFrame).Color = Color3.fromRGB(50, 50, 50)
local SuggestList = Instance.new("UIListLayout", SuggestFrame); SuggestList.Padding = UDim.new(0, 2)

local function UpdateSuggestions()
    local text = string.lower(CmdBox.Text); for _, child in pairs(SuggestFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    if text == "" then SuggestFrame.Visible = false return end
    local args = string.split(text, " "); local currentCmd = args[1]; local suggestions = {}

    if #args == 1 then
        for cmd, info in pairs(Comandos) do if string.sub(cmd, 1, #currentCmd) == currentCmd then table.insert(suggestions, {Display = cmd .. " - " .. info.Desc, Fill = cmd .. " "}) end end
    elseif #args == 2 and (currentCmd == "to") then
        local currentArg = args[2]
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local pName = string.lower(p.Name); local dName = string.lower(p.DisplayName)
                if string.sub(pName, 1, #currentArg) == currentArg or string.sub(dName, 1, #currentArg) == currentArg then table.insert(suggestions, {Display = p.DisplayName .. " (@" .. p.Name .. ")", Fill = currentCmd .. " " .. p.Name}) end
            end
        end
    end

    if #suggestions > 0 then
        SuggestFrame.Visible = true; local ySize = 0
        for _, sug in ipairs(suggestions) do
            local btn = Instance.new("TextButton", SuggestFrame); btn.Size = UDim2.new(1, -5, 0, 22); btn.BackgroundTransparency = 1; btn.Text = "  " .. sug.Display; btn.TextColor3 = tWhite; btn.Font = Enum.Font.Gotham; btn.TextSize = 13; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.ZIndex = 11; btn:SetAttribute("Fill", sug.Fill)
            btn.MouseEnter:Connect(function() btn.TextColor3 = tPurple end); btn.MouseLeave:Connect(function() btn.TextColor3 = tWhite end); btn.MouseButton1Click:Connect(function() CmdBox.Text = sug.Fill; CmdBox:CaptureFocus(); SuggestFrame.Visible = false end)
            ySize = ySize + 24
        end
        local frameHeight = math.min(ySize, 100); SuggestFrame.CanvasSize = UDim2.new(0, 0, 0, ySize); SuggestFrame.Size = UDim2.new(1, -20, 0, frameHeight); SuggestFrame.Position = UDim2.new(0, 10, 1, -45 - frameHeight - 5)
    else
        SuggestFrame.Visible = false
    end
end

CmdBox:GetPropertyChangedSignal("Text"):Connect(UpdateSuggestions)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Tab and CmdBox:IsFocused() and SuggestFrame.Visible then
        for _, child in ipairs(SuggestFrame:GetChildren()) do if child:IsA("TextButton") then local fill = child:GetAttribute("Fill"); if fill then task.defer(function() CmdBox.Text = fill; CmdBox:CaptureFocus(); CmdBox.CursorPosition = #fill + 1 end); SuggestFrame.Visible = false break end end end
    end
end)
CmdBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and CmdBox.Text ~= "" then
        local input = string.lower(CmdBox.Text); CmdBox.Text = ""; SuggestFrame.Visible = false; LogMessage("> " .. input, tWhite)
        local split = string.split(input, " "); local cmd = split[1]; table.remove(split, 1)
        if Comandos[cmd] then pcall(function() Comandos[cmd].Accion(split) end) else LogMessage("Error: Comando desconocido.", tOrange) end
    end
end)
