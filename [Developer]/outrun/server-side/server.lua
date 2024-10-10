-- Variáveis para armazenar rotações e coordenadas
local playerRotation = nil
local npcRotation = nil
local liderAtual = nil

-- Registra o comando /outrun
RegisterCommand("outrun", function(source, args, rawCommand)
    local players = GetPlayers()
    local playerCount = #players

    -- Verifica se apenas você está online
    if playerCount == 1 then
        -- Dispara um evento para o cliente que executou o comando para spawnar o NPC
        TriggerClientEvent("outrun:spawnNPC", source)
    else
        -- Notifica o jogador que o NPC não será spawnado devido a múltiplos jogadores
        TriggerClientEvent("chat:addMessage", source, {
            args = { "^1NPC não spawnado: Existem outros jogadores online." }
        })
    end

    local baseCoords = vector3(-2309.054, 449.820, 173.668)
    local offset = 5.0 -- Distância de 5 unidades entre cada jogador

    -- Teletransporta cada jogador para a posição determinada
    for index, playerId in ipairs(players) do
        local teleportCoords = vector3(baseCoords.x, baseCoords.y - (index * offset), baseCoords.z)
        TriggerClientEvent("outrun:teleportAndFreeze", playerId, teleportCoords)
    end

    -- Inicia o timer de contagem regressiva no servidor
    StartCountdown(5)
end, false)

-- Função para iniciar a contagem regressiva
function StartCountdown(seconds)
    Citizen.CreateThread(function()
        local timeLeft = seconds

        while timeLeft > 0 do
            TriggerClientEvent("outrun:showCountdown", -1, timeLeft)
            Citizen.Wait(1000)
            timeLeft = timeLeft - 1
        end

        -- Quando a contagem regressiva terminar, libera os veículos e inicia a corrida
        TriggerClientEvent("outrun:startRace", -1)
    end)
end

RegisterNetEvent("outrun:outrunRulesNpc")
AddEventHandler("outrun:outrunRulesNpc", function()
    Citizen.CreateThread(function()
        while true do
            local cordenadaNpc = getNpcCords()

            if cordenadaNpc then
                VerificaUltrapassagemNpcMode(cordenadaNpc, source)
            else
                print("Erro ao obter as coordenadas do NPC.")
            end

            Citizen.Wait(1000) -- Aguarda 1 segundo antes de verificar novamente
        end

        TriggerClientEvent("outrun:raceStopped", source)
    end)
end)

-- Função que verifica ultrapassagem
function VerificaUltrapassagemNpcMode(cordenadaNpc, source)
    local playerCoords = GetSynglePlayersCords(source)

    local playerRotation = getPlayerRotationSync(source)
    local npcRotation = getNpcRotationSync(source)

    local toleranciaDirecao = 45.0 -- Tolerância de 15 graus para considerar a mesma direção
    local distanciaMinimaX = 20.0 -- 3 carros (~3 metros cada)

    -- Verifica se a diferença de rotação é aceitável para considerar a mesma direção
    local diferencaRotacao = math.abs(playerRotation - npcRotation)

    -- Verifica se a diferença de espaço é aceitável para considerar ultrapassagem
    local distanciaX = math.abs(playerCoords.x - cordenadaNpc.x)
    local mesmaDirecao = diferencaRotacao <= toleranciaDirecao

    local novoLider

    if cordenadaNpc.y > playerCoords.y and distanciaX <= distanciaMinimaX and mesmaDirecao then
        novoLider = "npc"
    else
        novoLider = source
    end

    if novoLider ~= liderAtual then
        -- Se o líder mudou, atualiza a variável `liderAtual`
        liderAtual = novoLider
        print("Mudança de liderança detectada!")

        -- Dispara eventos para os clientes com base no novo líder
        if novoLider == "npc" then
            TriggerClientEvent("outrun:npcLeader", -1) -- Envia para todos os clientes que o NPC é o líder
        else
            TriggerClientEvent("outrun:playerLeader", novoLider) -- Envia apenas para o cliente do jogador líder
        end
    end

end

-- Função para obter rotação do jogador de maneira síncrona (Promise-style)
function getPlayerRotationSync(source)
    local p = promise.new()

    -- Solicita a rotação do jogador ao cliente
    TriggerClientEvent("outrun:requestPlayerRotation", source)

    -- Evento para receber a rotação do jogador enviada pelo cliente
    RegisterNetEvent("outrun:receivePlayerRotation")
    AddEventHandler("outrun:receivePlayerRotation", function(rotation)
        playerRotation = rotation
        p:resolve(rotation)
    end)

    -- Aguarda a resposta e retorna a rotação recebida
    return Citizen.Await(p)
end

-- Função para obter rotação do NPC de maneira síncrona (Promise-style)
function getNpcRotationSync(source)
    local p = promise.new()

    -- Solicita a rotação do NPC ao cliente
    TriggerClientEvent("outrun:requestNPCrotation", source)

    -- Evento para receber a rotação do NPC enviada pelo cliente
    RegisterNetEvent("outrun:receiveNPCRotation")
    AddEventHandler("outrun:receiveNPCRotation", function(rotation)
        npcRotation = rotation
        p:resolve(rotation)
    end)

    -- Aguarda a resposta e retorna a rotação recebida
    return Citizen.Await(p)
end

-- Função para obter as coordenadas do jogador
function GetSynglePlayersCords(source)
    local p = promise.new()

    -- Envia um evento ao cliente para solicitar as coordenadas do jogador
    TriggerClientEvent("outrun:requestPlayerCoords", source)

    -- Evento para receber as coordenadas do jogador enviadas pelo cliente
    RegisterNetEvent("outrun:receivePlayerCoords")
    AddEventHandler("outrun:receivePlayerCoords", function(x, y, z)
        if x and y and z then
            p:resolve({x = x, y = y, z = z})
        else
            print("Erro ao receber as coordenadas do Player.")
            p:resolve(nil)
        end
    end)

    -- Aguarda a resposta e retorna as coordenadas recebidas
    return Citizen.Await(p)
end

-- Função para obter as coordenadas do NPC
function getNpcCords()
    local p = promise.new()

    -- Envia um evento ao cliente para solicitar as coordenadas do NPC
    TriggerClientEvent("outrun:requestNPCCoords", -1)

    -- Evento para receber as coordenadas do NPC enviadas pelo cliente
    RegisterNetEvent("outrun:receiveNPCCoords")
    AddEventHandler("outrun:receiveNPCCoords", function(x, y, z)
        if x and y and z then
            p:resolve({x = x, y = y, z = z})
        else
            print("Erro ao receber as coordenadas do NPC.")
            p:resolve(nil)
        end
    end)

    -- Aguarda a resposta e retorna as coordenadas recebidas
    return Citizen.Await(p)
end
