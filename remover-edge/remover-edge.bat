@echo off
setlocal
title Remover o Microsoft Edge

rem Se foi aberto por um programa 32 bits, reabre no prompt de 64 bits.
if defined PROCESSOR_ARCHITEW6432 goto :relanca64

rem Ja e administrador? Senao, pede permissao (janela do Windows: clique em Sim).
"%SystemRoot%\System32\fltmc.exe" >nul 2>&1 && goto :admin
if /i "%~1"=="/elevado" goto :sem_admin
set "SELF=%~f0"
rem Reabre este arquivo como administrador. O caminho vai entre aspas
rem duplas mesmo se a pasta tiver espacos, parenteses ou "&".
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "$q=[char]34; Start-Process -FilePath ($env:SystemRoot + '\System32\cmd.exe') -ArgumentList ('/s /c ' + $q + $q + $env:SELF + $q + ' /elevado' + $q) -Verb RunAs"
if errorlevel 1 goto :recusado
exit /b

:relanca64
set "SELF=%~f0"
setlocal EnableDelayedExpansion
"%SystemRoot%\Sysnative\cmd.exe" /s /c ""!SELF!" %*"
exit /b

:recusado
echo.
echo  A permissao de administrador foi recusada. Nada foi alterado.
echo.
pause
exit /b 1

:sem_admin
echo.
echo  Nao foi possivel obter permissao de administrador. Nada foi alterado.
echo.
pause
exit /b 1

:admin
if not exist "%~dp0remover-edge.ps1" goto :sem_ps1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0remover-edge.ps1"
echo.
pause
exit /b

:sem_ps1
echo.
echo  [ERRO] O arquivo remover-edge.ps1 precisa estar na mesma pasta deste
echo  script. Extraia TODOS os arquivos para uma pasta e rode de novo.
echo.
pause
exit /b 1
