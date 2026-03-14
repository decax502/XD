local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CoreguiM = game:GetService("CoreGui")
local plr = Players.LocalPlayer

local invisOn = false

-- Sistema de notificaciones simplificado
local function showNotice(txt)
    pcall(function()
        if CoreguiM:FindFirstChild("InvisGhostNotice") then
            CoreguiM.InvisGhostNotice:Destroy()
        end
    end)
    local g = Instance.new("ScreenGui", CoreguiM)
    g.Name = "InvisGhostNotice"
    g.ResetOnSpawn = false
    local lbl = Instance.new("TextLabel", g)
    lbl.Size = UDim2.new(0, 300, 0, 40)
    lbl.Position = UDim2.new(0.5, -150, 0, 20)
    lbl.BackgroundTransparency = 0.15
    lbl.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Text = txt
    lbl.TextSize = 18
    lbl.Font = Enum.Font.SourceSansSemibold
    lbl.ZIndex = 9999
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 8)
    
    task.spawn(function()
        task.wait(2)
        pcall(function() g:Destroy() end)
    end)
end

local function setTransparency(char, val)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.Transparency = val
        end
    end
end

local function toggleInvis()
    invisOn = not invisOn
    local char = plr.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        if invisOn then
            setTransparency(char, 0.5)
            local savedpos = char.HumanoidRootPart.CFrame
            task.wait()
            char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
            task.wait(0.15)
            
            local Seat = Instance.new("Seat", workspace)
            Seat.Anchored = false
            Seat.CanCollide = false
            Seat.Name = "invischair"
            Seat.Transparency = 1
            Seat.Position = Vector3.new(-25.95, 84, 3537.55)
            
            local Weld = Instance.new("Weld", Seat)
            Weld.Part0 = Seat
            Weld.Part1 = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            Seat.CFrame = savedpos
            
            showNotice("Invisibility Enabled")
        else
            setTransparency(char, 0)
            if workspace:FindFirstChild("invischair") then
                workspace.invischair:Destroy()
            end
            showNotice("Invisibility Disabled")
        end
    end
end

-- Atajo de teclado para la letra Z
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end -- Ignora si el jugador está escribiendo en el chat
    if input.KeyCode == Enum.KeyCode.Z then
        toggleInvis()
    end
end)
