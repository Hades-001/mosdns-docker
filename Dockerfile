FROM alpine:3.14.0

########################################
#              Settings                #
########################################

ENV DNS_PORT    53
ENV DOH_PORT    443
ENV DOT_PORT    853

########################################
#               Build                  #
########################################

ARG MOSDNS_VER=v1.8.6
ARG PLATFORM=amd64
ARG MOSDNS_URL=https://github.com/IrineSistiana/mosdns/releases/download/${MOSDNS_VER}/mosdns-linux-${PLATFORM}.zip

RUN set -ex && \
    apk add --no-cache ca-certificates su-exec unzip wget && \
    mkdir -p /etc/mosdns && \
    cd /tmp && \
    wget ${MOSDNS_URL} && \
    unzip mosdns-linux-${PLATFORM}.zip && \
    mv mosdns /usr/bin/mosdns && \
    mv config.yaml /etc/mosdns && \
    rm -rf /tmp/*

VOLUME ["/etc/mosdns"]

WORKDIR /etc/mosdns

ENV PUID=1000 PGID=1000 HOME=/etc/mosdns

COPY docker-entrypoint.sh /bin/entrypoint.sh
RUN chmod a+x /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

EXPOSE ${DNS_PORT} ${DOH_PORT} ${DOT_PORT}

CMD /usr/bin/mosdns -dir /etc/mosdns