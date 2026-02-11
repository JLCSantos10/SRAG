@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo =============================
echo Atualizador de Boletim
echo =============================
echo.

set RSCRIPT_PATH=

REM -------------------------------------------------
REM 1) Tenta encontrar Rscript no PATH
REM -------------------------------------------------
echo Procurando Rscript no PATH...
where Rscript >nul 2>nul

if %errorlevel% equ 0 (
    for /f "delims=" %%i in ('where Rscript') do (
        set RSCRIPT_PATH=%%i
        goto :execute
    )
)

REM -------------------------------------------------
REM 2) Procura em Program Files
REM -------------------------------------------------
echo Rscript nao encontrado no PATH.
echo Procurando em Program Files...

for /d %%D in ("C:\Program Files\R\R-*") do (
    if exist "%%D\bin\x64\Rscript.exe" (
        set RSCRIPT_PATH=%%D\bin\x64\Rscript.exe
    )
)

REM -------------------------------------------------
REM 3) Procura em AppData (instalacao por usuario)
REM -------------------------------------------------
if not defined RSCRIPT_PATH (
    echo Procurando em AppData...
    for /d %%D in ("%LOCALAPPDATA%\Programs\R\R-*") do (
        if exist "%%D\bin\Rscript.exe" (
            set RSCRIPT_PATH=%%D\bin\Rscript.exe
        )
    )
)

REM -------------------------------------------------
REM 4) Se nao encontrou
REM -------------------------------------------------
if not defined RSCRIPT_PATH (
    echo.
    echo ERRO: R nao encontrado no sistema.
    echo Verifique se o R esta instalado corretamente.
    pause
    exit /b 1
)

REM -------------------------------------------------
REM EXECUCAO
REM -------------------------------------------------
:execute
echo.
echo Rscript encontrado em:
echo %RSCRIPT_PATH%
echo.
echo Executando render_boletim.R...
echo.

"%RSCRIPT_PATH%" render_boletim.R

echo.
echo Processo finalizado.
pause
endlocal
