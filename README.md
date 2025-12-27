<div align="center">

<h1 align="center">Qswitch</h1>

<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Lexend+Giga&size=30&pause=1200&color=B4BEFE&center=true&vCenter=true&width=900&lines=Switch+between+multiple+QuickShell+configs;QuickShell+flavours%2C+made+easy" />
</p>

<p align="center">
  <a href="https://github.com/MannuVilasara/qswitch/stargazers">
    <img src="https://img.shields.io/github/stars/MannuVilasara/qswitch?style=for-the-badge&logo=github&color=CBA6F7&logoColor=D9E0EE&labelColor=1E1E2E" alt="GitHub Stars" />
  </a>
  <a href="https://github.com/MannuVilasara/qswitch/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/MannuVilasara/qswitch?style=for-the-badge&logo=gnu&color=CBA6F7&logoColor=D9E0EE&labelColor=1E1E2E" alt="License" />
  </a>
</p>

</div>

---

<h2>
  <img src="https://github.com/microsoft/fluentui-emoji/blob/main/assets/Film%20projector/3D/film_projector_3d.png?raw=true"
       width="50"
       height="50"
       style="vertical-align: middle;" />
  Showcase Video
</h2>

https://github.com/user-attachments/assets/04aad5cf-09d5-4e38-acca-23ad67d91969

## 📋 Table of Contents

- [Features](#----features)
- [Installation](#-installation)
- [Usage](#-usage)
- [Configuration](#️-configuration)
- [Shell Completions](#️-shell-completions)
- [Uninstall](#️-uninstall)
- [Contributing](#-contributing)
- [Files](#-files)

---

<h2>
  <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Telegram-Animated-Emojis/main/Activity/Sparkles.webp" width="25" height="25" style="vertical-align: middle;" />
  Features
</h2>

- **Seamless Flavour Switching**: Easily switch between different QuickShell configurations
- **Keybind Management**: Automatic keybind switching with conflict resolution
- **Interactive Panel**: Toggle a quick switch panel for visual selection
- **Autofix**: Automatically detects and fixes common configuration issues
- **Shell Completions**: Supports bash, zsh, and fish completions
- **Lightweight**: Minimal dependencies, fast and efficient

---

<h2>
  <img src="https://github.com/microsoft/fluentui-emoji/blob/main/assets/Package/3D/package_3d.png?raw=true" width="25" height="25" style="vertical-align: middle;" />
  Installation
</h2>

### Prerequisites

- Go 1.25.4 or later
- CMake 3.15 or later (optional, for CMake build)
- Hyprland and QuickShell installed

### Quick Setup (Recommended)

1. **Clone the repository**:

   ```bash
   git clone https://github.com/MannuVilasara/qswitch.git
   cd qswitch
   ```

2. **Make setup script executable and run**:

   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

This will build and install qswitch using CMake, and run the initial setup.

### Manual Installation

<details>
<summary>Click to expand manual installation options</summary>

#### CMake Build

1. **Clone the repository**:

   ```bash
   git clone https://github.com/MannuVilasara/qswitch.git
   cd qswitch
   ```

2. **Build the project**:

   ```bash
   mkdir build
   cd build
   cmake ..
   make
   ```

3. **Install system-wide** (requires root):

   ```bash
   sudo make install
   ```

   This installs:
   - The `qswitch` binary to `/usr/local/bin`
   - Man page to `/usr/local/share/man/man1`
   - Shell completions to appropriate directories
   - `shell.qml` to `/etc/xdg/quickshell/qswitch/`

#### Go Build

1. **Clone the repository**:

   ```bash
   git clone https://github.com/MannuVilasara/qswitch.git
   cd qswitch
   ```

2. **Build and install**:

   ```bash
   go build -o qswitch .
   sudo cp qswitch /usr/local/bin/
   sudo cp man/qswitch.1 /usr/local/share/man/man1/
   sudo cp completions/qswitch.bash /usr/share/bash-completion/completions/qswitch
   sudo cp completions/qswitch.zsh /usr/share/zsh/site-functions/_qswitch
   sudo cp completions/qswitch.fish /usr/share/fish/vendor_completions.d/qswitch.fish
   sudo mkdir -p /etc/xdg/quickshell/qswitch
   sudo cp -r quickshell/* /etc/xdg/quickshell/qswitch
   ```

</details>

### Initial Setup

When you first run `qswitch`, it will check for setup and run autofix if needed:

```bash
qswitch exp-setup
```

This will:

1. Create necessary directories (`~/.config/qswitch`, `~/.cache/qswitch`)
2. Create the state file `~/.switch_state`
3. Generate a default `~/.config/qswitch/config.json`
4. Append `source=~/.cache/qswitch/qswitch.conf` to your `~/.config/hypr/hyprland.conf` (if not already present)
5. Remove any incorrect source lines (e.g., from old cache paths)

You can force the setup (even if files exist) with:

```bash
qswitch exp-setup --force
```

The autofix feature automatically detects and fixes common configuration issues.

---

<h2>
  <img src="https://github.com/Tarikul-Islam-Anik/Telegram-Animated-Emojis/blob/main/Objects/Open%20Book.webp?raw=true" width="25" height="25" style="vertical-align: middle;" />
  Usage
</h2>

### Command Examples

| Command                             | Description                                        |
| ----------------------------------- | -------------------------------------------------- |
| `qswitch`                           | Cycle to the next flavour (runs autofix if needed) |
| `qswitch apply <flavour>`           | Switch to a specific flavour                       |
| `qswitch apply --current`           | Re-apply current flavour                           |
| `qswitch list`                      | List all available flavours                        |
| `qswitch current`                   | Show current active flavour                        |
| `qswitch panel`                     | Toggle the quick switch panel                      |
| `qswitch reload`                    | Reload keybinds                                    |
| `qswitch switch-keybinds <flavour>` | Switch only the keybinds for a specific flavour    |
| `qswitch exp-setup`                 | Run the initial setup                              |
| `qswitch --help`                    | Show help information                              |

### Example Usage

```bash
# Switch to the 'caelestia' flavour
qswitch apply caelestia

# List all flavours
qswitch list
# Output: ii, caelestia, noctalia-shell, dms

# Check current flavour
qswitch current
# Output: caelestia
```

---

<h2>
  <img src="https://github.com/microsoft/fluentui-emoji/blob/main/assets/Gear/3D/gear_3d.png?raw=true" width="25" height="25" style="vertical-align: middle;" />
  Configuration
</h2>
Configuration is stored in `~/.config/qswitch/config.json`. Here's an example:

```json
{
  "flavours": ["ii", "caelestia", "noctalia-shell", "dms"],
  "unbinds": true,
  "keybinds": {
    "ii": "default",
    "caelestia": "caelestia.conf",
    "noctalia-shell": "noctalia.conf",
    "dms": "dms.conf"
  },
  "panel_keybind": "Super+Alt, P"
}
```

### Configuration Options

- **`flavours`**: Array of available QuickShell flavours
- **`unbinds`** _(Optional)_: Boolean. If `true`, sources `~/.config/qswitch/keybinds/unbinds.conf` before applying flavour-specific keybinds (except for "default" flavour). Useful for unbinding conflicting keys
- **`keybinds`**: Object mapping each flavour to a keybind file in `~/.config/qswitch/keybinds/`. Use `"default"` for the base configuration
- **`panel_keybind`** _(Optional)_: The keybind to open the QuickSwitch panel. Defaults to `"Super+Alt, P"`

Keybind files (e.g., `caelestia.conf`) contain Hyprland keybind definitions.

The tool generates `~/.cache/qswitch/qswitch.conf` with the appropriate `source` and `bind` commands, which is then sourced in `~/.config/hypr/hyprland.conf`.

---

<h2>
  <img src="https://github.com/microsoft/fluentui-emoji/blob/main/assets/Gear/3D/gear_3d.png?raw=true" width="25" height="25" style="vertical-align: middle;" />
  Shell Completions
</h2>

Qswitch supports shell completions for bash, zsh, and fish. The setup script installs them automatically, or you can install them manually:

- **Bash**: Source `completions/qswitch.bash` or copy to `/usr/share/bash-completion/completions/`
- **Zsh**: Source `completions/qswitch.zsh` or copy to `/usr/share/zsh/site-functions/`
- **Fish**: Source `completions/qswitch.fish` or copy to `/usr/share/fish/vendor_completions.d/`

---

<h2>
  <img src="https://github.com/microsoft/fluentui-emoji/blob/main/assets/Wastebasket/3D/wastebasket_3d.png?raw=true" width="25" height="25" style="vertical-align: middle;" />
  Uninstall
</h2>

### CMake Uninstall

If installed via CMake:

```bash
cd build
sudo make uninstall
```

This will remove the binary, man page, completions, and QML files.

### Manual Uninstall

Remove the following files manually:

- `/usr/local/bin/qswitch`
- `/usr/local/share/man/man1/qswitch.1`
- Shell completion files in their respective directories
- `/etc/xdg/quickshell/qswitch/`

Also remove user configuration:

- `~/.config/qswitch/`
- `~/.cache/qswitch/`
- `~/.switch_state`

---

<h2>
  <img src="https://github.com/Tarikul-Islam-Anik/Telegram-Animated-Emojis/blob/main/People/Handshake.webp?raw=true" width="25" height="25" style="vertical-align: middle;" />
  Contribution
</h2>

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

<h2>
  <img src="https://github.com/Tarikul-Islam-Anik/Telegram-Animated-Emojis/blob/main/Objects/File%20Folder.webp?raw=true" width="25" height="25" style="vertical-align: middle;" />
  Files
</h2>

| File/Directory                          | Description                                             |
| --------------------------------------- | ------------------------------------------------------- |
| `~/.switch_state`                       | Stores the current active flavour                       |
| `~/.config/qswitch/config.json`         | Main configuration file                                 |
| `~/.config/qswitch/keybinds/`           | Directory containing keybind configuration files        |
| `~/.cache/qswitch/qswitch.conf`         | Generated configuration file (sourced in hyprland.conf) |
| `/etc/xdg/quickshell/qswitch/shell.qml` | Panel QML file for the QuickSwitch interface            |

---

<h2>
  <img src="https://github.com/Tarikul-Islam-Anik/Telegram-Animated-Emojis/blob/main/Symbols/Speech%20Balloon.webp?raw=true" width="25" height="25" style="vertical-align: middle;" />
  Support
</h2>

<!-- Discord Icon -->
<div align="center">
  <a href="https://discord.com/users/786926252811485186" target="_blank">
    <img src="https://raw.githubusercontent.com/CLorant/readme-social-icons/refs/heads/main/large/colored/discord.svg" width="75" height="75" alt="Discord" />
  </a>
</div>

<br/>

<!-- Star History Timeline -->
<div align="center">
  <a href="https://star-history.com/#MannuVilasara/qswitch" target="_blank">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=MannuVilasara/qswitch&type=Timeline&theme=dark" />
      <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=MannuVilasara/qswitch&type=Timeline" />
      <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=MannuVilasara/qswitch&type=Timeline" />
    </picture>
  </a>
</div>

<br/>

<!-- Footer -->
<div align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" />
</div>
