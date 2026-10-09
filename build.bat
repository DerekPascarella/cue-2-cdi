@echo off
setlocal enabledelayedexpansion

REM Read version from version.txt
set /p VERSION=<version.txt
set PROJECT=cue-2-cdi.csproj

echo Building version: %VERSION%
echo.

REM Format code
dotnet format %PROJECT%
if %ERRORLEVEL% neq 0 goto :error
echo.

REM Clean previous builds
if exist "_releases" rd /s /q "_releases"
mkdir "_releases"

REM Build a self-contained, single-file binary for each target, then zip it
for %%R in (win-x64 win-x86 linux-x64 osx-x64 osx-arm64) do (
    echo.
    echo Building for %%R...
    dotnet publish %PROJECT% -c Release -r %%R --self-contained true -p:PublishSingleFile=true -p:EnableCompressionInSingleFile=true -p:PublishTrimmed=true -p:InvariantGlobalization=true -p:UseSystemResourceKeys=true -p:DebugType=none -p:DebugSymbols=false -p:Version=%VERSION% -o "_releases\%%R"
    if !ERRORLEVEL! neq 0 goto :error

    REM Keep only the standalone binary in the architecture folder
    del /q "_releases\%%R\*.pdb" >nul 2>&1

    REM Zip just the binary, with no nested folder, named after the architecture
    pushd "_releases\%%R"
    tar -a -c -f "..\cue-2-cdi-%%R.zip" *
    set ZIPRC=!ERRORLEVEL!
    popd
    if !ZIPRC! neq 0 echo Warning: failed to create _releases\%%R.zip
)

REM Remove intermediate build output
if exist obj rd /s /q obj
if exist bin rd /s /q bin

echo.
echo All builds completed successfully.
exit /b 0

:error
echo.
echo Build failed. See errors above.
exit /b 1
