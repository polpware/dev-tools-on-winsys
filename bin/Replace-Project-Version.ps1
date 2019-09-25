<#

.SYNOPSIS
This is used to update the version number in a project file.

.DESCRIPTION
The script itself will read the version number from a version file 
which can be passed in as a command line parameter, and 
then update the project file either given by the command line parameter 
or searched by the script itself.

.EXAMPLE
Replace-Project-Version.ps1 -source .\Backload.csproj -version ..\..\VERSION

.NOTES
-source is to specify the target project file. In case it is not specified, the script will try to find it out.
-version is to specify the version file containing the latest version number. In case it is not specified, the 
script looks for the file called VERSION under the current directory.

.LINK
http://polpware.com

#>

param (
    [string]$source = "",
    [string]$version = "VERSION"
)


Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Update Version ..."

$loc = Get-Location

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

    If (Test-Path -Path "$loc\$version" -PathType Leaf) {
        Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Read VERSION"
        $verNumber = Get-Content -Path "$loc\$version"
        Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "New version is $verNumber"

        if ($verNumber) {
            Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Updating version ..."
            (Get-Content -path "$proj" -Raw) -replace '<Version>[\d.]+</Version>',"<Version>$verNumber</Version>" | Set-Content -Path "$proj"
        }
    } else {
        Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "VERSION not found and Quit without doing anything"
    }
    
} else {
    Write-Host -ForegroundColor DarkBlue -BackgroundColor Green "Cannot find a project file"    
}
