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

-- Função para adicionar o submenu "Audi"
function AddAudiSubMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, "Audi")
    
    -- Lista de veículos da marca Audi
    local audiVehicles = {
        { name = "Audi-Rs", model = "rsq8mans" }
    }

    AddVehiclesToSubMenu(submenu, audiVehicles)
end

-- Função para adicionar o submenu "Chevrolet"
function AddChevroletSubMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, "Chevrolet")
    
    -- Lista de veículos da marca Chevrolet
    local chevroletVehicles = {
        { name = "Corvette", model = "corvetteZR1" }
    }

    AddVehiclesToSubMenu(submenu, chevroletVehicles)
end

-- Função para adicionar o submenu "Dodge"
function AddDodgeSubMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, "Dodge")
    
    -- Lista de veículos da marca Dodge
    local dodgeVehicles = {
        { name = "Dodge-Charge", model = "16charger" }
    }

    AddVehiclesToSubMenu(submenu, dodgeVehicles)
end

-- Função para adicionar o submenu "Nissan"
function AddNissanSubMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, "Nissan")
    
    -- Lista de veículos da marca Nissan
    local nissanVehicles = {
        { name = "Nissan-GT-R", model = "nismo20" },
        { name = "Nissan-R35", model = "r35kream" },
        { name = "Nissan-50", model = "rmodgtr50" }
    }

    AddVehiclesToSubMenu(submenu, nissanVehicles)
end

-- Função para adicionar o submenu "Honda"
function AddHondaSubMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, "Honda")
    
    -- Lista de veículos da marca Honda
    local hondaVehicles = {
        { name = "Honda-civic", model = "razerfd2civic" },
        { name = "Honda-Type-R", model = "DC5" }
    }

    AddVehiclesToSubMenu(submenu, hondaVehicles)
end

-- Função para adicionar o submenu "Ferrari"
function AddFerrariSubMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, "Ferrari")
    
    -- Lista de veículos da marca Ferrari
    local ferrariVehicles = {
        { name = "Ferrari-Spyder", model = "458spider" }
    }

    AddVehiclesToSubMenu(submenu, ferrariVehicles)
end

-- Função para adicionar o submenu "Lambo"
function AddLamboSubMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, "Lambo")
    
    -- Lista de veículos da marca Lambo
    local lamboVehicles = {
        { name = "Lambo-Aventador", model = "avj" },
        { name = "Lambo-Rt", model = "RTGurus" },
        { name = "Lambo-murus", model = "murus" },
        { name = "Lambo-gcm", model = "gcmlamboultimae" }
    }

    AddVehiclesToSubMenu(submenu, lamboVehicles)
end

-- Função para adicionar o submenu "Mitsubishi"
function AddMitsubishiSubMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, "Mitsubishi")
    
    -- Lista de veículos da marca Mitsubishi
    local mitsubishiVehicles = {
        { name = "Lancer-evo", model = "hycadeevo" }
    }

    AddVehiclesToSubMenu(submenu, mitsubishiVehicles)
end

-- Adiciona os submenus ao menu principal
AddAudiSubMenu(mainMenu)
AddChevroletSubMenu(mainMenu)
AddDodgeSubMenu(mainMenu)
AddNissanSubMenu(mainMenu)
AddHondaSubMenu(mainMenu)
AddFerrariSubMenu(mainMenu)
AddLamboSubMenu(mainMenu)
AddMitsubishiSubMenu(mainMenu)

-- Atualiza o Menu Pool
_menuPool:RefreshIndex()

-- Thread para processar os menus e detectar a tecla de ativação
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
        
        -- A tecla "E" (control 38) irá ativar o menu
        if IsControlJustPressed(1, 288) then -- 288 corresponde à tecla "f1"
            mainMenu:Visible(not mainMenu:Visible())
        end
    end
end)
