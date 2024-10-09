local panel = false

Citizen.CreateThread(function()
    Wait(1000)
    print ("Teste")
    for k,v in ipairs(skins) do
        SendNUIMessage({
            img = skins[k].img,
            name = skins[k].name,
            id = skins[k].id
        })
    end
end)

RegisterCommand("skin",function()
    if(panel == false) then
        SetNuiFocus(true,true)
        SendNUIMessage({
            open = true
        })
        panel = true
    else
        SetNuiFocus(false,false)
        SendNUIMessage({
            open = false
        })
        panel = false
    end
end, false)

RegisterNUICallback('buttonclose', function(data, cb)
    if(data.panel == false) then
        panel = false
        SetNuiFocus(false,false)
    end
end)

RegisterNUICallback('setskin', function(data, cb)
    if(data.id) then
        local model = data.id
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(500)
        end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
    end
end)