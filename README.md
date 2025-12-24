# minecraft-toolkit

[Server Setup](#server-setup)
[Client Setup](#client-setup)
---

## Cobblemon

**Client Features:**
- Automatic Minecraft Launcher installation (Linux only)
- Fabric 1.21.1 installation with all required mods
- Optional performance mods (Sodium, Mod Menu)

---

## Server Setup

### Prerequisites
- Oracle Linux (ARM64) or similar
- 10GB+ RAM recommended
- Port 25565 open in firewall

**Server Configuration**
- Minecraft 1.21.1
- Fabric API 0.116.7
- Fabric Loader 0.18.3
- Biomes O' Plenty 21.1.0.13
  - TerraBlender 4.1.0.8 (dependency)
- Cobblemon 1.7.1
  - Glitchcore 2.1.0.0 (dependency)
- Cobblemon Additions 1.0.0
  - Architectury 13.0.6 (dependency)
- Cobblemon Fight or Flight 1.1.0

**Server Performance Mods**
- Lithium 0.15.1
- FerriteCore 7.0.2
- Krypton 0.2.8

**Utility Mods**
- Essential Commands 0.35.1 (server management)
- LuckPerms 5.4.141 (permissions management)
- Let Me Despawn 1.4.0 (performance)
  - Almanac 1.0.0 (dependency)

### Installation Guide

Run `install-cobblemon-server.sh` on your server.

This script will install Cobblemon as a systemd service w/ 8GB RAM allocation.

**Copy script to server:**
```bash
scp -i ~/.ssh/your-key.pem install-cobblemon-server.sh op@your-server:~
```

**Run installation:**
```bash
ssh -i ~/.ssh/your-key.pem op@your-server
chmod +x install-cobblemon-server.sh
./install-cobblemon-server.sh
```

**Enable and start server:**
```bash
sudo systemctl enable cobblemon
sudo systemctl start cobblemon
sudo systemctl status cobblemon
```

### Server Management

```bash
# Control service
sudo systemctl start|stop|restart cobblemon

# Stream minecraft server log
tail -f ~/mc-cobblemon/logs/latest.log
```

**Configuration:** Edit `~/mc-cobblemon/server.properties` for game settings, then restart service.

### File Locations
- Server directory: `~/mc-cobblemon/`
- Mods: `~/mc-cobblemon/mods/`
- World data: `~/mc-cobblemon/world/`
- Config: `~/mc-cobblemon/server.properties`
- Systemd service: `/etc/systemd/system/cobblemon.service`

---

## Client Setup

**⚠️ Version Note:** Clients MUST use Minecraft 1.21.1. The latest version (1.21.11+) is incompatible with Cobblemon 1.7.1. The scripts below will install Fabric 1.21.1 which creates the correct profile.

---

### Linux (Debian/Ubuntu)

`install-cobblemon.sh`

#### Installation

```bash
chmod +x install-cobblemon.sh
./install-cobblemon.sh
```

Auto-installs Minecraft Launcher, Fabric 1.21.1, and all required mods.

---

### Windows

`install-cobblemon.ps1`

Installs a new Minecraft launcher profile called `fabric-loader-1.21.1` with necessary mods to play on the server.

Mods are installed in `%APPDATA%\.minecraft\mods\`

#### Installation

1. **Download** `install-cobblemon.ps1`
2. **Unblock:** Right-click → Properties → Check **Unblock** → OK
3. **Set execution policy (one-time):**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
4. **Run:** Right-click script → **Run with PowerShell**

Auto-installs Java 21 (if needed), Minecraft Launcher, Fabric 1.21.1, and all mods.

---

### Connect to Server

1. Launch Minecraft Launcher
2. Select **fabric-loader-1.21.1** profile (NOT "Latest release")
3. Click **Play**
4. Go to **Multiplayer** → **Add Server**
5. Server Address: `YOUR_SERVER_IP:25565`

---

## Geyser

_Coming soon..._

---

### Links

- [Cobblemon](https://modrinth.com/mod/cobblemon)
- [Fabric](https://fabricmc.net/)
- [Minecraft](https://www.minecraft.net/)

### License

MIT License - free to use and modify.