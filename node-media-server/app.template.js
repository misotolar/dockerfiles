const NodeMediaServer = require('./');

const config = {
    rtmp: {
        port: ${APP_RTMP_PORT},
        chunk_size: ${APP_RTMP_CHUNK_SIZE},
        gop_cache: ${APP_RTMP_GOP_CACHE},
        ping: ${APP_RTMP_PING},
        ping_timeout: ${APP_RTMP_PING_TIMEOUT}
    },
    http: {
        port: ${APP_HTTP_PORT},
        mediaroot: './media',
        webroot: './www',
        allow_origin: '${APP_HTTP_ALLOW_ORIGIN}',
        api: ${APP_HTTP_API}
    },
    auth: {
        api: ${APP_AUTH_API},
        api_user: '${APP_AUTH_API_USER}',
        api_pass: '${APP_AUTH_API_PASS}',
        play: ${APP_AUTH_PLAY},
        publish: ${APP_AUTH_PUBLISH},
        secret: '${APP_AUTH_SECRET}'
    }
}

let nms = new NodeMediaServer(config)
nms.run();
