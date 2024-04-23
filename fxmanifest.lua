fx_version 'cerulean'
game 'gta5'
lua54 'yes'

ui_page 'html/index.html'

shared_scripts {
    '@rs_base/import.lua',
    '@ox_lib/init.lua',
    'config.lua',
}

files({
    'html/index.html',
    'html/script.js',
    'html/style.css',
    'html/logo.png'
})

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_login.lua',
    'spawnmanager/sv_spawn.lua',
    'init.lua'

} 

client_scripts {
    'client/cl_login.lua',
    'spawnmanager/cl_spawn.lua',
    'init.lua'
} 