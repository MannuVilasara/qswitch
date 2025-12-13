# qswitch

A utility for switching between QuickShell flavours in Hyprland.

## Support

**First of all, DM me on Discord `@dev_mannu` if you want to use this and don't understand how to make it work.**

> NOTE: So far I only suggest using them with ii, caelestia & noctalia. it might not work with all.
> if you're using it after 13th of December 2025, dms is now supported as well. but it might not be stable.
> This code written here is fucking weird and I won't even suggest anyone writing it like I did. but if it works, it works.
> I'll refactor it after my exams probably

## Description

`qswitch` allows you to switch between different QuickShell configurations (flavours) seamlessly. It manages the QS process, updates Hyprland keybinds, and sources flavour-specific keybind files.

It is designed to be flexible and work with any QuickShell configuration installed in standard locations.
**Important:** Ensure your shells are installed at `/etc/xdg/quickshell` or `~/.config/quickshell`. (except dms)

## Installation

### Prerequisites

- Go 1.25.4 or later
- CMake 3.15 or later (optional, for CMake build)
- Hyprland and QuickShell installed

### Configuration Files

You can find an example configuration in the `example/` directory of this repository.
Also, you can check my personal configuration here:
[https://github.com/MannuVilasara/commaflies/tree/main/qswitch/.config/qswitch](https://github.com/MannuVilasara/commaflies/tree/main/qswitch/.config/qswitch)

### Build and Install

#### Option 1: CMake Build (Recommended)

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
- shell.qml to `/etc/xdg/quickshell/qswitch/`

#### Option 2: Go Build

1. Clone the repository:

   ```bash
   git clone https://github.com/MannuVilasara/qswitch.git
   cd qswitch
   ```

2. Build and install:

   ```bash
   go build -o qswitch .
   sudo cp qswitch /usr/local/bin/
   sudo cp man/qswitch.1 /usr/local/share/man/man1/
   sudo cp completions/qswitch.bash /usr/share/bash-completion/completions/qswitch
   sudo cp completions/qswitch.zsh /usr/share/zsh/site-functions/_qswitch
   sudo cp completions/qswitch.fish /usr/share/fish/vendor_completions.d/qswitch.fish
   sudo mkdir -p /etc/xdg/quickshell/qswitch
   sudo cp  -r quickshell/* /etc/xdg/quickshell/qswitch
   ```

### Uninstall (CMake)

To uninstall the project:

```bash
cd build
sudo make uninstall
```

## Configuration

Configuration is stored in `~/.config/qswitch/config.json`:

```json
{
  "flavours": ["ii", "caelestia", "noctalia-shell"],
  "unbinds": true,
  "keybinds": {
    "ii": "default",
    "caelestia": "caelestia.conf",
    "noctalia-shell": "noctalia.conf"
  },
  "panel_keybind": "Super+Alt, P"
}
```

- **flavours**: List of available flavours.
- **unbinds**: (Optional) Boolean. If true, sources `~/.config/qswitch/keybinds/unbinds.conf` before applying flavour-specific keybinds (except for "default" flavour). Useful for unbinding keys that might conflict.
- **keybinds**: Maps each flavour to a keybind file in `~/.config/qswitch/keybinds/`. Use "default" for the base configuration.
- **panel_keybind**: (Optional) The keybind to open the QuickSwitch panel. Defaults to "Super+Alt, P".

Keybind files (e.g., `caelestia.conf`) contain Hyprland keybind definitions.

The tool generates `~/.cache/qswitch/qswitch.conf` with the appropriate source and bind commands, and sources it in `~/.config/hypr/hyprland.conf`.

## Usage

### Commands

- `qswitch`: Cycle to the next flavour (runs autofix if needed)
- `qswitch apply <flavour>`: Switch to a specific flavour
- `qswitch apply --current`: Re-apply current flavour configuration
- `qswitch list`: List available flavours (use `--status` for JSON output)
- `qswitch current`: Show current flavour
- `qswitch panel`: Toggle the quick switch panel
- `qswitch reload`: Reload keybinds
- `qswitch switch-keybinds <flavour>`: Switch only the keybinds for a specific flavour
- `qswitch exp-setup`: Run the initial setup (creates directories, state file, and updates hyprland.conf with autofix)
- `qswitch --help`: Show help

### Setup

When you first run `qswitch`, it will check for setup and run autofix if needed.

```bash
qswitch exp-setup
```

This will:

1. Create necessary directories (`~/.config/qswitch`, `~/.cache/qswitch`)
2. Create the state file `~/.switch_state`
3. Generate a default `~/.config/qswitch/qswitch.conf`
4. Append `source=~/.cache/qswitch/qswitch.conf` to your `~/.config/hypr/hyprland.conf` (if not already present)
5. Remove any incorrect source lines (e.g., from old cache paths)

You can force the setup (even if files exist) with:

```bash
qswitch exp-setup --force
```

The autofix feature automatically detects and fixes common configuration issues.

### Examples

```bash
# Cycle flavours
qswitch

# Switch to caelestia
qswitch apply caelestia

# Re-apply current flavour
qswitch apply --current

# List flavours
qswitch list

# Show current flavour
qswitch current

# Toggle panel
qswitch panel

# Reload keybinds
qswitch reload
```

### Shell Completions

Install completions for bash, zsh, or fish by sourcing the files in `completions/` or using the installed versions.

## Files

- `~/.switch_state`: Stores the current flavour
- `~/.config/qswitch/config.json`: Configuration
- `~/.config/qswitch/keybinds/`: Keybind files
- `~/.cache/qswitch/qswitch.conf`: Generated keybinds (sourced in hyprland.conf)
- `/etc/xdg/quickshell/qswitch/shell.qml`: Panel QML file
