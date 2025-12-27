<div align="center">

# 🚀 Qswitch  
### A lightweight utility to switch between **QuickShell flavours** in **Hyprland**

<br/>

<p align="center">
  <img
    src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Telegram-Animated-Emojis/main/Activity/Sparkles.webp"
    width="22"
    height="22"
    alt="Sparkles"
  />
  <a href="https://github.com/MannuVilasara/qswitch">
    <img
      src="https://img.shields.io/badge/QuickShell-Flavour%20Switcher-0092CD?style=for-the-badge&logo=linux&logoColor=D9E0EE&labelColor=000000"
      alt="QuickShell Flavour Switcher"
    />
  </a>
  <img
    src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Telegram-Animated-Emojis/main/Activity/Sparkles.webp"
    width="22"
    height="22"
    alt="Sparkles"
  />
</p>

<p align="center">
  <a href="https://github.com/MannuVilasara/qswitch/stargazers">
    <img
      src="https://img.shields.io/github/stars/MannuVilasara/qswitch?style=for-the-badge&logo=github&color=E3B341&logoColor=D9E0EE&labelColor=000000"
      alt="GitHub Stars"
    />
  </a>
</p>

</div>

---

<h2><sub><img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Package.png" alt="Package" width="25" height="25" /></sub> Installation</h1>

### Prerequisites

- Go 1.25.4 or later
- CMake 3.15 or later (optional, for CMake build)
- Hyprland and QuickShell installed

### Build and Install
<details>
<summary>Option 1: CMake Build (Recommended)</summary>

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
</details>
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

<h2><sub><img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Travel%20and%20places/Rocket.png" alt="Rocket" width="25" height="25" /></sub> Features</h2>

- [X] Switch between QuickShell flavours
- [X] Manage Hyprland keybinds
- [X] Quick switch panel
- [X] Autofix configuration
- [X] Shell completions (bash, zsh, fish)
- [X] Man page

---

<h2><sub><img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Symbols/Check%20Mark%20Button.png" alt="Check Mark Button" width="25" height="25" /></sub> Usage</h2>

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

### Configuration

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

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Files

- `~/.switch_state`: Stores the current flavour
- `~/.config/qswitch/config.json`: Configuration
- `~/.config/qswitch/keybinds/`: Keybind files
- `~/.cache/qswitch/qswitch.conf`: Generated keybinds (sourced in hyprland.conf)
- `/etc/xdg/quickshell/qswitch/shell.qml`: Panel QML file

---

<a href="https://github.com/MannuVilasara/qswitch&Timeline">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=MannuVilasara/qswitch&type=Timeline&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=MannuVilasara/qswitch&type=Timeline" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=MannuVilasara/qswitch&type=Timeline" />
 </picture>
</a>

<p align="center">
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" />
</p>