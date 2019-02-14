@echo on
call :Resume
goto %current%
goto :eof

:one
msiexec /i "https://www.7-zip.org/a/7z1806-x64.msi" /quiet /qn /norestart /L*V "C:\Windows\Logs\7zip Install Log.log"
msiexec /i "https://aka.ms/teams64bitmsi"
::Install Chrome
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------
C:\chrome_installer.exe /silent /install
C:\SetDefaultBrowser.exe chrome
echo two >%~dp0current.txt
echo -- Section one --
shutdown.exe /r /t 000 /f
goto :eof

:two
::Remove script from Run key
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f
reg delete HKLM\Software\Microsoft\Windows\CurrentVersion\Run /v InstallApps /f
del %~dp0current.txt
echo -- Section two --
shutdown.exe /r /t 000 /f
goto :eof

:resume
if exist %~dp0current.txt (
    set /p current=<%~dp0current.txt
) else (
    set current=one
)