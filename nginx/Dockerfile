FROM misotolar/alpine:3.19.1 as build

ARG VERSION=1.25.5
ARG SHA256=2fe2294f8af4144e7e842eaea884182a84ee7970e11046ba98194400902bbec0
ADD http://nginx.org/download/nginx-$VERSION.tar.gz /tmp/nginx.tar.gz

ARG OPENSSL_VERSION=3.3.0
ARG OPENSSL_SHA256=53e66b043322a606abf0087e7699a0e033a37fa13feb9742df35c3a33b18fb02
ADD https://github.com/openssl/openssl/releases/download/openssl-$OPENSSL_VERSION/openssl-$OPENSSL_VERSION.tar.gz /tmp/openssl.tar.gz

ARG BROTLI_VERSION=a71f9312c2deb28875acc7bacfdd5695a111aa53
ARG BROTLI_URL=https://github.com/google/ngx_brotli.git

ARG FANCYINDEX_VERSION=cbc0d3fca4f06414612de441399393d4b3bbb315
ARG FANCYINDEX_URL=https://github.com/aperezdc/ngx-fancyindex.git

WORKDIR /build

RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        cmake \
        gcc \
        git \
        g++ \
        libc-dev \
        libtool \
        make \
        musl-dev \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        linux-headers \
        gnupg \
    ; \
    adduser -u 82 -D -S -G www-data www-data; \
    git config --global init.defaultBranch master; \
    mkdir -p /build/openssl && cd /build/openssl; \
    echo "$OPENSSL_SHA256 */tmp/openssl.tar.gz" | sha256sum -c -; \
    tar xf /tmp/openssl.tar.gz --strip-components=1; \
    mkdir -p /build/brotli && cd /build/brotli; \
    git init; git remote add origin $BROTLI_URL; \
    git fetch --depth 1 origin $BROTLI_VERSION; \
    git checkout --recurse-submodules -q FETCH_HEAD; \
    git submodule update --init --depth 1; \
    mkdir -p /build/brotli/deps/brotli/out && cd /build/brotli/deps/brotli/out; \
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" \
        -DCMAKE_INSTALL_PREFIX=./installed \
        .. \
    ; \
    cmake \
        --build . \
        --config Release \
        --target brotlienc\
    ; \
    mkdir -p /build/fancyindex && cd /build/fancyindex; \
    git init; git remote add origin $FANCYINDEX_URL; \
    git fetch --depth 1 origin $FANCYINDEX_VERSION; \
    git checkout -q FETCH_HEAD; \
    mkdir -p /build/nginx && cd /build/nginx; \
    echo "$SHA256 */tmp/nginx.tar.gz" | sha256sum -c -; \
    tar xf /tmp/nginx.tar.gz --strip-components=1; \
    sed -i -e 's/SSL_OP_CIPHER_SERVER_PREFERENCE);/SSL_OP_CIPHER_SERVER_PREFERENCE | SSL_OP_PRIORITIZE_CHACHA);/g' /build/nginx/src/event/ngx_event_openssl.c; \
    ./configure \
        --user=www-data \
        --group=www-data \
        --sbin-path=/usr/local/sbin/nginx \
        --pid-path=/var/run/nginx/nginx.pid \
        --lock-path=/var/run/nginx/nginx.lock \
        --http-client-body-temp-path=/usr/local/nginx/cache/client \
        --http-fastcgi-temp-path=/usr/local/nginx/cache/fastcgi \
        --http-proxy-temp-path=/usr/local/nginx/cache/proxy \
        --with-openssl=/build/openssl \
        --with-openssl-opt=enable-ktls \
        --with-openssl-opt=enable-ec_nistp_64_gcc_128 \
        --with-compat \
        --with-file-aio \
        --with-pcre-jit \
        --with-threads \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_v3_module \
        --with-http_sub_module \
        --with-http_auth_request_module \
        --with-http_gzip_static_module \
        --without-http_geo_module \
        --without-http_scgi_module \
        --without-http_uwsgi_module \
        --without-http_split_clients_module \
        --without-http_memcached_module \
        --without-http_ssi_module \
        --without-http_empty_gif_module \
        --without-http_browser_module \
        --without-http_userid_module \
        --without-http_mirror_module \
        --without-http_referer_module \
        --without-mail_pop3_module \
        --without-mail_imap_module \
        --without-mail_smtp_module \
        --add-dynamic-module=/build/brotli \
        --add-dynamic-module=/build/fancyindex \
    ; \
    make -j ${BUILD_CORES-$(getconf _NPROCESSORS_CONF)}; \
    make install; \
    mkdir -p /var/run/nginx; \
    mkdir -p /usr/local/nginx/cache; \
    strip /usr/local/sbin/nginx; \
    strip /usr/local/nginx/modules/*.so; \
    scanelf --needed --nobanner /usr/local/sbin/nginx /usr/local/nginx/modules/*.so \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u > /build/runDeps.txt

FROM misotolar/alpine:3.19.1

LABEL maintainer="michal@sotolar.com"

ARG OCSP_FETCHER_VERSION=18d9652fac2d3f9e7d5f88c64be72af30b7e82d2
ADD https://raw.githubusercontent.com/tomwassenberg/certbot-ocsp-fetcher/$OCSP_FETCHER_VERSION/certbot-ocsp-fetcher /usr/local/sbin/certbot-ocsp-fetcher

ARG ERROR_PAGES_VERSION=17554bced347ecea9bd1363f1b96738b1c3d74e3
ADD https://github.com/denysvitali/nginx-error-pages/archive/$ERROR_PAGES_VERSION.tar.gz /tmp/error-pages.tar.gz

COPY --from=build /var/run/nginx /var/run/nginx
COPY --from=build /usr/local/nginx /usr/local/nginx
COPY --from=build /usr/local/sbin/nginx /usr/local/sbin/nginx
COPY --from=build /build/runDeps.txt /tmp/runDeps.txt

COPY snippets /usr/local/nginx/snippets
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /usr/local/nginx

RUN set -ex; \
    apk add --no-cache \
        bash \
        coreutils \
        openssl \
        tzdata \
        util-linux \
        $(cat /tmp/runDeps.txt) \
    ; \
    mkdir -p /usr/local/nginx/errors; \
    tar xf /tmp/error-pages.tar.gz -C /usr/local/nginx/errors --strip-components=1; \
    touch /usr/local/nginx/logs/access.log; \
    ln -sf /dev/stdout /usr/local/nginx/logs/access.log; \
    touch /usr/local/nginx/logs/error.log; \
    ln -sf /dev/stderr /usr/local/nginx/logs/error.log; \
    chmod 755 /usr/local/sbin/certbot-ocsp-fetcher; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

STOPSIGNAL SIGTERM

ENTRYPOINT ["entrypoint.sh"]

CMD ["/usr/local/sbin/nginx", "-g", "daemon off;"]