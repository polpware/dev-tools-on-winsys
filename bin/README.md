FormLang Deployment Tools (PowerShell)

This folder contains scripts used to build and deploy FormLang applications to Linux FTP targets.

Updated deployment domain:
- staging and release targets now use chorigen.com hostnames

Scripts

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

