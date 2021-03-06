ARG NODE_VERSION=10.24.1

FROM node:${NODE_VERSION}-alpine

ARG VERSION=94d5d209ade772d192e6bb0fdbdec28c609000bb
ARG URL=https://github.com/misotolar/Node-Media-Server

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
        bash \
        gettext \
        ffmpeg \
        tzdata; \
    apk add --no-cache --virtual .fetch-deps \
        git; \
    git clone ${URL} --depth=1 .; \
    git reset --hard ${VERSION}; \
    npm i; \
    apk del --no-network .fetch-deps; \
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