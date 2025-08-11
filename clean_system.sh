#!/bin/bash
# Ubuntu/Linux System Cleanup Script with Safe Mode (--dry-run)
# Automatically performs cleanup of cache, logs, and unused packages

DRYRUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRYRUN=true
    echo "[SAFE MODE] Showing files to be deleted without actually removing them."
fi

run_cmd() {
    if $DRYRUN; then
        echo "[SIMULATION] Would run: $*"
    else
        eval "$@"
    fi
}

echo "[INFO] Starting system cleanup..."

# 1. Clean systemd logs
echo "[INFO] Cleaning journalctl logs..."
if ! $DRYRUN; then
    sudo journalctl --vacuum-time=5d
    sudo journalctl --vacuum-size=1G
else
    echo "[SIMULATION] sudo journalctl --vacuum-time=5d"
    echo "[SIMULATION] sudo journalctl --vacuum-size=1G"
fi

# 2. Check running apt processes
echo "[INFO] Checking for running apt processes..."
sudo ps aux | grep apt

# 3. Remove apt cache and locks
echo "[INFO] Removing apt cache and lock files..."
run_cmd "sudo rm -f /var/cache/apt/pkgcache.bin"
run_cmd "sudo rm -f /var/cache/apt/srcpkgcache.bin"
run_cmd "sudo rm -f /var/lib/apt/lists/lock"
run_cmd "sudo rm -f /var/cache/apt/archives/lock"
run_cmd "sudo rm -vf /var/lib/apt/lists/*"
run_cmd "sudo rm -rf /var/lib/apt/lists/*"
run_cmd "sudo rm -f /var/lib/dpkg/lock-frontend"
run_cmd "sudo rm -f /var/lib/dpkg/lock"

# 4. Reconfigure dpkg
echo "[INFO] Reconfiguring packages..."
if ! $DRYRUN; then
    sudo dpkg --configure -a
else
    echo "[SIMULATION] sudo dpkg --configure -a"
fi

# 5. Clear browser caches
echo "[INFO] Removing browser caches..."
run_cmd "sudo rm -rf ~/.cache/mozilla/firefox/"
run_cmd "sudo rm -rf ~/.cache/google-chrome/"
run_cmd "sudo rm -rf ~/.mozilla/firefox/*.default-release/storage/*"
run_cmd "sudo rm -rf ~/.mozilla/firefox/*.default-release/cache/*"
run_cmd "sudo rm -rf ~/.config/google-chrome/Default/Cache/*"
run_cmd "sudo rm -rf ~/.config/chromium/Default/Cache/*"

# 6. Clear trash, general cache, and thumbnails
echo "[INFO] Removing trash and cache..."
run_cmd "sudo rm -rf ~/.local/share/Trash/*"
run_cmd "sudo rm -rf ~/.cache/*"
run_cmd "sudo rm -rf ~/.cache/thumbnails/*"

# 7. Clean temporary folders
echo "[INFO] Removing temporary files..."
run_cmd "sudo rm -rf /tmp/*"
run_cmd "sudo rm -rf /var/tmp/*"

# 8. Remove old logs
echo "[INFO] Removing old log files..."
run_cmd "sudo rm -rf /var/log/*.gz /var/log/*.old"

# 9. Remove unused packages
echo "[INFO] Cleaning up unused packages..."
if ! $DRYRUN; then
    sudo apt autoremove -y
    sudo apt remove -y
    sudo apt autoclean -y
    sudo apt clean -y
    sudo apt autopurge -y
    sudo apt purge -y
else
    echo "[SIMULATION] sudo apt autoremove -y"
    echo "[SIMULATION] sudo apt remove -y"
    echo "[SIMULATION] sudo apt autoclean -y"
    echo "[SIMULATION] sudo apt clean -y"
    echo "[SIMULATION] sudo apt autopurge -y"
    echo "[SIMULATION] sudo apt purge -y"
fi

echo "[DONE] System cleanup completed!"
