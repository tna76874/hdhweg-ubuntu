# ubuntu homeschooling configuration

### Aim

Sometimes there are PCs/Notebooks available but without an up-to-date operating system. The aim of this notebook is to find the balance between data protection and a “somehow managed" device running a free-of-charge open-source system.  With this playbook an Ubuntu system can be configured to the basic needs of homeschooling.

This repository is the counterpart to the [homeschooling server stack](https://github.com/tna76874/hdhweg-homeschooling-stack), that allows to easily set up a server with different collaborative open-source tools.

### Usb-installation-stick

First download a fresh [Ubuntu image](http://releases.ubuntu.com/18.04.4/ubuntu-18.04.4-desktop-amd64.iso). Then you proceed to create a bootable usb-installation-stick:

[Tutorial for Mac](https://ubuntu.com/tutorials/tutorial-create-a-usb-stick-on-macos#3-prepare-the-usb-stick) 

[Tutorial for Windows](https://ubuntu.com/tutorials/tutorial-create-a-usb-stick-on-windows?_ga=2.155856051.944099286.1569325450-264943242.1569325450#2-requirements) 

If you have prepared your installation-stick, you [install](https://ubuntu.com/tutorials/tutorial-install-ubuntu-desktop#4-boot-from-usb-flash-drive) Ubuntu on the PC/Notebook.

### Installation

When everything is done, you log into your Ubuntu account and open a terminal (shortcut Ctrl+Alt+T). Copy the whole content of the box beneath, paste it into the console and press enter. This will download the setup-skript and install all [basic packages](roles/base/tasks/main.yml) including firewall configurations. For this setup you must enter again your password in the console - dont be confused that there is not shown anything when typing.

```bash
wget -O setup.sh https://raw.githubusercontent.com/tna76874/hdhweg-ubuntu/master/setup.sh && chmod +x setup.sh && sudo bash setup.sh 
```

**or**

when you want to install [additional software packages](roles/custom/tasks/main.yml):

```bash
wget -O setup.sh https://raw.githubusercontent.com/tna76874/hdhweg-ubuntu/master/setup.sh && chmod +x setup.sh && sudo bash setup.sh custom.yml
```

### Update your system

With this setup a cronjob will be installed that runs the `mail.yml` playbook 15 minutes after every startup. With this, all packages gets updated (no dist-upgrades). If you want to get the latest changes of this git-repository, you have to update the git-repository manually and run the notebook again.

```bash
sudo git -C /root/hdhweg-ubuntu pull && sudo ansible-playbook /root/hdhweg-ubuntu/setup.yml
```

### Preparing a custom installation image

If you have multiple devices to set up with this configuration, it might be handy to prepare a custom preconfigured Ubuntu image. If you use a ubuntu operating system, one way to do this is to use Cubic.

```bash
sudo apt-add-repository ppa:cubic-wizard/classic
sudo apt update
sudo apt install cubic
```

Once loaded the original Ubuntu image into Cubic, you will be logged into a root console. Proceed with the installation process of the ansible playbook and further customize the image to your needs. When finnished, you create a boot-installation-stick with your custom image.

