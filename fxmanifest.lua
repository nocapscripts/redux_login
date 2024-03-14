fx_version 'cerulean'
game 'gta5'
lua54 'yes'
ui_page "index.html"

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

files({
    "index.html",
    "script.js",
    "style.css",
    "logo.png"
})

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "sv_login.lua",
} 

client_script "cl_login.lua"