rem 修复计算器快捷方式显示名称
pushd "%~1\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories"
findstr /i /c:"Calculator.lnk=" desktop.ini >nul
if errorlevel 1 (
    type desktop.ini>desktop2.ini
    echo.Calculator.lnk=@%%SystemRoot%%\system32\shell32.dll,-22019>>desktop2.ini
    move /y desktop2.ini desktop.ini >nul
    attrib +h +s desktop.ini >nul
)
popd