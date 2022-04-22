# ubuntu desktop configuration

Ubuntu versions supported: 20.04, 22.04

## Aim

Sometimes there are PCs/Notebooks available but without an up-to-date operating system. The aim of this notebook is to find the balance between data protection and a “somehow managed" device running a free-of-charge open-source system. 

This repository is the counterpart to the [homeschooling server stack](https://github.com/tna76874/hdhweg-homeschooling-stack), that allows to easily set up a server with different collaborative open-source tools.

## Youtube

* [Installing](https://www.youtube.com/watch?v=hHPaVvq81t4) an Ubuntu system.
* First [startup and update](https://www.youtube.com/watch?v=dJ-NsT-xauk) of a WeG Ubuntu installation.
* [(Re)Install](https://www.youtube.com/watch?v=8Hjj5Kpx7tc) WeG Ubuntu on any Ubuntu installation.
* Just showing some random [features](https://www.youtube.com/watch?v=bTgEzdhq4nw) of Ubuntu.

## Usb-installation-stick

First download a fresh [Ubuntu image](http://releases.ubuntu.com/18.04.4/ubuntu-18.04.4-desktop-amd64.iso). Then you proceed to create a bootable usb-installation-stick:

[Tutorial for Mac](https://ubuntu.com/tutorials/tutorial-create-a-usb-stick-on-macos#3-prepare-the-usb-stick) 

[Tutorial for Windows](https://ubuntu.com/tutorials/tutorial-create-a-usb-stick-on-windows?_ga=2.155856051.944099286.1569325450-264943242.1569325450#2-requirements) 

If you have prepared your installation-stick, you [install](https://ubuntu.com/tutorials/tutorial-install-ubuntu-desktop#4-boot-from-usb-flash-drive) Ubuntu on the PC/Notebook.

## Installation

When everything is done, you log into your Ubuntu account and open a terminal (shortcut Ctrl+Alt+T). Copy the whole content of the box beneath, paste it into the console and press enter. This will download the setup-skript and install all [basic packages](roles/setup/defaults/main.yml) including firewall configurations. For this setup you must enter again your password in the console - don't be confused that there is not shown anything when typing.

```bash
wget -qO- https://raw.githubusercontent.com/tna76874/hdhweg-ubuntu/master/install | bash
```

OPTIONAL: When you want to install [additional software packages](roles/setup/defaults/main.yml) execute:

```bash
bigupdate
```

#### Custom commands

With this configuration a few custom console commands are defined. These will be initialized within the `.bashrc` of every user. Check the details [here](roles/base/templates/wegrc.j2) .

#### Automatic pulls and updates

By default automatic pulls from this git repository gets triggered 10 minutes after each system startup. 15 minutes after every reboot, the base role will be run once. To customize this behavior just edit `vars.yml` to your needs. 

```bash
sudo nano /root/.config/vars_sysconfig.yml
```

#### Package management

This repository uses `apt`, `snap` and `flatpak` as package management systems. If possible, a flatpak version is preferred. 

## Updates and maintenance

With this setup two cronjobs will be installed. One gets triggered 10 minutes after every startup and updates the git-repository containing the playbooks. The second runs the `main.yml` playbook 15 minutes after every startup. Please check the content of [main.yml](roles/custom/tasks/main.yml) carefully and disable automatic pulls (described above) if you do not want this role to be kept up to date with this repository. **Disabling automatic pulls is recommended if you have experience with linux systems!**  In any case, every other role except `main.yml` have to be triggered manually. To pull and install the latest software of this repository you have just to type in the terminal and confirm with your password:

```bash
update
```

The update process for the bigger software bundle gets tiggered with `bigupdate`. 

>**TL;DR**  --> Follow the ubuntu pop-ups to upgrade your system or type `update` in command line to trigger a system upgrade including latest update of this repo manually.

## Uninstall

To remove the playbook from the system, just execute `uninstall`. Please note, that this command will not remove installed programms and apt-sources but only the playbook and the cronjobs.

```bash
uninstall
```



## Documentation of hardware components

Sometimes it is mandatory to document the hardware components of the system. For this purpose you can generate a pdf file with a short overview of the components with the tool `inxi`. You find the document in the downloads folder.

```bash
hwpdf
```

If it is mandatory to wipe the harddrive, you can use another function. With this command, you first select a harddrive to wipe (e.g. sda) and the wipe process will be added to the overview of the system components. This command can only be executed from within a ubuntu-live system (username "ubuntu").

```bash
shreddrive
```

## Preparing a custom installation image

If you have multiple devices to set up with this configuration, it might be handy to prepare a custom preconfigured Ubuntu image. If you use a ubuntu operating system, one way to do this is to use [Cubic](https://launchpad.net/cubic) ([Example](https://askubuntu.com/questions/741753/how-to-use-cubic-to-create-a-custom-ubuntu-live-cd-image)). In the big software bundle `cubic` is already included.

```bash
sudo apt-add-repository ppa:cubic-wizard/release
sudo apt update
sudo apt install cubic
```

Once loaded the original [Ubuntu image](http://releases.ubuntu.com/18.04.4/ubuntu-18.04.4-desktop-amd64.iso) into Cubic, you will be logged into a root console. Proceed with the installation process of the ansible playbook and further customize the image to your needs. When finnished, you create a boot-installation-stick with your custom image.

There might be problems with the DNS of the chroot environment of cubic running on ubuntu 18.04. As a workaround you can try:

```bash
mkdir /run/systemd/resolve/
echo "nameserver 127.0.0.53
search network" | tee /run/systemd/resolve/resolv.conf
ln -sr /run/systemd/resolve/resolv.conf /run/systemd/resolve/stub-resolv.conf
```



## Miscellaneous

#### TeamViewer

By default TeamViewer gets installed. Every time the playbook runs (e.g. 15 min after startup) it will be ensured, that the TeamViewer daemon ist **disabled**! So if you start TeamViewer there will be reported "a problem with your internet connection". Actually it is just the switched-off daemon.

If TeamViewer is needed, you have to enable the daemon manually by typing in the terminal:

```bash
sudo killall /opt/teamviewer/tv_bin/TeamViewer; sudo teamviewer daemon enable
```

An alias for this command is `twstart`.

#### Fritzbox

[Roger Router](https://flathub.org/apps/details/org.tabos.roger) is an excellent addition if you already run a Fritzbox.

```bash
install_fritzbox
```

Check the documentation on [wiki.ubuntuusers.de](https://wiki.ubuntuusers.de/Fritzbox/Roger_Router/).

* Dial with your DECT Phone: \#96\*3\*
* Dial with your DECT Phone: \#96\*5\*

#### pi-hole

If you care about your privacy using pi-hole as an local DNS-server is recommended. A pi-hole Docker-container will handle and filter all DNS-requests. 

```bash
install_pihole
```

The pi-hole server can be customized and administrated via the web interface http://localhost:8008/admin/index.php  . To remove pi-hole execute `uninstall_pihole` .