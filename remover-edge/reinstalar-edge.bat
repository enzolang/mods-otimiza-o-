@echo off
setlocal
title Reinstalar o Microsoft Edge

rem Se foi aberto por um programa 32 bits, reabre no prompt de 64 bits.
if defined PROCESSOR_ARCHITEW6432 "%SystemRoot%\Sysnative\cmd.exe" /c ""%~f0" %*" & exit /b

rem Ja e administrador? Senao, pede permissao (janela do Windows: clique em Sim).
"%SystemRoot%\System32\fltmc.exe" >nul 2>&1 && goto :admin
if /i "%~1"=="/elevado" goto :sem_admin
set "SELF=%~f0"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SELF -ArgumentList '/elevado' -Verb RunAs"
if errorlevel 1 goto :recusado
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
if exist "%~dp0remover-edge.ps1" "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0remover-edge.ps1" -Recuperar

if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" goto :ja_instalado

where winget >nul 2>&1
if errorlevel 1 goto :sem_winget

echo  Baixando e instalando o Edge pelo winget (gerenciador oficial da
echo  Microsoft). Pode levar alguns minutos...
echo.
winget install --id Microsoft.Edge -e --source winget --accept-package-agreements --accept-source-agreements
if errorlevel 1 goto :falhou
echo.
echo  [OK] Pedido de instalacao concluido. Se o Edge nao aparecer no menu
echo  Iniciar, reinicie o PC.
goto :fim

:ja_instalado
echo  O Microsoft Edge ja esta instalado neste PC. Nada a fazer.
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
start "" "https://www.microsoft.com/edge/download"

:fim
echo.
pause
exit /b
