<#

.SYNOPSIS
This is used to deploy the Formlang App. 

.DESCRIPTION
The script itself will deploy a Formlang App based on the parameters. 

.EXAMPLE
Deploy-FormLang-App.ps1 -env staging -app formlang -skipwww true -dryrun false

.NOTES
-env is to specify the environment.
-app is to specify the formlang app.
-skipwww is to specify if the wwwroot is skipped.
-skipDesign is to specify if the Design App is skipped.
-skipportal is to specify if the Portal App is skipped.
-dryrun is true

.LINK
http://polpware.com

#>

param (
    [string]$app = "",
    [string]$env = "",
    [string]$server = "",    
    [bool]$skipwww = $true,
    [bool]$skipPortal = $true,
    [bool]$skipDesign = $true,
    [bool]$dryrun = $true
)

Import-Module -Name "$PSScriptRoot\PolpIOModule" -Verbose

# Function to calculate directories based on the app
function Get-Source-Directory($app) {
    switch ($app) {
        "formlang" {
            return "src\Nanshiie.FormProcessor.Web"
        }
        "formportal" {
            return "src\Nanshiie.FormPortal.HttpApi.Host"
        }
        "formsubm" {
            return "src\Nanshiie.FormSubmission.Web"
        }
        "formwork" { 
            return "src\Nanshiie.FormWorkflow.Web"
        }
        "formevents" {
            return "src\Nanshiie.FormEvents.Web"
        }
        "formdrive" {
            return "src\Nanshiie.FormDrive.Web"
        }
        "atlas" {
            return "src\FormLang.AtlasService.Web"
        }
        default {
            Write-Error "Invalid environment. Valid options: formlang, formportal, formsubm, formevents, formdrive, atlas"
            exit 1 
        }
    }
}

function Get-Solution-Prefix($env) {
    switch ($env) {
        "staging" {
            return "D:\FormLang_Apps\staging"
        }
        "release" {
            return "D:\FormLang_Apps\release"
        }
        default {
            Write-Error "Invalid environment. Valid options: staging, release"
            exit 1 
        }
    }
}

function Get-Ftp-Destination-Directory($app, $env) {
    switch ($app) {
        "formlang" {
            switch ($env) {
                "staging" {
                    return "staging.chorigen.com"
                }
                "release" {
                    return "next.chorigen.com"
                }
                default {
                    Write-Error "Invalid environment. Valid options: staging, release"
                    exit 1 
                }
            }
        }
        "formportal" {
            switch ($env) {
                "staging" {
                    return "staging-portal.chorigen.com"
                }
                "release" {
                    return "next-portal.chorigen.com"
                }
                default {
                    Write-Error "Invalid environment. Valid options: staging, release"
                    exit 1 
                }
            }

        }
        "formsubm" {
            switch ($env) {
                "staging" {
                    return "staging-submission.chorigen.com"
                }
                "release" {
                    return "next-submission.chorigen.com"
                }
                default {
                    Write-Error "Invalid environment. Valid options: staging, release"
                    exit 1 
                }
            }

        }
        "formwork" { 
            switch ($env) {
                "staging" {
                    return "staging-workflow.chorigen.com"
                }
                "release" {
                    return "next-workflow.chorigen.com"
                }
                default {
                    Write-Error "Invalid environment. Valid options: staging, release"
                    exit 1 
                }
            }

        }
        "formevents" {
            switch ($env) {
                "staging" {
                    return "staging-events.chorigen.com"
                }
                "release" {
                    return "next-events.chorigen.com"
                }
                default {
                    Write-Error "Invalid environment. Valid options: staging, release"
                    exit 1 
                }
            }
        }
        "formdrive" {
            switch ($env) {
                "staging" {
                    return "staging-drive.chorigen.com"
                }
                "release" {
                    return "next-drive.chorigen.com"
                }
                default {
                    Write-Error "Invalid environment. Valid options: staging, release"
                    exit 1 
                }
            }
        }
        "atlas" {
            switch ($env) {
                "staging" {
                    return "staging-atlas.chorigen.com"
                }
                "release" {
                    return "next-atlas.chorigen.com"
                }
                default {
                    Write-Error "Invalid environment. Valid options: staging, release"
                    exit 1 
                }
            }
        }
        default {
            Write-Error "Invalid environment. Valid options: formlang, formportal, formsubm, formevents, formdrive, atlas"
            exit 1 
        }
    }
}


# function to get the server information
function Get-Ftp-Server($server) {
    switch ($server) {
        "staging" {
            return "66.179.254.139", "chorigen.com_x23b318mkc", "QpFVn&gg1@nu3gn9"
        }
        "release-1" {
            return "74.208.107.107", "chorigen.com_dci88rr8b7l", "r#3%bCsdL24yRlnl"
        }
        "release-2" {
            return "209.46.122.181", "chorigen.com_dci88rr8b7l", "r#3%bCsdL24yRlnl"
        }
        default {
            Write-Error "Invalid environment. Valid options: staging, release-1, release-2 "
            exit 1 
        }
    }
}


# Function to upload a directory (updated)
function Upload-Directory($localPath, $remotePath) {
    Write-Host "Local path is $localPath"
    Write-Host "Remote Path is $remotePath"

    if ($localPath.Contains("wwwroot\portal")) {
        if ($skipPortal) {
            Write-Host "Skipping $localPath"
            return
        }
    } elseif ($localPath.Contains("wwwroot\studio")) {
        if ($skipDesign) {
            Write-Host "Skipping $localPath"
            return
        }
    }  elseif ($localPath.Contains("wwwroot\")) {
        if ($skipwww) {
            Write-Host "Skipping $localPath"
            return
        }
    }

    # Create an FTP session (simple, modify later for advanced options)
    $session = New-Object System.Net.WebClient
    $session.Credentials = New-Object System.Net.NetworkCredential($USERNAME, $PASSWORD)
    $baseUri = "ftp://$SERVER_ADDRESS/$remotePath/"    

    # Get files and directories in the local directory
    $items = Get-ChildItem $localPath

    foreach ($item in $items) {
        $uri = New-Object System.Uri($baseUri + $item.Name)

        if ($item.PSIsContainer) {  # It's a directory
            # Try to create the directory on the server
            Try {

                if ($dryrun) {
                    Write-Warning "Dry run $localPath to $remotePath"       
                } else { 
    
                   $ftpRequest = [System.Net.WebRequest]::Create($uri)
                   $ftpRequest.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory
                   $ftpRequest.UsePassive = $true # Adjust for your server
                   $ftpRequest.Credentials = $session.Credentials

                   $ftpResponse = $ftpRequest.GetResponse()
                   Write-Host "Directory created: $uri"
                }
            } Catch {
                Write-Warning "Failed to create directory: $uri"
            }

            # Recursively upload the subdirectory
            Upload-Directory $item.FullName ($remotePath + "/" + $item.Name)
        } else {  # It's a file
            if ($dryrun) {
                Write-Warning "Dry run $localPath to $remotePath"
                return
            } 
            $retryCount = 0
            while ($retryCount -lt 3) {
                try {
                    Write-Host "Uploading $item to $uri"
                    $session.UploadFile($uri, $item.FullName)
                    break  # Exit loop on success
                } catch {
                    Write-Warning "Upload failed for $item. Attempt: $($retryCount + 1)"
                    $retryCount++
                    Start-Sleep -Seconds 2  # Wait before retry
                }
            }
        }
    }
}

# Track start time
$startTime = Get-Date 

# Define variables (replace with your details)
$SERVER_ADDRESS, $USERNAME, $PASSWORD = Get-Ftp-Server $server

$solutionPrefix = Get-Solution-Prefix $env
$projectPath = Get-Source-Directory $app

$SOURCE_DIRECTORY = "$solutionPrefix\$app\$projectPath\bin\Release\net8.0\linux-x64\publish"
$DESTINATION_DIRECTORY = Get-Ftp-Destination-Directory $app $env

# Print out information
WriteInColor "Source is $SOURCE_DIRECTORY"
WriteInColor "Target is $DESTINATION_DIRECTORY"
WriteInColor "Server is $SERVER_ADDRESS"
WriteInColor "66 is for staging and 74 for release"

# Upload the root directory
Upload-Directory $SOURCE_DIRECTORY $DESTINATION_DIRECTORY

# Track end time
$endTime = Get-Date

# Calculate time difference
$timeSpent = $endTime - $startTime

Write-Host "Upload process took: $($timeSpent.ToString())"

# Error summary
if ($errorLog -ne $null) {
    Write-Host "Upload completed with errors:" -ForegroundColor Red
    $errorLog
} else {
    WriteInColor "Transfer completed successfully!"
}
