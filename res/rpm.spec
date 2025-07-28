Name:       bgdesk
Version:    1.4.0
Release:    0
Summary:    RPM package
License:    GPL-3.0
URL:        https://bgdesk.com
Vendor:     bgdesk <info@bgdesk.com>
Requires:   gtk3 libxcb libxdo libXfixes alsa-lib libva2 pam gstreamer1-plugins-base
Recommends: libayatana-appindicator-gtk3

# https://docs.fedoraproject.org/en-US/packaging-guidelines/Scriptlets/

%description
The best open-source remote desktop client software, written in Rust.

%prep
# we have no source, so nothing here

%build
# we have no source, so nothing here

%global __python %{__python3}

%install
mkdir -p %{buildroot}/usr/bin/
mkdir -p %{buildroot}/usr/share/bgdesk/
mkdir -p %{buildroot}/usr/share/bgdesk/files/
mkdir -p %{buildroot}/usr/share/icons/hicolor/256x256/apps/
mkdir -p %{buildroot}/usr/share/icons/hicolor/scalable/apps/
install -m 755 $HBB/target/release/bgdesk %{buildroot}/usr/bin/bgdesk
install $HBB/libsciter-gtk.so %{buildroot}/usr/share/bgdesk/libsciter-gtk.so
install $HBB/res/bgdesk.service %{buildroot}/usr/share/bgdesk/files/
install $HBB/res/128x128@2x.png %{buildroot}/usr/share/icons/hicolor/256x256/apps/bgdesk.png
install $HBB/res/scalable.svg %{buildroot}/usr/share/icons/hicolor/scalable/apps/bgdesk.svg
install $HBB/res/bgdesk.desktop %{buildroot}/usr/share/bgdesk/files/
install $HBB/res/bgdesk-link.desktop %{buildroot}/usr/share/bgdesk/files/

%files
/usr/bin/bgdesk
/usr/share/bgdesk/libsciter-gtk.so
/usr/share/bgdesk/files/bgdesk.service
/usr/share/icons/hicolor/256x256/apps/bgdesk.png
/usr/share/icons/hicolor/scalable/apps/bgdesk.svg
/usr/share/bgdesk/files/bgdesk.desktop
/usr/share/bgdesk/files/bgdesk-link.desktop
/usr/share/bgdesk/files/__pycache__/*

%changelog
# let's skip this for now

%pre
# can do something for centos7
case "$1" in
  1)
    # for install
  ;;
  2)
    # for upgrade
    systemctl stop bgdesk || true
  ;;
esac

%post
cp /usr/share/bgdesk/files/bgdesk.service /etc/systemd/system/bgdesk.service
cp /usr/share/bgdesk/files/bgdesk.desktop /usr/share/applications/
cp /usr/share/bgdesk/files/bgdesk-link.desktop /usr/share/applications/
systemctl daemon-reload
systemctl enable bgdesk
systemctl start bgdesk
update-desktop-database

%preun
case "$1" in
  0)
    # for uninstall
    systemctl stop bgdesk || true
    systemctl disable bgdesk || true
    rm /etc/systemd/system/bgdesk.service || true
  ;;
  1)
    # for upgrade
  ;;
esac

%postun
case "$1" in
  0)
    # for uninstall
    rm /usr/share/applications/bgdesk.desktop || true
    rm /usr/share/applications/bgdesk-link.desktop || true
    update-desktop-database
  ;;
  1)
    # for upgrade
  ;;
esac
