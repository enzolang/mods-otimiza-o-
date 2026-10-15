@echo off
setlocal
title Silent Hill 2 - desfazer otimizacao

set "CFGDIR=%LOCALAPPDATA%\SilentHill2\Saved\Config\Windows"
set "CFG=%CFGDIR%\Engine.ini"
set "BACKUP=%CFGDIR%\Engine.ini.backup-otimizacao"

echo.
echo  Silent Hill 2 - desfazer ajustes de desempenho
echo  ==============================================
echo  Feche o jogo antes de continuar.
echo.
pause

if not exist "%BACKUP%" goto :sem_backup

attrib -R "%CFG%" >nul 2>&1
copy /Y "%BACKUP%" "%CFG%" >nul
if errorlevel 1 goto :erro
del "%BACKUP%"

echo.
echo  [OK] Engine.ini original restaurado.
goto :fim

:sem_backup
echo  Nenhum backup encontrado em:
echo       %BACKUP%
echo  Se quiser remover os ajustes manualmente, abra o Engine.ini e apague
echo  tudo entre as linhas "SH2-OTIMIZACAO (inicio)" e "SH2-OTIMIZACAO (fim)".
goto :fim

:erro
echo  [ERRO] Nao foi possivel restaurar. O backup continua em:
echo       %BACKUP%

:fim
echo.
pause
endlocal
