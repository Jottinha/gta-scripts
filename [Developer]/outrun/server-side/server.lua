-- Registra o comando /outrun
RegisterCommand("outrun", function(source, args, rawCommand)
    -- Obtenha todos os jogadores conectados ao servidor
    local players = GetPlayers()

    -- Coordenadas para onde os jogadores serão teletransportados (X, Y, Z)
    local baseCoords = vector3(-2309.0541992188, 449.82046508789, 173.66809082031)
    -- local teleportCoords = vector3(-2307.2609863281, 444.1174621582, 174.46662902832) -- Ajuste conforme necessário
    
    -- Distância entre cada jogador
    local offset = 5.0 -- Distância de 5 unidades entre cada jogador
    -- Para cada jogador conectado no servidor
    for index, playerId in ipairs(players) do
        -- Calcula a posição de cada jogador com base no índice e no deslocamento
        local teleportCoords = vector3(baseCoords.x, baseCoords.y - (index * offset), baseCoords.z)

        -- Envia um evento para o cliente para que ele verifique se está dentro de um veículo e faça o teleporte e ajuste de heading
        TriggerClientEvent("outrun:teleportAndFreeze", playerId, teleportCoords)
    end

    -- Inicia o timer de contagem regressiva no servidor
    StartCountdown(10)
end, false) -- O último parâmetro define se o comando requer privilégios administrativos. False significa que qualquer um pode usar.

-- Função para iniciar a contagem regressiva no servidor
function StartCountdown(seconds)
    -- Cria uma thread para a contagem regressiva
    Citizen.CreateThread(function()
        local timeLeft = seconds

        -- Envia a contagem regressiva para todos os jogadores
        while timeLeft > 0 do
            TriggerClientEvent("outrun:showCountdown", -1, timeLeft) -- Envia a contagem regressiva para todos os jogadores
            Citizen.Wait(1000) -- Espera 1 segundo
            timeLeft = timeLeft - 1
        end

        -- Quando a contagem regressiva terminar, libera os veículos e inicia a corrida
        TriggerClientEvent("outrun:startRace", -1) -- Envia evento para liberar os veículos e começar a corrida
    end)
end
