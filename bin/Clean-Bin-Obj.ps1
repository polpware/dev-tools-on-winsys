Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Searching for bin and obj in the folder ..."

Get-Location | Get-ChildItem -Depth 1 -Directory -Include bin,obj | where {$_ -notmatch 'node_modules' -and $_ -notmatch 'wwwroot' -and $_ -notmatch '.git'} 

$answer = Read-Host -Prompt 'Are you sure to delete them? (y for yes)'

If ($answer -eq "y") {
  Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Starting to delete them ..."
  Get-Location | Get-ChildItem -Depth 1 -Directory -Include bin,obj | where {$_ -notmatch 'node_modules' -and $_ -notmatch 'wwwroot' -and $_ -notmatch '.git'} | Remove-Item -Recurse
  Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Done"
} Else {
  Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Done without doing nothing"
}
