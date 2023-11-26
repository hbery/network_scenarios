FROM python:3.11-alpine3.18

RUN apk update \
    && apk add \
        bash \
        mtr \
        iproute2 \
        bind-tools \
        traceroute \
        tini \
        openssh \
    && rm -rf /var/cache/apk/*

RUN pip --no-cache-dir install --no-compile \
    ansible \
    ansible-tower-cli

EXPOSE 22

COPY scripts/bashrc /root/.bashrc

WORKDIR /srv

ENTRYPOINT ["/sbin/tini", "--"]

COPY --chmod=755 scripts/docker-start /usr/lib/docker/docker-start
CMD ["/usr/lib/docker/docker-start"]
