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
    sudo apt autoclean -y
    sudo apt clean -y
else
    echo "[SIMULATION] sudo apt autoremove -y"
    echo "[SIMULATION] sudo apt autoclean -y"
    echo "[SIMULATION] sudo apt clean -y"
fi

# 10. Purge pip cache
echo "[INFO] Purging pip3 cache..."
if command -v pip3 >/dev/null 2>&1; then
    run_cmd "pip3 cache purge"
else
    echo "[INFO] pip3 not found, skipping."
fi

# 11. Extra apt/cache pass (covers /var/cache more broadly)
echo "[INFO] Extra apt clean + cache sweep..."
if ! $DRYRUN; then
    sudo apt clean
    sudo apt autoclean
    sudo apt autoremove --purge -y
    rm -rf ~/.cache/*
    sudo rm -rf /var/cache/*
else
    echo "[SIMULATION] sudo apt clean"
    echo "[SIMULATION] sudo apt autoclean"
    echo "[SIMULATION] sudo apt autoremove --purge -y"
    echo "[SIMULATION] rm -rf ~/.cache/*"
    echo "[SIMULATION] sudo rm -rf /var/cache/*"
fi

# 12. Purge packages left in "removed but config files remain" (rc) state
echo "[INFO] Purging residual-config (rc) packages..."
RC_PKGS=$(dpkg -l | awk '/^rc/{print $2}')
if [[ -n "$RC_PKGS" ]]; then
    if ! $DRYRUN; then
        sudo dpkg --purge $RC_PKGS
    else
        echo "[SIMULATION] sudo dpkg --purge $RC_PKGS"
    fi
else
    echo "[INFO] No residual-config packages found."
fi

# ---------------------------------------------------------------------------
# 13-18. Shell history & "recently used" traces
# NOTE: these steps erase YOUR OWN activity history (bash/zsh history and the
# GTK "recently used files" list), not system cache. Only run this section if
# you actually intend to clear your personal usage trail (e.g. privacy on a
# personal machine) — skip it if this is a shared/work system where activity
# logs may need to be kept for accountability reasons.
# ---------------------------------------------------------------------------
echo "[INFO] Clearing shell history and recently-used file list..."

run_cmd "rm -f ~/.zsh_history"
run_cmd "rm -f ~/.bash_history"

if ! $DRYRUN; then
    cat /dev/null > ~/.bash_history
    history -c
    history -w
else
    echo "[SIMULATION] cat /dev/null > ~/.bash_history"
    echo "[SIMULATION] history -c"
    echo "[SIMULATION] history -w"
fi

run_cmd "rm -f ~/.local/share/recently-used.xbel"
run_cmd "touch ~/.local/share/recently-used.xbel"

echo "[DONE] System cleanup completed!"
