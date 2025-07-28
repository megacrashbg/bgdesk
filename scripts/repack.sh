cd $(dirname $0)
FILENAME=$(basename $1)

# Backup the original file
if [ ! -f $FILENAME ]; then
    echo "File $FILENAME not found!"
    exit 1
fi
cp $FILENAME $FILENAME.bak

rm -rf tmp
mkdir -p tmp
dpkg-deb -R $1 tmp
cd tmp

# DEBIAN/control
sed -i -e 's/Package: rustdesk/Package: bgdesk/g' DEBIAN/control
sed -i -e 's/rustdesk <info@rustdesk.com>/bgdesk <thinksoftbr@gmail.com>/g' DEBIAN/control
sed -i -e 's/https:\/\/rustdesk.com/https:\/\/boagestao.com.br\/bgdesk/g' DEBIAN/control

# DEBIAN/md5sums
sed -i -e 's/\/rustdesk/\/bgdesk/g' DEBIAN/md5sums

mv etc/pam.d/rustdesk etc/pam.d/bgdesk
mv etc/rustdesk etc/bgdesk
mv usr/share/rustdesk usr/share/bgdesk
mv usr/share/applications/rustdesk.desktop usr/share/applications/bgdesk.desktop
mv usr/share/applications/rustdesk-link.desktop usr/share/applications/bgdesk-link.desktop
mv usr/share/bgdesk/rustdesk usr/share/bgdesk/bgdesk
mv usr/share/bgdesk/files/systemd/rustdesk.service usr/share/bgdesk/files/systemd/bgdesk.service
mv usr/share/icons/hicolor/256x256/apps/rustdesk.png usr/share/icons/hicolor/256x256/apps/bgdesk.png
mv usr/share/icons/hicolor/scalable/apps/rustdesk.svg usr/share/icons/hicolor/scalable/apps/bgdesk.svg

cd ..

rm -rf $FILENAME

dpkg-deb -b tmp $FILENAME

# rm -rf tmp