#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo "Provisioning development environment for Pterodactyl Panel."

echo "Add repositories"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - > /dev/null
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /dev/null
add-apt-repository -y ppa:longsleep/golang-backports > /dev/null
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - > /dev/null
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt-get update

echo "Install everything"
apt-get -y install nodejs yarn \
    golang-go mercurial \
    docker-ce docker-ce-cli containerd.io \
    tar unzip make gcc g++ python > /dev/null

systemctl enable docker
systemctl start docker

usermod -aG docker vagrant

echo "Install ctop for fancy container monitoring"
wget https://github.com/bcicen/ctop/releases/download/v0.7.2/ctop-0.7.2-linux-amd64 -q -O /usr/local/bin/ctop
chmod +x /usr/local/bin/ctop

echo "Setup GOPATH"
echo "export GOPATH=/home/vagrant/go" >> /home/vagrant/.profile
export GOPATH=/go
echo 'export PATH=$PATH:$GOPATH/bin' >> /home/vagrant/.profile

echo "Install nodejs dependencies"
$(cd /srv/daemon && npm install)

echo "   ------------"
echo "Provisioning is completed."
echo "You'll still need to configure your node in the panel manually."
