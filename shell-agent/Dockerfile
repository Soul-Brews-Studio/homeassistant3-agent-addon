FROM ghcr.io/home-assistant/base:3.24

RUN apk add --no-cache \
        bash \
        build-base \
        curl \
        git \
        nodejs \
        npm \
        openssh-server \
    && mkdir -p /run/sshd

COPY run.sh /run.sh
RUN chmod 0755 /run.sh

EXPOSE 2222

CMD ["/run.sh"]
