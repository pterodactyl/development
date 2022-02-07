#!/bin/bash

CURRENT_DIRECTORY="$(pwd)"
cd /tmp

cd ${CURRENT_DIRECTORY}

git clone https://github.com/pterodactyl/panel.git code/panel
git clone https://github.com/pterodactyl/documentation.git code/documentation
git clone https://github.com/pterodactyl/wings.git code/wings

mkcert -install
mkcert pterodactyl.test '*.pterodactyl.test'

mv *pterodactyl.test*-key.pem docker/certificates/pterodactyl.test-key.pem
mv *pterodactyl.test*.pem docker/certificates/pterodactyl.test.pem
cp "$(mkcert -CAROOT)/rootCA.pem" docker/certificates/root_ca.pem
