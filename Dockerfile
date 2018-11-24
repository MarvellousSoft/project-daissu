FROM nidup/love2d:0.10.2

WORKDIR /app

COPY . /app

EXPOSE 47111/udp

CMD ["love", "server"]
