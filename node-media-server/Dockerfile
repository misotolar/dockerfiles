FROM node:lts-alpine

ARG VERSION=ff68dee82d3b76a38640b75b68553e75077c399e
ARG SHA256=300ae524641d07d6178107d18e628b7d9aa27b0ffff06b21a9ebb5740dc8d1c4
ADD https://github.com/misotolar/Node-Media-Server/archive/${VERSION}.tar.gz /tmp/node-media-server.tar.gz

ENV APP_RTMP_PORT 1935
ENV APP_RTMP_HOST 0.0.0.0
ENV APP_RTMP_CHUNK_SIZE 60000
ENV APP_RTMP_GOP_CACHE true
ENV APP_RTMP_PING 30
ENV APP_RTMP_PING_TIMEOUT 60

ENV APP_HTTP_PORT 8000
ENV APP_HTTP_HOST 0.0.0.0
ENV APP_HTTP_ALLOW_ORIGIN *
ENV APP_HTTP_API true

ENV APP_AUTH_API true
ENV APP_AUTH_API_USER admin
ENV APP_AUTH_API_PASS admin
ENV APP_AUTH_PLAY false
ENV APP_AUTH_PUBLISH false
ENV APP_AUTH_SECRET nodemediasecret

WORKDIR /usr/local/node-media-server

RUN set -ex; \
    apk add --no-cache \
        gettext; \
    echo "$SHA256 */tmp/node-media-server.tar.gz" | sha256sum -c -; \
    tar xf /tmp/node-media-server.tar.gz --strip-components=1; \
    npm i; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*;

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY app.template.js .

EXPOSE 1935 8000

STOPSIGNAL SIGKILL
ENTRYPOINT ["entrypoint.sh"]
CMD ["node", "/usr/local/node-media-server/app.js"]