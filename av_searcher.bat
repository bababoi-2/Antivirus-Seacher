@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

set max_name_length=0
set max_path_length=0
set "data="
set count=-1

REM Get the information and data needed for formatting
for /f "delims=, tokens=2,3 skip=2" %%f in ('wmic /node:localhost /namespace:\\root\SecurityCenter2 path AntiVirusProduct get displayName^,pathToSignedReportingExe /format:csv') do (
	set /a count+=1
	
	REM get the max length of all av names (for formatting)
	echo %%f>%tmp%\av_search.tmp
	for %%l in (%tmp%\av_search.tmp) do (
		set /a length=%%~zl - 2
		if !length! GTR !max_name_length! (
			set /a max_name_length=!length!
		)
	)
	
	set data[!count!].length=!length!
	
	REM get the max length of all av paths (for formatting)
	echo %%g>%tmp%\av_search.tmp
	for %%l in (%tmp%\av_search.tmp) do (
		set /a length=%%~zl - 2
		if !length! GTR !max_path_length! (
			set /a max_path_length=!length!
		)
	)
	
	set data[!count!].name=%%f
	set data[!count!].path=%%g
)
del %tmp%\av_search.tmp > nul


echo.

REM Format and Output
set "padding="
set "first_line="
set "second_line="


REM data for table header
for /l %%l in (0,1,%max_name_length%) do (
	set "padding=!padding! "
	set "first_line=!first_line!━"
)

for /l %%l in (0,1,%max_path_length%) do set "second_line=!second_line!━"

rem table header
echo Name!padding:~4!┃ Path
echo !first_line!╋!second_line!

rem fill and output table

for /l %%i in (0,1,%count%) do (
	call set /a length=!max_name_length! - %%data[%%i].length%%
	
	set "padding="
	for /l %%l in (1,1,!length!) do set "padding=!padding! "
	call echo %%data[%%i].name%%!padding! ┃ %%data[%%i].path%%
)

rem clean up
endlocal
set "max_name_length="
set "max_path_length="
set "first_line="
set "second_line="
set "length="
set "data="
set "count="
set "padding="

echo. & pause > nul