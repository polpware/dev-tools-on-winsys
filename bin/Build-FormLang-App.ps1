# New parameter for app 
$app = $args[0]
# new parameter for environment
$env = $args[1]

# Function to calculate directories based on environment
function Get-Directories($app) {
    switch ($app) {
        "formlang" {
            return "src\Nanshiie.FormProcessor.Web", "Nanshiie.FormProcessor.Web.csproj"
        }
        "formportal" {
            return "src\Nanshiie.FormPortal.HttpApi.Host", "Nanshiie.FormPortal.HttpApi.Host.csproj"
        }
        "formsubm" {
            return "src\Nanshiie.FormSubmission.Web", "Nanshiie.FormSubmission.Web.csproj"
        }
        "formwork" { 
            return "src\Nanshiie.FormWorkflow.Web", "Nanshiie.FormWorkflow.Web.csproj"
        }
        "formevents" {
            return "src\Nanshiie.FormEvents.Web", "Nanshiie.FormEvents.Web.csproj"
        }
        default {
            Write-Error "Invalid environment. Valid options: formlang, formportal, formsubm, formevents"
            exit 1 
        }
    }
}

function Get-Environment($env) {
    switch ($env) {
        "staging" {
            return "D:\FormLang_Apps\staging", "StgDefaultFTPProfile.pubxml"
        }
        "release" {
            return "D:\FormLang_Apps\release", "ReleaseDefaultFTPProfile.pubxml"
        }
        default {
            Write-Error "Invalid environment. Valid options: staging, release"
            exit 1 
        }
    }
}


# Get directories based on the environment parameter
$projectPath, $projectFile = Get-Directories $app

# Get
$solutionFolderPrefix, $publishProfile = Get-Environment $env

$solutionFolder = "$solutionFolderPrefix\$app"

# Navigate to the project directory
cd $solutionFolder
Echo "Navigated to solution directory: $solutionFolder"

# Execute the dotnet publish command with the provided profile
Echo "Starting .NET project publish process..."
dotnet publish .\$projectFolder\$projectFile -p:PublishProfile=.\$projectFolder\Properties\PublishProfile\$publishProfile

Echo "Publish process complete!"