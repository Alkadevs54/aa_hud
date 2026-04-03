fx_version 'cerulean'
game 'gta5'

description 'HUD RolePlay'
author 'Alkadevs'
version '1.0.0'

ui_page 'ui/index.html'


files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    'new-postals.json' 
}

client_scripts {
    'client.lua'
}

server_script 'server.lua'

shared_scripts {
    '@es_extended/imports.lua'
}

dependencies {
    'es_extended',
    'esx_status'
}
