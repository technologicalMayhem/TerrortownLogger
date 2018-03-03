@ECHO OFF
IF NOT exist toolbox\config.txt GOTO END
for /f "delims=" %%x in (toolbox\config.txt) do (set "%%x")
echo You need to be logged into Steam as the addon Owner in order to update it!
:QUES
set /p issure="Are you sure you want to update the addon? (Y/N): "
IF /I "%issure%" == "Y" GOTO BEGIN
IF /I "%issure%" == "N" GOTO END
goto QUES
:BEGIN
%GModPath%\bin\gmad.exe create -folder "%CD%\TTT Logger" -out "%CD%\TTTLogger.gma"
set /p  changes="Changes: "
%GModPath%\bin\gmpublish.exe update -id 1306933722 -addon "%CD%\TTTLogger.gma" -changes %Changes%
:END