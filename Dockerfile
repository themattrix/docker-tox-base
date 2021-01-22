FROM themattrix/pyenv

LABEL maintainer="Matthew Tardiff <mattrix@gmail.com>"

RUN groupadd -r tox --gid=999 && \
    useradd -m -r -g tox --uid=999 tox

# Install gosu to run tox as the "tox" user instead of as root.
# https://github.com/tianon/gosu#from-debian
ENV GOSU_VERSION 1.10
RUN set -x && \
    apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* && \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" && \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" && \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV TOX_PYTHON_VERSION 3.9.1
ENV TOX_VERSION 3.21.2

RUN pyenv local $TOX_PYTHON_VERSION && \
    python -m pip install -U pip && \
    python -m pip install tox==$TOX_VERSION && \
    pyenv local --unset && \
    pyenv rehash

WORKDIR /app
VOLUME /src

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["tox"]
