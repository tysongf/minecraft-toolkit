#!/bin/bash

# Minecraft Fabric + Cobblemon Server Setup Script
# For Oracle Linux ARM64 - Idempotent version

echo "=== Minecraft Fabric + Cobblemon Server Setup ==="
echo ""

# Ask for server configuration
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

# Fixed configuration
MINECRAFT_VERSION="1.21.1"
FABRIC_LOADER="0.18.3"

# Server mod URLs dictionary
declare -A SERVER_MODS=(
    ["fabric-api"]="https://cdn.modrinth.com/data/P7dR8mSH/versions/m6zu1K31/fabric-api-0.116.7%2B1.21.1.jar"
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

# Update system
echo "Updating system..."
sudo dnf update -y

# Check for Java 21
echo ""
echo "=== Checking Java Installation ==="
JAVA_INSTALLED=false
JAVA_CORRECT_VERSION=false

if command -v java &> /dev/null; then
    JAVA_INSTALLED=true
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$JAVA_VERSION" = "21" ]; then
        JAVA_CORRECT_VERSION=true
        echo "Java 21 is already installed!"
    else
        echo "Java $JAVA_VERSION is installed, but Java 21 is required."
    fi
else
    echo "Java is not installed."
fi

# Ask to install Java if needed
if [ "$JAVA_CORRECT_VERSION" = false ]; then
    echo ""
    read -p "Would you like to install Java 21 from Adoptium? (y/n) [default: y]: " INSTALL_JAVA
    INSTALL_JAVA="${INSTALL_JAVA:-y}"
    
    if [[ "$INSTALL_JAVA" =~ ^[Yy]$ ]]; then
        echo ""
        echo "=== Installing Adoptium Java 21 for ARM64 ==="
        
        JAVA_TAR="OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.5_11.tar.gz"
        JAVA_DIR="/opt/java/jdk-21.0.5+11"
        
        if [ -d "$JAVA_DIR" ]; then
            echo "Java 21 directory already exists at $JAVA_DIR"
        else
            if [ ! -f "/tmp/$JAVA_TAR" ]; then
                echo "Downloading Java 21..."
                wget -P /tmp https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/$JAVA_TAR
            else
                echo "Using existing Java tarball from /tmp..."
            fi
            
            echo "Extracting Java 21..."
            sudo mkdir -p /opt/java
            sudo tar -xzf /tmp/$JAVA_TAR -C /opt/java
            rm -f /tmp/$JAVA_TAR
        fi
        
        if [ -L /usr/bin/java ]; then
            CURRENT_LINK=$(readlink -f /usr/bin/java)
            if [ "$CURRENT_LINK" != "$JAVA_DIR/bin/java" ]; then
                echo "Updating Java symlink..."
                sudo ln -sf $JAVA_DIR/bin/java /usr/bin/java
            else
                echo "Java symlink already correctly configured."
            fi
        else
            echo "Creating Java symlink..."
            sudo ln -sf $JAVA_DIR/bin/java /usr/bin/java
        fi
        
        if command -v java &> /dev/null; then
            NEW_JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
            if [ "$NEW_JAVA_VERSION" = "21" ]; then
                echo "Java 21 is available!"
                JAVA_CORRECT_VERSION=true
                java -version
            else
                echo "Error: Java 21 installation may have failed. Found version $NEW_JAVA_VERSION"
                exit 1
            fi
        else
            echo "Error: Java installation failed."
            exit 1
        fi
    else
        echo "Java 21 is required to continue. Please install it manually."
        exit 1
    fi
fi

echo ""

# Create minecraft directory
echo "Creating minecraft server directory..."
mkdir -p "${SERVER_DIR}"
cd "${SERVER_DIR}"

# Check if Fabric server is already installed
FABRIC_JAR="fabric-server-launch.jar"

if [ -f "$FABRIC_JAR" ]; then
    echo "Fabric server jar already exists, skipping download."
else
    echo "Downloading Fabric server installer..."
    curl -OJ https://meta.fabricmc.net/v2/versions/loader/${MINECRAFT_VERSION}/${FABRIC_LOADER}/1.1.0/server/jar
    mv fabric-server-mc.*.jar $FABRIC_JAR
    echo "Fabric server installed successfully!"
fi

# Accept EULA
if [ -f eula.txt ] && grep -q "eula=true" eula.txt; then
    echo "EULA already accepted."
else
    echo "Accepting Minecraft EULA..."
    echo "eula=true" > eula.txt
fi

# Create or update server.properties
if [ -f server.properties ]; then
    echo "server.properties already exists. Updating configuration..."
    sed -i "s/^server-port=.*/server-port=${SERVER_PORT}/" server.properties
    sed -i "s/^max-players=.*/max-players=${MAX_PLAYERS}/" server.properties
    ESCAPED_MOTD=$(echo "$SERVER_MOTD" | sed 's/[&/\]/\\&/g')
    sed -i "s/^motd=.*/motd=${ESCAPED_MOTD}/" server.properties
else
    echo "Creating server.properties..."
    cat > server.properties << 'ENDOFFILE'
server-port=PORTPLACEHOLDER
gamemode=survival
difficulty=easy
max-players=PLAYERSPLACEHOLDER
motd=MOTDPLACEHOLDER
white-list=false
spawn-protection=0
view-distance=10
simulation-distance=10
online-mode=true
allow-flight=true
ENDOFFILE
    sed -i "s/PORTPLACEHOLDER/${SERVER_PORT}/" server.properties
    sed -i "s/PLAYERSPLACEHOLDER/${MAX_PLAYERS}/" server.properties
    ESCAPED_MOTD=$(echo "$SERVER_MOTD" | sed 's/[&/\]/\\&/g')
    sed -i "s/MOTDPLACEHOLDER/${ESCAPED_MOTD}/" server.properties
fi

# Create mods directory
mkdir -p mods

# Download mods
echo ""
echo "=== Downloading Mods ==="
cd mods

for mod_name in "${!SERVER_MODS[@]}"; do
    MOD_FILE="${mod_name}.jar"
    
    if [ -f "$MOD_FILE" ]; then
        echo "Mod ${mod_name} already exists, skipping download."
    else
        echo "Downloading ${mod_name}..."
        wget "${SERVER_MODS[$mod_name]}" -O "${MOD_FILE}"
    fi
done

cd "${SERVER_DIR}"

# Open firewall for Minecraft port
echo ""
echo "Configuring firewall for port ${SERVER_PORT}..."
if sudo firewall-cmd --list-ports | grep -q "${SERVER_PORT}/tcp"; then
    echo "Port ${SERVER_PORT}/tcp already open in firewall."
else
    echo "Opening firewall port ${SERVER_PORT}..."
    sudo firewall-cmd --permanent --add-port=${SERVER_PORT}/tcp
    sudo firewall-cmd --reload
fi

# Create or update systemd service
SERVICE_FILE="/etc/systemd/system/cobblemon.service"
SERVICE_CHANGED=false

if [ -f "$SERVICE_FILE" ]; then
    echo "Systemd service already exists. Checking if update is needed..."
    
    TEMP_SERVICE=$(mktemp)
    cat > "$TEMP_SERVICE" << 'ENDSERVICE'
[Unit]
Description=Minecraft Cobblemon Server
After=network.target

[Service]
Type=simple
User=USERPLACEHOLDER
WorkingDirectory=DIRPLACEHOLDER
ExecStart=/usr/bin/java -XmxRAMPLACEHOLDER -XmsRAMPLACEHOLDER -jar DIRPLACEHOLDER/fabric-server-launch.jar nogui
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
ENDSERVICE
    sed -i "s|USERPLACEHOLDER|${USER}|g" "$TEMP_SERVICE"
    sed -i "s|DIRPLACEHOLDER|${SERVER_DIR}|g" "$TEMP_SERVICE"
    sed -i "s|RAMPLACEHOLDER|${RAM_ALLOCATION}|g" "$TEMP_SERVICE"
    
    if ! diff -w "$SERVICE_FILE" "$TEMP_SERVICE" > /dev/null 2>&1; then
        echo "Service configuration changed. Updating..."
        sudo cp "$TEMP_SERVICE" "$SERVICE_FILE"
        SERVICE_CHANGED=true
    else
        echo "Service configuration unchanged."
    fi
    
    rm -f "$TEMP_SERVICE"
else
    echo "Creating systemd service..."
    TEMP_SERVICE=$(mktemp)
    cat > "$TEMP_SERVICE" << 'ENDSERVICE'
[Unit]
Description=Minecraft Cobblemon Server
After=network.target

[Service]
Type=simple
User=USERPLACEHOLDER
WorkingDirectory=DIRPLACEHOLDER
ExecStart=/usr/bin/java -XmxRAMPLACEHOLDER -XmsRAMPLACEHOLDER -jar DIRPLACEHOLDER/fabric-server-launch.jar nogui
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
ENDSERVICE
    sed -i "s|USERPLACEHOLDER|${USER}|g" "$TEMP_SERVICE"
    sed -i "s|DIRPLACEHOLDER|${SERVER_DIR}|g" "$TEMP_SERVICE"
    sed -i "s|RAMPLACEHOLDER|${RAM_ALLOCATION}|g" "$TEMP_SERVICE"
    sudo cp "$TEMP_SERVICE" "$SERVICE_FILE"
    rm -f "$TEMP_SERVICE"
    SERVICE_CHANGED=true
fi

# Reload systemd if service changed
if [ "$SERVICE_CHANGED" = true ]; then
    echo "Reloading systemd daemon..."
    sudo systemctl daemon-reload
fi

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Server location: ${SERVER_DIR}"
echo "RAM allocation: ${RAM_ALLOCATION}"
echo "Server port: ${SERVER_PORT}"
echo "Max players: ${MAX_PLAYERS}"
echo ""
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
echo "You can run this script again safely - it will skip already installed components."
echo ""