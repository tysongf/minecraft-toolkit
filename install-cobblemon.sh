#!/bin/bash

echo "=== Minecraft 1.21.1 Client + Mods Installer ==="
echo ""

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MINECRAFT_DIR="$HOME/.minecraft";;
    Darwin*)    MINECRAFT_DIR="$HOME/Library/Application Support/minecraft";;
    MINGW*|MSYS*|CYGWIN*)    MINECRAFT_DIR="$APPDATA/.minecraft";;
    *)          MINECRAFT_DIR="$HOME/.minecraft";;
esac

echo "Detected OS: ${OS}"
echo "Minecraft directory: ${MINECRAFT_DIR}"
echo ""

# Install Minecraft Launcher on Linux
if [[ "$OS" == "Linux" ]]; then
    echo "=== Installing Minecraft Launcher ==="

    # Check if launcher is already installed
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
fi

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

# Download required mods
echo ""
echo "=== Downloading Required Mods ==="
cd "${MINECRAFT_DIR}/mods"

echo "Downloading Fabric API..."
wget https://cdn.modrinth.com/data/P7dR8mSH/versions/m6zu1K31/fabric-api-0.116.7%2B1.21.1.jar -O fabric-api.jar

echo "Downloading Cobblemon..."
wget https://cdn.modrinth.com/data/MdwFAVRL/versions/s64m1opn/Cobblemon-fabric-1.7.1%2B1.21.1.jar -O cobblemon.jar

echo "Downloading Glitchcore..."
wget https://cdn.modrinth.com/data/s3dmwKy5/versions/lbSHOhee/GlitchCore-fabric-1.21.1-2.1.0.0.jar -O glitchcore.jar

echo "Downloading TerraBlender..."
wget https://cdn.modrinth.com/data/kkmrDlKT/versions/XNtIBXyQ/TerraBlender-fabric-1.21.1-4.1.0.8.jar -O terrablender.jar

echo "Downloading Biomes O' Plenty..."
wget https://cdn.modrinth.com/data/HXF82T3G/versions/YPm4arUa/BiomesOPlenty-fabric-1.21.1-21.1.0.13.jar -O biomesoplenty.jar

# Optional performance mods
echo ""
echo "=== Downloading Optional Performance Mods ==="

echo "Downloading Sodium (performance)..."
wget https://cdn.modrinth.com/data/AANobbMI/versions/u1OEbNKx/sodium-fabric-0.6.13%2Bmc1.21.1.jar -O sodium.jar

echo "Downloading Mod Menu..."
wget https://cdn.modrinth.com/data/mOgUt4GM/versions/YIfqIJ8q/modmenu-11.0.3.jar -O modmenu.jar

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
echo "Note: If you don't have the Minecraft launcher installed, download it from:"
echo "https://www.minecraft.net/en-us/download"
echo ""
echo "macOS users: The launcher must be downloaded manually from the website above."
