create database if not exists testing;

grant all on testing.* TO 'pterodactyl'@'%';
grant all on `testing\_test_%`.* TO 'pterodactyl'@'%';

flush privileges;