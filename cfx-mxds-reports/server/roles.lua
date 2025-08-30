local Config = require("server.config")  

function GetDiscordID(source)
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.find(id, "discord:") then
            return string.gsub(id, "discord:", "")
        end
    end
    return nil
end

exports("GetDiscordID", GetDiscordID)

function GetUserRoles(disID)
    local allroles = {}
    local prom = promise.new()

    for i = 1, #Config.GuildIDs do
        local p = promise.new()

        PerformHttpRequest(
            string.format("https://discord.com/api/v10/guilds/%s/members/%s", Config.GuildIDs[i], disID),
            function(err, data, headers)
                if err ~= 200 then
                    p:reject("Error: " .. tostring(err))
                    return
                end

                local decoded = json.decode(data)
                if decoded and decoded.roles then
                    p:resolve(decoded.roles)
                else
                    p:resolve({})
                end
            end,
            'GET',
            '',
            {
                Authorization = "Bot " .. Config.BotToken,
                ['Content-Type'] = 'application/json'
            }
        )

        local roles = Citizen.Await(p)
        for j = 1, #roles do
            table.insert(allroles, roles[j])
        end
    end

    prom:resolve(allroles)
    return Citizen.Await(prom)
end

function UserHasRole(disID, role)
    local data = GetUserRoles(disID)
    for i = 1, #data do
        if data[i] == tostring(role) then
            return true
        end
    end
    return false
end

exports("GetUserRoles", function(source)
    return GetUserRoles(GetDiscordID(source))
end)

exports("UserHasRole", function(source, role)
    return UserHasRole(GetDiscordID(source), role)
end)
