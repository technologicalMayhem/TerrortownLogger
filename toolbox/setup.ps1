$steamfolder = Read-Host -Prompt "Absolute path to Steam's common folder: "
$steamfolder = "`$steamfolder = " + "`"$steamfolder`""
$setup = "`$setup = `"1`""
$steamfolder,$setup | Out-File -FilePath ./vars.ps1