fx_version 'cerulean'
games { 'gta5' }

author 'ManiMods'
description 'Divingsystem for Standalone FiveM'
version '1.0.0'

lua54 'yes'

ui_page 'html/index.html'

files { 'html/index.html' }

client_scripts { 'client.lua' }

server_scripts { 'server.lua' }

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}
