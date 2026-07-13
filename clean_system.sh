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
    sudo apt autoremove --purge -y
    sudo apt autoclean -y
    sudo apt clean -y
else
    echo "[SIMULATION] sudo apt autoremove --purge -y"
    echo "[SIMULATION] sudo apt autoclean -y"
    echo "[SIMULATION] sudo apt clean -y"
fi

# 10. Purge pip cache (cross-distro, tidak hanya Debian/Ubuntu based)
echo "[INFO] Membersihkan cache pip3..."
run_cmd "pip3 cache purge"

# 11. Purge paket dengan status 'rc' (residual config - sudah dihapus tapi config-nya masih tersisa)
echo "[INFO] Menghapus sisa config paket yang sudah di-remove (status rc)..."
RC_PKGS=$(dpkg -l | awk '/^rc/{print $2}')
if [[ -n "$RC_PKGS" ]]; then
    run_cmd "sudo dpkg --purge $RC_PKGS"
else
    echo "[INFO] Tidak ada paket dengan status 'rc'."
fi

# 12. Bersihkan sisa cache tambahan di /var/cache (selain apt, misal cache aplikasi lain)
echo "[INFO] Membersihkan /var/cache tambahan..."
run_cmd "sudo find /var/cache -mindepth 1 -maxdepth 1 ! -name apt -exec rm -rf {} +"

echo "[DONE] Package & cache cleanup completed!"

# =====================================================================
# BAGIAN TAMBAHAN: PEMBERSIHAN RIWAYAT AKTIVITAS (BUKAN PEMBERSIHAN DISK)
# Catatan: perintah di bawah ini TIDAK signifikan membebaskan ruang disk.
# Fungsinya menghapus riwayat command shell & daftar file yang baru dibuka.
# Gunakan hanya jika memang Anda ingin menghapus jejak aktivitas pribadi
# di mesin ini (mis. sebelum menjual laptop / pakai komputer bersama).
# =====================================================================
echo "[INFO] Membersihkan riwayat shell dan recently-used files..."

# 13. Hapus riwayat zsh (jika ada)
run_cmd "rm -f ~/.zsh_history"

# 14. Kosongkan & hapus riwayat bash (digabung, karena redundant jika dipisah)
if $DRYRUN; then
    echo "[SIMULATION] cat /dev/null > ~/.bash_history"
    echo "[SIMULATION] history -c"
else
    cat /dev/null > ~/.bash_history
    history -c
    history -w
fi

# 15. Reset daftar 'recently used files' (TANPA sudo — file ini milik user,
#     kalau dibuat pakai sudo maka ownership jadi root dan bisa error permission nantinya)
run_cmd "rm -f ~/.local/share/recently-used.xbel"
run_cmd "touch ~/.local/share/recently-used.xbel"

echo "[DONE] System cleanup completed!"
