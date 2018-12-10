# cygwin-portable-installer <a href="https://github.com/vegardit/cygwin-portable-installer" title="GitHub Repo"><img height="30" src="https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/github.svg?sanitize=true"></a> <a href="https://ansible.com" title="Ansible"><img align="right" height="48" src="https://avatars0.githubusercontent.com/u/1507452?s=48&v=4"></a> <a href="https://mintty.github.io/" title="MinTTY"><img align="right" src="https://raw.githubusercontent.com/mintty/mintty/master/icon/terminal-48.png"></a><a href="https://conemu.github.io/" title="ConEmu"><img align="right" src="https://raw.githubusercontent.com/Maximus5/ConEmu/master/logo/logo-48.png"></a> <a href="https://www.cygwin.com/" title="CygWin"><img align="right" height="48" src="https://upload.wikimedia.org/wikipedia/commons/2/29/Cygwin_logo.svg"></a>

[![License](https://img.shields.io/github/license/vegardit/cygwin-portable-installer.svg?label=license)](#license)

1. [What is it?](#what-is-it)
1. [Features](#features)
1. [Installation](#install)
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

![Tabbed Terminal](docs/img/tabbed_terminal.png)


## Features

* **portable**: you can e.g. install it on an USB sticks and use the same configuration on different computers
* **256-color multi-tabbed shell**: [ConEmu](https://conemu.github.io/) is pre-configured as terminal by default. Alternatively you can choose to use the single tabbed [Mintty](https://mintty.github.io/) terminal.
* **command-line package installer**: [apt-cyg](https://github.com/kou1okada/apt-cyg) package manager will be automatically installed (opt-out via config parameter is possible)
* **adaptive Bash prompt**: [bash-funk](https://github.com/vegardit/bash-funk) will be automatically installed (opt-out via config parameter is possible)
* additional tools (opt-out via config parameter is possible):
    * [Ansible](https://github.com/ansible/ansible): deployment automation tool
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
    1. install [testssl.sh](https://testssl.sh/)
1. Now you can launch your portable Cygwin environment using the newly created `cygwin-portable.cmd` batch file.
    ![Launch Script](docs/img/launch_script.png)


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
