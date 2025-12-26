#!/bin/bash

# Minecraft 1.21.1 Client + Mods Installer for Linux
# Bash Script - Fixed GPG key handling

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

# Check for Java 21 (prompt to install Temurin from Adoptium if missing)
echo "=== Checking Java Installation ==="
need_java_install=0
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$JAVA_VERSION" = "21" ]; then
        echo "Java 21 is already installed!"
    else
        echo "Java found but not version 21 (found: $JAVA_VERSION)."
        need_java_install=1
    fi
else
    echo "Java not found."
    need_java_install=1
fi

if [ "$need_java_install" -eq 1 ]; then
    read -r -p "Install Temurin (Adoptium) JRE 21 automatically? [Y/n] " reply
    reply=${reply:-Y}
    case "$reply" in
        [Yy]* )
            echo "Installing Temurin JRE 21..."
            # Detect distro
            . /etc/os-release 2>/dev/null || true
            ID_LIKE_LOWER=$(echo "${ID_LIKE:-$ID}" | tr '[:upper:]' '[:lower:]')

            if echo "$ID_LIKE_LOWER" | grep -E "debian|ubuntu|linux" >/dev/null 2>&1 && [ -f /etc/debian_version ]; then
                echo "Detected Debian/Ubuntu. Adding Adoptium APT repo and installing temurin-21-jre..."
                CODENAME="$(. /etc/os-release && echo ${VERSION_CODENAME:-${UBUNTU_CODENAME:-$(lsb_release -cs 2>/dev/null)}})"
                if [ -z "$CODENAME" ]; then
                    CODENAME="$(lsb_release -cs 2>/dev/null || echo buster)"
                fi
                
                # Modern GPG key handling for Debian/Ubuntu (not deprecated apt-key)
                echo "Installing GPG key for Adoptium repository..."
                sudo mkdir -p /etc/apt/keyrings
                wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | \
                    sudo gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg
                
                # Create sources list with signed-by directive
                echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb ${CODENAME} main" | \
                    sudo tee /etc/apt/sources.list.d/adoptium.list >/dev/null
                
                sudo apt-get update
                sudo apt-get install -y temurin-21-jre
            elif echo "$ID_LIKE_LOWER" | grep -E "rhel|fedora|centos|amzn" >/dev/null 2>&1 || [ -f /etc/redhat-release ]; then
                echo "Detected RHEL/CentOS/Fedora. Adding Adoptium YUM repo and installing temurin-21-jre..."
                sudo tee /etc/yum.repos.d/adoptium.repo >/dev/null <<'REPO'
[adoptium]
name=Adoptium
baseurl=https://packages.adoptium.net/artifactory/rpm/
enabled=1
gpgcheck=1
gpgkey=https://packages.adoptium.net/artifactory/api/gpg/key/public
REPO
                if command -v dnf >/dev/null 2>&1; then
                    sudo dnf makecache
                    sudo dnf install -y temurin-21-jre
                else
                    sudo yum makecache
                    sudo yum install -y temurin-21-jre
                fi
            else
                echo "Distro not detected or not supported for package install; falling back to tarball install into /opt/temurin-21." 
                TMPDIR=$(mktemp -d)
                ARCH=$(uname -m)
                if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
                    TARNAME="OpenJDK21U-jre_x64_linux_hotspot.tar.gz"
                elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
                    TARNAME="OpenJDK21U-jre_aarch64_linux_hotspot.tar.gz"
                else
                    echo "Unsupported architecture: $ARCH. Please install Java 21 manually from https://adoptium.net/."
                    exit 1
                fi
                # Try GitHub releases redirect (best-effort)
                echo "Downloading $TARNAME..."
                if ! curl -L -o "$TMPDIR/$TARNAME" "https://github.com/adoptium/temurin21-binaries/releases/latest/download/$TARNAME" --fail; then
                    echo "Failed to download tarball automatically. Please install Java 21 manually from https://adoptium.net/."
                    rm -rf "$TMPDIR"
                    exit 1
                fi
                sudo mkdir -p /opt/temurin-21
                sudo tar -xzf "$TMPDIR/$TARNAME" -C /opt/temurin-21 --strip-components=1
                sudo ln -sf /opt/temurin-21/bin/java /usr/local/bin/java
                rm -rf "$TMPDIR"
            fi

            # Verify installation
            if command -v java &> /dev/null; then
                NEW_VER=$(java -version 2>&1 | head -n1 | cut -d'"' -f2 | cut -d'.' -f1)
                if [ "$NEW_VER" = "21" ]; then
                    echo "Temurin JRE 21 installed successfully."
                else
                    echo "Java installed but major version is $NEW_VER (expected 21). Please verify installation."
                    exit 1
                fi
            else
                echo "Java still not found after attempted install. Please install Java 21 manually from https://adoptium.net/."
                exit 1
            fi
            ;;
        * )
            echo "User chose not to install Java automatically. Please install Java 21 from https://adoptium.net/ and re-run this script."
            exit 1
            ;;
    esac
fi

echo ""

# Install Minecraft Launcher on Debian/Ubuntu
echo "=== Installing Minecraft Launcher ==="
if command -v minecraft-launcher &> /dev/null; then
    echo "Minecraft Launcher is already installed!"
else
    echo "Installing required dependencies for Minecraft Launcher..."
    sudo apt-get update
    sudo apt-get install -y libgdk-pixbuf2.0-0 libgdk-pixbuf-2.0-0
    
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
echo "To launch Minecraft:"
echo "1. Open the Minecraft Launcher"
echo "2. Select the 'fabric-loader-0.18.3-1.21.1' profile"
echo "3. Click Play!"
echo ""