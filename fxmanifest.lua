fx_version 'cerulean'
game 'gta5'

author 'FMDR'
description 'FMDR Admin Menu - Complete ESX Admin System'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html'
}

dependencies {
    'es_extended',
    'oxmysql'
}