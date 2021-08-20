FROM --platform=${TARGETPLATFORM} golang:1.16-alpine as builder
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

RUN apk add --no-cache ca-certificates su-exec tzdata

RUN mkdir /etc/mosdns

VOLUME ["/etc/mosdns"]

WORKDIR /etc/mosdns

ENV TZ=Asia/Shanghai
RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
	echo "${TZ}" > /etc/timezone

ENV PUID=1000 PGID=1000 HOME=/etc/mosdns

COPY docker-entrypoint.sh /bin/entrypoint.sh
RUN chmod a+x /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

CMD /usr/bin/mosdns -dir /etc/mosdns