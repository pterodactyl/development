#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

chown -R vagrant:vagrant /home/vagrant

echo "Install docker, go and some dependencies"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - > /dev/null
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /dev/null
add-apt-repository -y ppa:longsleep/golang-backports > /dev/null
apt-get -qq update
apt-get -qq -o=Dpkg::Use-Pty=0 upgrade
apt-get -qq -o=Dpkg::Use-Pty=0 install -y golang-go docker-ce mercurial tar unzip make gcc g++ python

usermod -aG docker vagrant

echo "Setup GOPATH"
echo "export GOPATH=/home/vagrant/go" >> /home/vagrant/.profile
export GOPATH=/go
echo 'export PATH=$PATH:$GOPATH/bin' >> /home/vagrant/.profile

echo "Install go dep"
sudo -H -u vagrant bash -c 'go get -u github.com/golang/dep/cmd/dep'
echo "Install delve for debugging"
sudo -H -u vagrant bash -c 'go get -u github.com/derekparker/delve/cmd/dlv'

echo "Install ctop for fancy container monitoring"
wget https://github.com/bcicen/ctop/releases/download/v0.7.1/ctop-0.7.1-linux-amd64 -q -O /usr/local/bin/ctop
chmod +x /usr/local/bin/ctop

echo "cd /home/vagrant/go/src/github.com/pterodactyl/wings " >> /home/vagrant/.profile

echo "   ------------"
echo "Gopath is /home/vagrant/go"
echo "The project is mounted to /home/vagrant/go/src/github.com/pterodactyl/wings"
echo "Provisioning is completed."