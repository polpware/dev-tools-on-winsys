<#

.SYNOPSIS
Set the version in all the AssemblyInfo.cs or AssemblyInfo.vb files in any subdirectory.

.Example
Set-Assembly-Version 2.8.3

#>


function Update-SourceVersion
{
    Param ([string]$Version)
    $NewVersion = 'AssemblyVersion("' + $Version + '")';
    $NewFileVersion = 'AssemblyFileVersion("' + $Version + '")';

    foreach ($o in $input) 
    {
        Write-output $o.FullName
        $TmpFile = $o.FullName + ".tmp"

        get-content $o.FullName | 
          %{$_ -replace 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', $NewVersion } |
          %{$_ -replace 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', $NewFileVersion }  | Set-Content -Path $TmpFile

        move-item $TmpFile $o.FullName -force
    }
}


function Update-AllAssemblyInfoFiles ( $version )
{
    foreach ($file in "AssemblyInfo.cs", "AssemblyInfo.vb" ) 
    {
        get-childitem -recurse |? {$_.Name -eq $file} | Update-SourceVersion $version ;
    }
}


# validate arguments 
$r= [System.Text.RegularExpressions.Regex]::Match($args[0], "^[0-9]+(\.[0-9]+){1,3}$");

if ($r.Success)
{
    Update-AllAssemblyInfoFiles $args[0];
}
else
{
    echo " ";
    echo "Bad Input!"
    echo " ";
    echo "Use Get-Help to find usage";
}
