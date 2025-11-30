# qswitch

A utility for switching between QuickShell flavours in Hyprland.

## Description

`qswitch` allows you to switch between different QuickShell configurations (flavours) seamlessly. It manages the QS process, updates Hyprland keybinds, and sources flavour-specific keybind files.

**Important:** This tool works only with "end-4" dots installed first as the main dots, and other shells installed at `/etc/xdg/quickshell`. The "ii" flavour is treated as the default shell.

## Installation

### Prerequisites

- Go 1.25.4 or later
- CMake 3.15 or later
- Hyprland and QuickShell installed

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

## Configuration

Configuration is stored in `~/.config/qswitch/config.json`:

```json
{
  "flavours": ["ii", "caelestia", "noctalia"],
  "keybinds": {
    "ii": "default",
    "caelestia": "caelestia.conf",
    "noctalia": "noctalia.conf"
  }
}
```

- **flavours**: List of available flavours.
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
