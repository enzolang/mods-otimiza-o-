@echo off
setlocal
title Reinstalar o Microsoft Edge

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
echo.
echo  Reinstalar o Microsoft Edge
echo  ===========================
echo.

rem Desfaz restos de uma remocao interrompida, se houver.
if not exist "%~dp0remover-edge.ps1" goto :verifica
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0remover-edge.ps1" -Recuperar
if errorlevel 3 goto :outra_janela
if errorlevel 1 echo  Aviso: restos de uma remocao anterior nao puderam ser desfeitos. Depois, reinicie o PC, rode o remover-edge.bat e digite N.

:verifica

if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" goto :ja_instalado

where winget >nul 2>&1
if errorlevel 1 goto :sem_winget

echo  Baixando e instalando o Edge pelo winget (gerenciador oficial da
echo  Microsoft). Pode levar alguns minutos...
echo.
winget install --id Microsoft.Edge -e --source winget --accept-package-agreements --accept-source-agreements
rem Os codigos de erro do winget sao negativos; por isso a conferencia
rem e feita pelo arquivo do Edge, e nao pelo codigo de saida.
if not exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" goto :falhou
echo.
echo  [OK] O Microsoft Edge foi instalado. Se ele nao aparecer no menu
echo  Iniciar, reinicie o PC.
goto :fim

:ja_instalado
echo  O Microsoft Edge ja esta instalado neste PC. Nada a fazer.
goto :fim

:outra_janela
echo.
echo  O remover-edge esta aberto em outra janela. Feche aquela janela
echo  e rode o reinstalar-edge.bat de novo.
goto :fim

:sem_winget
echo  O winget nao foi encontrado neste PC.
goto :site

:falhou
echo.
echo  O winget nao conseguiu instalar o Edge.

:site
echo  Vou abrir a pagina oficial de download do Edge no seu navegador.
echo  Baixe e rode o instalador por la.
rem Abre pelo Explorer para o navegador NAO rodar como administrador.
"%SystemRoot%\explorer.exe" "https://www.microsoft.com/edge/download"

:fim
echo.
pause
exit /b
