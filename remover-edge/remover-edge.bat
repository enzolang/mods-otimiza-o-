@echo off
setlocal
title Remover o Microsoft Edge

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
