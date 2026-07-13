# 🧹 Clean Linux System

> **Cleaner tools for Linux Debian**

Automate your system maintenance with a single script — remove clutter, free up disk space, and keep your Debian-based system lean and healthy.

---

## ✨ Features

- 🗂️ **Clean apt cache** — Remove cached package files no longer needed
- 🗃️ **Remove old config files** — Delete leftover config files from uninstalled packages
- 🪨 **Remove old kernels** — Keep only your current kernel, drop the rest
- 🗑️ **Empty every trash** — Wipe all user and system trash folders

---

## 🚀 Getting Started

### Installation

```bash
$ git clone https://github.com/spyschools/clean-linux-system.git
$ cd clean-linux-system
$ sudo chmod +x *
```

### Usage

**Safe mode** *(no deletion — preview what will be cleaned)*
```bash
$ sudo ./clean_system.sh --dry-run
```

**Real cleanup** *(performs all cleaning actions)*
```bash
$ sudo ./clean_system.sh
```

> ⚠️ **Always run `--dry-run` first** to review what will be removed before committing to a real cleanup.

---

## 🔗 Related Tools

| Tool | Description |
|------|-------------|
| 🧰 [clean-linux-system-root](https://github.com/spyschools/clean-linux-system-root) | Tools for the **root** system |

---

## 📋 Requirements

- Debian-based Linux distribution (Debian, Ubuntu, Mint, etc.)
- `sudo` / root privileges

---

## 📄 License

This project is open source. See the [LICENSE](LICENSE) file for details.

---

<p align="center">Made with ❤️ for a cleaner Linux experience</p>
