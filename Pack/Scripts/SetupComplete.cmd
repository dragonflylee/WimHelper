@echo off
powercfg /h off
RMDIR /S /Q "%WINDIR%\Panther"
%~dp0"AAct.exe" /taskwin /wingvlk /win=act
cd %~dp0
attrib -R -A -S -H *.*
RMDIR /S /Q "%WINDIR%\Setup\Scripts"
exit