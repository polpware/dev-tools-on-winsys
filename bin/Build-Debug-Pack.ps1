<#

.SYNOPSIS
This is used to build nuget packages from a project.

.DESCRIPTION
The script itself will build the project and then generate the nuget package and its corresponding 
symbol one in the nupkgs directory. This script uses either nuget or dotnet to generate 
the final outputs.

.EXAMPLE
Build-Debug-Pack.ps1 for .NetCore/.AspNetCore project
Build-Debug-Pack.ps1 -msbuild -rebuild:$false for traditional .Net Framework target project
Build-Debug-Pack.ps1 -source .\Backload.csproj for given source project
Build-Debug-Pack.ps1 -version ..\..\VERSION for given version file
Build-Debug-Pack.ps1 -useVersionNumber 2.2.0 for given version number

.NOTES
-msbuild is to instruct the script to use the nuget command. 
-rebuild is to skip building.
-source is to specify the target project file. In case, it is not specified, the script will try to find it out.
-version is to specify the version file containing the latest version number. In the case that we use -msbuild, it is used.
-use-version-number is to override the version used for building package

.LINK
http://polpware.com

#>

param (
    [string]$source = "",
    [switch]$msbuild = $false,
    [string]$version = "VERSION",
    [switch]$rebuild = $true,
    [string]$useVersionNumber = ""
)

Import-Module -Name "$PSScriptRoot\PolpIOModule" -Verbose

WriteInColor "Build debug pack now ..."

$loc = Get-Location

If ($useVersionNumber) {
    $verNumber = $useVersionNumber
    WriteInColor "Using the given version number: $useVersionNumber"    
}
else
{
    If (Test-Path -Path "$loc\$version" -PathType Leaf) {
        WriteInColor "Read file: VERSION"
        $verNumber = Get-Content -Path "$loc\$version"
        WriteInColor "New version is $verNumber"
    }
}

if ($source) {
    $proj = "$loc\$source"
    WriteInColor "Use the given project file: $proj"                    
}
else { 
    $proj = Get-ChildItem -Path "$loc\*" -Include *.csproj
    WriteInColor "Use the found project: $proj"            
}

if ($proj) {

    if ($msbuild) {
        WriteInColor "Start to use nuget to build and pack ..."
        if ($verNumber) {
            if ($rebuild) {
                If (ConfirmContinue "Rebuild the project and override the version number with $verNumber")
                {
                    & nuget pack "$proj" -Build -OutputDirectory nupkgs -Symbols -Version $verNumber
                }
            }
            else
            {
                if (ConfirmContinue "Just Override the version number with $verNumber")
                {
                    & nuget pack "$proj" -OutputDirectory nupkgs -Symbols  -Version $verNumber
                }
            }
        }
        else
        {
            if ($rebuild) {
                if (ConfirmContinue "Rebuild the project and then pack")
                {
                    & nuget pack "$proj" -Build -OutputDirectory nupkgs -Symbols
                }
            }
            else
            {
                if (ConfirmContinue "Just rebuild the project")
                {
                    & nuget pack "$proj" -OutputDirectory nupkgs -Symbols
                }
            }
        }
    }
    else
    {

        if ($verNumber) {
            if ($rebuild) {
                If (ConfirmContinue "Start to use dotnet to build and pack")
                {
                    & dotnet pack "$proj" --output nupkgs --include-source --include-symbols -p:PackageVersion=$verNumber
                }
            }
            else
            {
                If (ConfirmContinue "Start to use dotnet to pack (without rebuild)")
                {
                    & dotnet pack "$proj" --no-build --output nupkgs --include-source --include-symbols -p:PackageVersion=$verNumber
                }
            }
        }
        else
        {
            if ($rebuild) {
                If (ConfirmContinue "Start to use dotnet to build and pack")
                {
                    & dotnet pack "$proj" --output nupkgs --include-source --include-symbols
                }
            }
            else
            {
                If (ConfirmContinue "Start to use dotnet to pack (without rebuild)")
                {
                    & dotnet pack "$proj" --no-build --output nupkgs --include-source --include-symbols
                }
            }
            
        }
    }
}
else
{
    WriteInColor "Found no project and quit"
}

