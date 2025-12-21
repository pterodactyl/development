[![Logo Image](https://cdn.pterodactyl.io/logos/new/pterodactyl_logo.png)](https://pterodactyl.io)

# Pterodactyl Development
This repository provides a `docker-compose` based environment for handling local development of Pterodactyl.

**This is not meant for production use! This is a local development environment only.**

> This environment is the official Pterodactyl development environment, in the sense that it is what
I, [`@DaneEveritt`](https://github.com/DaneEveritt) use for working on it. I've not tested it on anything
other than macOS, and I probably haven't documented most of the important bits. Please feel free to open
PRs or Issues as necessary to improve this environment.

### Getting Started
You'll need the following dependencies installed on your machine.

* [Orbstack](https://orbstack.dev)
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
Once you've setup the environment, simply run `./beak build` and then `./beak up -d` to start the environment.
`beak` aliases some common Docker compose commands, but everything else will pass through to `docker compose`.

Once the environment is running, `./beak app` and `./beak wings` will allow SSH access to the Panel and
Wings environments respectively. Your Panel is accessible at `https://pterodactyl.test`. You'll need to
run through the normal setup process for the Panel if you do not have a database and environment setup
already. This can be done by SSH'ing into the Panel environment and running `setup-pterodactyl`.

The code for the setup can be found in `build/panel/setup-pterodactyl`. Ensure you run `yarn serve` or
`yarn build` before accessing the Panel. You can run `yarn` inside the container, or just in the `code/panel`
directory on your host machine, assuming you have `node >= 22`.

### Running Wings
You'll need to create a location and a node in the Panel instance before you can configure Wings. Set up the
node _as being "Behind Proxy"_ and set the `Daemon Port` value to 443. Copy over the resulting `config.yml`
file to `/home/root/wings/config.yml` on the Wings dev container.

When you write that file, update the `port` value in the file to be `8080` since we're doing some proxying
for the environment with Traefik.

You should then be able to run `make debug` which will start the Wings daemon in debug mode.