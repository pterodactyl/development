FROM debian:11-slim

ENV DEBIAN_FRONTEND noninteractive \
    LANG C.UTF-8 \
    GOBIN /usr/local/go/bin

USER root
RUN apt -y update \
    && apt -y --no-install-recommends install software-properties-common gnupg2 curl sudo \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt -y update \
    && apt -y --no-install-recommends install \
        git \
        iputils-ping \
        tar \
        zip \
        unzip \
        make \
        gcc \
        g++ \
        gdb \
        python \
        docker-ce \
        docker-ce-cli \
        containerd.io \
    && curl -OL https://go.dev/dl/go1.17.6.linux-amd64.tar.gz \
    && tar xvf go1.17.6.linux-amd64.tar.gz -C /usr/local \
    && chown -R root:root /usr/local/go \
    && rm -rf go1.17.6.linux-amd64.tar.gz \
    && /usr/local/go/bin/go get github.com/go-delve/delve/cmd/dlv \
    && usermod -aG docker root \
    && echo "export PATH=\$PATH:/usr/local/go/bin" >> /etc/bash.bashrc

EXPOSE 8080
EXPOSE 2022

WORKDIR /home/root/wings

CMD ["/bin/bash"]
