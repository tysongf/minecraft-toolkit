#!/bin/bash

# Minecraft 1.21.1 Client + Mods Installer for Linux
# Bash Script

# Mod URLs dictionary
declare -A MODS=(
    # Dependencies
    ["fabric-api"]="https://cdn.modrinth.com/data/P7dR8mSH/versions/m6zu1K31/fabric-api-0.116.7%2B1.21.1.jar"
    ["glitchcore"]="https://cdn.modrinth.com/data/s3dmwKy5/versions/lbSHOhee/GlitchCore-fabric-1.21.1-2.1.0.0.jar"
    ["architectury"]="https://cdn.modrinth.com/data/lhGA9TYQ/versions/Wto0RchG/architectury-13.0.8-fabric.jar"
    ["terrablender"]="https://cdn.modrinth.com/data/kkmrDlKT/versions/XNtIBXyQ/TerraBlender-fabric-1.21.1-4.1.0.8.jar"
    ["almanac"]="https://cdn.modrinth.com/data/Gi02250Z/versions/PntWxGkY/Almanac-1.21.1-2-fabric-1.5.0.jar"
    
    # Gameplay mods
    ["cobblemon"]="https://cdn.modrinth.com/data/MdwFAVRL/versions/s64m1opn/Cobblemon-fabric-1.7.1%2B1.21.1.jar"
    ["biomesoplenty"]="https://cdn.modrinth.com/data/HXF82T3G/versions/YPm4arUa/BiomesOPlenty-fabric-1.21.1-21.1.0.13.jar"
    ["cobblemon-additions"]="https://cdn.modrinth.com/data/W2pr9jyL/versions/degN5DK4/cobblemon-additions-4.1.6.jar"
    ["cobblemon-fightorflight"]="https://cdn.modrinth.com/data/cTdIg5HZ/versions/dqn9P04w/fightorflight-fabric-0.10.3.jar"
    
    # Performance mods
    ["sodium"]="https://cdn.modrinth.com/data/AANobbMI/versions/u1OEbNKx/sodium-fabric-0.6.13%2Bmc1.21.1.jar"
    ["lithium"]="https://cdn.modrinth.com/data/gvQqBUqZ/versions/E5eJVp4O/lithium-fabric-0.15.1%2Bmc1.21.1.jar"
    ["ferritecore"]="https://cdn.modrinth.com/data/uXXizFIs/versions/bwKMSBhn/ferritecore-7.0.2-hotfix-fabric.jar"
    ["krypton"]="https://cdn.modrinth.com/data/fQEb0iXm/versions/Acz3ttTp/krypton-0.2.8.jar"
    ["modmenu"]="https://cdn.modrinth.com/data/mOgUt4GM/versions/YIfqIJ8q/modmenu-11.0.3.jar"
)

echo "=== Minecraft 1.21.1 Client + Mods Installer ==="
echo ""

MINECRAFT_DIR="$HOME/.minecraft"
echo "Minecraft directory: ${MINECRAFT_DIR}"
echo ""

# Check for Java 21
echo "=== Checking Java Installation ==="
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$JAVA_VERSION" = "21" ]; then
        echo "Java 21 is already installed!"
    else
        echo "Java found but not version 21. Please install Java 21."
        echo "Visit: https://adoptium.net/temurin/releases/?version=21"
        exit 1
    fi
else
    echo "Java 21 not found!"
    echo "Please install Java 21 from: https://adoptium.net/temurin/releases/?version=21"
    exit 1
fi

echo ""

# Install Minecraft Launcher on Debian/Ubuntu
echo "=== Installing Minecraft Launcher ==="
if command -v minecraft-launcher &> /dev/null; then
    echo "Minecraft Launcher is already installed!"
else
    echo "Downloading Minecraft Launcher..."
    wget https://launcher.mojang.com/download/Minecraft.deb -O /tmp/Minecraft.deb
    
    echo "Installing Minecraft Launcher (requires sudo)..."
    sudo dpkg -i /tmp/Minecraft.deb
    
    echo "Fixing dependencies..."
    sudo apt-get install -f -y
    
    rm /tmp/Minecraft.deb
    echo "Minecraft Launcher installed successfully!"
fi

echo ""

# Create directories
echo "Creating mod directory..."
mkdir -p "${MINECRAFT_DIR}/mods"

# Download Fabric Installer
echo ""
echo "=== Downloading Fabric Installer ==="
cd /tmp
wget https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar -O fabric-installer.jar

echo ""
echo "Installing Fabric 1.21.1 with loader 0.18.3..."
java -jar fabric-installer.jar client -mcversion 1.21.1 -loader 0.18.3 -dir "${MINECRAFT_DIR}"

rm fabric-installer.jar

# Download mods
echo ""
echo "=== Downloading Mods ==="
cd "${MINECRAFT_DIR}/mods"

for mod_name in "${!MODS[@]}"; do
    echo "Downloading ${mod_name}..."
    wget "${MODS[$mod_name]}" -O "${mod_name}.jar"
done

echo ""
echo "=== Installation Complete! ==="
echo ""
echo "Installed mods in: ${MINECRAFT_DIR}/mods"
echo ""
echo "Installed mods:"
ls -lh "${MINECRAFT_DIR}/mods"
echo ""
