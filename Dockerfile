FROM ubuntu:latest

RUN set -ex\
    && apt update -y \
    && apt upgrade -y \
    && apt install -y wget nginx qrencode\
    && apt autoremove -y

COPY build.sh /build.sh
RUN chmod +x /build.sh
CMD /build.sh
