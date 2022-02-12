#!/bin/bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
CERTS_DIR="$SCRIPT_DIR/docker/certificates"
CODE_DIR="$SCRIPT_DIR/code"

for REPO in "panel" "documentation" "wings"
do
  if [ ! -d "$CODE_DIR/$REPO" ]; then
    git clone https://github.com/pterodactyl/$REPO.git "$CODE_DIR/$REPO"
  else
    echo "$REPO repository already cloned into: $CODE_DIR/$REPO"
  fi
done

mkcert -install
mkcert pterodactyl.test wings.pterodactyl.test minio.pterodactyl.test s3.minio.pterodactyl.test

# Because we're doing Docker-in-Docker we actually need these paths to line
# up correctly with the host system.
sudo mkdir -p /var/lib/pterodactyl
sudo chown $(id -u):$(id -g) /var/lib/pterodactyl

mv -v *pterodactyl.test*-key.pem docker/certificates/pterodactyl.test-key.pem || exit 1
mv -v *pterodactyl.test*.pem docker/certificates/pterodactyl.test.pem || exit 1
cp -v "$(mkcert -CAROOT)/rootCA.pem" docker/certificates/root_ca.pem || exit 1

echo ""
if [ ! -f "/etc/hosts" ]; then
  echo "no system hosts file found, please manually configure your system"
else
  for DOMAIN in "pterodactyl.test" "wings.pterodactyl.test" "minio.pterodactyl.test" "s3.minio.pterodactyl.test"
  do
    ESCAPED_DOMAIN=$(echo $DOMAIN | sed "s/\./\\\./g")
    if ! grep -q -E "127\.0\.0\.1\s+$ESCAPED_DOMAIN\s*$" /etc/hosts; then
      echo "✅ adding \"$DOMAIN\" to system hosts file"
      echo "127.0.0.1 $DOMAIN" | sudo tee -a /etc/hosts || exit 1
    else
      echo "✅ found existing entry for \"$DOMAIN\" in /etc/hosts; skipping..."
    fi
  done
fi

echo "optionally, configure the beak alias:"

echo "bash:"
echo "echo \"alias beak=\\\"$SCRIPT_DIR/beak\\\"\" >> ~/.bash_profile"
echo ""
echo "zsh:"
echo "echo \"alias beak=\\\"$SCRIPT_DIR/beak\\\"\" >> ~/.zshrc"
