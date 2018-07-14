FROM ubuntu:16.04

LABEL maintainer="dane@daneeveritt.com" \
	  description="Base image used by Pterodactyl's development environments to provide SSH support for vagrant."

ENV DEBIAN_FRONTEND=noninteractive \
	NOTVISIBLE="in users profile"

RUN apt -y update \
	&& apt -y upgrade \
	&& apt -y --no-install-recommends install software-properties-common sudo openssh-server locales \
	&& sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
	&& locale-gen

ENV LANG=en_US.UTF-8 \ 
	LANGUAGE=en_US:en \
	LC_ALL=en_US.UTF-8

RUN echo 'root:vagrant' | chpasswd \
	&& sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
	&& sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
	&& echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

ENTRYPOINT service ssh start && /bin/bash