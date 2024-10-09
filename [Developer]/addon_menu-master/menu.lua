-- Inicialização do Menu Pool e do Menu Principal
_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("Vehicle Menu", "~r~Antisocial Network Custom Vehicles")
_menuPool:Add(mainMenu)
_menuPool:MouseControlsEnabled(false)
_menuPool:MouseEdgeEnabled(false)
_menuPool:ControlDisablingEnabled(false)

-- Função para exibir notificações na tela
function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, true)
end

-- Função para spawnar veículos
function spawnCar(model)
    local modelHash = GetHashKey(model)

    -- Solicita o modelo do veículo
    RequestModel(modelHash)
    local attempts = 0
    local maxAttempts = 100 -- Limite de tentativas para carregar o modelo

    -- Aguarda o carregamento do modelo com um limite de tentativas
    while not HasModelLoaded(modelHash) and attempts < maxAttempts do
        Citizen.Wait(50)
        attempts = attempts + 1
    end

    -- Verifica se o modelo foi carregado
    if not HasModelLoaded(modelHash) then
        notify("~r~Erro: Modelo de veículo não encontrado!")
        print("Erro: Modelo de veículo não encontrado! Modelo: " .. model)
        return
    end

    -- Obtém as coordenadas e a direção do jogador
    local playerPed = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(playerPed, false))
    local heading = GetEntityHeading(playerPed)

    -- Cria o veículo próximo ao jogador
    local vehicle = CreateVehicle(modelHash, x + 2, y + 2, z + 1, heading, true, false)
    
    -- Verifica se o veículo foi criado com sucesso
    if DoesEntityExist(vehicle) then
        SetPedIntoVehicle(playerPed, vehicle, -1) -- Coloca o jogador no banco do motorista
        SetEntityAsNoLongerNeeded(vehicle)         -- Marca o veículo como não necessário
        SetModelAsNoLongerNeeded(modelHash)        -- Marca o modelo como não necessário
        notify("~g~Veículo Spawnado: " .. model)
    else
        notify("~r~Erro: Não foi possível spawnar o veículo!")
        print("Erro: Não foi possível spawnar o veículo! Modelo: " .. model)
    end
end

-- Função para adicionar veículos a um submenu
function AddVehiclesToSubMenu(submenu, vehicleList)
    for _, vehicle in ipairs(vehicleList) do
        local vehicleItem = NativeUI.CreateItem(vehicle.name, vehicle.description or vehicle.name)
        submenu:AddItem(vehicleItem)
        vehicleItem.Activated = function(sender, item)
            if item == vehicleItem then
                spawnCar(vehicle.model)
                _menuPool:CloseAllMenus() -- Fecha o menu após spawnar o veículo
            end
        end
    end
end

-- Função para adicionar o submenu "Trucks"
function AddSportsSubMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, "Sports")
    
    -- Lista de veículos no submenu "Trucks"
    local sportsVehicles = {
        { name = "Coquette D10", model = "coquette4" },
        { name = "Flash GT", model = "flashgt" },
        { name = "Sugoi", model = "sugoi" },
        { name = "Sultan Classic", model = "sultan2" } -- Certifique-se de que este modelo existe
    }

    AddVehiclesToSubMenu(submenu, sportsVehicles)
end

-- Função para adicionar o submenu "SUVs"
function AddSuvsSubMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, "SUVs")
    
    -- Lista de veículos no submenu "SUVs"
    local suvVehicles = {
        { name = "Toros", model = "toros" },
        { name = "XLS", model = "xls" } -- Certifique-se de que este modelo existe
    }

    AddVehiclesToSubMenu(submenu, suvVehicles)
end

-- Adiciona os submenus ao menu principal
AddSportsSubMenu(mainMenu)
AddSuvsSubMenu(mainMenu)

-- Atualiza o Menu Pool
_menuPool:RefreshIndex()

-- Thread para processar os menus e detectar a tecla de ativação
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
        
        -- A tecla "E" (control 38) irá ativar o menu
        if IsControlJustPressed(1, 38) then -- 38 corresponde à tecla "E"
            mainMenu:Visible(not mainMenu:Visible())
        end
    end
end)
