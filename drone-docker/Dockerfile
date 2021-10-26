FROM golang:1.13-alpine AS build

ARG VERSION=6ec5e7141117e1489faa378b1c00e459d789642d
ARG URL=https://github.com/drone-plugins/drone-docker.git

ARG CGO_ENABLED=0
ARG GO111MODULE=on

WORKDIR /build

RUN set -ex; \
    apk add --no-cache --upgrade \
        git; \
    git clone ${URL} --depth=1 .; \
    git reset --hard ${VERSION}; \
    go build -v -ldflags "-X main.version=${VERSION:0:8}" -a -tags netgo -o release/linux/amd64/drone-docker ./cmd/drone-docker

FROM docker:20.10.10-dind

LABEL mantainer="michal@sotolar.com"

ENV DOCKER_HOST=unix:///var/run/docker.sock

COPY --from=build /build/release/linux/amd64/drone-docker /bin/

ENTRYPOINT ["/usr/local/bin/dockerd-entrypoint.sh", "/bin/drone-docker"]
