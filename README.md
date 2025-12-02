# qswitch

A utility for switching between QuickShell flavours in Hyprland.

## Support

**First of all, DM me on Discord `@dev_mannu` if you want to use this and don't understand how to make it work.**

## Description

`qswitch` allows you to switch between different QuickShell configurations (flavours) seamlessly. It manages the QS process, updates Hyprland keybinds, and sources flavour-specific keybind files.

**Important:** This tool works only with "end-4" dots installed first as the main dots. You must install the **"ii"** flavour as the default shell, and other shells should be installed at `/etc/xdg/quickshell`.

## Installation

### Prerequisites

- Go 1.25.4 or later
- CMake 3.15 or later
- Hyprland and QuickShell installed

### Configuration Files

You should use the configuration files provided here:
[https://github.com/MannuVilasara/commaflies/tree/main/qswitch/.config/qswitch](https://github.com/MannuVilasara/commaflies/tree/main/qswitch/.config/qswitch)

### Build and Install

1. Clone the repository:

   ```bash
   git clone https://github.com/MannuVilasara/qswitch.git
   cd qswitch
   ```

2. Build the project:

   ```bash
   mkdir build
   cd build
   cmake ..
   make
   ```

3. Install system-wide (requires root):
   ```bash
   sudo make install
   ```

This installs:

- The `qswitch` binary to `/usr/local/bin`
- Man page to `/usr/local/share/man/man1`
- Shell completions to appropriate directories
- QuickSwitchPanel.qml to `/etc/xdg/quickshell/qswitch/`

### Uninstall

To uninstall the project:

```bash
cd build
sudo make uninstall
```

## Configuration

Configuration is stored in `~/.config/qswitch/config.json`:

```json
{
  "flavours": ["ii", "caelestia", "noctalia"],
  "unbinds": true,
  "keybinds": {
    "ii": "default",
    "caelestia": "caelestia.conf",
    "noctalia": "noctalia.conf"
  }
}
```

- **flavours**: List of available flavours.
- **unbinds**: (Optional) Boolean. If true, sources `~/.config/qswitch/keybinds/unbinds.conf` before applying flavour-specific keybinds (except for "default" flavour). Useful for unbinding keys that might conflict.
- **keybinds**: Maps each flavour to a keybind file in `~/.config/qswitch/keybinds/`. Use "default" for the base configuration.

Keybind files (e.g., `caelestia.conf`) contain Hyprland keybind definitions.

The tool generates `~/.config/hypr/custom/keybinds.conf` with the appropriate source and bind commands.

## Usage

### Commands

- `qswitch`: Cycle to the next flavour
- `qswitch <flavour>`: Switch to a specific flavour
- `qswitch --help`: Show help
- `qswitch --list`: List available flavours

### Examples

```bash
# Cycle flavours
qswitch

# Switch to caelestia
qswitch caelestia

# List flavours
qswitch --list
```

### Shell Completions

Install completions for bash, zsh, or fish by sourcing the files in `completions/` or using the installed versions.

## Files

- `~/.switch_state`: Stores the current flavour
- `~/.config/qswitch/config.json`: Configuration
- `~/.config/qswitch/keybinds/`: Keybind files
- `~/.config/hypr/custom/keybinds.conf`: Generated keybinds
- `/etc/xdg/quickshell/qswitch/QuickSwitchPanel.qml`: Panel QML file
