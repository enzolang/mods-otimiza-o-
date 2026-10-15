@echo off
setlocal
title Silent Hill Townfall - desfazer otimizacao

set "CFGDIR=%LOCALAPPDATA%\Townfall\Saved\Config\Windows"
set "CFG=%CFGDIR%\Engine.ini"
set "BACKUP=%CFGDIR%\Engine.ini.backup-otimizacao"
set "SEMORIGINAL=TOWNFALL-SEM-ENGINE-INI-ORIGINAL"
set "FINDSTR=%SystemRoot%\System32\findstr.exe"
set "ATTRIB=%SystemRoot%\System32\attrib.exe"

echo.
echo  Silent Hill Townfall - desfazer ajustes de desempenho
echo  =====================================================
echo  Feche o jogo antes de continuar.
echo.
pause

if not exist "%BACKUP%" goto :sem_backup

rem Se o Engine.ini atual nao e o nosso (foi trocado depois), nao mexe nele.
if not exist "%CFG%" goto :cfg_ok
"%FINDSTR%" /C:"TOWNFALL-OTIMIZACAO" "%CFG%" >nul 2>&1
if errorlevel 1 goto :cfg_trocado

:cfg_ok
"%ATTRIB%" -R "%CFG%" >nul 2>&1
"%FINDSTR%" /C:"%SEMORIGINAL%" "%BACKUP%" >nul 2>&1
if errorlevel 1 goto :restaurar

rem Antes da otimizacao nao existia Engine.ini: basta apagar o nosso.
if exist "%CFG%" del /F /Q "%CFG%"
if exist "%CFG%" goto :erro
goto :limpar

:restaurar
copy /Y "%BACKUP%" "%CFG%" >nul || goto :erro

:limpar
del /F /Q "%BACKUP%"
echo.
echo  [OK] Tudo voltou a ser como era antes da otimizacao.
goto :fim

:cfg_trocado
rem Se o arquivo nao pode ser lido, nao da para saber se ele e o nosso.
type "%CFG%" >nul 2>&1 || goto :erro_leitura
echo  O Engine.ini atual nao tem os ajustes deste pacote (por exemplo,
echo  foi trocado por outro), entao ele foi mantido como esta.
"%FINDSTR%" /C:"%SEMORIGINAL%" "%BACKUP%" >nul 2>&1
if errorlevel 1 goto :cfg_trocado_com_original
rem Antes da instalacao nao existia Engine.ini: o backup e so um marcador.
del /F /Q "%BACKUP%"
echo  Antes da instalacao nao existia Engine.ini, entao nao ha mais nada
echo  para desfazer.
goto :fim

:cfg_trocado_com_original
echo  O Engine.ini de antes da instalacao continua guardado em:
echo       "%BACKUP%"
goto :fim

:sem_backup
echo  Nenhum backup encontrado em:
echo       "%BACKUP%"
echo  Para tirar os ajustes manualmente: clique com o botao direito no
echo  Engine.ini, Propriedades, desmarque "Somente leitura" e abra no Bloco
echo  de Notas. Apague desde a linha "TOWNFALL-OTIMIZACAO (inicio)" ate a
echo  ULTIMA linha que tenha "TOWNFALL-OTIMIZACAO", incluindo essas linhas.
goto :fim

:erro_leitura
echo  [ERRO] Nao foi possivel ler o Engine.ini. Nada foi alterado.
echo  Feche o jogo e qualquer programa que use o arquivo e tente de novo.
goto :fim

:erro
echo  [ERRO] Nao foi possivel restaurar. O backup continua em:
echo       "%BACKUP%"

:fim
echo.
pause
endlocal
