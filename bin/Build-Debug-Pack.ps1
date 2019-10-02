<#

.SYNOPSIS
This is used to build nuget packages from a project.

.DESCRIPTION
The script itself will build the project and then generate the nuget package and its corresponding 
symbol one in the nupkgs directory. This script uses either nuget or dotnet to generate 
the final outputs.

.EXAMPLE
Build-Debug-Pack.ps1 -msbuild -rebuild:$false -source .\Backload.csproj -version ..\..\VERSION -useVersionNumber 2.2.0

.NOTES
-msbuild is to instruct the script to use the nuget command. 
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

Write-In-Color "Build debug pack"

$loc = Get-Location

If ($useVersionNumber) {
    $verNumber = $useVersionNumber
}
else
{
    If (Test-Path -Path "$loc\$version" -PathType Leaf) {
        Write-In-Color "Read VERSION"
        $verNumber = Get-Content -Path "$loc\$version"
        Write-In-Color Green "New version is $verNumber"
    }
}

if ($source) {
    Write-In-Color "Project is provided"            
    $proj = "$loc\$source"
}
else { 
    Write-In-Color "Finding out the project file"        
    $proj = Get-ChildItem -Path "$loc\*" -Include *.csproj
}

Write-In-Color "Project file is $proj"

if ($proj) {

    if ($msbuild) {
        Write-In-Color "Start to use nuget to build and pack ..."
        if ($verNumber) {
            if ($rebuild) {
                Write-In-Color "Rebuild the project and override the version number with $verNumber"            
                & nuget pack "$proj" -Build -OutputDirectory nupkgs -Symbols -Version $verNumber
            }
            else
            {
                Write-In-Color "Just Override the version number with $verNumber"            
                & nuget pack "$proj" -OutputDirectory nupkgs -Symbols -Version $verNumber
            }
        }
        else
        {
            if ($rebuild) {
                Write-In-Color "Rebuild the project and then pack"                            
                & nuget pack "$proj" -Build -OutputDirectory nupkgs -Symbols
            }
            else
            {
                Write-In-Color "Just rebuild the project"                                            
                & nuget pack "$proj" -OutputDirectory nupkgs -Symbols                
            }
        }
    }
    else
    {
        Write-In-Color "Start to use dotnet to build and pack ..."
        if ($rebuild) {
            & dotnet pack "$proj" --output nupkgs --include-source --include-symbols
        }
        else
        {
            & dotnet pack "$proj" --no-build --output nupkgs --include-source --include-symbols            
        }
    }
}

