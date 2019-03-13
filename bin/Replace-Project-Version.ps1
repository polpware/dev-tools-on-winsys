Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Update Version ..."

$loc = Get-Location

If (Test-Path -Path "$loc\VERSION" -PathType Leaf) {
    Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Read VERSION"
    $version = Get-Content -Path "$loc\Version"
    Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "New version is $version"

    if ($version) {

        Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Finding out the project file"        
        $proj = Get-ChildItem -Path "$loc\*" -Include *.csproj

        Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Project file is $proj"

        if ($proj) {

            Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Updating version ..."
            (Get-Content -path "$proj" -Raw) -replace '<Version>[\d.]+</Version>',"<Version>$version</Version>" | Set-Content -Path "$proj"
        }
    }
} else {
    Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "VERSION not found and Quit without doing anything"
}
