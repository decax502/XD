--[[
    C.D.T OPTIFINE - V10.8 PROJECT SAFE (KEY & AUTO-UPDATE)
    - Trip Mode (Un solo toque para caer, te quedas tirado hasta saltar con ESPACIO).
    - Inyección Segura (Bulletproof) y Responsive UI.
    - TP Menu (Buscador dinámico).
    - Map Points (Comando 'mp', Guarda lugares por juego).
    - Menú Invisible (SEAT MODE PERFECTO + KEYBIND).
    - Menú de Vuelo (Noclip Fly).
    - VEHICLE FLY (Lerp Suave).
    - REVERSE MODE (Flashback System + Custom Keybind).
    - GLOBAL CHAT SMART (Auto-Scroll).
    - Consola Inteligente.
    - Comando 'vtag' para ocultar/mostrar tu propio tag visualmente.
    - Panel de Ajustes (⚙) con Temas Consistentes.
    - Comando 'hide' que OCULTA EL AVATAR, MUTEA SONIDOS LOCALES Y MUTEA VOICE CHAT (AudioDeviceInput).
    - Comando !re integrado en chat y consola.
    - Comando 'infbase' para generar baseplates infinitas.
    - Comando 'generacion' para crear objetos en el servidor (Sliders X, Y, Z integrados).
    - SISTEMA DE KEY, HWID, RECORDATORIO DE 30 DÍAS Y AUTO-ACTUALIZACIÓN GLOBAL.
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

repeat task.wait() until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local posicionGuardadaRE = nil
local DestruirScriptCompleto

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

local targetGuiParent = nil
pcall(function() targetGuiParent = gethui() end)
if not targetGuiParent then pcall(function() targetGuiParent = CoreGui end) end
if not targetGuiParent then targetGuiParent = LocalPlayer:WaitForChild("PlayerGui") end

if targetGuiParent:FindFirstChild("CDT_Optifine_Fluid") then
    targetGuiParent:FindFirstChild("CDT_Optifine_Fluid"):Destroy()
end
if _G.DestruirTags then pcall(function() _G.DestruirTags() end) end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CDT_Optifine_Fluid"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false 
ScreenGui.Parent = targetGuiParent

-- ==================================================================
-- FUNCION REINICIO GLOBAL AUTOMATICO Y DESTRUCCIÓN TOTAL
-- ==================================================================
local function AutoRestartScript()
    if DestruirScriptCompleto then
        DestruirScriptCompleto()
    end
    StarterGui:SetCore("SendNotification", {
        Title="SAFE DEV", 
        Text="El servidor ha forzado una actualización Global. Por favor, reinyecta el script.", 
        Duration=10
    })
end

-- ==================================================================
-- SISTEMA NAME TAGS E INVISIBILIDAD LOCAL DE JUGADORES + VOICE MUTE
-- ==================================================================

local function OcultarAvatar(character, ocultar)
    if not character then return end
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
            obj.Transparency = ocultar and 1 or 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = ocultar and 1 or 0
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
        if audioInput then
            audioInput.Muted = ocultar
        end
    end)
end

-- Bucle de Radar y Chequeo de Actualización
task.spawn(function()
    while scriptActivoTags do
        local successPing, resPing = pcall(function()
            return request({
                Url = BASE_URL .. "/api/ping/" .. tostring(LocalPlayer.UserId),
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = "{}"
            })
        end)
        
        if successPing and resPing and resPing.StatusCode == 200 then
            local sDecode, dat = pcall(function() return HttpService:JSONDecode(resPing.Body) end)
            if sDecode and dat and dat.updateTime then
                if _GlobalUpdateTimestamp == 0 then
                    _GlobalUpdateTimestamp = dat.updateTime
                elseif dat.updateTime > _GlobalUpdateTimestamp then
                    scriptActivoTags = false
                    AutoRestartScript()
                end
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
        snow.Position = UDim2.new(math.random(5, 95)/100, 0, -0.3, 0)
        snow.ZIndex = 2
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
                while uiData.animNameTask and uiData.TxtName and uiData.TxtName.Parent do
                    local t1 = TweenService:Create(uiData.TxtName, TweenInfo.new(1), {TextColor3 = Color3.fromHex("#60a5fa")})
                    t1:Play() t1.Completed:Wait()
                    if not uiData.animNameTask then break end
                    local t2 = TweenService:Create(uiData.TxtName, TweenInfo.new(1), {TextColor3 = Color3.fromHex("#c084fc")})
                    t2:Play() t2.Completed:Wait()
                    if not uiData.animNameTask then break end
                    local t3 = TweenService:Create(uiData.TxtName, TweenInfo.new(1), {TextColor3 = Color3.new(1,1,1)})
                    t3:Play() t3.Completed:Wait()
                end
            end)
        end
    else
        uiData.animNameTask = false
        if uiData.TxtName then uiData.TxtName.TextColor3 = Color3.new(1,1,1) end
    end
end

local function crearUITag(player, datos, userId)
    local head = player.Character and player.Character:FindFirstChild("Head")
    if not head then return end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end

    local nombreUI = "SafeHTML_" .. userId
    if targetGuiParent:FindFirstChild(nombreUI) then targetGuiParent[nombreUI]:Destroy() end

    local tTit = datos.titulo or "USER"; local tNom = player.Name:upper()
    local sF, fU = pcall(function() return Enum.Font[datos.fuente] end)
    if not sF or not fU then fU = Enum.Font.GothamBold end
    
    local bT = TextService:GetTextSize(tTit, 16, fU, Vector2.new(1000, 50)); 
    local bN = TextService:GetTextSize(tNom, 13, Enum.Font.GothamBold, Vector2.new(1000, 50))
    local aI = 8 + 36 + 10 + math.max(bT.X, bN.X) + 16; if aI < 110 then aI = 110 end 

    local bill = Instance.new("BillboardGui", targetGuiParent)
    bill.Name = nombreUI; bill.Adornee = head; bill.Size = UDim2.new(0, aI, 0, 50); 
    bill.StudsOffset = Vector3.new(0, 1.8, 0); 
    bill.AlwaysOnTop = true; bill.MaxDistance = math.huge; bill.ResetOnSpawn = false; bill.Active = true 
    local scale = Instance.new("UIScale", bill); scale.Scale = 1
    local card = Instance.new("Frame", bill); card.Size = UDim2.new(0, aI, 0, 50); card.AnchorPoint = Vector2.new(0.5, 0.5); card.Position = UDim2.new(0.5, 0, 0.5, 0); card.BackgroundColor3 = Color3.new(1, 1, 1) 
    local corner = Instance.new("UICorner", card); corner.CornerRadius = UDim.new(0, 8)
    local grad = Instance.new("UIGradient", card); grad.Rotation = 45; grad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, parseHexTag(datos.colorFondo1, "#1c1c24")), ColorSequenceKeypoint.new(1, parseHexTag(datos.colorFondo2, "#0f0f13")) })
    
    local stroke = Instance.new("UIStroke", card); stroke.Color = Color3.new(1,1,1); stroke.Transparency = 0.7; stroke.Thickness = 1.2
    local strokeGrad = Instance.new("UIGradient", stroke); strokeGrad.Rotation = 45; strokeGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, parseHexTag(datos.colorBorde1 or datos.colorBorde, "#FFFFFF")), ColorSequenceKeypoint.new(1, parseHexTag(datos.colorBorde2 or datos.colorBorde, "#FFFFFF")) })
    
    local snowCont = Instance.new("Frame", card); snowCont.Size = UDim2.new(1,0,1,0); snowCont.BackgroundTransparency = 1; snowCont.ClipsDescendants = true; Instance.new("UICorner", snowCont).CornerRadius = UDim.new(0,8)
    local listaCopos = crearNieveTag(snowCont, datos.emojiNieve, datos.colorNieve or "#ffffff")

    local avF = Instance.new("Frame", card); avF.Size = UDim2.new(0, 36, 0, 36); avF.AnchorPoint = Vector2.new(0, 0.5); avF.Position = UDim2.new(0, 8, 0.5, 0); avF.BackgroundColor3 = Color3.fromHex("#2a2a35"); Instance.new("UICorner", avF).CornerRadius = UDim.new(1, 0)
    local avS = Instance.new("UIStroke", avF); avS.Color = Color3.new(0, 0, 0); avS.Transparency = 0; avS.Thickness = 1 

    local avatarImg = Instance.new("ImageLabel", avF); avatarImg.Size = UDim2.new(1, 0, 1, 0); avatarImg.BackgroundTransparency = 1
    task.spawn(function() local img = obtenerImagenTag(datos.imagen, userId); if avatarImg and avatarImg.Parent then avatarImg.Image = img end end)
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame", avF); dot.Size = UDim2.new(0, 10, 0, 10); dot.Position = UDim2.new(1, 0, 1, 0); dot.AnchorPoint = Vector2.new(1, 1); dot.BackgroundColor3 = Color3.fromHex("#2ed573"); dot.ZIndex = 5
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local dotStroke = Instance.new("UIStroke", dot); dotStroke.Color = parseHexTag(datos.colorFondo2, "#0f0f13"); dotStroke.Thickness = 2

    local infoGroup = Instance.new("Frame", card); infoGroup.Size = UDim2.new(1, -54, 0, 36); infoGroup.AnchorPoint = Vector2.new(0, 0.5); infoGroup.Position = UDim2.new(0, 50, 0.5, 0); infoGroup.BackgroundTransparency = 1

    local txtTitle = Instance.new("TextLabel", infoGroup); txtTitle.BackgroundTransparency = 1; txtTitle.Size = UDim2.new(1, 0, 0, 18); txtTitle.Position = UDim2.new(0, 0, 0, 0)
    txtTitle.Font = fU; txtTitle.Text = tTit; txtTitle.TextColor3 = Color3.new(1,1,1); txtTitle.TextSize = 16; txtTitle.TextXAlignment = Enum.TextXAlignment.Left
    local titleGrad = Instance.new("UIGradient", txtTitle); titleGrad.Rotation = 45; titleGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, parseHexTag(datos.colorTitulo1 or datos.colorTitulo, "#ffffff")), ColorSequenceKeypoint.new(1, parseHexTag(datos.colorTitulo2 or datos.colorTitulo, "#ffffff")) })

    local txtName = Instance.new("TextLabel", infoGroup); txtName.BackgroundTransparency = 1; txtName.Size = UDim2.new(1, 0, 0, 14); txtName.Position = UDim2.new(0, 0, 0, 18)
    txtName.Font = Enum.Font.GothamBold; txtName.Text = tNom; txtName.TextColor3 = Color3.new(1,1,1); txtName.TextSize = 13; txtName.TextXAlignment = Enum.TextXAlignment.Left
    local nameGrad = Instance.new("UIGradient", txtName); nameGrad.Rotation = 45; nameGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, parseHexTag(datos.colorNombre1 or datos.colorNombre, "#a0a0b0")), ColorSequenceKeypoint.new(1, parseHexTag(datos.colorNombre2 or datos.colorNombre, "#a0a0b0")) })

    local btnTP = Instance.new("TextButton", card); btnTP.Size = UDim2.new(1, 0, 1, 0); btnTP.BackgroundTransparency = 1; btnTP.Text = ""; btnTP.ZIndex = 100
    btnTP.MouseButton1Click:Connect(function()
        if player.Character and LocalPlayer.Character and player ~= LocalPlayer then
            local target = player.Character:FindFirstChild("HumanoidRootPart"); local me = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if target and me then local flash = Instance.new("ColorCorrectionEffect", Lighting); flash.Brightness = 1; TweenService:Create(flash, TweenInfo.new(0.3), {Brightness = 0}):Play(); game.Debris:AddItem(flash, 0.4); me.CFrame = target.CFrame * CFrame.new(0, 0, 3) end
        end
    end)

    UIsActivos[userId] = { Estado = "Abierto", UI = bill, Escalador = scale, Head = head, Card = card, CardCorner = corner, CardStroke = stroke, Gradiente = grad, Avatar = avF, AvatarImg = avatarImg, TxtTitle = txtTitle, TxtName = txtName, SnowContainer = snowCont, Copos = listaCopos, DotStroke = dotStroke, AnchoIdeal = aI, StrokeGrad = strokeGrad, TitleGrad = titleGrad, NameGrad = nameGrad }
    actualizarAnimacionNombreTag(UIsActivos[userId], datos)
end

task.spawn(function()
    local oldDataCache = {}
    while scriptActivoTags do
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
                    
                    if hiddenTags[id] then 
                        OcultarAvatar(player.Character, true) 
                        MutearVoiceChat(player, true) 
                    end
                    
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
                                    local sF, fU = pcall(function() return Enum.Font[cfg.fuente] end)
                                    if sF and fU then ui.TxtTitle.Font = fU end
                                    ui.TxtTitle.TextColor3 = Color3.new(1,1,1)
                                    if not cfg.animarNombre then ui.TxtName.TextColor3 = Color3.new(1,1,1) end
                                    task.spawn(function() local newImg = obtenerImagenTag(cfg.imagen, id); if ui.AvatarImg and ui.AvatarImg.Parent then ui.AvatarImg.Image = newImg end end)
                                    ui.DotStroke.Color = parseHexTag(cfg.colorFondo2, "#0f0f13")
                                    for _, copo in ipairs(ui.Copos) do if copo.Parent then copo.Text = cfg.emojiNieve or "*"; copo.TextColor3 = parseHexTag(cfg.colorNieve, "#ffffff") end end
                                    actualizarAnimacionNombreTag(ui, cfg)
                                    local bT = TextService:GetTextSize(ui.TxtTitle.Text, 16, ui.TxtTitle.Font, Vector2.new(1000, 50)); local bN = TextService:GetTextSize(player.Name:upper(), 13, Enum.Font.GothamBold, Vector2.new(1000, 50))
                                    ui.AnchoIdeal = math.max(110, 8 + 36 + 10 + math.max(bT.X, bN.X) + 16)
                                    if ui.Estado == "Abierto" then TweenService:Create(ui.Card, TweenInfo.new(0.2), {Size = UDim2.new(0, ui.AnchoIdeal, 0, 50)}):Play() end
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
RunService.RenderStepped:Connect(function()
    if not scriptActivoTags then return end
    for id, data in pairs(UIsActivos) do
        if data.Head and data.Head.Parent and data.UI.Parent then
            if id == tostring(LocalPlayer.UserId) then data.UI.Enabled = verMiTag else data.UI.Enabled = not hiddenTags[id] end
            local dist = (Camera.CFrame.Position - data.Head.Position).Magnitude
            if dist > 35 then data.Escalador.Scale = math.clamp(40 / dist, 0.5, 1) else data.Escalador.Scale = 1 end
            if dist > 28 and data.Estado == "Abierto" then
                data.Estado = "Cerrado"; data.SnowContainer.Visible = false
                TweenService:Create(data.TxtTitle, animSpd, {TextTransparency = 1}):Play(); TweenService:Create(data.TxtName, animSpd, {TextTransparency = 1}):Play()
                TweenService:Create(data.Card, animSpd, {Size = UDim2.new(0, 46, 0, 46)}):Play(); TweenService:Create(data.CardCorner, animSpd, {CornerRadius = UDim.new(1, 0)}):Play(); TweenService:Create(data.Avatar, animSpd, {Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5)}):Play()
            elseif dist < 23 and data.Estado == "Cerrado" then
                data.Estado = "Abierto"; data.SnowContainer.Visible = true
                TweenService:Create(data.TxtTitle, animSpd, {TextTransparency = 0}):Play(); TweenService:Create(data.TxtName, animSpd, {TextTransparency = 0}):Play()
                TweenService:Create(data.Card, animSpd, {Size = UDim2.new(0, data.AnchoIdeal, 0, 50)}):Play(); TweenService:Create(data.CardCorner, animSpd, {CornerRadius = UDim.new(0, 8)}):Play(); TweenService:Create(data.Avatar, animSpd, {Position = UDim2.new(0, 8, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)}):Play()
            end
        else
            if data.UI then data.UI:Destroy() end; UIsActivos[id] = nil
        end
    end
end)


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

-- LABEL DE EXPIRACIÓN EN LA BARRA
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

LocalPlayer.Chatted:Connect(function(msg)
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
end)

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
TPSearchBox:GetPropertyChangedSignal("Text"):Connect(function() RefreshTPMenu(TPSearchBox.Text) end)
Players.PlayerAdded:Connect(function() if TPMain.Visible then RefreshTPMenu(TPSearchBox.Text) end end)
Players.PlayerRemoving:Connect(function() if TPMain.Visible then RefreshTPMenu(TPSearchBox.Text) end end)

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
                
                if isHid then
                    MutearVoiceChat(plr, true)
                end
                
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
HideSearchBox:GetPropertyChangedSignal("Text"):Connect(function() RefreshHideMenu(HideSearchBox.Text) end)
Players.PlayerAdded:Connect(function() if HideMain.Visible then RefreshHideMenu(HideSearchBox.Text) end end)
Players.PlayerRemoving:Connect(function() if HideMain.Visible then RefreshHideMenu(HideSearchBox.Text) end end)

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
local currentInvisSeat = nil -- FIX: Variable para no perder el asiento

-- FIX: Modificado para afectar también caras y texturas
local function setCharacterTransparency(char, val)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.Transparency = val
        elseif p:IsA("Decal") or p:IsA("Texture") then
            p.Transparency = val
        end
    end
end

local function ToggleGhost()
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
                -- FIX: Limpieza correcta si no encuentra el torso y reset de UI
                if currentInvisSeat then currentInvisSeat:Destroy(); currentInvisSeat = nil end
                isGhostActive = false; setCharacterTransparency(char, 0) 
                InvToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); InvToggleBtn.TextColor3 = tWhite; InvToggleBtn.Text = "INVISIBILIDAD: OFF"
            end
        end
    else
        if char then setCharacterTransparency(char, 0) end
        
        -- FIX: Eliminación exacta del asiento
        if currentInvisSeat and currentInvisSeat.Parent then 
            pcall(function() currentInvisSeat:Destroy() end) 
        end
        currentInvisSeat = nil
        
        -- Fallback de seguridad por si otro script creó uno
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
-- 5. INTERFAZ Y LÓGICA DEL MENÚ FLY (NOCLIP FLY AEREO)
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

local function ToggleVFly()
    isVFlying = not isVFlying; local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
    if isVFlying then
        VFlyToggleBtn.BackgroundColor3 = tPurple; VFlyToggleBtn.Text = "V-FLY: ON"
        if root then vFlyCurrentVel = root.Velocity end; vFlyConn = RunService.Heartbeat:Connect(VFlyLoop)
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
-- 8. TRIP MODE MENU (CAÍDA INFINITA + LEVANTARSE CON ESPACIO)
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

local isTripped = false
local tripKeybind = nil
local isTripBinding = false
local tripStateConn = nil -- Variable para la detección inteligente

local function CleanTripConnections()
    if tripStateConn then tripStateConn:Disconnect(); tripStateConn = nil end
end

-- El parámetro "autoClean" avisa si el juego lo levantó por su cuenta
local function GetUpFromTrip(autoClean)
    if not isTripped then return end
    isTripped = false
    CleanTripConnections()
    
    -- El botón vuelve a la normalidad
    TripToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TripToggleBtn.TextColor3 = tWhite
    TripToggleBtn.Text = "TRIP (CLICK)"

    local char = LocalPlayer.Character; if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    -- FIX: Restaurar físicas base SIEMPRE para que el Shift Lock y la rotación no se bugueen
    humanoid.PlatformStand = false
    humanoid.AutoRotate = true

    -- Si no fue forzado por el juego, ejecutamos la rutina para levantarlo nosotros
    if not autoClean then
        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + Vector3.new(0, 10, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    
    -- Siempre limpiamos las físicas personalizadas
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = nil 
        end
    end
end

local function DoTrip()
    if isTripped then return end
    local char = LocalPlayer.Character; if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    isTripped = true 
    CleanTripConnections()
    
    -- Evento Inteligente: Detectar si el juego u otro script levanta al personaje
    tripStateConn = humanoid.StateChanged:Connect(function(oldState, newState)
        if not isTripped then return end
        if newState == Enum.HumanoidStateType.Running or newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Walking or newState == Enum.HumanoidStateType.Dead then
            -- El juego lo levantó o mató, limpiamos la UI sin forzar físicas de nuevo
            GetUpFromTrip(true)
        end
    end)
    
    TripToggleBtn.BackgroundColor3 = tRed
    TripToggleBtn.TextColor3 = tWhite
    TripToggleBtn.Text = "LEVANTARSE (CLICK)"

    local currentVelocity = root.AssemblyLinearVelocity
    local speed = currentVelocity.Magnitude

    humanoid.PlatformStand = true
    humanoid.AutoRotate = false

    local impulso = (speed > 5) and (currentVelocity * 1.3) or (root.CFrame.LookVector * 10)
    root.AssemblyLinearVelocity = impulso + Vector3.new(0, 8, 0)
    
    local spin = speed > 5 and 20 or 10
    root.AssemblyAngularVelocity = Vector3.new(math.random(-spin, spin), math.random(-spin, spin), math.random(-spin, spin))

    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.1, 0.1, 1, 1)
        end
    end
end

TripToggleBtn.MouseButton1Click:Connect(function()
    if isTripped then
        GetUpFromTrip(false)
    else
        DoTrip()
    end
end)

TripCloseBtn.MouseButton1Click:Connect(function() 
    TripMain.Visible = false; tripKeybind = nil; isTripBinding = false; TripKeyBtn.Text = "KEY"; TripKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) 
    if isTripped then GetUpFromTrip(false) end
end)

TripKeyBtn.MouseButton1Click:Connect(function()
    if tripKeybind ~= nil then 
        tripKeybind = nil; TripKeyBtn.Text = "KEY"; TripKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isTripBinding = false
    else 
        isTripBinding = true; TripKeyBtn.Text = "..."; TripKeyBtn.BackgroundColor3 = tOrange 
    end
end)

-- ==================================================================
-- 14. FREECAM MENU (EXPLORACIÓN LIBRE + SHIFT LOCK + MOBILE)
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

local function ToggleFreecam()
    isFreecamActive = not isFreecamActive
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if isFreecamActive then
        FreecamToggleBtn.BackgroundColor3 = tCyan; FreecamToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 10); FreecamToggleBtn.Text = "FREECAM: ON"
        if hrp then hrp.Anchored = true end
        
        fcTargetCFrame = Camera.CFrame
        local rx, ry, rz = Camera.CFrame:ToEulerAnglesYXZ()
        fcPitch, fcYaw = rx, ry
        Camera.CameraType = Enum.CameraType.Scriptable
        
        -- Eventos de Input para mover la cámara libremente
        fcInputConn1 = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            
            -- Activar/Desactivar Shift Lock en Freecam
            if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
                isShiftLocked = not isShiftLocked
                if isShiftLocked then
                    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                else
                    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                end
            end

            -- Mirar manteniendo Click Derecho o Touch
            if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
                isHoldingRightClick = true
                if not isShiftLocked and input.UserInputType == Enum.UserInputType.MouseButton2 then 
                    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition 
                end
            end
        end)
        
        fcInputConn2 = UserInputService.InputEnded:Connect(function(input, gp)
            if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
                isHoldingRightClick = false
                if not isShiftLocked and input.UserInputType == Enum.UserInputType.MouseButton2 then 
                    UserInputService.MouseBehavior = Enum.MouseBehavior.Default 
                end
            end
        end)

        local moveConn = UserInputService.InputChanged:Connect(function(input, gp)
            if (isHoldingRightClick or isShiftLocked) and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Delta
                fcPitch = math.clamp(fcPitch - delta.Y * 0.005, -math.rad(89), math.rad(89))
                fcYaw = fcYaw - delta.X * 0.005
            end
        end)
        
        fcRenderConn = RunService.RenderStepped:Connect(function(dt)
            local moveVec = getFCMovement()
            local rotCFrame = CFrame.new(Vector3.zero) * CFrame.Angles(0, fcYaw, 0) * CFrame.Angles(fcPitch, 0, 0)
            local targetVelocity = rotCFrame:VectorToWorldSpace(moveVec) * fcSpeed
            
            fcVelocity = fcVelocity:Lerp(targetVelocity, fcSmoothness)
            fcTargetCFrame = CFrame.new(fcTargetCFrame.Position + (fcVelocity * dt)) * rotCFrame
            Camera.CFrame = Camera.CFrame:Lerp(fcTargetCFrame, fcSmoothness)
        end)
        
        -- Guardar la conexión de movimiento para limpiarla después
        fcRenderConn.Name = "FC_Render"
        _G.FCMoveConn = moveConn
    else
        FreecamToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); FreecamToggleBtn.TextColor3 = tWhite; FreecamToggleBtn.Text = "FREECAM: OFF"
        if hrp then hrp.Anchored = false end
        Camera.CameraType = Enum.CameraType.Custom
        if char and char:FindFirstChild("Humanoid") then Camera.CameraSubject = char.Humanoid end
        
        -- Limpiar estados de ratón
        isHoldingRightClick = false
        isShiftLocked = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        
        if fcInputConn1 then fcInputConn1:Disconnect() end
        if fcInputConn2 then fcInputConn2:Disconnect() end
        if fcRenderConn then fcRenderConn:Disconnect() end
        if _G.FCMoveConn then _G.FCMoveConn:Disconnect() end
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

-- ==================================================================
-- 13. REVERSE MODE (FLASHBACK / TIME REWIND)
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
local flashbacklength = 500; local flashbackspeed = 2; local frames = {}
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
    
    local value = defaultValue
    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        value = math.floor(1 + (pos * 199))
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        SliderBtn.Position = UDim2.new(pos, -6, 0.5, -9)
        Label.Text = name .. ": " .. value
    end

    SliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end)

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
        -- Feedback visual en el botón
        local oldText = GenFireBtn.Text; GenFireBtn.Text = "¡ENVIADO!"; task.wait(1); GenFireBtn.Text = oldText
    else
        -- Feedback de error
        local oldText = GenFireBtn.Text; GenFireBtn.BackgroundColor3 = tRed; GenFireBtn.TextColor3 = tWhite; GenFireBtn.Text = "ERROR: EVENTO NO ENCONTRADO"; task.wait(2); GenFireBtn.BackgroundColor3 = tGreen; GenFireBtn.TextColor3 = Color3.fromRGB(10, 10, 10); GenFireBtn.Text = oldText
    end
end)


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

    local frames = {Main, MPMain, TPMain, InvMain, FlyMain, VFlyMain, NoclipMain, TripMain, ChatMain, SetMain, HideMain, GenMain, ReverseMain}
    local topbars = {TopBar, MPTopBar, TPTopBar, InvTopBar, FlyTopBar, VFlyTopBar, NoclipTopBar, TripTopBar, ChatTopBar, SetTopBar, HideTopBar, GenTopBar, ReverseTopBar}
    local fixes = {Fix, MPFix, TPFix, InvFix, FlyFix, VFlyFix, NoclipFix, TripFix, ChatFix, SetFix, HideFix, GenFix, ReverseFix}
    local strokes = {MainStroke, MPMainStroke, TPMainStroke, InvMainStroke, FlyMainStroke, VFlyMainStroke, NoclipMainStroke, TripMainStroke, SetMainStroke, HideMainStroke, GenMainStroke, ReverseMainStroke}
    
    for _, f in ipairs(frames) do if f then f.BackgroundTransparency = bgTrans; f.BackgroundColor3 = bgColor end end
    for _, tb in ipairs(topbars) do if tb then tb.BackgroundTransparency = tbTrans; tb.BackgroundColor3 = tbColor end end
    for _, fx in ipairs(fixes) do if fx then fx.BackgroundTransparency = tbTrans; fx.BackgroundColor3 = tbColor end end
    for _, s in ipairs(strokes) do if s then s.Color = strokeColor; s.Transparency = strokeTrans; if isGlass then s.Thickness = 1.2 else s.Thickness = 1 end end end
end)

-- ==================================================================
-- 9. CHAT GLOBAL SMART SCROLL
-- ==================================================================
local setclipboard = setclipboard or toclipboard or set_clipboard

ChatMain = Instance.new("Frame", ScreenGui)
ChatMain.Size = UDim2.new(0, 380, 0, 270); ChatMain.Position = UDim2.new(0.5, -190, 1, -300); ChatMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); ChatMain.BorderSizePixel = 0; ChatMain.ClipsDescendants = true; ChatMain.Visible = false
Instance.new("UICorner", ChatMain).CornerRadius = UDim.new(0, 6); ChatStroke = Instance.new("UIStroke", ChatMain); ChatStroke.Color = borderDark
ApplyResponsiveScale(ChatMain)

ChatTopBar = Instance.new("Frame", ChatMain); ChatTopBar.Size = UDim2.new(1, 0, 0, 35); ChatTopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); ChatTopBar.BorderSizePixel = 0; Instance.new("UICorner", ChatTopBar).CornerRadius = UDim.new(0, 6)
ChatFix = Instance.new("Frame", ChatTopBar); ChatFix.Size = UDim2.new(1, 0, 0, 5); ChatFix.Position = UDim2.new(0, 0, 1, -5); ChatFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22); ChatFix.BorderSizePixel = 0
ChatTitle = Instance.new("TextLabel", ChatTopBar); ChatTitle.Size = UDim2.new(1, -70, 1, 0); ChatTitle.Position = UDim2.new(0, 15, 0, 0); ChatTitle.BackgroundTransparency = 1; ChatTitle.Text = "GLOBAL CHAT"; ChatTitle.TextColor3 = tWhite; ChatTitle.Font = Enum.Font.GothamBold; ChatTitle.TextSize = 13; ChatTitle.TextXAlignment = Enum.TextXAlignment.Left
ChatMinBtn = Instance.new("TextButton", ChatTopBar); ChatMinBtn.Size = UDim2.new(0, 35, 1, 0); ChatMinBtn.Position = UDim2.new(1, -70, 0, 0); ChatMinBtn.BackgroundTransparency = 1; ChatMinBtn.Text = "—"; ChatMinBtn.TextColor3 = tGreen; ChatMinBtn.Font = Enum.Font.GothamBlack; ChatMinBtn.TextSize = 14
ChatCloseBtn = Instance.new("TextButton", ChatTopBar); ChatCloseBtn.Size = UDim2.new(0, 35, 1, 0); ChatCloseBtn.Position = UDim2.new(1, -35, 0, 0); ChatCloseBtn.BackgroundTransparency = 1; ChatCloseBtn.Text = "X"; ChatCloseBtn.TextColor3 = tRed; ChatCloseBtn.Font = Enum.Font.GothamBlack; ChatCloseBtn.TextSize = 12

ChatScroll = Instance.new("ScrollingFrame", ChatMain); ChatScroll.Position = UDim2.new(0, 5, 0, 45); ChatScroll.Size = UDim2.new(1, -10, 0, 175); ChatScroll.BackgroundTransparency = 1; ChatScroll.ScrollBarThickness = 2; ChatScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
ChatLayout = Instance.new("UIListLayout", ChatScroll); ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder; ChatLayout.Padding = UDim.new(0, 4)

NewMsgBtn = Instance.new("TextButton", ChatMain); NewMsgBtn.Name = "NewMsgBtn"; NewMsgBtn.Text = "⬇ Nuevos Mensajes"; NewMsgBtn.Size = UDim2.new(0, 150, 0, 25); NewMsgBtn.Position = UDim2.new(0.5, -75, 1, -70); NewMsgBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22); NewMsgBtn.TextColor3 = tYellow; NewMsgBtn.Font = Enum.Font.GothamBold; NewMsgBtn.Visible = false; NewMsgBtn.ZIndex = 5; NewMsgBtn.TextSize = 12; Instance.new("UICorner", NewMsgBtn).CornerRadius = UDim.new(1, 0); Instance.new("UIStroke", NewMsgBtn).Color = borderDark

ChatBox = Instance.new("TextBox", ChatMain); ChatBox.Position = UDim2.new(0, 5, 1, -40); ChatBox.Size = UDim2.new(0.68, 0, 0, 35); ChatBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10); ChatBox.TextColor3 = tWhite; ChatBox.Text = ""; ChatBox.PlaceholderText = "Escribe un mensaje..."; ChatBox.Font = Enum.Font.Gotham; ChatBox.TextSize = 13; ChatBox.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", ChatBox).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", ChatBox).Color = Color3.fromRGB(40, 40, 40); Instance.new("UIPadding", ChatBox).PaddingLeft = UDim.new(0, 10)
ChatSendBtn = Instance.new("TextButton", ChatMain); ChatSendBtn.Position = UDim2.new(0.71, 0, 1, -40); ChatSendBtn.Size = UDim2.new(0.27, 0, 0, 35); ChatSendBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22); ChatSendBtn.TextColor3 = tGreen; ChatSendBtn.Text = "ENVIAR"; ChatSendBtn.Font = Enum.Font.GothamBold; ChatSendBtn.TextSize = 12; Instance.new("UICorner", ChatSendBtn).CornerRadius = UDim.new(0, 4)

MakeDraggable(ChatTopBar, ChatMain)

local chatMinimized = false
ChatMinBtn.MouseButton1Click:Connect(function()
    chatMinimized = not chatMinimized
    TweenService:Create(ChatMain, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = chatMinimized and UDim2.new(0, 380, 0, 35) or UDim2.new(0, 380, 0, 270)}):Play()
    ChatMinBtn.Text = chatMinimized and "+" or "—"; ChatFix.Visible = not chatMinimized
    ChatScroll.Visible = not chatMinimized 
    ChatBox.Visible = not chatMinimized
    ChatSendBtn.Visible = not chatMinimized
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
                    else 
                        if not chatMinimized then NewMsgBtn.Visible = true end
                    end
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

local charAddedConn
local inputBeganConn
local inputEndedConn

charAddedConn = LocalPlayer.CharacterAdded:Connect(function(character) 
    if isGhostActive then ToggleGhost() end
    if isFlying then ToggleFly() end
    if isNoclipActive then ToggleNoclipWalk() end
    if isReverseActive then frames = {} end
    isTripped = false

    if posicionGuardadaRE then
        task.spawn(function()
            local hrp = character:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                task.wait(0.1) 
                hrp.CFrame = posicionGuardadaRE
                posicionGuardadaRE = nil 
            end
        end)
    end
end)

inputBeganConn = UserInputService.InputBegan:Connect(function(input, gp)
    if isInvBinding and input.UserInputType == Enum.UserInputType.Keyboard then invKeybind = input.KeyCode; InvKeyBtn.Text = input.KeyCode.Name; InvKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isInvBinding = false; return end
    if isFlyBinding and input.UserInputType == Enum.UserInputType.Keyboard then flyKeybind = input.KeyCode; FlyKeyBtn.Text = input.KeyCode.Name; FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isFlyBinding = false; return end
    if isVFlyBinding and input.UserInputType == Enum.UserInputType.Keyboard then vFlyKeybind = input.KeyCode; VFlyKeyBtn.Text = input.KeyCode.Name; VFlyKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isVFlyBinding = false; return end
    if isNoclipBinding and input.UserInputType == Enum.UserInputType.Keyboard then noclipKeybind = input.KeyCode; NoclipKeyBtn.Text = input.KeyCode.Name; NoclipKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isNoclipBinding = false; return end
    if isTripBinding and input.UserInputType == Enum.UserInputType.Keyboard then tripKeybind = input.KeyCode; TripKeyBtn.Text = input.KeyCode.Name; TripKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isTripBinding = false; return end
    if isReverseBinding and input.UserInputType == Enum.UserInputType.Keyboard then reverseKeybind = input.KeyCode; ReverseKeyBtn.Text = input.KeyCode.Name; ReverseKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isReverseBinding = false; return end
    if isFcBinding and input.UserInputType == Enum.UserInputType.Keyboard then fcKeybind = input.KeyCode; FreecamKeyBtn.Text = input.KeyCode.Name; FreecamKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); isFcBinding = false; return end
    
    if not gp then
        if input.KeyCode == Enum.KeyCode.Insert then 
            if Main.Visible then
                Main.Visible = false; MPMain.Visible = false; TPMain.Visible = false; InvMain.Visible = false; FlyMain.Visible = false; VFlyMain.Visible = false; NoclipMain.Visible = false; TripMain.Visible = false; ChatMain.Visible = false; SetMain.Visible = false; HideMain.Visible = false; GenMain.Visible = false; ReverseMain.Visible = false
            else
                Main.Visible = true
            end
        end
        if invKeybind and input.KeyCode == invKeybind then ToggleGhost() end
        if flyKeybind and input.KeyCode == flyKeybind then ToggleFly() end
        if vFlyKeybind and input.KeyCode == vFlyKeybind then ToggleVFly() end
        if noclipKeybind and input.KeyCode == noclipKeybind then ToggleNoclipWalk() end
        if tripKeybind and input.KeyCode == tripKeybind then DoTrip() end
        if isTripped and input.KeyCode == Enum.KeyCode.Space then GetUpFromTrip() end
        if fcKeybind and input.KeyCode == fcKeybind then ToggleFreecam() end
        
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

inputEndedConn = UserInputService.InputEnded:Connect(function(input, gp)
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
AddCmd("chat", "Abre el chat global", function() ChatMain.Visible = true; ActualizarChat(); LogMessage("Chat Global conectado.", tGreen) end)
AddCmd("settings", "Abre el panel de Ajustes/Temas", function() SetMain.Visible = true; LogMessage("Menú de Ajustes abierto.", tOrange) end)
AddCmd("freecam", "Abre el panel de Cámara Libre", function() FreecamMain.Visible = true; LogMessage("Menú Freecam abierto.", tCyan) end)

-- [ACTUALIZADO] El comando abre el menú actual con muteo de Voice Chat
AddCmd("hide", "Abre el menú para ocultar avatares, sonidos locales y Voice Chat", function() 
    HideSearchBox.Text = ""; RefreshHideMenu(); HideMain.Visible = true; LogMessage("Menú Ocultar Jugadores abierto.", tPurple) 
end)

AddCmd("speed", "Cambia la velocidad", function(args)
    if args[1] and tonumber(args[1]) then LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(args[1]); LogMessage("Velocidad -> " .. args[1], tGreen) end
end)

AddCmd("vtag", "Oculta/Muestra tu propio Name Tag en tu pantalla", function()
    verMiTag = not verMiTag
    if verMiTag then
        LogMessage("Tu Name Tag ahora es VISIBLE para ti.", tGreen)
    else
        LogMessage("Tu Name Tag ahora está OCULTO para ti.", tOrange)
    end
end)

AddCmd("re", "Fuerza el respawn y te devuelve a tu posición actual", function()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if hrp and hum then
            posicionGuardadaRE = hrp.CFrame
            hum.Health = 0
            LogMessage("Reiniciando, no te muevas...", tYellow)
        else
            LogMessage("Error: No se encontró tu personaje.", tRed)
        end
    end
end)

-- INTEGRACIÓN DE INFINITE BASEPLATE COMO COMANDO
local infBaseActivo = false
AddCmd("infbase", "Genera baseplates infinitas alrededor de los jugadores", function()
    if infBaseActivo then
        LogMessage("Baseplate infinita ya está activa.", tYellow)
        return
    end
    
    local baseplateOriginal = workspace:FindFirstChild("Baseplate")
    if not baseplateOriginal then
        LogMessage("Error: No se encontró 'Baseplate' en el mapa.", tRed)
        return
    end
    
    infBaseActivo = true
    LogMessage("Iniciando sistema de Baseplate Infinita...", tGreen)
    
    task.spawn(function()
        local ORIGIN_POS = baseplateOriginal.Position
        local TILE_SIZE = 648
        local TILE_HEIGHT = 16

        local RENDER_DISTANCE = 2
        local DELETE_DISTANCE = 4
        local UPDATE_TICK = 0.0

        baseplateOriginal.Size = Vector3.new(TILE_SIZE, TILE_HEIGHT, TILE_SIZE)
        local plantilla = baseplateOriginal:Clone()
        baseplateOriginal:Destroy() 

        local activeChunks = {}
        local baseplateFolder = Instance.new("Folder", workspace)
        baseplateFolder.Name = "BaseplatesInfinitas"

        local function getChunkKey(x, z)
            return x .. "_" .. z
        end

        while scriptActivoTags and infBaseActivo do
            task.wait(UPDATE_TICK)
            local chunksNecesarios = {}
            local playerPositions = {}

            for _, player in ipairs(Players:GetPlayers()) do
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    table.insert(playerPositions, char.HumanoidRootPart.Position)
                end
            end

            for _, pos in ipairs(playerPositions) do
                local currentX = math.floor((pos.X - ORIGIN_POS.X + TILE_SIZE / 2) / TILE_SIZE)
                local currentZ = math.floor((pos.Z - ORIGIN_POS.Z + TILE_SIZE / 2) / TILE_SIZE)

                for x = -RENDER_DISTANCE, RENDER_DISTANCE do
                    for z = -RENDER_DISTANCE, RENDER_DISTANCE do
                        local key = getChunkKey(currentX + x, currentZ + z)
                        chunksNecesarios[key] = {X = currentX + x, Z = currentZ + z}
                    end
                end
            end

            for key, coords in pairs(chunksNecesarios) do
                if not activeChunks[key] then
                    local nueva = plantilla:Clone()
                    nueva.Name = "Chunk_" .. key
                    nueva.Position = Vector3.new(
                        ORIGIN_POS.X + (coords.X * TILE_SIZE),
                        ORIGIN_POS.Y,
                        ORIGIN_POS.Z + (coords.Z * TILE_SIZE)
                    )
                    nueva.Parent = baseplateFolder
                    activeChunks[key] = {Instance = nueva, X = coords.X, Z = coords.Z}
                end
            end

            for key, data in pairs(activeChunks) do
                local estaCerca = false
                for _, pos in ipairs(playerPositions) do
                    local currentX = math.floor((pos.X - ORIGIN_POS.X + TILE_SIZE / 2) / TILE_SIZE)
                    local currentZ = math.floor((pos.Z - ORIGIN_POS.Z + TILE_SIZE / 2) / TILE_SIZE)
                    
                    local dist = math.max(math.abs(data.X - currentX), math.abs(data.Z - currentZ))
                    
                    if dist <= DELETE_DISTANCE then
                        estaCerca = true
                        break
                    end
                end

                if not estaCerca then
                    data.Instance:Destroy()
                    activeChunks[key] = nil
                end
            end
        end
    end)
end)

-- INTEGRACIÓN DE COMANDO GENERACION C.D.T
AddCmd("generacion", "Abre el panel del Generador de Objetos", function()
    GenMain.Visible = true
    LogMessage("Generador C.D.T abierto.", tCyan)
end)


-- ==================================================================
-- DEFINICIÓN DE DESTRUCCIÓN TOTAL PARA EL COMANDO /DESTROY
-- ==================================================================
DestruirScriptCompleto = function()
    if isGhostActive then ToggleGhost() end
    if isFlying then ToggleFly() end
    if isVFlying then ToggleVFly() end
    if isNoclipActive then ToggleNoclipWalk() end
    if isReverseActive then ToggleReverse() end
    if isTripped then GetUpFromTrip() end
    
    if inputBeganConn then inputBeganConn:Disconnect() end
    if inputEndedConn then inputEndedConn:Disconnect() end
    if charAddedConn then charAddedConn:Disconnect() end

    task.spawn(function()
        pcall(function() 
            request({
                Url = BASE_URL .. "/api/offline/" .. tostring(LocalPlayer.UserId), 
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = "{}"
            }) 
        end)
    end)
    
    scriptActivoTags = false 
    infBaseActivo = false 
    for _, v in pairs(UIsActivos) do if v.UI then v.UI:Destroy() end end
    UIsActivos = {}
    
    -- [ACTUALIZADO] Restaurar Avatares y Voice Chat al destruir
    for idStr, isHidden in pairs(hiddenTags) do
        local p = Players:GetPlayerByUserId(tonumber(idStr))
        if p then
            if p.Character then OcultarAvatar(p.Character, false) end
            MutearVoiceChat(p, false) -- Asegurar desmuteo del Voice Chat
        end
    end
    hiddenTags = {}

    if targetGuiParent then
        for _, obj in ipairs(targetGuiParent:GetChildren()) do
            if string.sub(obj.Name, 1, 9) == "SafeHTML_" then 
                obj:Destroy() 
            end
        end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
            p.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
        end
    end
    
    if ScreenGui then ScreenGui:Destroy() end
    if KeyScreen then KeyScreen:Destroy() end
end

AddCmd("destroy", "Cierra y elimina el panel completo", function()
    LogMessage("Cerrando C.D.T Optifine...", tPurple)
    if DestruirScriptCompleto then DestruirScriptCompleto() end
end)

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

-- ==================================================================
-- SISTEMA DE KEY, RECORDATORIO (30 DÍAS) Y VERIFICACIÓN HWID
-- ==================================================================
Main.Visible = false 

local KeyScreen = Instance.new("ScreenGui", targetGuiParent)
KeyScreen.Name = "CDT_KeySystem"
KeyScreen.IgnoreGuiInset = true
KeyScreen.ResetOnSpawn = false 

local Background = Instance.new("Frame", KeyScreen)
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Background.BackgroundTransparency = 0.2

local KeyBox = Instance.new("Frame", Background)
KeyBox.Size = UDim2.new(0, 320, 0, 260)
KeyBox.Position = UDim2.new(0.5, -160, 0.5, -130)
KeyBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
KeyBox.ClipsDescendants = true
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 6)
local KeyStroke = Instance.new("UIStroke", KeyBox)
KeyStroke.Color = borderDark
KeyStroke.Thickness = 1.2

local TopKeyBar = Instance.new("Frame", KeyBox)
TopKeyBar.Size = UDim2.new(1, 0, 0, 35)
TopKeyBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Instance.new("UICorner", TopKeyBar).CornerRadius = UDim.new(0, 6)
local KeyFix = Instance.new("Frame", TopKeyBar)
KeyFix.Size = UDim2.new(1, 0, 0, 5)
KeyFix.Position = UDim2.new(0, 0, 1, -5)
KeyFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
local KeyTopTitle = Instance.new("TextLabel", TopKeyBar)
KeyTopTitle.Size = UDim2.new(1, -30, 1, 0)
KeyTopTitle.Position = UDim2.new(0, 15, 0, 0)
KeyTopTitle.BackgroundTransparency = 1
KeyTopTitle.Text = "C.D.T OPTIFINE // AUTHENTICATION"
KeyTopTitle.TextColor3 = tWhite
KeyTopTitle.Font = Enum.Font.GothamBold
KeyTopTitle.TextSize = 12
KeyTopTitle.TextXAlignment = Enum.TextXAlignment.Left

local WelcomeTitle = Instance.new("TextLabel", KeyBox)
WelcomeTitle.Size = UDim2.new(1, 0, 0, 40)
WelcomeTitle.Position = UDim2.new(0, 0, 0, 45)
WelcomeTitle.BackgroundTransparency = 1
WelcomeTitle.Text = "BIENVENIDO, " .. string.upper(LocalPlayer.Name)
WelcomeTitle.TextColor3 = tWhite
WelcomeTitle.Font = Enum.Font.GothamBold
WelcomeTitle.TextSize = 16

local SubTitle = Instance.new("TextLabel", KeyBox)
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 75)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Verificando conexión segura..."
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.TextSize = 12

local KeyInputBox = Instance.new("TextBox", KeyBox)
KeyInputBox.Size = UDim2.new(1, -40, 0, 40)
KeyInputBox.Position = UDim2.new(0, 20, 0, 110)
KeyInputBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
KeyInputBox.TextColor3 = tWhite
KeyInputBox.PlaceholderText = "> Ingresa tu key aquí..."
KeyInputBox.Font = Enum.Font.Gotham
KeyInputBox.TextSize = 13
KeyInputBox.Text = ""
KeyInputBox.Visible = false
Instance.new("UICorner", KeyInputBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", KeyInputBox).Color = Color3.fromRGB(40, 40, 40)

local RememberCheck = Instance.new("TextButton", KeyBox)
RememberCheck.Size = UDim2.new(1, -40, 0, 20)
RememberCheck.Position = UDim2.new(0, 20, 0, 160)
RememberCheck.BackgroundTransparency = 1
RememberCheck.Text = "☐ Recordar Key (30 días)"
RememberCheck.TextColor3 = tWhite
RememberCheck.Font = Enum.Font.Gotham
RememberCheck.TextSize = 12
RememberCheck.TextXAlignment = Enum.TextXAlignment.Left
RememberCheck.Visible = false
local isRemembered = false

RememberCheck.MouseButton1Click:Connect(function()
    isRemembered = not isRemembered
    RememberCheck.Text = isRemembered and "☑ Recordar Key (30 días)" or "☐ Recordar Key (30 días)"
    RememberCheck.TextColor3 = isRemembered and tGreen or tWhite
end)

local VerifyBtn = Instance.new("TextButton", KeyBox)
VerifyBtn.Size = UDim2.new(0.45, 0, 0, 35)
VerifyBtn.Position = UDim2.new(0, 20, 0, 195)
VerifyBtn.BackgroundColor3 = tGreen
VerifyBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
VerifyBtn.Text = "VERIFICAR"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 12
VerifyBtn.Visible = false
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 4)

local GetKeyBtn = Instance.new("TextButton", KeyBox)
GetKeyBtn.Size = UDim2.new(0.45, 0, 0, 35)
GetKeyBtn.Position = UDim2.new(0.55, -20, 0, 195)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
GetKeyBtn.TextColor3 = tWhite
GetKeyBtn.Text = "OBTENER KEY"
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 12
GetKeyBtn.Visible = false
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 4)

MakeDraggable(TopKeyBar, KeyBox)

local function SaveKeyLocal(key)
    if writefile then
        local data = HttpService:JSONEncode({savedKey = key, timestamp = tick()})
        pcall(function() writefile(AuthFileName, data) end)
    end
end

local function ProcessKey(inputKey, isAutoLogin)
    SubTitle.Text = isAutoLogin and "Comprobando llave recordada..." or "Comprobando..."
    SubTitle.TextColor3 = tYellow
    
    local hwid = RbxAnalytics:GetClientId()
    local reqAPI = BASE_URL .. "/api/verify"

    task.spawn(function()
        local success, res = pcall(function()
            return request({
                Url = reqAPI,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({key = inputKey, hwid = hwid})
            })
        end)

        if success and res and res.StatusCode == 200 then
            local decoded = HttpService:JSONDecode(res.Body)
            if decoded.success then
                if isRemembered and not isAutoLogin then SaveKeyLocal(inputKey) end
                SubTitle.Text = "¡Acceso Autorizado!"
                SubTitle.TextColor3 = tGreen
                
                CurrentExpirationText = decoded.expiresText or "Desconocido"
                ExpLabel.Text = CurrentExpirationText
                if string.find(CurrentExpirationText, "Expira") then ExpLabel.TextColor3 = tOrange else ExpLabel.TextColor3 = tCyan end
                
                task.wait(1)
                if KeyScreen then KeyScreen:Destroy() end
                Main.Visible = true
                LogMessage("Sistema desbloqueado correctamente.", tGreen)
            else
                if isAutoLogin then
                    if isfile and isfile(AuthFileName) then pcall(function() delfile(AuthFileName) end) end
                    SubTitle.Text = "La llave guardada expiró o fue baneada."
                    SubTitle.TextColor3 = tRed
                    task.wait(1.5)
                    SubTitle.Text = "Por favor, introduce tu Key de acceso."
                    KeyInputBox.Visible = true; VerifyBtn.Visible = true; GetKeyBtn.Visible = true; RememberCheck.Visible = true
                else
                    SubTitle.Text = decoded.msg or "Key Inválida o Baneada."
                    SubTitle.TextColor3 = tRed
                end
            end
        else
            SubTitle.Text = "Error al conectar con el servidor."
            SubTitle.TextColor3 = tRed
            if isAutoLogin then
                task.wait(2)
                KeyInputBox.Visible = true; VerifyBtn.Visible = true; GetKeyBtn.Visible = true; RememberCheck.Visible = true
            end
        end
    end)
end

task.spawn(function()
    local autoKey = nil
    if readfile and isfile and isfile(AuthFileName) then
        local success, dat = pcall(function() return HttpService:JSONDecode(readfile(AuthFileName)) end)
        if success and dat and dat.savedKey then
            autoKey = dat.savedKey
        end
    end

    if autoKey then
        task.wait(1)
        ProcessKey(autoKey, true)
    else
        task.wait(1.5)
        SubTitle.Text = "Por favor, introduce tu Key de acceso."
        KeyInputBox.Visible = true; VerifyBtn.Visible = true; GetKeyBtn.Visible = true; RememberCheck.Visible = true
    end
end)

VerifyBtn.MouseButton1Click:Connect(function()
    if KeyInputBox.Text == "" then SubTitle.Text = "No puedes dejar el campo vacío."; SubTitle.TextColor3 = tRed return end
    ProcessKey(KeyInputBox.Text, false)
end)

GetKeyBtn.MouseButton1Click:Connect(function()
    local link = "https://discord.gg/6qG75JtTsX"
    if isMobile then
        if setclipboard then
            setclipboard(link)
            SubTitle.Text = "¡Link copiado al portapapeles!"
            SubTitle.TextColor3 = tYellow
        end
    else
        local success = pcall(function() if open_url then open_url(link) else setclipboard(link) end end)
        if success then
            SubTitle.Text = "Link abierto / copiado. Entra al Discord."
            SubTitle.TextColor3 = tYellow
        else
            SubTitle.Text = "Error al copiar el link. Únete manual."
            SubTitle.TextColor3 = tRed
        end
    end
end)
