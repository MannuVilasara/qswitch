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
  apply --current        Apply current flavour configuration
  --itrustmyself         Bypass setup check (use with caution)`)
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

// checkFirstRun checks if ii is not installed and no state file exists
// Returns true if setup is needed (ii not installed and never run before)
func checkFirstRun() bool {
	// Skip check if user has already run qswitch before (state file exists)
	if _, err := os.Stat(stateFile); err == nil {
		return false
	}
	return !isFlavourInstalled("ii")
}

// showSetupMessage displays the setup requirement message
func showSetupMessage() {
	fmt.Println(`⚠️  qswitch Setup Required

	It looks like you don't have 'ii' (end-4 dots) installed as your default shell.

	This tool requires proper setup to work correctly.

	📧 Please contact @dev_mannu on Discord to get help setting it up completely.
   	Do NOT run random commands without proper guidance.

	💡 If you know what you're doing, you can bypass this check with:
   	qswitch --itrustmyself <command>

   Example: qswitch --itrustmyself caelestia`)
}

// isFlavourInstalled checks if a flavour configuration exists
// A flavour is installed if it has a directory in /etc/xdg/quickshell/<flavour>
// or ~/.config/quickshell/<flavour>
func isFlavourInstalled(flavour string) bool {
	// Check in ~/.config/quickshell/<flavour>
	userPath := filepath.Join(os.Getenv("HOME"), ".config", "quickshell", flavour)
	if _, err := os.Stat(userPath); err == nil {
		return true
	}

	// Check in /etc/xdg/quickshell/<flavour>
	systemPath := filepath.Join("/etc/xdg/quickshell", flavour)
	if _, err := os.Stat(systemPath); err == nil {
		return true
	}

	return false
}

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

	// Find the first installed flavour for fallback
	firstInstalled := ""
	for _, f := range config.Flavours {
		if isFlavourInstalled(f) {
			firstInstalled = f
			break
		}
	}

	if firstInstalled == "" {
		fmt.Println("No installed flavours found.")
		return
	}

	if current == "" {
		writeState(firstInstalled)
		applyFlavour(firstInstalled, config)
		fmt.Println("Switched to", firstInstalled)
		return
	}

	// Find current index and cycle to next installed flavour
	currentIdx := -1
	for i, f := range config.Flavours {
		if f == current {
			currentIdx = i
			break
		}
	}

	if currentIdx == -1 {
		// Current not found, use first installed
		writeState(firstInstalled)
		applyFlavour(firstInstalled, config)
		fmt.Println("Switched to", firstInstalled)
		return
	}

	// Find next installed flavour
	for i := 1; i <= len(config.Flavours); i++ {
		nextIdx := (currentIdx + i) % len(config.Flavours)
		next := config.Flavours[nextIdx]
		if isFlavourInstalled(next) {
			writeState(next)
			applyFlavour(next, config)
			fmt.Println("Switched to", next)
			return
		}
	}

	fmt.Println("No other installed flavours to switch to.")
}

func isValidFlavour(name string, config Config) bool {
	for _, f := range config.Flavours {
		if f == name {
			return true
		}
	}
	return false
}

func setup() {
	hyprDir := filepath.Join(os.Getenv("HOME"), ".config", "hypr", "custom")
	os.MkdirAll(hyprDir, 0755)
	keybindsFile := filepath.Join(hyprDir, "keybinds.conf")
	content := "bind=Super+Alt, P, exec, qswitch --panel"
	os.WriteFile(keybindsFile, []byte(content), 0644)
	hyprlandFile := filepath.Join(os.Getenv("HOME"), ".config", "hypr", "hyprland.conf")
	f, err := os.OpenFile(hyprlandFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Println("Error opening hyprland.conf:", err)
		return
	}
	defer f.Close()
	f.WriteString("\nsource=custom/keybinds.conf\n")
	fmt.Println("Setup completed")
}

func main() {
	config := loadConfig()

	args := os.Args[1:]

	// Check for --itrustmyself bypass flag
	bypassCheck := false
	if len(args) > 0 && args[0] == "--itrustmyself" {
		bypassCheck = true
		args = args[1:] // Remove the flag from args
	}

	// Check if first run without ii installed (unless bypassed or just asking for help/list)
	if !bypassCheck && len(args) > 0 {
		// Allow help and list without setup check
		if args[0] != "--help" && args[0] != "-h" && args[0] != "--list" && args[0] != "--list-status" && args[0] != "--current" {
			if checkFirstRun() {
				showSetupMessage()
				return
			}
		}
	} else if !bypassCheck && len(args) == 0 {
		// Cycling also needs setup
		if checkFirstRun() {
			showSetupMessage()
			return
		}
	}

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

	if len(args) == 1 && args[0] == "--list-status" {
		type FlavourStatus struct {
			Name      string `json:"name"`
			Installed bool   `json:"installed"`
		}
		var statuses []FlavourStatus
		for _, f := range config.Flavours {
			statuses = append(statuses, FlavourStatus{
				Name:      f,
				Installed: isFlavourInstalled(f),
			})
		}
		jsonData, _ := json.Marshal(statuses)
		fmt.Println(string(jsonData))
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

	if len(args) > 0 && args[0] == "apply"{
		if len(args) != 2 {
			fmt.Println("Invalid usage of apply. Use 'qswitch apply --current'.")
			return
		}
		if args[1] != "--current" {
			fmt.Println("Unknown option:", args[1])
			fmt.Println("Use 'qswitch apply --current' to apply the current flavour (only supported as of now).")
			return
		}
		current := readState()
		if isValidFlavour(current, config) {
			applyFlavour(current, config)
			fmt.Println("Applied current flavour:", current)
		} else {
			fmt.Println("No valid current flavour set.")
		}
		return
	}

	if len(args) == 1 && args[0] == "exp-setup" {
		setup()
		return
	}

	if len(args) == 0 {
		cycle(config)
		return
	}

	flavour := args[0]
	if !isValidFlavour(flavour, config) {
		fmt.Println("Unknown flavour:", flavour)
		fmt.Println("Run 'qswitch --help' to list flavours.")
		return
	}

	// Check if the flavour is installed
	if !isFlavourInstalled(flavour) {
		fmt.Println("Flavour not installed:", flavour)
		fmt.Println("Install it to /etc/xdg/quickshell/" + flavour + " first.")
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
