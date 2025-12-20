# Minecraft 1.21.1 Client + Mods Installer for Windows
# PowerShell Script

Write-Host "=== Minecraft 1.21.1 Client + Mods Installer ===" -ForegroundColor Cyan
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
    }
} catch {
    Write-Host "Java not found" -ForegroundColor Yellow
}

if (-not $javaInstalled) {
    Write-Host ""
    Write-Host "=== Installing Adoptium Java 21 ===" -ForegroundColor Cyan
    
    $javaInstallerUrl = "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_windows_hotspot_21.0.5_11.msi"
    $javaInstallerPath = "$env:TEMP\adoptium-jdk-21.msi"
    
    try {
        Write-Host "Downloading Java 21 installer..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $javaInstallerUrl -OutFile $javaInstallerPath
        
        Write-Host "Installing Java 21 (this may take a minute)..." -ForegroundColor Yellow
        Write-Host "Please follow the installer prompts if any appear..." -ForegroundColor Yellow
        Start-Process msiexec.exe -ArgumentList "/i `"$javaInstallerPath`" /quiet /norestart ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome" -Wait
        
        Remove-Item $javaInstallerPath
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Write-Host "Java 21 installed successfully!" -ForegroundColor Green
        
        # Verify installation
        try {
            $javaVersion = & java -version 2>&1 | Select-String "version"
            Write-Host "Verified: $javaVersion" -ForegroundColor Green
        } catch {
            Write-Host "Java installed but not yet in PATH. You may need to restart PowerShell." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error installing Java: $_" -ForegroundColor Red
        Write-Host "Please download and install Java 21 manually from:" -ForegroundColor Yellow
        Write-Host "https://adoptium.net/temurin/releases/?version=21" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
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

# Download required mods
Write-Host ""
Write-Host "=== Downloading Required Mods ===" -ForegroundColor Cyan

$mods = @{
    "fabric-api.jar" = "https://cdn.modrinth.com/data/P7dR8mSH/versions/m6zu1K31/fabric-api-0.116.7%2B1.21.1.jar"
    "cobblemon.jar" = "https://cdn.modrinth.com/data/MdwFAVRL/versions/cSelWkDu/Cobblemon-fabric-1.7.1%2B1.21.1.jar"
    "glitchcore.jar" = "https://cdn.modrinth.com/data/s3dmwKy5/versions/lbSHOhee/GlitchCore-fabric-1.21.1-2.1.0.0.jar"
    "terrablender.jar" = "https://cdn.modrinth.com/data/kkmrDlKT/versions/XNtIBXyQ/TerraBlender-fabric-1.21.1-4.1.0.8.jar"
    "biomesoplenty.jar" = "https://cdn.modrinth.com/data/HXF82T3G/versions/YPm4arUa/BiomesOPlenty-fabric-1.21.1-21.1.0.13.jar"
}

foreach ($mod in $mods.GetEnumerator()) {
    Write-Host "Downloading $($mod.Key)..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $mod.Value -OutFile "$MINECRAFT_DIR\mods\$($mod.Key)"
    } catch {
        Write-Host "Error downloading $($mod.Key): $_" -ForegroundColor Red
    }
}

# Optional performance mods
Write-Host ""
Write-Host "=== Downloading Optional Performance Mods ===" -ForegroundColor Cyan

$optionalMods = @{
    "sodium.jar" = "https://cdn.modrinth.com/data/AANobbMI/versions/4OZL6q6h/sodium-fabric-0.6.8%2Bmc1.21.1.jar"
    "modmenu.jar" = "https://cdn.modrinth.com/data/mOgUt4GM/versions/qc95ajME/modmenu-11.0.3.jar"
}

foreach ($mod in $optionalMods.GetEnumerator()) {
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
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Launch Minecraft Launcher"
Write-Host "2. Select 'fabric-loader-1.21.1' from the dropdown"
Write-Host "3. Click Play"
Write-Host "4. Go to Multiplayer -> Add Server"
Write-Host "5. Server Address: mc1.bitbot.ca"
Write-Host "6. Have fun!"
Write-Host ""
Write-Host "Note: If you don't have the Minecraft launcher installed, download it from:" -ForegroundColor Yellow
Write-Host "https://www.minecraft.net/en-us/download"
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
