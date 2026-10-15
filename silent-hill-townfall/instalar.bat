@echo off
setlocal
title Silent Hill Townfall - instalar otimizacao

set "CFGDIR=%LOCALAPPDATA%\Townfall\Saved\Config\Windows"
set "CFG=%CFGDIR%\Engine.ini"
set "BACKUP=%CFGDIR%\Engine.ini.backup-otimizacao"
set "SEMORIGINAL=TOWNFALL-SEM-ENGINE-INI-ORIGINAL"
set "TWEAKS=%~dp0Engine.ini"
set "FINDSTR=%SystemRoot%\System32\findstr.exe"
set "ATTRIB=%SystemRoot%\System32\attrib.exe"
set "MODO=%~1"
set "TROCADO="
set "ANTIGO="

echo.
echo  Silent Hill Townfall - instalar ajustes de desempenho
echo  =====================================================
if /I "%MODO%"=="teste" echo  MODO TESTE: inclui um ajuste visual exagerado de proposito.
echo  Feche o jogo antes de continuar.
echo.
pause

if not exist "%TWEAKS%" goto :sem_tweaks
if not exist "%CFGDIR%\" goto :sem_pasta
if /I "%TWEAKS%"=="%CFG%" goto :pasta_errada

if not exist "%BACKUP%" goto :sem_backup_ainda
rem Ja foi instalado antes. Se o Engine.ini ainda e o nosso (ou sumiu),
rem reconstroi a partir do original: rodar de novo nunca duplica nada.
if not exist "%CFG%" goto :restaurar_base
"%FINDSTR%" /C:"TOWNFALL-OTIMIZACAO" "%CFG%" >nul 2>&1
if not errorlevel 1 goto :restaurar_base

rem O Engine.ini atual nao e o que o pacote instalou (ex.: outro mod).
rem Ele vira o novo original. Primeiro copia, depois mexe no backup antigo.
set "TROCADO=1"
if exist "%BACKUP%.novo" "%ATTRIB%" -R "%BACKUP%.novo" >nul 2>&1
copy /Y "%CFG%" "%BACKUP%.novo" >nul || goto :erro_backup
"%ATTRIB%" -R "%BACKUP%" >nul 2>&1
"%FINDSTR%" /C:"%SEMORIGINAL%" "%BACKUP%" >nul 2>&1
if errorlevel 1 goto :rotacionar
rem O backup antigo so dizia que nao existia Engine.ini: pode substituir.
move /Y "%BACKUP%.novo" "%BACKUP%" >nul
if exist "%BACKUP%.novo" goto :erro_backup
goto :conferir_backup

:rotacionar
rem Guarda o backup antigo como .antigo1, .antigo2, ... sem sobrescrever.
set "N=1"
:achar_nome_antigo
if not exist "%BACKUP%.antigo%N%" goto :girar_backup
set /a N+=1
goto :achar_nome_antigo

:girar_backup
set "ANTIGO=%BACKUP%.antigo%N%"
move "%BACKUP%" "%ANTIGO%" >nul
if not exist "%BACKUP%" goto :mover_novo
set "ANTIGO="
goto :erro_backup

:mover_novo
move "%BACKUP%.novo" "%BACKUP%" >nul
if exist "%BACKUP%" goto :conferir_backup
rem Nao deu para trocar: devolve o backup antigo ao lugar dele.
move "%ANTIGO%" "%BACKUP%" >nul
set "ANTIGO="
goto :erro_backup

:sem_backup_ainda
if not exist "%CFG%" goto :backup_sem_original
"%FINDSTR%" /C:"TOWNFALL-OTIMIZACAO" "%CFG%" >nul 2>&1
if not errorlevel 1 goto :marcador_sem_backup
copy /Y "%CFG%" "%BACKUP%" >nul
goto :conferir_backup

:backup_sem_original
> "%BACKUP%" echo ; %SEMORIGINAL%

:conferir_backup
if not exist "%BACKUP%" goto :erro_backup

:restaurar_base
"%ATTRIB%" -R "%CFG%" >nul 2>&1
"%FINDSTR%" /C:"%SEMORIGINAL%" "%BACKUP%" >nul 2>&1
if errorlevel 1 goto :copiar_original
if exist "%CFG%" del /F /Q "%CFG%"
if exist "%CFG%" goto :erro_escrita
goto :aplicar

:copiar_original
copy /Y "%BACKUP%" "%CFG%" >nul || goto :erro_escrita
rem A copia herda o "somente leitura" do original; libera para escrever.
"%ATTRIB%" -R "%CFG%" >nul 2>&1

:aplicar
>> "%CFG%" echo.|| goto :erro_escrita
type "%TWEAKS%" >> "%CFG%" || goto :erro_escrita
if /I not "%MODO%"=="teste" goto :proteger
>> "%CFG%" echo.
>> "%CFG%" echo ; TOWNFALL-OTIMIZACAO-TESTE (inicio): rode o instalar.bat para tirar.
>> "%CFG%" echo [SystemSettings]
>> "%CFG%" echo r.Tonemapper.Sharpen=10
>> "%CFG%" echo ; TOWNFALL-OTIMIZACAO-TESTE (fim)

:proteger
rem Somente leitura: o jogo pode apagar linhas que ele nao conhece.
"%ATTRIB%" +R "%CFG%" >nul 2>&1

echo.
if defined TROCADO echo  Obs.: o Engine.ini atual era diferente do que o pacote tinha
if defined TROCADO echo  instalado, entao ele virou o novo original.
if defined ANTIGO echo  O backup anterior foi guardado em:
if defined ANTIGO echo       "%ANTIGO%"
if /I "%MODO%"=="teste" goto :msg_teste
echo  [OK] Ajustes instalados em:
echo       "%CFG%"
echo  Backup do original:
echo       "%BACKUP%"
echo.
echo  Pode abrir o jogo. Para desfazer, rode o desinstalar.bat.
goto :fim

:msg_teste
echo  [OK] Ajustes instalados COM o teste.
echo.
echo  1. Abra o jogo e entre em uma partida.
echo  2. Se a imagem estiver MUITO "crocante", com contornos marcados e
echo     chiado exagerado, o jogo esta lendo o arquivo.
echo     Se estiver normal, o jogo provavelmente ignora o Engine.ini.
echo  3. Feche o jogo e rode o instalar.bat para tirar o teste.
goto :fim

:sem_tweaks
echo  [ERRO] O arquivo Engine.ini precisa estar na mesma pasta deste script.
echo  Extraia TODOS os arquivos para uma pasta e rode de novo.
goto :fim

:sem_pasta
echo  [ERRO] Pasta de configuracao do jogo nao encontrada:
echo         "%CFGDIR%"
echo  Abra o jogo uma vez, espere chegar ao menu principal, feche
echo  e rode este script de novo.
goto :fim

:pasta_errada
echo  [ERRO] Nao coloque estes arquivos na pasta de configuracao do jogo.
echo  Deixe o pacote em outra pasta, por exemplo na Area de Trabalho,
echo  e rode o script de la.
goto :fim

:marcador_sem_backup
"%ATTRIB%" -R "%CFG%" >nul 2>&1
echo  [ERRO] O Engine.ini ja tem os ajustes, mas o backup sumiu.
echo  Para nao estragar nada, o conteudo do arquivo nao foi mexido.
echo  Abra o arquivo abaixo no Bloco de Notas e apague desde a linha
echo  "TOWNFALL-OTIMIZACAO (inicio)" ate a ULTIMA linha que tenha
echo  "TOWNFALL-OTIMIZACAO", incluindo essas linhas. Salve e rode de novo:
echo       "%CFG%"
goto :fim

:erro_backup
if exist "%BACKUP%.novo" del /F /Q "%BACKUP%.novo"
echo  [ERRO] Nao foi possivel criar o backup. Nada foi alterado.
echo  Feche o jogo e qualquer programa que use o Engine.ini e tente de novo.
goto :fim

:erro_escrita
rem Em caso de erro nenhum backup e apagado: so avisa onde eles estao.
echo  [ERRO] Nao foi possivel escrever em:
echo       "%CFG%"
echo  Nenhum backup foi apagado. O Engine.ini de antes esta guardado em:
echo       "%BACKUP%"
if defined ANTIGO echo  e o backup mais antigo em:
if defined ANTIGO echo       "%ANTIGO%"
echo  Feche o jogo e qualquer programa que use o Engine.ini e rode o
echo  instalar.bat de novo, ou rode o desinstalar.bat para desfazer.

:fim
echo.
pause
endlocal
