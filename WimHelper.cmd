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
set "SRC=%SystemDrive%"
set "MNT=%~dp0Mount"
set "TMP=%~dp0Temp"
set "ImagePath=%~1"

rem 脚本起始
:Start
if "%ImagePath%" equ "" goto :SelectImage
if not exist "%ImagePath%" ( echo 镜像 %ImagePath% 不存在 && goto :Exit )
Dism /Get-ImageInfo /ImageFile:"%ImagePath%" 1>nul 2>nul || echo 文件 %ImagePath% 不是有效的镜像文件 && goto :Exit

title 正在初始化
call :CleanUp
md "%TMP%" && md "%MNT%"
call :MakeWim "%ImagePath%", "%~2"
rem call :MakeOEM "%ImagePath%", 1
goto :Exit

rem 选择镜像
:SelectImage
set selectimage=mshta "about:<input type=file id=f><script>f.click();new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(f.value);window.close();</script>"
for /f "tokens=* delims=" %%f in ('%selectimage%') do set "ImagePath=%%f"
if "%ImagePath%" equ "" goto :Exit
goto :Start

rem 处理镜像 [ %~1 : 镜像文件路径 ]
:MakeWim
if /i "%~x1" equ ".esd" ( call :MakeESD "%~1" && goto :eof )
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" ^| findstr /i Index') do ( set "ImageCount=%%f" )
for /l %%f in (1, 1, %ImageCount%) do call :MakeWimIndex "%~1", "%%f"
call :ImageOptimize "%~1"
goto :eof

rem 处理镜像 [ %~1 : 镜像文件路径 ]
:MakeESD
setlocal
set "WimPath=%TMP%\%~n1_%time:~0,2%%time:~3,2%%time:~5,2%.wim"
%Dism% /Export-Image /SourceImageFile:"%~1" /All /DestinationImageFile:"%WimPath%" /Compress:max
call :MakeWim "%WimPath%"
rem 导出为ESD镜像
call :RemoveFile "%~1"
%Dism% /Export-Image /SourceImageFile:"%WimPath%" /All /DestinationImageFile:"%~1" /Compress:recovery
call :RemoveFile "%WimPath%"
endlocal
goto :eof

rem 处理镜像 [ %~1 : 镜像文件路径, %~2 : 镜像序号 ]
:MakeWimIndex
call :GetImageInfo "%~1", "%~2"
title 正在处理 [%~2] 镜像 %ImageName% 版本 %ImageVersion% 语言 %ImageLanguage%
%Dism% /Mount-Wim /WimFile:"%~1" /Index:%~2 /MountDir:"%MNT%"
call :MakeWimClean "%MNT%"
goto :eof


rem 处理原版镜像 [ %~1 : 镜像挂载路径 ]
:MakeWimClean
call :RemoveAppx "%~1"
for /f %%f in ('type "%~dp0Pack\FeatureList.%ImageShortVersion%.txt" 2^>nul') do call :RemoveCapability "%~1", "%%f"
for /f %%f in ('type "%~dp0Pack\RemoveList.%ImageVersion%.txt" 2^>nul') do call :RemoveComponent "%~1", "%%f"
call :IntRollupFix "%~1"
call :AddAppx "%~1", "DesktopAppInstaller", "VCLibs"
call :AddAppx "%~1", "Store", "VCLibs Runtime Framework"
call :AddAppx "%~1", "WindowsCalculator"
call :AddAppx "%~1", "XboxGamingOverlay"
call :ImportOptimize "%~1"
call :ImportUnattend "%~1"
%Dism% /Unmount-Wim /MountDir:"%~1" /Commit
goto :eof

rem 处理OEM镜像 [ %~1 : 镜像文件路径, %~2 : 镜像序号 ]
:MakeOEM
call :GetImageInfo "%~1", "%~2"
title 正在处理 [%~2] 镜像 %ImageName% 版本 %ImageVersion% 语言 %ImageLanguage%
%Dism% /Mount-Wim /WimFile:"%~1" /Index:%~2 /MountDir:"%MNT%"
call :RemoveAppx "%MNT%"
for /f %%f in ('type "%~dp0Pack\FeatureList.%ImageShortVersion%.txt" 2^>nul') do call ::RemoveCapability "%MNT%", "%%f"
for /f %%f in ('type "%~dp0Pack\RemoveList.%ImageVersion%.txt" 2^>nul') do call :RemoveComponent "%MNT%", "%%f"
call :IntRollupFix "%MNT%"
call :AddAppx "%MNT%", "DesktopAppInstaller", "VCLibs"
call :AddAppx "%MNT%", "Store", "VCLibs Runtime Framework"
call :AddAppx "%MNT%", "WacomTechnologyCorp", "UWPDesktop"
call :ImportOptimize "%MNT%"
call :ImportUnattend "%MNT%", "OEM"
if exist "%~dp0Driver" %Dism% /Image:"%MNT%" /Add-Driver /Driver:"%~dp0Driver" /recurse /ForceUnsigned 
call :ImageClean "%MNT%"
%Dism% /Unmount-Wim /MountDir:"%MNT%" /Commit
goto :eof

rem 处理lopatkin镜像 [ %~1 : 镜像挂载路径 ]
:lopatkin
rem 修复默认用户头像
xcopy /E /I /H /R /Y /J "%SRC%\ProgramData\Microsoft\User Account Pictures\*.*" "%~1\ProgramData\Microsoft\User Account Pictures" >nul

call :MountImageRegistry "%~1"
rem 修复默认主题
call :RemoveFolder "%~1\Windows\Web\Wallpaper\Theme1"
call :RemoveFile "%~1\Windows\Resources\Themes\Theme1.theme"
move "%~1\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories\Калькулятор.lnk" "%~1\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories\Calculator.lnk"
notepad "%~1\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories\desktop.ini"
reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\LastTheme" /v "ThemeFile" /t REG_EXPAND_SZ /d "%%SystemRoot%%\Resources\Themes\Aero.theme" /f >nul
rem 修复设备管理器英文
for /f "tokens=2 delims=@," %%j in ('reg query "HKLM\TK_SYSTEM\ControlSet001\Control\Class" /v "ClassDesc" /s ^| findstr /i inf') do (
    for %%i in (System32\DriverStore\%ImageLanguage% INF) do (
        for %%f in (%SRC%\Windows\%%i\%%j*) do %NSudo% cmd.exe /c copy /Y "%%f" "%~1\Windows\%%i\%%~nxf"
    )
)
call :UnMountImageRegistry
rem call :AddAppx "%~1", "Store", "VCLibs.14 Runtime.1.7 Framework.1.7"
call :RemoveFolder "%~1\Program Files (x86)\Trey"
call :RemoveFolder "%~1\Program Files\Trey"
call :RemoveFile "%~1\Users\Default\Desktop\Green Christmas Tree.lnk"
call :RemoveFile "%~1\Windows\KEY_Aquarium-Screensavers.txt"
call :RemoveFile "%~1\Windows\System32\MA2_6.scr"
call :ImportOptimize "%~1"
call :ImportUnattend "%~1"
call :ImageClean "%~1"
%Dism% /Unmount-Wim /MountDir:"%~1" /Commit
goto :eof

rem ############################################################################################
rem 组件集成相关
rem ############################################################################################

rem 集成积累更新 [ %~1 : 镜像挂载路径 ]
:IntRollupFix
setlocal
set "UpdatePath=%~dp0Pack\Update\%ImageVersion%.%ImageArch%"
if exist "%UpdatePath%" (
    %Dism% /Image:"%~1" /Add-Package /ScratchDir:"%TMP%" /PackagePath:"%UpdatePath%"
)
set "RollupPath=%~dp0Pack\RollupFix\%ImageVersion%.%ImageArch%"
if exist "%RollupPath%" (
    %Dism% /Image:"%~1" /Add-Package /ScratchDir:"%TMP%" /PackagePath:"%RollupPath%"
    call :IntRecovery "%~1", "%RollupPath%"
)
if not exist "%~1\Windows\WinSxS\pending.xml" (
    rem Enable DISM Image Cleanup with Full ResetBase...
    call :MountImageRegistry "%~1"
    Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "DisableComponentBackups" /t REG_DWORD /d "1" /f >nul
    Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "SupersededActions" /t REG_DWORD /d "1" /f >nul
    call :UnMountImageRegistry
    %Dism% /Image:"%~1" /Cleanup-Image /ScratchDir:"%TMP%" /StartComponentCleanup
) else (
    %NSudo% cmd.exe /c del /q "%~1\Windows\WinSxS\ManifestCache\*.bin"
    %NSudo% cmd.exe /c rd /s /q "%~1\Windows\WinSxS\Temp\PendingDeletes"
    %NSudo% cmd.exe /c rd /s /q "%~1\Windows\WinSxS\Temp\TransformerRollbackData"
    %NSudo% cmd.exe /c rd /s /q "%~1\Windows\CbsTemp"
)
endlocal
goto :eof

rem 向 WinRe 集成更新 [ %~1 : 镜像挂载路径, %~2 更新包路径 ]
:IntRecovery
setlocal
set "WinrePath=%TMP%\Winre.%ImageVersion%.%ImageArch%.wim"
if not exist "%WinrePath%" (
    call :RemoveFolder "%TMP%\RE"
    md "%TMP%\RE"
    echo.挂载镜像 [%WinrePath%]
    %Dism% /Mount-Wim /WimFile:"%~1\Windows\System32\Recovery\Winre.wim" /Index:1 /MountDir:"%TMP%\RE" /Quiet
    call :MountImageRegistry "%TMP%\RE"
    rem Enable DISM Image Cleanup with Full ResetBase...
    Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "DisableComponentBackups" /t REG_DWORD /d "1" /f >nul
    call :UnMountImageRegistry
    echo.集成更新 [%WinrePath%]
    %Dism% /Image:"%TMP%\RE" /Add-Package /ScratchDir:"%TMP%" /PackagePath:"%~2" /Quiet
    %Dism% /Image:"%TMP%\RE" /Cleanup-Image /ScratchDir:"%TMP%" /StartComponentCleanup /ResetBase /Quiet
    call :ImageClean "%TMP%\RE"
    echo.保存镜像 [%WinrePath%]
    %Dism% /Unmount-Wim /MountDir:"%TMP%\RE" /Commit /Quiet
    echo.优化镜像 [%WinrePath%]
    %Dism% /Export-Image /SourceImageFile:"%~1\Windows\System32\Recovery\Winre.wim" /All /DestinationImageFile:"%WinrePath%" /Compress:max /Quiet
)
copy /Y "%WinrePath%" "%~1\Windows\System32\Recovery\Winre.wim" >nul
endlocal
goto :eof

rem 集成功能 [ %~1 : 镜像挂载路径, %~2 功能名称 ]
:IntFeature
setlocal
set "FeaturePath=%~dp0Pack\%~2\%ImageVersion%.%ImageArch%"
if not exist "%FeaturePath%" ( echo.未找到 %FeaturePath% && goto :eof )
%Dism% /Image:"%~1" /Get-FeatureInfo /FeatureName:%~2 | findstr /c:"State : Enable Pending" >nul
if errorlevel 1 (
    echo.开启功能 [%~2]
    %Dism% /Image:"%~1" /Enable-Feature /All /LimitAccess /FeatureName:%~2 /Source:"%FeaturePath%" /Quiet
) else ( echo.功能 [%~2] 已开启 )
endlocal
goto :eof

rem 导入优化 [ %~1 : 镜像挂载路径 ]
:ImportOptimize
call :MountImageRegistry "%~1"
call :ImportRegistry "%~dp0Pack\Optimize\%ImageShortVersion%.reg"
call :ImportRegistry "%~dp0Pack\Optimize\%ImageShortVersion%.%ImageArch%.reg"
if "%ImageType%" equ "Server" call :ImportRegistry "%~dp0Pack\Optimize\Server.reg"
if "%ImageShortVersion%" equ "10.0" (
    rem Removing Windows Mixed Reality Menu from Settings App
    Reg add "HKLM\TK_NTUSER\Software\Microsoft\Windows\CurrentVersion\Holographic" /v "FirstRunSucceeded" /t REG_DWORD /d "0" /f >nul
    rem 启用照片查看器, 删除 3D画图 右键
    Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities" /v "ApplicationDescription" /t REG_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3069" /f >nul
    Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities" /v "ApplicationName" /t REG_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3009" /f >nul
    for %%t in (.bmp .gif .jfif .ico .jpe .jpeg .jpg .png .tif .tiff) do (
        Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v "%%t" /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f >nul
        Reg add "HKLM\TK_SOFTWARE\Classes\%%t" /ve /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f >nul 2>&1
        Reg delete "HKLM\TK_SOFTWARE\Classes\SystemFileAssociations\%%t\Shell\3D Edit" /f >nul 2>&1
    )
    rem 延迟功能更新
    if "%ImageVersion%" leq "10.0.17134" Reg add "HKLM\TK_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferFeatureUpdatesPeriodInDays" /t REG_DWORD /d "365" /f >nul
    rem 右键菜单优化
    call :ImportRegistry "%~dp0Pack\Optimize\Context.reg"
    call :ImportStartLayout "%~1", "%~dp0Pack\StartLayout.xml"
)
call :UnMountImageRegistry
goto :eof

rem 集成额外组件 [ %~1 : 镜像挂载路径, %~2 : 组件名称 ]
:IntExtra
echo.集成组件 [%~2]
setlocal
set "ExtraPath=%~dp0Pack\Extra\%~2"
if "%ImageArch%"=="x86" set "PackageIndex=1"
if "%ImageArch%"=="x64" set "PackageIndex=2"
if exist "%ExtraPath%.tpk" (
   %Dism% /Apply-Image /ImageFile:"%ExtraPath%.tpk" /Index:%PackageIndex% /ApplyDir:"%~1" /CheckIntegrity /Verify /Quiet
)
if exist "%ExtraPath%.%ImageLanguage%.tpk" (
   %Dism% /Apply-Image /ImageFile:"%ExtraPath%.%ImageLanguage%.tpk" /Index:%PackageIndex% /ApplyDir:"%~1" /CheckIntegrity /Verify /Quiet
)
rem if exist "%ExtraPath%.%ImageArch%.reg" (
rem     call :MountImageRegistry "%~1"
rem     call :ImportRegistry "%ExtraPath%.%ImageArch%.reg"
rem     call :UnMountImageRegistry
rem )
if exist "%ExtraPath%.cmd" call %ExtraPath%.cmd "%~1" %ImageArch% %ImageLanguage%
endlocal
goto :eof

rem ############################################################################################
rem 工具函数
rem ############################################################################################

rem 导入应答文件 [ %~1 : 镜像挂载路径, %~2 : 应答文件类型(Admin, Audit) ]
:ImportUnattend
call :RemoveFolder "%~1\Windows\Setup\Scripts"
md "%~1\Windows\Setup\Scripts"
xcopy /E /I /H /R /Y /J "%~dp0Pack\Scripts\*.*" "%~1\Windows\Setup\Scripts" >nul

setlocal
if /i "%~2" equ "Admin" (
    if exist "%~dp0Pack\AAct_%ImageArch%.exe" copy "%~dp0Pack\AAct_%ImageArch%.exe" "%~1\Windows\Setup\Scripts\AAct.exe" >nul
    set "UnattendFile=%~dp0Pack\Unattend.Admin.xml"

if "%ImageShortVersion%" leq "10.0" (
    call :MountImageRegistry "%~1"
    Reg add "HKLM\TK_SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "FilterAdministratorToken" /t REG_DWORD /d 1 /f >nul
    call :UnMountImageRegistry
)
    
) else if /i "%~2" equ "OEM" (
    set "UnattendFile=%~dp0Pack\Unattend.OEM.xml"
    copy "%~dp0Pack\oemlogo.bmp" "%~1\Windows\System32\oemlogo.bmp"
) else (
    set "UnattendFile=%~dp0Pack\Unattend.%ImageShortVersion%.xml"
)
if exist "%UnattendFile%" (
    echo.导入应答 [%UnattendFile%]
    call :RemoveFolder "%~1\Windows\Panther"
    md "%~1\Windows\Panther"
    copy /Y "%UnattendFile%" "%~1\Windows\Panther\unattend.xml" >nul
)
endlocal
goto :eof

rem 导入开始菜单布局文件 [ %~1 : 镜像挂载路径, %~2 布局文件路径 ]
:ImportStartLayout
copy /y "%~2" "%~1\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml" >nul
call :RemoveFile "%~1\Users\Default\AppData\Local\TileDataLayer"
goto :eof

rem 集成Appx应用 [ %~1 : 镜像挂载路径, %~2 : 应用包名, %~3 : 应用依赖包名 ]
:AddAppx
setlocal
set "Apps=%~dp0Pack\Appx"
set LicPath=/SkipLicense
if "%ImageArch%" equ "x86" ( set "AppxArch=*x86*" ) else ( set "AppxArch=*" )
for /f %%f in ('"dir /b %Apps%\*%~2*.xml" 2^>nul') do ( set LicPath=/LicensePath:"%Apps%\%%f" )
for %%j in (%~3) do for /f %%i in ('"dir /b %Apps%\*%%j%AppxArch%.appx" 2^>nul') do ( set Dependency=!Dependency! /DependencyPackagePath:"%Apps%\%%i" )
for /f %%i in ('"dir /b %Apps%\*%~2*.appxbundle" 2^>nul') do (
    echo.集成应用 [%%~ni]
    %Dism% /Image:"%~1" /Add-ProvisionedAppxPackage /PackagePath:"%Apps%\%%i" %LicPath% %Dependency% /Quiet
)
endlocal
goto :eof

rem 禁用功能 [ %~1 : 镜像挂载路径, %~2 : 功能名称 ]
:RemoveFeature
for /f "tokens=4" %%f in ('%Dism% /English /Image:"%~1" /Get-Features ^| findstr Feature ^| findstr /i "%~2"') do (
    echo.移除功能 [%%f]
    %Dism% /Image:"%~1" /Disable-Feature /FeatureName:"%%f" /Remove
)
goto :eof

rem 移除自带应用 [ %~1 : 镜像挂载路径 ]
:RemoveAppx
for /f "tokens=3" %%f in ('%Dism% /English /Image:"%~1" /Get-ProvisionedAppxPackages ^| findstr PackageName') do (
    echo.移除应用 [%%f]
    %Dism% /Image:"%~1" /Remove-ProvisionedAppxPackage /PackageName:"%%f" /Quiet
)
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
%NSudo% reg import "%TMP%\%~nx1" >nul 2>&1
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

rem 保存镜像 [ %~1 : 镜像挂载路径 ]
:ImageClean
rd /s /q "%~1\Users\Administrator" >nul 2>&1
rd /s /q "%~1\Program Files\Classic Shell" >nul 2>&1
rd /s /q "%~1\Recovery" >nul 2>&1
rd /s /q "%~1\$RECYCLE.BIN" >nul 2>&1
rd /s /q "%~1\Logs" >nul 2>&1
del /q "%~1\Windows\INF\*.pnf" >nul 2>&1
del /s /q "%~1\*.log" >nul 2>&1
del /s /q /a:h "%~1\*.log" >nul 2>&1
del /s /q /a:h "%~1\*.blf" >nul 2>&1
del /s /q /a:h "%~1\*.regtrans-ms" >nul 2>&1
goto :eof

rem 获取镜像基本信息 [ %~1 : 镜像文件路径, %~2 : 镜像序号 ]
:GetImageInfo
for /f "tokens=2 delims=:" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:%~2 ^| findstr /i Name') do ( set "ImageName=%%f" )
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:%~2 ^| findstr /i Architecture') do ( set "ImageArch=%%f" )
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:%~2 ^| findstr /i Version') do ( set "ImageVersion=%%f" )
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:%~2 ^| findstr /i Edition') do ( set "ImageEdition=%%f" )
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:%~2 ^| findstr /i Installation') do ( set "ImageType=%%f" )
for /f "tokens=* delims=" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:%~2 ^| findstr /i Default') do ( set "ImageLanguage=%%f" && set "ImageLanguage=!ImageLanguage:~1,-10!" )
for /f "tokens=1,2 delims=." %%f in ('echo %ImageVersion%') do ( set "ImageShortVersion=%%f.%%g" )
goto :eof

rem 优化镜像 [ %~1 : 镜像文件路径 ]
:ImageOptimize
title 正在优化镜像 %~1
if not exist "%TMP%\%~nx1" %Dism% /Export-Image /SourceImageFile:"%~1" /All /DestinationImageFile:"%TMP%\%~nx1" /CheckIntegrity /Compress:max
move /Y "%TMP%\%~nx1" "%~1" >nul
goto :eof

rem 清理文件
:CleanUp
call :UnMountImageRegistry
if exist "%MNT%\Windows" ( %Dism% /Unmount-Wim /MountDir:"%MNT%" /ScratchDir:"%TMP%" /Discard /Quiet )
if exist "%TMP%\RE\Windows" ( %Dism% /Unmount-Wim /MountDir:"%TMP%\RE" /ScratchDir:"%TMP%" /Discard /Quiet )
call :RemoveFolder "%TMP%"
call :RemoveFolder "%MNT%"
if errorlevel 0 goto :eof
goto :Exit

rem 删除文件 [ %~1 : 文件路径 ]
:RemoveFile
if exist "%~1" %NSudo% cmd.exe /c del /f /q "%~1"
goto :eof

rem 删除目录 [ %~1 : 目录路径 ]
:RemoveFolder
if exist "%~1" %NSudo% cmd.exe /c rd /q /s "%~1"
goto :eof

:Exit
call :CleanUp
endlocal EnableDelayedExpansion
title 操作完成