# https://developer.valvesoftware.com/wiki/SteamCMD
FROM cm2network/steamcmd:root

EXPOSE 10999/udp

# ensure image is updated
RUN apt update \
    && apt full-upgrade -y \
    && apt autoremove -y \
    && apt-get clean

# install deps for dst server and fix libcurl-gnutls link
RUN dpkg --add-architecture i386 \
    && apt update && apt install -y libcurl3-gnutls:i386 \
    && apt autoremove -y \
    && apt-get clean \
    && ln -sf /usr/lib/libcurl.so.4 /usr/lib/libcurl-gnutls.so.4 \
    && ldconfig

USER steam
WORKDIR /home/steam/steamcmd

# install dont starve together server
RUN /home/steam/steamcmd/steamcmd.sh +login anonymous \
      +force_install_dir /home/steam/steamapps/DST \
      +app_update 343050 validate \
      +quit
