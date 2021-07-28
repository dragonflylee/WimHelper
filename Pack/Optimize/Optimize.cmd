@echo off

setlocal EnableDelayedExpansion
set "Dism=Dism /NoRestart /LogLevel:1"
call :ImportOptimize "C:"
rem call :RemoveAppx "C:"
goto :Exit

rem 移除自带应用 [ %~1 : 镜像挂载路径 ]
:RemoveAppx
for /f "tokens=3" %%f in ('%Dism% /English /Image:"%~1" /Get-ProvisionedAppxPackages ^| findstr PackageName ^| findstr /V WindowsStore') do (
    echo.移除应用 [%%f]
    %Dism% /Image:"%~1" /Remove-ProvisionedAppxPackage /PackageName:"%%f" /Quiet
)
goto :eof

rem 导入优化 [ %~1 : 镜像挂载路径 ]
:ImportOptimize
call :MountImageRegistry "%~1"
call :ImportRegistry "%~dp010.0.reg"
call :ImportRegistry "%~dp010.0.x64.reg"
call :ImportRegistry "%~dp0Context.reg"
call :UnMountImageRegistry
goto :eof

rem 导入注册表 [ %~1 : 注册表路径 ]
:ImportRegistry
if not exist "%~1" goto :eof
call :RemoveFile "%TMP%\%~nx1"
rem 处理注册表路径
for /f "delims=" %%f in ('type "%~1"') do (
    set str=%%f
    set "str=!str:HKEY_CURRENT_USER=HKEY_LOCAL_MACHINE\TK_NTUSER!"
    set "str=!str:HKEY_LOCAL_MACHINE\SOFTWARE=HKEY_LOCAL_MACHINE\TK_SOFTWARE!"
    set "str=!str:HKEY_LOCAL_MACHINE\SYSTEM=HKEY_LOCAL_MACHINE\TK_SYSTEM!"
    set "str=!str:CurrentControlSet=ControlSet001!"
    echo !str!>>"%TMP%\%~nx1"
)
reg import "%TMP%\%~nx1"
goto :eof

rem 加载注册表 [ %~1 : 镜像挂载路径 ]
:MountImageRegistry
reg load HKLM\TK_NTUSER "%~1\Users\Default\ntuser.dat" >nul
reg load HKLM\TK_SOFTWARE "%~1\Windows\System32\config\SOFTWARE" >nul
reg load HKLM\TK_SYSTEM "%~1\Windows\System32\config\SYSTEM" >nul
goto :eof

rem 卸载注册表
:UnMountImageRegistry
reg unload HKLM\TK_NTUSER >nul 2>&1
reg unload HKLM\TK_SOFTWARE >nul 2>&1
reg unload HKLM\TK_SYSTEM >nul 2>&1
goto :eof

rem 删除文件 [ %~1 : 文件路径 ]
:RemoveFile
if exist "%~1" cmd.exe /c del /f /q "%~1"
goto :eof

rem 删除目录 [ %~1 : 目录路径 ]
:RemoveFolder
if exist "%~1" cmd.exe /c rd /q /s "%~1"
goto :eof

:Exit
endlocal EnableDelayedExpansion
title 操作完成