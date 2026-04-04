FormLang Build & Deployment Tools

This folder contains scripts and utilities for building, versioning, and deploying FormLang applications to Linux FTP targets.

Updated deployment domain:
- staging and release targets now use chorigen.com hostnames

Deployment Scripts

1) Build-FormLang-App.ps1
- Purpose: publish one application with dotnet publish.
- Required parameters:
	- -app: formlang | formportal | formsubm | formwork | formevents | formdrive | atlas
	- -env: staging | release
- Example:
	- .\Build-FormLang-App.ps1 -app formlang -env staging

2) Deploy-FormLang-App.ps1
- Purpose: upload one published application to FTP.
- Parameters:
	- -app: formlang | formportal | formsubm | formwork | formevents | formdrive | atlas
	- -env: staging | release
	- -server: staging | release-1 | release-2
	- -skipwww: true/false
	- -skipPortal: true/false
	- -skipDesign: true/false
	- -dryrun: true/false

Important:
- In practice, -server must be provided. If omitted, server lookup fails.
- -env selects local source folder and destination naming pattern.
- -server selects FTP IP and credentials.

Current FTP credential mapping (configured in script)
- staging server
	- user: chorigen.com_x23b318mkc
- release-1 and release-2 servers
	- user: chorigen.com_dci88rr8b7l

Destination hostnames
- formlang: staging.chorigen.com / next.chorigen.com
- formportal: staging-portal.chorigen.com / next-portal.chorigen.com
- formsubm: staging-submission.chorigen.com / next-submission.chorigen.com
- formwork: staging-workflow.chorigen.com / next-workflow.chorigen.com
- formevents: staging-events.chorigen.com / next-events.chorigen.com
- formdrive: staging-drive.chorigen.com / next-drive.chorigen.com
- atlas: staging-atlas.chorigen.com / next-atlas.chorigen.com

Single app deployment examples
- Dry run to staging:
	- .\Deploy-FormLang-App.ps1 -app formlang -env staging -server staging -dryrun $true
- Real deploy to staging:
	- .\Deploy-FormLang-App.ps1 -app formlang -env staging -server staging -dryrun $false
- Real deploy to production server 1:
	- .\Deploy-FormLang-App.ps1 -app formlang -env release -server release-1 -dryrun $false
- Real deploy to production server 2:
	- .\Deploy-FormLang-App.ps1 -app formlang -env release -server release-2 -dryrun $false

3) Build-Deploy-All.ps1
- Purpose: batch build and deploy multiple applications from one run.
- Inputs:
	- -environment: staging | release
	- -dryRun: $true | $false

Current behavior:
- This script now resolves and passes -server automatically:
	- staging environment uses server staging
	- release environment uses release-2 for formdrive and release-1 for all other apps

Recommended safe run sequence

1. Build one app
	- .\Build-FormLang-App.ps1 -app formlang -env staging
2. Dry run upload
	- .\Deploy-FormLang-App.ps1 -app formlang -env staging -server staging -dryrun $true
3. Real staging upload
	- .\Deploy-FormLang-App.ps1 -app formlang -env staging -server staging -dryrun $false
4. Real production upload
	- .\Deploy-FormLang-App.ps1 -app formlang -env release -server release-1 -dryrun $false

Batch deployment examples
- Dry run batch to staging:
	- .\Build-Deploy-All.ps1 -environment staging -dryRun $true
- Real batch to production server 1:
	- .\Build-Deploy-All.ps1 -environment release -dryRun $false

Development & Build Tools

4) Build-Debug-Pack.ps1
- Purpose: Build NuGet packages from a project (supports .NET Core and .NET Framework)
- Parameters:
	- -source: Path to .csproj file (auto-detected if omitted)
	- -version: Path to VERSION file (default: "VERSION")
	- -useVersionNumber: Override version (e.g., "2.2.0")
	- -msbuild: Use nuget command instead of dotnet
	- -rebuild: Skip building (default: $true)
- Examples:
	- .\Build-Debug-Pack.ps1
	- .\Build-Debug-Pack.ps1 -source .\MyProject.csproj
	- .\Build-Debug-Pack.ps1 -useVersionNumber 2.2.0
	- .\Build-Debug-Pack.ps1 -msbuild -rebuild:$false
- Output: Generates .nupkg and symbol packages in nupkgs directory

5) Build-Project.ps1
- Purpose: Build a .NET Core or ASP.NET Core C# project with version management
- Parameters:
	- -source: Path to .csproj file (auto-detected if omitted)
	- -version: Path to VERSION file (default: "VERSION")
	- -useVersionNumber: Override version (e.g., "2.2.0")
- Examples:
	- .\Build-Project.ps1 -source .\MyProject.csproj
	- .\Build-Project.ps1 -version ..\..\VERSION
	- .\Build-Project.ps1 -useVersionNumber 2.2.0

6) Clean-Bin-Obj.ps1
- Purpose: Recursively find and delete bin and obj directories
- Parameters: None (interactive confirmation required)
- Behavior:
	- Searches current directory and one level deep
	- Excludes: node_modules, wwwroot, .git
	- Prompts for confirmation before deletion
- Example:
	- .\Clean-Bin-Obj.ps1

7) Replace-Project-Version.ps1
- Purpose: Update version number in a .csproj file from VERSION file
- Parameters:
	- -source: Path to .csproj file (auto-detected if omitted)
	- -version: Path to VERSION file (default: "VERSION")
- Examples:
	- .\Replace-Project-Version.ps1
	- .\Replace-Project-Version.ps1 -source .\MyProject.csproj -version ..\..\VERSION

8) Set-AssemblyInfo-Version.ps1
- Purpose: Update version in all AssemblyInfo.cs or AssemblyInfo.vb files recursively
- Parameters:
	- Version number as first argument (e.g., "2.8.3")
- Example:
	- .\Set-AssemblyInfo-Version.ps1 2.8.3
- Behavior: Updates AssemblyVersion and AssemblyFileVersion attributes

9) bump-version.sh
- Purpose: Interactive semantic versioning with Git tag creation (Bash script)
- Behavior:
	- Reads current version from VERSION file
	- Suggests minor version increment
	- Pulls Git history and updates CHANGELOG.md
	- Creates Git tag with new version
	- Allows manual CHANGELOG.md editing before commit
- Requirements: Git, Bash shell
- Example:
	- bash bump-version.sh

Utilities & Dependencies

PolpIOModule/
- PowerShell module providing common helper functions
- Functions:
	- WriteInColor: Write colored console output
	- ConfirmContinue: Interactive yes/no prompt
- Imported by: Build-Debug-Pack.ps1, Build-Project.ps1, Build-FormLang-App.ps1, Deploy-FormLang-App.ps1

ditaa0_9.jar
- Diagram generation tool (converts ASCII art to PNG/SVG images)
- Usage: java -jar ditaa0_9.jar input.txt output.png

plantuml.jar
- UML diagram generation tool (supports sequence, class, component diagrams, etc.)
- Usage: java -jar plantuml.jar diagram.puml

make.exe
- GNU Make executable for Windows
- Used for build automation with Makefile scripts

