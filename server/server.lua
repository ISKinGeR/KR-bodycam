local jobPlayers = {}
local bodyCams = {}
-- local carCams  = {}
local gradeLabels = {}
local watchingRelations = {
    watchers = {},       -- [watcherId] = targetId
    subjects = {},       -- [targetId] = {watcherIds}
    activeViewers = {}   -- [viewerId] = true (people watching ANY camera)
}
RegisterNetEvent('Job:Server:DutyAdd', function(dutyData, source, stateId, callsign)
    if dutyData.Id ~= 'police' then return end

    gradeLabels[source] = dutyData.GradeId
end)

function ifprint(...)
    if Config.DebugMode then
        local args = { ... }
        local msg = "[Debug] "

        for i = 1, #args do
            msg = msg .. tostring(args[i])
            if i < #args then
                msg = msg .. " "
            end
        end

        print(msg)
    end
end

AddEventHandler('Bodycam:Shared:DependencyUpdate', RetrieveComponents)
function RetrieveComponents()
    Database = exports[Config.BaseName]:FetchComponent('Database')
    Callbacks = exports[Config.BaseName]:FetchComponent('Callbacks')
    Fetch = exports[Config.BaseName]:FetchComponent('Fetch')
    Chat = exports[Config.BaseName]:FetchComponent('Chat')
    Execute = exports[Config.BaseName]:FetchComponent('Execute')
    Logger = exports[Config.BaseName]:FetchComponent("Logger")
    Inventory = exports[Config.BaseName]:FetchComponent('Inventory')
    print("[BodyCAM] | The System is Ready!")
end

AddEventHandler('Core:Shared:Ready', function()
    exports[Config.BaseName]:RequestDependencies('Bodycam', {
        'Database',
        'Callbacks',
        'Fetch',
        'Chat',
        'Execute',
        'Logger',
        'Inventory',
    }, function(error)
        if #error > 0 then 
            return 
        end 

        RetrieveComponents()

        Callbacks:RegisterServerCallback('KR:getCoords', function(source, data, cb)
            local ped = GetPlayerPed(data.id)
            local playerCoords = GetEntityCoords(ped)
            cb(playerCoords)
        end)
    
        -- Callbacks:RegisterServerCallback('KR:getCoordsCar', function(source, data, cb)
        --     local coords = GetEntityCoords(NetworkGetEntityFromNetworkId(data.id))
        --     cb(coords)
        -- end)

        Callbacks:RegisterServerCallback('Bodycam:AttemptWatch', function(source, data, cb)
            local watcherId = source
            local targetId = data.targetId
        
            if watchingRelations.activeViewers[watcherId] then
                cb({success = false, message = Config.Notifications.AlreadyWatching})
                return
            end
        
            if watchingRelations.subjects[targetId] then
                cb({success = false, message = Config.Notifications.CameraInUse})
                return
            end
        
            if watchingRelations.watchers[targetId] then
                cb({success = false, message = Config.Notifications.SubjectIsWatching})
                return
            end
        
            -- Cleanup previous watches by this watcher
            local previousTarget = watchingRelations.watchers[watcherId]
            if previousTarget then
                if watchingRelations.subjects[previousTarget] then
                    for k,v in pairs(watchingRelations.subjects[previousTarget]) do
                        if v == watcherId then
                            table.remove(watchingRelations.subjects[previousTarget], k)
                            break
                        end
                    end
                end
            end

            watchingRelations.watchers[watcherId] = targetId
            watchingRelations.activeViewers[watcherId] = true
            watchingRelations.subjects[targetId] = watchingRelations.subjects[targetId] or {}
            table.insert(watchingRelations.subjects[targetId], watcherId)
        

            -- Force disconnect anyone watching the watcher
            if watchingRelations.subjects[watcherId] then
                for _, victimId in ipairs(watchingRelations.subjects[watcherId]) do
                    TriggerClientEvent('Bodycam:ForceDisconnect', victimId, Config.Notifications.SubjectStartedWatching)
                    -- Reset victim's relationships
                    watchingRelations.watchers[victimId] = nil
                    watchingRelations.activeViewers[victimId] = nil
                    -- Re-enable victim's camera
                    if bodyCams[tostring(victimId)] then
                        bodyCams[tostring(victimId)].isDisabled = false
                        TriggerJob(true, tostring(victimId), true)
                    end
                end
                watchingRelations.subjects[watcherId] = nil
            end

            if watchingRelations.subjects[watcherId] then
                for _, victimId in ipairs(watchingRelations.subjects[watcherId]) do
                    TriggerClientEvent('Bodycam:ForceDisconnect', victimId, Config.Notifications.SubjectStartedWatching)
                    watchingRelations.watchers[victimId] = nil
                    watchingRelations.activeViewers[victimId] = nil
                end
                watchingRelations.subjects[watcherId] = nil
            end
        
            bodyCams[tostring(watcherId)].isDisabled = true
            TriggerJob(true, tostring(watcherId), true)
        
            cb({success = true})
        end)

        if Config.Items.Enable then
            Inventory.Items:RegisterUse("bodycam", "bodycam", function(source, item, itemData)
                if Config.Base == "mythic" then
                    local player = Fetch:Source(source)
                    local char = player:GetData("Character")
                else 
                    local char = Fetch:CharacterSource(source)
                end

                if not char then 
                    return 
                end

                if jobPlayers[tostring(source)] ~= nil then
                    if not jobPlayers[tostring(source)] then
                        jobPlayers[tostring(source)] = true
                
                        if bodyCams[tostring(source)] == nil then
                            local player = Player(source)
                            if player and player.state and player.state.onDuty and player.state.onDuty == "police" then
                                local grade_label = gradeLabels[source] or "TBD"
                
                                if char then
                                    local firstName = char:GetData("First")
                                    local lastName = char:GetData("Last")
                                    
                                    if firstName and lastName then
                                        bodyCams[tostring(source)] = {
                                            gradeLabel = grade_label,
                                            names = firstName .. " " .. lastName
                                        }
                                        TriggerJob(true, tostring(source), true)
                                        Execute:Client(source, "Notification", "Success", Config.Notifications.BodycamON)
                                    end
                                end
                            end
                        end
                    else
                        jobPlayers[tostring(source)] = false
                        if bodyCams[tostring(source)] ~= nil then
                            CleanupSubjectWatchers(source)
                            bodyCams[tostring(source)] = nil
                            TriggerJob(true, tostring(source), false)
                            Execute:Client(source, "Notification", "Error", Config.Notifications.BodycamOFF)
                        end
                    end
                end            
            end)
        
            -- Inventory.Items:RegisterUse("dashcam", "dashcam", function(source, item, itemData)
            --     if jobPlayers[tostring(source)] ~= nil then
            --         TriggerClientEvent('KR:AddOrRemove:DashCam',source)
            --     end
            -- end)
        end

    end)
end)

-- Add this function to clean up watchers when someone disables their bodycam
function CleanupSubjectWatchers(subjectId)
    if watchingRelations.subjects[subjectId] then
        for _, watcherId in ipairs(watchingRelations.subjects[subjectId]) do
            TriggerClientEvent('Bodycam:ForceDisconnect', watcherId, Config.Notifications.SubjectDisabledCamera)
            -- Cleanup watcher's relationships
            watchingRelations.watchers[watcherId] = nil
            watchingRelations.activeViewers[watcherId] = nil
            -- Re-enable watcher's camera if needed
            if bodyCams[tostring(watcherId)] then
                bodyCams[tostring(watcherId)].isDisabled = false
                TriggerJob(true, tostring(watcherId), true)
            end
        end
        watchingRelations.subjects[subjectId] = nil
    end
end

RegisterNetEvent('Bodycam:ReleaseWatch', function()
    local src = source
    local targetId = watchingRelations.watchers[src]
    
    if targetId then
        -- Cleanup relationships
        watchingRelations.watchers[src] = nil
        watchingRelations.activeViewers[src] = nil
        
        if watchingRelations.subjects[targetId] then
            for k,v in pairs(watchingRelations.subjects[targetId]) do
                if v == src then
                    table.remove(watchingRelations.subjects[targetId], k)
                    break
                end
            end
            
            if #watchingRelations.subjects[targetId] == 0 then
                watchingRelations.subjects[targetId] = nil
            end
        end

        -- Re-enable bodycam
        if bodyCams[tostring(src)] then
            bodyCams[tostring(src)].isDisabled = false
            TriggerJob(true, tostring(src), true)
        end
    end
end)

RegisterNetEvent('KR:playerLoaded:bodycam', function()
    local src = source
    if Player(src).state.onDuty == 'police' then
        if jobPlayers[tostring(src)] == nil then
            jobPlayers[tostring(src)] = false
        end
        TriggerClientEvent('KR:body:pload', src, bodyCams)
    end
end)

RegisterNetEvent('KR:jobCheck', function()
    local src = source
    if Player(src).state.onDuty == 'police' then
        if jobPlayers[tostring(src)] == nil then
            jobPlayers[tostring(src)] = false
        end
    else
        if jobPlayers[tostring(src)] ~= nil then
            jobPlayers[tostring(src)] = nil
            if bodyCams[tostring(src)] ~= nil then
                bodyCams[tostring(src)] = nil
                TriggerJob(true, tostring(src), false)
            end
        end
    end
end)

-- RegisterNetEvent('KR:closeBodyCam:Inventory', function(source)
--     local src = source
--     if jobPlayers[tostring(src)] then
--         jobPlayers[tostring(src)] = false
--         if bodyCams[tostring(src)] ~= nil then
--             bodyCams[tostring(src)] = nil
--             TriggerJob(true, tostring(src), false)
--             TriggerClientEvent('showNotification', src, "Bodycam turned off")
--         end
--     end
-- end)

AddEventHandler('playerDropped', function(reason)
    local src = source    
    TriggerEvent('Bodycam:ReleaseWatch', src)
    
    -- Handle if player was being watched
    if watchingRelations.subjects[src] then
        for _, watcherId in ipairs(watchingRelations.subjects[src]) do
            TriggerClientEvent('Bodycam:ForceDisconnect', watcherId, Config.Notifications.SubjectDisconnected)
        end
        watchingRelations.subjects[src] = nil
    end

    if jobPlayers[tostring(src)] ~= nil then
        jobPlayers[tostring(src)] = nil
        if bodyCams[tostring(src)] ~= nil then
            bodyCams[tostring(src)] = nil
            TriggerJob(true, tostring(src), false)
        end
    end
    gradeLabels[src] = nil
end)

-- RegisterNetEvent('KR:addDashCam', function(netId, plate, bone)
--     local src = source
--     local player = Fetch:Source(src)
--     local char = player:GetData("Character")
--     if char then
--         local firstName = char:GetData("First")
--         local lastName = char:GetData("Last")
--         carCams[netId] = {
--             names = firstName .. " " .. lastName,
--             plate = plate,
--             bone = bone
--         }
--         TriggerJob(false, netId, true)
--     end
-- end)

-- RegisterNetEvent('KR:removeTable:DashCam:s', function(carId)
--     carCams[carId] = nil
--     TriggerJob(false, carId, false)
-- end)

function TriggerJob(bodyCam, tableId, add)

    if bodyCam then
        for k, v in pairs(jobPlayers) do
            if add then
                TriggerClientEvent('KR:addTable:BodyCam', k, tableId, bodyCams[tableId])
            else
                TriggerClientEvent('KR:removeTable:BodyCam', k, tableId)
            end
        end
    else
        if Config.DebugMode then
            ifprint("The dashcam have been removed coz its broken")
        end
        -- for k, v in pairs(jobPlayers) do
        --     if add then
        --         TriggerClientEvent('KR:addTable:DashCam', k, tableId, carCams[tableId])
        --     else
        --         TriggerClientEvent('KR:removeTable:DashCam', k, tableId)
        --     end
        -- end
    end
end

-- RegisterCommand("bodycam", function(source, args, rawCommand)
--     if not args[1] then
--         return
--     end
--     local enable = args[1]:lower() == "true"
--     TriggerEvent("KR:ToggleBodycam", enable)
-- end, false)

-- RegisterCommand("bodycam", function(source, args, rawCommand)
--     print("We are here")
--     TriggerClientEvent('KR:AddOrRemove:DashCam',2)
-- end, false)

if not Config.Items.Enable then
    RegisterNetEvent("KR:ToggleBodycam", function(enable)
        local source = source
        ifprint("Source:", source)
        ifprint("Enable:", enable)

        local char

        if Config.Base == "mythic" then
            ifprint("Config.Base is mythic")
            local player = Fetch:Source(source)
            ifprint("Player:", player)
            if player then
                char = player:GetData("Character")
                ifprint("Character (from player):", char)
            end
        else 
            ifprint("Config.Base is NOT mythic")
            char = Fetch:CharacterSource(source)
            ifprint("Character (from CharacterSource):", char)
        end

        if not char then
            ifprint("char is nil, aborting.")
            return
        end

        jobPlayers[tostring(source)] = enable
        ifprint("jobPlayers updated:", jobPlayers[tostring(source)])

        if enable then
            if not bodyCams[tostring(source)] then
                ifprint("No existing bodycam, proceeding to turn on.")

                local plystates = Player(source)
                ifprint("plystates:", plystates)

                if not (plystates and plystates.state and plystates.state.onDuty and plystates.state.onDuty == "police") then
                    ifprint("Player is not onDuty as police, aborting.")
                    return
                end

                local grade_label = gradeLabels[source] or "TBD"
                ifprint("Grade Label:", grade_label)

                local firstName = char:GetData("First")
                local lastName = char:GetData("Last")
                ifprint("First Name:", firstName)
                ifprint("Last Name:", lastName)

                if not (firstName and lastName) then
                    Execute:Client(source, "Notification", "Error", Config.Notifications.NoNameFound)
                    ifprint("Missing names, aborted.")
                    return
                end

                bodyCams[tostring(source)] = {
                    gradeLabel = grade_label,
                    names = firstName .. " " .. lastName,
                    isDisabled = false
                }

                ifprint("Bodycam data saved:", json.encode(bodyCams[tostring(source)]))

                TriggerJob(true, tostring(source), true)
                Execute:Client(source, "Notification", "Success", Config.Notifications.BodycamON)
            else
                ifprint("Bodycam already exists, skipping.")
            end
        else
            if bodyCams[tostring(source)] then
                -- Cleanup anyone watching this player
                CleanupSubjectWatchers(source)
                TriggerEvent('Bodycam:ReleaseWatch', source)
                bodyCams[tostring(source)] = nil
                TriggerJob(true, tostring(source), false)
                Execute:Client(source, "Notification", "Error", Config.Notifications.BodycamOFF)
            else
                ifprint("No bodycam to remove for source:", source)
            end
        end
    end)
    
    -- RegisterNetEvent("KR:ToggleDashcam", function()
    --     local source = source
    --     if jobPlayers[tostring(source)] ~= nil then
    --         TriggerClientEvent('KR:AddOrRemove:DashCam', source)
    --     end
    -- end)
end