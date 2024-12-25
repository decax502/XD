local key = "clave123"  -- Clave de acceso

return function(userKey)
    if userKey == key then
        print("Clave correcta. Activando exploit...")
        
        -- Cambiar velocidad
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 200
        
        -- ESP (resaltar jugadores)
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player ~= game.Players.LocalPlayer then
                local highlight = Instance.new("Highlight", player.Character)
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.FillTransparency = 0.5
            end
        end
    else
        print("Clave incorrecta.")
    end
end
