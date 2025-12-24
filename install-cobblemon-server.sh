#!/bin/bash

# Minecraft Fabric + Cobblemon Server Setup Script
# For Oracle Linux ARM64

# Server configuration
MINECRAFT_VERSION="1.21.1"
FABRIC_LOADER="0.18.3"
SERVER_PORT="25565"
MAX_PLAYERS="12"
RAM_ALLOCATION="8G"
SERVER_MOTD="Cobblemon + Biomes O' Plenty"

# Server mod URLs dictionary
declare -A SERVER_MODS=(
    # Dependencies
    ["fabric-api"]="https://cdn.modrinth.com/data/P7dR8mSH/versions/m6zu1K31/fabric-api-0.116.7%2B1.21.1.jar"
    ["glitchcore"]="https://cdn.modrinth.com/data/s3dmwKy5/versions/lbSHOhee/GlitchCore-fabric-1.21.1-2.1.0.0.jar"
    ["architectury"]="https://cdn.modrinth.com/data/lhGA9TYQ/versions/Wto0RchG/architectury-13.0.8-fabric.jar"
    ["terrablender"]="https://cdn.modrinth.com/data/kkmrDlKT/versions/XNtIBXyQ/TerraBlender-fabric-1.21.1-4.1.0.8.jar"
    ["patchouli"]="https://cdn.modrinth.com/data/nU0bVIaL/versions/sAUHGZXc/Patchouli-1.21.1-92-FABRIC.jar"
    ["almanac"]="https://cdn.modrinth.com/data/Gi02250Z/versions/PntWxGkY/Almanac-1.21.1-2-fabric-1.5.0.jar"

    # Gameplay mods
    ["cobblemon"]="https://cdn.modrinth.com/data/MdwFAVRL/versions/s64m1opn/Cobblemon-fabric-1.7.1%2B1.21.1.jar"
    ["biomesoplenty"]="https://cdn.modrinth.com/data/HXF82T3G/versions/YPm4arUa/BiomesOPlenty-fabric-1.21.1-21.1.0.13.jar"
    ["cobblemon-additions"]="https://cdn.modrinth.com/data/W2pr9jyL/versions/degN5DK4/cobblemon-additions-4.1.6.jar"
    ["cobblemon-fightorflight"]="https://cdn.modrinth.com/data/cTdIg5HZ/versions/dqn9P04w/fightorflight-fabric-0.10.3.jar"
    ["cobblepedia"]="https://cdn.modrinth.com/data/2obPz7jf/versions/4wBW6vUa/Cobblepedia-Fabric-0.7.1.jar"

    # Utility mods
    ["essential-commands"]="https://cdn.modrinth.com/data/6VdDUivB/versions/kev3hDqV/essential_commands-0.35.2-mc1.21.jar"
    ["luckperms"]="https://cdn.modrinth.com/data/Vebnzrzj/versions/l47d4ZWk/LuckPerms-Fabric-5.4.140.jar"

    # Performance mods
    ["lithium"]="https://cdn.modrinth.com/data/gvQqBUqZ/versions/E5eJVp4O/lithium-fabric-0.15.1%2Bmc1.21.1.jar"
    ["ferritecore"]="https://cdn.modrinth.com/data/uXXizFIs/versions/bwKMSBhn/ferritecore-7.0.2-hotfix-fabric.jar"
    ["krypton"]="https://cdn.modrinth.com/data/fQEb0iXm/versions/Acz3ttTp/krypton-0.2.8.jar"
    ["let-me-despawn"]="https://cdn.modrinth.com/data/vE2FN5qn/versions/Wb7jqi55/letmedespawn-1.21.x-fabric-1.5.0.jar"
)

echo "=== Minecraft Fabric + Cobblemon Server Setup ==="
echo ""

# Update system
echo "Updating system..."
sudo dnf update -y

# Install Adoptium Java 21 (ARM64)
echo "Installing Adoptium Java 21 for ARM64..."
wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.5_11.tar.gz
sudo mkdir -p /opt/java
sudo tar -xzf OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.5_11.tar.gz -C /opt/java
sudo ln -sf /opt/java/jdk-21.0.5+11/bin/java /usr/bin/java
rm OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.5_11.tar.gz

# Verify Java installation
java -version

# Create minecraft directory
echo "Creating minecraft server directory..."
mkdir -p ~/mc-cobblemon
cd ~/mc-cobblemon

# Download Fabric server installer
echo "Downloading Fabric server installer..."
curl -OJ https://meta.fabricmc.net/v2/versions/loader/${MINECRAFT_VERSION}/${FABRIC_LOADER}/1.1.0/server/jar
mv fabric-server-mc.*.jar fabric-server-launch.jar

# Accept EULA
echo "Accepting Minecraft EULA..."
echo "eula=true" > eula.txt

# Create server.properties with basic settings
cat > server.properties << EOF
server-port=${SERVER_PORT}
gamemode=survivalnsdnf,asdf
difficulty=easy
max-players=${MAX_PLAYERS}
motd=${SERVER_MOTD}
white-list=false
spawn-protection=0
view-distance=10
simulation-distance=10
online-mode=true
allow-flight=true
EOF

# Create mods directory
mkdir -p mods

# Download mods
echo ""
echo "=== Downloading Mods ==="
cd mods

for mod_name in "${!SERVER_MODS[@]}"; do
    echo "Downloading ${mod_name}..."
    wget "${SERVER_MODS[$mod_name]}" -O "${mod_name}.jar"
done

cd ~/mc-cobblemon

# Open firewall for Minecraft port
echo ""
echo "Opening firewall port ${SERVER_PORT}..."
sudo firewall-cmd --permanent --add-port=${SERVER_PORT}/tcp
sudo firewall-cmd --reload

# Create systemd service for auto-start
echo "Creating systemd service..."
sudo tee /etc/systemd/system/cobblemon.service > /dev/null << EOF
[Unit]
Description=Minecraft Cobblemon Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/mc-cobblemon
ExecStart=/usr/bin/java -Xmx${RAM_ALLOCATION} -Xms${RAM_ALLOCATION} -jar $HOME/mc-cobblemon/fabric-server-launch.jar nogui
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Server location: ~/mc-cobblemon"
echo "Installed mods:"
echo "  - Fabric API, Cobblemon, Biomes O' Plenty"
echo "  - Cobblemon Additions, Fight or Flight, Cobblepedia, Almanac"
echo "  - Essential Commands, LuckPerms"
echo "  - Performance: Lithium, FerriteCore, Krypton, Let Me Despawn"
echo ""
echo "To enable and start the server:"
echo "  sudo systemctl enable cobblemon"
echo "  sudo systemctl start cobblemon"
echo ""
echo "To check server status:"
echo "  sudo systemctl status cobblemon"
echo ""
echo "To view server logs:"
echo "  sudo journalctl -u cobblemon -f"
echo ""
echo "To stop the server:"
echo "  sudo systemctl stop cobblemon"
echo ""
echo "Don't forget to allow TCP port ${SERVER_PORT} through your firewall!"
echo ""
