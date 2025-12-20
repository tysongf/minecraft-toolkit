#!/bin/bash

# Minecraft Fabric + Cobblemon Server Setup Script
# For Oracle Linux

echo "=== Minecraft Fabric + Cobblemon Server Setup ==="
echo ""

# Update system
echo "Updating system..."
sudo dnf update -y

# Install Adoptium Java 21
echo "Installing Adoptium Java 21..."
wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
sudo mkdir -p /opt/java
sudo tar -xzf OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz -C /opt/java
sudo ln -sf /opt/java/jdk-21.0.5+11/bin/java /usr/bin/java
rm OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz

# Verify Java installation
java -version

# Create minecraft directory
echo "Creating minecraft server directory..."
mkdir -p ~/mc-cobblemon
cd ~/mc-cobblemon

# Download Fabric server installer
echo "Downloading Fabric server installer..."
# Using Minecraft 1.21.1 and latest Fabric loader 0.18.3
MINECRAFT_VERSION="1.21.1"
curl -OJ https://meta.fabricmc.net/v2/versions/loader/${MINECRAFT_VERSION}/0.18.3/1.1.0/server/jar
mv fabric-server-mc.*.jar fabric-server-launch.jar

# Create server startup script
echo "Creating server startup script..."
cat > start.sh << 'EOF'
#!/bin/bash
java -Xmx8G -Xms8G -jar fabric-server-launch.jar nogui
EOF

chmod +x start.sh

# Accept EULA
echo "Accepting Minecraft EULA..."
echo "eula=true" > eula.txt

# Create server.properties with basic settings
cat > server.properties << 'EOF'
server-port=25565
gamemode=survival
difficulty=easy
max-players=12
motd=A Minecraft Server with Cobblemon
white-list=false
spawn-protection=16
view-distance=10
online-mode=true
EOF

# Create mods directory
mkdir -p mods

# Download Fabric API (required for most mods)
echo "Downloading Fabric API..."
# Fabric API for 1.21.1
wget https://cdn.modrinth.com/data/P7dR8mSH/versions/m6zu1K31/fabric-api-0.116.7%2B1.21.1.jar -O mods/fabric-api.jar

# Download Cobblemon
echo "Downloading Cobblemon..."
# Cobblemon 1.7.1 for 1.21.1
wget https://cdn.modrinth.com/data/MdwFAVRL/versions/s64m1opn/Cobblemon-fabric-1.7.1%2B1.21.1.jar -O mods/cobblemon.jar

# Download performance mods
echo "Downloading Lithium (performance)..."
wget https://cdn.modrinth.com/data/gvQqBUqZ/versions/E5eJVp4O/lithium-fabric-0.15.1%2Bmc1.21.1.jar -O mods/lithium.jar

echo "Downloading FerriteCore (memory optimization)..."
wget https://cdn.modrinth.com/data/uXXizFIs/versions/bwKMSBhn/ferritecore-7.0.2-hotfix-fabric.jar -O mods/ferritecore.jar

echo "Downloading Krypton (network optimization)..."
wget https://cdn.modrinth.com/data/fQEb0iXm/versions/Acz3ttTp/krypton-0.2.8.jar -O mods/krypton.jar

# Download biome mods and dependencies
echo "Downloading Glitchcore (dependency)..."
wget https://cdn.modrinth.com/data/s3dmwKy5/versions/lbSHOhee/GlitchCore-fabric-1.21.1-2.1.0.0.jar -O mods/glitchcore.jar

echo "Downloading TerraBlender (biome library)..."
wget https://cdn.modrinth.com/data/kkmrDlKT/versions/XNtIBXyQ/TerraBlender-fabric-1.21.1-4.1.0.8.jar -O mods/terrablender.jar

echo "Downloading Biomes O' Plenty..."
wget https://cdn.modrinth.com/data/HXF82T3G/versions/YPm4arUa/BiomesOPlenty-fabric-1.21.1-21.1.0.13.jar -O mods/biomesoplenty.jar

# Open firewall for Minecraft port
echo "Opening firewall port 25565..."
sudo firewall-cmd --permanent --add-port=25565/tcp
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
ExecStart=$HOME/mc-cobblemon/start.sh
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
echo ""
echo "To start the server manually:"
echo "  cd ~/mc-cobblemon"
echo "  ./start.sh"
echo ""
echo "To enable auto-start on boot:"
echo "  sudo systemctl enable minecraft"
echo "  sudo systemctl start minecraft"
echo ""
echo "To check server status:"
echo "  sudo systemctl status minecraft"
echo ""
echo "To view server logs:"
echo "  sudo journalctl -u minecraft -f"
echo ""
echo "Don't forget to configure Oracle Cloud security list to allow port 25565!"
echo "Go to: Networking -> Virtual Cloud Networks -> Your VCN -> Security Lists"
echo "Add Ingress Rule: Source CIDR: 0.0.0.0/0, Destination Port: 25565, Protocol: TCP"
