@ECHO OFF
IF NOT exist toolbox\config.txt goto END
for /f "delims=" %%x in (toolbox\config.txt) do (set "%%x")
echo OPEN %SSH%>upload.txt
echo %UserName%>>upload.txt
echo %ServerPassword%>>upload.txt
echo hash>>upload.txt
echo asc>>upload.txt
echo lcd "%CD%\TTT Logger\lua\autorun">>upload.txt
echo cd "/home/tttserver/serverfiles/garrysmod/lua/">>upload.txt
echo put tttlogger.lua>>upload.txt
echo bye>>upload.txt
ftp -s:upload.txt
plink -ssh -pw %ServerPassword% %UserName%@%SSH% tmux send -t gmodserver lua_openscript SPACE tttlogger.lua ENTER
del upload.txt
:END