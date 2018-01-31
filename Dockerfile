FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
            automake \
            build-essential \
            checkinstall \
            libavcodec-dev \
            libavutil-dev \
            libcairo2-dev \
            libfreerdp-dev \
            libossp-uuid-dev \
            libpango1.0-dev \
            libpng12-dev \
            libpulse-dev \
            libssh2-1-dev \
            libssl-dev \
            libswscale-dev \
            libtelnet-dev \
            libvncserver-dev \
            libvorbis-dev \
            libwebp-dev \
            man-db \
            parallel \
            rsyslog \
            runit \
            tomcat7 \
            wget \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8080
VOLUME /etc/guacamole
VOLUME /file-transfer

ENV VERSION=0.9.13
WORKDIR /APP/bin/remote
RUN wget "http://archive.apache.org/dist/incubator/guacamole/${VERSION}-incubating/source/guacamole-server-${VERSION}-incubating.tar.gz" \
    && tar zxvf guacamole-server-${VERSION}-incubating.tar.gz

COPY en_gb_qwerty.keymap /APP/bin/remote/guacamole-server-${VERSION}-incubating/src/protocols/rdp/keymaps/en_gb_qwerty.keymap
COPY Keymap.patch /tmp/Keymap.patch
COPY rsyslog.conf /etc/rsyslog.conf
COPY start.sh /usr/local/bin/start.sh
COPY rsyslog.init /etc/sv/rsyslog/run
COPY tomcat.init /etc/sv/tomcat/run
COPY guacd.init /etc/sv/guacd/run

RUN cd /APP/bin/remote/guacamole-server-${VERSION}-incubating/src/protocols/rdp \
    && patch -b < /tmp/Keymap.patch \
    && cd /APP/bin/remote/guacamole-server-${VERSION}-incubating \
    && ./configure --with-init-dir=/etc/init.d \
    && make \
    && make install \
    && ldconfig  \
    && mkdir /usr/lib/x86_64-linux-gnu/freerdp \
    && ln -s /usr/local/lib/freerdp/*.so /usr/lib/x86_64-linux-gnu/freerdp/. \
    && cd /APP/bin/remote \
    && wget http://archive.apache.org/dist/incubator/guacamole/${VERSION}-incubating/binary/guacamole-${VERSION}-incubating.war \
    && ln -s /APP/bin/remote/guacamole-${VERSION}-incubating.war /var/lib/tomcat7/webapps/remote.war \
    && echo "GUACAMOLE_HOME=/etc/guacamole" >> /etc/default/tomcat7 \
    && chown tomcat7:tomcat7 /file-transfer \
    && rm -rf /etc/sv/getty-5 \
    && rm -rf /etc/rsyslog.d \
    && chmod +x /usr/local/bin/start.sh \
    && chmod +x /etc/sv/*/run \
    && ln -s /etc/sv/* /etc/service

HEALTHCHECK \
    --interval=1m \
    --timeout=3s \
    --start-period=30s \
    --retries=3 \
    CMD pidof guacd > /dev/null || exit 1

ENTRYPOINT ["/bin/bash"]
CMD ["/usr/local/bin/start.sh"]
 
