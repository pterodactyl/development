#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Add Docker's GPG key and configure the repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Add support for easily fetching the latest version of Go
add-apt-repository ppa:longsleep/golang-backports

# Perform the installation of the required software.
apt -y update
apt -y --no-install-recommends install iputils-ping tar zip unzip make gcc g++ gdb python docker-ce docker-ce-cli containerd.io golang-go

# Install delve for Go debugging support.
GOBIN=/usr/local/bin go get github.com/go-delve/delve/cmd/dlv

# Configure the vagrant user to have permission to use Docker.
usermod -aG docker vagrant

# Ensure docker is started and will continue to start up.
systemctl enable docker --now

# Install ctop for easy container metrics visualization.
curl -fsSL https://github.com/bcicen/ctop/releases/download/v0.7.1/ctop-0.7.1-linux-amd64 -o /usr/local/bin/ctop
chmod +x /usr/local/bin/ctop

# create config directory
mkdir -p /etc/pterodactyl /var/log/pterodactyl
cp /etc/ssl/pterodactyl/root_ca.pem /etc/ssl/certs/mkcert.pem

# ensure permissions are set correctly
chown -R vagrant:vagrant /home/vagrant /etc/pterodactyl /var/log/pterodactyl

# map pterodactyl.test to the host system
echo "$(ip route | grep default | cut -d' ' -f3,3) pterodactyl.test" >> /etc/hosts

echo "done."
