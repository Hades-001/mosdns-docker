FROM --platform=${TARGETPLATFORM} golang:alpine as builder
ARG CGO_ENABLED=0
ARG TAG

WORKDIR /root
RUN set -ex && \
	apk add --update git && \
	git clone https://github.com/IrineSistiana/mosdns mosdns && \
	cd ./mosdns && \
	git fetch --all --tags && \
	git checkout tags/${TAG} && \
	go build -ldflags "-s -w -X main.version=${TAG}" -trimpath -o mosdns

FROM --platform=${TARGETPLATFORM} alpine:latest
COPY --from=builder /root/mosdns/mosdns /usr/bin/

RUN apk add --no-cache ca-certificates su-exec

RUN mkdir /etc/mosdns

VOLUME ["/etc/mosdns"]

WORKDIR /etc/mosdns

ENV PUID=1000 PGID=1000 HOME=/etc/mosdns

COPY docker-entrypoint.sh /bin/entrypoint.sh
RUN chmod a+x /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

EXPOSE 53/udp 53/tcp

CMD /usr/bin/mosdns -dir /etc/mosdns