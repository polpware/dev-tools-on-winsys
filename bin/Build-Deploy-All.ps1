<#
.SYNOPSIS
    A script to automate the build and deployment of multiple FormLang applications.

.DESCRIPTION
    This script iterates through a predefined list of application sub-folders,
    changes into each directory, and runs the build and deployment PowerShell scripts.
    It includes a configuration section for easy management of deployment parameters.
    The script is designed to be placed in the parent folder of all application sub-folders.

.NOTES
    Author: Gemini
    Version: 1.1
    - The script will terminate immediately if any command fails.
    - Assumes 'Build-FormLang-App.ps1' and 'Deploy-FormLang-App.ps1' are present
      in each application's sub-folder.
    - Updated to allow per-application deployment configurations.
#>

param (
    [ValidateSet("staging", "release")]
    [string]$environment = "staging",
    [bool]$dryRun = $true
)

#--------------------------------------------------------------------------------
# Configuration Section
#--------------------------------------------------------------------------------
# Application-specific deployment configurations.
# For each application, specify its name and the deployment steps to skip.
$appConfigurations = @(
    [PSCustomObject]@{
        Name       = "atlas"
        SkipDesign = $false
        SkipPortal = $false
        SkipWWW    = $false
    },
    [PSCustomObject]@{
        Name       = "formdrive"
        SkipDesign = $false
        SkipPortal = $false
        SkipWWW    = $false
    },
    [PSCustomObject]@{
        Name       = "formevents"
        SkipDesign = $false
        SkipPortal = $false
        SkipWWW    = $false
    },
    [PSCustomObject]@{
        Name       = "formlang"
        SkipDesign = $false
        SkipPortal = $false
        SkipWWW    = $false
    },
    [PSCustomObject]@{
        Name       = "formportal"
        SkipDesign = $false
        SkipPortal = $false
        SkipWWW    = $false
    },
    [PSCustomObject]@{
        Name       = "formsubm"
        SkipDesign = $false
        SkipPortal = $false
        SkipWWW    = $false
    }
)

#--------------------------------------------------------------------------------
# Script Logic - Do not modify below this line
#--------------------------------------------------------------------------------

# This setting ensures that any error, even non-terminating ones, will stop
# the script and trigger the 'catch' block. This is crucial for the requirement
# to halt the entire process on failure.
$ErrorActionPreference = "Stop"

# Resolve app paths from the directory where the command is invoked.
$scriptRoot = (Get-Location).Path

# In staging, all apps deploy to the single staging server.
# In release, formdrive is assigned to release-2; all other apps to release-1.
function Get-DeployServer([string]$env, [string]$appName) {
    switch ($env) {
        "staging" {
            return "staging"
        }
        "release" {
            if ($appName -eq "formdrive") {
                return "release-2"
            }
            return "release-1"
        }
        default {
            Write-Error "Invalid environment '$env'. Valid options: staging, release"
            exit 1
        }
    }
}

Write-Host "Starting batch application deployment process..." -ForegroundColor Cyan
Write-Host "Target Environment: $environment"
Write-Host "Dry Run Mode: $dryRun`n"
Write-Host "Invocation Root: $scriptRoot"

# Loop through each application defined in the configuration.
foreach ($appConfig in $appConfigurations) {
    # The 'try...catch' block handles error management. If anything inside 'try'
    # fails, the 'catch' block will execute, and the script will terminate.
    try {
        $appName = $appConfig.Name
        $appPath = Join-Path -Path $scriptRoot -ChildPath $appName
        
        # Check if the application directory actually exists before proceeding.
        if (-not (Test-Path -Path $appPath -PathType Container)) {
            Write-Warning "Directory not found for application '$appName' at '$appPath'. Skipping."
            # 'continue' skips to the next item in the foreach loop.
            continue
        }

        # Use Push-Location to change the directory and save the original location.
        # This makes it easy to return with Pop-Location later.
        Push-Location -Path $appPath

        Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
        Write-Host "Deploying Application: $appName"
        Write-Host "------------------------------------------------------------" -ForegroundColor Yellow

        $deployServer = Get-DeployServer -env $environment -appName $appName
        $buildCommand = "Build-FormLang-App.ps1 -app $appName -env $environment"
        $deployCommand = "Deploy-FormLang-App.ps1 -app $appName -env $environment -server $deployServer -skipDesign $($appConfig.SkipDesign) -skipPortal $($appConfig.SkipPortal) -skipwww $($appConfig.SkipWWW) -dryrun $dryRun"

        # Step 1: Build the application.
        Write-Host "Step 1: Building '$appName'..."
        if ($dryRun) {
            Write-Host "Dry run command: $buildCommand" -ForegroundColor Cyan
        }
        else {
            # We assume the build script is inside the application folder.
            Build-FormLang-App.ps1 -app $appName -env $environment
            Write-Host "Build for '$appName' completed successfully." -ForegroundColor Green
        }

        # Step 2: Deploy the application.
        Write-Host "Step 2: Deploying '$appName'..."
        Write-Host "Target Server: $deployServer"
        if ($dryRun) {
            Write-Host "Dry run command: $deployCommand" -ForegroundColor Cyan
        }
        else {
            # We assume the deploy script is inside the application folder.
            Deploy-FormLang-App.ps1 -app $appName -env $environment -server $deployServer -skipDesign $appConfig.SkipDesign -skipPortal $appConfig.SkipPortal -skipwww $appConfig.SkipWWW -dryrun $dryRun
            Write-Host "Deployment for '$appName' completed successfully." -ForegroundColor Green
        }

        Write-Host "`n"

    }
    catch {
        Write-Error "FATAL: An error occurred during the deployment of '$($appName)'."
        # $_ is the current error object. .Exception.Message provides the specific error text.
        Write-Error "Error Details: $($_.Exception.Message)"
        Write-Error "Terminating the entire deployment process."
        
        # Exit the script with a non-zero status code to indicate failure.
        exit 1
    }
    finally {
        # The 'finally' block always runs, whether there was an error or not.
        # This ensures we always return to the script's root directory before
        # processing the next application or exiting.
        Pop-Location
    }
}

Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "All applications deployed successfully!"
Write-Host "------------------------------------------------------------" -ForegroundColor Cyan

