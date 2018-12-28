@echo off

rem 获取管理员权限
pushd "%~dp0" && Dism 1>nul 2>nul || mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 "%*"","","runas",1)(window.close) && Exit /B 1
rem 设置变量
color 1F
mode con cols=120
cls
setlocal EnableDelayedExpansion
set NSudo="%~dp0Bin\%PROCESSOR_ARCHITECTURE%\NSudo.exe"
set "Dism=Dism.exe /NoRestart /LogLevel:1"
set "ImageLanguage=zh-CN"
set "Mount=%~1"

rem 选择文件夹
if "%Mount%" equ "" call :SelectFolder
if "%Mount%" equ "" goto :Exit

for %%i in (
QuickAssist
OpenSSH.Client
) do call :RemoveCapability "%Mount%" "%%i"

for %%i in (
HyperV-Guest-Networking-SrIov-onecore-Package
Microsoft-Hyper-V-ClientEdition-Package
Microsoft-Windows-HyperV-Guest-Package
Microsoft-Windows-HyperV-Guest-WOW64-Package
HyperV-Compute-System-VmDirect-Package
HyperV-Feature-ApplicationGuard-Package
Microsoft-Hyper-V-Hypervisor-Package
Microsoft-Windows-PAW-Feature-Package
HyperV-VID-Package
Microsoft-Windows-HyperV-HypervisorPlatform-Package
Microsoft-Windows-HyperV-OptionalFeature-HypervisorPlatform-Package
Microsoft-Windows-OneCore-Containers-Opt-Package
) do call :RemoveComponent "%Mount%" "%%i"

call :ImportRegistry "%CD%\O.reg" "%Mount%"

pause
goto :Exit

:SelectFolder
set folder=mshta "javascript:var folder=new ActiveXObject('Shell.Application').BrowseForFolder(0,'选择挂载目录', 513, '');if(folder) new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(folder.Self.Path);window.close();"
for /f %%f in ('%folder%') do set "Mount=%%f"
goto :eof

rem 移除系统功能 [ %~1 : 镜像挂载路径, %~2 : 功能名称 ]
:RemoveCapability
for /f "tokens=4" %%f in ('%Dism% /English /Image:"%~1" /Get-Capabilities ^| findstr Capability ^| findstr /i "%~2"') do (
    echo.移除功能 [%%f]
    %Dism% /Image:"%~1" /Remove-Capability /CapabilityName:"%%f" /Quiet
)
goto :eof

rem 移除系统组件 [ %~1 : 镜像挂载路径, %~2 : 组件名称 ]
:RemoveComponent
setlocal
rem 处理隐藏组件
call :MountImageRegistry "%~1"
for /f "tokens=* delims=" %%f in ('reg query "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages" /f "%~2" ^| findstr /i "%~2"') do ( 
    %NSudo% reg add "%%f" /v Visibility /t REG_DWORD /d 1 /f
    %NSudo% reg add "%%f" /v DefVis /t REG_DWORD /d 2 /f
    %NSudo% reg delete "%%f\Owners" /f
)
call :UnMountImageRegistry

for /f "tokens=3 delims=: " %%f in ('%Dism% /English /Image:"%~1" /Get-Packages ^| findstr /i "%~2" ^| findstr /v %ImageLanguage%') do (
    echo.移除组件 [%%f]
    %Dism% /Image:"%~1" /Remove-Package /PackageName:"%%f" /Quiet
)
endlocal
goto :eof

rem 导入注册表 [ %~1 : 注册表路径 %~2 : 镜像挂载路径 ]
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
call :MountImageRegistry "%~2%
%NSudo% reg import "%TMP%\%~nx1" >nul 2>&1
call :UnMountImageRegistry
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
if exist "%~1" %NSudo% cmd.exe /c del /f /q "%~1"
goto :eof

:Exit
endlocal EnableDelayedExpansion
title 操作完成