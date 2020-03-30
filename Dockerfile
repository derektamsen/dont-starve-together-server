# https://developer.valvesoftware.com/wiki/SteamCMD
FROM cm2network/steamcmd:root

EXPOSE 10999/udp

ENV DST_DEFAULT_SERVER_NAME="A unique server name" \
    DST_DEFAULT_SERVER_DESCRIPTION="A very nice server description" \
    DST_SERVER_PORT="10999" \
    DST_SERVER_PASSWORD="" \
    DST_MAX_PLAYERS="6" \
    DST_PVP="false" \
    DST_GAME_MODE="endless" \
    DST_SERVER_INTENTION="cooperative" \
    DST_ENABLE_SNAPSHOTS="true" \
    DST_ENABLE_AUTOSAVER="true" \
    DST_TICK_RATE="30" \
    DST_CONNECTION_TIMEOUT="8000" \
    DST_SERVER_SAVE_SLOT="1" \
    DST_VOTE_KICK_ENABLED="true" \
    DST_PAUSE_WHEN_EMPTY="true" \
    DST_DEDICATED_LAN_SERVER="true" \
    DST_CLUSTER_TOKEN=""

# ensure image is updated
RUN apt update \
    && apt full-upgrade -y \
    && apt autoremove -y \
    && apt-get clean

# install deps for dst server and fix libcurl-gnutls link
RUN dpkg --add-architecture i386 \
    && apt update && apt install -y tini libcurl3-gnutls:i386 \
    && apt autoremove -y \
    && apt-get clean \
    && ln -sf /usr/lib/libcurl.so.4 /usr/lib/libcurl-gnutls.so.4 \
    && ldconfig \
    && mkdir -p /dstserver/dstserver_config \
    && chown steam:steam -R /dstserver

# add entrypoint script to image
COPY entrypoint /usr/local/bin/entrypoint

USER steam
WORKDIR /home/steam/steamcmd

# install dont starve together server
RUN /home/steam/steamcmd/steamcmd.sh +login anonymous \
      +force_install_dir /dstserver \
      +app_update 343050 validate \
      +quit

ENTRYPOINT ["tini", "--", "entrypoint"]
