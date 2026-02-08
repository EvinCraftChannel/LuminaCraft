FROM alpine:3.18

RUN apk add --no-cache \
    luajit \
    luajit-dev \
    build-base \
    cmake \
    git \
    openssl-dev \
    leveldb-dev \
    leveldb \
    curl \
    bash

WORKDIR /app
RUN curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh
RUN cp lit /usr/local/bin/lit && cp luvi /usr/local/bin/luvi

COPY . /app

EXPOSE 19132/udp

CMD ["./luvit", "main.lua"]
