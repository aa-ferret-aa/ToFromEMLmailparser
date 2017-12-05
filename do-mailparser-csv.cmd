:: Gets the Nt Batch Script name and path and puts in the var 'ScriptPath'
Set ScriptPath=%~d0%~p0
:: Removes Slash at end of path 
Set ScriptPath=%ScriptPath:~0,-1%


:: ------------------------------------------------------------------------------------
:: Set the line below to the path to portable perl, default is C:\perl
Set PtblPerl=C:\perl\portableshell.bat
:: -----------------------------------

:: Directory where all the log files will be stored
Set RtDir=%ScriptPath%

:: Set this to where you extracted your EML files....
:: The line below assumes Subdirectory of Script location called Emails
Set EmailSrcPath=%RtDir%\Emails

:: STDOUT -  This file will contain the list of TO and FROM addresses.
Set OutFile=Addresses-list.txt.csv

:: STDERR  - Data is logged to this file: 
Set ErrLog=%RtDir%\Errors.log.txt.csv

:: Run paramter information is logged to this file: 
Set RunLog=%RtDir%\Run.log.txt

:: ------------------------------------------------------------------------------------

Set PerlFile=mailparser-csv.pl

IF NOT EXIST "%RtDir%\."  md "%RtDir%"

if exist "%ErrLog%" del "%ErrLog%"
Echo ____________________________________________________>> "%RunLog%"


@IF NOT EXIST "%RtDir%\%PerlFile%" @Echo "%RtDir%\%PerlFile%" Is missing Can't continue! >> "%ErrLog%"
@IF NOT EXIST "%RtDir%\%PerlFile%" @Echo "%RtDir%\%PerlFile%" Is missing Can't continue! >> "%RunLog%"
@IF NOT EXIST "%RtDir%\%PerlFile%" @Echo "%RtDir%\%PerlFile%" Is missing Can't continue! & @Goto :EOF

call "%PtblPerl%" /SETENV
set PtblErrCde=%Errorlevel%
Echo Ptbl Error code: %PtblErrCde%
:: Gets up to here 

IF "%PtblErrCde%"=="9009" Echo "Error Unable to find %PtblPerl%" >> "%ErrLog%"
IF "%PtblErrCde%"=="9009" Echo "Error Unable to find %PtblPerl%" >> "%RunLog%"
:: IF "%PtblErrCde%"=="1" Echo Unable to Continue Can't find %PtblPerl% to execute .pl script. & Goto :EOF
:: IF "%PtblErrCde%"=="0" "%PtblPerl%" /SETENV
IF "%PtblErrCde%"=="0" Set PerlCmd=perl.exe

perl.exe -v 
Set EXEErrCde=%Errorlevel%
Echo EXEErrCde: %EXEErrCde%
IF "%EXEErrCde%"=="9009" Echo "Error Unable to find Perl.exe unable to continue." >> "%ErrLog%"
IF "%EXEErrCde%"=="9009" Echo "Error Unable to find Perl.exe unable to continue." >> "%RunLog%"
IF "%EXEErrCde%"=="0" Set PerlCmd=perl.exe
@IF "%EXEErrCde%"=="9009" @Echo Unable to Continue Can't find perl.exe to execute .pl script! 
@IF "%EXEErrCde%"=="9009" @pause & @Goto :EOF

Echo        Start,%date%,%time%>> "%RunLog%" 
Echo Script running.....
echo @%PerlCmd% "%RtDir%\%PerlFile%"  "%ScriptPath%\Emails" 1^> "%RtDir%\%OutFile%" 2^>^>"%ErrLog%"  >> "%RunLog%"
@%PerlCmd% "%RtDir%\%PerlFile%"  "%ScriptPath%\Emails" 1> "%RtDir%\%OutFile%" 2>>"%ErrLog%"
Echo End Perl Processing,%date%,%time%>> "%RunLog%" 
@Echo.
@Echo.
type "%ErrLog%"
@Echo.
@Echo Run completed! 
@Echo Email addresses are in: "%RtDir%\%OutFile%"
@Echo.
@Echo.

pause 