@echo off

rem ��ȡ����ԱȨ��
pushd "%~dp0" && Dism 1>nul 2>nul || mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 "%*"","","runas",1)(window.close) && Exit /B 1
rem ���ñ���
color 1F
mode con cols=120
set "Dism=Dism.exe /NoRestart /LogLevel:1"
set "ESDPath=%~1"

if "%ESDPath%" equ "" call :SelectFolder
if "%ESDPath%" equ "" goto :Exit
rem call :ExportISO "E G", "%~dp0install.wim"
for %%i in (X64) do call :Export21H1 "%ESDPath%", "%~dp0DVD_%%i", "%%i"
goto :Exit

:SelectFolder
set folder=mshta "javascript:var folder=new ActiveXObject('Shell.Application').BrowseForFolder(0,'ѡ��ESD��������Ŀ¼', 513, '');if(folder) new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(folder.Self.Path);window.close();"
for /f %%f in ('%folder%') do set "ESDPath=%%f"
goto :eof

rem ����ISO���� [ %~1 : �̷��б�[�ո�ָ�], %~2 : Ŀ��·�� ]
:ExportISO
call :RemoveFile "%~2"
for %%i in (%~1) do call :ExportImage "%%i:\sources\install.wim", "%~2"
goto :eof

rem ����21H1���� [ %~1 : Դ·��, %~2 : Ŀ��·��, %~3 �������ܹ� ]
:Export21H1
if not exist "%~1" echo [%~1] ������ && goto :eof
set "WimPath=%~dp0install_22H2_%~3_%date:~0,4%%date:~5,2%%date:~8,2%.wim"
call :RemoveFile "%WimPath%"
call :RemoveFolder "%~2"
rem ������װ����
for %%i in (china consumer business) do (
    for %%j in ("%~1\*.ni_release_*%%i*_%~3fre_*.esd") do (
        if not exist "%~2" call :ExportDVD "%%j", "%~2"
        call :ExportImage "%%j", "%WimPath%"
    )
)
call :MakeISO "%WimPath%", "%~2"
goto :eof

rem ����ISO [ %~1 : Դ·��, %~2 : Ŀ��·�� ]
:MakeISO
call "%~dp0WimHelper.cmd" "%~1"
rem ת��ESD����
%Dism% /Export-Image /SourceImageFile:"%~1" /All /DestinationImageFile:"%~2\sources\install.esd" /Compress:recovery
rem ����ISO����
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:1 ^| findstr /i Architecture') do ( set "ImageArch=%%f" )
for /f "tokens=3 delims=." %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:1 ^| findstr /i Version') do ( set "ImageRevision=%%f" )
for /f "tokens=4" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:1 ^| find "ServicePack Build"') do ( set "ImageBuild=%%f" )
for /f "tokens=* delims=" %%f in ('Dism.exe /English /Get-ImageInfo /ImageFile:"%~1" /Index:1 ^| findstr /i Default') do ( set "ImageLanguage=%%f" )
call "%~dp0MakeISO.cmd" "%~2" "Win10_%ImageRevision%.%ImageBuild%_%ImageArch%_%ImageLanguage:~1,-10%"
rem ���ɶ���һ����
set "ESDPath=%~dp0cn_windows_10_%ImageRevision%.%ImageBuild%_x86_x64.esd"
if exist "%ESDPath%" (
    %Dism% /Export-Image /SourceImageFile:"%~1" /All /DestinationImageFile:"%ESDPath%" /Compress:recovery
) else (
    move "%~2\sources\install.esd" "%ESDPath%" >nul
)
call :RemoveFile "%~1"
call :RemoveFolder "%~2"
goto :eof

rem ����DVD����Ŀ¼ [ %~1 : Դ·��, %~2 : Ŀ��·�� ]
:ExportDVD
md "%~2"
%Dism% /Apply-Image /ImageFile:"%~1" /Index:1 /ApplyDir:"%~2"
rem ��ȡ�汾��Ϣ
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:3 ^| findstr /i Version') do ( set "ImageVersion=%%f" )
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:3 ^| findstr /i Architecture') do ( set "ImageArch=%%f" )
set "NetFx3Path=%~dp0Pack\NetFx3\%ImageVersion%.%ImageArch%"
rem if not exist "%NetFx3Path%" xcopy /I /H /R /Y "%~2\sources\sxs" "%NetFx3Path%" >nul
rem ���������ļ�
del /q "%~2\autorun.inf"
rd /s /q "%~2\support"
rd /s /q "%~2\boot\zh-cn"
rd /s /q "%~2\sources\sxs"
for /f "tokens=* delims=" %%f in ('dir /a:-d /b "%~2\boot" ^| findstr /v "bcd boot.sdi etfsboot.com"') do del /q "%~2\boot\%%f"
for /f "tokens=* delims=" %%f in ('dir /a:-d /b "%~2\boot\fonts" ^| findstr /v "chs wgl4"') do del /q "%~2\boot\fonts\%%f"
for /f "tokens=* delims=" %%f in ('dir /a:-d /b "%~2\efi\microsoft\boot" ^| findstr /v "bcd efisys.bin"') do del /q "%~2\efi\microsoft\boot\%%f"
for /f "tokens=* delims=" %%f in ('dir /a:-d /b "%~2\efi\microsoft\boot\fonts" ^| findstr /v "chs wgl4"') do del /q "%~2\efi\microsoft\boot\fonts\%%f"
rem ����WinPE
%Dism% /Export-Image /SourceImageFile:"%~1" /SourceIndex:3 /DestinationImageFile:"%~2\sources\boot.wim" /Bootable /Compress:max
goto :eof

rem ############################################################################################
rem ���ߺ���
rem ############################################################################################

rem �������� [ %~1 : ����·��, %~2 : Ŀ��·�� ]
:ExportImage
if not exist "%~1" ( echo.���� %~1 ������ && goto :eof )
for /f "tokens=2 delims=: " %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" ^| findstr /i Index') do ( call :ExportImageIndex "%~1", %%f, "%~2" )
goto :eof

rem �������� [ %~1 : ����·��, %~2 : �������, %~3 : Ŀ��·�� ]
:ExportImageIndex
rem ��ȡ������Ϣ
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:%~2 ^| findstr /i Installation') do ( set "ImageType=%%f" )
for /f "tokens=2,3 delims=:. " %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:%~2 ^| findstr /i Version') do ( set "ImageShortVersion=%%f.%%g" )
rem ϵͳ����
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
rem ϵͳ�汾
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:%~2 ^| findstr /i Edition') do ( set "ImageEdition=%%f" )
if "%ImageEdition%" equ "Cloud" ( goto :eof )
if "%ImageEdition%" equ "CoreCountrySpecific" ( set "ImageName=%ImageName% ��ͥ���İ�" )
if "%ImageEdition%" equ "CoreSingleLanguage" ( goto :eof )
if "%ImageEdition%" equ "Core" ( goto :eof )
if "%ImageEdition%" equ "Education" ( goto :eof )
if "%ImageEdition%" equ "Professional" ( set "ImageName=%ImageName% רҵ��" )
if "%ImageEdition%" equ "Enterprise" ( set "ImageName=%ImageName% ��ҵ��" )
if "%ImageEdition%" equ "EnterpriseS" ( set "ImageName=%ImageName% ��ҵ�� 2016 ���ڷ����" )
if "%ImageEdition%" equ "ServerStandard" ( set "ImageName=%ImageName% ��׼��" )
if "%ImageEdition%" equ "ServerEnterprise" ( set "ImageName=%ImageName% ��ҵ��" )
if "%ImageEdition%" equ "ServerWeb" ( set "ImageName=%ImageName% Web��" )
if "%ImageEdition%" equ "ServerDatacenter" ( set "ImageName=%ImageName% �������İ�" )
rem �������ܹ�
rem for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~1" /Index:%~2 ^| findstr /i Architecture') do ( set "ImageArch=%%f" )
rem if "%ImageArch%" equ "x86" ( set "ImageName=%ImageName% 32λ" )
rem if "%ImageArch%" equ "x64" ( set "ImageName=%ImageName% 64λ" )
rem �ж��Ƿ����ظ�����
for /f "tokens=3" %%f in ('%Dism% /English /Get-ImageInfo /ImageFile:"%~3" /Name:"%ImageName%" ^| findstr /i Index') do ( echo ���� %ImageName% �Ѵ��� %%f && goto :eof )
rem ������ʽ
if /i "%~x3" equ ".wim" ( set "Compress=/Compress:max" )
if /i "%~x3" equ ".esd" ( set "Compress=/Compress:recovery" )
%Dism% /Export-Image /SourceImageFile:"%~1" /SourceIndex:%~2 /DestinationImageFile:"%~3" /DestinationName:"%ImageName%" %Compress%
goto :eof

rem ɾ���ļ� [ %~1 : �ļ�·�� ]
:RemoveFile
if exist "%~1" del /f /q "%~1"
goto :eof

rem ɾ��Ŀ¼ [ %~1 : Ŀ¼·�� ]
:RemoveFolder
if exist "%~1" rd /q /s "%~1"
goto :eof

:Exit
rem shutdown -s -t 0