@echo off
setlocal EnableExtensions

rem Build llama-server with the same MSVC/CUDA/Ninja configuration used for
rem the working spotcobuild_9_18_2026 build.
cd /d "%~dp0"

set "VSDEV=C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\Common7\Tools\VsDevCmd.bat"
set "CMAKE=C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
set "CUDA_PATH=E:\cuda-toolkit-12.4"
set "BUILD_DIR=%~dp0build-cuda"

if exist "%VSDEV%" goto vsdev_exists
echo ERROR: Visual Studio developer command file not found:
echo        %VSDEV%
exit /b 1

:vsdev_exists
if exist "%CMAKE%" goto cmake_exists
echo ERROR: CMake not found:
echo        %CMAKE%
exit /b 1

:cmake_exists
if exist "%CUDA_PATH%\bin\nvcc.exe" goto cuda_exists
echo ERROR: CUDA compiler not found:
echo        %CUDA_PATH%\bin\nvcc.exe
exit /b 1

:cuda_exists

call "%VSDEV%" -arch=x64
if not errorlevel 1 goto dev_environment_ready
echo ERROR: failed to initialize the Visual Studio x64 build environment.
exit /b 1

:dev_environment_ready
set "PATH=%CUDA_PATH%\bin;%PATH%"

echo.
echo === Configuring llama.cpp ===
"%CMAKE%" -S "%~dp0." -B "%BUILD_DIR%" -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DGGML_CUDA=ON ^
  -DCMAKE_CUDA_COMPILER="%CUDA_PATH%\bin\nvcc.exe" ^
  -DCMAKE_CUDA_ARCHITECTURES=89 ^
  -DCMAKE_CUDA_FLAGS="-allow-unsupported-compiler" ^
  -DLLAMA_BUILD_SERVER=ON
if not errorlevel 1 goto configure_succeeded
echo ERROR: CMake configuration failed.
exit /b 1

:configure_succeeded
echo.
echo === Building llama-server ===
"%CMAKE%" --build "%BUILD_DIR%" --target llama-server --parallel 8
if not errorlevel 1 goto build_succeeded
echo ERROR: llama-server build failed.
exit /b 1

:build_succeeded
echo.
echo Build complete:
echo   %BUILD_DIR%\bin\llama-server.exe
exit /b 0
