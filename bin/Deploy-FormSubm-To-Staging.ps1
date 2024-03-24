@echo off

rem Define variables (replace with your details)
set SERVER_ADDRESS=your_server_address
set USERNAME=your_username
set PASSWORD=your_password
set SOURCE_DIRECTORY=D:\FormLang_Apps\staging\formlang
set DESTINATION_DIRECTORY=/remote/directory

rem Check for skip argument (optional)
set SKIP_WWW=

:check_argument
if "%~1%" EQU "-skipwww" (
  set SKIP_WWW=true
  shift /1
  goto check_argument
)

! Enable passive mode (add "-p" flag for passive mode)
ftp -p %SERVER_ADDRESS% <<!

USER %USERNAME%
PASS %PASSWORD%

! Turn off Interactive mode (prevents prompting)
prompt off

! Change directory on server (replace with your destination path)
CWD %DESTINATION_DIRECTORY%

! Change directory locally (replace with your source path)
cd /d %SOURCE_DIRECTORY%

! Loop through each file or directory (excluding www if SKIP_WWW is set)
for /d %%f in ("%SOURCE_DIRECTORY%\*") do (
  if "!SKIP_WWW!" EQU "" OR %%f NEQ "www" (
    ftp -in <<END_SCRIPT
        lcd %%f
        cd %DESTINATION_DIRECTORY%\%%f
        mput *.*
        bye
    END_SCRIPT
  )
)

! Close connection
bye

! Exit script
exit

!>>

echo Transfer completed!

pause
