
-- Registra o comando /coords para obter as coordenadas do jogador
RegisterCommand("coords", function()
    -- Obtém o ped do jogador
    local ped = PlayerPedId()

    -- Obtém as coordenadas do jogador
    local playerCoords = GetEntityCoords(ped)
    
    -- Exibe as coordenadas no chat do cliente
    local x, y, z = table.unpack(playerCoords)
    TriggerEvent('chat:addMessage', {
        args = { "Suas coordenadas atuais são: X: " .. x .. " | Y: " .. y .. " | Z: " .. z }
    })

    -- Também imprime as coordenadas no console do cliente (F8)
    print("Suas coordenadas atuais são: X: " .. x .. " | Y: " .. y .. " | Z: " .. z)
end, false) -- Define que qualquer jogador pode executar este comando