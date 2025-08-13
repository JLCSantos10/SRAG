@echo off
cd /d "%~dp0"

REM Tenta encontrar o Rscript no sistema
set RSCRIPT_PATH=

REM Verifica se existe no PATH
where Rscript >nul 2>&1
if %errorlevel% equ 0 (
    set RSCRIPT_PATH=Rscript
    goto :execute
)

REM Verifica caminhos comuns de instalação do R
if exist "C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" (
    set RSCRIPT_PATH="C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe"
    goto :execute
)

if exist "C:\Program Files\R\R-4.4\bin\x64\Rscript.exe" (
    set RSCRIPT_PATH="C:\Program Files\R\R-4.4\bin\x64\Rscript.exe"
    goto :execute
)

if exist "C:\Program Files\R\R-4.3\bin\x64\Rscript.exe" (
    set RSCRIPT_PATH="C:\Program Files\R\R-4.3\bin\x64\Rscript.exe"
    goto :execute
)

if exist "C:\Program Files\R\R-4.2\bin\x64\Rscript.exe" (
    set RSCRIPT_PATH="C:\Program Files\R\R-4.2\bin\x64\Rscript.exe"
    goto :execute
)

if exist "C:\Program Files\R\R-4.1\bin\x64\Rscript.exe" (
    set RSCRIPT_PATH="C:\Program Files\R\R-4.1\bin\x64\Rscript.exe"
    goto :execute
)

if exist "C:\Program Files\R\R-4.0\bin\x64\Rscript.exe" (
    set RSCRIPT_PATH="C:\Program Files\R\R-4.0\bin\x64\Rscript.exe"
    goto :execute
)

REM Se não encontrou, mostra erro
echo ERRO: Nao foi possivel encontrar o Rscript.exe
echo Verifique se o R esta instalado no sistema
pause
exit /b 1

:execute
echo Executando com: %RSCRIPT_PATH%
%RSCRIPT_PATH% render_boletim.R
pause
