# FROM ubuntu:latest
FROM cm2network/steamcmd:latest


# Install SteamCMD

# RUN apt update
# RUN apt install -y software-properties-common
# RUN add-apt-repository multiverse
# RUN dpkg --add-architecture i386
# RUN apt update
# RUN echo steam steam/question select "I AGREE" | debconf-set-selections
# RUN apt install -y steamcmd

# Add server files and entrypoint script
USER 0
RUN apt update
RUN apt install -y --no-install-recommends --no-install-suggests sqlite3 libsqlite3-dev
USER 1000
WORKDIR /home/steam/
ADD --chown=steam ./scripts/entrypoint.sh .
ADD --chown=steam ./scripts/aniv-ds.sh .

# Expose ports

EXPOSE 7776-7779/tcp
EXPOSE 7776-7779/udp

# Start server

ENTRYPOINT ["./entrypoint.sh"]