@echo off

call %~dp0env.bat

REM 检查是否提供了编译方式
if "%~1"=="" (
    echo 编译方式
    exit /b 1
)

REM 调用可执行文件并传递参数
if /i "%exe%"=="log" (
    start %w3x2lni%/log/report.log
) else (
    %w3x2lni%\w2l.exe %*
)