function WriteInColor {
    param(
        [string] $info,
        [string] $fg = "DarkBlue",
        [string] $bg = "Green"
    )

    Write-Host -ForegroundColor $fg -BackgroundColor $bg $info
}

function ConfirmContinue {
    param(
        [string] $message  = 'something'
    )

    $question = 'Are you sure you want to proceed?'
    $choices  = '&Yes', '&No'

    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'confirmed'
        return $true
    } else {
        Write-Host 'cancelled'
        return $false
    }
}

# Export-ModuleMember -Function WriteInColor ConfirmContinue
