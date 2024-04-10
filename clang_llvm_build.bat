@echo off
REM 声明采用 UTF-8 编码
chcp 65001

setlocal enabledelayedexpansion

goto :begin

:usage
echo Script for building the LLVM installer on Windows,
echo used for the releases at https://github.com/llvm/llvm-project/releases
echo.
echo Usage: build.bat --version ^<version^> [--c] [--f] [--b]
echo.
echo Options:
echo --version: [required] version to build
echo --help: display this help
echo --c: clean build cache
echo --f: config the build procedure, must set version too.
echo --b: build the llvm
echo.
echo Note: At least one variant to build is required, if only version setted then clean,config and build will execute in ordered. 
echo.
echo Example: build.bat --version 15.0.0
exit /b 1

:begin
::==============================================================================
:: parse args
set version=
set c=
set f=
set b=
call :parse_args %*

if "%help%" NEQ "" goto usage

if "%c%"=="true" call :do_clean || exit /b 1
if "%f%"=="true" call :do_configure || exit /b 1
if "%b%"=="true" call :do_build || exit /b 1
if "%c%"=="" if "%f%"=="" if "%b%"=="" if not "%version%" == ""  (
    call :do_clean || exit /b 1
    call :do_configure || exit /b 1
    call :do_build || exit /b 1
)
exit /b 0

:do_clean
@echo on
rmdir /S /Q build
@echo off
exit /b 0


:do_configure
if "%version%" == "" (
    echo --version option is required
    echo =============================
    goto usage
)
REM 调用 vcvarsall.bat 来设置环境变量
call "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" amd64 || exit /b 1
@echo on
:: generate tarball with install toolchain only off
set filename=clang+llvm-%version%-x86_64-pc-windows-msvc
    @REM -DLLVM_ENABLE_RUNTIMES="all"^

set cmake_flags=-DCMAKE_INSTALL_PREFIX="D:/Program Files/llvm/%filename%"^
    -DCMAKE_C_COMPILER=cl.exe^
    -DCMAKE_CXX_COMPILER=cl.exe^
    -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;compiler-rt;libc;lld;lldb;mlir;openmp;"^
    -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE^
    -DCMAKE_C_FLAGS="/utf-8"^
    -DCMAKE_CXX_FLAGS="/utf-8"^
    -DLLVM_TARGETS_TO_BUILD=X86^
    -DLLVM_HOST_TRIPLE=x86_64-pc-windows-msvc^
    -DLLVM_ENABLE_LLD=On^
    -DLLVM_ENABLE_LTO=On^
    -DLLVM_ENABLE_EH=On^
    -DLLVM_ENABLE_RTTI=On^
    -DLLVM_INCLUDE_TESTS=On^
    -DLIBCXXABI_USE_LLVM_UNWINDER=Off^
    -DLLVM_PARALLEL_COMPILE_JOBS=12^
    -DLLVM_PARALLEL_LINK_JOBS=6^
    -DCMAKE_BUILD_TYPE=Release^
    -G Ninja^
    -S llvm^
    -B build

@REM @REM  -DCMAKE_C_COMPILER="C:/Program Files/Microsoft Visual Studio/2022/Professional/VC/Tools/MSVC/14.39.33519/bin/HostX64/x64/cl.exe"^
@REM @REM  -DCMAKE_CXX_COMPILER="C:/Program Files/Microsoft Visual Studio/2022/Professional/VC/Tools/MSVC/14.39.33519/bin/HostX64/x64/cl.exe"^
echo 开始配置...
cmake %cmake_flags%

echo 复制compile_commands.json到.vscode目录...
copy build\compile_commands.json .vscode\
@echo off

:do_build
REM 调用 vcvarsall.bat 来设置环境变量
call "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" amd64 || exit /b 1
@echo on
echo 开始构建...
cmake --build build

echo 构建完成。
@echo off
exit /b 0

::=============================================================================
:: Parse command line arguments.
:: The format for the arguments is:
::   Boolean: --option
::   Value:   --option<separator>value
::     with <separator> being: space, colon, semicolon or equal sign
::
:: Command line usage example:
::   my-batch-file.bat --build --type=release --version 123
:: It will create 3 variables:
::   'build' with the value 'true'
::   'type' with the value 'release'
::   'version' with the value '123'
::
:: Usage:
::   set "build="
::   set "type="
::   set "version="
::
::   REM Parse arguments.
::   call :parse_args %*
::
::   if defined build (
::     ...
::   )
::   if %type%=='release' (
::     ...
::   )
::   if %version%=='123' (
::     ...
::   )
::=============================================================================
:parse_args
  set "arg_name="
  :parse_args_start
  if "%1" == "" (
    :: Set a seen boolean argument.
    if "%arg_name%" neq "" (
      set "%arg_name%=true"
    )
    goto :parse_args_done
  )
  set aux=%1
  if "%aux:~0,2%" == "--" (
    :: Set a seen boolean argument.
    if "%arg_name%" neq "" (
      set "%arg_name%=true"
    )
    set "arg_name=%aux:~2,250%"
  ) else (
    set "%arg_name%=%1"
    set "arg_name="
  )
  shift
  goto :parse_args_start

:parse_args_done
exit /b 0
