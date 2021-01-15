require 'yaml'
require 'pathname'

["vagrant-vbguest", "vagrant-hostmanager"].each do |plugin|
    unless Vagrant.has_plugin?(plugin)
      raise plugin + " plugin is not installed. Hint: vagrant plugin install " + plugin
    end
end

vagrant_root = File.dirname(__FILE__)

$configMap = FileTest.exist?("#{vagrant_root}/vagrant.config.yml") ? YAML.load_file("#{vagrant_root}/vagrant.config.yml") : {}
def config(key, def_val)
  return $configMap.dig(*key.split(".")) || def_val
end

Vagrant.configure("2") do |config|
	config.hostmanager.enabled = false
	config.hostmanager.manage_host = true
	config.hostmanager.manage_guest = false
	config.hostmanager.ignore_private_ip = false
	config.hostmanager.include_offline = true

	config.vm.define "app", primary: true do |app|
		app.vm.hostname = "pterodactyl.test"

		app.vm.synced_folder ".", "/vagrant", disabled: true

		app.vm.network "forwarded_port", guest: 80, host: 80
		app.vm.network "forwarded_port", guest: 443, host: 443
		app.vm.network "forwarded_port", guest: 8080, host: 8080
		app.vm.network "forwarded_port", guest: 8081, host: 8081

		app.ssh.insert_key = true
		app.ssh.username = "vagrant"
		app.ssh.password = "vagrant"

		app.vm.provider "docker" do |d|
			d.build_dir = "./build" 
			d.build_args = "-f=build/Dockerfile-panel"
			d.create_args = [
			    "-it",
			    "--add-host=host.pterodactyl.test:172.17.0.1",
				"--add-host=daemon.pterodactyl.test:192.168.50.4",
				"--add-host=wings.pterodactyl.test:192.168.50.3",
			]
			d.ports = ["80:80", "443:443", "8080:8080", "8081:8081"]

			if ENV['FILE_SYNC_METHOD'] === 'docker-sync'
				d.volumes = [
				    "panel-sync:/home/vagrant/app:nocopy",
				    "#{vagrant_root}/.data/certificates:/etc/ssl/private:ro"
				]
			else
				d.volumes = [
				    "#{vagrant_root}/code/panel:/home/vagrant/app:cached",
				    "#{vagrant_root}/.data/certificates:/etc/ssl/private:ro"
				]
			end

			d.remains_running = true
			d.has_ssh = true
		end

		app.vm.provision :hostmanager
		app.vm.provision "deploy_nginx_config", type: "file", source: "#{vagrant_root}/build/configs/nginx/pterodactyl.test.conf", destination: "/tmp/.deploy/nginx/pterodactyl.test.conf"
		app.vm.provision "deploy_supervisor_config", type: "file", source: "#{vagrant_root}/build/configs/supervisor/pterodactyl.conf", destination: "/tmp/.deploy/supervisor/pterodactyl.conf"
		app.vm.provision "configure_application", type: "shell", privileged: false, path: "#{vagrant_root}/scripts/deploy_app.sh"
		app.vm.provision "setup", type: "shell", run: "never", inline: <<-SHELL
			cd /home/vagrant/app

			cp .env .env.bkup
			php artisan key:generate --force --no-interaction

			php artisan p:environment:setup --new-salt --author="you@example.com" --url="http://pterodactyl.test" --timezone="America/Los_Angeles" --cache=redis --session=redis --queue=redis --redis-host="host.pterodactyl.test" --no-interaction
			php artisan p:environment:database --host="host.pterodactyl.test" --database=panel --username=pterodactyl --password=pterodactyl --port=33060 --no-interaction
			php artisan p:environment:mail --driver=smtp --email="outgoing@example.com" --from="Pterodactyl Panel" --host="host.pterodactyl.test" --port=1025 --no-interaction

			php artisan migrate --seed
		SHELL
	end

	config.vm.define "wings", autostart: false do |wings|
		wings.vm.hostname = "wings.pterodactyl.test"
		wings.vm.box = "bento/ubuntu-18.04"

        wings.vm.provider "virtualbox" do |v|
            v.memory = config("wings.memory", 2048)
            v.cpus = config("wings.cpus", 2)
            v.customize ["modifyvm", :id, "--cpuexecutioncap", "75"]
        end

		wings.vm.synced_folder ".", "/vagrant", disabled: true
        wings.vm.synced_folder "#{vagrant_root}/code/wings", "/home/vagrant/wings", owner: "vagrant", group: "vagrant"
        wings.vm.synced_folder "#{vagrant_root}/code/sftp-server", "/home/vagrant/sftp-server", owner: "vagrant", group: "vagrant"
        wings.vm.synced_folder "#{vagrant_root}/.data/certificates", "/etc/ssl/pterodactyl", owner: "vagrant", group: "vagrant"

		wings.vm.network :private_network, ip: "192.168.50.3"

		wings.vm.provision "provision", type: "shell", path: "#{vagrant_root}/scripts/provision_wings.sh"
		config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"
	end

	config.vm.define "daemon", autostart: false do |daemon|
		daemon.vm.hostname = "daemon.pterodactyl.test"
		daemon.vm.box = "bento/ubuntu-18.04"

		daemon.vm.synced_folder ".", "/vagrant", disabled: true
		daemon.vm.synced_folder "#{vagrant_root}/code/daemon", "/srv/daemon", owner: "vagrant", group: "vagrant"
		daemon.vm.synced_folder "#{vagrant_root}/.data/certificates", "/etc/ssl/private", owner: "vagrant", group: "vagrant"
		daemon.vm.synced_folder "#{vagrant_root}/code/sftp-server", "/home/vagrant/sftp-server", owner: "vagrant", group: "vagrant"

		daemon.vm.network :private_network, ip: "192.168.50.4"

		daemon.vm.provision "provision", type: "shell", path: "#{vagrant_root}/scripts/provision_daemon.sh"
	end

	config.vm.define "docs" do |docs|
		docs.vm.hostname = "docs.pterodactyl.test"
		docs.vm.synced_folder ".", "/vagrant", disabled: true

		docs.vm.network "forwarded_port", guest: 80, host: 9090
		docs.vm.network "forwarded_port", guest: 9091, host: 9091

		docs.ssh.insert_key = true
		docs.ssh.username = "root"
		docs.ssh.password = "vagrant"

		docs.vm.provider "docker" do |d|
			d.image = "quay.io/pterodactyl/vagrant-core"
			d.create_args = ["-it", "--add-host=host.pterodactyl.test:172.17.0.1"]
			d.ports = ["9090:80", "9091:9091"]
			d.volumes = ["#{vagrant_root}/code/documentation:/srv/documentation:cached"]
			d.remains_running = true
			d.has_ssh = true
			d.privileged = true
		end

		docs.vm.provision "deploy_files", type: "file", source: "#{vagrant_root}/build/configs", destination: "/tmp/.deploy"
		docs.vm.provision "setup_documentation", type: "shell", path: "#{vagrant_root}/scripts/deploy_docs.sh"
	end


	# Configure a mysql docker container.
	config.vm.define "mysql" do |mysql|
		mysql.vm.hostname = "mysql.pterodactyl.test"
		mysql.vm.synced_folder ".", "/vagrant", disabled: true

		mysql.vm.network "forwarded_port", guest: 3306, host: 33060

		mysql.vm.provider "docker" do |d|
			d.image = "mysql:8"
			d.ports = ["33060:3306"]
			d.cmd = [
				"--sql_mode=no_engine_substitution",
				"--innodb_buffer_pool_size=1G",
				"--innodb_log_file_size=256M",
				"--innodb_flush_log_at_trx_commit=0",
				"--lower_case_table_names=1"
			]
			d.volumes = ["#{vagrant_root}/.data/mysql:/var/lib/mysql:cached"]
			d.env = {
				"MYSQL_ROOT_PASSWORD": "root",
				"MYSQL_DATABASE": "panel",
				"MYSQL_USER": "pterodactyl",
				"MYSQL_PASSWORD": "pterodactyl"
			}
			d.remains_running = true
		end
	end

	config.vm.define "chromedriver" do |chrome|
		chrome.vm.hostname = "chromedriver.pterodactyl.test"
		chrome.vm.synced_folder ".", "/vagrant", disabled: true

		chrome.vm.network "forwarded_port", guest: 4444, host: 4444
		chrome.vm.network "forwarded_port", guest: 5900, host: 5900

		chrome.vm.provider "docker" do |d|
			d.image = "selenium/standalone-chrome-debug:3.12.0-boron"
			d.ports = ["5900:5900", "4444:4444"]
			d.create_args = ["--add-host=pterodactyl.test:172.17.0.1"]
			d.remains_running = true
		end
	end

	# Create a docker container for mailhog which providers a local SMTP environment that avoids actually
	# sending emails to the address.
	config.vm.define "mailhog" do |mh|
		mh.vm.hostname = "mailhog.pterodactyl.test"
		mh.vm.synced_folder ".", "/vagrant", disabled: true

		mh.vm.network "forwarded_port", guest: 1025, host: 1025
		mh.vm.network "forwarded_port", guest: 8025, host: 8025

		mh.vm.provider "docker" do |d|
			d.image = "mailhog/mailhog"
			d.ports = ["1025:1025", "8025:8025"]
			d.remains_running = true
		end
	end

	# Create a docker container for the redis server.
	config.vm.define "redis" do |redis|
		redis.vm.hostname = "redis.pterodactyl.test"
		redis.vm.synced_folder ".", "/vagrant", disabled: true

		redis.vm.network "forwarded_port", guest: 6379, host: 6379

		redis.vm.provider "docker" do |d|
			d.image = "redis:5-alpine"
			d.ports = ["6379:6379"]
			d.remains_running = true
		end
	end
end
