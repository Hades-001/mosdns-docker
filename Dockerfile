FROM --platform=${TARGETPLATFORM} golang:1.18-bullseye as builder

ARG CGO_ENABLED=0
ARG TAG
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /root

RUN set -ex && \
    apt-get update && \
    apt-get install --no-install-recommends -y ca-certificates git libcap2-bin && \
    git clone https://github.com/IrineSistiana/mosdns mosdns && \
    cd ./mosdns && \
    git fetch --all --tags && \
    git checkout tags/${TAG} && \
    go build -ldflags "-s -w -X main.version=${TAG}" -trimpath -o mosdns && \
    setcap CAP_NET_BIND_SERVICE=+eip mosdns

FROM --platform=${TARGETPLATFORM} debian:11-slim
COPY --from=builder /root/mosdns/mosdns /usr/bin/

ARG DEBIAN_FRONTEND=noninteractive

RUN set -ex && \
    apt-get update && \
    apt-get install --no-install-recommends -y ca-certificates tzdata gosu && \
    rm -rf /var/lib/apt/lists/*

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
	echo "${TZ}" > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata

VOLUME ["/etc/mosdns"]

WORKDIR /etc/mosdns

ENV PUID=1000 PGID=1000 HOME=/etc/mosdns

COPY docker-entrypoint.sh /bin/entrypoint.sh
RUN chmod a+x /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

CMD /usr/bin/mosdns -dir /etc/mosdns
