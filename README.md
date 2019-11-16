# cygwin-portable-installer <a href="https://github.com/vegardit/cygwin-portable-installer" title="GitHub Repo"><img height="30" src="https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/github.svg?sanitize=true"></a> <a href="https://ansible.com" title="Ansible"><img align="right" height="48" src="https://avatars0.githubusercontent.com/u/1507452?s=48&v=4"></a> <a href="https://mintty.github.io/" title="MinTTY"><img align="right" src="https://raw.githubusercontent.com/mintty/mintty/master/icon/terminal-48.png"></a><a href="https://conemu.github.io/" title="ConEmu"><img align="right" src="https://raw.githubusercontent.com/Maximus5/ConEmu/master/logo/logo-48.png"></a> <a href="https://www.cygwin.com/" title="CygWin"><img align="right" height="48" src="https://upload.wikimedia.org/wikipedia/commons/2/29/Cygwin_logo.svg"></a>

[![License](https://img.shields.io/github/license/vegardit/cygwin-portable-installer.svg?label=license)](#license)

1. [What is it?](#what-is-it)
1. [Features](#features)
1. [Installation](#install)
   1. [Customizing the installer](#customize)
1. [Update](#update)
1. [License](#license)


## What is it?

cygwin-portable-installer is a self-containing Windows batch file to perform an unattended installation of a portable [Cygwin](http://cygwin.org) environment.

The installer has been implemented as a Batch script and not PowerShell script because in some corporate environments execution of PowerShell scripts is
disabled for non-administrative users via group policies.

See also:
1. https://github.com/evandrocoan/MyLinuxSettings
1. https://github.com/MachinaCore/CygwinPortable
1. https://github.com/vegardit/cygwin-portable-installer

![Tabbed Terminal](tabbed_terminal.png)


## Features

* **portable**: you can e.g. install it on an USB sticks and use the same configuration on different computers
* **256-color multi-tabbed shell**: [ConEmu](https://conemu.github.io/) is pre-configured as terminal by default. Alternatively you can choose to use the single tabbed [Mintty](https://mintty.github.io/) terminal.
* **command-line package installer**: [apt-cyg](https://github.com/kou1okada/apt-cyg) package manager will be automatically installed (opt-out via config parameter is possible)
* **adaptive Bash prompt**: [bash-funk](https://github.com/vegardit/bash-funk) will be automatically installed (opt-out via config parameter is possible)
* additional tools (opt-out via config parameter is possible):
    * [Ansible](https://github.com/ansible/ansible): deployment automation tool
    * [AWS CLI](https://github.com/aws/aws-cli): AWS cloud commandline tool
    * [Node.js](https://nodejs.org): JavaScript runtime
    * [testssl.sh](https://testssl.sh/): command line tool to check SSL/TLS configurations of servers


## Installation

1. Get a copy of the installer using one of these ways:
   * Using old-school **Copy & Paste**:
      1. Create a local empty directory where Cygwin shall be installed, e.g. `C:\apps\cygwin-portable`
      1. Download the [cygwin-portable-installer.cmd](cygwin-portable-installer.cmd) file into that directory.
   * Using **Git**:
      1. Clone the project into a local directory, e.g.
         ```batch
         git clone https://github.com/vegardit/cygwin-portable-installer --single-branch --branch master --depth 1 C:\apps\cygwin-portable
         ```

1. (Optional) Open the file [cygwin-portable-installer.cmd](cygwin-portable-installer.cmd) in a text editor and adjust the configuration variables to e.g. set an HTTP Proxy, change the set of pre-installed Cygwin packages, select the terminal (ConEmu or Mintty), etc.
1. Execute the `cygwin-portable-installer.cmd`. This will automatically:
    1. download the 32 or 64bit Cygwin setup.exe depending on your OS
    1. install [Cygwin](http://cygwin.org) with the pre-selected set of packages
    1. install the [ConEmu](https://conemu.github.io/) tabbed terminal
    1. create an init scripts that will keep the installation portable
    1. install the [apt-cyg](https://github.com/kou1okada/apt-cyg) command-line package manager
    1. install the [bash-funk](https://github.com/vegardit/bash-funk) Bash toolbox with it's adaptive Bash prompt
    1. install [Ansible](https://github.com/ansible/ansible)
    1. install [AWS CLI](https://github.com/aws/aws-cli)
    1. install [Node.js](https://nodejs.org)
    1. install [testssl.sh](https://testssl.sh/)
1. Now you can launch your portable Cygwin environment using the newly created `cygwin-portable.cmd` batch file.
    ![Launch Script](launch_script.png)


### <a name="customize"></a>Customizing the installer

You can customize the installer by either directly modifying the default settings in the `cygwin-portable-installer.cmd` file,
or by placing a separate file called `cygwin-portable-installer-config.cmd` next where some or all of these settings are overwritten.

These settings are currently available:

```batch
:: ############################################################################################################
:: CONFIG CUSTOMIZATION START
:: You can customize the following variables to your needs before running the batch file
:: ############################################################################################################

:: Only generate the configuration files, do not install anything
:: It can also be enabled by the command line with the argument -d or --dry-run
set "DRY_RUN_MODE="
:: set "DRY_RUN_MODE=yes"

:: set proxy if required (unfortunately Cygwin setup.exe does not have commandline options to specify proxy user credentials)
set PROXY_HOST=
set PROXY_PORT=8080

:: change the URL to the closest mirror https://cygwin.com/mirrors.html
set CYGWIN_MIRROR=http://cygwin.mirror.constant.com/

:: if set to yes, then, a different user than your current computer account will be created.
:: if set to no, then, you need to set CYGWIN_USERNAME to your current computer user name.
set CREATE_ROOT_USER=no

:: choose a user name under Cygwin
set CYGWIN_USERNAME=root
if not "%CREATE_ROOT_USER%"=="yes" set "CYGWIN_USERNAME=%USERNAME%"

:: one of: auto,64,32 - specifies if 32 or 64 bit version should be installed or automatically detected based on current OS architecture
set CYGWIN_ARCH=auto
set INSTALL_IMPROVED_USER_SETTINGS=yes

:: select the packages to be installed automatically via apt-cyg
set CYGWIN_PACKAGES=bash-completion,bc,curl,expect,git,git-svn,gnupg,inetutils,lz4,mc,nc,openssh,openssl,perl,psmisc,python3,pv,rsync,python2,python2-pip,python3-pip,python2-devel,python3-devel,screen,subversion,unzip,vim,wget,zip,zstd,graphviz,unison2.51,make,gcc-g++,ncdu,gdb,tree

:: if set to 'yes' the local package cache created by cygwin setup will be deleted after installation/update
set DELETE_CYGWIN_PACKAGE_CACHE=no

:: if set to 'yes' the apt-cyg command line package manager (https://github.com/kou1okada/apt-cyg) will be installed automatically
set INSTALL_APT_CYG=yes

:: if set to 'yes' the bash-funk adaptive Bash prompt (https://github.com/vegardit/bash-funk) will be installed automatically
set INSTALL_BASH_FUNK=no

:: if set to 'yes' Node.js (https://nodejs.org/) will be installed automatically
set INSTALL_NODEJS=yes
:: Use of the folder names found here https://nodejs.org/dist/ as version name.
set NODEJS_VERSION=latest-v12.x
:: one of: auto,64,32 - specifies if 32 or 64 bit version should be installed or automatically detected based on current OS architecture
set NODEJS_ARCH=auto

:: if set to 'yes' Ansible (https://github.com/ansible/ansible) will be installed automatically
set INSTALL_ANSIBLE=no
set ANSIBLE_GIT_BRANCH=stable-2.9

:: if set to 'yes' AWS CLI (https://github.com/aws/aws-cli) will be installed automatically
set INSTALL_AWS_CLI=no

:: if set to 'yes' SSH Memory Keys Passphrase Cache (https://github.com/cuviper/ssh-pageant) will be installed automatically
set INSTALL_PAGEANT=no

:: https://georgik.rocks/how-to-fix-incorrect-cygwin-permission-inwindows-7/
set DISABLE_WINDOWS_ACL_HANDLING=no

:: if set to 'yes' testssl.sh (https://testssl.sh/) will be installed automatically
set INSTALL_TESTSSL_SH=yes
:: name of the GIT branch to install from, see https://github.com/drwetter/testssl.sh/
set TESTSSL_GIT_BRANCH=v2.9.5-8

:: use ConEmu based tabbed terminal instead of Mintty based single window terminal, see https://conemu.github.io/
set INSTALL_CONEMU=no
set CON_EMU_OPTIONS=-Title Cygwin-portable -QuitOnClose

:: add more path if required, but at the cost of runtime performance (e.g. slower forks)
set "CYGWIN_PATH=%%SystemRoot%%\system32;%%SystemRoot%%"

:: set Mintty options, see https://cdn.rawgit.com/mintty/mintty/master/docs/mintty.1.html#CONFIGURATION
:: set MINTTY_OPTIONS=--Title Cygwin-portable ^
::   -o Columns=160 ^
::   -o Rows=50 ^
::   -o BellType=0 ^
::   -o ClicksPlaceCursor=yes ^
::   -o CursorBlinks=yes ^
::   -o CursorColour=96,96,255 ^
::   -o CursorType=Block ^
::   -o CopyOnSelect=yes ^
::   -o RightClickAction=Paste ^
::   -o Font="Courier New" ^
::   -o FontHeight=10 ^
::   -o FontSmoothing=None ^
::   -o ScrollbackLines=10000 ^
::   -o Transparency=off ^
::   -o Term=xterm-256color ^
::   -o Charset=UTF-8 ^
::   -o Locale=C

:: ############################################################################################################
:: CONFIG CUSTOMIZATION END
:: ############################################################################################################
```


## Updating your installation

To update installed Cygwin packages execute the generated `cygwin-portable-updater.cmd` file.


# Reparing your installation

After cloning this repository,
you can repair the Cygwin installation with corrupted all files.

To fix it, just run the installer as show bellow on `License`.
1. After that, select `View -> Category` <br/> ![View -> Category](https://i.imgur.com/h8I4l1S.png)
1. Then, hit the sync sign until it shows `Reinstall` <br/> ![Reinstall](https://i.imgur.com/LKLsDJx.gif)
1. Now, hit the `next` button until you finish the Cygwin wizard assistant.


## License

All files are released by this repository with a `git clone` are under the [Apache License 2.0](LICENSE.txt).

The files downloaded by the Cygwin installer without their sources to save space.
1. You can find their sources by running the Cygwin installer and selecting to download the sources.
   ```batch
   start .\setup-x86.exe --no-admin --delete-orphans --download --force-current --no-shortcuts
   ```
1. ![View -> Category](https://i.imgur.com/h8I4l1S.png)

> Can I bundle Cygwin with my product for free?
>
> Starting with Cygwin version 2.5.2, which is LGPL licensed, yes, albeit it's not recommended for interoperability reasons.
>
> Cygwin versions prior to 2.5.2 were GPL licensed.
> If you choose to distribute an older cygwin1.dll,
> you must be willing to distribute the exact source code used to build that copy of cygwin1.dll as per the terms of the GPL.
> If you ship applications that link with older cygwin1.dll,
> you must provide those applications' source code under a GPL-compatible license.
> https://www.cygwin.com/faq.html
> https://cygwin.com/licensing.html


All files are released under the [Apache License 2.0](LICENSE.txt).
