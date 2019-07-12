@echo off
color 1F
mode con lines=30 cols=90
rem 初始化变量
set "Oscdimg=%~sdp0Bin\%PROCESSOR_ARCHITECTURE%\oscdimg.exe"
set "DVD=%~1"
set "ISOLabel=%~2"
set "ISOFileName=%~3"
rem 选择光盘镜像目录
if "%DVD%" equ "" call :SelectFolder
set "BIOSBoot=%DVD%\boot\etfsboot.com"
set "UEFIBoot=%DVD%\efi\microsoft\boot\efisys.bin"
rem 自动生成卷标
call :MakeLabel %DVD%
if "%ISOFileName%" equ "" ( set "ISOFileName=%~dp0%ISOLabel%.iso" )
rem 生成ei.cfg
if exist "%DVD%\sources\ei.cfg" del /f /q "%DVD%\sources\ei.cfg"
if exist "%DVD%\sources" (
    echo.[EditionID]
    echo.
    echo.[Channel]
    echo.OEM
    echo.[VL]
    echo.1
)>"%DVD%\sources\ei.cfg"
rem 判断UEFI引导
if exist "%UEFIBoot%" (
   "%Oscdimg%" -bootdata:2#p0,e,b"%BIOSBoot%"#pEF,e,b"%UEFIBoot%" -o -h -m -u2 -l"%ISOLabel%" "%DVD%" "%ISOFileName%"
) else if exist "%BIOSBoot%" (
   "%Oscdimg%" -bootdata:1#p0,e,b"%BIOSBoot%" -o -h -m -u2 -l"%ISOLabel%" "%DVD%" "%ISOFileName%"
) else (
   "%Oscdimg%" -o -h -m -u2 -l"%ISOLabel%" "%DVD%" "%ISOFileName%"
)
goto :Exit

:SelectFolder
set folder=mshta "javascript:var folder=new ActiveXObject('Shell.Application').BrowseForFolder(0,'选择安装镜像所在目录', 513, '');if(folder) new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(folder.Self.Path);window.close();"
for /f "tokens=* delims=" %%f in ('%folder%') do set "DVD=%%f"
if "%DVD%" equ "" goto :Exit
goto :eof

:MakeLabel
if "%ISOLabel%" equ "" ( set "ISOLabel=%~n1" )
goto :eof

:Exit
if "%~1" equ "" pause