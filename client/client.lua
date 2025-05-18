AddEventHandler("Bodycam:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Callbacks = exports[Config.BaseName]:FetchComponent("Callbacks")
	Notification = exports[Config.BaseName]:FetchComponent("Notification")
    ListMenu = exports[Config.BaseName]:FetchComponent("ListMenu")
    Targeting = exports[Config.BaseName]:FetchComponent("Targeting")
    Police = exports[Config.BaseName]:FetchComponent("Police")
    Hud = exports[Config.BaseName]:FetchComponent("Hud")
end

AddEventHandler("Core:Shared:Ready", function()
	exports[Config.BaseName]:RequestDependencies("Bodycam", {
		"Callbacks",
		"Notification",
        "ListMenu",
        "Targeting",
        "Police",
        "Hud",

	}, function(error)
		if #error > 0 then
			return
		end
		RetrieveComponents()
        Startupp()
    end)
end)

PlacesCams = {}

local seenGroups = {}

for i, cam in ipairs(Config.Places.Cameras) do
    if cam.isOnline and not seenGroups[cam.group] then
        table.insert(PlacesCams, {
            label = cam.label,
            group = cam.group
        })
        seenGroups[cam.group] = true
    end
end

local playerdataLoaded = false
local bodyCams = {}
-- local carCams  = {}
local PlayerData = {}
local cam = nil
local inCam = false
local lastMenu
local lastCoords
local pedHeading
local targetPed
local bodycamW = false

RegisterNetEvent('playerLoaded', function()
    playerLoaded()
end)

RegisterNetEvent('KR:body:pload', function(body)
    bodyCams = body
    -- carCams = cars
end)

RegisterNetEvent('KR:addTable:BodyCam', function(tableId, tableData)
    if bodyCams == nil then
        bodyCams = {}
    end
    if bodyCams[tableId] == nil then 
        bodyCams[tableId] = tableData
    end
end)

RegisterNetEvent('KR:removeTable:BodyCam', function(tableId)
    bodyCams[tableId] = nil
end)

-- RegisterNetEvent('KR:addTable:DashCam', function(tableId, tableData)
--     if carCams == nil then
--         carCams = {}
--     end
--     if carCams[tableId] == nil then 
--         carCams[tableId] = tableData
--     end
-- end)

-- RegisterNetEvent('KR:removeTable:DashCam', function(tableId)
--     carCams[tableId] = nil
-- end)

function GetClosestVehicleWithinRadius(coords, radius)
    if not radius then
        radius = 5.0
    end

    local poolVehicles = GetGamePool('CVehicle')
    local lastDist = radius
    local lastVeh = false
    
    for k, v in ipairs(poolVehicles) do
        if DoesEntityExist(v) then
            local dist = #(coords - GetEntityCoords(v))
            if dist <= lastDist then
                lastDist = dist
                lastVeh = v
            end
        end
    end

    return lastVeh
end

-- RegisterNetEvent('KR:AddOrRemove:DashCam', function()
--     local coords = GetEntityCoords(PlayerPedId())
--     local carId = GetClosestVehicleWithinRadius(coords, 2.0)

--     if carId then
--         if Police:IsPdCar(carId) then
--             local bone = GetEntityBoneIndexByName(carId, 'windscreen')
--             if bone == -1 then
--                 bone = GetEntityBoneIndexByName(carId, 'windscreen_f')
--             end
            
--             local plate = GetVehicleNumberPlateText(carId)
--             TriggerServerEvent('KR:addDashCam', tostring(NetworkGetNetworkIdFromEntity(carId)), plate, bone)
--             Notification:Success("Dashcam turned on")
--         else
--             Notification:Error("This vehicle is not authorized for a dashcam")
--         end
--     else
--         Notification:Error("You are not near a vehicle")
--     end
-- end)

RegisterNetEvent('KR:watchBodycam', function(data)
    local tableId = data.tableId
    local targetServerId = tableId
    Callbacks:ServerCallback('Bodycam:AttemptWatch', {targetId = targetServerId}, function(response)
        if not response.success then
            Notification:Error(response.message)
            return
        end

        DoScreenFadeOut(1000)

        while not IsScreenFadedOut() do
            Wait(0)
        end

        myPed = PlayerPedId()
        myCoords = GetEntityCoords(myPed)
        SetEntityVisible(myPed, false)

        Callbacks:ServerCallback('KR:getCoords', { id = tableId }, function(coords)
            SetEntityCoords(myPed, coords.x, coords.y, coords.z - 50)
            FreezeEntityPosition(myPed, true)
        end)

        Wait(500)

        targetplayer = GetPlayerFromServerId(tableId)
        targetPed = GetPlayerPed(targetplayer)

        SetTimecycleModifier("scanline_cam_cheap")
        SetTimecycleModifierStrength(2.0)
        CreateHeliCam()
        cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)

        AttachCamToPedBone(cam, targetPed, 31086, 0.0, 0, 0.1, true)
        SetCamFov(cam, 60.0)
        RenderScriptCams(true, false, 0, 1, 0)
        Hud:Hide()
        inCam = true
        bodycamW = true
        LocalPlayer.state:set("inCCTVCam", true, true)

        DoScreenFadeIn(1000)

        while true do
            if inCam then
                -- Add connection validity check
                if not DoesEntityExist(targetPed) or GetEntityHealth(targetPed) <= 0 then
                    Notification:Error(Config.Notifications.SubjectDisconnected)
                    exitCam()
                    break
                end
                
                -- Existing distance check
                targetCoords2 = GetEntityCoords(targetPed)
                local distance = #(myCoords - targetCoords2)
                if distance > 290 then
                    SetEntityCoords(myPed, targetCoords2.x, targetCoords2.y, targetCoords2.z - 100)
                end
            else
                break
            end
            Wait(250)
        end
    end)
end)

-- RegisterNetEvent('KR:watchDashcam', function(data)
--     DoScreenFadeOut(1000)
--     while not IsScreenFadedOut() do Wait(0) end

--     local camId = data.camId

--     local ped = PlayerPedId()
--     SetEntityVisible(ped, false)
--     FreezeEntityPosition(ped, true)

--     local vehicle = NetworkGetEntityFromNetworkId(tonumber(camId))

--     if DoesEntityExist(vehicle) then
--         local vehCoords = GetEntityCoords(vehicle)
--         SetEntityCoords(ped, vehCoords.x, vehCoords.y, vehCoords.z - 100.0)

--         SetTimecycleModifier("scanline_cam_cheap")
--         SetTimecycleModifierStrength(2.0)
--         CreateHeliCam()
--         local cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)

--         if carCams and carCams[camId] then
--             AttachCamToVehicleBone(cam, vehicle, carCams[camId].bone, true, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true)
--         end

--         SetCamFov(cam, 80.0)
--         RenderScriptCams(true, false, 0, 1, 0)

--         inCam = true
--         DoScreenFadeIn(1000)
--         LocalPlayer.state:set("inCCTVCam", true, true)

--         CreateThread(function()
--             while inCam do
--                 if DoesEntityExist(vehicle) then
--                     local currentVehCoords = GetEntityCoords(vehicle)
--                     local currentPedCoords = GetEntityCoords(ped)
                    
--                     if #(currentPedCoords - currentVehCoords) > 290.0 then
--                         SetEntityCoords(ped, currentVehCoords.x, currentVehCoords.y, currentVehCoords.z - 100.0)
--                     end
--                 else
--                     break
--                 end
--                 Wait(250)
--             end

--             RenderScriptCams(false, false, 0, 1, 0)
--             DestroyCam(cam, false)
--             ClearTimecycleModifier()
--             SetEntityVisible(ped, true)
--             FreezeEntityPosition(ped, false)
--             inCam = false
--             LocalPlayer.state:set("inCCTVCam", false, true)
--         end)
--     else
--         DoScreenFadeIn(1000)
--     end
-- end)

AddEventHandler('onClientResourceStart', function(resName)
    if (GetCurrentResourceName() == resName) then
        playerLoaded()
    end
end)

RegisterNetEvent("Job:Client:DutyChanged", function(state)
	if state == "police" then
        playerLoaded()
    else
        playerdataLoaded = false
    end
end)

function playerLoaded()
    if LocalPlayer.state.onDuty == "police" then
        TriggerServerEvent('KR:playerLoaded:bodycam')
        playerdataLoaded = true
    end
end

Citizen.CreateThread(function()
    while true do
        if inCam then
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
            DisableControlAction(0, 22, true) -- INPUT_JUMP
            DisableControlAction(0, 30, true) -- disable left/right
            DisableControlAction(0, 31, true) -- disable forward/back
            DisableControlAction(0, 36, true) -- INPUT_DUCK
            DisableControlAction(0, 21, true) -- disable sprint
            DisableControlAction(0, 44, true) -- disable cover
            DisableControlAction(0, 63, true) -- veh turn left
            DisableControlAction(0, 64, true) -- veh turn right
            DisableControlAction(0, 71, true) -- veh forward
            DisableControlAction(0, 72, true) -- veh backwards
            DisableControlAction(0, 75, true) -- disable exit vehicle
            DisablePlayerFiring(PlayerId(), true) -- Disable weapon firing
            DisableControlAction(0, 24, true) -- disable attack
            DisableControlAction(0, 25, true) -- disable aim
            DisableControlAction(1, 37, true) -- disable weapon select
            DisableControlAction(0, 47, true) -- disable weapon
            DisableControlAction(0, 58, true) -- disable weapon
            DisableControlAction(0, 140, true) -- disable melee
            DisableControlAction(0, 141, true) -- disable melee
            DisableControlAction(0, 142, true) -- disable melee
            DisableControlAction(0, 143, true) -- disable melee
            DisableControlAction(0, 263, true) -- disable melee
            DisableControlAction(0, 264, true) -- disable melee
            DisableControlAction(0, 257, true) -- disable melee
        end
        Wait(0)
    end
end)

function CreateHeliCam()
    local scaleform = RequestScaleformMovie("HELI_CAM")
	while not HasScaleformMovieLoaded(scaleform) do
		Wait(0)
	end
end

function InstructionButton(ControlButton)
    ScaleformMovieMethodAddParamPlayerNameString(ControlButton)
end

function InstructionButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function CreateInstuctionScaleform(scaleform)
    scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    InstructionButton(GetControlInstructionalButton(1, 202, true))
    InstructionButtonMessage("Exit cam")
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()
    return scaleform
end

function prepareCameraSelf(ped, activating)
	DetachEntity(ped, 1, 1)
	SetEntityCollision(ped, not activating, not activating)
	SetEntityInvincible(ped, activating)
	if activating then
	  	NetworkFadeOutEntity(ped, activating, false)
	else
	  	NetworkFadeInEntity(ped, 0, false)
	end
    SetEntityVisible(ped, true)
    FreezeEntityPosition(ped, false)
    if bodycamW then
        SetFocusEntity(ped)
        NetworkSetInSpectatorMode(0, ped)
    end
    SetEntityCoords(ped, lastCoords.x, lastCoords.y, lastCoords.z)
end

function exitCam()
    -- Immediately set inCam to prevent race conditions
    inCam = false
    bodycamW = false
    
    -- Server cleanup
    TriggerServerEvent('Bodycam:ReleaseWatch')
    
    -- Rest of existing visual cleanup
    local ped = PlayerPedId()
    Hud:Show()
    LocalPlayer.state:set("inCCTVCam", false, true)
    prepareCameraSelf(ped, false)
    RenderScriptCams(false, false, 0, 1, 0)
    SetTimecycleModifier("default")
    SetTimecycleModifierStrength(0.3)
    
    -- Ensure player is visible and unfrozen
    SetEntityVisible(ped, true)
    FreezeEntityPosition(ped, false)
end

RegisterNetEvent('Bodycam:ForceDisconnect', function(message)
    if inCam then
        Notification:Error(message)
        exitCam()
    end
end)

AddEventHandler('openCamsMenu', function()
    lastCoords = GetEntityCoords(PlayerPedId())
    local menu = {
        main = {
            label = Config.MenuTexts.MainMenuText,
            items = {
                {
                    label = Config.MenuTexts.DashCamsLabel,
                    description = Config.MenuTexts.DashCamsText,
                    event = 'CAMS:Client:ListCams',
                    data = { type = 'bodycam' }
                },
                -- {
                --     label = "Dashcam List",
                --     description = "Click to see the vehicles with Dashcam",
                --     event = 'CAMS:Client:ListCams',
                --     data = { type = 'dashcam' }
                -- }
            }
        }
    }

    if Config.Places.Enable then
        table.insert(menu.main.items, {
            label = Config.MenuTexts.cctvsLabel,
            description = Config.MenuTexts.cctvsText,
            event = 'CAMS:Client:ListCams',
            data = { type = 'places' }
        })
    end

    ListMenu:Show(menu)
end)

AddEventHandler('CAMS:Client:ListCams', function(data)
    lastMenu = data.type
    local menu = {
        main = {
            label = '',
            items = {}
        }
    }

    if data.type == "bodycam" then
        if not next(bodyCams) then
            Notification:Error(Config.Notifications.NoCameraFound)
            return
        end
    
        menu.main.label = Config.MenuTexts.DashCamLabel
    
        local playerServerId = GetPlayerServerId(PlayerId())
    
        for k, v in pairs(bodyCams) do
            local isSelf = tonumber(k) == playerServerId
            local disabled = isSelf or v.isDisabled
    
            menu.main.items[#menu.main.items + 1] = {
                label = (v.isDisabled and "🔴 " or "") .. v.gradeLabel .. ' - ' .. v.names,
                description = Config.MenuTexts.DashCamText .. v.names,
                event = 'KR:watchBodycam',
                data = { tableId = tonumber(k) },
                disabled = disabled
            }
        end

    -- elseif data.type == "dashcam" then
    --     if not next(carCams) then
    --         Notification:Error(Config.Notifications.NoCameraFound)
    --         return
    --     end
    --     menu.main.label = "Dashcam List"
    --     for k, v in pairs(carCams) do
    --         menu.main.items[#menu.main.items + 1] = {
    --             label = v.plate .. ' - ' .. v.names,
    --             description = string.format("Watch the dashcam of cop %s", v.names),
    --             event = 'KR:watchDashcam',
    --             data = { camId = k }
    --         }
    --     end

    elseif data.type == "places" then
        if not next(PlacesCams) then
            Notification:Error(Config.Notifications.NoCameraFound)
            return
        end
        menu.main.label = Config.MenuTexts.cctvLabel
        for _, v in ipairs(PlacesCams) do
            menu.main.items[#menu.main.items + 1] = {
                label = v.label,
                description = Config.MenuTexts.cctvText .. v.group,
                event = 'CAMS:Client:ViewGroup',
                data = { group = v.group }
            }
        end
    end
    ListMenu:Show(menu)
end)


AddEventHandler('CAMS:Client:ViewGroup', function(data)
    Callbacks:ServerCallback('CCTV:ViewGroup', data.group)
end)

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.28, 0.28)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextDropshadow(0)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 250
    DrawRect(_x,_y +0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
end

CreateThread(function()
    while true do
        local sleep = 1000
        if playerdataLoaded then
            if inCam then
                sleep = 1
                if bodycamW then
                    pedHeading = GetEntityHeading(targetPed)
                    if not printed and Config.DebugMode then
                        print("We are doing it!")
                        printed = true
                        SetTimeout(10000, function()
                            printed = false
                        end)
                    end
                    SetCamRot(cam, 0, 0, pedHeading, 2)
                end
                local instructions = CreateInstuctionScaleform("instructional_buttons")
                DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)
                if IsControlJustPressed(0, 202) then
                    exitCam()
                end
            else
                sleep = 1000
            end
        end
        Wait(sleep)
    end
end)

function Startupp()
    if not Config.Targeting.Enable then
        if Config.DebugMode then
            print("Native mode")
        end
        CreateThread(function()
            while true do
                local sleep = 1000
                if playerdataLoaded then
                    local ped = PlayerPedId()
                    local coords = GetEntityCoords(ped)
                    if LocalPlayer.state.onDuty == "police" and not inCam then
                        local zoneSize = math.max(2, math.min(Config.Native.ZoneSize, 15))
                        local distance = #(coords - Config.WatchCoords)
                        if distance <= zoneSize then
                            sleep = 5
                            DrawText3D(Config.WatchCoords.x, Config.WatchCoords.y, Config.WatchCoords.z, Config.Native.Text)
                            if IsControlJustPressed(0, Config.Native.KEY) then
                                TriggerEvent("openCamsMenu")
                            end
                        end
                    end
                end
                Wait(sleep)
            end
        end)
    else
        if Config.DebugMode then
            print("Targeting mode")
        end
        Targeting.Zones:AddBox("dispatch-cameras", "camera", Config.WatchCoords, 1, 1, {
            heading = 0,
            minZ = Config.WatchCoords.z - 1,
            maxZ = Config.WatchCoords.z + 1,
        },{
            {
                icon = Config.Targeting.Icon,
                text = Config.Targeting.Text,
                event = "openCamsMenu",
                data = {},
                isEnabled = function()
                    return LocalPlayer.state.onDuty == "police"
                end,                
            }
        }, 3.0, true)
    end
end

RegisterKeyMapping('bodyexit', 'Bodycam Exit', 'keyboard', 'back')
RegisterCommand('bodyexit', function()
    if inCam then
        exitCam()
    else
        TriggerEvent("openCamsMenu")
    end
end)
RegisterCommand('ForceExitBodyCam', function()
    DoScreenFadeIn(1000)
end)
