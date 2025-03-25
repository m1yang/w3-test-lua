@echo off

call %~dp0env.bat

REM 检查是否提供了exe参数
if "%~1"=="" (
    echo 必需参数 exe 未提供
    exit /b 1
)

set exe=%~1

REM 根据exe参数的值调用不同的可执行文件
if /i "%exe%"=="run" (
    start %we%\bin\ydweconfig.exe %*
) else if /i "%exe%"=="open" (
    start %we%\KKWE.exe %*
) else (
    echo 未知的exe参数: %exe%
    exit /b 1
)