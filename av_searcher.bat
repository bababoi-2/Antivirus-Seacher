@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

goto :main

:str_len <string> <length_variable>
set len=0
set str=%~1
:l
if "!str:~%len%,1!"=="" (
	set "%~2=%len%"
	goto :eof
)
set /a len=%len%+1
goto :l


:main
set max_name_length=0
set max_path_length=0
set "data="
set count=-1

REM Get the information and data needed for formatting
for /f "delims=, tokens=2,3,4 skip=2" %%f in ('wmic /node:localhost /namespace:\\root\SecurityCenter2 path AntiVirusProduct get displayName^,pathToSignedReportingExe^,productState /format:csv') do (
	set /a count+=1
	
	REM get the max length of all av names (for formatting)
	call :str_len "%%f" length
	if !length! GTR !max_name_length! (
		set /a max_name_length=!length!
	)
	set data[!count!].length=!length!

	call :str_len "%%g" length
	if !length! GTR !max_path_length! (
		set /a max_path_length=!length!
	)
	
	set data[!count!].name=%%f
	set data[!count!].path=%%g
	
	REM https://blog.idera.com/database-tools/identifying-antivirus-engine-state/
	set /a "state=%%h & 0xF000"
	if !state! EQU 0x1000 (
		set "data[!count!].status= [Enabled]"
	) else (
		set "data[!count!].status=[Disabled]"
	)
	
)

echo. & echo Antivirus Searcher. Note: The status may be incorrect. & echo.

REM Format and Output

REM padding and first_line include the "[Enabled] " or "[Disabled]"
set "padding=           "
set "first_line=━━━━━━━━━━━"
set "second_line="


REM data for table header
for /l %%l in (0,1,%max_name_length%) do (
	set "padding=!padding! "
	set "first_line=!first_line!━"
)

for /l %%l in (0,1,%max_path_length%) do set "second_line=!second_line!━"

rem table header, remove "Name" from padding length (4 chars)
echo Name!padding:~4!┃ Path
echo !first_line!╋!second_line!

rem fill and output table

for /l %%i in (0,1,%count%) do (
	call set /a length=!max_name_length! - %%data[%%i].length%%
	
	set "padding="
	for /l %%l in (1,1,!length!) do set "padding=!padding! "
	call echo %%data[%%i].name%%!padding! %%data[%%i].status%% ┃ %%data[%%i].path%%
)

rem clean up
endlocal
set "max_name_length="
set "max_path_length="
set "first_line="
set "second_line="
set "length="
set "len="
set "str="
set "data="
set "count="
set "padding="

echo. & pause > nul
REM made by bababoiiiii on discord
