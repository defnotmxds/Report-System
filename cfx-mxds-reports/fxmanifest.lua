fx_version 'cerulean'
game 'gta5'

author 'M Developments'
description 'Advanced In-Game Report System with Discord Logging and Role Permissions'
version '1.0.0'

shared_script '@ox_lib/init.lua'

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/config.lua',
    'server/roles.lua',
    'server/server.lua'
}

lua54 'yes'

dependencies {
    'ox_lib'
}
