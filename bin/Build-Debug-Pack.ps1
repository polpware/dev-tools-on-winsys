param (
    [string]$source = "",
    [switch]$msbuild = $false,
    [string]$version = ""
)

Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Build debug pack"

$loc = Get-Location

If (Test-Path -Path "$loc\$version" -PathType Leaf) {
    Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Read VERSION"
    $verNumber = Get-Content -Path "$loc\$version"
    Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "New version is $verNumber"
}

if ($source) {
    Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Project is provided"            
    $proj = "$loc\$source"
}
else { 
    Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Finding out the project file"        
    $proj = Get-ChildItem -Path "$loc\*" -Include *.csproj
}

Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Project file is $proj"

if ($proj) {

    if ($msbuild) {
        Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Start to use nuget to build and pack ..."
        if ($verNumber) {
            Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Ovrriding the version number with $verNumber"            
            & nuget pack "$proj" -Build -OutputDirectory nupkgs -Symbols -Version $verNumber
        }
        else
        {
            & nuget pack "$proj" -Build -OutputDirectory nupkgs -Symbols
        }
    }
    else
    {
        Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Start to use dotnet to build and pack ..."
        & dotnet pack "$proj" --output nupkgs --include-source --include-symbols 
    }
}

