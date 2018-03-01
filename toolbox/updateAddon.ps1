. .\toolbox\vars.ps1
if ($steamfolder -eq "") {
    Write-Output "Config invalid! Aborted."
    exit
}
Write-Output "You need to be logged into Steam as the addon Owner in order to update it!"
$IsSure = ""
while ($IsSure -ne "y" -and $IsSure -ne "n" ) {
    $IsSure = Read-Host -Prompt 'Are you sure you want to update the addon? (Y/N): '
    $IsSure.ToLower()
}
if ($IsSure -eq "y") {
    $exe = $steamfolder + "\GarrysMod\bin\gmad.exe"
    &$exe create -folder '.\TTT Logger' -out '.\TTTLogger.gma'
    $Changes = Read-Host -Prompt 'Changes: '
    $exe = $steamfolder + "\GarrysMod\bin\gmpublish.exe"
    &$exe update -id 1306933722 -addon '.\TTTLogger.gma' -changes $Changes
}
else {
    Write-Output "Addon Update Process stopped!"
    Start-Sleep -s 3
}