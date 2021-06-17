#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

tmp_dir=$(mktemp -d)
cd $tmp_dir
git clone -b build-21286+ https://github.com/diddledan/one-script-wsl2-systemd
python3 -c "import configparser; config = configparser.ConfigParser(); config.read('/etc/wsl.conf'); config['boot']['command'] = \"/usr/bin/env -i /usr/bin/unshare --fork --mount-proc --pid -- sh -c 'mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc; [ -x /usr/lib/systemd/systemd ] && exec /usr/lib/systemd/systemd --unit=multi-user.target || exec /lib/systemd/systemd'\"; x = open('/etc/wsl.conf', 'w'); config.write(x); x.close();"
cp one-script-wsl2-systemd/src/sudoers /etc/sudoers.d/wsl2-systemd
cp one-script-wsl2-systemd/src/00-wsl2-systemd.sh /etc/profile.d/00-wsl2-systemd.sh
mkdir -p "/etc/systemd/system/user-runtime-dir@.service.d/"
cp one-script-wsl2-systemd/src/systemd/user-runtime-dir.override "/etc/systemd/system/user-runtime-dir@.service.d/override.conf"
cp one-script-wsl2-systemd/src/systemd/wsl2-xwayland.service /etc/systemd/system/wsl2-xwayland.service
cp one-script-wsl2-systemd/src/systemd/wsl2-xwayland.socket /etc/systemd/system/wsl2-xwayland.socket
ln -sf /etc/systemd/system/wsl2-xwayland.socket /etc/systemd/system/sockets.target.wants/
rm -rf $tmp_dir