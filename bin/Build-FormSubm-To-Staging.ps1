# Parameters for customization
$solutionFolder = "D:\FormLang_Apps\staging\formsubm"
$projectFolder = "src\Nanshiie.FormSubmission.Web"
$projectFile = "Nanshiie.FormSubmission.Web.csproj"
$publishProfile = "StgDefaultFTPProfile.pubxml"

# Navigate to the project directory
cd $solutionFolder
Echo "Navigated to solution directory: $solutionFolder"

# Execute the dotnet publish command with the provided profile
Echo "Starting .NET project publish process..."
dotnet publish .\$projectFolder\$projectFile -p:PublishProfile=.\$projectFolder\Properties\PublishProfile\$publishProfile

Echo "Publish process complete!"