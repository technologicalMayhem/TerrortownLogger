@ECHO OFF
IF NOT exist toolbox\config.txt goto END
for /f "delims=" %%x in (toolbox\config.txt) do (set "%%x")
echo You need to be logged into Steam as the addon Owner in order to update it!
set /p issure="Are you sure you want to update the addon? (Y/N): "
IF %issure% == "Y" goto START
goto END
:START
%SteamCommon%\bin\gmad.exe create -folder '.\TTT Logger' -out '.\TTTLogger.gma'
set /p  changes="Changes: "
%SteamCommon%\bin\gmpublish.exe update -id 1306933722 -addon '.\TTTLogger.gma' -changes %Changes%
:END