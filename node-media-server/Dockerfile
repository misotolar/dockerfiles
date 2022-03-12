ARG NODE_VERSION=lts

FROM node:$NODE_VERSION-alpine

ARG VERSION=107d5d5b11fac6198e5196d10b725e2afc92fcd5
ARG SHA256=d5d921a333bad1e32ac544414e15fe4c190a92605e9dc674d3cddaffeba8c1f7
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