FROM golang:1.21-alpine AS build

ARG VERSION=20.17.2
ARG SHA256=a70deed7d2e5ee1247b9b6265a6f0a012a8861039f5bd06403dfa61846c79d95
ADD https://github.com/drone-plugins/drone-docker/archive/refs/tags/v${VERSION}.tar.gz /tmp/drone-docker.tar.gz

ARG CGO_ENABLED=0
ARG GO111MODULE=on

WORKDIR /build

RUN set -ex; \
    echo "$SHA256 */tmp/drone-docker.tar.gz" | sha256sum -c -; \
    tar xf /tmp/drone-docker.tar.gz --strip-components=1; \
    go build -v -ldflags "-X main.version=${VERSION:0:8}" -a -tags netgo -o release/linux/amd64/drone-docker ./cmd/drone-docker

FROM docker:24.0.7-dind

LABEL mantainer="michal@sotolar.com"

ENV DOCKER_HOST=unix:///var/run/docker.sock

COPY --from=build /build/release/linux/amd64/drone-docker /bin/

ENTRYPOINT ["/usr/local/bin/dockerd-entrypoint.sh", "/bin/drone-docker"]
