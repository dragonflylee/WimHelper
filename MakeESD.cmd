@echo off

rem 获取管理员权限
pushd "%~dp0" && Dism 1>nul 2>nul || mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 "%*"","","runas",1)(window.close) && Exit /B 1

for %%i in (*.wim) do Dism /Export-Image /SourceImageFile:"%%i" /All /DestinationImageFile:"%%~ni.esd" /Compress:recovery
rem shutdown -s -t 0