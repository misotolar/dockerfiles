FROM archlinux:base-devel

LABEL maintainer="michal@sotolar.com"

RUN set -ex; \
    useradd -m build; \
    pacman -Syu --noconfirm; \
    pacman -Sy --noconfirm git

COPY config/sudoers /etc/sudoers.d/build
COPY config/gpg.conf /home/build/.gnupg/gpg.conf

USER build
WORKDIR /home/build

RUN set -ex; \
    git clone https://aur.archlinux.org/paru-bin.git; \
    cd paru-bin && makepkg --noconfirm --syncdeps --rmdeps --install --clean && cd ..; \
    rm -rf paru-bin

COPY makepkg.sh /usr/local/bin/makepkg.sh

ENTRYPOINT ["makepkg.sh"]
