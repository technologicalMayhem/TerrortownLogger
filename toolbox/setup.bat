@ECHO OFF
echo Path to Garry's Mod Folder. (The Folder inside the Steam's common folder!)
set /p Config1="Path: "
echo GModPath=%Config1%>toolbox\config.txt
echo SSH details that will be used for upload.
set /p Config2="Server Adress: "
set /p Config3="User Name: "
set /p Config4="Password: "
echo SSH=%Config2%>>toolbox\config.txt
echo UserName=%Config3%>>toolbox\config.txt
echo ServerPassword=%Config4%>>toolbox\config.txt
echo Server IP, Port and Password for the actual Garry's Mod Server
set /p Config5="IP: "
set /p Config6="Port: "
set /p Config7="Password: "
echo GameIP=%Config5%:%Config6%/%Config7%>>toolbox\config.txt