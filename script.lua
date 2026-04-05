--[[
    C.D.T OPTIFINE - V10.9 PROJECT SAFE (MASTER EDITION)
    - Trip Mode Inteligente (Anti Shift-Lock Bug).
    - Inyección Segura (Bulletproof) y Responsive UI.
    - TP Menu & Map Points (Buscador dinámico).
    - Menú Invisible (SEAT MODE PERFECTO + KEYBIND).
    - Menú de Vuelo Normal & VEHICLE FLY (Lerp Suave).
    - REVERSE MODE (Flashback System).
    - FREECAM MODE (Shift-Lock Native Override).
    - ESP SYSTEM (Highlights + Team Check).
    - SPINBOT (Angular Velocity + Keybind Fix + Comando spinstup).
    - WALK ON AIR (Generación dinámica + Keybind).
    - GLOBAL CHAT SMART (Auto-Scroll).
    - Comandos: clear, afk, hop, rejoin, tptool, infbase, generacion, air, spinstup, destroy.
    - Panel de Ajustes (⚙) con Temas Consistentes.
    - SISTEMA DE KEY, HWID Y AUTO-ACTUALIZACIÓN.
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
local Lighting = game:GetService("Lighting")
local TextService = game:GetService("TextService")
local RbxAnalytics = game:GetService("RbxAnalyticsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

repeat task.wait() until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local posicionGuardadaRE = nil
local DestruirScriptCompleto
local ScriptIsDead = false -- Bandera de kill switch global

-- ==================================================================
-- VARIABLES GLOBALES (API)
-- ==================================================================
local BASE_URL = "http://185.249.196.246:3000"
local API_URL = BASE_URL .. "/api/nametags"
local scriptActivoTags = true
local verMiTag = true
local UIsActivos = {} 
local tagsDescargados = {}
local hiddenTags = {} 
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local _GlobalUpdateTimestamp = 0
local CurrentExpirationText = "Cargando..."

local AuthFileName = "SAFE_DEV_KEY.json"

local tPurple = Color3.fromRGB(170, 85, 255)
local tWhite = Color3.fromRGB(255, 255, 255)
local tGreen = Color3.fromRGB(0, 255, 136)
local tOrange = Color3.fromRGB(255, 150, 0)
local tCyan = Color3.fromRGB(0, 200, 255)
local tYellow = Color3.fromRGB(255, 220, 0)
local tRed = Color3.fromRGB(255, 60, 60)
local borderDark = Color3.fromRGB(45, 45, 45)

local URL_NGROK = "https://garnett-waterborne-overoffensively.ngrok-free.dev" 

local GlobalConnections = {} -- Almacenará conexiones críticas para limpiarlas

local function ApplyResponsiveScale(frame)
    local scaleObj = Instance.new("UIScale", frame)
    local function UpdateScale()
        local vs = Workspace.CurrentCamera.ViewportSize
        if vs.X < 850 then scaleObj.Scale = 1.15 else scaleObj.Scale = 1.05 end
    end
    table.insert(GlobalConnections, Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale))
    UpdateScale()
end

local function MakeDraggable(dragArea, targetFrame)
    local dragging, dragInput, dragStart, startPos
    table.insert(GlobalConnections, dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = targetFrame.Position end
    end))
    table.insert(GlobalConnections, dragArea.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end))
    table.insert(GlobalConnections, UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end))
    table.insert(GlobalConnections, UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
end

local targetGuiParent = nil
pcall(function() targetGuiParent = gethui() end)
if not targetGuiParent then pcall(function() targetGuiParent = CoreGui end) end
if not targetGuiParent then targetGuiParent = LocalPlayer:WaitForChild("PlayerGui") end

if targetGuiParent:FindFirstChild("CDT_Optifine_Fluid") then targetGuiParent:FindFirstChild("CDT_Optifine_Fluid"):Destroy() end
if _G.DestruirTags then pcall(function() _G.DestruirTags() end) end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CDT_Optifine_Fluid"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false 
ScreenGui.Parent = targetGuiParent

local function AutoRestartScript()
    if DestruirScriptCompleto then DestruirScriptCompleto() end
    StarterGui:SetCore("SendNotification", { Title="SAFE DEV", Text="El servidor ha forzado una actualización Global. Por favor, reinyecta el script.", Duration=10 })
end

-- ==================================================================
-- SISTEMA NAME TAGS E INVISIBILIDAD LOCAL DE JUGADORES + VOICE MUTE
-- ==================================================================
local function OcultarAvatar(character, ocultar)
    if not character then return end
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then obj.Transparency = ocultar and 1 or 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = ocultar and 1 or 0
        elseif obj:IsA("Sound") or obj:IsA("AudioEmitter") or string.match(obj.ClassName, "Voice") then
            pcall(function()
                if ocultar then
                    if not obj:GetAttribute("OldVol") then obj:SetAttribute("OldVol", obj.Volume) end
                    obj.Volume = 0
                else
                    if obj:GetAttribute("OldVol") then obj.Volume = obj:GetAttribute("OldVol") end
                end
            end)
        end
    end
end

local function MutearVoiceChat(player, ocultar)
    pcall(function()
        local audioInput = player:FindFirstChild("AudioDeviceInput")
        if audioInput then audioInput.Muted = ocultar end
    end)
end

task.spawn(function()
    while scriptActivoTags and not ScriptIsDead do
        local successPing, resPing = pcall(function()
            return request({ Url = BASE_URL .. "/api/ping/" .. tostring(LocalPlayer.UserId), Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = "{}" })
        end)
        
        if successPing and resPing and resPing.StatusCode == 200 then
            local sDecode, dat = pcall(function() return HttpService:JSONDecode(resPing.Body) end)
            if sDecode and dat and dat.updateTime then
                if _GlobalUpdateTimestamp == 0 then _GlobalUpdateTimestamp = dat.updateTime
                elseif dat.updateTime > _GlobalUpdateTimestamp then scriptActivoTags = false; AutoRestartScript() end
            end
        end
        task.wait(4)
    end
end)

local function parseHexTag(hexStr, defaultHex)
    if not hexStr or hexStr == "" then return Color3.fromHex(defaultHex) end
    if hexStr:sub(1,1) ~= "#" then hexStr = "#" .. hexStr end
    local success, color = pcall(function() return Color3.fromHex(hexStr) end)
    return success and color or Color3.fromHex(defaultHex)
end

local function obtenerImagenTag(url, userId)
    if not url or url == "" or url == "default" then return Players:GetUserThumbnailAsync(tonumber(userId), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end
    if url:find("rbxassetid://") then return url end
    if tagsDescargados[userId] and tagsDescargados[userId].url == url then return tagsDescargados[userId].asset end
    
    local nombreArchivo = "RF_Logo_" .. tostring(userId) .. "_" .. tostring(math.random(1000, 99999)) .. ".png"
    local s, r = pcall(function() return request({Url = url, Method = "GET"}) end)
    if s and r.StatusCode == 200 then
        writefile(nombreArchivo, r.Body)
        local assetId = getcustomasset(nombreArchivo)
        tagsDescargados[userId] = {url = url, asset = assetId}
        return assetId
    end
    return Players:GetUserThumbnailAsync(tonumber(userId), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
end

local function crearNieveTag(container, emojiText, colorNieveHex)
    local listaCopos = {}
    for i = 1, 6 do
        local snow = Instance.new("TextLabel", container)
        snow.BackgroundTransparency = 1; snow.Text = emojiText or "*"; snow.Font = Enum.Font.GothamBlack 
        snow.TextColor3 = parseHexTag(colorNieveHex, "#ffffff"); snow.TextTransparency = 0.4; snow.TextSize = math.random(16, 24) 
        snow.Position = UDim2.new(math.random(5, 95)/100, 0, -0.3, 0); snow.ZIndex = 2
        table.insert(listaCopos, snow)

        local speed = math.random(30, 50) / 10; local delay = math.random(0, 20) / 10
        task.spawn(function()
            task.wait(delay)
            while scriptActivoTags and container and container.Parent and snow and snow.Parent do
                snow.Position = UDim2.new(math.random(5, 95)/100, 0, -0.3, 0)
                local tween = TweenService:Create(snow, TweenInfo.new(speed, Enum.EasingStyle.Linear), {Position = UDim2.new(snow.Position.X.Scale, 0, 1.3, 0)})
                tween:Play(); tween.Completed:Wait()
            end
        end)
    end
    return listaCopos
end

local function actualizarAnimacionNombreTag(uiData, cfg)
    if cfg.animarNombre then
        if not uiData.animNameTask then
            uiData.animNameTask = true
            task.spawn(function()
                while uiData.animNameTask and uiData.TxtName and uiData.TxtName.Parent and not ScriptIsDead do
                    local t1 = TweenService:Create(uiData.TxtName, TweenInfo.new(1), {TextColor3 = Color3.fromHex("#60a5fa")})
                    t1:Play() t1.Completed:Wait()
                    if not uiData.animNameTask or ScriptIsDead then break end
                    local t2 = TweenService:Create(uiData.TxtName, TweenInfo.new(1), {TextColor3 = Color3.fromHex("#c084fc")})
                    t2:Play() t2.Completed:Wait()
                    if not uiData.animNameTask or ScriptIsDead then break end
                    local t3 = TweenService:Create(uiData.TxtName, TweenInfo.new(1), {TextColor3 = Color3.new(1,1,1)})
                    t3:Play() t3.Completed:Wait()
                end
            end)
        end
    else
        uiData.animNameTask = false; if uiData.TxtName then uiData.TxtName.TextColor3 = Color3.new(1,1,1) end
    end
end

local function crearUITag(player, datos, userId)
    local head = player.Character and player.Character:FindFirstChild("Head"); if not head then return end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid"); if humanoid then humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end

    local nombreUI = "SafeHTML_" .. userId
    if targetGuiParent:FindFirstChild(nombreUI) then targetGuiParent[nombreUI]:Destroy() end

    local tTit = datos.titulo or "USER"; local tNom = player.Name:upper()
    local sF, fU = pcall(function() return Enum.Font[datos.fuente] end); if not sF or not fU then fU = Enum.Font.GothamBold end
    
    local bT = TextService:GetTextSize(tTit, 14, fU, Vector2.new(1000, 40)); 
    local bN = TextService:GetTextSize(tNom, 12, Enum.Font.GothamBold, Vector2.new(1000, 40))
    local aI = 5 + 30 + 8 + math.max(bT.X, bN.X) + 12; if aI < 100 then aI = 100 end 

    local bill = Instance.new("BillboardGui", targetGuiParent)
    bill.Name = nombreUI; bill.Adornee = head; bill.Size = UDim2.new(0, aI, 0, 40); bill.StudsOffset = Vector3.new(0, 1.8, 0); bill.AlwaysOnTop = true; bill.MaxDistance = math.huge; bill.ResetOnSpawn = false; bill.Active = true 
    local scale = Instance.new("UIScale", bill); scale.Scale = 1
    
    local card = Instance.new("Frame", bill); card.Size = UDim2.new(0, aI, 0, 40); card.AnchorPoint = Vector2.new(0.5, 0.5); card.Position = UDim2.new(0.5, 0, 0.5, 0); card.BackgroundColor3 = Color3.new(1, 1, 1) 
    local corner = Instance.new("UICorner", card); corner.CornerRadius = UDim.new(0, 6)
    local grad = Instance.new("UIGradient", card); grad.Rotation = 45; grad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, parseHexTag(datos.colorFondo1, "#1c1c24")), ColorSequenceKeypoint.new(1, parseHexTag(datos.colorFondo2, "#0f0f13")) })
    
    local stroke = Instance.new("UIStroke", card); stroke.Color = Color3.new(1,1,1); stroke.Transparency = 0.2; stroke.Thickness = 2.5
    local strokeGrad = Instance.new("UIGradient", stroke); strokeGrad.Rotation = 45; strokeGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, parseHexTag(datos.colorBorde1 or datos.colorBorde, "#FFFFFF")), ColorSequenceKeypoint.new(1, parseHexTag(datos.colorBorde2 or datos.colorBorde, "#FFFFFF")) })
    
    local snowCont = Instance.new("Frame", card); snowCont.Size = UDim2.new(1,0,1,0); snowCont.BackgroundTransparency = 1; snowCont.ClipsDescendants = true; Instance.new("UICorner", snowCont).CornerRadius = UDim.new(0,6)
    local listaCopos = crearNieveTag(snowCont, datos.emojiNieve, datos.colorNieve or "#ffffff")

    local avF = Instance.new("Frame", card); avF.Size = UDim2.new(0, 30, 0, 30); avF.AnchorPoint = Vector2.new(0, 0.5); avF.Position = UDim2.new(0, 5, 0.5, 0); avF.BackgroundTransparency = 1; Instance.new("UICorner", avF).CornerRadius = UDim.new(1, 0)

    local avatarImg = Instance.new("ImageLabel", avF); avatarImg.Size = UDim2.new(1, 0, 1, 0); avatarImg.BackgroundTransparency = 1
    task.spawn(function() local img = obtenerImagenTag(datos.imagen, userId); if avatarImg and avatarImg.Parent then avatarImg.Image = img end end)
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)

    local infoGroup = Instance.new("Frame", card); infoGroup.Size = UDim2.new(1, -43, 0, 30); infoGroup.AnchorPoint = Vector2.new(0, 0.5); infoGroup.Position = UDim2.new(0, 43, 0.5, 0); infoGroup.BackgroundTransparency = 1

    local txtTitle = Instance.new("TextLabel", infoGroup)
    txtTitle.BackgroundTransparency = 1; txtTitle.Size = UDim2.new(1, 0, 0, 15); txtTitle.Position = UDim2.new(0, 0, 0, 0)
    txtTitle.Font = fU; txtTitle.Text = tTit; txtTitle.TextColor3 = Color3.new(1,1,1); txtTitle.TextSize = 14; txtTitle.TextXAlignment = Enum.TextXAlignment.Left; txtTitle.TextYAlignment = Enum.TextYAlignment.Center
    local titleGrad = Instance.new("UIGradient", txtTitle); titleGrad.Rotation = 45; titleGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, parseHexTag(datos.colorTitulo1 or datos.colorTitulo, "#ffffff")), ColorSequenceKeypoint.new(1, parseHexTag(datos.colorTitulo2 or datos.colorTitulo, "#ffffff")) })

    local txtName = Instance.new("TextLabel", infoGroup)
    txtName.BackgroundTransparency = 1; txtName.Size = UDim2.new(1, 0, 0, 13); txtName.Position = UDim2.new(0, 0, 0, 15)
    txtName.Font = Enum.Font.GothamBold; txtName.Text = tNom; txtName.TextColor3 = Color3.new(1,1,1); txtName.TextSize = 12; txtName.TextXAlignment = Enum.TextXAlignment.Left; txtName.TextYAlignment = Enum.TextYAlignment.Center
    local nameGrad = Instance.new("UIGradient", txtName); nameGrad.Rotation = 45; nameGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, parseHexTag(datos.colorNombre1 or datos.colorNombre, "#a0a0b0")), ColorSequenceKeypoint.new(1, parseHexTag(datos.colorNombre2 or datos.colorNombre, "#a0a0b0")) })
    
    local btnTP = Instance.new("TextButton", card); btnTP.Size = UDim2.new(1, 0, 1, 0); btnTP.BackgroundTransparency = 1; btnTP.Text = ""; btnTP.ZIndex = 100
    btnTP.MouseButton1Click:Connect(function()
        if player.Character and LocalPlayer.Character and player ~= LocalPlayer then
            local target = player.Character:FindFirstChild("HumanoidRootPart"); local me = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if target and me then local flash = Instance.new("ColorCorrectionEffect", Lighting); flash.Brightness = 1; TweenService:Create(flash, TweenInfo.new(0.3), {Brightness = 0}):Play(); game.Debris:AddItem(flash, 0.4); me.CFrame = target.CFrame * CFrame.new(0, 0, 3) end
        end
    end)

    UIsActivos[userId] = { Estado = "Abierto", UI = bill, Escalador = scale, Head = head, Card = card, CardCorner = corner, CardStroke = stroke, Gradiente = grad, Avatar = avF, AvatarImg = avatarImg, TxtTitle = txtTitle, TxtName = txtName, SnowContainer = snowCont, Copos = listaCopos, AnchoIdeal = aI, StrokeGrad = strokeGrad, TitleGrad = titleGrad, NameGrad = nameGrad }
    actualizarAnimacionNombreTag(UIsActivos[userId], datos)
end

task.spawn(function()
    local oldDataCache = {}
    while scriptActivoTags and not ScriptIsDead do
        local s1, resActive = pcall(function() return request({Url = BASE_URL .. "/api/active?t=" .. tostring(tick()), Method = "GET"}) end)
        local s2, resTags = pcall(function() return request({Url = API_URL .. "?t=" .. tostring(tick()), Method = "GET"}) end)
        
        if s1 and s2 and resActive.StatusCode == 200 and resTags.StatusCode == 200 then
            local sA, activeArray = pcall(function() return HttpService:JSONDecode(resActive.Body) end)
            local sT, apiData = pcall(function() return HttpService:JSONDecode(resTags.Body) end)
            
            if sA and sT then
                local isScriptUser = {}
                for _, uid in ipairs(activeArray) do isScriptUser[tostring(uid)] = true end
                
                for _, player in ipairs(Players:GetPlayers()) do
                    local id = tostring(player.UserId)
                    
                    if hiddenTags[id] then OcultarAvatar(player.Character, true); MutearVoiceChat(player, true) end
                    
                    if isScriptUser[id] or player == LocalPlayer then
                        local cfg = apiData[id] or { titulo = "USER", colorFondo1 = "#1c1c24", colorFondo2 = "#0f0f13", colorBorde = "#ffffff", colorTitulo = "#ffffff", colorNombre = "#a0a0b0", animarNombre = false, emojiNieve = "*", colorNieve = "#ffffff", fuente = "GothamBold" }
                        local hashData = HttpService:JSONEncode(cfg)

                        if player.Character and player.Character:FindFirstChild("Head") then
                            local currentHead = player.Character.Head
                            if not UIsActivos[id] or UIsActivos[id].Head ~= currentHead then
                                if UIsActivos[id] then if UIsActivos[id].UI then UIsActivos[id].UI:Destroy() end; UIsActivos[id] = nil end
                                crearUITag(player, cfg, id); oldDataCache[id] = hashData
                            elseif oldDataCache[id] ~= hashData then
                                local ui = UIsActivos[id]
                                if ui and ui.UI and ui.UI.Parent then
                                    ui.Gradiente.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, parseHexTag(cfg.colorFondo1, "#1c1c24")), ColorSequenceKeypoint.new(1, parseHexTag(cfg.colorFondo2, "#0f0f13")) })
                                    if ui.StrokeGrad then ui.StrokeGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, parseHexTag(cfg.colorBorde1 or cfg.colorBorde, "#FFFFFF")), ColorSequenceKeypoint.new(1, parseHexTag(cfg.colorBorde2 or cfg.colorBorde, "#FFFFFF")) }) end
                                    if ui.TitleGrad then ui.TitleGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, parseHexTag(cfg.colorTitulo1 or cfg.colorTitulo, "#ffffff")), ColorSequenceKeypoint.new(1, parseHexTag(cfg.colorTitulo2 or cfg.colorTitulo, "#ffffff")) }) end
                                    if ui.NameGrad then ui.NameGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, parseHexTag(cfg.colorNombre1 or cfg.colorNombre, "#a0a0b0")), ColorSequenceKeypoint.new(1, parseHexTag(cfg.colorNombre2 or cfg.colorNombre, "#a0a0b0")) }) end
                                    ui.TxtTitle.Text = cfg.titulo or "USER"
                                    local sF, fU = pcall(function() return Enum.Font[cfg.fuente] end); if sF and fU then ui.TxtTitle.Font = fU end
                                    ui.TxtTitle.TextColor3 = Color3.new(1,1,1); if not cfg.animarNombre then ui.TxtName.TextColor3 = Color3.new(1,1,1) end
                                    task.spawn(function() local newImg = obtenerImagenTag(cfg.imagen, id); if ui.AvatarImg and ui.AvatarImg.Parent then ui.AvatarImg.Image = newImg end end)
                                    
                                    for _, copo in ipairs(ui.Copos) do if copo.Parent then copo.Text = cfg.emojiNieve or "*"; copo.TextColor3 = parseHexTag(cfg.colorNieve, "#ffffff") end end
                                    actualizarAnimacionNombreTag(ui, cfg)
                                    local bT = TextService:GetTextSize(ui.TxtTitle.Text, 14, ui.TxtTitle.Font, Vector2.new(1000, 40)); local bN = TextService:GetTextSize(player.Name:upper(), 12, Enum.Font.GothamBold, Vector2.new(1000, 40))
                                    ui.AnchoIdeal = math.max(100, 5 + 30 + 8 + math.max(bT.X, bN.X) + 12)
                                    if ui.Estado == "Abierto" then TweenService:Create(ui.Card, TweenInfo.new(0.2), {Size = UDim2.new(0, ui.AnchoIdeal, 0, 40)}):Play() end
                                end
                                oldDataCache[id] = hashData
                            end
                        end
                    else
                        if UIsActivos[id] then UIsActivos[id].UI:Destroy(); UIsActivos[id] = nil
                            if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then player.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end 
                        end
                    end
                end
            end
        end
        task.wait(2.5) 
    end
end)

local animSpd = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
table.insert(GlobalConnections, RunService.RenderStepped:Connect(function()
    if not scriptActivoTags or ScriptIsDead then return end
    for id, data in pairs(UIsActivos) do
        if data.Head and data.Head.Parent and data.UI.Parent then
            if id == tostring(LocalPlayer.UserId) then data.UI.Enabled = verMiTag else data.UI.Enabled = not hiddenTags[id] end
            local dist = (Camera.CFrame.Position - data.Head.Position).Magnitude
            if dist > 35 then data.Escalador.Scale = math.clamp(40 / dist, 0.5, 1) else data.Escalador.Scale = 1 end
            if dist > 28 and data.Estado == "Abierto" then
                data.Estado = "Cerrado"; data.SnowContainer.Visible = false
                TweenService:Create(data.TxtTitle, animSpd, {TextTransparency = 1}):Play(); TweenService:Create(data.TxtName, animSpd, {TextTransparency = 1}):Play()
                TweenService:Create(data.Card, animSpd, {Size = UDim2.new(0, 36, 0, 36)}):Play(); TweenService:Create(data.CardCorner, animSpd, {CornerRadius = UDim.new(1, 0)}):Play(); TweenService:Create(data.Avatar, animSpd, {Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5)}):Play()
            elseif dist < 23 and data.Estado == "Cerrado" then
                data.Estado = "Abierto"; data.SnowContainer.Visible = true
                TweenService:Create(data.TxtTitle, animSpd, {TextTransparency = 0}):Play(); TweenService:Create(data.TxtName, animSpd, {TextTransparency = 0}):Play()
                TweenService:Create(data.Card, animSpd, {Size = UDim2.new(0, data.AnchoIdeal, 0, 40)}):Play(); TweenService:Create(data.CardCorner, animSpd, {CornerRadius = UDim.new(0, 6)}):Play(); TweenService:Create(data.Avatar, animSpd, {Position = UDim2.new(0, 5, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)}):Play()
            end
        else
            if data.UI then data.UI:Destroy() end; UIsActivos[id] = nil
        end
    end
end))


-- ==================================================================
-- 1. CONSOLA PRINCIPAL OPTIFINE
-- ==================================================================
Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 320, 0, 350); Main.Position = UDim2.new(1, -340, 0, 20); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.BorderSizePixel = 0; Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6); MainStroke = Instance.new("UIStroke", Main); MainStroke.Color = borderDark
ApplyResponsiveScale(Main)

FullUI = Instance.new("Frame", Main); FullUI.Size = UDim2.new(1, 0, 1, 0); FullUI.BackgroundTransparency = 1; FullUI.BorderSizePixel = 0
TopBar = Instance.new("Frame", FullUI); TopBar.Size = UDim2.new(1, 0, 0, 35); TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TopBar.BorderSizePixel = 0; Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)
Fix = Instance.new("Frame", TopBar); Fix.Size = UDim2.new(1, 0, 0, 5); Fix.Position = UDim2.new(0, 0, 1, -5); Fix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); Fix.BorderSizePixel = 0
Title = Instance.new("TextLabel", TopBar); Title.Size = UDim2.new(1, -150, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0); Title.BackgroundTransparency = 1; Title.Text = "C.D.T OPTIFINE // SYSTEM"; Title.TextColor3 = tWhite; Title.Font = Enum.Font.GothamBold; Title.TextSize = 12; Title.TextXAlignment = Enum.TextXAlignment.Left

local ExpLabel = Instance.new("TextLabel", TopBar)
ExpLabel.Size = UDim2.new(0, 100, 1, 0); ExpLabel.Position = UDim2.new(1, -180, 0, 0)
ExpLabel.BackgroundTransparency = 1; ExpLabel.Text = "Verificando..."
ExpLabel.TextColor3 = tYellow; ExpLabel.Font = Enum.Font.GothamBold; ExpLabel.TextSize = 11; ExpLabel.TextXAlignment = Enum.TextXAlignment.Right

MinBtn = Instance.new("TextButton", TopBar); MinBtn.Size = UDim2.new(0, 35, 1, 0); MinBtn.Position = UDim2.new(1, -35, 0, 0); MinBtn.BackgroundTransparency = 1; MinBtn.Text = "—"; MinBtn.TextColor3 = tGreen; MinBtn.Font = Enum.Font.GothamBlack; MinBtn.TextSize = 14
SetBtn = Instance.new("TextButton", TopBar); SetBtn.Size = UDim2.new(0, 35, 1, 0); SetBtn.Position = UDim2.new(1, -70, 0, 0); SetBtn.BackgroundTransparency = 1; SetBtn.Text = "⚙"; SetBtn.TextColor3 = tWhite; SetBtn.Font = Enum.Font.GothamBlack; SetBtn.TextSize = 16

Console = Instance.new("ScrollingFrame", FullUI)
Console.Size = UDim2.new(1, -20, 1, -95); Console.Position = UDim2.new(0, 10, 0, 40); Console.BackgroundTransparency = 1; Console.BorderSizePixel = 0; Console.ScrollBarThickness = 2; Console.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
UIList = Instance.new("UIListLayout", Console); UIList.Padding = UDim.new(0, 4); UIList.SortOrder = Enum.SortOrder.LayoutOrder

CmdBox = Instance.new("TextBox", FullUI)
CmdBox.Size = UDim2.new(1, -20, 0, 35); CmdBox.Position = UDim2.new(0, 10, 1, -45); CmdBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10); CmdBox.TextColor3 = tWhite; CmdBox.Text = ""; CmdBox.PlaceholderText = "> Escribe un comando aquí..."; CmdBox.Font = Enum.Font.Gotham; CmdBox.TextSize = 13; CmdBox.TextXAlignment = Enum.TextXAlignment.Left; CmdBox.ClearTextOnFocus = false; Instance.new("UICorner", CmdBox).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", CmdBox).Color = Color3.fromRGB(40, 40, 40); Instance.new("UIPadding", CmdBox).PaddingLeft = UDim.new(0, 10)

MiniUI = Instance.new("Frame", Main); MiniUI.Size = UDim2.new(1, 0, 1, 0); MiniUI.BackgroundTransparency = 1; MiniUI.BorderSizePixel = 0; MiniUI.Visible = false
MiniLabel = Instance.new("TextLabel", MiniUI); MiniLabel.Size = UDim2.new(1, -40, 1, 0); MiniLabel.Position = UDim2.new(0, 15, 0, 0); MiniLabel.BackgroundTransparency = 1; MiniLabel.Text = "C.D.T TERMINAL"; MiniLabel.TextColor3 = tWhite; MiniLabel.Font = Enum.Font.GothamBold; MiniLabel.TextSize = 12; MiniLabel.TextXAlignment = Enum.TextXAlignment.Left
Dot = Instance.new("Frame", MiniUI); Dot.Size = UDim2.new(0, 6, 0, 6); Dot.Position = UDim2.new(0, 140, 0.5, -3); Dot.BackgroundColor3 = tGreen; Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
MaxBtn = Instance.new("TextButton", MiniUI); MaxBtn.Size = UDim2.new(0, 35, 1, 0); MaxBtn.Position = UDim2.new(1, -35, 0, 0); MaxBtn.BackgroundTransparency = 1; MaxBtn.Text = "⤢"; MaxBtn.TextColor3 = tGreen; MaxBtn.Font = Enum.Font.GothamBlack; MaxBtn.TextSize = 18

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

table.insert(GlobalConnections, LocalPlayer.Chatted:Connect(function(msg)
    if ScriptIsDead then return end
    local msgLower = string.lower(msg)
    if msgLower == "!re" then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if humanoid and hrp then
                posicionGuardadaRE = hrp.CFrame
                humanoid.Health = 0
            end
        end
        return
    end
    
    local cmd = string.match(msg, "^!%s*(.+)")
    if cmd then
        cmd = string.lower(cmd)
        for wpName, coords in pairs(waypoints) do
            if string.lower(wpName) == cmd then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then 
                    char.HumanoidRootPart.CFrame = CFrame.new(coords.X, coords.Y, coords.Z) 
                end
                break
            end
        end
    end
end))

MPMain = Instance.new("Frame", ScreenGui); MPMain.Size = UDim2.new(0, 260, 0, 350); MPMain.Position = UDim2.new(0.5, 150, 0.5, -175); MPMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); MPMain.BorderSizePixel = 0; MPMain.ClipsDescendants = true; MPMain.Visible = false; Instance.new("UICorner", MPMain).CornerRadius = UDim.new(0, 6); MPMainStroke = Instance.new("UIStroke", MPMain); MPMainStroke.Color = borderDark
MPTopBar = Instance.new("Frame", MPMain); MPTopBar.Size = UDim2.new(1, 0, 0, 35); MPTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); MPTopBar.BorderSizePixel = 0; Instance.new("UICorner", MPTopBar).CornerRadius = UDim.new(0, 6)
MPFix = Instance.new("Frame", MPTopBar); MPFix.Size = UDim2.new(1, 0, 0, 5); MPFix.Position = UDim2.new(0, 0, 1, -5); MPFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); MPFix.BorderSizePixel = 0
MPTitle = Instance.new("TextLabel", MPTopBar); MPTitle.Size = UDim2.new(1, -70, 1, 0); MPTitle.Position = UDim2.new(0, 15, 0, 0); MPTitle.BackgroundTransparency = 1; MPTitle.Text = "MAP: ID " .. tostring(game.PlaceId); MPTitle.TextColor3 = tWhite; MPTitle.Font = Enum.Font.GothamBold; MPTitle.TextSize = 13; MPTitle.TextXAlignment = Enum.TextXAlignment.Left
task.spawn(function() pcall(function() local info = MarketplaceService:GetProductInfo(game.PlaceId); if info and info.Name then MPTitle.Text = "MAP: " .. string.sub(info.Name, 1, 20) end end) end)

MPMinBtn = Instance.new("TextButton", MPTopBar); MPMinBtn.Size = UDim2.new(0, 35, 1, 0); MPMinBtn.Position = UDim2.new(1, -70, 0, 0); MPMinBtn.BackgroundTransparency = 1; MPMinBtn.Text = "—"; MPMinBtn.TextColor3 = tGreen; MPMinBtn.Font = Enum.Font.GothamBlack; MPMinBtn.TextSize = 14
MPCloseBtn = Instance.new("TextButton", MPTopBar); MPCloseBtn.Size = UDim2.new(0, 35, 1, 0); MPCloseBtn.Position = UDim2.new(1, -35, 0, 0); MPCloseBtn.BackgroundTransparency = 1; MPCloseBtn.Text = "X"; MPCloseBtn.TextColor3 = tRed; MPCloseBtn.Font = Enum.Font.GothamBlack; MPCloseBtn.TextSize = 12

MPInput = Instance.new("TextBox", MPMain); MPInput.Size = UDim2.new(1, -85, 0, 30); MPInput.Position = UDim2.new(0, 5, 0, 40); MPInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MPInput.TextColor3 = tWhite; MPInput.Text = ""; MPInput.PlaceholderText = "Nombre del lugar..."; MPInput.Font = Enum.Font.Gotham; MPInput.TextSize = 12; MPInput.ClearTextOnFocus = false; Instance.new("UICorner", MPInput).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", MPInput).Color = Color3.fromRGB(50, 50, 50); Instance.new("UIPadding", MPInput).PaddingLeft = UDim.new(0, 5)
MPSaveBtn = Instance.new("TextButton", MPMain); MPSaveBtn.Size = UDim2.new(0, 70, 0, 30); MPSaveBtn.Position = UDim2.new(1, -75, 0, 40); MPSaveBtn.BackgroundColor3 = tPurple; MPSaveBtn.TextColor3 = tWhite; MPSaveBtn.Text = "ADD"; MPSaveBtn.Font = Enum.Font.GothamBold; MPSaveBtn.TextSize = 12; Instance.new("UICorner", MPSaveBtn).CornerRadius = UDim.new(0, 4)
MPScroll = Instance.new("ScrollingFrame", MPMain); MPScroll.Size = UDim2.new(1, -10, 1, -85); MPScroll.Position = UDim2.new(0, 5, 0, 80); MPScroll.BackgroundTransparency = 1; MPScroll.BorderSizePixel = 0; MPScroll.ScrollBarThickness = 2; MPScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
MPListLayout = Instance.new("UIListLayout", MPScroll); MPListLayout.Padding = UDim.new(0, 5)

ConfirmPopup = Instance.new("Frame", MPMain); ConfirmPopup.Size = UDim2.new(1, 0, 1, 0); ConfirmPopup.BackgroundColor3 = Color3.fromRGB(15, 15, 20); ConfirmPopup.BackgroundTransparency = 0.2; ConfirmPopup.Visible = false; ConfirmPopup.ZIndex = 10
ConfirmMsg = Instance.new("TextLabel", ConfirmPopup); ConfirmMsg.Size = UDim2.new(1, -20, 0, 60); ConfirmMsg.Position = UDim2.new(0, 10, 0.5, -60); ConfirmMsg.BackgroundTransparency = 1; ConfirmMsg.TextColor3 = tWhite; ConfirmMsg.Text = "¿Estás seguro?"; ConfirmMsg.Font = Enum.Font.GothamBold; ConfirmMsg.TextSize = 13; ConfirmMsg.TextWrapped = true; ConfirmMsg.ZIndex = 11
YesBtn = Instance.new("TextButton", ConfirmPopup); YesBtn.Size = UDim2.new(0, 100, 0, 35); YesBtn.Position = UDim2.new(0.5, -110, 0.5, 10); YesBtn.BackgroundColor3 = tGreen; YesBtn.TextColor3 = Color3.fromRGB(10, 10, 10); YesBtn.Text = "SÍ"; YesBtn.Font = Enum.Font.GothamBold; YesBtn.TextSize = 13; YesBtn.ZIndex = 11; Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 4)
NoBtn = Instance.new("TextButton", ConfirmPopup); NoBtn.Size = UDim2.new(0, 100, 0, 35); NoBtn.Position = UDim2.new(0.5, 10, 0.5, 10); NoBtn.BackgroundColor3 = tRed; NoBtn.TextColor3 = tWhite; NoBtn.Text = "NO"; NoBtn.Font = Enum.Font.GothamBold; NoBtn.TextSize = 13; NoBtn.ZIndex = 11; Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 4)

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
    if accionPendiente == "eliminar" then waypoints[waypointPendiente] = nil
    elseif accionPendiente == "actualizar" then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position; waypoints[waypointPendiente] = {X = pos.X, Y = pos.Y, Z = pos.Z}
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
TPMain = Instance.new("Frame", ScreenGui); TPMain.Size = UDim2.new(0, 260, 0, 380); TPMain.Position = UDim2.new(0.5, -130, 0.5, -190); TPMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); TPMain.BorderSizePixel = 0; TPMain.ClipsDescendants = true; TPMain.Visible = false; Instance.new("UICorner", TPMain).CornerRadius = UDim.new(0, 6); TPMainStroke = Instance.new("UIStroke", TPMain); TPMainStroke.Color = borderDark
TPTopBar = Instance.new("Frame", TPMain); TPTopBar.Size = UDim2.new(1, 0, 0, 35); TPTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TPTopBar.BorderSizePixel = 0; Instance.new("UICorner", TPTopBar).CornerRadius = UDim.new(0, 6)
TPFix = Instance.new("Frame", TPTopBar); TPFix.Size = UDim2.new(1, 0, 0, 5); TPFix.Position = UDim2.new(0, 0, 1, -5); TPFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TPFix.BorderSizePixel = 0
TPTitle = Instance.new("TextLabel", TPTopBar); TPTitle.Size = UDim2.new(1, -70, 1, 0); TPTitle.Position = UDim2.new(0, 15, 0, 0); TPTitle.BackgroundTransparency = 1; TPTitle.Text = "TP PLAYERS"; TPTitle.TextColor3 = tWhite; TPTitle.Font = Enum.Font.GothamBold; TPTitle.TextSize = 13; TPTitle.TextXAlignment = Enum.TextXAlignment.Left
TPMinBtn = Instance.new("TextButton", TPTopBar); TPMinBtn.Size = UDim2.new(0, 35, 1, 0); TPMinBtn.Position = UDim2.new(1, -70, 0, 0); TPMinBtn.BackgroundTransparency = 1; TPMinBtn.Text = "—"; TPMinBtn.TextColor3 = tYellow; TPMinBtn.Font = Enum.Font.GothamBlack; TPMinBtn.TextSize = 14
TPCloseBtn = Instance.new("TextButton", TPTopBar); TPCloseBtn.Size = UDim2.new(0, 35, 1, 0); TPCloseBtn.Position = UDim2.new(1, -35, 0, 0); TPCloseBtn.BackgroundTransparency = 1; TPCloseBtn.Text = "X"; TPCloseBtn.TextColor3 = tRed; TPCloseBtn.Font = Enum.Font.GothamBlack; TPCloseBtn.TextSize = 12
TPSearchBox = Instance.new("TextBox", TPMain); TPSearchBox.Size = UDim2.new(1, -10, 0, 35); TPSearchBox.Position = UDim2.new(0, 5, 0, 40); TPSearchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TPSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255); TPSearchBox.Text = ""; TPSearchBox.PlaceholderText = "🔍 Buscar jugador..."; TPSearchBox.Font = Enum.Font.Gotham; TPSearchBox.TextSize = 13; TPSearchBox.ClearTextOnFocus = false; Instance.new("UICorner", TPSearchBox).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", TPSearchBox).Color = Color3.fromRGB(50, 50, 50)
TPScroll = Instance.new("ScrollingFrame", TPMain); TPScroll.Size = UDim2.new(1, -10, 1, -85); TPScroll.Position = UDim2.new(0, 5, 0, 80); TPScroll.BackgroundTransparency = 1; TPScroll.BorderSizePixel = 0; TPScroll.ScrollBarThickness = 2; TPScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
TPListLayout = Instance.new("UIListLayout", TPScroll); TPListLayout.Padding = UDim.new(0, 5)

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
table.insert(GlobalConnections, TPSearchBox:GetPropertyChangedSignal("Text"):Connect(function() RefreshTPMenu(TPSearchBox.Text) end))
table.insert(GlobalConnections, Players.PlayerAdded:Connect(function() if TPMain.Visible then RefreshTPMenu(TPSearchBox.Text) end end))
table.insert(GlobalConnections, Players.PlayerRemoving:Connect(function() if TPMain.Visible then RefreshTPMenu(TPSearchBox.Text) end end))

-- ==================================================================
-- INTERFAZ HIDE MENU (OCULTAR AVATAR, SONIDOS LOCALES Y VOICE CHAT)
-- ==================================================================
HideMain = Instance.new("Frame", ScreenGui); HideMain.Size = UDim2.new(0, 260, 0, 380); HideMain.Position = UDim2.new(0.5, 150, 0.5, -190); HideMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); HideMain.BorderSizePixel = 0; HideMain.ClipsDescendants = true; HideMain.Visible = false; Instance.new("UICorner", HideMain).CornerRadius = UDim.new(0, 6); HideMainStroke = Instance.new("UIStroke", HideMain); HideMainStroke.Color = borderDark
HideTopBar = Instance.new("Frame", HideMain); HideTopBar.Size = UDim2.new(1, 0, 0, 35); HideTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); HideTopBar.BorderSizePixel = 0; Instance.new("UICorner", HideTopBar).CornerRadius = UDim.new(0, 6)
HideFix = Instance.new("Frame", HideTopBar); HideFix.Size = UDim2.new(1, 0, 0, 5); HideFix.Position = UDim2.new(0, 0, 1, -5); HideFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); HideFix.BorderSizePixel = 0
HideTitle = Instance.new("TextLabel", HideTopBar); HideTitle.Size = UDim2.new(1, -70, 1, 0); HideTitle.Position = UDim2.new(0, 15, 0, 0); HideTitle.BackgroundTransparency = 1; HideTitle.Text = "HIDE PLAYERS"; HideTitle.TextColor3 = tWhite; HideTitle.Font = Enum.Font.GothamBold; HideTitle.TextSize = 13; HideTitle.TextXAlignment = Enum.TextXAlignment.Left
HideMinBtn = Instance.new("TextButton", HideTopBar); HideMinBtn.Size = UDim2.new(0, 35, 1, 0); HideMinBtn.Position = UDim2.new(1, -70, 0, 0); HideMinBtn.BackgroundTransparency = 1; HideMinBtn.Text = "—"; HideMinBtn.TextColor3 = tYellow; HideMinBtn.Font = Enum.Font.GothamBlack; HideMinBtn.TextSize = 14
HideCloseBtn = Instance.new("TextButton", HideTopBar); HideCloseBtn.Size = UDim2.new(0, 35, 1, 0); HideCloseBtn.Position = UDim2.new(1, -35, 0, 0); HideCloseBtn.BackgroundTransparency = 1; HideCloseBtn.Text = "X"; HideCloseBtn.TextColor3 = tRed; HideCloseBtn.Font = Enum.Font.GothamBlack; HideCloseBtn.TextSize = 12
HideSearchBox = Instance.new("TextBox", HideMain); HideSearchBox.Size = UDim2.new(1, -10, 0, 35); HideSearchBox.Position = UDim2.new(0, 5, 0, 40); HideSearchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20); HideSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255); HideSearchBox.Text = ""; HideSearchBox.PlaceholderText = "🔍 Buscar jugador..."; HideSearchBox.Font = Enum.Font.Gotham; HideSearchBox.TextSize = 13; HideSearchBox.ClearTextOnFocus = false; Instance.new("UICorner", HideSearchBox).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", HideSearchBox).Color = Color3.fromRGB(50, 50, 50)
HideScroll = Instance.new("ScrollingFrame", HideMain); HideScroll.Size = UDim2.new(1, -10, 1, -85); HideScroll.Position = UDim2.new(0, 5, 0, 80); HideScroll.BackgroundTransparency = 1; HideScroll.BorderSizePixel = 0; HideScroll.ScrollBarThickness = 2; HideScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
HideListLayout = Instance.new("UIListLayout", HideScroll); HideListLayout.Padding = UDim.new(0, 5)

ApplyResponsiveScale(HideMain); MakeDraggable(HideTopBar, HideMain)

local hideMinimized = false
HideMinBtn.MouseButton1Click:Connect(function()
    hideMinimized = not hideMinimized; HideMain:TweenSize(hideMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 380), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    HideMinBtn.Text = hideMinimized and "+" or "—"; HideFix.Visible = not hideMinimized
end)
HideCloseBtn.MouseButton1Click:Connect(function() HideMain.Visible = false end)

local function RefreshHideMenu(filterText)
    filterText = filterText and string.lower(filterText) or ""
    for _, child in pairs(HideScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if filterText == "" or string.find(string.lower(plr.Name), filterText) or string.find(string.lower(plr.DisplayName), filterText) then
                local Card = Instance.new("Frame", HideScroll); Card.Size = UDim2.new(1, -5, 0, 40); Card.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
                local Avatar = Instance.new("ImageLabel", Card); Avatar.Size = UDim2.new(0, 30, 0, 30); Avatar.Position = UDim2.new(0, 5, 0, 5); Avatar.BackgroundTransparency = 1; Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
                task.spawn(function() pcall(function() Avatar.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end) end)
                local NameLbl = Instance.new("TextLabel", Card); NameLbl.Size = UDim2.new(1, -110, 1, 0); NameLbl.Position = UDim2.new(0, 40, 0, 0); NameLbl.BackgroundTransparency = 1; NameLbl.Text = plr.DisplayName; NameLbl.TextColor3 = tWhite; NameLbl.Font = Enum.Font.GothamMedium; NameLbl.TextSize = 13; NameLbl.TextXAlignment = Enum.TextXAlignment.Left
                
                local idStr = tostring(plr.UserId)
                local isHid = hiddenTags[idStr]
                if isHid then MutearVoiceChat(plr, true) end
                
                local HBtn = Instance.new("TextButton", Card); HBtn.Size = UDim2.new(0, 60, 0, 26); HBtn.Position = UDim2.new(1, -65, 0.5, -13)
                HBtn.BackgroundColor3 = isHid and tGreen or Color3.fromRGB(40, 40, 40)
                HBtn.Text = isHid and "OCULTO" or "VISIBLE"
                HBtn.TextColor3 = isHid and Color3.fromRGB(10, 10, 10) or tWhite
                HBtn.Font = Enum.Font.GothamBold; HBtn.TextSize = 11; Instance.new("UICorner", HBtn).CornerRadius = UDim.new(0, 4)
                
                HBtn.MouseButton1Click:Connect(function()
                    hiddenTags[idStr] = not hiddenTags[idStr]
                    local h = hiddenTags[idStr]
                    HBtn.BackgroundColor3 = h and tGreen or Color3.fromRGB(40, 40, 40)
                    HBtn.Text = h and "OCULTO" or "VISIBLE"
                    HBtn.TextColor3 = h and Color3.fromRGB(10, 10, 10) or tWhite
                    if plr.Character then OcultarAvatar(plr.Character, h) end
                    MutearVoiceChat(plr, h) 
                end)
            end
        end
    end
    HideScroll.CanvasSize = UDim2.new(0, 0, 0, HideListLayout.AbsoluteContentSize.Y + 10)
end
table.insert(GlobalConnections, HideSearchBox:GetPropertyChangedSignal("Text"):Connect(function() RefreshHideMenu(HideSearchBox.Text) end))
table.insert(GlobalConnections, Players.PlayerAdded:Connect(function() if HideMain.Visible then RefreshHideMenu(HideSearchBox.Text) end end))
table.insert(GlobalConnections, Players.PlayerRemoving:Connect(function() if HideMain.Visible then RefreshHideMenu(HideSearchBox.Text) end end))

-- ==================================================================
-- 4. INTERFAZ INVISIBLE MENU (SEAT MODE FIX GHOST)
-- ==================================================================
InvMain = Instance.new("Frame", ScreenGui); InvMain.Size = UDim2.new(0, 260, 0, 100); InvMain.Position = UDim2.new(0, 20, 0, 20); InvMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); InvMain.BorderSizePixel = 0; InvMain.ClipsDescendants = true; InvMain.Visible = false; Instance.new("UICorner", InvMain).CornerRadius = UDim.new(0, 6); InvMainStroke = Instance.new("UIStroke", InvMain); InvMainStroke.Color = borderDark
InvTopBar = Instance.new("Frame", InvMain); InvTopBar.Size = UDim2.new(1, 0, 0, 35); InvTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); InvTopBar.BorderSizePixel = 0; Instance.new("UICorner", InvTopBar).CornerRadius = UDim.new(0, 6)
InvFix = Instance.new("Frame", InvTopBar); InvFix.Size = UDim2.new(1, 0, 0, 5); InvFix.Position = UDim2.new(0, 0, 1, -5); InvFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); InvFix.BorderSizePixel = 0
InvTitle = Instance.new("TextLabel", InvTopBar); InvTitle.Size = UDim2.new(1, -70, 1, 0); InvTitle.Position = UDim2.new(0, 15, 0, 0); InvTitle.BackgroundTransparency = 1; InvTitle.Text = "INVISIBILITY"; InvTitle.TextColor3 = tWhite; InvTitle.Font = Enum.Font.GothamBold; InvTitle.TextSize = 13; InvTitle.TextXAlignment = Enum.TextXAlignment.Left
InvMinBtn = Instance.new("TextButton", InvTopBar); InvMinBtn.Size = UDim2.new(0, 35, 1, 0); InvMinBtn.Position = UDim2.new(1, -70, 0, 0); InvMinBtn.BackgroundTransparency = 1; InvMinBtn.Text = "—"; InvMinBtn.TextColor3 = tGreen; InvMinBtn.Font = Enum.Font.GothamBlack; InvMinBtn.TextSize = 14
InvCloseBtn = Instance.new("TextButton", InvTopBar); InvCloseBtn.Size = UDim2.new(0, 35, 1, 0); InvCloseBtn.Position = UDim2.new(1, -35, 0, 0); InvCloseBtn.BackgroundTransparency = 1; InvCloseBtn.Text = "X"; InvCloseBtn.TextColor3 = tRed; InvCloseBtn.Font = Enum.Font.GothamBlack; InvCloseBtn.TextSize = 12
InvToggleBtn = Instance.new("TextButton", InvMain); InvToggleBtn.Size = UDim2.new(1, -75, 0, 45); InvToggleBtn.Position = UDim2.new(0, 10, 0, 45); InvToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); InvToggleBtn.Text = "INVISIBILIDAD: OFF"; InvToggleBtn.TextColor3 = tWhite; InvToggleBtn.Font = Enum.Font.GothamBold; InvToggleBtn.TextSize = 12; Instance.new("UICorner", InvToggleBtn).CornerRadius = UDim.new(0, 6)
InvKeyBtn = Instance.new("TextButton", InvMain); InvKeyBtn.Size = UDim2.new(0, 50, 0, 45); InvKeyBtn.Position = UDim2.new(1, -60, 0, 45); InvKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); InvKeyBtn.Text = "KEY"; InvKeyBtn.TextColor3 = tWhite; InvKeyBtn.Font = Enum.Font.GothamBold; InvKeyBtn.TextSize = 11; Instance.new("UICorner", InvKeyBtn).CornerRadius = UDim.new(0, 6)

ApplyResponsiveScale(InvMain); MakeDraggable(InvTopBar, InvMain)

local invMinimized = false
InvMinBtn.MouseButton1Click:Connect(function()
    invMinimized = not invMinimized; InvMain:TweenSize(invMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 100), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    InvMinBtn.Text = invMinimized and "+" or "—"; InvFix.Visible = not invMinimized
end)

local function showNotice(txt)
    pcall(function() if CoreGui:FindFirstChild("InvisGhostNotice") then CoreGui.InvisGhostNotice:Destroy() end end)
    local g = Instance.new("ScreenGui", CoreGui); g.Name = "InvisGhostNotice"; g.ResetOnSpawn = false
    local lbl = Instance.new("TextLabel", g); lbl.Size = UDim2.new(0, 300, 0, 40); lbl.Position = UDim2.new(0.5, -150, 0, 20); lbl.BackgroundTransparency = 0.15; lbl.BackgroundColor3 = Color3.fromRGB(30, 30, 30); lbl.TextColor3 = Color3.new(1, 1, 1); lbl.Text = txt; lbl.TextSize = 18; lbl.Font = Enum.Font.SourceSansSemibold; lbl.ZIndex = 9999; Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 8)
    task.spawn(function() task.wait(2); pcall(function() g:Destroy() end) end)
end

local isGhostActive = false; local invKeybind = nil; local isInvBinding = false; local ghostDebounce = false
local currentInvisSeat = nil 

local function setCharacterTransparency(char, val)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = val
        elseif p:IsA("Decal") or p:IsA("Texture") then p.Transparency = val end
    end
end

ToggleGhost = function()
    if ghostDebounce then return end
    ghostDebounce = true
    isGhostActive = not isGhostActive
    local char = LocalPlayer.Character

    if isGhostActive then
        if char and char:FindFirstChild("HumanoidRootPart") then
            setCharacterTransparency(char, 0.5)
            local savedpos = char.HumanoidRootPart.CFrame
            task.wait()
            pcall(function() char:MoveTo(Vector3.new(-25.95, 84, 3537.55)) end)
            task.wait(0.15)
            
            if currentInvisSeat and currentInvisSeat.Parent then currentInvisSeat:Destroy() end
            currentInvisSeat = Instance.new("Seat", Workspace)
            currentInvisSeat.Anchored = false; currentInvisSeat.CanCollide = false; currentInvisSeat.Name = "invischair"; currentInvisSeat.Transparency = 1; currentInvisSeat.Position = Vector3.new(-25.95, 84, 3537.55)
            
            local Weld = Instance.new("Weld", currentInvisSeat)
            Weld.Part0 = currentInvisSeat
            local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            
            if torso then 
                Weld.Part1 = torso; currentInvisSeat.CFrame = savedpos 
                InvToggleBtn.BackgroundColor3 = tGreen; InvToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10); InvToggleBtn.Text = "INVISIBILIDAD: ON"
                showNotice("Invisibility Enabled")
            else 
                if currentInvisSeat then currentInvisSeat:Destroy(); currentInvisSeat = nil end
                isGhostActive = false; setCharacterTransparency(char, 0) 
                InvToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); InvToggleBtn.TextColor3 = tWhite; InvToggleBtn.Text = "INVISIBILIDAD: OFF"
            end
        end
    else
        if char then setCharacterTransparency(char, 0) end
        if currentInvisSeat and currentInvisSeat.Parent then pcall(function() currentInvisSeat:Destroy() end) end
        currentInvisSeat = nil
        local inv = Workspace:FindFirstChild("invischair")
        if inv then pcall(function() inv:Destroy() end) end
        InvToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); InvToggleBtn.TextColor3 = tWhite; InvToggleBtn.Text = "INVISIBILIDAD: OFF"
        showNotice("Invisibility Disabled")
    end
    task.wait(0.5); ghostDebounce = false
end
InvToggleBtn.MouseButton1Click:Connect(ToggleGhost)

InvCloseBtn.MouseButton1Click:Connect(function() 
    InvMain.Visible = false; invKeybind = nil; isInvBinding = false; InvKeyBtn.Text = "KEY"; InvKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    if isGhostActive then ToggleGhost() end
end)
InvKeyBtn.MouseButton1Click:Connect(function()
    if invKeybind ~= nil then invKeybind = nil; InvKeyBtn.Text = "KEY"; InvKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isInvBinding = false
    else isInvBinding = true; InvKeyBtn.Text = "..."; InvKeyBtn.BackgroundColor3 = tOrange end
end)

-- ==================================================================
-- 5. INTERFAZ Y LÓGICA DEL MENÚ FLY (NORMAL FLY SIN NOCLIP)
-- ==================================================================
FlyMain = Instance.new("Frame", ScreenGui); FlyMain.Size = UDim2.new(0, 260, 0, 145); FlyMain.Position = UDim2.new(0, 20, 0, 140); FlyMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); FlyMain.BorderSizePixel = 0; FlyMain.ClipsDescendants = true; FlyMain.Visible = false; Instance.new("UICorner", FlyMain).CornerRadius = UDim.new(0, 6); FlyMainStroke = Instance.new("UIStroke", FlyMain); FlyMainStroke.Color = borderDark
FlyTopBar = Instance.new("Frame", FlyMain); FlyTopBar.Size = UDim2.new(1, 0, 0, 35); FlyTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); FlyTopBar.BorderSizePixel = 0; Instance.new("UICorner", FlyTopBar).CornerRadius = UDim.new(0, 6)
FlyFix = Instance.new("Frame", FlyTopBar); FlyFix.Size = UDim2.new(1, 0, 0, 5); FlyFix.Position = UDim2.new(0, 0, 1, -5); FlyFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); FlyFix.BorderSizePixel = 0
FlyTitle = Instance.new("TextLabel", FlyTopBar); FlyTitle.Size = UDim2.new(1, -70, 1, 0); FlyTitle.Position = UDim2.new(0, 15, 0, 0); FlyTitle.BackgroundTransparency = 1; FlyTitle.Text = "NORMAL FLY"; FlyTitle.TextColor3 = tWhite; FlyTitle.Font = Enum.Font.GothamBold; FlyTitle.TextSize = 13; FlyTitle.TextXAlignment = Enum.TextXAlignment.Left
FlyMinBtn = Instance.new("TextButton", FlyTopBar); FlyMinBtn.Size = UDim2.new(0, 35, 1, 0); FlyMinBtn.Position = UDim2.new(1, -70, 0, 0); FlyMinBtn.BackgroundTransparency = 1; FlyMinBtn.Text = "—"; FlyMinBtn.TextColor3 = tGreen; FlyMinBtn.Font = Enum.Font.GothamBlack; FlyMinBtn.TextSize = 14
FlyCloseBtn = Instance.new("TextButton", FlyTopBar); FlyCloseBtn.Size = UDim2.new(0, 35, 1, 0); FlyCloseBtn.Position = UDim2.new(1, -35, 0, 0); FlyCloseBtn.BackgroundTransparency = 1; FlyCloseBtn.Text = "X"; FlyCloseBtn.TextColor3 = tRed; FlyCloseBtn.Font = Enum.Font.GothamBlack; FlyCloseBtn.TextSize = 12

FlyToggleBtn = Instance.new("TextButton", FlyMain); FlyToggleBtn.Size = UDim2.new(1, -75, 0, 45); FlyToggleBtn.Position = UDim2.new(0, 10, 0, 45); FlyToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); FlyToggleBtn.Text = "VUELO: OFF"; FlyToggleBtn.TextColor3 = tWhite; FlyToggleBtn.Font = Enum.Font.GothamBold; FlyToggleBtn.TextSize = 12; Instance.new("UICorner", FlyToggleBtn).CornerRadius = UDim.new(0, 6)
FlyKeyBtn = Instance.new("TextButton", FlyMain); FlyKeyBtn.Size = UDim2.new(0, 50, 0, 45); FlyKeyBtn.Position = UDim2.new(1, -60, 0, 45); FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FlyKeyBtn.Text = "KEY"; FlyKeyBtn.TextColor3 = tWhite; FlyKeyBtn.Font = Enum.Font.GothamBold; FlyKeyBtn.TextSize = 11; Instance.new("UICorner", FlyKeyBtn).CornerRadius = UDim.new(0, 6)

FlySpeedMinus = Instance.new("TextButton", FlyMain); FlySpeedMinus.Size = UDim2.new(0, 40, 0, 35); FlySpeedMinus.Position = UDim2.new(0, 10, 0, 100); FlySpeedMinus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FlySpeedMinus.Text = "-"; FlySpeedMinus.TextColor3 = tWhite; FlySpeedMinus.Font = Enum.Font.GothamBold; Instance.new("UICorner", FlySpeedMinus)
FlySpeedDisplay = Instance.new("TextBox", FlyMain); FlySpeedDisplay.Size = UDim2.new(1, -110, 0, 35); FlySpeedDisplay.Position = UDim2.new(0, 55, 0, 100); FlySpeedDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 25); FlySpeedDisplay.Text = ""; FlySpeedDisplay.PlaceholderText = "SPEED: 100"; FlySpeedDisplay.TextColor3 = tWhite; FlySpeedDisplay.Font = Enum.Font.GothamSemibold; FlySpeedDisplay.TextSize = 14; FlySpeedDisplay.ClearTextOnFocus = true; Instance.new("UICorner", FlySpeedDisplay); Instance.new("UIStroke", FlySpeedDisplay).Color = Color3.fromRGB(50, 50, 50)
FlySpeedPlus = Instance.new("TextButton", FlyMain); FlySpeedPlus.Size = UDim2.new(0, 40, 0, 35); FlySpeedPlus.Position = UDim2.new(1, -50, 0, 100); FlySpeedPlus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FlySpeedPlus.Text = "+"; FlySpeedPlus.TextColor3 = tWhite; FlySpeedPlus.Font = Enum.Font.GothamBold; Instance.new("UICorner", FlySpeedPlus)

ApplyResponsiveScale(FlyMain); MakeDraggable(FlyTopBar, FlyMain)

local flyMinimized = false
FlyMinBtn.MouseButton1Click:Connect(function()
    flyMinimized = not flyMinimized; FlyMain:TweenSize(flyMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 145), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    FlyMinBtn.Text = flyMinimized and "+" or "—"; FlyFix.Visible = not flyMinimized
end)

isFlying = false; flycontrol = {F = 0, R = 0, B = 0, L = 0, U = 0, D = 0}
local flySpeed = 100; local flyKeybind = nil; local isFlyBinding = false; local flyLoop = nil

FlySpeedMinus.MouseButton1Click:Connect(function() flySpeed = math.max(10, flySpeed - 10); FlySpeedDisplay.Text = "SPEED: " .. flySpeed end)
FlySpeedPlus.MouseButton1Click:Connect(function() flySpeed = flySpeed + 10; FlySpeedDisplay.Text = "SPEED: " .. flySpeed end)
FlySpeedDisplay.FocusLost:Connect(function() local num = tonumber(FlySpeedDisplay.Text:match("%d+")); if num then flySpeed = num end; FlySpeedDisplay.Text = "SPEED: " .. flySpeed end)

ToggleFly = function()
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
            local camCF = Workspace.CurrentCamera.CFrame
            bv.Velocity = (camCF.LookVector * ((flycontrol.F - flycontrol.B) * flySpeed)) + (camCF.RightVector * ((flycontrol.R - flycontrol.L) * flySpeed)) + (camCF.UpVector * ((flycontrol.U - flycontrol.D) * flySpeed))
            bg.CFrame = camCF
        end)
    else
        FlyToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); FlyToggleBtn.TextColor3 = tWhite; FlyToggleBtn.Text = "VUELO: OFF"
        if flyLoop then flyLoop:Disconnect() flyLoop = nil end
        if hrp:FindFirstChild("AK_FlyVel") then hrp.AK_FlyVel:Destroy() end; if hrp:FindFirstChild("AK_FlyGyro") then hrp.AK_FlyGyro:Destroy() end
        hum.PlatformStand = false
    end
end
FlyToggleBtn.MouseButton1Click:Connect(ToggleFly)

FlyCloseBtn.MouseButton1Click:Connect(function() 
    FlyMain.Visible = false; flyKeybind = nil; isFlyBinding = false; FlyKeyBtn.Text = "KEY"; FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    if isFlying then ToggleFly() end
end)
FlyKeyBtn.MouseButton1Click:Connect(function()
    if flyKeybind ~= nil then flyKeybind = nil; FlyKeyBtn.Text = "KEY"; FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isFlyBinding = false
    else isFlyBinding = true; FlyKeyBtn.Text = "..."; FlyKeyBtn.BackgroundColor3 = tOrange end
end)

-- ==================================================================
-- 6. NOCLIP WALK (ATRAVIESA PAREDES CAMINANDO + ANTI-VACÍO)
-- ==================================================================
NoclipMain = Instance.new("Frame", ScreenGui); NoclipMain.Size = UDim2.new(0, 260, 0, 100); NoclipMain.Position = UDim2.new(0, 20, 0, 260); NoclipMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); NoclipMain.BorderSizePixel = 0; NoclipMain.ClipsDescendants = true; NoclipMain.Visible = false; Instance.new("UICorner", NoclipMain).CornerRadius = UDim.new(0, 6); NoclipMainStroke = Instance.new("UIStroke", NoclipMain); NoclipMainStroke.Color = borderDark
NoclipTopBar = Instance.new("Frame", NoclipMain); NoclipTopBar.Size = UDim2.new(1, 0, 0, 35); NoclipTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); NoclipTopBar.BorderSizePixel = 0; Instance.new("UICorner", NoclipTopBar).CornerRadius = UDim.new(0, 6)
NoclipFix = Instance.new("Frame", NoclipTopBar); NoclipFix.Size = UDim2.new(1, 0, 0, 5); NoclipFix.Position = UDim2.new(0, 0, 1, -5); NoclipFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); NoclipFix.BorderSizePixel = 0
NoclipTitle = Instance.new("TextLabel", NoclipTopBar); NoclipTitle.Size = UDim2.new(1, -70, 1, 0); NoclipTitle.Position = UDim2.new(0, 15, 0, 0); NoclipTitle.BackgroundTransparency = 1; NoclipTitle.Text = "NOCLIP WALK"; NoclipTitle.TextColor3 = tWhite; NoclipTitle.Font = Enum.Font.GothamBold; NoclipTitle.TextSize = 13; NoclipTitle.TextXAlignment = Enum.TextXAlignment.Left
NoclipMinBtn = Instance.new("TextButton", NoclipTopBar); NoclipMinBtn.Size = UDim2.new(0, 35, 1, 0); NoclipMinBtn.Position = UDim2.new(1, -70, 0, 0); NoclipMinBtn.BackgroundTransparency = 1; NoclipMinBtn.Text = "—"; NoclipMinBtn.TextColor3 = tGreen; NoclipMinBtn.Font = Enum.Font.GothamBlack; NoclipMinBtn.TextSize = 14
NoclipCloseBtn = Instance.new("TextButton", NoclipTopBar); NoclipCloseBtn.Size = UDim2.new(0, 35, 1, 0); NoclipCloseBtn.Position = UDim2.new(1, -35, 0, 0); NoclipCloseBtn.BackgroundTransparency = 1; NoclipCloseBtn.Text = "X"; NoclipCloseBtn.TextColor3 = tRed; NoclipCloseBtn.Font = Enum.Font.GothamBlack; NoclipCloseBtn.TextSize = 12

NoclipToggleBtn = Instance.new("TextButton", NoclipMain); NoclipToggleBtn.Size = UDim2.new(1, -75, 0, 45); NoclipToggleBtn.Position = UDim2.new(0, 10, 0, 45); NoclipToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); NoclipToggleBtn.Text = "NOCLIP: OFF"; NoclipToggleBtn.TextColor3 = tWhite; NoclipToggleBtn.Font = Enum.Font.GothamBold; NoclipToggleBtn.TextSize = 12; Instance.new("UICorner", NoclipToggleBtn).CornerRadius = UDim.new(0, 6)
NoclipKeyBtn = Instance.new("TextButton", NoclipMain); NoclipKeyBtn.Size = UDim2.new(0, 50, 0, 45); NoclipKeyBtn.Position = UDim2.new(1, -60, 0, 45); NoclipKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); NoclipKeyBtn.Text = "KEY"; NoclipKeyBtn.TextColor3 = tWhite; NoclipKeyBtn.Font = Enum.Font.GothamBold; NoclipKeyBtn.TextSize = 11; Instance.new("UICorner", NoclipKeyBtn).CornerRadius = UDim.new(0, 6)

ApplyResponsiveScale(NoclipMain); MakeDraggable(NoclipTopBar, NoclipMain)

local noclipMinimized = false
NoclipMinBtn.MouseButton1Click:Connect(function()
    noclipMinimized = not noclipMinimized; NoclipMain:TweenSize(noclipMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 100), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    NoclipMinBtn.Text = noclipMinimized and "+" or "—"; NoclipFix.Visible = not noclipMinimized
end)

local isNoclipActive = false; local noclipLoop = nil; local noclipFloor = nil; local noclipKeybind = nil; local isNoclipBinding = false

ToggleNoclipWalk = function()
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

NoclipCloseBtn.MouseButton1Click:Connect(function() 
    NoclipMain.Visible = false; noclipKeybind = nil; isNoclipBinding = false; NoclipKeyBtn.Text = "KEY"; NoclipKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) 
    if isNoclipActive then ToggleNoclipWalk() end
end)
NoclipKeyBtn.MouseButton1Click:Connect(function()
    if noclipKeybind ~= nil then noclipKeybind = nil; NoclipKeyBtn.Text = "KEY"; NoclipKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isNoclipBinding = false
    else isNoclipBinding = true; NoclipKeyBtn.Text = "..."; NoclipKeyBtn.BackgroundColor3 = tOrange end
end)

-- ==================================================================
-- 7. VEHICLE FLY (ZACH'S SCRIPT LERP)
-- ==================================================================
VFlyMain = Instance.new("Frame", ScreenGui); VFlyMain.Size = UDim2.new(0, 260, 0, 145); VFlyMain.Position = UDim2.new(0, 20, 0, 380); VFlyMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); VFlyMain.BorderSizePixel = 0; VFlyMain.ClipsDescendants = true; VFlyMain.Visible = false; Instance.new("UICorner", VFlyMain).CornerRadius = UDim.new(0, 6); VFlyMainStroke = Instance.new("UIStroke", VFlyMain); VFlyMainStroke.Color = borderDark
VFlyTopBar = Instance.new("Frame", VFlyMain); VFlyTopBar.Size = UDim2.new(1, 0, 0, 35); VFlyTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); VFlyTopBar.BorderSizePixel = 0; Instance.new("UICorner", VFlyTopBar).CornerRadius = UDim.new(0, 6)
VFlyFix = Instance.new("Frame", VFlyTopBar); VFlyFix.Size = UDim2.new(1, 0, 0, 5); VFlyFix.Position = UDim2.new(0, 0, 1, -5); VFlyFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); VFlyFix.BorderSizePixel = 0
VFlyTitle = Instance.new("TextLabel", VFlyTopBar); VFlyTitle.Size = UDim2.new(1, -70, 1, 0); VFlyTitle.Position = UDim2.new(0, 15, 0, 0); VFlyTitle.BackgroundTransparency = 1; VFlyTitle.Text = "VEHICLE FLY"; VFlyTitle.TextColor3 = tWhite; VFlyTitle.Font = Enum.Font.GothamBold; VFlyTitle.TextSize = 13; VFlyTitle.TextXAlignment = Enum.TextXAlignment.Left
VFlyMinBtn = Instance.new("TextButton", VFlyTopBar); VFlyMinBtn.Size = UDim2.new(0, 35, 1, 0); VFlyMinBtn.Position = UDim2.new(1, -70, 0, 0); VFlyMinBtn.BackgroundTransparency = 1; VFlyMinBtn.Text = "—"; VFlyMinBtn.TextColor3 = tGreen; VFlyMinBtn.Font = Enum.Font.GothamBlack; VFlyMinBtn.TextSize = 14
VFlyCloseBtn = Instance.new("TextButton", VFlyTopBar); VFlyCloseBtn.Size = UDim2.new(0, 35, 1, 0); VFlyCloseBtn.Position = UDim2.new(1, -35, 0, 0); VFlyCloseBtn.BackgroundTransparency = 1; VFlyCloseBtn.Text = "X"; VFlyCloseBtn.TextColor3 = tRed; VFlyCloseBtn.Font = Enum.Font.GothamBlack; VFlyCloseBtn.TextSize = 12

VFlyToggleBtn = Instance.new("TextButton", VFlyMain); VFlyToggleBtn.Size = UDim2.new(1, -75, 0, 45); VFlyToggleBtn.Position = UDim2.new(0, 10, 0, 45); VFlyToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); VFlyToggleBtn.Text = "V-FLY: OFF"; VFlyToggleBtn.TextColor3 = tWhite; VFlyToggleBtn.Font = Enum.Font.GothamBold; VFlyToggleBtn.TextSize = 12; Instance.new("UICorner", VFlyToggleBtn).CornerRadius = UDim.new(0, 6)
VFlyKeyBtn = Instance.new("TextButton", VFlyMain); VFlyKeyBtn.Size = UDim2.new(0, 50, 0, 45); VFlyKeyBtn.Position = UDim2.new(1, -60, 0, 45); VFlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); VFlyKeyBtn.Text = "KEY"; VFlyKeyBtn.TextColor3 = tWhite; VFlyKeyBtn.Font = Enum.Font.GothamBold; VFlyKeyBtn.TextSize = 11; Instance.new("UICorner", VFlyKeyBtn).CornerRadius = UDim.new(0, 6)

VFlySpeedMinus = Instance.new("TextButton", VFlyMain); VFlySpeedMinus.Size = UDim2.new(0, 40, 0, 35); VFlySpeedMinus.Position = UDim2.new(0, 10, 0, 100); VFlySpeedMinus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); VFlySpeedMinus.Text = "-"; VFlySpeedMinus.TextColor3 = tWhite; VFlySpeedMinus.Font = Enum.Font.GothamBold; Instance.new("UICorner", VFlySpeedMinus)
VFlySpeedDisplay = Instance.new("TextBox", VFlyMain); VFlySpeedDisplay.Size = UDim2.new(1, -110, 0, 35); VFlySpeedDisplay.Position = UDim2.new(0, 55, 0, 100); VFlySpeedDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 25); VFlySpeedDisplay.Text = ""; VFlySpeedDisplay.PlaceholderText = "SPEED: 256"; VFlySpeedDisplay.TextColor3 = tWhite; VFlySpeedDisplay.Font = Enum.Font.GothamSemibold; VFlySpeedDisplay.TextSize = 14; VFlySpeedDisplay.ClearTextOnFocus = true; Instance.new("UICorner", VFlySpeedDisplay); Instance.new("UIStroke", VFlySpeedDisplay).Color = Color3.fromRGB(50, 50, 50)
VFlySpeedPlus = Instance.new("TextButton", VFlyMain); VFlySpeedPlus.Size = UDim2.new(0, 40, 0, 35); VFlySpeedPlus.Position = UDim2.new(1, -50, 0, 100); VFlySpeedPlus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); VFlySpeedPlus.Text = "+"; VFlySpeedPlus.TextColor3 = tWhite; VFlySpeedPlus.Font = Enum.Font.GothamBold; Instance.new("UICorner", VFlySpeedPlus)

ApplyResponsiveScale(VFlyMain); MakeDraggable(VFlyTopBar, VFlyMain)

local vflyMinimized = false
VFlyMinBtn.MouseButton1Click:Connect(function()
    vflyMinimized = not vflyMinimized; VFlyMain:TweenSize(vflyMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 145), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    VFlyMinBtn.Text = vflyMinimized and "+" or "—"; VFlyFix.Visible = not vflyMinimized
end)

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

ToggleVFly = function()
    isVFlying = not isVFlying; local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
    if isVFlying then
        VFlyToggleBtn.BackgroundColor3 = tPurple; VFlyToggleBtn.Text = "V-FLY: ON"
        if root then vFlyCurrentVel = root.Velocity end; table.insert(GlobalConnections, RunService.Heartbeat:Connect(VFlyLoop))
    else
        VFlyToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); VFlyToggleBtn.Text = "V-FLY: OFF"
        if vFlyConn then vFlyConn:Disconnect(); vFlyConn = nil end
    end
end
VFlyToggleBtn.MouseButton1Click:Connect(ToggleVFly)

VFlyCloseBtn.MouseButton1Click:Connect(function() 
    VFlyMain.Visible = false; vFlyKeybind = nil; isVFlyBinding = false; VFlyKeyBtn.Text = "KEY"; VFlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) 
    if isVFlying then ToggleVFly() end
end)
VFlyKeyBtn.MouseButton1Click:Connect(function()
    if vFlyKeybind ~= nil then vFlyKeybind = nil; VFlyKeyBtn.Text = "KEY"; VFlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isVFlyBinding = false
    else isVFlyBinding = true; VFlyKeyBtn.Text = "..."; VFlyKeyBtn.BackgroundColor3 = tOrange end
end)

-- ==================================================================
-- 8. TRIP MODE MENU (CAÍDA INFINITA + LEVANTARSE)
-- ==================================================================
TripMain = Instance.new("Frame", ScreenGui); TripMain.Size = UDim2.new(0, 260, 0, 100); TripMain.Position = UDim2.new(0, 20, 0, 540); TripMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); TripMain.BorderSizePixel = 0; TripMain.ClipsDescendants = true; TripMain.Visible = false; Instance.new("UICorner", TripMain).CornerRadius = UDim.new(0, 6); TripMainStroke = Instance.new("UIStroke", TripMain); TripMainStroke.Color = borderDark
TripTopBar = Instance.new("Frame", TripMain); TripTopBar.Size = UDim2.new(1, 0, 0, 35); TripTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TripTopBar.BorderSizePixel = 0; Instance.new("UICorner", TripTopBar).CornerRadius = UDim.new(0, 6)
TripFix = Instance.new("Frame", TripTopBar); TripFix.Size = UDim2.new(1, 0, 0, 5); TripFix.Position = UDim2.new(0, 0, 1, -5); TripFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TripFix.BorderSizePixel = 0
TripTitle = Instance.new("TextLabel", TripTopBar); TripTitle.Size = UDim2.new(1, -70, 1, 0); TripTitle.Position = UDim2.new(0, 15, 0, 0); TripTitle.BackgroundTransparency = 1; TripTitle.Text = "TRIP MODE"; TripTitle.TextColor3 = tWhite; TripTitle.Font = Enum.Font.GothamBold; TripTitle.TextSize = 13; TripTitle.TextXAlignment = Enum.TextXAlignment.Left
TripMinBtn = Instance.new("TextButton", TripTopBar); TripMinBtn.Size = UDim2.new(0, 35, 1, 0); TripMinBtn.Position = UDim2.new(1, -70, 0, 0); TripMinBtn.BackgroundTransparency = 1; TripMinBtn.Text = "—"; TripMinBtn.TextColor3 = tGreen; TripMinBtn.Font = Enum.Font.GothamBlack; TripMinBtn.TextSize = 14
TripCloseBtn = Instance.new("TextButton", TripTopBar); TripCloseBtn.Size = UDim2.new(0, 35, 1, 0); TripCloseBtn.Position = UDim2.new(1, -35, 0, 0); TripCloseBtn.BackgroundTransparency = 1; TripCloseBtn.Text = "X"; TripCloseBtn.TextColor3 = tRed; TripCloseBtn.Font = Enum.Font.GothamBlack; TripCloseBtn.TextSize = 12

TripToggleBtn = Instance.new("TextButton", TripMain); TripToggleBtn.Size = UDim2.new(1, -75, 0, 45); TripToggleBtn.Position = UDim2.new(0, 10, 0, 45); TripToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TripToggleBtn.Text = "TRIP (CLICK)"; TripToggleBtn.TextColor3 = tWhite; TripToggleBtn.Font = Enum.Font.GothamBold; TripToggleBtn.TextSize = 12; Instance.new("UICorner", TripToggleBtn).CornerRadius = UDim.new(0, 6)
TripKeyBtn = Instance.new("TextButton", TripMain); TripKeyBtn.Size = UDim2.new(0, 50, 0, 45); TripKeyBtn.Position = UDim2.new(1, -60, 0, 45); TripKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); TripKeyBtn.Text = "KEY"; TripKeyBtn.TextColor3 = tWhite; TripKeyBtn.Font = Enum.Font.GothamBold; TripKeyBtn.TextSize = 11; Instance.new("UICorner", TripKeyBtn).CornerRadius = UDim.new(0, 6)

ApplyResponsiveScale(TripMain); MakeDraggable(TripTopBar, TripMain)

local tripMinimized = false
TripMinBtn.MouseButton1Click:Connect(function()
    tripMinimized = not tripMinimized; TripMain:TweenSize(tripMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 100), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    TripMinBtn.Text = tripMinimized and "+" or "—"; TripFix.Visible = not tripMinimized
end)

local tripKeybind = nil; local isTripBinding = false; local tripStateConn = nil 
isTripped = false

local function CleanTripConnections()
    if tripStateConn then tripStateConn:Disconnect(); tripStateConn = nil end
end

GetUpFromTrip = function(autoClean)
    if not isTripped then return end
    isTripped = false
    CleanTripConnections()
    
    TripToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TripToggleBtn.TextColor3 = tWhite; TripToggleBtn.Text = "TRIP (CLICK)"

    local char = LocalPlayer.Character; if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    humanoid.PlatformStand = false
    humanoid.AutoRotate = true

    if not autoClean then
        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + Vector3.new(0, 10, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CustomPhysicalProperties = nil end
    end
end

DoTrip = function()
    if isTripped then return end
    local char = LocalPlayer.Character; if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    isTripped = true 
    CleanTripConnections()
    
    tripStateConn = humanoid.StateChanged:Connect(function(oldState, newState)
        if not isTripped then return end
        if newState == Enum.HumanoidStateType.Running or newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Walking or newState == Enum.HumanoidStateType.Dead then
            GetUpFromTrip(true)
        end
    end)
    
    TripToggleBtn.BackgroundColor3 = tRed; TripToggleBtn.TextColor3 = tWhite; TripToggleBtn.Text = "LEVANTARSE (CLICK)"

    local currentVelocity = root.AssemblyLinearVelocity
    local speed = currentVelocity.Magnitude

    humanoid.PlatformStand = true
    humanoid.AutoRotate = false

    local impulso = (speed > 5) and (currentVelocity * 1.3) or (root.CFrame.LookVector * 10)
    root.AssemblyLinearVelocity = impulso + Vector3.new(0, 8, 0)
    local spin = speed > 5 and 20 or 10
    root.AssemblyAngularVelocity = Vector3.new(math.random(-spin, spin), math.random(-spin, spin), math.random(-spin, spin))

    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.1, 0.1, 1, 1) end
    end
end

TripToggleBtn.MouseButton1Click:Connect(function()
    if isTripped then GetUpFromTrip(false) else DoTrip() end
end)
TripCloseBtn.MouseButton1Click:Connect(function() 
    TripMain.Visible = false; tripKeybind = nil; isTripBinding = false; TripKeyBtn.Text = "KEY"; TripKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) 
    if isTripped then GetUpFromTrip(false) end
end)
TripKeyBtn.MouseButton1Click:Connect(function()
    if tripKeybind ~= nil then tripKeybind = nil; TripKeyBtn.Text = "KEY"; TripKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isTripBinding = false
    else isTripBinding = true; TripKeyBtn.Text = "..."; TripKeyBtn.BackgroundColor3 = tOrange end
end)

-- ==================================================================
-- 13. REVERSE MODE (FLASHBACK / TIME REWIND) + FIX DE KEYBIND
-- ==================================================================
ReverseMain = Instance.new("Frame", ScreenGui); ReverseMain.Size = UDim2.new(0, 260, 0, 145); ReverseMain.Position = UDim2.new(0, 20, 0, 660); ReverseMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); ReverseMain.BorderSizePixel = 0; ReverseMain.ClipsDescendants = true; ReverseMain.Visible = false; Instance.new("UICorner", ReverseMain).CornerRadius = UDim.new(0, 6); ReverseMainStroke = Instance.new("UIStroke", ReverseMain); ReverseMainStroke.Color = borderDark
ReverseTopBar = Instance.new("Frame", ReverseMain); ReverseTopBar.Size = UDim2.new(1, 0, 0, 35); ReverseTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); ReverseTopBar.BorderSizePixel = 0; Instance.new("UICorner", ReverseTopBar).CornerRadius = UDim.new(0, 6)
ReverseFix = Instance.new("Frame", ReverseTopBar); ReverseFix.Size = UDim2.new(1, 0, 0, 5); ReverseFix.Position = UDim2.new(0, 0, 1, -5); ReverseFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); ReverseFix.BorderSizePixel = 0
ReverseTitle = Instance.new("TextLabel", ReverseTopBar); ReverseTitle.Size = UDim2.new(1, -70, 1, 0); ReverseTitle.Position = UDim2.new(0, 15, 0, 0); ReverseTitle.BackgroundTransparency = 1; ReverseTitle.Text = "REVERSE (FLASHBACK)"; ReverseTitle.TextColor3 = tWhite; ReverseTitle.Font = Enum.Font.GothamBold; ReverseTitle.TextSize = 13; ReverseTitle.TextXAlignment = Enum.TextXAlignment.Left
ReverseMinBtn = Instance.new("TextButton", ReverseTopBar); ReverseMinBtn.Size = UDim2.new(0, 35, 1, 0); ReverseMinBtn.Position = UDim2.new(1, -70, 0, 0); ReverseMinBtn.BackgroundTransparency = 1; ReverseMinBtn.Text = "—"; ReverseMinBtn.TextColor3 = tGreen; ReverseMinBtn.Font = Enum.Font.GothamBlack; ReverseMinBtn.TextSize = 14
ReverseCloseBtn = Instance.new("TextButton", ReverseTopBar); ReverseCloseBtn.Size = UDim2.new(0, 35, 1, 0); ReverseCloseBtn.Position = UDim2.new(1, -35, 0, 0); ReverseCloseBtn.BackgroundTransparency = 1; ReverseCloseBtn.Text = "X"; ReverseCloseBtn.TextColor3 = tRed; ReverseCloseBtn.Font = Enum.Font.GothamBlack; ReverseCloseBtn.TextSize = 12

ReverseToggleBtn = Instance.new("TextButton", ReverseMain); ReverseToggleBtn.Size = UDim2.new(1, -75, 0, 40); ReverseToggleBtn.Position = UDim2.new(0, 10, 0, 45); ReverseToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); ReverseToggleBtn.Text = "SISTEMA: OFF"; ReverseToggleBtn.TextColor3 = tWhite; ReverseToggleBtn.Font = Enum.Font.GothamBold; ReverseToggleBtn.TextSize = 12; Instance.new("UICorner", ReverseToggleBtn).CornerRadius = UDim.new(0, 6)
ReverseKeyBtn = Instance.new("TextButton", ReverseMain); ReverseKeyBtn.Size = UDim2.new(0, 50, 0, 40); ReverseKeyBtn.Position = UDim2.new(1, -60, 0, 45); ReverseKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); ReverseKeyBtn.Text = "KEY"; ReverseKeyBtn.TextColor3 = tWhite; ReverseKeyBtn.Font = Enum.Font.GothamBold; ReverseKeyBtn.TextSize = 11; Instance.new("UICorner", ReverseKeyBtn).CornerRadius = UDim.new(0, 6)

ReverseActionBtn = Instance.new("TextButton", ReverseMain); ReverseActionBtn.Size = UDim2.new(1, -20, 0, 45); ReverseActionBtn.Position = UDim2.new(0, 10, 0, 90); ReverseActionBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); ReverseActionBtn.Text = "⏮ MANTENER PARA REBOBINAR"; ReverseActionBtn.TextColor3 = Color3.fromRGB(150, 150, 150); ReverseActionBtn.Font = Enum.Font.GothamBold; ReverseActionBtn.TextSize = 11; ReverseActionBtn.AutoButtonColor = false; Instance.new("UICorner", ReverseActionBtn).CornerRadius = UDim.new(0, 6)

ApplyResponsiveScale(ReverseMain); MakeDraggable(ReverseTopBar, ReverseMain)

local reverseMinimized = false
ReverseMinBtn.MouseButton1Click:Connect(function()
    reverseMinimized = not reverseMinimized; ReverseMain:TweenSize(reverseMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 145), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    ReverseMinBtn.Text = reverseMinimized and "+" or "—"; ReverseFix.Visible = not reverseMinimized
end)

local isReverseActive = false; local reverseKeybind = nil; local isReverseBinding = false; local isMobileRewinding = false
local flashbacklength = 500; local flashbackspeed = 2; local frames = {}
local flashbackName = "CDT_FlashbackSystem"
local flashback = { lastinput = false, canrevert = true }

local function CleanCharacterState(char, hrp, hum)
    if not char or not hrp or not hum then return end
    hum.PlatformStand = false; hum.AutoRotate = true
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    hum:ChangeState(Enum.HumanoidStateType.Running)
    for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CustomPhysicalProperties = nil end end
end

function flashback:Advance(char, hrp, hum, allowinput)
    if #frames > flashbacklength * 60 then table.remove(frames, 1) end
    if allowinput and not self.canrevert then self.canrevert = true end
    if self.lastinput then CleanCharacterState(char, hrp, hum); self.lastinput = false end
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

ToggleReverse = function()
    isReverseActive = not isReverseActive
    local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
    if isReverseActive then
        ReverseToggleBtn.BackgroundColor3 = tCyan; ReverseToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10); ReverseToggleBtn.Text = "SISTEMA: ON"; frames = {}
        ReverseActionBtn.TextColor3 = tWhite; ReverseActionBtn.BackgroundColor3 = tPurple
        RunService:BindToRenderStep(flashbackName, 1, function()
            local char2 = LocalPlayer.Character; if not char2 then return end
            local hrp2 = char2:FindFirstChild("HumanoidRootPart"); local hum2 = char2:FindFirstChildOfClass("Humanoid")
            if not hrp2 or not hum2 then return end
            if (reverseKeybind and UserInputService:IsKeyDown(reverseKeybind)) or isMobileRewinding then
                flashback:Revert(char2, hrp2, hum2)
            else
                flashback:Advance(char2, hrp2, hum2, true)
            end
        end)
    else
        ReverseToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); ReverseToggleBtn.TextColor3 = tWhite; ReverseToggleBtn.Text = "SISTEMA: OFF"
        ReverseActionBtn.TextColor3 = Color3.fromRGB(150, 150, 150); ReverseActionBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        isMobileRewinding = false
        RunService:UnbindFromRenderStep(flashbackName); frames = {}
        if char and hrp and hum then CleanCharacterState(char, hrp, hum) end
    end
end
ReverseToggleBtn.MouseButton1Click:Connect(ToggleReverse)

table.insert(GlobalConnections, ReverseActionBtn.InputBegan:Connect(function(input)
    if not isReverseActive then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isMobileRewinding = true; ReverseActionBtn.BackgroundColor3 = tCyan; ReverseActionBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
    end
end))
table.insert(GlobalConnections, ReverseActionBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isMobileRewinding = false; if isReverseActive then ReverseActionBtn.BackgroundColor3 = tPurple; ReverseActionBtn.TextColor3 = tWhite end
    end
end))
ReverseCloseBtn.MouseButton1Click:Connect(function() 
    ReverseMain.Visible = false; reverseKeybind = nil; isReverseBinding = false; ReverseKeyBtn.Text = "KEY"; ReverseKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isMobileRewinding = false 
    if isReverseActive then ToggleReverse() end
end)
ReverseKeyBtn.MouseButton1Click:Connect(function()
    if reverseKeybind ~= nil then reverseKeybind = nil; ReverseKeyBtn.Text = "KEY"; ReverseKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isReverseBinding = false
    else isReverseBinding = true; ReverseKeyBtn.Text = "..."; ReverseKeyBtn.BackgroundColor3 = tOrange end
end)

-- ==================================================================
-- 14. FREECAM MENU (EXPLORACIÓN LIBRE + SHIFT LOCK FIX)
-- ==================================================================
FreecamMain = Instance.new("Frame", ScreenGui); FreecamMain.Size = UDim2.new(0, 260, 0, 145); FreecamMain.Position = UDim2.new(0, 20, 0, 140); FreecamMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); FreecamMain.BorderSizePixel = 0; FreecamMain.ClipsDescendants = true; FreecamMain.Visible = false; Instance.new("UICorner", FreecamMain).CornerRadius = UDim.new(0, 6); FreecamMainStroke = Instance.new("UIStroke", FreecamMain); FreecamMainStroke.Color = borderDark
FreecamTopBar = Instance.new("Frame", FreecamMain); FreecamTopBar.Size = UDim2.new(1, 0, 0, 35); FreecamTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); FreecamTopBar.BorderSizePixel = 0; Instance.new("UICorner", FreecamTopBar).CornerRadius = UDim.new(0, 6)
FreecamFix = Instance.new("Frame", FreecamTopBar); FreecamFix.Size = UDim2.new(1, 0, 0, 5); FreecamFix.Position = UDim2.new(0, 0, 1, -5); FreecamFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); FreecamFix.BorderSizePixel = 0
FreecamTitle = Instance.new("TextLabel", FreecamTopBar); FreecamTitle.Size = UDim2.new(1, -70, 1, 0); FreecamTitle.Position = UDim2.new(0, 15, 0, 0); FreecamTitle.BackgroundTransparency = 1; FreecamTitle.Text = "FREECAM"; FreecamTitle.TextColor3 = tWhite; FreecamTitle.Font = Enum.Font.GothamBold; FreecamTitle.TextSize = 13; FreecamTitle.TextXAlignment = Enum.TextXAlignment.Left
FreecamMinBtn = Instance.new("TextButton", FreecamTopBar); FreecamMinBtn.Size = UDim2.new(0, 35, 1, 0); FreecamMinBtn.Position = UDim2.new(1, -70, 0, 0); FreecamMinBtn.BackgroundTransparency = 1; FreecamMinBtn.Text = "—"; FreecamMinBtn.TextColor3 = tGreen; FreecamMinBtn.Font = Enum.Font.GothamBlack; FreecamMinBtn.TextSize = 14
FreecamCloseBtn = Instance.new("TextButton", FreecamTopBar); FreecamCloseBtn.Size = UDim2.new(0, 35, 1, 0); FreecamCloseBtn.Position = UDim2.new(1, -35, 0, 0); FreecamCloseBtn.BackgroundTransparency = 1; FreecamCloseBtn.Text = "X"; FreecamCloseBtn.TextColor3 = tRed; FreecamCloseBtn.Font = Enum.Font.GothamBlack; FreecamCloseBtn.TextSize = 12

FreecamToggleBtn = Instance.new("TextButton", FreecamMain); FreecamToggleBtn.Size = UDim2.new(1, -75, 0, 45); FreecamToggleBtn.Position = UDim2.new(0, 10, 0, 45); FreecamToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); FreecamToggleBtn.Text = "FREECAM: OFF"; FreecamToggleBtn.TextColor3 = tWhite; FreecamToggleBtn.Font = Enum.Font.GothamBold; FreecamToggleBtn.TextSize = 12; Instance.new("UICorner", FreecamToggleBtn).CornerRadius = UDim.new(0, 6)
FreecamKeyBtn = Instance.new("TextButton", FreecamMain); FreecamKeyBtn.Size = UDim2.new(0, 50, 0, 45); FreecamKeyBtn.Position = UDim2.new(1, -60, 0, 45); FreecamKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FreecamKeyBtn.Text = "KEY"; FreecamKeyBtn.TextColor3 = tWhite; FreecamKeyBtn.Font = Enum.Font.GothamBold; FreecamKeyBtn.TextSize = 11; Instance.new("UICorner", FreecamKeyBtn).CornerRadius = UDim.new(0, 6)

FreecamSpeedMinus = Instance.new("TextButton", FreecamMain); FreecamSpeedMinus.Size = UDim2.new(0, 40, 0, 35); FreecamSpeedMinus.Position = UDim2.new(0, 10, 0, 100); FreecamSpeedMinus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FreecamSpeedMinus.Text = "-"; FreecamSpeedMinus.TextColor3 = tWhite; FreecamSpeedMinus.Font = Enum.Font.GothamBold; Instance.new("UICorner", FreecamSpeedMinus)
FreecamSpeedDisplay = Instance.new("TextBox", FreecamMain); FreecamSpeedDisplay.Size = UDim2.new(1, -110, 0, 35); FreecamSpeedDisplay.Position = UDim2.new(0, 55, 0, 100); FreecamSpeedDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 25); FreecamSpeedDisplay.Text = ""; FreecamSpeedDisplay.PlaceholderText = "SPEED: 60"; FreecamSpeedDisplay.TextColor3 = tWhite; FreecamSpeedDisplay.Font = Enum.Font.GothamSemibold; FreecamSpeedDisplay.TextSize = 14; FreecamSpeedDisplay.ClearTextOnFocus = true; Instance.new("UICorner", FreecamSpeedDisplay); Instance.new("UIStroke", FreecamSpeedDisplay).Color = Color3.fromRGB(50, 50, 50)
FreecamSpeedPlus = Instance.new("TextButton", FreecamMain); FreecamSpeedPlus.Size = UDim2.new(0, 40, 0, 35); FreecamSpeedPlus.Position = UDim2.new(1, -50, 0, 100); FreecamSpeedPlus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FreecamSpeedPlus.Text = "+"; FreecamSpeedPlus.TextColor3 = tWhite; FreecamSpeedPlus.Font = Enum.Font.GothamBold; Instance.new("UICorner", FreecamSpeedPlus)

ApplyResponsiveScale(FreecamMain); MakeDraggable(FreecamTopBar, FreecamMain)

local fcMinimized = false
FreecamMinBtn.MouseButton1Click:Connect(function()
    fcMinimized = not fcMinimized; FreecamMain:TweenSize(fcMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 145), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    FreecamMinBtn.Text = fcMinimized and "+" or "—"; FreecamFix.Visible = not fcMinimized
end)

local isFreecamActive = false; local fcSpeed = 60; local fcSmoothness = 0.1; local fcKeybind = nil; local isFcBinding = false
local fcTargetCFrame = CFrame.new(); local fcVelocity = Vector3.zero; local fcPitch, fcYaw = 0, 0
local fcRenderConn, fcInputConn1, fcInputConn2; local isHoldingRightClick = false; local isShiftLocked = false

FreecamSpeedMinus.MouseButton1Click:Connect(function() fcSpeed = math.max(10, fcSpeed - 10); FreecamSpeedDisplay.Text = "SPEED: " .. fcSpeed end)
FreecamSpeedPlus.MouseButton1Click:Connect(function() fcSpeed = fcSpeed + 10; FreecamSpeedDisplay.Text = "SPEED: " .. fcSpeed end)
FreecamSpeedDisplay.FocusLost:Connect(function() local num = tonumber(FreecamSpeedDisplay.Text:match("%d+")); if num then fcSpeed = num end; FreecamSpeedDisplay.Text = "SPEED: " .. fcSpeed end)

local function getFCMovement()
    local vec = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then vec = vec + Vector3.new(0, 0, -1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then vec = vec + Vector3.new(0, 0, 1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then vec = vec + Vector3.new(-1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then vec = vec + Vector3.new(1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.E) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then vec = vec + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.Q) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vec = vec + Vector3.new(0, -1, 0) end
    return vec.Magnitude > 0 and vec.Unit or vec
end

ToggleFreecam = function()
    isFreecamActive = not isFreecamActive
    local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if isFreecamActive then
        FreecamToggleBtn.BackgroundColor3 = tCyan; FreecamToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10); FreecamToggleBtn.Text = "FREECAM: ON"
        if hrp then hrp.Anchored = true end
        
        fcTargetCFrame = Camera.CFrame
        local rx, ry, rz = Camera.CFrame:ToEulerAnglesYXZ()
        fcPitch, fcYaw = rx, ry
        Camera.CameraType = Enum.CameraType.Scriptable
        
        fcInputConn1 = UserInputService.InputBegan:Connect(function(input, gp)
            if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
                isShiftLocked = not isShiftLocked
                return
            end
            if gp then return end
            if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
                isHoldingRightClick = true
            end
        end)
        
        fcInputConn2 = UserInputService.InputEnded:Connect(function(input, gp)
            if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
                isHoldingRightClick = false
            end
        end)
        
        fcRenderConn = RunService.RenderStepped:Connect(function(dt)
            if isShiftLocked then UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            elseif isHoldingRightClick then UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
            else UserInputService.MouseBehavior = Enum.MouseBehavior.Default end

            if isShiftLocked or isHoldingRightClick then
                local delta = UserInputService:GetMouseDelta()
                fcPitch = math.clamp(fcPitch - delta.Y * 0.005, -math.rad(89), math.rad(89))
                fcYaw = fcYaw - delta.X * 0.005
            end

            local moveVec = getFCMovement()
            local rotCFrame = CFrame.new(Vector3.zero) * CFrame.Angles(0, fcYaw, 0) * CFrame.Angles(fcPitch, 0, 0)
            local targetVelocity = rotCFrame:VectorToWorldSpace(moveVec) * fcSpeed
            
            fcVelocity = fcVelocity:Lerp(targetVelocity, fcSmoothness)
            fcTargetCFrame = CFrame.new(fcTargetCFrame.Position + (fcVelocity * dt)) * rotCFrame
            Camera.CFrame = Camera.CFrame:Lerp(fcTargetCFrame, fcSmoothness)
        end)
    else
        FreecamToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); FreecamToggleBtn.TextColor3 = tWhite; FreecamToggleBtn.Text = "FREECAM: OFF"
        if hrp then hrp.Anchored = false end
        Camera.CameraType = Enum.CameraType.Custom
        if char and char:FindFirstChild("Humanoid") then Camera.CameraSubject = char.Humanoid end
        
        isHoldingRightClick = false; isShiftLocked = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        
        if fcInputConn1 then fcInputConn1:Disconnect() end
        if fcInputConn2 then fcInputConn2:Disconnect() end
        if fcRenderConn then fcRenderConn:Disconnect() end
    end
end
FreecamToggleBtn.MouseButton1Click:Connect(ToggleFreecam)

FreecamCloseBtn.MouseButton1Click:Connect(function() 
    FreecamMain.Visible = false; fcKeybind = nil; isFcBinding = false; FreecamKeyBtn.Text = "KEY"; FreecamKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    if isFreecamActive then ToggleFreecam() end
end)
FreecamKeyBtn.MouseButton1Click:Connect(function()
    if fcKeybind ~= nil then fcKeybind = nil; FreecamKeyBtn.Text = "KEY"; FreecamKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isFcBinding = false
    else isFcBinding = true; FreecamKeyBtn.Text = "..."; FreecamKeyBtn.BackgroundColor3 = tOrange end
end)
table.insert(GlobalConnections, UserInputService.InputBegan:Connect(function(input, gp)
    if isFcBinding and input.UserInputType == Enum.UserInputType.Keyboard then
        fcKeybind = input.KeyCode; FreecamKeyBtn.Text = input.KeyCode.Name; FreecamKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isFcBinding = false; return
    end
    if fcKeybind and input.KeyCode == fcKeybind and not UserInputService:GetFocusedTextBox() then ToggleFreecam() end
end))

-- ==================================================================
-- 17. ESP SYSTEM FULL + SPECTATOR + UNIVERSAL ENGINE (BULLETPROOF)
-- ==================================================================
ESPMain = Instance.new("Frame", ScreenGui); ESPMain.Size = UDim2.new(0, 260, 0, 350); ESPMain.Position = UDim2.new(0, 20, 0, 780); ESPMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); ESPMain.BorderSizePixel = 0; ESPMain.ClipsDescendants = true; ESPMain.Visible = false; Instance.new("UICorner", ESPMain).CornerRadius = UDim.new(0, 6); ESPMainStroke = Instance.new("UIStroke", ESPMain); ESPMainStroke.Color = borderDark
ESPTopBar = Instance.new("Frame", ESPMain); ESPTopBar.Size = UDim2.new(1, 0, 0, 35); ESPTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); ESPTopBar.BorderSizePixel = 0; Instance.new("UICorner", ESPTopBar).CornerRadius = UDim.new(0, 6)
ESPFix = Instance.new("Frame", ESPTopBar); ESPFix.Size = UDim2.new(1, 0, 0, 5); ESPFix.Position = UDim2.new(0, 0, 1, -5); ESPFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); ESPFix.BorderSizePixel = 0
ESPTitle = Instance.new("TextLabel", ESPTopBar); ESPTitle.Size = UDim2.new(1, -70, 1, 0); ESPTitle.Position = UDim2.new(0, 15, 0, 0); ESPTitle.BackgroundTransparency = 1; ESPTitle.Text = "ESP & SPECTATOR"; ESPTitle.TextColor3 = tWhite; ESPTitle.Font = Enum.Font.GothamBold; ESPTitle.TextSize = 13; ESPTitle.TextXAlignment = Enum.TextXAlignment.Left
ESPMinBtn = Instance.new("TextButton", ESPTopBar); ESPMinBtn.Size = UDim2.new(0, 35, 1, 0); ESPMinBtn.Position = UDim2.new(1, -70, 0, 0); ESPMinBtn.BackgroundTransparency = 1; ESPMinBtn.Text = "—"; ESPMinBtn.TextColor3 = tGreen; ESPMinBtn.Font = Enum.Font.GothamBlack; ESPMinBtn.TextSize = 14
ESPCloseBtn = Instance.new("TextButton", ESPTopBar); ESPCloseBtn.Size = UDim2.new(0, 35, 1, 0); ESPCloseBtn.Position = UDim2.new(1, -35, 0, 0); ESPCloseBtn.BackgroundTransparency = 1; ESPCloseBtn.Text = "X"; ESPCloseBtn.TextColor3 = tRed; ESPCloseBtn.Font = Enum.Font.GothamBlack; ESPCloseBtn.TextSize = 12

ESPScroll = Instance.new("ScrollingFrame", ESPMain); ESPScroll.Size = UDim2.new(1, 0, 1, -35); ESPScroll.Position = UDim2.new(0, 0, 0, 35); ESPScroll.BackgroundTransparency = 1; ESPScroll.BorderSizePixel = 0; ESPScroll.ScrollBarThickness = 3; ESPScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
local ESPListLayout = Instance.new("UIListLayout", ESPScroll); ESPListLayout.Padding = UDim.new(0, 5); ESPListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; ESPListLayout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", ESPScroll).PaddingTop = UDim.new(0, 10)

local function CreateESPToggle(name, defaultText, isMaster)
    local btn = Instance.new("TextButton", ESPScroll)
    btn.Size = isMaster and UDim2.new(1, -20, 0, 35) or UDim2.new(1, -20, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = defaultText; btn.TextColor3 = tWhite; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    return btn
end

-- Toggles
ESPMasterBtn = CreateESPToggle("Master", "ESP MASTER: OFF", true)
ESPBoxBtn = CreateESPToggle("Box", "BOX: OFF", false)
ESPLineBtn = CreateESPToggle("Line", "LÍNEAS (TRACERS): OFF", false)
ESPNameBtn = CreateESPToggle("Name", "NOMBRE: OFF", false)
ESPDistBtn = CreateESPToggle("Dist", "DISTANCIA: OFF", false)
ESPSkelBtn = CreateESPToggle("Skel", "ESQUELETO: OFF", false)
ESPTeamBtn = CreateESPToggle("Team", "TEAM CHECK: ON", false); ESPTeamBtn.BackgroundColor3 = tGreen; ESPTeamBtn.TextColor3 = Color3.fromRGB(10,10,10)
ESPFriendsBtn = CreateESPToggle("Friends", "SOLO AMIGOS: OFF", false)

-- Color Palette
local ColorLabel = Instance.new("TextLabel", ESPScroll); ColorLabel.Size = UDim2.new(1, -20, 0, 20); ColorLabel.BackgroundTransparency = 1; ColorLabel.Text = "COLOR DEL ESP:"; ColorLabel.TextColor3 = tWhite; ColorLabel.Font = Enum.Font.GothamBold; ColorLabel.TextSize = 11; ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
local PaletteFrame = Instance.new("Frame", ESPScroll); PaletteFrame.Size = UDim2.new(1, -20, 0, 30); PaletteFrame.BackgroundTransparency = 1
local PList = Instance.new("UIListLayout", PaletteFrame); PList.FillDirection = Enum.FillDirection.Horizontal; PList.Padding = UDim.new(0, 8); PList.HorizontalAlignment = Enum.HorizontalAlignment.Center
local Colores = {tRed, tGreen, tCyan, tPurple, tYellow, tWhite}
for _, col in ipairs(Colores) do
    local cBtn = Instance.new("TextButton", PaletteFrame); cBtn.Size = UDim2.new(0, 30, 0, 30); cBtn.BackgroundColor3 = col; cBtn.Text = ""; Instance.new("UICorner", cBtn).CornerRadius = UDim.new(1, 0); Instance.new("UIStroke", cBtn).Color = tWhite; Instance.new("UIStroke", cBtn).Thickness = 0
    cBtn.MouseButton1Click:Connect(function() 
        for _, b in ipairs(PaletteFrame:GetChildren()) do if b:IsA("TextButton") then b.UIStroke.Thickness = 0 end end
        cBtn.UIStroke.Thickness = 2; espColor = col 
    end)
    if col == tRed then cBtn.UIStroke.Thickness = 2 end
end

-- Spectator Section
local SpecDiv = Instance.new("Frame", ESPScroll); SpecDiv.Size = UDim2.new(1, -40, 0, 2); SpecDiv.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
local SpecLabel = Instance.new("TextLabel", ESPScroll); SpecLabel.Size = UDim2.new(1, -20, 0, 20); SpecLabel.BackgroundTransparency = 1; SpecLabel.Text = "--- MODO ESPECTADOR ---"; SpecLabel.TextColor3 = tYellow; SpecLabel.Font = Enum.Font.GothamBold; SpecLabel.TextSize = 12
local SpecTargetLabel = Instance.new("TextLabel", ESPScroll); SpecTargetLabel.Size = UDim2.new(1, -20, 0, 20); SpecTargetLabel.BackgroundTransparency = 1; SpecTargetLabel.Text = "OBJETIVO: NINGUNO"; SpecTargetLabel.TextColor3 = tWhite; SpecTargetLabel.Font = Enum.Font.Gotham; SpecTargetLabel.TextSize = 11
local SpecToggleBtn = CreateESPToggle("Spec", "ESPECTAR: OFF", true)
local SpecListFrame = Instance.new("Frame", ESPScroll); SpecListFrame.Size = UDim2.new(1, -20, 0, 150); SpecListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UICorner", SpecListFrame).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", SpecListFrame).Color = Color3.fromRGB(40,40,40)
local SpecListScroll = Instance.new("ScrollingFrame", SpecListFrame); SpecListScroll.Size = UDim2.new(1, 0, 1, 0); SpecListScroll.BackgroundTransparency = 1; SpecListScroll.BorderSizePixel = 0; SpecListScroll.ScrollBarThickness = 2
local SpecListLayout = Instance.new("UIListLayout", SpecListScroll); SpecListLayout.Padding = UDim.new(0, 2)

ApplyResponsiveScale(ESPMain); MakeDraggable(ESPTopBar, ESPMain)

local espMinimized = false
ESPMinBtn.MouseButton1Click:Connect(function()
    espMinimized = not espMinimized; ESPMain:TweenSize(espMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 350), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    ESPMinBtn.Text = espMinimized and "+" or "—"; ESPFix.Visible = not espMinimized
end)
ESPCloseBtn.MouseButton1Click:Connect(function() ESPMain.Visible = false end)

-- Variables Lógicas
isESPActive = false; espBox = false; espLine = false; espName = false; espDist = false; espSkel = false; espTeam = true; espFriends = false; espColor = tRed
local FriendCache = {}; local isSpectating = false; local spectateTarget = nil

-- Utilidad Toggles
local function toggleState(btn, stateVar, name)
    local state = not stateVar
    btn.BackgroundColor3 = state and tCyan or Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = state and Color3.fromRGB(10, 10, 10) or tWhite
    btn.Text = name .. ": " .. (state and "ON" or "OFF")
    return state
end

ESPMasterBtn.MouseButton1Click:Connect(function() isESPActive = toggleState(ESPMasterBtn, isESPActive, "ESP MASTER") end)
ESPBoxBtn.MouseButton1Click:Connect(function() espBox = toggleState(ESPBoxBtn, espBox, "BOX") end)
ESPLineBtn.MouseButton1Click:Connect(function() espLine = toggleState(ESPLineBtn, espLine, "LÍNEAS (TRACERS)") end)
ESPNameBtn.MouseButton1Click:Connect(function() espName = toggleState(ESPNameBtn, espName, "NOMBRE") end)
ESPDistBtn.MouseButton1Click:Connect(function() espDist = toggleState(ESPDistBtn, espDist, "DISTANCIA") end)
ESPSkelBtn.MouseButton1Click:Connect(function() espSkel = toggleState(ESPSkelBtn, espSkel, "ESQUELETO") end)
ESPTeamBtn.MouseButton1Click:Connect(function() 
    espTeam = not espTeam
    ESPTeamBtn.BackgroundColor3 = espTeam and tGreen or Color3.fromRGB(30, 30, 30)
    ESPTeamBtn.TextColor3 = espTeam and Color3.fromRGB(10, 10, 10) or tWhite
    ESPTeamBtn.Text = "TEAM CHECK: " .. (espTeam and "ON" or "OFF")
end)
ESPFriendsBtn.MouseButton1Click:Connect(function() espFriends = toggleState(ESPFriendsBtn, espFriends, "SOLO AMIGOS") end)

local function IsFriend(player)
    if FriendCache[player.UserId] ~= nil then return FriendCache[player.UserId] end
    task.spawn(function()
        local s, r = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
        FriendCache[player.UserId] = s and r or false
    end)
    return false
end

-- ==========================================
-- MOTOR DE RENDERIZADO UNIVERSAL (SIN DRAWING API)
-- ==========================================
local ESPDrawFolder = Instance.new("ScreenGui")
ESPDrawFolder.Name = "CDT_Universal_ESP"
ESPDrawFolder.IgnoreGuiInset = true
ESPDrawFolder.ResetOnSpawn = false
pcall(function() ESPDrawFolder.Parent = gethui() end)
if not ESPDrawFolder.Parent then ESPDrawFolder.Parent = CoreGui end

local function NewGuiLine()
    local line = Instance.new("Frame")
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BorderSizePixel = 0
    line.Visible = false
    line.Parent = ESPDrawFolder
    return line
end

local function UpdateGuiLine(frame, p1, p2, color)
    if not p1 or not p2 then frame.Visible = false return end
    local dist = (p1 - p2).Magnitude
    local mid = (p1 + p2) / 2
    frame.Size = UDim2.new(0, dist, 0, 1.5)
    frame.Position = UDim2.new(0, mid.X, 0, mid.Y)
    frame.Rotation = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))
    frame.BackgroundColor3 = color
    frame.Visible = true
end

local function NewGuiBox()
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.Visible = false
    box.Parent = ESPDrawFolder
    local stroke = Instance.new("UIStroke", box)
    stroke.Thickness = 1.5
    return {Frame = box, Stroke = stroke}
end

local function NewGuiText()
    local txt = Instance.new("TextLabel")
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 12
    txt.TextStrokeTransparency = 0.2
    txt.Visible = false
    txt.Parent = ESPDrawFolder
    return txt
end

local Drawings = {}
local function GetDrawings(player)
    if not Drawings[player] then
        Drawings[player] = {
            Box = NewGuiBox(), Line = NewGuiLine(), Name = NewGuiText(), Dist = NewGuiText(),
            Skel = { NewGuiLine(), NewGuiLine(), NewGuiLine(), NewGuiLine(), NewGuiLine(), NewGuiLine(), NewGuiLine(), NewGuiLine(), NewGuiLine(), NewGuiLine(), NewGuiLine(), NewGuiLine() }
        }
    end
    return Drawings[player]
end

local function ClearESPPlayer(player)
    if Drawings[player] then
        Drawings[player].Box.Frame.Visible = false; Drawings[player].Line.Visible = false; Drawings[player].Name.Visible = false; Drawings[player].Dist.Visible = false
        for _, l in ipairs(Drawings[player].Skel) do l.Visible = false end
    end
end

local R15_Bones = { {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"} }
local R6_Bones = { {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"} }

table.insert(GlobalConnections, RunService.RenderStepped:Connect(function()
    ESPScroll.CanvasSize = UDim2.new(0, 0, 0, ESPListLayout.AbsoluteContentSize.Y + 20)
    SpecListScroll.CanvasSize = UDim2.new(0, 0, 0, SpecListLayout.AbsoluteContentSize.Y + 5)
    
    if ScriptIsDead then return end

    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        
        local char = p.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        local valid = isESPActive and hrp and hum and hum.Health > 0
        if valid and espTeam and p.Team == LocalPlayer.Team then valid = false end
        if valid and espFriends and not IsFriend(p) then valid = false end

        local D = GetDrawings(p)
        
        if valid then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                local height = math.clamp(Camera.ViewportSize.Y / dist * 4.5, 10, 1000)
                local width = height * 0.6
                
                -- Box
                if espBox then
                    D.Box.Frame.Size = UDim2.new(0, width, 0, height)
                    D.Box.Frame.Position = UDim2.new(0, pos.X - width / 2, 0, pos.Y - height / 2)
                    D.Box.Stroke.Color = espColor; D.Box.Frame.Visible = true
                else D.Box.Frame.Visible = false end
                
                -- Line
                if espLine then
                    UpdateGuiLine(D.Line, Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y), Vector2.new(pos.X, pos.Y + height/2), espColor)
                else D.Line.Visible = false end
                
                -- Name
                if espName then
                    D.Name.Text = p.DisplayName
                    D.Name.Position = UDim2.new(0, pos.X - 50, 0, pos.Y - height / 2 - 20)
                    D.Name.Size = UDim2.new(0, 100, 0, 20)
                    D.Name.TextColor3 = espColor; D.Name.Visible = true
                else D.Name.Visible = false end
                
                -- Dist
                if espDist then
                    D.Dist.Text = math.floor(dist) .. "m"
                    D.Dist.Position = UDim2.new(0, pos.X - 50, 0, pos.Y + height / 2)
                    D.Dist.Size = UDim2.new(0, 100, 0, 20)
                    D.Dist.TextColor3 = espColor; D.Dist.Visible = true
                else D.Dist.Visible = false end
                
                -- Skeleton
                if espSkel then
                    local bones = hum.RigType == Enum.HumanoidRigType.R15 and R15_Bones or R6_Bones
                    for i, bonePair in ipairs(bones) do
                        local p1 = char:FindFirstChild(bonePair[1]); local p2 = char:FindFirstChild(bonePair[2])
                        if p1 and p2 and D.Skel[i] then
                            local pos1, vis1 = Camera:WorldToViewportPoint(p1.Position)
                            local pos2, vis2 = Camera:WorldToViewportPoint(p2.Position)
                            if vis1 or vis2 then
                                UpdateGuiLine(D.Skel[i], Vector2.new(pos1.X, pos1.Y), Vector2.new(pos2.X, pos2.Y), espColor)
                            else D.Skel[i].Visible = false end
                        elseif D.Skel[i] then D.Skel[i].Visible = false end
                    end
                else
                    for _, l in ipairs(D.Skel) do l.Visible = false end
                end
            else ClearESPPlayer(p) end
        else ClearESPPlayer(p) end
    end
end))

-- LÓGICA MODO ESPECTADOR (ESPEC)
local function UpdateSpectatorList()
    for _, child in pairs(SpecListScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local btn = Instance.new("TextButton", SpecListScroll)
            btn.Size = UDim2.new(1, -5, 0, 22); btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); btn.Text = "  " .. p.DisplayName
            btn.TextColor3 = tWhite; btn.Font = Enum.Font.Gotham; btn.TextSize = 11; btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
            btn.MouseButton1Click:Connect(function()
                spectateTarget = p
                SpecTargetLabel.Text = "OBJETIVO: " .. p.DisplayName
                SpecTargetLabel.TextColor3 = tCyan
                if isSpectating then Camera.CameraSubject = p.Character and p.Character:FindFirstChild("Humanoid") or LocalPlayer.Character.Humanoid end
            end)
        end
    end
end

table.insert(GlobalConnections, Players.PlayerAdded:Connect(UpdateSpectatorList))
table.insert(GlobalConnections, Players.PlayerRemoving:Connect(function(p)
    ClearESPPlayer(p)
    if Drawings[p] then
        Drawings[p].Box.Frame:Destroy(); Drawings[p].Line:Destroy(); Drawings[p].Name:Destroy(); Drawings[p].Dist:Destroy()
        for _, l in ipairs(Drawings[p].Skel) do l:Destroy() end
        Drawings[p] = nil
    end
    UpdateSpectatorList()
    
    if isSpectating and spectateTarget == p then
        isSpectating = false
        spectateTarget = nil
        SpecTargetLabel.Text = "OBJETIVO: NINGUNO (DESCONECTADO)"
        SpecTargetLabel.TextColor3 = tRed
        SpecToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); SpecToggleBtn.TextColor3 = tWhite; SpecToggleBtn.Text = "ESPECTAR: OFF"
        Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    end
end))

SpecToggleBtn.MouseButton1Click:Connect(function()
    isSpectating = not isSpectating
    SpecToggleBtn.BackgroundColor3 = isSpectating and tPurple or Color3.fromRGB(30, 30, 30)
    SpecToggleBtn.TextColor3 = isSpectating and tWhite or tWhite
    SpecToggleBtn.Text = "ESPECTAR: " .. (isSpectating and "ON" or "OFF")
    
    if isSpectating and spectateTarget and spectateTarget.Character then
        Camera.CameraSubject = spectateTarget.Character:FindFirstChild("Humanoid")
    else
        Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    end
end)

-- Limpieza Segura
local oldDestruirESP = DestruirScriptCompleto
DestruirScriptCompleto = function()
    if oldDestruirESP then oldDestruirESP() end
    if ESPDrawFolder then ESPDrawFolder:Destroy() end
    Drawings = {}
    if isSpectating then Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") end
end

task.spawn(UpdateSpectatorList)

-- ==================================================================
-- 11. INTERFAZ DE AJUSTES Y TEMAS (SETTINGS / THEMES)
-- ==================================================================
SetMain = Instance.new("Frame", ScreenGui); SetMain.Size = UDim2.new(0, 260, 0, 100); SetMain.Position = UDim2.new(0.5, 0, 0.5, 0); SetMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); SetMain.BorderSizePixel = 0; SetMain.ClipsDescendants = true; SetMain.Visible = false; Instance.new("UICorner", SetMain).CornerRadius = UDim.new(0, 6); SetMainStroke = Instance.new("UIStroke", SetMain); SetMainStroke.Color = borderDark
SetTopBar = Instance.new("Frame", SetMain); SetTopBar.Size = UDim2.new(1, 0, 0, 35); SetTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); SetTopBar.BorderSizePixel = 0; Instance.new("UICorner", SetTopBar).CornerRadius = UDim.new(0, 6)
SetFix = Instance.new("Frame", SetTopBar); SetFix.Size = UDim2.new(1, 0, 0, 5); SetFix.Position = UDim2.new(0, 0, 1, -5); SetFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); SetFix.BorderSizePixel = 0
SetTitle = Instance.new("TextLabel", SetTopBar); SetTitle.Size = UDim2.new(1, -70, 1, 0); SetTitle.Position = UDim2.new(0, 15, 0, 0); SetTitle.BackgroundTransparency = 1; SetTitle.Text = "AJUSTES DE INTERFAZ"; SetTitle.TextColor3 = tWhite; SetTitle.Font = Enum.Font.GothamBold; SetTitle.TextSize = 13; SetTitle.TextXAlignment = Enum.TextXAlignment.Left
SetMinBtn = Instance.new("TextButton", SetTopBar); SetMinBtn.Size = UDim2.new(0, 35, 1, 0); SetMinBtn.Position = UDim2.new(1, -70, 0, 0); SetMinBtn.BackgroundTransparency = 1; SetMinBtn.Text = "—"; SetMinBtn.TextColor3 = tGreen; SetMinBtn.Font = Enum.Font.GothamBlack; SetMinBtn.TextSize = 14
SetCloseBtn = Instance.new("TextButton", SetTopBar); SetCloseBtn.Size = UDim2.new(0, 35, 1, 0); SetCloseBtn.Position = UDim2.new(1, -35, 0, 0); SetCloseBtn.BackgroundTransparency = 1; SetCloseBtn.Text = "X"; SetCloseBtn.TextColor3 = tRed; SetCloseBtn.Font = Enum.Font.GothamBlack; SetCloseBtn.TextSize = 12

ThemeToggleBtn = Instance.new("TextButton", SetMain); ThemeToggleBtn.Size = UDim2.new(1, -20, 0, 45); ThemeToggleBtn.Position = UDim2.new(0, 10, 0, 45); ThemeToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); ThemeToggleBtn.Text = "TEMA: DEFAULT"; ThemeToggleBtn.TextColor3 = tWhite; ThemeToggleBtn.Font = Enum.Font.GothamBold; ThemeToggleBtn.TextSize = 12; Instance.new("UICorner", ThemeToggleBtn).CornerRadius = UDim.new(0, 6)

ApplyResponsiveScale(SetMain); MakeDraggable(SetTopBar, SetMain)

local setMinimized = false
SetMinBtn.MouseButton1Click:Connect(function()
    setMinimized = not setMinimized; SetMain:TweenSize(setMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 100), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    SetMinBtn.Text = setMinimized and "+" or "—"; SetFix.Visible = not setMinimized
end)
SetCloseBtn.MouseButton1Click:Connect(function() SetMain.Visible = false end)

local currentTheme = "Default"
ThemeToggleBtn.MouseButton1Click:Connect(function()
    if currentTheme == "Default" then
        currentTheme = "Glass"
        ThemeToggleBtn.Text = "TEMA: CRISTAL"
        ThemeToggleBtn.BackgroundColor3 = tCyan
        ThemeToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
    else
        currentTheme = "Default"
        ThemeToggleBtn.Text = "TEMA: DEFAULT"
        ThemeToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ThemeToggleBtn.TextColor3 = tWhite
    end
    
    local isGlass = (currentTheme == "Glass")
    local bgTrans = isGlass and 0.4 or 0
    local tbTrans = isGlass and 0.5 or 0
    local bgColor = isGlass and Color3.fromRGB(5, 5, 5) or Color3.fromRGB(15, 15, 15)
    local tbColor = isGlass and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(22, 22, 22)
    local strokeColor = isGlass and tCyan or borderDark
    local strokeTrans = isGlass and 0.3 or 0

    local frames = {Main, MPMain, TPMain, InvMain, FlyMain, VFlyMain, NoclipMain, TripMain, ChatMain, SetMain, HideMain, GenMain, ReverseMain, FreecamMain, ESPMain, SpinMain, AirMain}
    local topbars = {TopBar, MPTopBar, TPTopBar, InvTopBar, FlyTopBar, VFlyTopBar, NoclipTopBar, TripTopBar, ChatTopBar, SetTopBar, HideTopBar, GenTopBar, ReverseTopBar, FreecamTopBar, ESPTopBar, SpinTopBar, AirTopBar}
    local fixes = {Fix, MPFix, TPFix, InvFix, FlyFix, VFlyFix, NoclipFix, TripFix, ChatFix, SetFix, HideFix, GenFix, ReverseFix, FreecamFix, ESPFix, SpinFix, AirFix}
    local strokes = {MainStroke, MPMainStroke, TPMainStroke, InvMainStroke, FlyMainStroke, VFlyMainStroke, NoclipMainStroke, TripMainStroke, SetMainStroke, HideMainStroke, GenMainStroke, ReverseMainStroke, FreecamMainStroke, ESPMainStroke, SpinMainStroke, AirMainStroke}
    
    for _, f in ipairs(frames) do if f then f.BackgroundTransparency = bgTrans; f.BackgroundColor3 = bgColor end end
    for _, tb in ipairs(topbars) do if tb then tb.BackgroundTransparency = tbTrans; tb.BackgroundColor3 = tbColor end end
    for _, fx in ipairs(fixes) do if fx then fx.BackgroundTransparency = tbTrans; fx.BackgroundColor3 = tbColor end end
    for _, s in ipairs(strokes) do if s then s.Color = strokeColor; s.Transparency = strokeTrans; if isGlass then s.Thickness = 1.2 else s.Thickness = 1 end end end
end)

-- ==================================================================
-- 12. GENERADOR C.D.T (EVENT GENERATION SLIDERS)
-- ==================================================================
GenMain = Instance.new("Frame", ScreenGui); GenMain.Size = UDim2.new(0, 260, 0, 310); GenMain.Position = UDim2.new(0.5, 100, 0.5, -150); GenMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); GenMain.BorderSizePixel = 0; GenMain.ClipsDescendants = true; GenMain.Visible = false; Instance.new("UICorner", GenMain).CornerRadius = UDim.new(0, 6); GenMainStroke = Instance.new("UIStroke", GenMain); GenMainStroke.Color = borderDark
GenTopBar = Instance.new("Frame", GenMain); GenTopBar.Size = UDim2.new(1, 0, 0, 35); GenTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); GenTopBar.BorderSizePixel = 0; Instance.new("UICorner", GenTopBar).CornerRadius = UDim.new(0, 6)
GenFix = Instance.new("Frame", GenTopBar); GenFix.Size = UDim2.new(1, 0, 0, 5); GenFix.Position = UDim2.new(0, 0, 1, -5); GenFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); GenFix.BorderSizePixel = 0
GenTitle = Instance.new("TextLabel", GenTopBar); GenTitle.Size = UDim2.new(1, -70, 1, 0); GenTitle.Position = UDim2.new(0, 15, 0, 0); GenTitle.BackgroundTransparency = 1; GenTitle.Text = "GENERADOR C.D.T"; GenTitle.TextColor3 = tWhite; GenTitle.Font = Enum.Font.GothamBold; GenTitle.TextSize = 13; GenTitle.TextXAlignment = Enum.TextXAlignment.Left
GenMinBtn = Instance.new("TextButton", GenTopBar); GenMinBtn.Size = UDim2.new(0, 35, 1, 0); GenMinBtn.Position = UDim2.new(1, -70, 0, 0); GenMinBtn.BackgroundTransparency = 1; GenMinBtn.Text = "—"; GenMinBtn.TextColor3 = tGreen; GenMinBtn.Font = Enum.Font.GothamBlack; GenMinBtn.TextSize = 14
GenCloseBtn = Instance.new("TextButton", GenTopBar); GenCloseBtn.Size = UDim2.new(0, 35, 1, 0); GenCloseBtn.Position = UDim2.new(1, -35, 0, 0); GenCloseBtn.BackgroundTransparency = 1; GenCloseBtn.Text = "X"; GenCloseBtn.TextColor3 = tRed; GenCloseBtn.Font = Enum.Font.GothamBlack; GenCloseBtn.TextSize = 12

local GenInput = Instance.new("TextBox", GenMain)
GenInput.Size = UDim2.new(1, -20, 0, 30); GenInput.Position = UDim2.new(0, 10, 0, 45); GenInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20); GenInput.TextColor3 = tWhite; GenInput.Text = ""; GenInput.PlaceholderText = "Nombre del objeto..."; GenInput.Font = Enum.Font.Gotham; GenInput.TextSize = 12; GenInput.ClearTextOnFocus = false; Instance.new("UICorner", GenInput).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", GenInput).Color = Color3.fromRGB(50, 50, 50); Instance.new("UIPadding", GenInput).PaddingLeft = UDim.new(0, 5)

local function CreateCDTSlider(parent, name, yPos, defaultValue)
    local SliderFrame = Instance.new("Frame", parent)
    SliderFrame.Size = UDim2.new(1, -20, 0, 40); SliderFrame.Position = UDim2.new(0, 10, 0, yPos); SliderFrame.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", SliderFrame)
    Label.Size = UDim2.new(1, 0, 0, 15); Label.BackgroundTransparency = 1; Label.Text = name .. ": " .. defaultValue; Label.TextColor3 = tWhite; Label.Font = Enum.Font.GothamMedium; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left
    local Bar = Instance.new("Frame", SliderFrame)
    Bar.Size = UDim2.new(1, 0, 0, 6); Bar.Position = UDim2.new(0, 0, 0, 22); Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new(defaultValue/200, 0, 1, 0); Fill.BackgroundColor3 = tCyan; Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    local SliderBtn = Instance.new("TextButton", Bar)
    SliderBtn.Size = UDim2.new(0, 12, 0, 18); SliderBtn.Position = UDim2.new(defaultValue/200, -6, 0.5, -9); SliderBtn.Text = ""; SliderBtn.BackgroundColor3 = tWhite; Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)
    local value = defaultValue; local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        value = math.floor(1 + (pos * 199)); Fill.Size = UDim2.new(pos, 0, 1, 0); SliderBtn.Position = UDim2.new(pos, -6, 0.5, -9); Label.Text = name .. ": " .. value
    end

    table.insert(GlobalConnections, SliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end))
    table.insert(GlobalConnections, UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end))
    table.insert(GlobalConnections, UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end))
    return function() return value end
end

local getX = CreateCDTSlider(GenMain, "Ancho (X)", 85, 2)
local getY = CreateCDTSlider(GenMain, "Alto (Y)", 135, 2)
local getZ = CreateCDTSlider(GenMain, "Largo (Z)", 185, 2)

local GenFireBtn = Instance.new("TextButton", GenMain)
GenFireBtn.Size = UDim2.new(1, -20, 0, 40); GenFireBtn.Position = UDim2.new(0, 10, 0, 250); GenFireBtn.BackgroundColor3 = tGreen; GenFireBtn.TextColor3 = Color3.fromRGB(10, 10, 10); GenFireBtn.Text = "GENERAR OBJETO"; GenFireBtn.Font = Enum.Font.GothamBold; GenFireBtn.TextSize = 13; Instance.new("UICorner", GenFireBtn).CornerRadius = UDim.new(0, 6)

ApplyResponsiveScale(GenMain); MakeDraggable(GenTopBar, GenMain)

local genMinimized = false
GenMinBtn.MouseButton1Click:Connect(function()
    genMinimized = not genMinimized; GenMain:TweenSize(genMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 310), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true); GenMinBtn.Text = genMinimized and "+" or "—"; GenFix.Visible = not genMinimized
end)
GenCloseBtn.MouseButton1Click:Connect(function() GenMain.Visible = false end)

GenFireBtn.MouseButton1Click:Connect(function()
    local Event = ReplicatedStorage:FindFirstChild("event_generation")
    if Event then
        local valX, valY, valZ = getX(), getY(), getZ()
        Event:FireServer(GenInput.Text, Vector3.new(valX, valY, valZ))
        local oldText = GenFireBtn.Text; GenFireBtn.Text = "¡ENVIADO!"; task.wait(1); GenFireBtn.Text = oldText
    else
        local oldText = GenFireBtn.Text; GenFireBtn.BackgroundColor3 = tRed; GenFireBtn.TextColor3 = tWhite; GenFireBtn.Text = "ERROR: EVENTO NO ENCONTRADO"; task.wait(2); GenFireBtn.BackgroundColor3 = tGreen; GenFireBtn.TextColor3 = Color3.fromRGB(10, 10, 10); GenFireBtn.Text = oldText
    end
end)

-- ==================================================================
-- 18. SPINBOT MENU (BODY ANGULAR VELOCITY INTEGRADO)
-- ==================================================================
SpinMain = Instance.new("Frame", ScreenGui); SpinMain.Size = UDim2.new(0, 260, 0, 145); SpinMain.Position = UDim2.new(0, 20, 0, 140); SpinMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); SpinMain.BorderSizePixel = 0; SpinMain.ClipsDescendants = true; SpinMain.Visible = false; Instance.new("UICorner", SpinMain).CornerRadius = UDim.new(0, 6); SpinMainStroke = Instance.new("UIStroke", SpinMain); SpinMainStroke.Color = borderDark
SpinTopBar = Instance.new("Frame", SpinMain); SpinTopBar.Size = UDim2.new(1, 0, 0, 35); SpinTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); SpinTopBar.BorderSizePixel = 0; Instance.new("UICorner", SpinTopBar).CornerRadius = UDim.new(0, 6)
SpinFix = Instance.new("Frame", SpinTopBar); SpinFix.Size = UDim2.new(1, 0, 0, 5); SpinFix.Position = UDim2.new(0, 0, 1, -5); SpinFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); SpinFix.BorderSizePixel = 0
SpinTitle = Instance.new("TextLabel", SpinTopBar); SpinTitle.Size = UDim2.new(1, -70, 1, 0); SpinTitle.Position = UDim2.new(0, 15, 0, 0); SpinTitle.BackgroundTransparency = 1; SpinTitle.Text = "SPINBOT (ANGULAR VELOCITY)"; SpinTitle.TextColor3 = tWhite; SpinTitle.Font = Enum.Font.GothamBold; SpinTitle.TextSize = 13; SpinTitle.TextXAlignment = Enum.TextXAlignment.Left
SpinMinBtn = Instance.new("TextButton", SpinTopBar); SpinMinBtn.Size = UDim2.new(0, 35, 1, 0); SpinMinBtn.Position = UDim2.new(1, -70, 0, 0); SpinMinBtn.BackgroundTransparency = 1; SpinMinBtn.Text = "—"; SpinMinBtn.TextColor3 = tGreen; SpinMinBtn.Font = Enum.Font.GothamBlack; SpinMinBtn.TextSize = 14
SpinCloseBtn = Instance.new("TextButton", SpinTopBar); SpinCloseBtn.Size = UDim2.new(0, 35, 1, 0); SpinCloseBtn.Position = UDim2.new(1, -35, 0, 0); SpinCloseBtn.BackgroundTransparency = 1; SpinCloseBtn.Text = "X"; SpinCloseBtn.TextColor3 = tRed; SpinCloseBtn.Font = Enum.Font.GothamBlack; SpinCloseBtn.TextSize = 12

SpinToggleBtn = Instance.new("TextButton", SpinMain); SpinToggleBtn.Size = UDim2.new(1, -75, 0, 45); SpinToggleBtn.Position = UDim2.new(0, 10, 0, 45); SpinToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); SpinToggleBtn.Text = "SPIN: OFF"; SpinToggleBtn.TextColor3 = tWhite; SpinToggleBtn.Font = Enum.Font.GothamBold; SpinToggleBtn.TextSize = 12; Instance.new("UICorner", SpinToggleBtn).CornerRadius = UDim.new(0, 6)
SpinKeyBtn = Instance.new("TextButton", SpinMain); SpinKeyBtn.Size = UDim2.new(0, 50, 0, 45); SpinKeyBtn.Position = UDim2.new(1, -60, 0, 45); SpinKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); SpinKeyBtn.Text = "KEY"; SpinKeyBtn.TextColor3 = tWhite; SpinKeyBtn.Font = Enum.Font.GothamBold; SpinKeyBtn.TextSize = 11; Instance.new("UICorner", SpinKeyBtn).CornerRadius = UDim.new(0, 6)

SpinSpeedMinus = Instance.new("TextButton", SpinMain); SpinSpeedMinus.Size = UDim2.new(0, 40, 0, 35); SpinSpeedMinus.Position = UDim2.new(0, 10, 0, 100); SpinSpeedMinus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); SpinSpeedMinus.Text = "-"; SpinSpeedMinus.TextColor3 = tWhite; SpinSpeedMinus.Font = Enum.Font.GothamBold; Instance.new("UICorner", SpinSpeedMinus)
SpinSpeedDisplay = Instance.new("TextBox", SpinMain); SpinSpeedDisplay.Size = UDim2.new(1, -110, 0, 35); SpinSpeedDisplay.Position = UDim2.new(0, 55, 0, 100); SpinSpeedDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 25); SpinSpeedDisplay.Text = ""; SpinSpeedDisplay.PlaceholderText = "SPEED: 30"; SpinSpeedDisplay.TextColor3 = tWhite; SpinSpeedDisplay.Font = Enum.Font.GothamSemibold; SpinSpeedDisplay.TextSize = 14; SpinSpeedDisplay.ClearTextOnFocus = true; Instance.new("UICorner", SpinSpeedDisplay); Instance.new("UIStroke", SpinSpeedDisplay).Color = Color3.fromRGB(50, 50, 50)
SpinSpeedPlus = Instance.new("TextButton", SpinMain); SpinSpeedPlus.Size = UDim2.new(0, 40, 0, 35); SpinSpeedPlus.Position = UDim2.new(1, -50, 0, 100); SpinSpeedPlus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); SpinSpeedPlus.Text = "+"; SpinSpeedPlus.TextColor3 = tWhite; SpinSpeedPlus.Font = Enum.Font.GothamBold; Instance.new("UICorner", SpinSpeedPlus)

ApplyResponsiveScale(SpinMain); MakeDraggable(SpinTopBar, SpinMain)

local spinMinimized = false
SpinMinBtn.MouseButton1Click:Connect(function()
    spinMinimized = not spinMinimized; SpinMain:TweenSize(spinMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 145), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    SpinMinBtn.Text = spinMinimized and "+" or "—"; SpinFix.Visible = not spinMinimized
end)

local isSpinning = false; local spinSpeedNum = 30; local spinKeybind = nil; local isSpinBinding = false
local spinDebounce = false

SpinSpeedMinus.MouseButton1Click:Connect(function() spinSpeedNum = math.max(1, spinSpeedNum - 5); SpinSpeedDisplay.Text = "SPEED: " .. spinSpeedNum end)
SpinSpeedPlus.MouseButton1Click:Connect(function() spinSpeedNum = spinSpeedNum + 5; SpinSpeedDisplay.Text = "SPEED: " .. spinSpeedNum end)
table.insert(GlobalConnections, SpinSpeedDisplay.FocusLost:Connect(function() local num = tonumber(SpinSpeedDisplay.Text:match("%d+")); if num then spinSpeedNum = num end; SpinSpeedDisplay.Text = "SPEED: " .. spinSpeedNum end))

ToggleSpin = function(forceSpeed)
    if spinDebounce or ScriptIsDead then return end
    spinDebounce = true

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hrp then 
        spinDebounce = false
        return 
    end

    if forceSpeed then
        spinSpeedNum = forceSpeed
        isSpinning = true
    else
        isSpinning = not isSpinning
    end

    if isSpinning then
        SpinToggleBtn.BackgroundColor3 = tCyan
        SpinToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
        SpinToggleBtn.Text = "SPIN: ON"
        SpinSpeedDisplay.Text = "SPEED: " .. spinSpeedNum
        
        for _,v in pairs(hrp:GetChildren()) do 
            if v.Name == "Spinning" then v:Destroy() end 
        end
        
        local Spin = Instance.new("BodyAngularVelocity")
        Spin.Name = "Spinning"
        Spin.Parent = hrp
        Spin.MaxTorque = Vector3.new(0, math.huge, 0)
        Spin.AngularVelocity = Vector3.new(0, spinSpeedNum, 0)
    else
        SpinToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        SpinToggleBtn.TextColor3 = tWhite
        SpinToggleBtn.Text = "SPIN: OFF"
        
        for _,v in pairs(hrp:GetChildren()) do 
            if v.Name == "Spinning" then v:Destroy() end 
        end
        
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
    end

    task.wait(0.2)
    spinDebounce = false
end

SpinToggleBtn.MouseButton1Click:Connect(function() ToggleSpin() end)

SpinCloseBtn.MouseButton1Click:Connect(function() 
    SpinMain.Visible = false; spinKeybind = nil; isSpinBinding = false; SpinKeyBtn.Text = "KEY"; SpinKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    if isSpinning then ToggleSpin() end
end)

SpinKeyBtn.MouseButton1Click:Connect(function()
    if spinKeybind ~= nil then spinKeybind = nil; SpinKeyBtn.Text = "KEY"; SpinKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isSpinBinding = false
    else isSpinBinding = true; SpinKeyBtn.Text = "..."; SpinKeyBtn.BackgroundColor3 = tOrange end
end)

-- ==================================================================
-- 19. WALK ON AIR MENU (INVISIBLE DYNAMIC BASE)
-- ==================================================================
AirMain = Instance.new("Frame", ScreenGui); AirMain.Size = UDim2.new(0, 260, 0, 100); AirMain.Position = UDim2.new(0, 20, 0, 920); AirMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); AirMain.BorderSizePixel = 0; AirMain.ClipsDescendants = true; AirMain.Visible = false; Instance.new("UICorner", AirMain).CornerRadius = UDim.new(0, 6); AirMainStroke = Instance.new("UIStroke", AirMain); AirMainStroke.Color = borderDark
AirTopBar = Instance.new("Frame", AirMain); AirTopBar.Size = UDim2.new(1, 0, 0, 35); AirTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); AirTopBar.BorderSizePixel = 0; Instance.new("UICorner", AirTopBar).CornerRadius = UDim.new(0, 6)
AirFix = Instance.new("Frame", AirTopBar); AirFix.Size = UDim2.new(1, 0, 0, 5); AirFix.Position = UDim2.new(0, 0, 1, -5); AirFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); AirFix.BorderSizePixel = 0
AirTitle = Instance.new("TextLabel", AirTopBar); AirTitle.Size = UDim2.new(1, -70, 1, 0); AirTitle.Position = UDim2.new(0, 15, 0, 0); AirTitle.BackgroundTransparency = 1; AirTitle.Text = "WALK ON AIR"; AirTitle.TextColor3 = tWhite; AirTitle.Font = Enum.Font.GothamBold; AirTitle.TextSize = 13; AirTitle.TextXAlignment = Enum.TextXAlignment.Left
AirMinBtn = Instance.new("TextButton", AirTopBar); AirMinBtn.Size = UDim2.new(0, 35, 1, 0); AirMinBtn.Position = UDim2.new(1, -70, 0, 0); AirMinBtn.BackgroundTransparency = 1; AirMinBtn.Text = "—"; AirMinBtn.TextColor3 = tGreen; AirMinBtn.Font = Enum.Font.GothamBlack; AirMinBtn.TextSize = 14
AirCloseBtn = Instance.new("TextButton", AirTopBar); AirCloseBtn.Size = UDim2.new(0, 35, 1, 0); AirCloseBtn.Position = UDim2.new(1, -35, 0, 0); AirCloseBtn.BackgroundTransparency = 1; AirCloseBtn.Text = "X"; AirCloseBtn.TextColor3 = tRed; AirCloseBtn.Font = Enum.Font.GothamBlack; AirCloseBtn.TextSize = 12

AirToggleBtn = Instance.new("TextButton", AirMain); AirToggleBtn.Size = UDim2.new(1, -75, 0, 45); AirToggleBtn.Position = UDim2.new(0, 10, 0, 45); AirToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); AirToggleBtn.Text = "WALK ON AIR: OFF"; AirToggleBtn.TextColor3 = tWhite; AirToggleBtn.Font = Enum.Font.GothamBold; AirToggleBtn.TextSize = 12; Instance.new("UICorner", AirToggleBtn).CornerRadius = UDim.new(0, 6)
AirKeyBtn = Instance.new("TextButton", AirMain); AirKeyBtn.Size = UDim2.new(0, 50, 0, 45); AirKeyBtn.Position = UDim2.new(1, -60, 0, 45); AirKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); AirKeyBtn.Text = "KEY"; AirKeyBtn.TextColor3 = tWhite; AirKeyBtn.Font = Enum.Font.GothamBold; AirKeyBtn.TextSize = 11; Instance.new("UICorner", AirKeyBtn).CornerRadius = UDim.new(0, 6)

ApplyResponsiveScale(AirMain); MakeDraggable(AirTopBar, AirMain)

local airMinimized = false
AirMinBtn.MouseButton1Click:Connect(function()
    airMinimized = not airMinimized; AirMain:TweenSize(airMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 100), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    AirMinBtn.Text = airMinimized and "+" or "—"; AirFix.Visible = not airMinimized
end)

local isAirWalkActive = false; local airKeybind = nil; local isAirBinding = false; local airBaseplateFolder = nil
local airPlantilla = Instance.new("Part"); airPlantilla.Size = Vector3.new(648, 16, 648); airPlantilla.Anchored = true; airPlantilla.CanCollide = true; airPlantilla.Transparency = 1; airPlantilla.Material = Enum.Material.SmoothPlastic

local function getAirChunkKey(x, z) return x .. "_" .. z end

ToggleAirWalk = function()
    isAirWalkActive = not isAirWalkActive
    if isAirWalkActive then
        AirToggleBtn.BackgroundColor3 = tCyan; AirToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10); AirToggleBtn.Text = "WALK ON AIR: ON"
        airBaseplateFolder = Instance.new("Folder", Workspace); airBaseplateFolder.Name = "CDT_AirWalkFolder"
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local startY = hrp and (hrp.Position.Y - 11.5) or 0 
        local ORIGIN_POS = Vector3.new(0, startY, 0)
        
        local TILE_SIZE = 648
        local RENDER_DISTANCE = 2
        local DELETE_DISTANCE = 4
        
        local activeChunks = {}
        
        task.spawn(function()
            while isAirWalkActive and airBaseplateFolder and airBaseplateFolder.Parent and not ScriptIsDead do
                task.wait(0.0)
                local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local pos = hrp.Position
                    local currentX = math.floor((pos.X - ORIGIN_POS.X + TILE_SIZE / 2) / TILE_SIZE)
                    local currentZ = math.floor((pos.Z - ORIGIN_POS.Z + TILE_SIZE / 2) / TILE_SIZE)
                    
                    local chunksNecesarios = {}
                    for x = -RENDER_DISTANCE, RENDER_DISTANCE do
                        for z = -RENDER_DISTANCE, RENDER_DISTANCE do
                            local key = getAirChunkKey(currentX + x, currentZ + z)
                            chunksNecesarios[key] = {X = currentX + x, Z = currentZ + z}
                        end
                    end
                    
                    for key, coords in pairs(chunksNecesarios) do
                        if not activeChunks[key] then
                            local nueva = airPlantilla:Clone()
                            nueva.Position = Vector3.new(ORIGIN_POS.X + (coords.X * TILE_SIZE), ORIGIN_POS.Y, ORIGIN_POS.Z + (coords.Z * TILE_SIZE))
                            nueva.Parent = airBaseplateFolder
                            activeChunks[key] = {Instance = nueva, X = coords.X, Z = coords.Z}
                        end
                    end
                    
                    for key, data in pairs(activeChunks) do
                        local dist = math.max(math.abs(data.X - currentX), math.abs(data.Z - currentZ))
                        if dist > DELETE_DISTANCE then 
                            data.Instance:Destroy()
                            activeChunks[key] = nil 
                        end
                    end
                end
            end
        end)
    else
        AirToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); AirToggleBtn.TextColor3 = tWhite; AirToggleBtn.Text = "WALK ON AIR: OFF"
        if airBaseplateFolder then airBaseplateFolder:Destroy(); airBaseplateFolder = nil end
    end
end
AirToggleBtn.MouseButton1Click:Connect(ToggleAirWalk)

AirCloseBtn.MouseButton1Click:Connect(function() 
    AirMain.Visible = false; airKeybind = nil; isAirBinding = false; AirKeyBtn.Text = "KEY"; AirKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) 
    if isAirWalkActive then ToggleAirWalk() end
end)

AirKeyBtn.MouseButton1Click:Connect(function()
    if airKeybind ~= nil then airKeybind = nil; AirKeyBtn.Text = "KEY"; AirKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isAirBinding = false
    else isAirBinding = true; AirKeyBtn.Text = "..."; AirKeyBtn.BackgroundColor3 = tOrange end
end)

-- ==================================================================
-- 20. GLITCH TP MENU (EFECTO BRUSCO + FIX SHIFT LOCK + ANTI-SMOOTHING)
-- ==================================================================
GlitchMain = Instance.new("Frame", ScreenGui); GlitchMain.Size = UDim2.new(0, 260, 0, 145); GlitchMain.Position = UDim2.new(0.5, -130, 0.5, -70); GlitchMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); GlitchMain.BorderSizePixel = 0; GlitchMain.ClipsDescendants = true; GlitchMain.Visible = false; Instance.new("UICorner", GlitchMain).CornerRadius = UDim.new(0, 6); GlitchMainStroke = Instance.new("UIStroke", GlitchMain); GlitchMainStroke.Color = borderDark
GlitchTopBar = Instance.new("Frame", GlitchMain); GlitchTopBar.Size = UDim2.new(1, 0, 0, 35); GlitchTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); GlitchTopBar.BorderSizePixel = 0; Instance.new("UICorner", GlitchTopBar).CornerRadius = UDim.new(0, 6)
GlitchFix = Instance.new("Frame", GlitchTopBar); GlitchFix.Size = UDim2.new(1, 0, 0, 5); GlitchFix.Position = UDim2.new(0, 0, 1, -5); GlitchFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); GlitchFix.BorderSizePixel = 0
GlitchTitle = Instance.new("TextLabel", GlitchTopBar); GlitchTitle.Size = UDim2.new(1, -70, 1, 0); GlitchTitle.Position = UDim2.new(0, 15, 0, 0); GlitchTitle.BackgroundTransparency = 1; GlitchTitle.Text = "GLITCH TP"; GlitchTitle.TextColor3 = tWhite; GlitchTitle.Font = Enum.Font.GothamBold; GlitchTitle.TextSize = 13; GlitchTitle.TextXAlignment = Enum.TextXAlignment.Left
GlitchMinBtn = Instance.new("TextButton", GlitchTopBar); GlitchMinBtn.Size = UDim2.new(0, 35, 1, 0); GlitchMinBtn.Position = UDim2.new(1, -70, 0, 0); GlitchMinBtn.BackgroundTransparency = 1; GlitchMinBtn.Text = "—"; GlitchMinBtn.TextColor3 = tGreen; GlitchMinBtn.Font = Enum.Font.GothamBlack; GlitchMinBtn.TextSize = 14
GlitchCloseBtn = Instance.new("TextButton", GlitchTopBar); GlitchCloseBtn.Size = UDim2.new(0, 35, 1, 0); GlitchCloseBtn.Position = UDim2.new(1, -35, 0, 0); GlitchCloseBtn.BackgroundTransparency = 1; GlitchCloseBtn.Text = "X"; GlitchCloseBtn.TextColor3 = tRed; GlitchCloseBtn.Font = Enum.Font.GothamBlack; GlitchCloseBtn.TextSize = 12

GlitchToggleBtn = Instance.new("TextButton", GlitchMain); GlitchToggleBtn.Size = UDim2.new(1, -75, 0, 45); GlitchToggleBtn.Position = UDim2.new(0, 10, 0, 45); GlitchToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); GlitchToggleBtn.Text = "GLITCH: OFF"; GlitchToggleBtn.TextColor3 = tWhite; GlitchToggleBtn.Font = Enum.Font.GothamBold; GlitchToggleBtn.TextSize = 12; Instance.new("UICorner", GlitchToggleBtn).CornerRadius = UDim.new(0, 6)
GlitchKeyBtn = Instance.new("TextButton", GlitchMain); GlitchKeyBtn.Size = UDim2.new(0, 50, 0, 45); GlitchKeyBtn.Position = UDim2.new(1, -60, 0, 45); GlitchKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); GlitchKeyBtn.Text = "KEY"; GlitchKeyBtn.TextColor3 = tWhite; GlitchKeyBtn.Font = Enum.Font.GothamBold; GlitchKeyBtn.TextSize = 11; Instance.new("UICorner", GlitchKeyBtn).CornerRadius = UDim.new(0, 6)

GlitchDistMinus = Instance.new("TextButton", GlitchMain); GlitchDistMinus.Size = UDim2.new(0, 40, 0, 35); GlitchDistMinus.Position = UDim2.new(0, 10, 0, 100); GlitchDistMinus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); GlitchDistMinus.Text = "-"; GlitchDistMinus.TextColor3 = tWhite; GlitchDistMinus.Font = Enum.Font.GothamBold; Instance.new("UICorner", GlitchDistMinus)
GlitchDistDisplay = Instance.new("TextBox", GlitchMain); GlitchDistDisplay.Size = UDim2.new(1, -110, 0, 35); GlitchDistDisplay.Position = UDim2.new(0, 55, 0, 100); GlitchDistDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 25); GlitchDistDisplay.Text = ""; GlitchDistDisplay.PlaceholderText = "DISTANCIA: 4"; GlitchDistDisplay.TextColor3 = tWhite; GlitchDistDisplay.Font = Enum.Font.GothamSemibold; GlitchDistDisplay.TextSize = 14; GlitchDistDisplay.ClearTextOnFocus = true; Instance.new("UICorner", GlitchDistDisplay); Instance.new("UIStroke", GlitchDistDisplay).Color = Color3.fromRGB(50, 50, 50)
GlitchDistPlus = Instance.new("TextButton", GlitchMain); GlitchDistPlus.Size = UDim2.new(0, 40, 0, 35); GlitchDistPlus.Position = UDim2.new(1, -50, 0, 100); GlitchDistPlus.BackgroundColor3 = Color3.fromRGB(40, 40, 40); GlitchDistPlus.Text = "+"; GlitchDistPlus.TextColor3 = tWhite; GlitchDistPlus.Font = Enum.Font.GothamBold; Instance.new("UICorner", GlitchDistPlus)

ApplyResponsiveScale(GlitchMain); MakeDraggable(GlitchTopBar, GlitchMain)

local glitchMinimized = false
GlitchMinBtn.MouseButton1Click:Connect(function()
    glitchMinimized = not glitchMinimized; GlitchMain:TweenSize(glitchMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 145), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    GlitchMinBtn.Text = glitchMinimized and "+" or "—"; GlitchFix.Visible = not glitchMinimized
end)

isGlitching = false; local glitchDistNum = 4; local glitchKeybind = nil; local isGlitchBinding = false
local glitchStep = 1; local lastGlitchOffset = Vector3.new()
local glitchTickCounter = 0
local UPDATE_RATE = 2 -- Velocidad agresiva (2 frames). Rompe la predicción visual del servidor.

GlitchDistMinus.MouseButton1Click:Connect(function() glitchDistNum = math.max(1, glitchDistNum - 1); GlitchDistDisplay.Text = "DISTANCIA: " .. glitchDistNum end)
GlitchDistPlus.MouseButton1Click:Connect(function() glitchDistNum = glitchDistNum + 1; GlitchDistDisplay.Text = "DISTANCIA: " .. glitchDistNum end)
table.insert(GlobalConnections, GlitchDistDisplay.FocusLost:Connect(function() local num = tonumber(GlitchDistDisplay.Text:match("%d+")); if num then glitchDistNum = num end; GlitchDistDisplay.Text = "DISTANCIA: " .. glitchDistNum end))

ToggleGlitch = function()
    if ScriptIsDead then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not hum then return end
    
    isGlitching = not isGlitching

    if isGlitching then
        GlitchToggleBtn.BackgroundColor3 = tCyan
        GlitchToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
        GlitchToggleBtn.Text = "GLITCH: ON"
        
        lastGlitchOffset = Vector3.zero
        glitchStep = 1
        glitchTickCounter = 0
        
        -- PASO 1: ANTES DE LA CÁMARA (Centramos para el Shift Lock y para ti)
        RunService:BindToRenderStep("CDT_GlitchPre", Enum.RenderPriority.Camera.Value - 10, function()
            if not char or not hrp or not hum or hum.Health <= 0 then
                if isGlitching then ToggleGlitch() end
                return
            end
            
            if lastGlitchOffset ~= Vector3.zero then
                hrp.CFrame = hrp.CFrame - lastGlitchOffset
                lastGlitchOffset = Vector3.zero
            end
        end)
        
        -- PASO 2: DESPUÉS DE LA CÁMARA (Patrón caótico para el servidor)
        RunService:BindToRenderStep("CDT_GlitchPost", Enum.RenderPriority.Camera.Value + 10, function()
            glitchTickCounter = glitchTickCounter + 1
            if glitchTickCounter >= UPDATE_RATE then
                glitchTickCounter = 0
                glitchStep = glitchStep + 1
                if glitchStep > 4 then glitchStep = 1 end
            end
            
            local offset = Vector3.zero
            
            -- Patrón anti-suavizado: Salto enorme de un extremo a otro, luego centro.
            if glitchStep == 1 then offset = -hrp.CFrame.RightVector * glitchDistNum       -- Izquierda
            elseif glitchStep == 2 then offset = hrp.CFrame.RightVector * glitchDistNum      -- Derecha (Salto enorme)
            elseif glitchStep == 3 then offset = Vector3.zero                                -- Centro
            elseif glitchStep == 4 then offset = -hrp.CFrame.RightVector * (glitchDistNum/2) -- Medio Izquierda (Caótico)
            end
            
            if offset ~= Vector3.zero then
                hrp.CFrame = hrp.CFrame + offset
                lastGlitchOffset = offset
            end
        end)
        
    else
        GlitchToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        GlitchToggleBtn.TextColor3 = tWhite
        GlitchToggleBtn.Text = "GLITCH: OFF"
        
        pcall(function() RunService:UnbindFromRenderStep("CDT_GlitchPre") end)
        pcall(function() RunService:UnbindFromRenderStep("CDT_GlitchPost") end)
        
        if hrp and lastGlitchOffset ~= Vector3.zero then
            hrp.CFrame = hrp.CFrame - lastGlitchOffset
        end
        
        lastGlitchOffset = Vector3.zero
    end
end

GlitchToggleBtn.MouseButton1Click:Connect(ToggleGlitch)

GlitchCloseBtn.MouseButton1Click:Connect(function() 
    GlitchMain.Visible = false; glitchKeybind = nil; isGlitchBinding = false; GlitchKeyBtn.Text = "KEY"; GlitchKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    if isGlitching then ToggleGlitch() end
end)

GlitchKeyBtn.MouseButton1Click:Connect(function()
    if glitchKeybind ~= nil then glitchKeybind = nil; GlitchKeyBtn.Text = "KEY"; GlitchKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isGlitchBinding = false
    else isGlitchBinding = true; GlitchKeyBtn.Text = "..."; GlitchKeyBtn.BackgroundColor3 = tOrange end
end)

-- ==================================================================
-- COMANDOS Y CONSOLA DE EVENTOS
-- ==================================================================
local function GetPlayer(nameString)
    nameString = string.lower(nameString)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then if string.lower(string.sub(p.Name, 1, #nameString)) == nameString or string.lower(string.sub(p.DisplayName, 1, #nameString)) == nameString then return p end end
    end
    return nil
end

local Comandos = {}
local function AddCmd(cmd, desc, action) Comandos[cmd] = {Desc = desc, Accion = action} end

local function LogMessage(text, color)
    local lbl = Instance.new("TextLabel", Console)
    lbl.Size = UDim2.new(1, 0, 0, 20); lbl.BackgroundTransparency = 1; lbl.Text = "  " .. text; lbl.TextColor3 = color or tWhite; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextWrapped = true
    Console.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
    Console.CanvasPosition = Vector2.new(0, Console.CanvasSize.Y.Offset)
end

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
AddCmd("fly", "Abre el panel de Vuelo", function() FlyMain.Visible = true; LogMessage("Menú de Vuelo abierto.", tYellow) end)
AddCmd("vfly", "Abre el panel de Vehicle Fly", function() VFlyMain.Visible = true; LogMessage("Menú de Vehicle Fly abierto.", tPurple) end)
AddCmd("noclip", "Abre el panel de Noclip Walk", function() NoclipMain.Visible = true; LogMessage("Menú de Noclip Walk abierto.", tCyan) end)
AddCmd("trip", "Abre el panel de Trip Mode", function() TripMain.Visible = true; LogMessage("Menú Trip abierto.", tGreen) end)
AddCmd("reverse", "Abre el panel de Flashback / Rewind", function() ReverseMain.Visible = true; LogMessage("Menú Reverse abierto.", tCyan) end)
AddCmd("chat", "Abre el chat global", function() ChatMain.Visible = true; pcall(function() ActualizarChat() end); LogMessage("Chat Global conectado.", tGreen) end)
AddCmd("settings", "Abre el panel de Ajustes/Temas", function() SetMain.Visible = true; LogMessage("Menú de Ajustes abierto.", tOrange) end)
AddCmd("freecam", "Abre el panel de Cámara Libre", function() FreecamMain.Visible = true; LogMessage("Menú Freecam abierto.", tCyan) end)
AddCmd("esp", "Abre el panel del ESP System", function() ESPMain.Visible = true; LogMessage("Menú ESP abierto.", tPurple) end)
AddCmd("hide", "Abre el menú para ocultar avatares, sonidos locales y Voice Chat", function() HideSearchBox.Text = ""; RefreshHideMenu(); HideMain.Visible = true; LogMessage("Menú Ocultar Jugadores abierto.", tPurple) end)
AddCmd("generacion", "Abre el panel del Generador de Objetos", function() GenMain.Visible = true; LogMessage("Generador C.D.T abierto.", tCyan) end)
AddCmd("air", "Abre el panel de Walk on Air", function() AirMain.Visible = true; LogMessage("Menú Walk on Air abierto.", tCyan) end)
AddCmd("glitch", "Abre el panel de Glitch TP (3 Clones)", function() GlitchMain.Visible = true; LogMessage("Menú Glitch TP abierto.", tCyan) end)

AddCmd("spinstup", "Abre el panel del Spinbot", function()
    SpinMain.Visible = true; LogMessage("Menú Spinbot abierto.", tCyan)
end)

AddCmd("speed", "Cambia la velocidad", function(args)
    if args[1] and tonumber(args[1]) then LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(args[1]); LogMessage("Velocidad -> " .. args[1], tGreen) end
end)

AddCmd("vtag", "Oculta/Muestra tu propio Name Tag en tu pantalla", function()
    verMiTag = not verMiTag
    if verMiTag then LogMessage("Tu Name Tag ahora es VISIBLE para ti.", tGreen) else LogMessage("Tu Name Tag ahora está OCULTO para ti.", tOrange) end
end)

AddCmd("re", "Fuerza el respawn y te devuelve a tu posición actual", function()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChild("Humanoid")
        if hrp and hum then
            posicionGuardadaRE = hrp.CFrame; hum.Health = 0; LogMessage("Reiniciando, no te muevas...", tYellow)
        else LogMessage("Error: No se encontró tu personaje.", tRed) end
    end
end)

AddCmd("tptool", "Te da una herramienta para hacer TP donde hagas click", function()
    local toolName = "TP"
    if LocalPlayer.Backpack:FindFirstChild(toolName) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(toolName)) then LogMessage("Ya tienes el TP Tool en tu inventario.", tYellow) return end

    local tpTool = Instance.new("Tool")
    tpTool.Name = toolName; tpTool.RequiresHandle = false; tpTool.CanBeDropped = false
    local mouse = LocalPlayer:GetMouse()

    table.insert(GlobalConnections, tpTool.Activated:Connect(function()
        local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and mouse.Hit then
            hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3.5, 0))
            pcall(function()
                local flash = Instance.new("ColorCorrectionEffect", Lighting)
                flash.Brightness = 1; TweenService:Create(flash, TweenInfo.new(0.3), {Brightness = 0}):Play(); game.Debris:AddItem(flash, 0.4)
            end)
        end
    end))
    tpTool.Parent = LocalPlayer.Backpack
    LogMessage("TP Tool creado. Equípalo y toca donde quieras ir.", tGreen)
end)

local isClearModeActive = false
local originalLightingProps = {}
local disabledEffects = {}

AddCmd("clear", "Hace de día, quita la niebla, efectos (bloom/blur) y mejora la visión", function()
    isClearModeActive = not isClearModeActive

    if isClearModeActive then
        originalLightingProps.ClockTime = Lighting.ClockTime
        originalLightingProps.FogEnd = Lighting.FogEnd
        originalLightingProps.GlobalShadows = Lighting.GlobalShadows
        originalLightingProps.Ambient = Lighting.Ambient
        originalLightingProps.OutdoorAmbient = Lighting.OutdoorAmbient
        originalLightingProps.Brightness = Lighting.Brightness

        Lighting.ClockTime = 14 
        Lighting.FogEnd = 100000 
        Lighting.GlobalShadows = false 
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2

        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("PostEffect") or obj:IsA("Atmosphere") or obj:IsA("Sky") then
                table.insert(disabledEffects, obj)
                if obj:IsA("Sky") then obj.Parent = nil else obj.Enabled = false end
            end
        end
        LogMessage("Clear Mode ACTIVADO: Visión perfecta y sin lag.", tCyan)
    else
        if originalLightingProps.ClockTime then Lighting.ClockTime = originalLightingProps.ClockTime end
        if originalLightingProps.FogEnd then Lighting.FogEnd = originalLightingProps.FogEnd end
        if originalLightingProps.GlobalShadows ~= nil then Lighting.GlobalShadows = originalLightingProps.GlobalShadows end
        if originalLightingProps.Ambient then Lighting.Ambient = originalLightingProps.Ambient end
        if originalLightingProps.OutdoorAmbient then Lighting.OutdoorAmbient = originalLightingProps.OutdoorAmbient end
        if originalLightingProps.Brightness then Lighting.Brightness = originalLightingProps.Brightness end

        for _, obj in ipairs(disabledEffects) do
            if obj:IsA("Sky") then obj.Parent = Lighting elseif obj.Parent then obj.Enabled = true end
        end
        disabledEffects = {} 
        LogMessage("Clear Mode DESACTIVADO: Gráficos originales restaurados.", tOrange)
    end
end)

-- ==================================================================
-- LOGICA INFBASE REPARADA (MANTIENE BASE ORIGINAL)
-- ==================================================================
local infBaseActivo = false
local baseplateFolder = nil
local infPlantilla = nil
local ORIGIN_POS = Vector3.new(0, -8, 0)

task.spawn(function()
    local baseplateOriginal = workspace:FindFirstChild("Baseplate")
    if baseplateOriginal and baseplateOriginal:IsA("BasePart") then 
        ORIGIN_POS = baseplateOriginal.Position
        infPlantilla = baseplateOriginal:Clone()
        infPlantilla.Name = "CDT_InfBase_Template"
        infPlantilla.Size = Vector3.new(648, 16, 648) 
    else
        infPlantilla = Instance.new("Part")
        infPlantilla.Name = "CDT_InfBase_Fallback"
        infPlantilla.Size = Vector3.new(648, 16, 648)
        infPlantilla.Anchored = true
        infPlantilla.Material = Enum.Material.SmoothPlastic
        infPlantilla.Color = Color3.fromRGB(99, 95, 98)
    end
end)

AddCmd("infbase", "Genera baseplates infinitas alrededor de la original (Toggle On/Off)", function()
    infBaseActivo = not infBaseActivo
    if infBaseActivo then
        LogMessage("Generación de Baseplate infinita ACTIVADA.", tGreen)
        if not baseplateFolder or not baseplateFolder.Parent then
            baseplateFolder = Instance.new("Folder", workspace)
            baseplateFolder.Name = "BaseplatesInfinitas_CDT"
        end
        
        task.spawn(function()
            local TILE_SIZE = 648
            local RENDER_DISTANCE = 2
            local DELETE_DISTANCE = 4
            local UPDATE_TICK = 0.5   
            local activeChunks = {}
            local function getChunkKey(x, z) return x .. "_" .. z end

            while scriptActivoTags and infBaseActivo and not ScriptIsDead do
                task.wait(UPDATE_TICK)
                if not baseplateFolder or not baseplateFolder.Parent then break end

                local chunksNecesarios = {}
                local playerPositions = {}
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then 
                        table.insert(playerPositions, player.Character.HumanoidRootPart.Position) 
                    end
                end
                
                for _, pos in ipairs(playerPositions) do
                    local currentX = math.floor((pos.X - ORIGIN_POS.X + TILE_SIZE / 2) / TILE_SIZE)
                    local currentZ = math.floor((pos.Z - ORIGIN_POS.Z + TILE_SIZE / 2) / TILE_SIZE)
                    for x = -RENDER_DISTANCE, RENDER_DISTANCE do
                        for z = -RENDER_DISTANCE, RENDER_DISTANCE do
                            if x == 0 and z == 0 and workspace:FindFirstChild("Baseplate") then
                            else
                                local key = getChunkKey(currentX + x, currentZ + z)
                                chunksNecesarios[key] = {X = currentX + x, Z = currentZ + z}
                            end
                        end
                    end
                end
                
                if infPlantilla then
                    for key, coords in pairs(chunksNecesarios) do
                        if not activeChunks[key] then
                            local nueva = infPlantilla:Clone()
                            nueva.Name = "Chunk_" .. key
                            nueva.Position = Vector3.new(ORIGIN_POS.X + (coords.X * TILE_SIZE), ORIGIN_POS.Y, ORIGIN_POS.Z + (coords.Z * TILE_SIZE))
                            nueva.Parent = baseplateFolder
                            activeChunks[key] = {Instance = nueva, X = coords.X, Z = coords.Z}
                        end
                    end
                end
                
                for key, data in pairs(activeChunks) do
                    local estaCerca = false
                    for _, pos in ipairs(playerPositions) do
                        local currentX = math.floor((pos.X - ORIGIN_POS.X + TILE_SIZE / 2) / TILE_SIZE)
                        local currentZ = math.floor((pos.Z - ORIGIN_POS.Z + TILE_SIZE / 2) / TILE_SIZE)
                        local dist = math.max(math.abs(data.X - currentX), math.abs(data.Z - currentZ))
                        if dist <= DELETE_DISTANCE then estaCerca = true; break end
                    end
                    if not estaCerca then 
                        if data.Instance and data.Instance.Parent then data.Instance:Destroy() end
                        activeChunks[key] = nil 
                    end
                end
            end
            if baseplateFolder then baseplateFolder:Destroy(); baseplateFolder = nil end
        end)
    else
        LogMessage("Generación de Baseplate infinita DESACTIVADA. Limpiando...", tOrange)
    end
end)

local isAntiAfkActive = false; local afkConnection = nil
AddCmd("afk", "Activa o desactiva el sistema Anti-AFK", function()
    isAntiAfkActive = not isAntiAfkActive
    if isAntiAfkActive then
        afkConnection = LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
            LogMessage("Anti-AFK evadió una desconexión por inactividad.", tYellow)
        end)
        table.insert(GlobalConnections, afkConnection)
        LogMessage("Anti-AFK Activado. Puedes dejar el juego en segundo plano.", tGreen)
    else
        if afkConnection then afkConnection:Disconnect(); afkConnection = nil end
        LogMessage("Anti-AFK Desactivado.", tOrange)
    end
end)

AddCmd("rejoin", "Te reconecta al mismo servidor al instante", function()
    LogMessage("Reconectando al servidor actual...", tYellow)
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

AddCmd("hop", "Busca y te conecta a un servidor con menos gente", function()
    LogMessage("Buscando un servidor disponible...", tYellow)
    local Http = game:GetService("HttpService"); local TPS = game:GetService("TeleportService")
    local ApiUrl = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
    task.spawn(function()
        local s, r = pcall(function() return request({Url = ApiUrl, Method = "GET"}) end)
        if s and r and r.StatusCode == 200 then
            local data = Http:JSONDecode(r.Body)
            if data and data.data then
                for _, server in ipairs(data.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        LogMessage("¡Servidor encontrado! Saltando...", tGreen)
                        TPS:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                        return
                    end
                end
            end
        end
        LogMessage("No se encontraron servidores. Intenta de nuevo.", tRed)
    end)
end)

-- ==================================================================
-- DEFINICIÓN DE DESTRUCCIÓN TOTAL PARA EL COMANDO !destroy
-- ==================================================================
DestruirScriptCompleto = function()
    ScriptIsDead = true
    
    if isGhostActive and type(ToggleGhost) == "function" then ToggleGhost() end
    if isFlying and type(ToggleFly) == "function" then ToggleFly() end
    if isVFlying and type(ToggleVFly) == "function" then ToggleVFly() end
    if isNoclipActive and type(ToggleNoclipWalk) == "function" then ToggleNoclipWalk() end
    if isReverseActive and type(ToggleReverse) == "function" then ToggleReverse() end
    if isTripped and type(GetUpFromTrip) == "function" then GetUpFromTrip(false) end
    if isFreecamActive and type(ToggleFreecam) == "function" then ToggleFreecam() end
    if isESPActive and type(ToggleESP) == "function" then ToggleESP() end
    if isSpinning and type(ToggleSpin) == "function" then ToggleSpin() end
    if isAirWalkActive and type(ToggleAirWalk) == "function" then ToggleAirWalk() end
    if isClearModeActive then pcall(function() Comandos["clear"].Accion({}) end) end
    if isAntiAfkActive then pcall(function() Comandos["afk"].Accion({}) end) end
    if infBaseActivo then infBaseActivo = false end
    if isGlitching and type(ToggleGlitch) == "function" then ToggleGlitch() end
    
    for _, conn in ipairs(GlobalConnections) do
        if conn and typeof(conn) == "RBXScriptConnection" and conn.Connected then
            conn:Disconnect()
        end
    end
    GlobalConnections = {}
    
    if inputBeganConn then inputBeganConn:Disconnect() end
    if inputEndedConn then inputEndedConn:Disconnect() end
    if charAddedConn then charAddedConn:Disconnect() end
    if espFolder then espFolder:Destroy() end

    task.spawn(function() pcall(function() request({Url = BASE_URL .. "/api/offline/" .. tostring(LocalPlayer.UserId), Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = "{}"}) end) end)
    
    scriptActivoTags = false
    for _, v in pairs(UIsActivos) do if v.UI then v.UI:Destroy() end end
    UIsActivos = {}
    
    for idStr, isHidden in pairs(hiddenTags) do
        local p = Players:GetPlayerByUserId(tonumber(idStr))
        if p then
            if p.Character then OcultarAvatar(p.Character, false) end
            MutearVoiceChat(p, false)
        end
    end
    hiddenTags = {}

    if targetGuiParent then
        for _, obj in ipairs(targetGuiParent:GetChildren()) do if string.sub(obj.Name, 1, 9) == "SafeHTML_" then obj:Destroy() end end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then p.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
    end
    if ScreenGui then ScreenGui:Destroy() end
    if KeyScreen then KeyScreen:Destroy() end
end

AddCmd("destroy", "Cierra y elimina el panel completo apagando todo", function()
    LogMessage("Cerrando y apagando scripts de C.D.T Optifine...", tPurple)
    if DestruirScriptCompleto then DestruirScriptCompleto() end
end)

-- ==================================================================
-- AUTOCOMPLETADO Y DETECCIÓN DEL CHAT/CONSOLA
-- ==================================================================
SuggestFrame = Instance.new("ScrollingFrame", FullUI); SuggestFrame.Size = UDim2.new(1, -20, 0, 0); SuggestFrame.Position = UDim2.new(0, 10, 1, -45); SuggestFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); SuggestFrame.BorderSizePixel = 0; SuggestFrame.Visible = false; SuggestFrame.ScrollBarThickness = 2; SuggestFrame.ZIndex = 10; Instance.new("UICorner", SuggestFrame).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", SuggestFrame).Color = Color3.fromRGB(50, 50, 50)
SuggestList = Instance.new("UIListLayout", SuggestFrame); SuggestList.Padding = UDim.new(0, 2)

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
            table.insert(GlobalConnections, btn.MouseEnter:Connect(function() btn.TextColor3 = tPurple end))
            table.insert(GlobalConnections, btn.MouseLeave:Connect(function() btn.TextColor3 = tWhite end))
            table.insert(GlobalConnections, btn.MouseButton1Click:Connect(function() CmdBox.Text = sug.Fill; CmdBox:CaptureFocus(); SuggestFrame.Visible = false end))
            ySize = ySize + 24
        end
        local frameHeight = math.min(ySize, 100); SuggestFrame.CanvasSize = UDim2.new(0, 0, 0, ySize); SuggestFrame.Size = UDim2.new(1, -20, 0, frameHeight); SuggestFrame.Position = UDim2.new(0, 10, 1, -45 - frameHeight - 5)
    else
        SuggestFrame.Visible = false
    end
end

table.insert(GlobalConnections, CmdBox:GetPropertyChangedSignal("Text"):Connect(UpdateSuggestions))
table.insert(GlobalConnections, UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Tab and CmdBox:IsFocused() and SuggestFrame.Visible then
        for _, child in ipairs(SuggestFrame:GetChildren()) do if child:IsA("TextButton") then local fill = child:GetAttribute("Fill"); if fill then task.defer(function() CmdBox.Text = fill; CmdBox:CaptureFocus(); CmdBox.CursorPosition = #fill + 1 end); SuggestFrame.Visible = false break end end end
    end
end))
table.insert(GlobalConnections, CmdBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and CmdBox.Text ~= "" then
        local input = string.lower(CmdBox.Text); CmdBox.Text = ""; SuggestFrame.Visible = false; LogMessage("> " .. input, tWhite)
        local split = string.split(input, " "); local cmd = split[1]; table.remove(split, 1)
        if Comandos[cmd] then pcall(function() Comandos[cmd].Accion(split) end) else LogMessage("Error: Comando desconocido.", tOrange) end
    end
end))

charAddedConn = LocalPlayer.CharacterAdded:Connect(function(character) 
    if isGhostActive then ToggleGhost() end
    if isFlying then ToggleFly() end
    if isNoclipActive then ToggleNoclipWalk() end
    if isReverseActive then frames = {} end
    if isTripped then GetUpFromTrip(false) end
    if isFreecamActive then ToggleFreecam() end
    if isSpinning then ToggleSpin() end
    if isAirWalkActive then ToggleAirWalk() end

    if posicionGuardadaRE then
        task.spawn(function()
            local hrp = character:WaitForChild("HumanoidRootPart", 5)
            if hrp then task.wait(0.1); hrp.CFrame = posicionGuardadaRE; posicionGuardadaRE = nil end
        end)
    end
end)

-- ==================================================================
-- MANEJADOR GLOBAL DE TECLAS (DEBE IR AL FINAL DEL SCRIPT)
-- ==================================================================
local inputBeganConn
local inputEndedConn

if inputBeganConn then inputBeganConn:Disconnect() end
if inputEndedConn then inputEndedConn:Disconnect() end

inputBeganConn = UserInputService.InputBegan:Connect(function(input, gp)
    if ScriptIsDead then return end
    
    -- Asignación de teclas
    if isInvBinding and input.UserInputType == Enum.UserInputType.Keyboard then invKeybind = input.KeyCode; InvKeyBtn.Text = input.KeyCode.Name; InvKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isInvBinding = false; return end
    if isFlyBinding and input.UserInputType == Enum.UserInputType.Keyboard then flyKeybind = input.KeyCode; FlyKeyBtn.Text = input.KeyCode.Name; FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isFlyBinding = false; return end
    if isVFlyBinding and input.UserInputType == Enum.UserInputType.Keyboard then vFlyKeybind = input.KeyCode; VFlyKeyBtn.Text = input.KeyCode.Name; VFlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isVFlyBinding = false; return end
    if isNoclipBinding and input.UserInputType == Enum.UserInputType.Keyboard then noclipKeybind = input.KeyCode; NoclipKeyBtn.Text = input.KeyCode.Name; NoclipKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isNoclipBinding = false; return end
    if isTripBinding and input.UserInputType == Enum.UserInputType.Keyboard then tripKeybind = input.KeyCode; TripKeyBtn.Text = input.KeyCode.Name; TripKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isTripBinding = false; return end
    if isSpinBinding and input.UserInputType == Enum.UserInputType.Keyboard then spinKeybind = input.KeyCode; SpinKeyBtn.Text = input.KeyCode.Name; SpinKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isSpinBinding = false; return end
    if isReverseBinding and input.UserInputType == Enum.UserInputType.Keyboard then reverseKeybind = input.KeyCode; ReverseKeyBtn.Text = input.KeyCode.Name; ReverseKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isReverseBinding = false; return end
    if isAirBinding and input.UserInputType == Enum.UserInputType.Keyboard then airKeybind = input.KeyCode; AirKeyBtn.Text = input.KeyCode.Name; AirKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isAirBinding = false; return end
    if isGlitchBinding and input.UserInputType == Enum.UserInputType.Keyboard then glitchKeybind = input.KeyCode; GlitchKeyBtn.Text = input.KeyCode.Name; GlitchKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isGlitchBinding = false; return end
        
    if not gp then
        -- Ocultar/Mostrar Menú (Botón Insert)
        if input.KeyCode == Enum.KeyCode.Insert then 
            if Main.Visible then
                Main.Visible = false; MPMain.Visible = false; TPMain.Visible = false; InvMain.Visible = false; FlyMain.Visible = false; VFlyMain.Visible = false; NoclipMain.Visible = false; TripMain.Visible = false; SetMain.Visible = false; HideMain.Visible = false; GenMain.Visible = false
                if ChatMain then ChatMain.Visible = false end
                if ReverseMain then ReverseMain.Visible = false end
                if FreecamMain then FreecamMain.Visible = false end
                if ESPMain then ESPMain.Visible = false end
                if SpinMain then SpinMain.Visible = false end
                if AirMain then AirMain.Visible = false end
                if GlitchMain then GlitchMain.Visible = false end -- <--- ESTA ES LA LÍNEA NUEVA
            else
                Main.Visible = true
            end
        end
        
        -- Ejecución Segura
        if invKeybind and input.KeyCode == invKeybind and type(ToggleGhost) == "function" then ToggleGhost() end
        if flyKeybind and input.KeyCode == flyKeybind and type(ToggleFly) == "function" then ToggleFly() end
        if vFlyKeybind and input.KeyCode == vFlyKeybind and type(ToggleVFly) == "function" then ToggleVFly() end
        if noclipKeybind and input.KeyCode == noclipKeybind and type(ToggleNoclipWalk) == "function" then ToggleNoclipWalk() end
        if tripKeybind and input.KeyCode == tripKeybind and type(DoTrip) == "function" then DoTrip() end
        if isTripped and input.KeyCode == Enum.KeyCode.Space and type(GetUpFromTrip) == "function" then GetUpFromTrip(false) end
        if airKeybind and input.KeyCode == airKeybind and type(ToggleAirWalk) == "function" then ToggleAirWalk() end
        if glitchKeybind and input.KeyCode == glitchKeybind and not UserInputService:GetFocusedTextBox() then
        if type(ToggleGlitch) == "function" then ToggleGlitch() end
    end
        
        -- FIX DEL KEYBIND DE SPINBOT: Verifica que no estés escribiendo en un TextBox
        if spinKeybind and input.KeyCode == spinKeybind and not UserInputService:GetFocusedTextBox() then
            if type(ToggleSpin) == "function" then ToggleSpin() end
        end
        
        -- FIX REVERSE: Activación por Teclado
        if reverseKeybind and input.KeyCode == reverseKeybind and isReverseActive then
            -- El Rewind se activa mientras se mantenga presionada la tecla (Manejado en el RenderStepped de Reverse)
        end
        
        -- Controles Vuelo
        if isFlying and type(flycontrol) == "table" then
            if input.KeyCode == Enum.KeyCode.W then flycontrol.F = 1
            elseif input.KeyCode == Enum.KeyCode.S then flycontrol.B = 1
            elseif input.KeyCode == Enum.KeyCode.D then flycontrol.R = 1
            elseif input.KeyCode == Enum.KeyCode.A then flycontrol.L = 1
            elseif input.KeyCode == Enum.KeyCode.Space then flycontrol.U = 1
            elseif input.KeyCode == Enum.KeyCode.Q then flycontrol.D = 1 end
        end
    end
end)

inputEndedConn = UserInputService.InputEnded:Connect(function(input, gp)
    if ScriptIsDead then return end
    if not gp then
        if isFlying and type(flycontrol) == "table" then
            if input.KeyCode == Enum.KeyCode.W then flycontrol.F = 0
            elseif input.KeyCode == Enum.KeyCode.S then flycontrol.B = 0
            elseif input.KeyCode == Enum.KeyCode.D then flycontrol.R = 0
            elseif input.KeyCode == Enum.KeyCode.A then flycontrol.L = 0
            elseif input.KeyCode == Enum.KeyCode.Space then flycontrol.U = 0
            elseif input.KeyCode == Enum.KeyCode.Q then flycontrol.D = 0 end
        end
    end
end)

-- ==================================================================
-- SISTEMA DE KEY, RECORDATORIO (30 DÍAS) Y VERIFICACIÓN HWID
-- ==================================================================
Main.Visible = false 

local KeyScreen = Instance.new("ScreenGui", targetGuiParent)
KeyScreen.Name = "CDT_KeySystem"
KeyScreen.IgnoreGuiInset = true
KeyScreen.ResetOnSpawn = false 

local Background = Instance.new("Frame", KeyScreen)
Background.Size = UDim2.new(1, 0, 1, 0); Background.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Background.BackgroundTransparency = 0.2

local KeyBox = Instance.new("Frame", Background)
KeyBox.Size = UDim2.new(0, 320, 0, 260); KeyBox.Position = UDim2.new(0.5, -160, 0.5, -130); KeyBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15); KeyBox.ClipsDescendants = true
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 6)
local KeyStroke = Instance.new("UIStroke", KeyBox); KeyStroke.Color = borderDark; KeyStroke.Thickness = 1.2

local TopKeyBar = Instance.new("Frame", KeyBox)
TopKeyBar.Size = UDim2.new(1, 0, 0, 35); TopKeyBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); Instance.new("UICorner", TopKeyBar).CornerRadius = UDim.new(0, 6)
local KeyFix = Instance.new("Frame", TopKeyBar); KeyFix.Size = UDim2.new(1, 0, 0, 5); KeyFix.Position = UDim2.new(0, 0, 1, -5); KeyFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
local KeyTopTitle = Instance.new("TextLabel", TopKeyBar); KeyTopTitle.Size = UDim2.new(1, -30, 1, 0); KeyTopTitle.Position = UDim2.new(0, 15, 0, 0); KeyTopTitle.BackgroundTransparency = 1; KeyTopTitle.Text = "C.D.T OPTIFINE // AUTHENTICATION"; KeyTopTitle.TextColor3 = tWhite; KeyTopTitle.Font = Enum.Font.GothamBold; KeyTopTitle.TextSize = 12; KeyTopTitle.TextXAlignment = Enum.TextXAlignment.Left

local WelcomeTitle = Instance.new("TextLabel", KeyBox); WelcomeTitle.Size = UDim2.new(1, 0, 0, 40); WelcomeTitle.Position = UDim2.new(0, 0, 0, 45); WelcomeTitle.BackgroundTransparency = 1; WelcomeTitle.Text = "BIENVENIDO, " .. string.upper(LocalPlayer.Name); WelcomeTitle.TextColor3 = tWhite; WelcomeTitle.Font = Enum.Font.GothamBold; WelcomeTitle.TextSize = 16
local SubTitle = Instance.new("TextLabel", KeyBox); SubTitle.Size = UDim2.new(1, 0, 0, 20); SubTitle.Position = UDim2.new(0, 0, 0, 75); SubTitle.BackgroundTransparency = 1; SubTitle.Text = "Verificando conexión segura..."; SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150); SubTitle.Font = Enum.Font.GothamMedium; SubTitle.TextSize = 12

local KeyInputBox = Instance.new("TextBox", KeyBox); KeyInputBox.Size = UDim2.new(1, -40, 0, 40); KeyInputBox.Position = UDim2.new(0, 20, 0, 110); KeyInputBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10); KeyInputBox.TextColor3 = tWhite; KeyInputBox.PlaceholderText = "> Ingresa tu key aquí..."; KeyInputBox.Font = Enum.Font.Gotham; KeyInputBox.TextSize = 13; KeyInputBox.Text = ""; KeyInputBox.Visible = false; Instance.new("UICorner", KeyInputBox).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", KeyInputBox).Color = Color3.fromRGB(40, 40, 40)

local RememberCheck = Instance.new("TextButton", KeyBox); RememberCheck.Size = UDim2.new(1, -40, 0, 20); RememberCheck.Position = UDim2.new(0, 20, 0, 160); RememberCheck.BackgroundTransparency = 1; RememberCheck.Text = "☐ Recordar Key (30 días)"; RememberCheck.TextColor3 = tWhite; RememberCheck.Font = Enum.Font.Gotham; RememberCheck.TextSize = 12; RememberCheck.TextXAlignment = Enum.TextXAlignment.Left; RememberCheck.Visible = false
local isRemembered = false
RememberCheck.MouseButton1Click:Connect(function() isRemembered = not isRemembered; RememberCheck.Text = isRemembered and "☑ Recordar Key (30 días)" or "☐ Recordar Key (30 días)"; RememberCheck.TextColor3 = isRemembered and tGreen or tWhite end)

local VerifyBtn = Instance.new("TextButton", KeyBox); VerifyBtn.Size = UDim2.new(0.45, 0, 0, 35); VerifyBtn.Position = UDim2.new(0, 20, 0, 195); VerifyBtn.BackgroundColor3 = tGreen; VerifyBtn.TextColor3 = Color3.fromRGB(10, 10, 10); VerifyBtn.Text = "VERIFICAR"; VerifyBtn.Font = Enum.Font.GothamBold; VerifyBtn.TextSize = 12; VerifyBtn.Visible = false; Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 4)
local GetKeyBtn = Instance.new("TextButton", KeyBox); GetKeyBtn.Size = UDim2.new(0.45, 0, 0, 35); GetKeyBtn.Position = UDim2.new(0.55, -20, 0, 195); GetKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); GetKeyBtn.TextColor3 = tWhite; GetKeyBtn.Text = "OBTENER KEY"; GetKeyBtn.Font = Enum.Font.GothamBold; GetKeyBtn.TextSize = 12; GetKeyBtn.Visible = false; Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 4)

MakeDraggable(TopKeyBar, KeyBox)

local function SaveKeyLocal(key)
    if writefile then local data = HttpService:JSONEncode({savedKey = key, timestamp = tick()}); pcall(function() writefile(AuthFileName, data) end) end
end

local function ProcessKey(inputKey, isAutoLogin)
    SubTitle.Text = isAutoLogin and "Comprobando llave recordada..." or "Comprobando..."; SubTitle.TextColor3 = tYellow
    local hwid = RbxAnalytics:GetClientId()
    local reqAPI = BASE_URL .. "/api/verify"

    task.spawn(function()
        local success, res = pcall(function() return request({Url = reqAPI, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode({key = inputKey, hwid = hwid})}) end)

        if success and res and res.StatusCode == 200 then
            local decoded = HttpService:JSONDecode(res.Body)
            if decoded.success then
                if isRemembered and not isAutoLogin then SaveKeyLocal(inputKey) end
                SubTitle.Text = "¡Acceso Autorizado!"; SubTitle.TextColor3 = tGreen
                CurrentExpirationText = decoded.expiresText or "Desconocido"; ExpLabel.Text = CurrentExpirationText
                if string.find(CurrentExpirationText, "Expira") then ExpLabel.TextColor3 = tOrange else ExpLabel.TextColor3 = tCyan end
                
                task.wait(1); if KeyScreen then KeyScreen:Destroy() end
                Main.Visible = true; LogMessage("Sistema desbloqueado correctamente.", tGreen)
            else
                if isAutoLogin then
                    if isfile and isfile(AuthFileName) then pcall(function() delfile(AuthFileName) end) end
                    SubTitle.Text = "La llave guardada expiró o fue baneada."; SubTitle.TextColor3 = tRed
                    task.wait(1.5); SubTitle.Text = "Por favor, introduce tu Key de acceso."; KeyInputBox.Visible = true; VerifyBtn.Visible = true; GetKeyBtn.Visible = true; RememberCheck.Visible = true
                else
                    SubTitle.Text = decoded.msg or "Key Inválida o Baneada."; SubTitle.TextColor3 = tRed
                end
            end
        else
            SubTitle.Text = "Error al conectar con el servidor."; SubTitle.TextColor3 = tRed
            if isAutoLogin then task.wait(2); KeyInputBox.Visible = true; VerifyBtn.Visible = true; GetKeyBtn.Visible = true; RememberCheck.Visible = true end
        end
    end)
end

task.spawn(function()
    local autoKey = nil
    if readfile and isfile and isfile(AuthFileName) then
        local success, dat = pcall(function() return HttpService:JSONDecode(readfile(AuthFileName)) end)
        if success and dat and dat.savedKey then autoKey = dat.savedKey end
    end
    if autoKey then task.wait(1); ProcessKey(autoKey, true)
    else task.wait(1.5); SubTitle.Text = "Por favor, introduce tu Key de acceso."; KeyInputBox.Visible = true; VerifyBtn.Visible = true; GetKeyBtn.Visible = true; RememberCheck.Visible = true end
end)

VerifyBtn.MouseButton1Click:Connect(function() if KeyInputBox.Text == "" then SubTitle.Text = "No puedes dejar el campo vacío."; SubTitle.TextColor3 = tRed return end; ProcessKey(KeyInputBox.Text, false) end)

GetKeyBtn.MouseButton1Click:Connect(function()
    local link = "https://discord.gg/6qG75JtTsX"
    if isMobile then
        if setclipboard then setclipboard(link); SubTitle.Text = "¡Link copiado al portapapeles!"; SubTitle.TextColor3 = tYellow end
    else
        local success = pcall(function() if open_url then open_url(link) else setclipboard(link) end end)
        if success then SubTitle.Text = "Link abierto / copiado. Entra al Discord."; SubTitle.TextColor3 = tYellow
        else SubTitle.Text = "Error al copiar el link. Únete manual."; SubTitle.TextColor3 = tRed end
    end
end)
