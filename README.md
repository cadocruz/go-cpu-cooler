# CPU Cooler LCD Controller (Go) - Tested on Redragon CCW-3017
**OBS: Developed with AI assistance**


![Status](https://img.shields.io/badge/Status-Active-brightgreen)
![Language](https://img.shields.io/badge/Language-Go-blue)
![Platform](https://img.shields.io/badge/Platform-Linux-orange)

This project is a resilient Go-based controller for Water Cooler LCD displays on Linux. It monitors CPU temperature and updates the HID display in real-time. 

Originally written in Python, this **Go version** offers better stability, zero runtime dependencies (single binary), and lower resource footprint.

## ✨ Features
- **Resilient:** Handles system hibernation, USB disconnects, and kernel device resets automatically.
- **Low Footprint:** Written in Go for minimal CPU and RAM usage.
- **Smart Sensing:** Automatic detection of AMD (`k10temp`) and Intel (`coretemp`) sensors.
- **System Integration:** Fully integrated with `systemd` (user-mode) and `udev`.
- **Auto-Reconnect:** Retries connection every 2 seconds if the device is missing.

## 🚀 Installation

The easiest way to install is using the automated script:

```bash
chmod +x install.sh
./install.sh
```

### Manual Steps (Overview)
1. **Requirements:** Go 1.21+ and `libhidapi-dev`.
2. **Build:** `go build -o cpu-cooler main.go`.
3. **Permissions:** Install UDEV rule in `/etc/udev/rules.d/99-cpu-cooler.rules`.
4. **Service:** Enable the systemd user service for background execution.

## 🛠 Technical Details

- **Language:** Go (Golang)
- **HID Library:** `github.com/karalabe/hid` (CGO based)
- **Metrics Library:** `github.com/shirou/gopsutil/v4`
- **Update Frequency:** 1 second
- **Logging:** Heartbeat logged every 60 seconds to `journalctl`.

## 🔍 Monitoring

Check if the service is running and view real-time temperature updates:

```bash
# View live logs
journalctl --user -u cpu-cooler -f

# Check service status
systemctl --user status cpu-cooler
```

## 🤝 Compatibility
- **Tested Hardware:** Redragon CCW-3017, Husky Glacier.
- **VendorID:** `0x5131`
- **ProductID:** `0x2007`

---
*Developed for Linux stability and performance.*
