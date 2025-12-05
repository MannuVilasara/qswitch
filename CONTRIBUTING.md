# Contributing to qswitch

Thank you for your interest in contributing to qswitch! I am open to contributions, whether it's bug fixes, new features, or documentation improvements.

## Code Structure

The project is written in Go and uses CMake for building.

- **`cmd/qswitch/`**: Contains the source code for the main application.
  - **`main.go`**: The entry point. Handles CLI argument parsing and high-level command logic.
  - **`config.go`**: Handles loading and parsing the `config.json` file.
  - **`state.go`**: Manages the application state (current flavour) and checks for installed flavours.
  - **`actions.go`**: Contains the core logic for performing actions like switching flavours, applying keybinds, and running the setup.
- **`quickshell/`**: Contains the QML files for the QuickSwitch panel.
- **`completions/`**: Shell completion scripts.

## How it Works

`qswitch` works by managing the `qs` (QuickShell) process and Hyprland keybinds dynamically.

1. **Configuration**: It reads `~/.config/qswitch/config.json` to know about available flavours and their specific keybind mappings.
2. **State**: It tracks the currently active flavour in `~/.switch_state`.
3. **Switching**: When switching flavours:
   - It kills the current `qs` process.
   - It starts a new `qs` instance with the selected configuration (`qs -c <flavour>`).
   - It generates `~/.config/qswitch/qswitch.conf`. This file contains `source` directives to load flavour-specific keybinds into Hyprland.
   - Hyprland automatically picks up these changes because `hyprland.conf` sources `qswitch.conf`.

## Development

1. Clone the repository.
2. Make your changes in the `cmd/qswitch` directory.
3. Build the project using CMake:

   ```bash
   mkdir build
   cd build
   cmake ..
   make
   ```

4. Test your changes with the built binary.

## Pull Requests

Please ensure your code is formatted (standard Go formatting) and clearly documented. Feel free to open a PR!
