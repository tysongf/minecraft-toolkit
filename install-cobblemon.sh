```bash
#!/bin/bash

# Mod URLs dictionary
declare -A MODS=(
    ["fabric-api"]="https://cdn.modrinth.com/data/P7dR8mSH/versions/m6zu1K31/fabric-api-0.116.7%2B1.21.1.jar"
    ["cobblemon"]="https://cdn.modrinth.com/data/MdwFAVRL/versions/cSelWkDu/Cobblemon-fabric-1.7.1%2B1.21.1.jar"
    ["glitchcore"]="https://cdn.modrinth.com/data/s3dmwKy5/versions/lbSHOhee/GlitchCore-fabric-1.21.1-2.1.0.0.jar"
    ["terrablender"]="https://cdn.modrinth.com/data/kkmrDlKT/versions/XNtIBXyQ/TerraBlender-fabric-1.21.1-4.1.0.8.jar"
    ["biomesoplenty"]="https://cdn.modrinth.com/data/HXF82T3G/versions/YPm4arUa/BiomesOPlenty-fabric-1.21.1-21.1.0.13.jar"
    ["architectury"]="https://cdn.modrinth.com/data/lhGA9TYQ/versions/ApsT9KZh/architectury-13.0.6-fabric.jar"
    ["cobblemon-additions"]="https://cdn.modrinth.com/data/qbeBoSYR/versions/vALAbbJ5/cobblemon-additions-1.0.0%2B1.21.1-fabric.jar"
    ["cobblemon-fightorflight"]="https://cdn.modrinth.com/data/W3s9g7No/versions/AdjsGC9u/cobblemon-fightorflight-1.1.0%2B1.21-fabric.jar"
    ["almanac"]="https://cdn.modrinth.com/data/A6zlgwC5/versions/K7VXrP13/almanac-fabric-1.21.1-1.0.0.jar"
)

echo "=== Minecraft 1.21.1 Client + Mods Installer ==="
echo ""

MINECRAFT_DIR="$HOME/.minecraft"
echo "Minecraft directory: ${MINECRAFT_DIR}"
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
cd "${MINECRAFT_DIR}/mods"

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
echo "Next steps:"
echo "1. Launch Minecraft Launcher"
echo "2. Select 'fabric-loader-1.21.1' from the dropdown"
echo "3. Click Play"
echo "4. Go to Multiplayer -> Add Server"
echo "5. Server Address: mc1.bitbot.ca"
echo "6. Have fun!"
echo ""
```