FROM ubuntu:latest

# Install SteamCMD

RUN apt update
RUN apt install -y software-properties-common
RUN add-apt-repository multiverse
RUN dpkg --add-architecture i386
RUN apt update
RUN echo steam steam/question select "I AGREE" | debconf-set-selections
RUN apt install -y steamcmd

# Add server files and entrypoint script

RUN useradd -ms /bin/bash steam
USER steam
WORKDIR /home/steam/
# ADD ./ds/ .
ADD --chown=steam ./scripts/entrypoint.sh .
ADD --chown=steam ./scripts/aniv-ds.sh .

# Expose ports

EXPOSE 7777
EXPOSE 7778
EXPOSE 7779

# Start server

CMD ["./entrypoint.sh"]