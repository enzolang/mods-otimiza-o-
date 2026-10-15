@echo off
setlocal
title Silent Hill 2 - instalar otimizacao

set "CFGDIR=%LOCALAPPDATA%\SilentHill2\Saved\Config\Windows"
set "CFG=%CFGDIR%\Engine.ini"
set "BACKUP=%CFGDIR%\Engine.ini.backup-otimizacao"
set "TWEAKS=%~dp0Engine.ini"

echo.
echo  Silent Hill 2 - instalar ajustes de desempenho
echo  ==============================================
echo  Feche o jogo antes de continuar.
echo.
pause

if not exist "%TWEAKS%" goto :sem_tweaks
if not exist "%CFGDIR%\" goto :sem_pasta

if not exist "%CFG%" goto :fazer_backup
findstr /C:"SH2-OTIMIZACAO" "%CFG%" >nul 2>&1
if not errorlevel 1 goto :ja_instalado

:fazer_backup
if exist "%BACKUP%" goto :aplicar
if exist "%CFG%" (
    copy /Y "%CFG%" "%BACKUP%" >nul
) else (
    > "%BACKUP%" echo ; Engine.ini nao existia antes da otimizacao
)
if not exist "%BACKUP%" goto :erro_backup

:aplicar
attrib -R "%CFG%" >nul 2>&1
>> "%CFG%" echo.
type "%TWEAKS%" >> "%CFG%"
if errorlevel 1 goto :erro_escrita

echo.
echo  [OK] Ajustes instalados em:
echo       %CFG%
echo  Backup do arquivo original:
echo       %BACKUP%
echo.
echo  Abra o jogo normalmente. Para desfazer, rode desinstalar.bat.
goto :fim

:sem_tweaks
echo  [ERRO] O arquivo Engine.ini precisa estar na mesma pasta deste script.
goto :fim

:sem_pasta
echo  [ERRO] Pasta de configuracao do jogo nao encontrada:
echo         %CFGDIR%
echo  Abra o jogo uma vez, espere chegar ao menu principal, feche
echo  e rode este script de novo.
goto :fim

:ja_instalado
echo  Os ajustes ja estao instalados. Nada foi alterado.
echo  Para reinstalar, rode desinstalar.bat primeiro.
goto :fim

:erro_backup
echo  [ERRO] Nao foi possivel criar o backup. Nada foi alterado.
goto :fim

:erro_escrita
echo  [ERRO] Nao foi possivel escrever em %CFG%
echo  O backup continua em %BACKUP%

:fim
echo.
pause
endlocal
