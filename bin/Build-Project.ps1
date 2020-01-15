<#

.SYNOPSIS
This is used to build a C# project.

.DESCRIPTION
The script itself will build the project.

.EXAMPLE
Build-Project.ps1 -source .\Backload.csproj for given source project
Build-Project.ps1 -version ..\..\VERSION for given version file
Build-Project.ps1 -useVersionNumber 2.2.0 for given version number, overriding VERSION

.NOTES
-source is to specify the target project file. In case, it is not specified, the script will try to find it out.
-version is to specify the version file containing the latest version number. 
-use-version-number is to override the version used for building package

.LINK
http://polpware.com

#>

param (
    [string]$source = "",
    [string]$version = "VERSION",    
    [string]$useVersionNumber = ""    
)

Import-Module -Name "$PSScriptRoot\PolpIOModule" -Verbose

WriteInColor "Build csharp lib"

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

if ($proj)
{
    if ($verNumber) {
        If (ConfirmContinue "Build the project and override the version number with $verNumber")
        {
            & dotnet build "$proj" -p:Version=$verNumber           
        }
    }
    else
    {
        If (ConfirmContinue "Start to use dotnet to build with the project specified version")
        
        {
            & dotnet build "$proj"
        }
    }
}
else
{
    WriteInColor "Found no project and quit"
}


