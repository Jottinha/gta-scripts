-- Evento para teletransportar e congelar o veículo do jogador
RegisterNetEvent("outrun:teleportAndFreeze")
AddEventHandler("outrun:teleportAndFreeze", function(teleportCoords)
    -- Obtém o ped do jogador
    local ped = PlayerPedId()

    -- Verifica se o jogador está dentro de um veículo usando IsPedInVehicle
    if IsPedInAnyVehicle(ped, false) then
        -- Obtém o veículo do jogador
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        -- Teletransporta o veículo e o jogador para as coordenadas especificadas
        SetEntityCoords(vehicle, teleportCoords.x, teleportCoords.y, teleportCoords.z, false, false, false, true)
        SetEntityHeading(vehicle, 360)
        -- Trava o veículo para impedir que o jogador se mova
        FreezeEntityPosition(vehicle, true)
        
        -- Notifica o jogador
        ShowNotification("Você foi teleportado para a linha de partida! A corrida começará em breve.")
    else
        -- Notifica o jogador caso ele não esteja em um veículo
        ShowNotification("Você precisa estar em um veículo para participar da corrida.")
    end
end)

-- Evento para exibir a contagem regressiva na tela
RegisterNetEvent("outrun:showCountdown")
AddEventHandler("outrun:showCountdown", function(timeLeft)
    -- Mostra a contagem regressiva padrão do GTA V (no canto inferior direito)
    BeginTextCommandPrint("STRING")
    AddTextComponentSubstringPlayerName("Corrida começa em: " .. tostring(timeLeft))
    EndTextCommandPrint(1000, 1)
end)

-- Evento para liberar os veículos e começar a corrida
RegisterNetEvent("outrun:startRace")
AddEventHandler("outrun:startRace", function()
    -- Obtém o ped do jogador
    local ped = PlayerPedId()
    
    -- Verifica se o jogador está dentro de um veículo
    if IsPedInAnyVehicle(ped, false) then
        -- Obtém o veículo do jogador
        local vehicle = GetVehiclePedIsIn(ped, false)

        -- Destrava o veículo
        FreezeEntityPosition(vehicle, false)

        -- Notifica o jogador que a corrida começou
        ShowNotification("A corrida começou! Boa sorte!")

        --TODO: Chamar meotodo que vai gerenciar a corrida
    end
end)

-- Função auxiliar para exibir notificações
function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    DrawNotification(false, true)
end

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


-- Variável para rastrear o estado do no-clip
local noclip = false
local noclipSpeed = 1.0 -- Velocidade inicial do no-clip

-- Função para alternar o no-clip
function toggleNoClipMode()
    local ped = PlayerPedId() -- Obtém o ped do jogador
    noclip = not noclip -- Alterna o estado do no-clip

    if noclip then
        -- Se o no-clip for ativado, desativa a colisão do jogador
        SetEntityInvincible(ped, true) -- Torna o jogador invencível
        SetEntityVisible(ped, false, false) -- Torna o jogador invisível
        TriggerEvent('chat:addMessage', { args = { '^2No-clip ativado!' } })
    else
        -- Se o no-clip for desativado, ativa a colisão e visibilidade do jogador
        SetEntityInvincible(ped, false)
        SetEntityVisible(ped, true, false)
        TriggerEvent('chat:addMessage', { args = { '^1No-clip desativado!' } })
    end
end

-- Registro do comando /noclip
RegisterCommand("noclip", function()
    toggleNoClipMode()
end, false)

-- Thread para controlar o movimento no no-clip
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if noclip then
            local ped = PlayerPedId()
            local x, y, z = table.unpack(GetEntityCoords(ped, true))
            local dx, dy, dz = getCamDirection()
            
            -- Controla a velocidade do movimento
            SetEntityVelocity(ped, 0.01, 0.01, 0.01) -- Remove a velocidade anterior
            if IsControlPressed(0, 32) then -- W (Move para frente)
                x = x + noclipSpeed * dx
                y = y + noclipSpeed * dy
                z = z + noclipSpeed * dz
            end

            if IsControlPressed(0, 269) then -- S (Move para trás)
                x = x - noclipSpeed * dx
                y = y - noclipSpeed * dy
                z = z - noclipSpeed * dz
            end

            if IsControlPressed(0, 44) then -- Q (Desce)
                z = z - noclipSpeed
            end

            if IsControlPressed(0, 20) then -- Z (Sobe)
                z = z + noclipSpeed
            end

            -- Ajusta a posição do jogador com as coordenadas calculadas
            SetEntityCoordsNoOffset(ped, x, y, z, true, true, true)
        end
    end
end)

-- Função auxiliar para obter a direção da câmera
function getCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()

    local x = -math.sin(heading * math.pi / 180.0)
    local y = math.cos(heading * math.pi / 180.0)
    local z = math.sin(pitch * math.pi / 180.0)

    local len = math.sqrt(x * x + y * y + z * z)
    if len ~= 0 then
        x = x / len
        y = y / len
        z = z / len
    end

    return x, y, z
end

