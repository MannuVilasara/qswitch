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
var panelPidFile = os.Getenv("HOME") + "/.qswitch_panel_pid"

type Config struct {
	Flavours []string          `json:"flavours"`
	Keybinds map[string]string `json:"keybinds"`
	Unbinds  bool              `json:"unbinds"`
}

var defaultConfig = Config{
	Flavours: []string{"ii", "caelestia", "noctalia"},
	Keybinds: map[string]string{
		"ii":        "default",
		"caelestia": "caelestia.conf",
		"noctalia":  "noctalia.conf",
	},
	Unbinds: false,
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
  qswitch <flavour>       Switch to a specific flavour
  qswitch                 Cycle to the next flavour

Available flavours:`)
	for _, f := range config.Flavours {
		fmt.Println("  " + f)
	}
	fmt.Println(`
Options:
  --help, -h             Show this help message
  --list                 List available flavours
  --current              Show current flavour
  --panel                Toggle panel
  apply --current        Apply current flavour configuration`)
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

	var contentParts []string

	// Check for unbinds if enabled
	if config.Unbinds && config.Keybinds[flavour] != "default" {
		unbindsPath := filepath.Join(os.Getenv("HOME"), ".config", "qswitch", "keybinds", "unbinds.conf")
		if _, err := os.Stat(unbindsPath); err == nil {
			contentParts = append(contentParts, "source="+unbindsPath)
		}
	}

	// Add flavour keybinds
	if config.Keybinds[flavour] == "default" {
		contentParts = append(contentParts, "# Default")
	} else {
		contentParts = append(contentParts, "source="+filepath.Join(os.Getenv("HOME"), ".config", "qswitch", "keybinds", config.Keybinds[flavour]))
	}

	// Add QuickSwitchPanel keybind
	contentParts = append(contentParts, "bind=Super+Alt, P, exec, qswitch --panel")

	content := strings.Join(contentParts, "\n")
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

// togglePanel opens the panel if not running, closes it if running
func togglePanel() {
	// Check if panel is already running by reading PID file
	pidData, err := os.ReadFile(panelPidFile)
	if err == nil {
		pid := strings.TrimSpace(string(pidData))
		// Check if process is still running
		checkCmd := exec.Command("kill", "-0", pid)
		if checkCmd.Run() == nil {
			// Process is running, kill it
			exec.Command("kill", pid).Run()
			os.Remove(panelPidFile)
			return
		}
	}

	// Panel not running, start it
	cmd := exec.Command("qs", "-p", "/etc/xdg/quickshell/qswitch/QuickSwitchPanel.qml")
	cmd.Start()
	if cmd.Process != nil {
		os.WriteFile(panelPidFile, []byte(fmt.Sprintf("%d", cmd.Process.Pid)), 0644)
	}
}

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

	if len(args) == 1 && args[0] == "--panel" {
		togglePanel()
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

	// Check if the flavour is already running
	current := readState()
	if current == flavour {
		fmt.Println("Already running:", flavour)
		return
	}

	writeState(flavour)
	applyFlavour(flavour, config)
	fmt.Println("Switched to", flavour)
}
