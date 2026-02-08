FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    cmake \
    libssl-dev \
    libleveldb-dev \
    libleveldb1d \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN curl -fsSL https://github.com/luvit/lit-install/raw/master/install.sh | sh && \
    mv lit luvi luvit /usr/local/bin/

RUN lit install creationix/json && \
    lit install luvit/secure-socket

COPY . .

EXPOSE 19132/udp
EXPOSE 8080/tcp

CMD ["luvit", "main.lua"]
