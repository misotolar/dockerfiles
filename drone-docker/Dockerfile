FROM golang:1.17-alpine AS build

ARG VERSION=20.14.4
ARG SHA256=ea751c6202679237fc235cc0ecb43da42790900d7ef642ca7ea902e3e0968740
ADD https://github.com/drone-plugins/drone-docker/archive/refs/tags/v${VERSION}.tar.gz /tmp/drone-docker.tar.gz

ARG CGO_ENABLED=0
ARG GO111MODULE=on

WORKDIR /build

RUN set -ex; \
    echo "$SHA256 */tmp/drone-docker.tar.gz" | sha256sum -c -; \
    tar xf /tmp/drone-docker.tar.gz --strip-components=1; \
    go build -v -ldflags "-X main.version=${VERSION:0:8}" -a -tags netgo -o release/linux/amd64/drone-docker ./cmd/drone-docker

FROM docker:24.0.2-dind

LABEL mantainer="michal@sotolar.com"

ENV DOCKER_HOST=unix:///var/run/docker.sock

COPY --from=build /build/release/linux/amd64/drone-docker /bin/

ENTRYPOINT ["/usr/local/bin/dockerd-entrypoint.sh", "/bin/drone-docker"]
