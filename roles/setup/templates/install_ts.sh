#!/bin/bash
INSTALLDIR=${1-${HOME}}

# getting latest teamspeak version
VERSION=$(curl -s -L https://www.teamspeak.com/de/downloads/ |  grep TeamSpeak3-Client-linux_amd64- | awk '/TeamSpeak3-Client-linux_amd64-/,/.run/' | awk -v FS="(TeamSpeak3-Client-linux_amd64-|.run)" '{print $2}' | head -n 1)

# download the client
cd /tmp
wget -O teamspeak.run --content-disposition https://files.teamspeak-services.com/releases/client/${VERSION}/TeamSpeak3-Client-linux_amd64-${VERSION}.run

#BY UNCOMMENT THE NEXT LINE YOU ACCEPT THE TEAMSPEAK TERMS AND CONDITIONS!
#sed -i -e 's/read FOO//g' -e 's/read yn/yn="y"/g' -e 's/echo "$licensetxt" | less//g' teamspeak.run

# extract the teamspeak client
rm -rf TeamSpeak3-Client-linux_amd64
chmod +x teamspeak.run && ./teamspeak.run
rm teamspeak.run
mv TeamSpeak3-Client-linux_amd64 ${INSTALLDIR}/teamspeak

# download a teamspeak logo
cd ${INSTALLDIR}/teamspeak
wget -O logo.png --content-disposition https://daskeet.com/img/teamspeaklogo.png

if [ $INSTALLDIR = "/srv" ]
then
    LINKDIR="/usr/share/applications/"
    sudo chmod -R 777 /srv/teamspeak
else
    LINKDIR=${HOME}/.local/share/applications
fi

# creating menu entry
echo -e "
[Desktop Entry]\n\
Name=Teamspeak 3 Client\n\
GenericName=Teamspeak\n\
Comment=Speak with friends\n\
Comment[de]=Spreche mit Freunden\n\
Exec=${INSTALLDIR}/teamspeak/ts3client_runscript.sh\n\
Terminal=false\n\
X-MultipleArgs=false\n\
Type=Application\n\
Icon=${INSTALLDIR}/teamspeak/logo.png\n\
Categories=Network;\n\
StartupWMClass=TeamSpeak 3\n\
StartupNotify=true\n\
" \
> ${LINKDIR}/teamspeak3-client.desktop
