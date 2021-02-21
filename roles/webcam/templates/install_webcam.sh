#!/bin/bash
# Define paths
SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")

TMP="/tmp/"
OBSDIR="$DIR/obs-studio"
OBSLOOPDIR="$DIR/obs-v4l2"
V4L2LOOPBACKDIR="$DIR/v4l2loopback"
AKVCAMDIR="$DIR/akvcam"

# Define functions
function pulllatest() {
cd "$1"
git clean -xdf
branchcount=$(git for-each-ref --format='%(refname:short)' refs/heads/* | grep main | wc -l)
if [[ "$branchcount" == "1" ]]; then
    git checkout main > /dev/null 2>&1
    echo "Checkout $1 on main. Pulling latest changes."
else
    git checkout master > /dev/null 2>&1 
    echo "Checkout $1 on master. Pulling latest changes."
fi
git pull > /dev/null 2>&1
git show-branch
}
export -f pulllatest

repocleanup() {
# checkout on main branch and cleanup all non-repo files
pulllatest "$1"

#pull latest files of all submodules
git submodule update --init --recursive
git submodule foreach -q 'echo $sm_path' | xargs -i bash -c 'pulllatest {}'
}


install_obsloop() {
    sudo apt install libobs-dev -y

    # cleanup and update
    repocleanup "$OBSLOOPDIR"
    repocleanup "$OBSDIR"

    # run scripts
    cd "$OBSLOOPDIR"
    mkdir -p $OBSLOOPDIR/build
    cd "$OBSLOOPDIR"/build
    cmake -DLIBOBS_INCLUDE_DIR="$OBSDIR/libobs" -DCMAKE_INSTALL_PREFIX=/usr "$OBSLOOPDIR"
    make -j4
    sudo make install

    # #link plugins into own home directory
    # mkdir -p ${HOME}/.config/obs-studio/plugins/v4l2sink/{data,bin/64bit}
    # ln -sf /usr/lib/obs-plugins/v4l2sink.so ${HOME}/.config/obs-studio/plugins/v4l2sink/bin/64bit/
    # ln -sf /usr/share/obs-plugins/v4l2sink/locale ${HOME}/.config/obs-studio/plugins/v4l2sink/data/
}

install_loopback() {
# cleanup and update
repocleanup "$V4L2LOOPBACKDIR"

# run scripts
### installing virtual webcam
sudo apt install v4l2loopback-dkms -y
OPTIONS="options v4l2loopback exclusive_caps=1,1 
max_buffer=10,10 
video_nr=8,9 
card_label=\"obs, fakecam\""

sudo echo $OPTIONS | sudo tee /etc/modprobe.d/v4l2loopback.conf
echo 'v4l2loopback' | sudo tee /etc/modules-load.d/v4l2loopback.conf
sudo modprobe -r v4l2loopback
sudo modprobe v4l2loopback
sudo apt remove v4l2loopback-dkms -y
sudo apt-get install linux-generic -y
sudo apt install dkms -y

cd "$V4L2LOOPBACKDIR"
make
sudo cp -R . /usr/src/v4l2loopback-1.1
sudo dkms add -m v4l2loopback -v 1.1
sudo dkms build -m v4l2loopback -v 1.1
sudo dkms install -m v4l2loopback -v 1.1
}

install_akvcam() {
    # cleanup and update
    repocleanup "$AKVCAMDIR"

    #Checkout to latest release of akvcam
    cd "$AKVCAMDIR"
    VERSION=$(git describe --tags)
    git checkout ${VERSION}

    # run scripts
    cd "$AKVCAMDIR"/src
    make
    make clean

    sudo mkdir -p /usr/src/akvcam-${VERSION}
    sudo cp -ar * /usr/src/akvcam-${VERSION}
    sudo dkms install akvcam/${VERSION}

    # cleanup folder
    cd "$AKVCAMDIR"
    git clean -xdf
}

install_droidcam() {
    cd "$TMP"

    # directely download latest binary from source
    DOWNLOAD_URL=$( curl -s https://api.github.com/repos/dev47apps/droidcam/releases/latest | grep 'browser_' | cut -d\" -f4 )
    DROIDCAM_ZIP="$TMP/droidcam_latest.zip"

    # cleanup
    rm "$DROIDCAM_ZIP"
    rm -rf "$TMP"/droidcam
    sudo rmmod v4l2loopback_dc > /dev/null 2>&1 || echo "No driver to unload"

    # download
    wget -O "$DROIDCAM_ZIP" "$DOWNLOAD_URL"
    unzip droidcam_latest.zip -d droidcam

    # install
    cd droidcam && sudo ./install-client

    sudo apt install linux-headers-`uname -r` gcc make

    cd "$TMP"/droidcam

    sed -i \
        -e "s#WIDTH=.*#WIDTH=\"960\"#g" \
        -e "s#HEIGHT=.*#HEIGHT=\"720\"#g" \
        "$TMP"/droidcam/install.common

    sudo ./install-video

    cd "$TMP"/droidcam
    sudo ./install-sound
}

desktopentry_droidcam() {
echo -e "
[Desktop Entry]\n\
Name=Droidcam\n\
GenericName=Droidcam\n\
Comment=Smartphone webcam\n\
Comment[de]=Smaprtphone webcam\n\
Exec=droidcam\n\
Terminal=false\n\
X-MultipleArgs=false\n\
Type=Application\n\
Categories=Network;\n\
StartupWMClass=Droidcam 3\n\
StartupNotify=true\n\
" \
> ${HOME}/.local/share/applications/droidcam.desktop
}

# ###### Parsing arguments

#Usage print
usage() {
    echo "Usage: $0 -[l|c|a|o|d|p|h]" >&2
    echo "
   -l,    install loopback of virtual webcams
   -c,    install akvcam
   -a,    install droidcam
   -o,    install obs loop
   -d,    Desktop entry
   -p,    pull submodules
   -h,    Print this help text

If the script will be called without parameters, it will run:
    $0 -p -l -c -a -o -b -d``
   ">&2
    exit 1
}

while getopts ':lcaobpd' opt
#putting : in the beginnnig suppresses the errors for invalid options
do
case "$opt" in
   'l')install_loopback;
       ;;
   'c')install_akvcam;
       ;;
   'a')install_droidcam;
       ;;
   'o')install_obsloop;
       ;;
   'd')desktopentry_fakecam && desktopentry_droidcam;
       ;;
    *) usage;
       ;;
esac
done
if [ $OPTIND -eq 1 ]; then
    install_droidcam > /dev/null 2>&1 && echo "Installed Droidcam" || ( echo "Error installing Droidcam"; exit 1 )
    install_loopback > /dev/null 2>&1 && echo "Installed loopback" || ( echo "Error installing loopback"; exit 1 )
    install_akvcam > /dev/null 2>&1 && echo "Installed akvcam" || ( echo "Error installing akvcam"; exit 1 )
    install_obsloop > /dev/null 2>&1 && echo "Installed obsloop" || ( echo "Error installing obsloop"; exit 1 )
fi
