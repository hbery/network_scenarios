FROM alpine:3.18

RUN apk update \
    && apk add \
        bash \
        mtr \
        iproute2 \
        bind-tools \
        traceroute \
        tini \
        openrc \
        openssh-server \
    && rm -rf /var/cache/apk/*

EXPOSE 22

RUN mkdir /root/.ssh \
    && chmod 0700 /root/.ssh \
    && ssh-keygen -A \
    && sed -i s/^#PasswordAuthentication\ yes/PasswordAuthentication\ no/ /etc/ssh/sshd_config

COPY scripts/bashrc /root/.bashrc
RUN echo ENV=/root/.bashrc >> /etc/profile

RUN mkdir -p /run/openrc \
    && touch /run/openrc/softlevel \
    && rc-status

WORKDIR /srv

ENTRYPOINT ["/sbin/tini", "--"]

COPY --chmod=755 scripts/docker-start /usr/lib/docker/docker-start
CMD ["/usr/lib/docker/docker-start"]
