# Pterodactyl Development Environment
This repository provides a `docker-compose` based environment for handling local development of Pterodactyl.

**This is not meant for production use! This is a local development environment only.**

> This environment is the official Pterodactyl development environment, in the sense that it is what
I, [`@DaneEveritt`](https://github.com/DaneEveritt) use for working on it. I've not tested it on anything
other than macOS, and I probably haven't documented most of the important bits. Please feel free to open
PRs or Issues as necessary to improve this environment.

### Getting Started
You'll need the following things installed on your machine.

* [Docker](https://docker.io)
* [Mutagen Compose](https://github.com/mutagen-io/mutagen-compose)
* [mkcert](https://github.com/FiloSottile/mkcert)

### Setup
To begin clone this repository to your system, and then run `./setup.sh` which will configure the
additional git repositories, and setup your local certificates and host file routing.

```sh
git clone https://github.com/pterodactyl/development.git
cd development
./setup.sh
```

#### What is Created
* Traefik Container
* Panel & Wings Containers
* MySQL & Redis Containers
* Minio Container for S3 emulation

### Accessing the Environment
Once you've setup the environment, simply run `./beak up -d` to start the environment. This simply aliases
some common Docker compose commands.

Once the environment is running, `./beak app` and `./beak wings` will allow SSH access to the Panel and
Wings environments respectively. Your Panel is accessible at `https://pterodactyl.test`. You'll need to
run through the normal setup process for the Panel if you do not have a database and environment setup
already. This can be done by SSH'ing into the Panel environment and running `setup-pterodactyl`.

The code for the setup can be found in `build/panel/setup-pterodactyl`. Please note, this environment uses
Mutagen for file handling, so replace calls to `docker compse up` or `down` with `mutagen-compose up` or `down`.
All other `docker compose` commands can be used as normal.

### Setting up a node on the panel and configuring wings
When creating the node on the panel, please make sure that:
* FQDN is set to `wings.pterodactyl.test`
* Set to use a SSL connection
* Daemon port is `443` (NOT 8080)

Next go to the configuration tab of the node, and copy the configuration and save it as `config.yml` under the wings code directory `./code/wings/`

In the saved file `config.yml` you need to:
* `Disable SSL` (Traefik is handling SSL)
* Set the port to `8080`

To start wings, run `./beak wings`, and run `make debug`

