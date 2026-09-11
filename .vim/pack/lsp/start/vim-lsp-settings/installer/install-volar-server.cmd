@echo off

call "%~dp0\npm_install.cmd" vue-language-server @vue/language-server@3
ren vue-language-server.cmd volar-server.cmd
call npm install typescript@5.8.3
