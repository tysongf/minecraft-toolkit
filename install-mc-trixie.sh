#!/usr/bin/env bash

# Install Minecraft Launcher on Debian 13 (Trixie)
# secure download using curl, trap-based cleanup, idempotent behavior.

set -euo pipefail

PROGNAME="$(basename "$0")"
TMPDIR=""
ASSUME_YES=0

log() { printf "%s\n" "$*"; }
err() { printf "ERROR: %s\n" "$*" >&2; }
die() { err "$*"; cleanup; exit 1; }

usage() {
    cat <<EOF
Usage: $PROGNAME [--yes|-y] [--help|-h]

Installs the official Minecraft Launcher on Debian/Trixie systems.
Options:
  -y, --yes     Assume yes for prompts (non-interactive)
  -h, --help    Show this help
EOF
}

cleanup() {
    if [[ -n "$TMPDIR" && -d "$TMPDIR" ]]; then
        rm -rf "$TMPDIR"
    fi
}

trap cleanup EXIT

while [[ ${#} -gt 0 ]]; do
    case "$1" in
        -y|--yes) ASSUME_YES=1; shift ;;
        -h|--help) usage; exit 0 ;;
        --) shift; break ;;
        -*) err "Unknown option: $1"; usage; exit 2 ;;
        *) break ;;
    esac
done

if command -v minecraft-launcher &>/dev/null; then
    log "Minecraft Launcher is already installed. Exiting."
    exit 0
fi

if ! command -v apt-get &>/dev/null || ! command -v dpkg &>/dev/null; then
    die "This script requires apt-get and dpkg (Debian/Ubuntu)."
fi

# Prepare temporary workspace
TMPDIR=$(mktemp -d /tmp/mc-launcher.XXXX)
control_file="$TMPDIR/libgdk-pixbuf2.0-0-dummy"
deb_out="$TMPDIR/libgdk-pixbuf2.0-0_999.0_all.deb"
launcher_deb="$TMPDIR/Minecraft.deb"

SUDO=''
if [[ $EUID -ne 0 ]]; then
    if command -v sudo &>/dev/null; then
        SUDO='sudo'
    else
        die "Must be run as root or have sudo available."
    fi
fi

log "Updating package lists..."
if [[ $ASSUME_YES -eq 1 ]]; then
    $SUDO apt-get update -y
else
    $SUDO apt-get update
fi

log "Installing required packages: libgdk-pixbuf-2.0-0 libgdk-pixbuf-xlib-2.0-0 equivs curl"
$SUDO apt-get install -y --no-install-recommends libgdk-pixbuf-2.0-0 libgdk-pixbuf-xlib-2.0-0 equivs curl

# Create a compatibility package to satisfy older dependency names
log "Creating compatibility package for libgdk-pixbuf2.0-0..."
cat > "$control_file" <<EOF
Section: misc
Priority: optional
Standards-Version: 3.9.2

Package: libgdk-pixbuf2.0-0
Version: 999.0
Maintainer: Local User <local@localhost>
Depends: libgdk-pixbuf-2.0-0
Architecture: all
Description: Dummy package to satisfy Minecraft Launcher dependency
 This is a dummy package that allows the Minecraft Launcher to install
 on newer Debian/Ubuntu systems where libgdk-pixbuf2.0-0 has been
 replaced by libgdk-pixbuf-2.0-0.
EOF

pushd "$TMPDIR" >/dev/null
if ! command -v equivs-build &>/dev/null; then
    die "equivs-build not available after install. Aborting."
fi
equivs-build "$control_file"
if [[ ! -f "$deb_out" ]]; then
    # Try to find generated deb file if equivs-build names it differently
    generated=(/tmp/libgdk-pixbuf2.0-0_*.deb "$TMPDIR"/libgdk-pixbuf2.0-0_*.deb)
    for f in "${generated[@]}"; do
        [[ -f "$f" ]] && mv -f "$f" "$deb_out" && break
    done
fi

if [[ -f "$deb_out" ]]; then
    $SUDO dpkg -i "$deb_out" || true
else
    err "Failed to build dummy deb; continuing — package may still work without it."
fi

log "Downloading Minecraft Launcher..."
if ! curl -fSL "https://launcher.mojang.com/download/Minecraft.deb" -o "$launcher_deb"; then
    die "Failed to download Minecraft Launcher from official URL."
fi

log "Installing Minecraft Launcher (requires sudo)..."
$SUDO dpkg -i "$launcher_deb" || true

log "Fixing broken dependencies (if any)..."
$SUDO apt-get install -f -y

log "Cleaning up temporary files..."
popd >/dev/null

log "Minecraft Launcher installation finished. Verify by running: minecraft-launcher"
