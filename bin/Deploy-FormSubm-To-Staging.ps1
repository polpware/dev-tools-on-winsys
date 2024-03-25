# Define variables (replace with your details)
$SERVER_ADDRESS = "66.179.254.139"
$USERNAME = "formlang.com_paa9dgf93ik"
$PASSWORD = "vP95x_LgQ8"
$SOURCE_DIRECTORY = "D:\FormLang_Apps\staging\formsubm\src\Nanshiie.FormSubmission.Web\bin\Release\net8.0\linux-x64"
$DESTINATION_DIRECTORY = "staging-submission.formlang.com"

# Check for skip argument (optional)
$SKIP_WWW = $false  # Assume not skipping by default
if ($args[0] -eq "-skipwww") {
    $SKIP_WWW = $true
    $args = $args[1..($args.length - 1)] # Shift arguments
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

# Change local directory
Set-Location $SOURCE_DIRECTORY

# Get subdirectories
$directories = Get-ChildItem -Directory

# Optionally skip 'www'
$directories = $directories | Where-Object { $_.Name -ne "wwwroot" -or !$SKIP_WWW }

foreach ($dir in $directories) {
    Upload-Directory $dir.FullName $DESTINATION_DIRECTORY + $dir.Name
}

# Error summary
if ($errorLog -ne $null) {
    Write-Host "Upload completed with errors:" -ForegroundColor Red
    $errorLog
} else {
    Write-Host "Transfer completed successfully!"
}
