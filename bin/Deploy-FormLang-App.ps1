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
-dryrun is true

.LINK
http://polpware.com

#>

param (
    [string]$app = "",
    [string]$env = "",
    [bool]$skipwww = $false,
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
        default {
            Write-Error "Invalid environment. Valid options: formlang, formportal, formsubm, formevents"
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
                    return "staging.formlang.com"
                }
                "release" {
                    return "next.formlang.com"
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
                    return "staging-portal.formlang.com"
                }
                "release" {
                    return "next-portal.formlang.com"
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
                    return "staging-submission.formlang.com"
                }
                "release" {
                    return "next-submission.formlang.com"
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
                    return "staging-workflow.formlang.com"
                }
                "release" {
                    return "next-workflow.formlang.com"
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
                    return "staging-events.formlang.com"
                }
                "release" {
                    return "next-events.formlang.com"
                }
                default {
                    Write-Error "Invalid environment. Valid options: staging, release"
                    exit 1 
                }
            }
        }
        default {
            Write-Error "Invalid environment. Valid options: formlang, formportal, formsubm, formevents"
            exit 1 
        }
    }
}


# function to get the server information
function Get-Ftp-Server($env) {
    switch ($env) {
        "staging" {
            return "66.179.254.139", "formlang.com_paa9dgf93ik", "vP95x_LgQ8"
        }
        "release" {
            return "74.208.107.107", "formlang.com_lqhtl0fq1qi", "r#3%bCsdL24yRlnl"
        }
        default {
            Write-Error "Invalid environment. Valid options: staging, release"
            exit 1 
        }
    }
}


# Function to upload a directory (updated)
function Upload-Directory($localPath, $remotePath) {
    Write-Host "Local path is $localPath"
    Write-Host "Remote Path is $remotePath"

    # Create an FTP session (simple, modify later for advanced options)
    $session = New-Object System.Net.WebClient
    $session.Credentials = New-Object System.Net.NetworkCredential($USERNAME, $PASSWORD)
    $baseUri = "ftp://$SERVER_ADDRESS/$remotePath/"    

    # Get files and directories in the local directory
    $items = Get-ChildItem $localPath

    $items = $items | Where-Object { $_.Name -ne "wwwroot" -or !$skipwww }

    if ($dryrun) {
       Write-Warning "Dry run $localPath to $remotePath"       
       return
    } 
    
    foreach ($item in $items) {
        $uri = New-Object System.Uri($baseUri + $item.Name)

        if ($item.PSIsContainer) {  # It's a directory
            # Try to create the directory on the server
            Try {
                $ftpRequest = [System.Net.WebRequest]::Create($uri)
                $ftpRequest.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory
                $ftpRequest.UsePassive = $true # Adjust for your server
                $ftpRequest.Credentials = $session.Credentials

                $ftpResponse = $ftpRequest.GetResponse()
                Write-Host "Directory created: $uri"
            } Catch {
                Write-Warning "Failed to create directory: $uri"
            }

            # Recursively upload the subdirectory
            Upload-Directory $item.FullName ($remotePath + "/" + $item.Name)
        } else {  # It's a file
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
$SERVER_ADDRESS, $USERNAME, $PASSWORD = Get-Ftp-Server $env

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
