local reports = {}
local REPORT_WEBHOOK = ''


local function sendToDiscord(title, description, color)
    local embed = {
        {
            title = title,
            description = description,
            color = color or 16777215,
            footer = { text = "Report System Logs" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(REPORT_WEBHOOK, function(err, text, headers) end, 'POST', json.encode({
        username = 'M Developments',
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

function submitReport(playerId, reportText)
    local name = GetPlayerName(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)
    local discord, ip = "N/A", "N/A"

    for _, id in ipairs(identifiers) do
        if id:find("discord:") then
            discord = "<@" .. id:gsub("discord:", "") .. ">"
        elseif id:find("ip:") then
            ip = "||" .. id:gsub("ip:", "") .. "||"
        end
    end

    local report = {
        id = #reports + 1,
        playerId = playerId,
        text = reportText,
        status = "open"
    }

    table.insert(reports, report)
    TriggerClientEvent('cfx-mxds-reports:submitted', playerId)

    local description = ("**Name:** %s\n**Server ID:** %s\n**Discord:** %s\n**IP:** %s\n\n**Report Text:** %s")
        :format(name, playerId, discord, ip, reportText)

    sendToDiscord("📥 New Report Submitted", description, 3066993)

    for _, id in ipairs(GetPlayers()) do
        if IsPlayerAdmin(id) then
            TriggerClientEvent('cfx-mxds-reports:notify', id, "🆕 New player report received! Use /reports to check.", "inform")
        end
    end
end

RegisterCommand("report", function(source, args, rawCommand)
    TriggerClientEvent('cfx-mxds-reports:openSubmitMenu', source)
end, false)

local allowedRoles = {
    'REPLACEME',
    'REPLACEME',
}

function IsPlayerAdmin(playerId)
    local discordID = exports['cfx-mxds-reports']:GetDiscordID(playerId)
    if not discordID then return false end

    for _, role in pairs(allowedRoles) do
        if exports['cfx-mxds-reports']:UserHasRole(playerId, role) then
            return true
        end
    end

    return false
end



lib.callback.register('cfx-mxds-reports:getReports', function(source)
    if IsPlayerAdmin(source) then
        return reports
    end
    return {}
end)

RegisterNetEvent('cfx-mxds-reports:submit')
AddEventHandler('cfx-mxds-reports:submit', function(reportText)
    local playerId = source
    submitReport(playerId, reportText)
end)

RegisterNetEvent('cfx-mxds-reports:teleportToPlayer')
AddEventHandler('cfx-mxds-reports:teleportToPlayer', function(targetId)
    local src = source
    if not IsPlayerAdmin(src) then
    TriggerClientEvent('ox_lib:notify', src, {
        title = "Permission Denied",
        description = "You are not authorized to use this command.",
        type = "error"
    }) return end

    local ped = GetPlayerPed(targetId)
    if not ped then
        TriggerClientEvent('cfx-mxds-reports:notify', src, "Target player not found.")
        return
    end

    local coords = GetEntityCoords(ped)
    TriggerClientEvent('cfx-mxds-reports:teleportClient', src, coords)
end)

RegisterNetEvent('cfx-mxds-reports:close')
AddEventHandler('cfx-mxds-reports:close', function(reportId)
    local src = source
    if not IsPlayerAdmin(src) then
    TriggerClientEvent('ox_lib:notify', src, {
        title = "Permission Denied",
        description = "You are not authorized to use this command.",
        type = "error"
    }) return end

    for i, report in ipairs(reports) do
        if report.id == reportId then
            local reporterName = GetPlayerName(report.playerId)
            local reporterIdentifiers = GetPlayerIdentifiers(report.playerId)
            local adminName = GetPlayerName(src)
            local adminIdentifiers = GetPlayerIdentifiers(src)

            local reporterDiscord, reporterIP = "N/A", "N/A"
            local adminDiscord, adminIP = "N/A", "N/A"

            for _, id in ipairs(reporterIdentifiers) do
                if id:find("discord:") then
                    reporterDiscord = "<@" .. id:gsub("discord:", "") .. ">"
                elseif id:find("ip:") then
                    reporterIP = "||" .. id:gsub("ip:", "") .. "||"
                end
            end

            for _, id in ipairs(adminIdentifiers) do
                if id:find("discord:") then
                    adminDiscord = "<@" .. id:gsub("discord:", "") .. ">"
                elseif id:find("ip:") then
                    adminIP = "||" .. id:gsub("ip:", "") .. "||"
                end
            end

            local description = ("**Name of Reporter:** %s\n**Server ID:** %s\n**Discord:** %s\n**IP:** %s\n\n**Closed By:** %s\n**Admin ID:** %s\n**Discord:** %s\n**IP:** %s\n\n**Report Text:** %s")
                :format(reporterName, report.playerId, reporterDiscord, reporterIP, adminName, src, adminDiscord, adminIP, report.text)

            sendToDiscord("✅ Report Closed", description, 15105570)

            table.remove(reports, i)
            TriggerClientEvent('cfx-mxds-reports:notify', src, "✅ Report ID " .. reportId .. " has been closed and removed.", "success")
            return
        end
    end

    TriggerClientEvent('cfx-mxds-reports:notify', src, "❌ Report ID not found.", "error")
end)


lib.callback.register('cfx-mxds-reports:isAdmin', function(source)
    return IsPlayerAdmin(source)
end)
