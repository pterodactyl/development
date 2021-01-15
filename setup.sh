#!/bin/bash

CURRENT_DIRECTORY=$(pwd)
cd /tmp

vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-hostmanager

cd ${CURRENT_DIRECTORY}

git clone https://github.com/pterodactyl/panel.git code/panel
git clone https://github.com/pterodactyl/documentation.git code/documentation
git clone https://github.com/pterodactyl/wings.git code/wings
git clone https://github.com/pterodactyl/daemon.git code/daemon
git clone https://github.com/pterodactyl/sftp-server.git code/sftp-server

mkdir -p .data/certificates

mkcert -install
mkcert pterodactyl.test '*.pterodactyl.test'

mv *pterodactyl.test*-key.pem .data/certificates/pterodactyl.test-key.pem
mv *pterodactyl.test*.pem .data/certificates/pterodactyl.test.pem
cp $(mkcert -CAROOT)/rootCA.pem .data/certificates/

# sudo gem install docker-sync
# docker-sync start
