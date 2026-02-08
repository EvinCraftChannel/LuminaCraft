FROM alpine:latest
RUN apk add --no-cache lua5.3 luajit build-base cmake git
RUN git clone https://github.com/luvit/lithe.git && cd lithe && make install
COPY . /app
WORKDIR /app
EXPOSE 19132/udp
CMD ["luvit", "main.lua"]