param (
   [string]$source = ""
)

Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Build csharp lib"

$loc = Get-Location

if ($source) {
    Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Project is provided"            
    $proj = "$loc\$source"
}
else
{
    Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Finding out the project file"        
    $proj = Get-ChildItem -Path "$loc\*" -Include *.csproj
}    

Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Project file is $proj"

if ($proj) {

    Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Start to build ..."
    & dotnet build "$proj"
}

