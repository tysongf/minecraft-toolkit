# Cobblemon Minecraft Server Setup

Automated installation scripts for setting up a Minecraft 1.21.1 Fabric server with Cobblemon and client installation.

## 📑 Table of Contents

- [What This Does](#-what-this-does)
- [Prerequisites](#-prerequisites)
  - [Server Requirements](#server-requirements)
  - [Client Requirements](#client-requirements)
- [Server Installation](#-server-installation)
- [Client Installation](#-client-installation)
  - [Windows](#windows)
  - [Linux (Debian/Ubuntu)](#linux-debianubuntu)
  - [macOS](#macos)
  - [Connect to Server](#connect-to-server)
- [Installed Mods](#-installed-mods)
- [Server Management](#-server-management)
- [Troubleshooting](#-troubleshooting)
- [File Locations](#-file-locations)
- [Contributing](#-contributing)
- [Links](#-links)
- [Notes](#%EF%B8%8F-notes)

## 🎮 What This Does

These scripts automate the entire setup process for running a Cobblemon Minecraft server and getting clients connected.

**Server Features:**
- Minecraft 1.21.1 with Fabric Loader 0.18.3
- Cobblemon 1.7.1 (Pokémon in Minecraft!)
- Biomes O' Plenty (more biomes for Pokémon spawning)
- Performance mods (Lithium, FerriteCore, Krypton)
- Systemd service for auto-start
- 8GB RAM allocation

**Client Features:**
- Automatic Minecraft Launcher installation (Linux only)
- Fabric 1.21.1 installation
- All required mods
- Optional performance mods (Sodium, Mod Menu)

## 📋 Prerequisites

### Server Requirements
- Oracle Linux (ARM64/aarch64) or similar
- 8GB+ RAM recommended
- Java 21 (installed by script)
- Port 25565 open in firewall

### Client Requirements
- Java 21 installed
- Valid Minecraft account (purchased game)
- Linux: Debian/Ubuntu for auto-launcher install, or download manually
- macOS/Windows: Download launcher manually from minecraft.net

## 🚀 Server Installation

### 1. Copy Script to Server
```bash
scp -i ~/.ssh/your-key.pem install-cobblemon-server.sh user@your-server:~
```

### 2. Run Installation
```bash
ssh -i ~/.ssh/your-key.pem user@your-server
chmod +x install-cobblemon-server.sh
./install-cobblemon-server.sh
```

### 3. Configure Oracle Cloud Security List
Open port 25565 in your Oracle Cloud VCN:
1. Go to **Networking** → **Virtual Cloud Networks**
2. Click your VCN → **Security Lists** → **Default Security List**
3. Click **Add Ingress Rules**
4. Configure:
   - Source CIDR: `0.0.0.0/0`
   - IP Protocol: TCP
   - Destination Port: `25565`
5. Click **Add Ingress Rules**

### 4. Start Server
```bash
# Enable service (auto-start on boot)
sudo systemctl enable cobblemon
sudo systemctl start cobblemon

# Check status
sudo systemctl status cobblemon

# View logs
sudo journalctl -u cobblemon -f
```

## 💻 Client Installation

### Windows

**Prerequisites:**
- Windows 10 or 11
- PowerShell (pre-installed on Windows)
- Valid Minecraft account

**Step 1: Download the script**
Download `install-cobblemon-client.ps1` from the repository.

**Step 2: Unblock the script**
Right-click the downloaded `.ps1` file → **Properties** → Check **Unblock** → Click **OK**

**Step 3: Set execution policy (one-time setup)**
Open PowerShell as Administrator and run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
Type `Y` and press Enter to confirm.

**Step 4: Run the installer**
Right-click `install-cobblemon-client.ps1` → **Run with PowerShell**

OR open PowerShell in the download folder and run:
```powershell
.\install-cobblemon-client.ps1
```

The script will automatically:
- Install Java 21 (if not already installed)
- Install Minecraft Launcher (download manually if needed)
- Install Fabric 1.21.1
- Download all required mods

### Linux (Debian/Ubuntu)
```bash
chmod +x install-cobblemon.sh
./install-cobblemon.sh
```

The script will automatically:
- Install Minecraft Launcher
- Install Fabric 1.21.1
- Download all required mods

### macOS

**Prerequisites:**
- macOS 10.14 or later
- Java 21 installed ([Download here](https://adoptium.net/temurin/releases/?version=21))
- Valid Minecraft account

**Installation:**
1. Download Minecraft Launcher from https://minecraft.net
2. Download `install-cobblemon.sh` from the repository
3. Open Terminal and navigate to the download folder:
```bash
cd ~/Downloads
chmod +x install-cobblemon.sh
./install-cobblemon.sh
```

The script will automatically install Fabric 1.21.1 and download all required mods.

### Connect to Server
1. Launch Minecraft Launcher
2. Select **fabric-loader-1.21.1** profile
3. Click **Play**
4. Go to **Multiplayer** → **Add Server**
5. Server Address: `YOUR_SERVER_IP` (port 25565 is automatic)

## 📦 Installed Mods

### Server & Client Mods
- Fabric API 0.116.7
- Cobblemon 1.7.1
- Glitchcore 2.1.0.0
- TerraBlender 4.1.0.8
- Biomes O' Plenty 21.1.0.13

### Server-Only Mods (Performance)
- Lithium 0.15.1
- FerriteCore 7.0.2
- Krypton 0.2.8

### Client-Only Mods (Optional)
- Sodium 0.6.8 (performance boost)
- Mod Menu 11.0.3 (view installed mods)

## 🔧 Server Management

### Start/Stop Server
```bash
# Using systemd service
sudo systemctl start cobblemon
sudo systemctl stop cobblemon
sudo systemctl restart cobblemon
```

### View Logs
```bash
# Real-time logs
sudo journalctl -u cobblemon -f

# Last 100 lines
sudo journalctl -u cobblemon -n 100
```

### Server Configuration
Edit `~/mc-cobblemon/server.properties` to change:
- Server port
- Game mode
- Difficulty
- Max players
- MOTD (message of the day)

After editing, restart the server:
```bash
sudo systemctl restart cobblemon
```

### Add Operators/Admins
While server is running:
```bash
# Connect to server console
screen -r minecraft  # if running in screen
# or check logs and use RCON

# Or edit ops.json directly
nano ~/mc-cobblemon/ops.json
```

## 🐛 Troubleshooting

### Server won't start
```bash
# Check logs
sudo journalctl -u cobblemon -n 50

# Check Java version
java -version  # Should be 21

# Verify systemd service
sudo systemctl status cobblemon
```

### Can't connect to server
1. Check server is running: `sudo systemctl status cobblemon`
2. Check firewall: `sudo firewall-cmd --list-ports` (should show 25565/tcp)
3. Check Oracle Cloud Security List has port 25565 open
4. Verify client is using Minecraft 1.21.1 (not 1.21.4 or other versions)

### Mods not loading
```bash
# Check mods directory
ls -lh ~/mc-cobblemon/mods/

# Re-download corrupted mods
cd ~/mc-cobblemon/mods
rm broken-mod.jar
wget [mod-download-url]
```

### Out of memory
Edit the systemd service to change RAM allocation:
```bash
sudo nano /etc/systemd/system/cobblemon.service

# Change -Xmx8G and -Xms8G to different values in the ExecStart line
# For example: ExecStart=/usr/bin/java -Xmx4G -Xms4G -jar ...

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart cobblemon
```

## 📝 File Locations

### Server
- Server directory: `~/mc-cobblemon/`
- Mods: `~/mc-cobblemon/mods/`
- World data: `~/mc-cobblemon/world/`
- Config: `~/mc-cobblemon/server.properties`
- Systemd service: `/etc/systemd/system/cobblemon.service`

### Client
- Minecraft directory: `~/.minecraft/` (Linux), `~/Library/Application Support/minecraft/` (macOS)
- Mods: `~/.minecraft/mods/`
- Logs: `~/.minecraft/logs/latest.log`

## 🤝 Contributing

Feel free to open issues or submit pull requests for improvements!

## 📄 License

MIT License - feel free to use and modify these scripts.

## 🔗 Links

- [Cobblemon](https://modrinth.com/mod/cobblemon)
- [Fabric](https://fabricmc.net/)
- [Minecraft](https://www.minecraft.net/)
- [Oracle Cloud](https://www.oracle.com/cloud/)

## ⚠️ Notes

- These scripts are designed for Oracle Linux ARM64 instances
- Client script auto-installs launcher on Debian/Ubuntu only
- Server requires 8GB+ RAM for smooth performance
- Always backup your world data before updates!

### Version Compatibility
**IMPORTANT:** Clients must use Minecraft 1.21.1 to connect to this server.
- The latest Minecraft version is 1.21.11 (as of December 2024)
- This server uses 1.21.1 because Cobblemon doesn't support 1.21.11 yet
- When launching Minecraft, select the **fabric-loader-1.21.1** profile, NOT "Latest release"
- Version mismatch will result in "Incompatible client" or "Network protocol error"