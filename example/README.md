# Example Configuration

This directory contains an example configuration that I use in my personal setup. It demonstrates how to structure your `config.json` and keybind files.

## Structure

- `config.json`: The main configuration file defining available flavours and their keybind mappings.
- `keybinds/`: Directory containing flavour-specific keybind files.
  - `unbinds.conf`: Keybinds to unbind before applying new ones (if `unbinds: true` is set).
  - `caelestia.conf`: Keybinds for the "caelestia" flavour.
  - `noctalia.conf`: Keybinds for the "noctalia" flavour.

## Usage

You can copy these files to your `~/.config/qswitch/` directory to get started.

```bash
mkdir -p ~/.config/qswitch
cp -r . ~/.config/qswitch/
```

Make sure to adjust the `flavours` list in `config.json` to match the QuickShell themes you have installed.
