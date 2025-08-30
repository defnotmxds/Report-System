function OpenReportMenu()
    local input = lib.inputDialog('Submit a Report', {
        {type = 'input', label = 'Report Text', placeholder = 'Describe the issue...'}
    })

    if input and input[1] and input[1] ~= "" then
        TriggerServerEvent('cfx-mxds-reports:submit', input[1])
    end
end

function OpenViewReportsMenu(reports)
    lib.callback('cfx-mxds-reports:isAdmin', false, function(isAdmin)
        local reportList = {}
        for _, report in ipairs(reports) do
            table.insert(reportList, {
                title = "Report ID: " .. report.id,
                description = "Player ID: " .. report.playerId .. " | Status: " .. report.status .. " | Text: " .. report.text,
                icon = "file-text",
                onSelect = function()
                    local options = {}

                    if isAdmin then
                        table.insert(options, {
                            title = "🗑️ Close Report",
                            icon = "check-circle",
                            onSelect = function()
                                local confirm = lib.alertDialog({
                                    header = "Close Report",
                                    content = "Are you sure you want to close this report?",
                                    centered = true,
                                    cancel = true
                                })
                                if confirm == "confirm" then
                                    TriggerServerEvent('cfx-mxds-reports:close', report.id)
                                end
                            end
                        })

                        table.insert(options, {
                            title = "📍 Go To Player",
                            icon = "location-arrow",
                            onSelect = function()
                                TriggerServerEvent('cfx-mxds-reports:teleportToPlayer', report.playerId)
                            end
                        })
                    end

                    lib.registerContext({
                        id = 'report_actions_' .. report.id,
                        title = 'Actions for Report ID ' .. report.id,
                        options = options
                    })

                    lib.showContext('report_actions_' .. report.id)
                end
            })
        end

        lib.registerContext({
            id = 'report_menu',
            title = 'View Reports',
            options = reportList
        })

        lib.showContext('report_menu')
    end)
end


RegisterCommand('reports', function()
    lib.callback('cfx-mxds-reports:getReports', false, function(reports)
        if reports and #reports > 0 then
            OpenViewReportsMenu(reports)
        else
            lib.notify({title = 'Reports', description = 'No reports found or no access.', type = 'error'})
        end
    end)
end)

RegisterNetEvent('cfx-mxds-reports:teleportClient')
AddEventHandler('cfx-mxds-reports:teleportClient', function(coords)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
    lib.notify({title = 'Teleport', description = 'Teleported to player.', type = 'success'})
end)


RegisterNetEvent('cfx-mxds-reports:openSubmitMenu')
AddEventHandler('cfx-mxds-reports:openSubmitMenu', function()
    OpenReportMenu()
end)

RegisterNetEvent('cfx-mxds-reports:submitted')
AddEventHandler('cfx-mxds-reports:submitted', function()
    lib.notify({
        title = 'Report Submitted',
        description = 'Your report has been successfully submitted!',
        type = 'success'
    })
end)

RegisterNetEvent('cfx-mxds-reports:notify')
AddEventHandler('cfx-mxds-reports:notify', function(message, type)
    lib.notify({
        title = 'Report System',
        description = message,
        type = type or 'info'
    })
end)


RegisterNetEvent('cfx-mxds-reports:notify')
AddEventHandler('cfx-mxds-reports:notify', function(message)
    print(message)
end)
