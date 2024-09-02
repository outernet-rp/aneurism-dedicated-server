FROM ubuntu:latest

#Add server files and entrypoint script

WORKDIR /home/steam/steamcmd/
ADD ./ds/ .
ADD ./scripts/entrypoint.sh .

# Expose ports
EXPOSE 7777
EXPOSE 7778
EXPOSE 7779

# Start server
CMD ["./entrypoint.sh"]