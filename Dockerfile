FROM debian:12-slim

# Add PhasecoreX user-entrypoint script
ADD https://raw.githubusercontent.com/PhasecoreX/docker-user-image/master/user-entrypoint.sh /bin/user-entrypoint
RUN chmod +x /bin/user-entrypoint && /bin/user-entrypoint --init
ENTRYPOINT ["/bin/user-entrypoint"]

# Install dependencies to run the server
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends  \
        # Updater
        bzip2 \
        ca-certificates \
        curl \
        xz-utils \
    ; \
    rm -rf /var/lib/apt/lists/*

# Add local files
COPY root/ /

# Ports are as follows:
# 7777  UDP/IP  (Game Port)
# 7778  UDP/IP  (Query Port; game port + 1)
# 7779  UDP/IP  (Query Port; game port + 2)
# 7780  UDP/IP  (GameSpy Query Port; game port + 3)
# 7781  UDP/IP  (GameSpy Query Port; game port + 4)
EXPOSE 7777/udp 7778/udp 7779/udp 7780/udp 7781/udp

CMD ["/app/start_server.sh"]
