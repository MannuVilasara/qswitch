package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

var stateFile = os.Getenv("HOME") + "/.switch_state"

type Config struct {
	Flavours []string          `json:"flavours"`
	Keybinds map[string]string `json:"keybinds"`
}

var defaultConfig = Config{
	Flavours: []string{"ii", "caelestia", "noctalia"},
	Keybinds: map[string]string{
		"ii":        "default",
		"caelestia": "caelestia.conf",
		"noctalia":  "noctalia.conf",
	},
}

func loadConfig() Config {
	configDir := filepath.Join(os.Getenv("HOME"), ".config", "qswitch")
	configPath := filepath.Join(configDir, "config.json")

	// Create dir if not exists
	os.MkdirAll(configDir, 0755)

	// Create keybinds dir
	keybindsDir := filepath.Join(configDir, "keybinds")
	os.MkdirAll(keybindsDir, 0755)

	// Read file
	data, err := os.ReadFile(configPath)
	if err != nil {
		// Create with default
		defaultData, _ := json.MarshalIndent(defaultConfig, "", "  ")
		os.WriteFile(configPath, defaultData, 0644)
		return defaultConfig
	}

	var config Config
	json.Unmarshal(data, &config)
	if config.Keybinds == nil {
		config.Keybinds = defaultConfig.Keybinds
		// Write back updated config
		updatedData, _ := json.MarshalIndent(config, "", "  ")
		os.WriteFile(configPath, updatedData, 0644)
	}
	return config
}

func help(config Config) {
	fmt.Println(`Usage:
  switch <flavour>       Switch to a specific flavour
  switch                 Cycle to the next flavour

Available flavours:`)
	for _, f := range config.Flavours {
		fmt.Println("  " + f)
	}
	fmt.Println(`
Options:
  --help, -h             Show this help message
  --list                 List available flavours`)
}

func applyFlavour(flavour string, config Config) {
	// kill old qs
	exec.Command("pkill", "-x", "qs").Run()

	// start new one
	exec.Command("hyprctl", "dispatch", "exec", "qs -c "+flavour).Run()

	// Handle keybinds
	hyprDir := filepath.Join(os.Getenv("HOME"), ".config", "hypr", "custom")
	os.MkdirAll(hyprDir, 0755)
	keybindsFile := filepath.Join(hyprDir, "keybinds.conf")
	var content string
	if config.Keybinds[flavour] == "default" {
		content = "# Default"
	} else {
		content = "source=" + filepath.Join(os.Getenv("HOME"), ".config", "qswitch", "keybinds", config.Keybinds[flavour])
	}
	content += "\nbind=Super+Alt, P, exec, qs -p /etc/xdg/quickshell/qswitch/QuickSwitchPanel.qml"
	os.WriteFile(keybindsFile, []byte(content), 0644)
}

func readState() string {
	data, err := os.ReadFile(stateFile)
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(data))
}

func writeState(f string) { os.WriteFile(stateFile, []byte(f), 0644) }

func cycle(config Config) {
	current := readState()

	if current == "" {
		writeState(config.Flavours[0])
		applyFlavour(config.Flavours[0], config)
		fmt.Println("Switched to", config.Flavours[0])
		return
	}

	for i, f := range config.Flavours {
		if f == current {
			next := config.Flavours[(i+1)%len(config.Flavours)]
			writeState(next)
			applyFlavour(next, config)
			fmt.Println("Switched to", next)
			return
		}
	}

	// fallback
	writeState(config.Flavours[0])
	applyFlavour(config.Flavours[0], config)
	fmt.Println("Switched to", config.Flavours[0])
}

func isValidFlavour(name string, config Config) bool {
	for _, f := range config.Flavours {
		if f == name {
			return true
		}
	}
	return false
}

func main() {
	config := loadConfig()

	args := os.Args[1:]

	if len(args) == 1 && (args[0] == "--help" || args[0] == "-h") {
		help(config)
		return
	}

	if len(args) == 1 && args[0] == "--list" {
		for _, f := range config.Flavours {
			fmt.Println(f)
		}
		return
	}

	if len(args) == 1 && args[0] == "--current" {
		fmt.Println(readState())
		return
	}

	if len(args) == 2 && args[0] == "apply" && args[1] == "--current" {
		current := readState()
		if isValidFlavour(current, config) {
			applyFlavour(current, config)
			fmt.Println("Applied current flavour:", current)
		} else {
			fmt.Println("No valid current flavour set.")
		}
		return
	}

	if len(args) == 0 {
		cycle(config)
		return
	}

	flavour := args[0]
	if !isValidFlavour(flavour, config) {
		fmt.Println("Unknown flavour:", flavour)
		fmt.Println("Run 'switch --help' to list flavours.")
		return
	}

	writeState(flavour)
	applyFlavour(flavour, config)
	fmt.Println("Switched to", flavour)
}
