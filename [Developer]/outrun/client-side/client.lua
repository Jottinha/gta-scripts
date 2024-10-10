local npcPed = nil

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

        --TODO: Chamar método que vai gerenciar a corrida
        TriggerServerEvent("outrun:outrunRulesNpc")
    end
end)

-- Função auxiliar para exibir notificações
function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    DrawNotification(false, true)
end


local npcPed = nil -- Variável para armazenar o NPC criado no cliente

-- Evento para criar o NPC
RegisterNetEvent("outrun:spawnNPC")
AddEventHandler("outrun:spawnNPC", function()
    -- Defina o modelo do veículo NPC
    local npcVehicleModel = GetHashKey("sultanrs")

    -- Carrega o modelo do veículo
    RequestModel(npcVehicleModel)
    while not HasModelLoaded(npcVehicleModel) do
        Citizen.Wait(0)
    end

    -- Coordenadas para spawnar o NPC (ajuste conforme necessário)
    local spawnCoords = vector3(-2309.0541992188, 449.82046508789, 173.66809082031)
    local spawnHeading = 0.0 -- Direção do veículo

    -- Cria o veículo NPC
    local npcVehicle = CreateVehicle(npcVehicleModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnHeading, true, false)

    -- Define o veículo como uma entidade de missão para evitar que desapareça
    SetEntityAsMissionEntity(npcVehicle, true, true)

    -- Cria um ped dentro do veículo NPC
    local npcPedModel = GetHashKey("a_m_y_business_01")
    RequestModel(npcPedModel)
    while not HasModelLoaded(npcPedModel) do
        Citizen.Wait(0)
    end

    npcPed = CreatePedInsideVehicle(npcVehicle, 4, npcPedModel, -1, true, false)

    -- Configurações adicionais para o ped NPC
    SetEntityInvincible(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)

    -- Trava o veículo NPC para que ele fique parado
    FreezeEntityPosition(npcVehicle, true)

    -- Notifica o jogador que o NPC foi spawnado
    ShowNotification("NPC spawnado e pronto.")
end)

-- Cliente responde ao servidor com as coordenadas do NPC
RegisterNetEvent("outrun:requestNPCCoords")
AddEventHandler("outrun:requestNPCCoords", function()
    if npcPed ~= nil then
        -- Obtém as coordenadas do NPC
        local npcCoords = GetEntityCoords(npcPed)
        
        -- Envia as coordenadas de volta ao servidor
        TriggerServerEvent("outrun:receiveNPCCoords", npcCoords.x, npcCoords.y, npcCoords.z)
    else
        -- Caso o NPC não esteja disponível, envia uma mensagem ao servidor
        TriggerServerEvent("outrun:receiveNPCCoords", nil, nil, nil)
    end
end)

-- Cliente responde ao servidor com as coordenadas do jogador
RegisterNetEvent("outrun:requestPlayerCoords")
AddEventHandler("outrun:requestPlayerCoords", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Envia as coordenadas do jogador de volta ao servidor
    TriggerServerEvent("outrun:receivePlayerCoords", playerCoords.x, playerCoords.y, playerCoords.z)
end)

-- Cliente responde ao servidor com a rotação do jogador
RegisterNetEvent("outrun:requestPlayerRotation")
AddEventHandler("outrun:requestPlayerRotation", function()
    -- Obtém o Ped do jogador local
    local playerPed = PlayerPedId()
    -- Obtém a rotação do jogador no eixo Z (Yaw)
    local playerRotation = GetEntityRotation(playerPed, 2).z
    -- Envia a rotação do jogador de volta ao servidor
    TriggerServerEvent("outrun:receivePlayerRotation", playerRotation)
end)

-- Cliente responde ao servidor com a rotação do NPC
RegisterNetEvent("outrun:requestNPCrotation")
AddEventHandler("outrun:requestNPCrotation", function()
    if npcPed ~= nil then
        -- Obtém a rotação do NPC no eixo Z (Yaw)
        local npcRotation = GetEntityRotation(npcPed, 2).z
        -- Envia a rotação do NPC de volta ao servidor
        TriggerServerEvent("outrun:receiveNPCRotation", npcRotation)
    else
        -- Caso o NPC não esteja disponível, envia nil ao servidor
        TriggerServerEvent("outrun:receiveNPCRotation", nil)
    end
end)

-- Evento para indicar que o NPC está liderando
RegisterNetEvent("outrun:npcLeader")
AddEventHandler("outrun:npcLeader", function()
    -- Aqui você pode exibir uma mensagem ou tomar alguma ação quando o NPC está na liderança
    ShowTextOnScreen("Você perdeu a liderança!", 5000)
end)

-- Evento para indicar que o jogador está liderando
RegisterNetEvent("outrun:playerLeader")
AddEventHandler("outrun:playerLeader", function()
    -- Aqui você pode exibir uma mensagem ou tomar alguma ação quando o jogador está na liderança
    ShowTextOnScreen("Você é o líder da corrida!")
end)

function ShowTextOnScreen(text)
     -- Inicia um thread para exibir o texto
     Citizen.CreateThread(function()
        -- Tempo para exibir a mensagem
        local displayTime = 1200 -- 1.2 segundos
        local endTime = GetGameTimer() + displayTime
        
        while GetGameTimer() < endTime do
            -- Configura o texto
            SetTextFont(4) -- Fonte do texto (4 = fonte de "WASTED")
            SetTextScale(1.0, 2.0) -- Escala do texto (ajuste conforme necessário)
            SetTextColour(255, 0, 0, 255) -- Cor do texto (vermelho)
            SetTextDropShadow()
            SetTextOutline()
            SetTextCentre(true) -- Centraliza o texto

            -- Adiciona o texto à tela
            SetTextEntry("STRING")
            AddTextComponentString(text)
            DrawText(0.5, 0.4) -- Coordenadas (0.5, 0.4) para o centro alto da tela

            -- Aguarda para manter o texto visível
            Citizen.Wait(0)
        end

        -- Após o tempo, você pode limpar ou substituir o texto se necessário
        ClearPrints() -- Limpa qualquer mensagem anterior, se necessário
    end)
end


















-----------------------------------------------

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



