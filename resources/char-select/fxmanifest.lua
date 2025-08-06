fx_version 'cerulean'
game 'gta5'

author 'Keegan'
description 'basic character selection for the demo'
version '0.1.0' -- need to implement character selection and customization before 1.0

client_script 'client/cl_main.lua'

server_script 'server/sv_main.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/script.js',
    'html/styles.css'
}
