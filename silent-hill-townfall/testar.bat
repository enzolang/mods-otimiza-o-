@echo off
rem Instala os ajustes + um efeito visual exagerado, so para confirmar
rem que o jogo le o Engine.ini. Depois rode o instalar.bat para tirar.
if exist "%~dp0instalar.bat" goto :rodar
echo.
echo  [ERRO] O instalar.bat precisa estar na mesma pasta deste script.
echo  Extraia TODOS os arquivos para uma pasta e rode de novo.
echo.
pause
goto :eof

:rodar
"%~dp0instalar.bat" teste
