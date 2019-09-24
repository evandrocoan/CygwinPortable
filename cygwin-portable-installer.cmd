@echo on
::
:: Copyright 2017-2019 by Vegard IT GmbH (https://vegardit.com) and the cygwin-portable-installer contributors.
:: SPDX-License-Identifier: Apache-2.0
::
:: @author Sebastian Thomschke, Vegard IT GmbH


:: ABOUT
:: =====
:: This self-contained Windows batch file creates a portable Cygwin (https://cygwin.com/mirrors.html) installation.
:: By default it automatically installs :
:: - apt-cyg (cygwin command-line package manager, see https://github.com/kou1okada/apt-cyg)
:: - bash-funk (Bash toolbox and adaptive Bash prompt, see https://github.com/vegardit/bash-funk)
:: - ConEmu (multi-tabbed terminal, https://conemu.github.io/)
:: - Ansible (deployment automation tool, see https://github.com/ansible/ansible)
:: - AWS CLI (AWS cloud command line tool, see https://github.com/aws/aws-cli)
:: - testssl.sh (command line tool to check SSL/TLS configurations of servers, see https://testssl.sh/)


:: ============================================================================================================
:: CONFIG CUSTOMIZATION START
:: ============================================================================================================

:: You can customize the following variables to your needs before running the batch file:

:: set proxy if required (unfortunately Cygwin setup.exe does not have commandline options to specify proxy user credentials)
set PROXY_HOST=
set PROXY_PORT=8080

:: change the URL to the closest mirror https://cygwin.com/mirrors.html
set CYGWIN_MIRROR=http://linorg.usp.br/cygwin/

:: if set to yes, then, a different user than your current computer account will be created.
:: if set to no, then, you need to set CYGWIN_USERNAME to your current computer user name.
set CREATE_ROOT_USER=no

:: choose a user name under Cygwin
set CYGWIN_USERNAME=root
if not "%CREATE_ROOT_USER%"=="yes" set "CYGWIN_USERNAME=%USERNAME%"

:: one of: auto,64,32 - specifies if 32 or 64 bit version should be installed or automatically detected based on current OS architecture
set CYGWIN_ARCH=auto
set INSTALL_NODEJS=yes
set INSTALL_IMPROVED_USER_SETTINGS=yes

:: select the packages to be installed automatically via apt-cyg
set CYGWIN_PACKAGES=bash-completion,bc,curl,expect,git,git-svn,gnupg,inetutils,lz4,mc,nc,openssh,openssl,perl,pv,screen,subversion,unzip,vim,wget,zip,zstd,python2,python3,python2-pip,python3-pip,python2-devel,python3-devel,graphviz,unison2.51,make,gcc-g++,ncdu,gdb,tree,psmisc,rsync

:: if set to 'yes' the local package cache created by Cygwin setup will be deleted after installation/update
set DELETE_CYGWIN_PACKAGE_CACHE=no

:: if set to 'yes' the apt-cyg command line package manager (https://github.com/kou1okada/apt-cyg) will be installed automatically
set INSTALL_APT_CYG=yes

:: if set to 'yes' the bash-funk adaptive Bash prompt (https://github.com/vegardit/bash-funk) will be installed automatically
set INSTALL_BASH_FUNK=no

:: if set to 'yes' Ansible (https://github.com/ansible/ansible) will be installed automatically
set INSTALL_ANSIBLE=no
set ANSIBLE_GIT_BRANCH=stable-2.7

:: if set to 'yes' AWS CLI (https://github.com/aws/aws-cli) will be installed automatically
set INSTALL_AWS_CLI=no

:: if set to 'yes' SSH Memory Keys Passphrase Cache (https://github.com/cuviper/ssh-pageant) will be installed automatically
set INSTALL_PAGEANT=no

:: https://georgik.rocks/how-to-fix-incorrect-cygwin-permission-inwindows-7/
set DISABLE_WINDOWS_ACL_HANDLING=no

:: if set to 'yes' testssl.sh (https://testssl.sh/) will be installed automatically
set INSTALL_TESTSSL_SH=yes
:: name of the GIT branch to install from, see https://github.com/drwetter/testssl.sh/
set TESTSSL_GIT_BRANCH=2.9.5

:: use ConEmu based tabbed terminal instead of Mintty based single window terminal, see https://conemu.github.io/
set INSTALL_CONEMU=no
set CON_EMU_OPTIONS=-Title Cygwin-portable ^
 -QuitOnClose

:: add more path if required, but at the cost of runtime performance (e.g. slower forks)
set "CYGWIN_PATH=%%SystemRoot%%\system32;%%SystemRoot%%"

:: set Mintty options, see https://cdn.rawgit.com/mintty/mintty/master/docs/mintty.1.html#CONFIGURATION
rem set MINTTY_OPTIONS=--Title Cygwin-portable ^
rem   -o Columns=160 ^
rem   -o Rows=50 ^
rem   -o BellType=0 ^
rem   -o ClicksPlaceCursor=yes ^
rem   -o CursorBlinks=yes ^
rem   -o CursorColour=96,96,255 ^
rem   -o CursorType=Block ^
rem   -o CopyOnSelect=yes ^
rem   -o RightClickAction=Paste ^
rem   -o Font="Courier New" ^
rem   -o FontHeight=10 ^
rem   -o FontSmoothing=None ^
rem   -o ScrollbackLines=10000 ^
rem   -o Transparency=off ^
rem   -o Term=xterm-256color ^
rem   -o Charset=UTF-8 ^
rem   -o Locale=C

:: ============================================================================================================
:: CONFIG CUSTOMIZATION END
:: ============================================================================================================


echo.
echo ###########################################################
echo # Installing [Cygwin Portable]...
echo ###########################################################
echo.

:: Avoid conflicts with another Cygwin installation already on the system path
:: https://stackoverflow.com/questions/3160058/how-to-get-the-path-of-a-batch-script-without-the-trailing-backslash-in-a-single
set "CYGWIN_DRIVE=%~d0"
set "INSTALL_ROOT=%~dp0.\PortableCygwin"
set "CYGWIN_ROOT=%INSTALL_ROOT%\Cygwin"
set "PATH=%SystemRoot%\system32;%SystemRoot%;%CYGWIN_ROOT%\bin;%ADB_PATH%"

echo Creating Cygwin root [%CYGWIN_ROOT%]...
if not exist "%CYGWIN_ROOT%" (
    md "%CYGWIN_ROOT%" || goto :fail
)

:: create VB script that can download files
:: not using PowerShell which may be blocked by group policies
set "DOWNLOADER=%INSTALL_ROOT%\downloader.vbs"
echo Creating [%DOWNLOADER%] script...

if "%PROXY_HOST%" == "" (
    set DOWNLOADER_PROXY=.
) else (
    set DOWNLOADER_PROXY= req.SetProxy 2, "%PROXY_HOST%:%PROXY_PORT%", ""
)

(
    echo url = Wscript.Arguments(0^)
    echo target = Wscript.Arguments(1^)
    echo WScript.Echo "Downloading '" ^& url ^& "' to '" ^& target ^& "'..."
    echo Set req = CreateObject("WinHttp.WinHttpRequest.5.1"^)
    echo%DOWNLOADER_PROXY%
    echo req.Open "GET", url, False
    echo req.Send
    echo If req.Status ^<^> 200 Then
    echo    WScript.Echo "FAILED to download: HTTP Status " ^& req.Status
    echo    WScript.Quit 1
    echo End If
    echo Set buff = CreateObject("ADODB.Stream"^)
    echo buff.Open
    echo buff.Type = 1
    echo buff.Write req.ResponseBody
    echo buff.Position = 0
    echo buff.SaveToFile target
    echo buff.Close
    echo.
) >"%DOWNLOADER%" || goto :fail

:: https://blogs.msdn.microsoft.com/david.wang/2006/03/27/howto-detect-process-bitness/
if "%CYGWIN_ARCH%" == "auto" (
    if "%PROCESSOR_ARCHITECTURE%" == "x86" (
        if defined PROCESSOR_ARCHITEW6432 (
            set CYGWIN_ARCH=64
        ) else (
            set CYGWIN_ARCH=32
        )
    ) else (
        set CYGWIN_ARCH=64
    )
)

:: download Cygwin 32 or 64 setup exe depending on detected architecture
if "%CYGWIN_ARCH%" == "64" (
    set CYGWIN_SETUP=setup-x86_64.exe
) else (
    set CYGWIN_SETUP=setup-x86.exe
)

if exist "%CYGWIN_ROOT%\%CYGWIN_SETUP%" (
    del "%CYGWIN_ROOT%\%CYGWIN_SETUP%" || goto :fail
)
cscript //Nologo "%DOWNLOADER%" https://cygwin.org/%CYGWIN_SETUP% "%CYGWIN_ROOT%\%CYGWIN_SETUP%" || goto :fail
del "%DOWNLOADER%"

:: Cygwin command line options: https://cygwin.com/faq/faq.html#faq.setup.cli
if "%PROXY_HOST%" == "" (
    set CYGWIN_PROXY=
) else (
    set CYGWIN_PROXY=--proxy "%PROXY_HOST%:%PROXY_PORT%"
)

if "%INSTALL_APT_CYG%" == "yes" (
   set CYGWIN_PACKAGES=wget,ca-certificates,gnupg,%CYGWIN_PACKAGES%
)

if "%INSTALL_PAGEANT%" == "yes" (
   set CYGWIN_PACKAGES=ssh-pageant,%CYGWIN_PACKAGES%
)

if "%INSTALL_IMPROVED_USER_SETTINGS%" == "yes" (
    set CYGWIN_PACKAGES=git,rsync,%CYGWIN_PACKAGES%
)

if "%INSTALL_ANSIBLE%" == "yes" (
    set CYGWIN_PACKAGES=git,openssh,python-jinja2,python-six,python-yaml,%CYGWIN_PACKAGES%
)

:: if conemu install is selected we need to be able to extract 7z archives, otherwise we need to install mintty
if "%INSTALL_CONEMU%" == "yes" (
    set CYGWIN_PACKAGES=mintty,bsdtar,%CYGWIN_PACKAGES%
) else (
    set CYGWIN_PACKAGES=mintty,%CYGWIN_PACKAGES%
)

if "%INSTALL_TESTSSL_SH%" == "yes" (
    set CYGWIN_PACKAGES=bind-utils,%CYGWIN_PACKAGES%
)


echo Running Cygwin setup...
"%CYGWIN_ROOT%\%CYGWIN_SETUP%" --no-admin ^
 --site %CYGWIN_MIRROR% %CYGWIN_PROXY% ^
 --root "%CYGWIN_ROOT%" ^
 --local-package-dir "%CYGWIN_ROOT%\.pkg-cache" ^
 --no-shortcuts ^
 --no-desktop ^
 --delete-orphans ^
 --upgrade-also ^
 --no-replaceonreboot ^
 --quiet-mode ^
 --packages dos2unix,wget,%CYGWIN_PACKAGES% || goto :fail

if "%DELETE_CYGWIN_PACKAGE_CACHE%" == "yes" (
    rd /s /q "%CYGWIN_ROOT%\.pkg-cache" || goto :fail
)

set "Updater_cmd=%INSTALL_ROOT%\cygwin-updater.cmd"
echo Creating updater [%Updater_cmd%]...
(
    echo @echo off
    echo rem https://stackoverflow.com/questions/3160058/how-to-get-the-path-of-a-batch-script-without-the-trailing-backslash-in-a-single
    echo set "CYGWIN_ROOT=%%~dp0.\Cygwin"
    echo set "CYGWIN_PROXY=%CYGWIN_PROXY%"
    echo.
    echo rem change the URL to the closest mirror https://cygwin.com/mirrors.html
    echo set CYGWIN_MIRROR=%CYGWIN_MIRROR%
    echo.
    echo echo.
    echo echo ###########################################################
    echo echo # Updating [Cygwin Portable]...
    echo echo ###########################################################
    echo echo.
    echo "%%CYGWIN_ROOT%%\%CYGWIN_SETUP%" --no-admin ^^
    echo --site %%CYGWIN_MIRROR%% %%CYGWIN_PROXY%% ^^
    echo --root "%%CYGWIN_ROOT%%" ^^
    echo --local-package-dir "%%CYGWIN_ROOT%%\.pkg-cache" ^^
    echo --no-shortcuts ^^
    echo --no-desktop ^^
    echo --delete-orphans ^^
    echo --upgrade-also ^^
    echo --no-replaceonreboot ^^
    echo --quiet-mode ^|^| goto :fail
    echo.
    echo echo DELETE_CYGWIN_PACKAGE_CACHE? '%DELETE_CYGWIN_PACKAGE_CACHE%'
    echo if "%DELETE_CYGWIN_PACKAGE_CACHE%" == "yes" ^(
    echo     rd /s /q "%%CYGWIN_ROOT%%\.pkg-cache" ^|^| goto :fail
    echo ^)
    echo echo.
    echo echo ###########################################################
    echo echo # Updating [Cygwin Portable] succeeded.
    echo echo ###########################################################
    echo.
    echo :typeitright1
    echo rem timeout /T 60
    echo set /p "UserInputPath=Type 'exit' to quit... "
    echo if not "%%UserInputPath%%" == "exit" goto typeitright1
    echo echo exit /0
    echo.
    echo :: Exit the batch file, without closing the cmd.exe, if called from another script
    echo goto :eof
    echo.
    echo :fail
    echo echo.
    echo echo ###########################################################
    echo echo # Updating [Cygwin Portable] FAILED!
    echo echo ###########################################################
    echo.
    echo :typeitright2
    echo rem timeout /T 60
    echo set /p "UserInputPath=Type 'exit' to quit... "
    echo if not "%%UserInputPath%%" == "exit" goto typeitright2
    echo exit /1
) >"%Updater_cmd%" || goto :fail

:: https://stackoverflow.com/questions/9102422/windows-batch-set-inside-if-not-working
set "Cygwin_bat=%CYGWIN_ROOT%\Cygwin.bat"
set "Cygwin_prompt=cygwin-prompt.bat"

if exist "%Cygwin_bat%" (
    echo Disabling default Cygwin launcher [%Cygwin_bat%]...
    if exist "%CYGWIN_ROOT%\%Cygwin_prompt%" (
        del "%CYGWIN_ROOT%\%Cygwin_prompt%" || goto :fail
    )
    rename "%Cygwin_bat%" "%Cygwin_prompt%" || goto :fail
)

set "Init_sh=%CYGWIN_ROOT%\portable-init.sh"
echo Creating [%Init_sh%]...
(
    echo #!/usr/bin/env bash
    echo.
    echo function handle_exception^(^) {
    echo     printf "\\n"
    echo     printf "There was some exception while running this script!\\n"
    echo     printf "Check/revise the error messages and decide if it is safe to continue.\\n"
    echo     read -p "If it is safe, press 'Enter' to continue... Otherwise close this terminal window!" variable1
    echo }
    echo.
    echo # CREATE_ROOT_USER? '%CREATE_ROOT_USER%'
    echo if [[ "w%CREATE_ROOT_USER%" == "wyes" ]]; then
    echo     #
    echo     # Map Current Windows User to root user
    echo     #
    echo     # Check if current Windows user is in /etc/passwd
    echo     USER_SID="$(mkpasswd -c | cut -d':' -f 5)" ^|^| handle_exception
    echo.
    echo     if ! grep -F "$USER_SID" /etc/passwd ^&^>/dev/null; then
    echo         echo "Mapping Windows user '$USER_SID' to Cygwin '$USERNAME' in /etc/passwd..."
    echo         GID="$(mkpasswd -c | cut -d':' -f 4)" ^|^| handle_exception
    echo         echo $USERNAME:unused:1001:$GID:$USER_SID:$HOME:/bin/bash ^>^> /etc/passwd
    echo     fi
    echo.
    echo     # already set in cygwin-environment.cmd:
    echo     # export CYGWIN_ROOT=$(cygpath -w /^)
    echo.
    echo     #
    echo     # adjust Cygwin packages cache path
    echo     #
    echo     pkg_cache_dir=$(cygpath -w "$CYGWIN_ROOT/.pkg-cache"^) ^|^| handle_exception
    echo     sed -i -E "s/.*\\\.pkg-cache/"$'\t'"${pkg_cache_dir//\\/\\\\}/" /etc/setup/setup.rc ^|^| handle_exception
    echo fi
    echo.
    echo # PROXY_HOST? '%PROXY_HOST%'
    echo if ! [[ "w%PROXY_HOST%" == "w" ]]; then
    echo     if [[ "$HOSTNAME" == "%COMPUTERNAME%" ]]; then
    echo         export http_proxy=http://%PROXY_HOST%:%PROXY_PORT%
    echo         export https_proxy=$http_proxy
    echo     fi
    echo fi
    echo.
    echo # INSTALL_CONEMU? '%INSTALL_CONEMU%'
    echo if [[ "w%INSTALL_CONEMU%" == "wyes" ]]; then
    echo     #
    echo     # Installing conemu if required
    echo     #
    echo     conemu_dir=$(cygpath -w "$CYGWIN_ROOT/../conemu"^) ^|^| handle_exception
    echo.
    echo     if [[ ! -e $conemu_dir ]]; then
    echo         echo "*******************************************************************************"
    echo         echo "* Installing ConEmu..."
    echo         echo "*******************************************************************************"
    echo.
    echo         conemu_url="https://github.com$(wget https://github.com/Maximus5/ConEmu/releases/latest -O - 2>/dev/null | egrep '/.*/releases/download/.*/.*7z' -o)" ^&^& \
    echo         echo "Download URL=$conemu_url" ^&^& \
    echo         wget -O "${conemu_dir}.7z" $conemu_url ^&^& \
    echo         mkdir "$conemu_dir" ^&^& \
    echo         bsdtar -xvf "${conemu_dir}.7z" -C "$conemu_dir" ^&^& \
    echo         rm "${conemu_dir}.7z" ^|^| handle_exception
    echo     fi
    echo fi
    echo.
    echo # INSTALL_ANSIBLE? '%INSTALL_ANSIBLE%'
    echo if [[ "w%INSTALL_ANSIBLE%" == "wyes" ]]; then
    echo     #
    echo     # Installing Ansible if not yet installed
    echo     #
    echo     if [[ ! -e /opt ]]; then mkdir /opt; fi
    echo     export PYTHONHOME=/usr/ PYTHONPATH=/usr/lib/python2.7 # workaround for "ImportError: No module named site" when Python for Windows is installed too
    echo     export PATH=$PATH:/opt/ansible/bin
    echo     export PYTHONPATH=$PYTHONPATH:/opt/ansible/lib
    echo.
    echo     if ! hash ansible 2^>/dev/null; then
    echo         echo "*******************************************************************************"
    echo         echo "* Installing [Ansible - %ANSIBLE_GIT_BRANCH%]..."
    echo         echo "*******************************************************************************"
    echo.
    echo         git clone https://github.com/ansible/ansible --branch %ANSIBLE_GIT_BRANCH% --single-branch --depth 1 --shallow-submodules /opt/ansible ^|^| handle_exception
    echo     fi
    echo fi
    echo.
    echo # INSTALL_NODEJS? '%INSTALL_NODEJS%'
    echo if [[ "w%INSTALL_NODEJS%" == "wyes" ]]; then
    echo     #
    echo     # Installing NodeJS if not yet installed
    echo     #
    echo     if [[ ! -x /opt/nodejs ]]; then
    echo         echo "*******************************************************************************"
    echo         echo "* Installing [NodeJS]..."
    echo         echo "*******************************************************************************"
    echo.
    echo         mkdir -p /opt/
    echo         cd /opt/
    echo         curl https://nodejs.org/dist/v10.16.3/node-v10.16.3-win-x64.zip -o nodejs.zip ^|^| handle_exception
    echo.
    echo         echo ""
    echo         echo "Extracting NodeJS to '/opt/nodejs'..."
    echo         unzip -q -d . nodejs.zip ^|^| handle_exception
    echo         mv ./node-v10.16.3-win-x64 ./nodejs ^|^| handle_exception
    echo         rm -rf nodejs.zip ^|^| handle_exception
    echo         cd - ^|^| handle_exception
    echo     fi
    echo fi
    echo.
    echo # INSTALL_APT_CYG? '%INSTALL_APT_CYG%'
    echo if [[ "w%INSTALL_APT_CYG%" == "wyes" ]]; then
    echo     #
    echo     # Installing apt-cyg package manager if not yet installed
    echo     #
    echo     if [[ ! -x /usr/local/bin/apt-cyg ]]; then
    echo         echo "*******************************************************************************"
    echo         echo "* Installing apt-cyg..."
    echo         echo "*******************************************************************************"
    echo.
    echo         wget -O /usr/local/bin/apt-cyg https://raw.githubusercontent.com/kou1okada/apt-cyg/master/apt-cyg ^|^| handle_exception
    echo         chmod +x /usr/local/bin/apt-cyg ^|^| handle_exception
    echo     fi
    echo fi
    echo.
    echo # INSTALL_BASH_FUNK? '%INSTALL_BASH_FUNK%'
    echo if [[ "w%INSTALL_BASH_FUNK%" == "wyes" ]]; then
    echo     #
    echo     # Installing bash-funk if not yet installed
    echo     #
    echo     if [[ ! -e /opt ]]; then
    echo          mkdir /opt ^|^| handle_exception
    echo     fi
    echo.
    echo     if [[ ! -e /opt/bash-funk/bash-funk.sh ]]; then
    echo         echo "*******************************************************************************"
    echo         echo "* Installing [bash-funk]..."
    echo         echo "*******************************************************************************"
    echo.
    echo         if hash git ^&^>/dev/null; then
    echo             git clone https://github.com/vegardit/bash-funk --branch master --single-branch --depth 1 --shallow-submodules /opt/bash-funk ^|^| handle_exception
    echo         elif hash svn ^&^>/dev/null; then
    echo             svn checkout https://github.com/vegardit/bash-funk/trunk /opt/bash-funk ^|^| handle_exception
    echo         else
    echo             mkdir /opt/bash-funk ^&^& \
    echo             cd /opt/bash-funk ^&^& \
    echo             wget -qO- --show-progress https://github.com/vegardit/bash-funk/tarball/master ^| tar -xzv --strip-components 1 ^|^| handle_exception
    echo         fi
    echo     fi
    echo fi
    echo.
    echo # INSTALL_TESTSSL_SH? '%INSTALL_TESTSSL_SH%'
    echo if [[ "w%INSTALL_TESTSSL_SH%" == "wyes" ]]; then
    echo     #
    echo     # Installing testssl.sh if not yet installed
    echo     #
    echo     if [[ ! -e /opt ]]; then
    echo          mkdir /opt ^|^| handle_exception
    echo     fi
    echo.
    echo     if [[ ! -e /opt/testssl/testssl.sh ]]; then
    echo         echo "*******************************************************************************"
    echo         echo "* Installing [testssl.sh - %TESTSSL_GIT_BRANCH%]..."
    echo         echo "*******************************************************************************"
    echo.
    echo         if hash git ^&^>/dev/null; then
    echo             git clone https://github.com/drwetter/testssl.sh --branch %TESTSSL_GIT_BRANCH% --single-branch --depth 1 --shallow-submodules /opt/testssl ^|^| handle_exception
    echo         elif hash svn ^&^>/dev/null; then
    echo             svn checkout https://github.com/drwetter/testssl.sh/branches/%TESTSSL_GIT_BRANCH% /opt/testssl ^|^| handle_exception
    echo         else
    echo             mkdir /opt/testssl ^&^& \
    echo             cd /opt/testssl ^&^& \
    echo             wget -qO- --show-progress https://github.com/drwetter/testssl.sh/tarball/%TESTSSL_GIT_BRANCH% ^| tar -xzv --strip-components 1 ^|^| handle_exception
    echo         fi
    echo         chmod +x /opt/testssl/testssl.sh ^|^| handle_exception
    echo     fi
    echo fi

) >"%Init_sh%" || goto :fail

"%CYGWIN_ROOT%\bin\dos2unix" "%Init_sh%" || goto :fail

set "Start_cmd=%INSTALL_ROOT%\cygwin-environment.cmd"
echo Creating launcher [%Start_cmd%]...
(
    echo @echo on
    echo setlocal enabledelayedexpansion
    echo set "CWD=%%cd%%"
    echo set "CYGWIN_DRIVE=%%~d0"
    echo rem https://stackoverflow.com/questions/3160058/how-to-get-the-path-of-a-batch-script-without-the-trailing-backslash-in-a-single
    echo set "CYGWIN_ROOT=%%~dp0.\Cygwin"
    echo.
    echo for %%%%i in ^(adb.exe^) do ^(
    echo     set "ADB_PATH=%%%%~dp$PATH:i"
    echo ^)
    echo.
    echo set "PATH=%CYGWIN_PATH%;%%CYGWIN_ROOT%%\bin;%%ADB_PATH%%"
    echo set "ALLUSERSPROFILE=%%CYGWIN_ROOT%%\.ProgramData"
    echo set "ProgramData=%%ALLUSERSPROFILE%%"
    echo set "CYGWIN=nodosfilewarning"
    echo.
    echo set "USERNAME=%CYGWIN_USERNAME%"
    echo set "HOME=/home/%%USERNAME%%"
    echo set "SHELL=/bin/bash"
    echo set "HOMEDRIVE=%%CYGWIN_DRIVE%%"
    echo set "HOMEPATH=%%CYGWIN_ROOT%%\home\%%USERNAME%%"
    echo set "GROUP=None"
    echo set "GRP="
    echo.
    echo echo DISABLE_WINDOWS_ACL_HANDLING? %DISABLE_WINDOWS_ACL_HANDLING%
    echo if "%DISABLE_WINDOWS_ACL_HANDLING%"=="yes" ^(
    echo      echo Replacing [/etc/fstab]...
    echo      ^(
    echo          echo # /etc/fstab
    echo          echo # IMPORTANT: this files is recreated on each start by cygwin-environment.cmd
    echo          echo #
    echo          echo #    This file is read once by the first process in a Cygwin process tree.
    echo          echo #    To pick up changes, restart all Cygwin processes.  For a description
    echo          echo #    see https://cygwin.com/cygwin-ug-net/using.html#mount-table
    echo          echo.
    echo          echo # This is default anyway:
    echo          echo # none /cygdrive cygdrive binary,posix=0,user 0 0
    echo          echo.
    echo          echo # https://georgik.rocks/how-to-fix-incorrect-cygwin-permission-inwindows-7/
    echo          echo # noacl = disable Cygwin's - apparently broken - special ACL treatment which prevents apt-cyg and other programs from working
    echo          echo none /cygdrive cygdrive binary,noacl,posix=0,user 0 0
    echo          echo.
    echo      ^) ^> "%%CYGWIN_ROOT%%\etc\fstab" ^|^| goto :fail
    echo ^)
    echo.
    echo %%CYGWIN_DRIVE%%
    echo chdir "%%CYGWIN_ROOT%%\bin" ^|^| goto :fail
    echo bash "%%CYGWIN_ROOT%%\portable-init.sh" ^|^| goto :fail
    echo.
    echo if "%%1" == "" (
    if "%INSTALL_CONEMU%" == "yes" (
        if "%CYGWIN_ARCH%" == "64" (
            echo rem https://stackoverflow.com/questions/3160058/how-to-get-the-path-of-a-batch-script-without-the-trailing-backslash-in-a-single
            echo   start "" "%%~dp0.\conemu\ConEmu64.exe" %CON_EMU_OPTIONS% ^|^| goto :fail
        ) else (
            echo   start "" "%%~dp0.\conemu\ConEmu.exe" %CON_EMU_OPTIONS% ^|^| goto :fail
        )
    ) else (
        echo   mintty --nopin %MINTTY_OPTIONS% --icon %%CYGWIN_ROOT%%\Cygwin-Terminal.ico - ^|^| goto :fail
    )
    echo ^) else (
    echo   if "%%1" == "no-mintty" (
    echo     bash --login -i ^|^| goto :fail
    echo   ^) else (
    echo     bash --login -c %%* ^|^| goto :fail
    echo   ^)
    echo ^)
    echo.
    echo cd "%%CWD%%" ^|^| goto :fail
    echo.
    echo :: Exit the batch file, without closing the cmd.exe, if called from another script
    echo goto :eof
    echo.
    echo :fail
    echo rem timeout /T 60
    echo set /p "UserInputPath=Type 'exit' to quit... "
    echo if not "%UserInputPath%" == "exit" goto fail
) >"%Start_cmd%" || goto :fail

:: launching Bash once to initialize user home dir
call "%Start_cmd%" whoami || goto :fail

set Start_Mintty=%INSTALL_ROOT%\cygwin-terminal.cmd
echo Creating launcher [%Start_Mintty%]...
(
    echo @echo on
    echo setlocal enabledelayedexpansion
    echo.
    echo rem https://stackoverflow.com/questions/3160058/how-to-get-the-path-of-a-batch-script-without-the-trailing-backslash-in-a-single
    echo set "CWD=%%cd%%"
    echo set "CYGWIN_DRIVE=%%~d0"
    echo set "CYGWIN_ROOT=%%~dp0.\Cygwin"
    echo.
    echo set "USERNAME=%CYGWIN_USERNAME%"
    echo set "HOME=/home/%%USERNAME%%"
    echo set "SHELL=/bin/bash"
    echo set "HOMEDRIVE=%%CYGWIN_DRIVE%%"
    echo set "HOMEPATH=%%CYGWIN_ROOT%%\home\%%USERNAME%%"
    echo set "GROUP=None"
    echo set "GRP="
    echo.
    echo %%CYGWIN_DRIVE%%
    echo chdir "%%CYGWIN_ROOT%%\bin" ^|^| goto :fail
    echo.
    echo if "%%1" == "" (
    echo   mintty --nopin %MINTTY_OPTIONS% --icon %%CYGWIN_ROOT%%\Cygwin-Terminal.ico - ^|^| goto :fail
    echo ^) else (
    echo   if "%%1" == "no-mintty" (
    echo     bash --login -i ^|^| goto :fail
    echo   ^) else (
    echo     bash --login -c %%* ^|^| goto :fail
    echo   ^)
    echo ^)
    echo.
    echo cd "%%CWD%%" ^|^| goto :fail
    echo.
    echo :: Exit the batch file, without closing the cmd.exe, if called from another script
    echo goto :eof
    echo.
    echo :fail
    echo rem timeout /T 60
    echo set /p "UserInputPath=Type 'exit' to quit... "
    echo if not "%UserInputPath%" == "exit" goto fail
) >"%Start_Mintty%" || goto :fail

:: https://stackoverflow.com/questions/9102422/windows-batch-set-inside-if-not-working
set "InstallImprovedSettings=%CYGWIN_ROOT%\cygwin-install-improved-settings.sh"

:: https://stackoverflow.com/questions/57651023/how-do-i-run-a-command-with-spaces-on-the-name-the-filename-directory-name-or
for /F "tokens=*" %%g in ('^""%CYGWIN_ROOT%\bin\cygpath.exe" -u "%InstallImprovedSettings%"^"') do (
set "InstallImprovedSettingsUnix=%%g"
) || goto :fail

if "%INSTALL_IMPROVED_USER_SETTINGS%" == "yes" (
    echo Creating launcher [%InstallImprovedSettings%]...
    (
        echo #
        echo # Installing improved user settings
        echo #
        echo echo "*******************************************************************************"
        echo echo "* Installing [improved user settings]..."
        echo echo "*******************************************************************************"
        echo /bin/git --version ^|^| exit $?
        echo /bin/git clone https://github.com/evandrocoan/MyLinuxSettings --single-branch --depth 1 --shallow-submodules "/home/%CYGWIN_USERNAME%/Downloads/MyLinuxSettings" ^|^| exit $?
        echo /bin/rsync -r -t -v -s "/home/%CYGWIN_USERNAME%/Downloads/MyLinuxSettings/" "/home/%CYGWIN_USERNAME%/" ^|^| exit $?
        echo /bin/rm -rf "/home/%CYGWIN_USERNAME%/Downloads/MyLinuxSettings/" ^|^| exit $?
        echo.
    ) >"%InstallImprovedSettings%" || goto :fail
    "%CYGWIN_ROOT%\bin\dos2unix" "%InstallImprovedSettings%" || goto :fail

    "%CYGWIN_ROOT%\bin\bash" "%InstallImprovedSettingsUnix%" || goto :fail
    "%CYGWIN_ROOT%\bin\rm" -f "%InstallImprovedSettingsUnix%" || goto :fail
)

echo CONEMU_CONFIG?
set "conemu_config=%INSTALL_ROOT%\conemu\ConEmu.xml"
if "%INSTALL_CONEMU%" == "yes" (
    (
        echo ^<?xml version="1.0" encoding="UTF-8"?^>
        echo ^<key name="Software"^>^<key name="ConEmu"^>^<key name=".Vanilla" build="170622"^>
        echo    ^<value name="StartTasksName" type="string" data="{Bash::CygWin bash}"/^>
        echo    ^<value name="ColorTable00" type="dword" data="00000000"/^>
        echo    ^<value name="ColorTable01" type="dword" data="00ee0000"/^>
        echo    ^<value name="ColorTable02" type="dword" data="0000cd00"/^>
        echo    ^<value name="ColorTable03" type="dword" data="00cdcd00"/^>
        echo    ^<value name="ColorTable04" type="dword" data="000000cd"/^>
        echo    ^<value name="ColorTable05" type="dword" data="00cd00cd"/^>
        echo    ^<value name="ColorTable06" type="dword" data="0000cdcd"/^>
        echo    ^<value name="ColorTable07" type="dword" data="00e5e5e5"/^>
        echo    ^<value name="ColorTable08" type="dword" data="007f7f7f"/^>
        echo    ^<value name="ColorTable09" type="dword" data="00ff5c5c"/^>
        echo    ^<value name="ColorTable10" type="dword" data="0000ff00"/^>
        echo    ^<value name="ColorTable11" type="dword" data="00ffff00"/^>
        echo    ^<value name="ColorTable12" type="dword" data="000000ff"/^>
        echo    ^<value name="ColorTable13" type="dword" data="00ff00ff"/^>
        echo    ^<value name="ColorTable14" type="dword" data="0000ffff"/^>
        echo    ^<value name="ColorTable15" type="dword" data="00ffffff"/^>
        echo    ^<value name="KeyboardHooks" type="hex" data="01"/^>
        echo    ^<value name="UseInjects" type="hex" data="01"/^>
        echo    ^<value name="Update.CheckOnStartup" type="hex" data="00"/^>
        echo    ^<value name="Update.CheckHourly" type="hex" data="00"/^>
        echo    ^<value name="Update.UseBuilds" type="hex" data="02"/^>
        echo    ^<value name="FontUseUnits" type="hex" data="01"/^>
        echo    ^<value name="FontSize" type="ulong" data="13"/^>
        echo    ^<value name="StatusFontHeight" type="long" data="12"/^>
        echo    ^<value name="TabFontHeight" type="long" data="12"/^>
        echo    ^<key name="HotKeys"^>
        echo        ^<value name="KeyMacro01" type="dword" data="00001157"/^>
        echo        ^<value name="KeyMacro01.Text" type="string" data="Close(1,1)"/^>
        echo    ^</key^>
        echo    ^<value name="FontName" type="string" data="Courier New"/^>
        echo    ^<value name="Anti-aliasing" type="ulong" data="3"/^>
        echo    ^<value name="DefaultBufferHeight" type="long" data="9999"/^>
        echo    ^<value name="ClipboardConfirmEnter" type="hex" data="00"/^>
        echo    ^<value name="StatusBar.Flags" type="dword" data="00000003"/^>
        echo    ^<value name="StatusFontFace" type="string" data="Tahoma"/^>
        echo    ^<value name="StatusBar.Color.Back" type="dword" data="007f7f7f"/^>
        echo    ^<value name="StatusBar.Color.Light" type="dword" data="00ffffff"/^>
        echo    ^<value name="StatusBar.Color.Dark" type="dword" data="00000000"/^>
        echo    ^<value name="StatusBar.Hide.VCon" type="hex" data="01"/^>
        echo    ^<value name="StatusBar.Hide.CapsL" type="hex" data="00"/^>
        echo    ^<value name="StatusBar.Hide.ScrL" type="hex" data="00"/^>
        echo    ^<value name="StatusBar.Hide.ABuf" type="hex" data="01"/^>
        echo    ^<value name="StatusBar.Hide.Srv" type="hex" data="01"/^>
        echo    ^<value name="StatusBar.Hide.Transparency" type="hex" data="01"/^>
        echo    ^<value name="StatusBar.Hide.New" type="hex" data="01"/^>
        echo    ^<value name="StatusBar.Hide.Sync" type="hex" data="01"/^>
        echo    ^<value name="StatusBar.Hide.Proc" type="hex" data="01"/^>
        echo    ^<value name="StatusBar.Hide.Title" type="hex" data="00"/^>
        echo    ^<value name="StatusBar.Hide.Time" type="hex" data="00"/^>
        echo    ^<value name="TabFontFace" type="string" data="Tahoma"/^>
        echo    ^<key name="Tasks"^>
        echo        ^<value name="Count" type="long" data="1"/^>
        echo        ^<key name="Task1"^>
        echo            ^<value name="Name" type="string" data="{Bash::CygWin bash}"/^>
        echo            ^<value name="Flags" type="dword" data="00000005"/^>
        echo            ^<value name="Hotkey" type="dword" data="0000a254"/^>
        echo            ^<value name="GuiArgs" type="string" data=""/^>
        echo            ^<value name="Cmd1" type="string" data="%%ConEmuBaseDirShort%%\conemu-cyg-%CYGWIN_ARCH%.exe -new_console:m:/cygdrive -new_console:p1:C:&quot;%%ConEmuDir%%\..\Cygwin\Cygwin.ico&quot;:d:&quot;%%ConEmuDir%%\..\Cygwin\home\%CYGWIN_USERNAME%&quot;"/^>
        echo            ^<value name="Active" type="long" data="0"/^>
        echo            ^<value name="Count" type="long" data="1"/^>
        echo        ^</key^>
        echo    ^</key^>
        echo ^</key^>^</key^>^</key^>
    )> "%conemu_config%" || goto :fail
)

set "Bashrc_sh=%CYGWIN_ROOT%\home\%CYGWIN_USERNAME%\.bashrc"

echo INSTALL_PAGEANT? '%INSTALL_PAGEANT%'
if "%INSTALL_PAGEANT%" == "yes" (
    :: https://github.com/cuviper/ssh-pageant
    echo Adding ssh-pageant to [/home/%CYGWIN_USERNAME%/.bashrc]...
    find "ssh-pageant" "%Bashrc_sh%" >NUL || (
        echo.
        echo eval $(/usr/bin/ssh-pageant -r -a "/tmp/.ssh-pageant-$USERNAME"^)
    ) >>"%Bashrc_sh%" || goto :fail
)

echo PROXY_HOST? '%PROXY_HOST%'
if not "%PROXY_HOST%" == "" (
    echo Adding proxy settings for host [%COMPUTERNAME%] to [/home/%CYGWIN_USERNAME%/.bashrc]...
    find "export http_proxy" "%Bashrc_sh%" >NUL || (
        echo.
        echo if [[ "$HOSTNAME" == "%COMPUTERNAME%" ]]; then
        echo     export http_proxy=http://%PROXY_HOST%:%PROXY_PORT%
        echo     export https_proxy=$http_proxy
        echo     export no_proxy="::1,127.0.0.1,localhost,169.254.169.254,%COMPUTERNAME%,*.%USERDNSDOMAIN%"
        echo     export HTTP_PROXY=$http_proxy
        echo     export HTTPS_PROXY=$http_proxy
        echo     export NO_PROXY=$no_proxy
        echo fi
    ) >>"%Bashrc_sh%" || goto :fail
)

echo INSTALL_NODEJS? '%INSTALL_NODEJS%'
if "%INSTALL_NODEJS%" == "yes" (
    echo Adding NodeJS to PATH in [/home/%CYGWIN_USERNAME%/.bashrc]...
    find "nodejs" "%Bashrc_sh%" >NUL || (
        (
            echo.
            echo export PATH=$PATH:/opt/nodejs
        ) >>"%Bashrc_sh%" || goto :fail
    )
)

echo INSTALL_ANSIBLE? '%INSTALL_ANSIBLE%'
if "%INSTALL_ANSIBLE%" == "yes" (
    echo Adding Ansible to PATH in [/home/%CYGWIN_USERNAME%/.bashrc]...
    find "ansible" "%Bashrc_sh%" >NUL || (
        (
            echo.
            echo export PYTHONPATH=$PYTHONPATH:/opt/ansible/lib
            echo export PATH=$PATH:/opt/ansible/bin
        ) >>"%Bashrc_sh%" || goto :fail
    )
)

echo INSTALL_TESTSSL_SH? '%INSTALL_TESTSSL_SH%'
if "%INSTALL_TESTSSL_SH%" == "yes" (
    echo Adding testssl.sh to PATH in [/home/%CYGWIN_USERNAME%/.bashrc]...
    find "testssl" "%Bashrc_sh%" >NUL || (
        (
            echo.
            echo export PATH=$PATH:/opt/testssl
        ) >>"%Bashrc_sh%" || goto :fail
    )
)

echo INSTALL_BASH_FUNK? '%INSTALL_BASH_FUNK%'
if "%INSTALL_BASH_FUNK%" == "yes" (
    echo Adding bash-funk to [/home/%CYGWIN_USERNAME%/.bashrc]...
    find "bash-funk" "%Bashrc_sh%" >NUL || (
        (
            echo.
            echo source /opt/bash-funk/bash-funk.sh
        ) >>"%Bashrc_sh%" || goto :fail
    )
)
"%CYGWIN_ROOT%\bin\dos2unix" "%Bashrc_sh%" || goto :fail

echo.
echo ###########################################################
echo # Installing [Cygwin Portable] succeeded.
echo ###########################################################
echo.
echo Use [%Start_cmd%] to launch Cygwin Portable.
echo.

:typeitright1
rem timeout /T 60
set /p "UserInputPath=Type 'exit' to quit... "
if not "%UserInputPath%" == "exit" goto typeitright1

:: Exit the batch file, without closing the cmd.exe, if called from another script
goto :eof

:fail
    if exist "%DOWNLOADER%" (
        del "%DOWNLOADER%"
    )
    echo.
    echo ###########################################################
    echo # Installing [Cygwin Portable] FAILED!
    echo ###########################################################
    echo.

    :typeitright2
    rem timeout /T 60
    set /p "UserInputPath=Type 'exit' to quit... "
    if not "%UserInputPath%" == "exit" goto typeitright2
    exit /b 1
