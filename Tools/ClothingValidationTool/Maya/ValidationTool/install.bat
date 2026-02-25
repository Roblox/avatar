@echo off
setlocal EnableDelayedExpansion


py -m ensurepip --upgrade

pip3 install numpy

pip3 install pillow 

:userinput
set /p "VERSION=Enter Maya version (ValidationTool supports Maya2020 or later): "

echo "%USERPROFILE%\Documents\maya\%VERSION%"

IF EXIST "%USERPROFILE%\Documents\maya\%VERSION%" (
   echo f | xcopy /f /y %0\..\scripts "%USERPROFILE%\Documents\maya\%VERSION%\prefs\scripts\ValidationTool\" /E
   echo f | xcopy /f /y %0\..\icon\robloxValidationTool.png "%USERPROFILE%\Documents\maya\%VERSION%\prefs\icons\"
   for /f %%p in ('where python') do (
        echo "%%p" | findstr "Python3" > nul
        if not ERRORLEVEL 1 (
            echo %%p > "%USERPROFILE%\Documents\maya\%VERSION%\prefs\scripts\ValidationTool\pythonpath.txt"
        )
    )
    echo Scripts are installed, you can close this window.
    pause
) ELSE (
    echo Specified Maya version was not found.
    goto  :userinput
)



endlocal

