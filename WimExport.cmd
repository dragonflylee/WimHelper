@echo off

rem 获取管理员权限
pushd "%~dp0" && Dism 1>nul 2>nul || mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 "%*"","","runas",1)(window.close) && Exit /B 1
rem 设置变量
color 1F
mode con cols=120
set "Dism=Dism.exe /NoRestart /LogLevel:1"
set "ESDPath=%~1"

if "%ESDPath%" equ "" call :SelectFolder
if "%ESDPath%" equ "" goto :Exit
rem call :ExportISO "E G", "%~dp0install.wim"
for %%i in (X64) do call :Export19H1 "%ESDPath%", "%~dp0DVD_%%i", "%%i"
goto :Exit

:SelectFolder
set folder=mshta "javascript:var folder=new ActiveXObject('Shell.Application').BrowseForFolder(0,'选择ESD镜像所在目录', 513, '');if(folder) new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(folder.Self.Path);window.close();"
for /f %%f in ('%folder%') do set "ESDPath=%%f"
goto :eof

rem 导出ISO镜像 [ %~1 : 盘符列表[空格分隔], %~2 : 目标路径 ]
:ExportISO
call :RemoveFile "%~2"
for %%i in (%~1) do call :ExportImage "%%i:\sources\install.wim", "%~2"
goto :eof

rem 导出RS2镜像 [ %~1 : 源路径, %~2 : 目标路径, %~3 处理器架构 ]
:ExportRS2
if not exist "%~1" echo [%~1] 不存在 && goto :eof
set "WimPath=%~dp0Win10_RS2_%~3_%date:~0,4%%date:~5,2%%date:~8,2%.wim"
call :RemoveFile "%WimPath%"
call :RemoveFolder "%~2"
rem 导出安装镜像
for %%i in (combinedchina enterprise) do (
    for %%j in ("%~1\*.rs2_release_*%%i*_%~3fre_*.esd") do (
        if not exist "%~2" call :ExportDVD "%%j", "%~2"
        call :ExportImage "%%j", "%WimPath%"
    )
)
if not exist "%WimPath%" goto :eof
call :MakeISO "%WimPath%", "%~2"
goto :eof

rem 导出19H1镜像 [ %~1 : 源路径, %~2 : 目标路径, %~3 处理器架构 ]
:Export19H1
if not exist "%~1" echo [%~1] 不存在 && goto :eof
set "WimPath=%~dp0install_19H1_%~3_%date:~0,4%%date:~5,2%%date:~8,2%.wim"
call :RemoveFile "%WimPath%"
call :RemoveFolder "%~2"
rem 导出安装镜像
for %%i in (china consumer business) do (
    for %%j in ("%~1\*.19h2_release_*%%i*_%~3fre_*.esd") do (
        if not exist "%~2" call :ExportDVD "%%j", "%~2"
        call :ExportImage "%%j", "%WimPath%"
    )
)
call :MakeISO "%WimPath%", "%~2"
goto :eof

rem 生成ISO [ %~1 : 源路径, %~2 : 目标路径 ]
:MakeISO
call "%~dp0WimHelper.cmd" "%~1"
rem 转换ESD镜像
%Dism% /Export-Image /SourceImageFile:"%~1" /All /DestinationImageFile:"%~2\sources\install.esd" /Compress:recovery
rem 生成ISO镜像
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:1 ^| findstr /i Architecture') do ( set "ImageArch=%%f" )
for /f "tokens=3 delims=." %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:1 ^| findstr /i Version') do ( set "ImageRevision=%%f" )
for /f "tokens=4" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:1 ^| find "ServicePack Build"') do ( set "ImageBuild=%%f" )
for /f "tokens=* delims=" %%f in ('Dism.exe /English /Get-ImageInfo /ImageFile:"%~1" /Index:1 ^| findstr /i Default') do ( set "ImageLanguage=%%f" )
call "%~dp0MakeISO.cmd" "%~2" "Win10_%ImageRevision%.%ImageBuild%_%ImageArch%_%ImageLanguage:~1,-10%"
rem 生成二合一镜像
set "ESDPath=%~dp0cn_windows_10_%ImageRevision%.%ImageBuild%_x86_x64.esd"
if exist "%ESDPath%" (
    %Dism% /Export-Image /SourceImageFile:"%~1" /All /DestinationImageFile:"%ESDPath%" /Compress:recovery
) else (
    move "%~2\sources\install.esd" "%ESDPath%" >nul
)
call :RemoveFile "%~1"
call :RemoveFolder "%~2"
goto :eof

rem 生成DVD镜像目录 [ %~1 : 源路径, %~2 : 目标路径 ]
:ExportDVD
md "%~2"
%Dism% /Apply-Image /ImageFile:"%~1" /Index:1 /ApplyDir:"%~2"
rem 获取版本信息
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:3 ^| findstr /i Version') do ( set "ImageVersion=%%f" )
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:3 ^| findstr /i Architecture') do ( set "ImageArch=%%f" )
set "NetFx3Path=%~dp0Pack\NetFx3\%ImageVersion%.%ImageArch%"
rem if not exist "%NetFx3Path%" xcopy /I /H /R /Y "%~2\sources\sxs" "%NetFx3Path%" >nul
rem 清理无用文件
del /q "%~2\autorun.inf"
rd /s /q "%~2\support"
rd /s /q "%~2\boot\zh-cn"
rd /s /q "%~2\sources\sxs"
for /f "tokens=* delims=" %%f in ('dir /a:-d /b "%~2\boot" ^| findstr /v "bcd boot.sdi etfsboot.com"') do del /q "%~2\boot\%%f"
for /f "tokens=* delims=" %%f in ('dir /a:-d /b "%~2\boot\fonts" ^| findstr /v "chs wgl4"') do del /q "%~2\boot\fonts\%%f"
for /f "tokens=* delims=" %%f in ('dir /a:-d /b "%~2\efi\microsoft\boot" ^| findstr /v "bcd efisys.bin"') do del /q "%~2\efi\microsoft\boot\%%f"
for /f "tokens=* delims=" %%f in ('dir /a:-d /b "%~2\efi\microsoft\boot\fonts" ^| findstr /v "chs wgl4"') do del /q "%~2\efi\microsoft\boot\fonts\%%f"
rem 导出WinPE
%Dism% /Export-Image /SourceImageFile:"%~1" /SourceIndex:3 /DestinationImageFile:"%~2\sources\boot.wim" /Bootable /Compress:max
goto :eof

rem ############################################################################################
rem 工具函数
rem ############################################################################################

rem 导出镜像 [ %~1 : 镜像路径, %~2 : 目标路径 ]
:ExportImage
if not exist "%~1" ( echo.镜像 %~1 不存在 && goto :eof )
for /f "tokens=2 delims=: " %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" ^| findstr /i Index') do ( call :ExportImageIndex "%~1", %%f, "%~2" )
goto :eof

rem 导出镜像 [ %~1 : 镜像路径, %~2 : 镜像序号, %~3 : 目标路径 ]
:ExportImageIndex
rem 获取镜像信息
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:%~2 ^| findstr /i Installation') do ( set "ImageType=%%f" )
for /f "tokens=2,3 delims=:. " %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:%~2 ^| findstr /i Version') do ( set "ImageShortVersion=%%f.%%g" )
rem 系统名称
if "%ImageType%" equ "Client" (
    if "%ImageShortVersion%" equ "6.1" ( set "ImageName=Windows 7" )
    if "%ImageShortVersion%" equ "6.2" ( set "ImageName=Windows 8" )
    if "%ImageShortVersion%" equ "6.3" ( set "ImageName=Windows 8.1" )
    if "%ImageShortVersion%" equ "10.0" ( set "ImageName=Windows 10" )
) else if "%ImageType%" equ "Server" (
    if "%ImageShortVersion%" equ "6.1" ( set "ImageName=Windows 2008 R2" )
    if "%ImageShortVersion%" equ "6.2" ( set "ImageName=Windows 2012" )
    if "%ImageShortVersion%" equ "6.3" ( set "ImageName=Windows 2012 R2" )
    if "%ImageShortVersion%" equ "10.0" ( set "ImageName=Windows 2016" )
) else ( goto :eof )
rem 系统版本
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:%~2 ^| findstr /i Edition') do ( set "ImageEdition=%%f" )
if "%ImageEdition%" equ "Cloud" ( goto :eof )
if "%ImageEdition%" equ "CoreCountrySpecific" ( set "ImageName=%ImageName% 家庭中文版" )
if "%ImageEdition%" equ "CoreSingleLanguage" ( goto :eof )
if "%ImageEdition%" equ "Core" ( goto :eof )
if "%ImageEdition%" equ "Education" ( goto :eof )
if "%ImageEdition%" equ "Professional" ( set "ImageName=%ImageName% 专业版" )
if "%ImageEdition%" equ "Enterprise" ( set "ImageName=%ImageName% 企业版" )
if "%ImageEdition%" equ "EnterpriseS" ( set "ImageName=%ImageName% 企业版 2016 长期服务版" )
if "%ImageEdition%" equ "ServerStandard" ( set "ImageName=%ImageName% 标准版" )
if "%ImageEdition%" equ "ServerEnterprise" ( set "ImageName=%ImageName% 企业版" )
if "%ImageEdition%" equ "ServerWeb" ( set "ImageName=%ImageName% Web版" )
if "%ImageEdition%" equ "ServerDatacenter" ( set "ImageName=%ImageName% 数据中心版" )
rem 处理器架构
rem for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:%~2 ^| findstr /i Architecture') do ( set "ImageArch=%%f" )
rem if "%ImageArch%" equ "x86" ( set "ImageName=%ImageName% 32位" )
rem if "%ImageArch%" equ "x64" ( set "ImageName=%ImageName% 64位" )
rem 判断是否有重复镜像
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~3" /Name:"%ImageName%" ^| findstr /i Index') do ( echo 镜像 %ImageName% 已存在 %%f && goto :eof )
rem 导出格式
if /i "%~x3" equ ".wim" ( set "Compress=/Compress:max" )
if /i "%~x3" equ ".esd" ( set "Compress=/Compress:recovery" )
%Dism% /Export-Image /SourceImageFile:"%~1" /SourceIndex:%~2 /DestinationImageFile:"%~3" /DestinationName:"%ImageName%" %Compress%
goto :eof

rem 删除文件 [ %~1 : 文件路径 ]
:RemoveFile
if exist "%~1" del /f /q "%~1"
goto :eof

rem 删除目录 [ %~1 : 目录路径 ]
:RemoveFolder
if exist "%~1" rd /q /s "%~1"
goto :eof

:Exit
rem shutdown -s -t 0