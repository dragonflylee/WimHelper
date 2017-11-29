@echo off
powercfg /h off
"%~dp0AAct.exe" /taskwin /wingvlk /win=act
attrib -r -a -s -h "%~dp0\*.*"
rd /s /q "%~dp0"
exit