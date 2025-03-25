@echo off

call %~dp0env.bat

REM 根据exe参数的值调用不同的可执行文件
if "%~1"=="" (
    start %we%\bin\ydweconfig.exe
) else if /i "%~1"=="-launchwar3" (
    start %we%\bin\ydweconfig.exe %*
) else if /i "%~1"=="-loadfile" (
    start %we%\KKWE.exe %*
) else (
    echo 未知的exe参数: %*
    exit /b 1
)