FROM i386/ubuntu:18.04

# Install dependencies and SteamCMD
RUN apt-get update && \
    apt-get install -y curl gdb unzip && \
    echo "I AGREE" | apt-get install -y steamcmd

# Add the steam user
RUN useradd -m steam

# Create the /opt/hlds directory and make steam its owner
RUN mkdir -p /opt/hlds && chown -R steam:steam /opt/hlds

# Change user to steam
USER steam
WORKDIR /home/steam

# Update steamcmd and symlink the library directory
RUN /usr/games/steamcmd +quit && \
    ln -s ~/.steam/steamcmd/linux32 ~/.steam/sdk32

# Install HLDS
# (running app_update multiple times to deal with incomplete downloads,
# as suggested at https://developer.valvesoftware.com/wiki/SteamCMD)
RUN n=0; \
    until [ $n -ge 5 ]; do \
        /usr/games/steamcmd \
            +login anonymous \
            +force_install_dir /opt/hlds \
            +app_update 90 validate \
            +quit; \
        status=$?; \
        echo "SteamCMD has exited with code $status"; \
        if [ $status -eq 0 ]; then break; else sleep 1; fi; \
        n=$((n+1)); \
    done; \
    exit $status

# Install Metamod
RUN curl -qsL "https://www.amxmodx.org/release/metamod-1.21.1-am.zip" -o metamod.zip && \
    unzip metamod.zip -d /opt/hlds/cstrike && \
    rm -f metamod.zip

# Install AMX Mod X
RUN cd /opt/hlds/cstrike && \
    curl -qsL "https://www.amxmodx.org/release/amxmodx-1.8.2-base-linux.tar.gz" \
        | tar -zxvf - && \
    curl -qsL "https://www.amxmodx.org/release/amxmodx-1.8.2-cstrike-linux.tar.gz" \
        | tar -zxvf -

# Add the configuration files
COPY --chown=steam:steam cstrike /opt/hlds/cstrike

# Expose the ports used by HLDS
EXPOSE 26900/udp
EXPOSE 27015
EXPOSE 27015/udp
EXPOSE 27020/udp

# Run the server
WORKDIR /opt/hlds
ENTRYPOINT ["./hlds_run", "-game", "cstrike"]
