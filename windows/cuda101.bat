@echo off

IF NOT "%BUILD_VISION%" == "" (
    set MODULE_NAME=vision
) ELSE (
    set MODULE_NAME=pytorch
)

IF NOT EXIST "setup.py" IF NOT EXIST "%MODULE_NAME%" (
    call internal\clone.bat
    cd ..
    IF ERRORLEVEL 1 goto eof
) ELSE (
    call internal\clean.bat
)

call internal\check_deps.bat
IF ERRORLEVEL 1 goto eof

REM Check for optional components

set USE_CUDA=
set CMAKE_GENERATOR=Visual Studio 15 2017 Win64

IF "%NVTOOLSEXT_PATH%"=="" (
    IF EXIST "C:\Program Files\NVIDIA Corporation\NvToolsExt\lib\x64\nvToolsExt64_1.lib"  (
        set NVTOOLSEXT_PATH=C:\Program Files\NVIDIA Corporation\NvToolsExt
    ) ELSE (
        echo NVTX ^(Visual Studio Extension ^for CUDA^) ^not installed, failing
        exit /b 1
    )
)

IF "%CUDA_PATH_V10_1%"=="" (
    IF EXIST "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.1\bin\nvcc.exe" (
        set "CUDA_PATH_V10_1=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.1"
    ) ELSE (
        echo CUDA 10.1 not found, failing
        exit /b 1
    )
)

IF "%BUILD_VISION%" == "" (
    set TORCH_CUDA_ARCH_LIST=3.7+PTX;5.0;6.0;6.1;7.0;7.5
    set TORCH_NVCC_FLAGS=-Xfatbin -compress-all
) ELSE (
    set NVCC_FLAGS=-D__CUDA_NO_HALF_OPERATORS__ --expt-relaxed-constexpr -gencode=arch=compute_35,code=sm_35 -gencode=arch=compute_50,code=sm_50 -gencode=arch=compute_60,code=sm_60 -gencode=arch=compute_70,code=sm_70 -gencode=arch=compute_75,code=sm_75 -gencode=arch=compute_50,code=compute_50
)

set "CUDA_PATH=%CUDA_PATH_V10_1%"
set "PATH=%CUDA_PATH_V10_1%\bin;%PATH%"

:optcheck

IF "%BUILD_VISION%" == "" (
    call internal\check_opts.bat
    IF ERRORLEVEL 1 goto eof

    call internal\copy.bat
    IF ERRORLEVEL 1 goto eof
)

call internal\setup.bat
IF ERRORLEVEL 1 goto eof

:eof
