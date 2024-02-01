FROM debian:bookworm

ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN apt-get update && \
    apt-get install -y \
        less \
        libpcre3-dev \
        apt-transport-https \
        ca-certificates \
        curl \
        wget \
        logrotate \
        libc-ares2 \
        libjson-c5 \
        vim \
        procps \
        libreadline8 \
        gnupg2 \
        lsb-release \
        apt-utils \
        libprotobuf-c-dev \
        protobuf-c-compiler \
        tini \
        iproute2 \
        mtr \
        traceroute \
        dnsutils \
        inetutils-ping \
        openssh-server \
        lldpd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -s https://deb.frrouting.org/frr/keys.asc | gpg --dearmor --yes --batch --output "/etc/apt/trusted.gpg.d/frr-deb.gpg"
RUN echo "deb https://deb.frrouting.org/frr $(lsb_release -s -c) frr-stable" | tee -a /etc/apt/sources.list.d/frr.list

RUN apt-get update && \
    apt-get install -y \
        frr \
        frr-pythontools \
    && rm -rf /var/lib/apt/lists/*

# Own the config / PID files
RUN mkdir -p /var/run/frr
RUN chown -R frr:frr /etc/frr /var/run/frr

COPY scripts/bashrc /root/.bashrc
COPY frr/daemons /etc/frr/daemons
COPY scripts/sshd_config /etc/ssh/sshd_config
# COPY ../atsbox/keys/ansible-tower_mgmt.pub /root/.ssh/authorized_keys

EXPOSE 179 22

WORKDIR /srv

# Simple init manager for reaping processes and forwarding signals
ENTRYPOINT ["/usr/bin/tini", "--"]

# Default CMD starts watchfrr
COPY --chmod=755 scripts/docker-start /usr/lib/frr/docker-start
CMD ["/usr/lib/frr/docker-start"]
