FROM python:3.11-alpine3.18

RUN apk update \
    && apk add \
        vim \
        bash \
        mtr \
        iproute2 \
        bind-tools \
        traceroute \
        tini \
        openssh \
    && rm -rf /var/cache/apk/*

RUN pip --no-cache-dir install --no-compile \
    ansible

RUN ansible-galaxy collection install community.general

EXPOSE 22

COPY scripts/bashrc /root/.bashrc
COPY scripts/ansible.cfg /etc/ansible/ansible.cfg
COPY --chown=root:root keys /root/.ssh

RUN mkdir -p /srv/ansible
WORKDIR /srv/ansible

ENTRYPOINT ["/sbin/tini", "--"]

COPY --chmod=755 scripts/docker-start /usr/lib/docker/docker-start
CMD ["/usr/lib/docker/docker-start"]
