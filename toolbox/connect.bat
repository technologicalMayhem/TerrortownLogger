@ECHO OFF
IF NOT exist toolbox\config.txt goto END
for /f "delims=" %%x in (toolbox\config.txt) do (set "%%x")
start "" steam://connect/%GameIP%
:END