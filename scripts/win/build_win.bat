@echo off
setlocal
set QT_DIR=%1
set CONFIG=Release

if "%QT_DIR%"=="" (
  echo 用法: build_win.bat ^<Qt目录^>  例如: build_win.bat C:\Qt\6.7.2\msvc2022_64
  exit /b 1
)

if not exist build mkdir build
cmake -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="%QT_DIR%" -DCMAKE_BUILD_TYPE=%CONFIG% -B build -S .
if errorlevel 1 exit /b 1
cmake --build build --config %CONFIG% -j
if errorlevel 1 exit /b 1

set DEPLOYDIR=dist\QuickCut
if exist dist rmdir /s /q dist
mkdir %DEPLOYDIR%
copy build\%CONFIG%\quickcut.exe %DEPLOYDIR% >nul

"%QT_DIR%\bin\windeployqt.exe" --release --compiler-runtime %DEPLOYDIR%\quickcut.exe
echo 便携版位于 dist\QuickCut 目录。可手动放入 ffmpeg.exe/ffprobe.exe 后直接运行。
endlocal