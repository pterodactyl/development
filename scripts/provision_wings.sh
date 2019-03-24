#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

chown -R vagrant:vagrant /home/vagrant

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - > /dev/null
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /dev/null
add-apt-repository -y ppa:longsleep/golang-backports > /dev/null
apt-get -qq update
apt-get -qq -o=Dpkg::Use-Pty=0 upgrade
apt-get -qq -o=Dpkg::Use-Pty=0 install -y golang-go docker-ce mercurial tar unzip make gcc g++ python

usermod -aG docker vagrant

echo "export GOPATH=/home/vagrant/go" >> /home/vagrant/.profile
export GOPATH=/go
echo "export PATH=$PATH:$GOPATH/bin" >> /home/vagrant/.profile

sudo -H -u vagrant bash -c 'go get -u github.com/golang/dep/cmd/dep'
sudo -H -u vagrant bash -c 'go get -u github.com/derekparker/delve/cmd/dlv'

wget https://github.com/bcicen/ctop/releases/download/v0.7.1/ctop-0.7.1-linux-amd64 -q -O /usr/local/bin/ctop
chmod +x /usr/local/bin/ctop

echo "cd /home/vagrant/wings " >> /home/vagrant/.profile
