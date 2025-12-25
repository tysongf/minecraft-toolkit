#!/bin/bash
set -Eeuo pipefail
IFS=$'\n\t'

trap 'echo "❌ Error on line $LINENO. Exiting."; exit 1' ERR

# Minecraft Fabric + Cobblemon Server Setup Script
# Oracle Linux ARM64 – Hardened & Idempotent

echo "=== Minecraft Fabric + Cobblemon Server Setup ==="
echo ""

#################################
# User Configuration
#################################

read -p "Enter server installation directory [default: $HOME/mc-cobblemon]: " SERVER_DIR
SERVER_DIR="${SERVER_DIR:-$HOME/mc-cobblemon}"
echo "Server will be installed to: ${SERVER_DIR}"
echo ""

read -p "Enter RAM allocation (e.g., 4G, 8G, 16G) [default: 8G]: " RAM_ALLOCATION
RAM_ALLOCATION="${RAM_ALLOCATION:-8G}"
echo "RAM allocation set to: ${RAM_ALLOCATION}"
echo ""

read -p "Enter server port [default: 25565]: " SERVER_PORT
SERVER_PORT="${SERVER_PORT:-25565}"
echo "Server port set to: ${SERVER_PORT}"
echo ""

read -p "Enter max players [default: 12]: " MAX_PLAYERS
MAX_PLAYERS="${MAX_PLAYERS:-12}"
echo "Max players set to: ${MAX_PLAYERS}"
echo ""

read -p "Enter server MOTD [default: Cobblemon + Biomes O Plenty]: " SERVER_MOTD
SERVER_MOTD="${SERVER_MOTD:-Cobblemon + Biomes O Plenty}"
echo "Server MOTD set to: ${SERVER_MOTD}"
echo ""

#################################
# Fixed Versions
#################################

MINECRAFT_VERSION="1.21.1"
FABRIC_LOADER="0.18.3"

#################################
# Mods
#################################

declare -A SERVER_MODS=(
    ["fabric-api"]="https://cdn.modrinth.com/data/P7dR8mSH/versions/m6zu1K31/fabric-api-0.116.7%2B1.21.1.jar"
    ["forge-api"]="https://cdn.modrinth.com/data/ohNO6lps/versions/N5qzq0XV/ForgeConfigAPIPort-v21.1.6-1.21.1-Fabric.jar"
    ["opac"]="https://cdn.modrinth.com/data/gF3BGWvG/versions/uUz4cbjU/open-parties-and-claims-fabric-1.21.1-0.25.8.jar"
    ["glitchcore"]="https://cdn.modrinth.com/data/s3dmwKy5/versions/lbSHOhee/GlitchCore-fabric-1.21.1-2.1.0.0.jar"
    ["architectury"]="https://cdn.modrinth.com/data/lhGA9TYQ/versions/Wto0RchG/architectury-13.0.8-fabric.jar"
    ["terrablender"]="https://cdn.modrinth.com/data/kkmrDlKT/versions/XNtIBXyQ/TerraBlender-fabric-1.21.1-4.1.0.8.jar"
    ["almanac"]="https://cdn.modrinth.com/data/Gi02250Z/versions/PntWxGkY/Almanac-1.21.1-2-fabric-1.5.0.jar"
    ["cobblemon"]="https://cdn.modrinth.com/data/MdwFAVRL/versions/s64m1opn/Cobblemon-fabric-1.7.1%2B1.21.1.jar"
    ["biomesoplenty"]="https://cdn.modrinth.com/data/HXF82T3G/versions/YPm4arUa/BiomesOPlenty-fabric-1.21.1-21.1.0.13.jar"
    ["cobblemon-additions"]="https://cdn.modrinth.com/data/W2pr9jyL/versions/degN5DK4/cobblemon-additions-4.1.6.jar"
    ["cobblemon-fightorflight"]="https://cdn.modrinth.com/data/cTdIg5HZ/versions/dqn9P04w/fightorflight-fabric-0.10.3.jar"
    ["essential-commands"]="https://cdn.modrinth.com/data/6VdDUivB/versions/kev3hDqV/essential_commands-0.35.2-mc1.21.jar"
    ["luckperms"]="https://cdn.modrinth.com/data/Vebnzrzj/versions/l47d4ZWk/LuckPerms-Fabric-5.4.140.jar"
    ["lithium"]="https://cdn.modrinth.com/data/gvQqBUqZ/versions/E5eJVp4O/lithium-fabric-0.15.1%2Bmc1.21.1.jar"
    ["ferritecore"]="https://cdn.modrinth.com/data/uXXizFIs/versions/bwKMSBhn/ferritecore-7.0.2-hotfix-fabric.jar"
    ["krypton"]="https://cdn.modrinth.com/data/fQEb0iXm/versions/Acz3ttTp/krypton-0.2.8.jar"
    ["let-me-despawn"]="https://cdn.modrinth.com/data/vE2FN5qn/versions/Wb7jqi55/letmedespawn-1.21.x-fabric-1.5.0.jar"
)

#################################
# System Prep
#################################

echo "Updating system..."
sudo dnf update -y

#################################
# Java 21 Check
#################################

JAVA_OK=false
if command -v java &>/dev/null; then
    JAVA_VER=$(java -version 2>&1 | awk -F\" 'NR==1{print $2}' | cut -d. -f1)
    [[ "$JAVA_VER" == "21" ]] && JAVA_OK=true
fi

if [[ "$JAVA_OK" == false ]]; then
    read -p "Install Java 21 (Adoptium)? [Y/n]: " INSTALL_JAVA
    INSTALL_JAVA="${INSTALL_JAVA:-Y}"

    if [[ "$INSTALL_JAVA" =~ ^[Yy]$ ]]; then
        JAVA_TAR="OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.5_11.tar.gz"
        JAVA_DIR="/opt/java/jdk-21.0.5+11"

        sudo mkdir -p /opt/java
        wget -q --show-progress -P /tmp \
          https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/$JAVA_TAR

        sudo tar -xzf /tmp/$JAVA_TAR -C /opt/java
        sudo ln -sf "$JAVA_DIR/bin/java" /usr/bin/java
        rm -f /tmp/$JAVA_TAR
    else
        echo "Java 21 required. Exiting."
        exit 1
    fi
fi

#################################
# Server Setup
#################################

mkdir -p "$SERVER_DIR"
cd "$SERVER_DIR"

FABRIC_JAR="fabric-server-launch.jar"
if [[ ! -f "$FABRIC_JAR" ]]; then
    curl -fsSL -o "$FABRIC_JAR" \
      https://meta.fabricmc.net/v2/versions/loader/${MINECRAFT_VERSION}/${FABRIC_LOADER}/1.1.0/server/jar
fi

echo "eula=true" > eula.txt

#################################
# server.properties
#################################

ESCAPED_MOTD=$(printf '%s\n' "$SERVER_MOTD" | sed 's/[&/\\]/\\&/g')

cat > server.properties <<EOF
server-port=${SERVER_PORT}
gamemode=survival
difficulty=normal
max-players=${MAX_PLAYERS}
motd=${ESCAPED_MOTD}
white-list=false
spawn-protection=0
view-distance=10
simulation-distance=10
online-mode=true
allow-flight=true
EOF

#################################
# Mods
#################################

mkdir -p mods
cd mods

for MOD in "${!SERVER_MODS[@]}"; do
    FILE="${MOD}.jar"
    [[ -f "$FILE" ]] || wget -q --show-progress "${SERVER_MODS[$MOD]}" -O "$FILE"
done

#################################
# Firewall
#################################

sudo firewall-cmd --permanent --add-port=${SERVER_PORT}/tcp || true
sudo firewall-cmd --reload

#################################
# systemd Service
#################################

SERVICE_FILE="/etc/systemd/system/cobblemon.service"

sudo tee "$SERVICE_FILE" >/dev/null <<EOF
[Unit]
Description=Minecraft Cobblemon Server
After=network.target

[Service]
User=${USER}
WorkingDirectory=${SERVER_DIR}
ExecStart=/usr/bin/java -Xms${RAM_ALLOCATION} -Xmx${RAM_ALLOCATION} -jar ${SERVER_DIR}/fabric-server-launch.jar nogui
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload

#################################
# Done
#################################

echo ""
echo "✅ Setup Complete"
echo "Enable server:"
echo "  sudo systemctl enable cobblemon"
echo "  sudo systemctl start cobblemon"
echo ""
