FROM ghcr.io/archlinux/archlinux:base-devel-20240502.0.233219

LABEL maintainer="michal@sotolar.com"

RUN set -ex; \
    useradd -m build; \
    pacman -Syu --noconfirm; \
    pacman -Sy --noconfirm git python-keyring python-urllib3 rsync

COPY config/sudoers /etc/sudoers.d/build
COPY config/gpg.conf /home/build/.gnupg/gpg.conf
COPY config/oscrc /home/build/.config/osc/oscrc

USER build
WORKDIR /home/build

RUN set -ex; \
    sudo chmod 0700 /home/build/.gnupg; \
    sudo chown -R build:build /home/build/.gnupg; \
    sudo chmod 0700 /home/build/.config/osc; \
    sudo chown -R build:build /home/build/.config/osc; \
    git clone https://aur.archlinux.org/osc.git; \
    cd osc && makepkg --noconfirm --syncdeps --rmdeps --install --clean && cd ..; \
    rm -rf osc

COPY makepkg.sh /usr/local/bin/makepkg.sh

ENTRYPOINT ["makepkg.sh"]
