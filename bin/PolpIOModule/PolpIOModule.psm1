function Write-In-Color {
    param(
        [string] $info,
        [string] $fg = "DarkBlue",
        [string] $bg = "Green"
    )

    Write-Host -ForegroundColor DarkBlue -BackgroundColor Green $info
}

Export-ModuleMember -Function Write-In-Color
