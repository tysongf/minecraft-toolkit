# Core mods
$mods = @{
    "fabric-api.jar" = "https://cdn.modrinth.com/data/P7dR8mSH/versions/m6zu1K31/fabric-api-0.116.7%2B1.21.1.jar"
    "cobblemon.jar" = "https://cdn.modrinth.com/data/MdwFAVRL/versions/cSelWkDu/Cobblemon-fabric-1.7.1%2B1.21.1.jar"
    "glitchcore.jar" = "https://cdn.modrinth.com/data/s3dmwKy5/versions/lbSHOhee/GlitchCore-fabric-1.21.1-2.1.0.0.jar"
    "terrablender.jar" = "https://cdn.modrinth.com/data/kkmrDlKT/versions/XNtIBXyQ/TerraBlender-fabric-1.21.1-4.1.0.8.jar"
    "biomesoplenty.jar" = "https://cdn.modrinth.com/data/HXF82T3G/versions/YPm4arUa/BiomesOPlenty-fabric-1.21.1-21.1.0.13.jar"
    "architectury.jar" = "https://cdn.modrinth.com/data/lhGA9TYQ/versions/ApsT9KZh/architectury-13.0.6-fabric.jar"
    "cobblemon-additions.jar" = "https://cdn.modrinth.com/data/qbeBoSYR/versions/vALAbbJ5/cobblemon-additions-1.0.0%2B1.21.1-fabric.jar"
    "cobblemon-fightorflight.jar" = "https://cdn.modrinth.com/data/W3s9g7No/versions/AdjsGC9u/cobblemon-fightorflight-1.1.0%2B1.21-fabric.jar"
    "almanac.jar" = "https://cdn.modrinth.com/data/A6zlgwC5/versions/K7VXrP13/almanac-fabric-1.21.1-1.0.0.jar"
}

Write-Host "=== Minecraft + Cobblemon + Fight or Flight + Biomes O' Plenty ===" -ForegroundColor Cyan
Write-Host ""

# Check for Java 21
Write-Host "=== Checking Java Installation ===" -ForegroundColor Cyan
$javaInstalled = $false
try {
    $javaVersion = & java -version 2>&1 | Select-String "version" | ForEach-Object { $_ -replace '.*version "([^"]*)".*', '$1' }
    if ($javaVersion -match "^21\.") {
        Write-Host "Java 21 is already installed: $javaVersion" -ForegroundColor Green
        $javaInstalled = $true
    } else {
        Write-Host "Java found but not version 21: $javaVersion" -ForegroundColor Yellow
        Write-Host "Please install Java 21 from: https://adoptium.net/temurin/releases/?version=21" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Java 21 not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Java 21 from:" -ForegroundColor Yellow
    Write-Host "https://adoptium.net/temurin/releases/?version=21" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "After installing Java, restart PowerShell and run this script again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host ""

# Set Minecraft directory
$MINECRAFT_DIR = "$env:APPDATA\.minecraft"
Write-Host "Minecraft directory: $MINECRAFT_DIR" -ForegroundColor Green
Write-Host ""

# Create mods directory
Write-Host "Creating mod directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$MINECRAFT_DIR\mods" | Out-Null

# Download Fabric Installer
Write-Host ""
Write-Host "=== Downloading Fabric Installer ===" -ForegroundColor Cyan
$fabricInstallerUrl = "https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar"
$fabricInstallerPath = "$env:TEMP\fabric-installer.jar"

try {
    Write-Host "Downloading Fabric Installer..."
    Invoke-WebRequest -Uri $fabricInstallerUrl -OutFile $fabricInstallerPath
    
    Write-Host ""
    Write-Host "Installing Fabric 1.21.1 with loader 0.18.3..." -ForegroundColor Yellow
    & java -jar $fabricInstallerPath client -mcversion 1.21.1 -loader 0.18.3 -dir $MINECRAFT_DIR
    
    Remove-Item $fabricInstallerPath
} catch {
    Write-Host "Error downloading or installing Fabric: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Download core mods
Write-Host ""
Write-Host "=== Downloading Core Mods ===" -ForegroundColor Cyan

foreach ($mod in $mods.GetEnumerator()) {
    Write-Host "Downloading $($mod.Key)..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $mod.Value -OutFile "$MINECRAFT_DIR\mods\$($mod.Key)"
    } catch {
        Write-Host "Error downloading $($mod.Key): $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Installation Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Installed mods in: $MINECRAFT_DIR\mods" -ForegroundColor Green
Write-Host ""
Write-Host "Installed mods:" -ForegroundColor Yellow
Get-ChildItem "$MINECRAFT_DIR\mods" | Format-Table Name, Length -AutoSize
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
