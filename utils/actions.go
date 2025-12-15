package utils

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func ApplyKeybinds(flavour string, config Config) {
	// Handle keybinds
	qswitchDir := filepath.Join(os.Getenv("HOME"), ".config", "qswitch")
	qswitchCacheDir := filepath.Join(os.Getenv("HOME"), ".cache", "qswitch")
	os.MkdirAll(qswitchDir, 0755)
	if err := os.MkdirAll(qswitchCacheDir, 0755); err != nil {
		fmt.Printf("Error creating cache directory: %v\n", err)
		return
	}
	keybindsFile := filepath.Join(qswitchCacheDir, "qswitch.conf")

	var contentParts []string

	// Check for unbinds if enabled
	if config.Unbinds && config.Keybinds[flavour] != "default" {
		unbindsPath := filepath.Join(
			os.Getenv("HOME"),
			".config",
			"qswitch",
			"keybinds",
			"unbinds.conf",
		)
		if _, err := os.Stat(unbindsPath); err == nil {
			contentParts = append(contentParts, "source="+unbindsPath)
		} else {
			fmt.Printf("Warning: unbinds.conf not found at %s\n", unbindsPath)
		}
	}

	// Add flavour keybinds
	if config.Keybinds[flavour] == "default" {
		contentParts = append(contentParts, "# Default")
	} else {
		keybindPath := filepath.Join(os.Getenv("HOME"), ".config", "qswitch", "keybinds", config.Keybinds[flavour])
		if _, err := os.Stat(keybindPath); err == nil {
			contentParts = append(contentParts, "source="+keybindPath)
		} else {
			fmt.Printf("Warning: keybind file %s not found for flavour %s\n", config.Keybinds[flavour], flavour)
		}
	}

	// Add QuickSwitchPanel keybind
	contentParts = append(contentParts, "bind="+config.PanelKeybind+", exec, qswitch panel")

	content := strings.Join(contentParts, "\n")
	if err := os.WriteFile(keybindsFile, []byte(content), 0644); err != nil {
		fmt.Printf("Error writing keybinds file: %v\n", err)
	}
}

func ApplyFlavour(flavour string, config Config) {
	// kill old qs
	exec.Command("pkill", "-x", "qs").Run()
	exec.Command("caelestia", "shell", "-k").Run()

	// start new one
	if flavour == "dms" {
		exec.Command("dms", "run", "-d").Run()
	} else {
		exec.Command("hyprctl", "dispatch", "exec", "qs -c "+flavour).Run()
	}

	ApplyKeybinds(flavour, config)
}

// TogglePanel opens the panel if not running, closes it if running
func TogglePanel() {
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
	cmd := exec.Command("qs", "-c", "qswitch")
	cmd.Start()
	if cmd.Process != nil {
		os.WriteFile(panelPidFile, []byte(fmt.Sprintf("%d", cmd.Process.Pid)), 0644)
	}
}

func Cycle(config Config) {
	current := ReadState()

	// Find the first installed flavour for fallback
	firstInstalled := ""
	for _, f := range config.Flavours {
		if IsFlavourInstalled(f) {
			firstInstalled = f
			break
		}
	}

	if firstInstalled == "" {
		fmt.Println("No installed flavours found.")
		return
	}

	if current == "" {
		WriteState(firstInstalled)
		ApplyFlavour(firstInstalled, config)
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
		WriteState(firstInstalled)
		ApplyFlavour(firstInstalled, config)
		fmt.Println("Switched to", firstInstalled)
		return
	}

	// Find next installed flavour
	for i := 1; i <= len(config.Flavours); i++ {
		nextIdx := (currentIdx + i) % len(config.Flavours)
		next := config.Flavours[nextIdx]
		if IsFlavourInstalled(next) {
			WriteState(next)
			ApplyFlavour(next, config)
			fmt.Println("Switched to", next)
			return
		}
	}

	fmt.Println("No other installed flavours to switch to.")
}

func Setup(config Config, force bool) {
	// Check if state file exists
	if _, err := os.Stat(stateFile); err == nil && !force {
		fmt.Println("Setup already completed (state file exists).")
		return
	}

	// Create state file if it doesn't exist
	if err := os.WriteFile(stateFile, []byte(""), 0644); err != nil {
		fmt.Printf("Error creating state file: %v\n", err)
	}

	// Create cache directory
	qswitchCacheDir := filepath.Join(os.Getenv("HOME"), ".cache", "qswitch")
	if err := os.MkdirAll(qswitchCacheDir, 0755); err != nil {
		fmt.Printf("Error creating cache directory: %v\n", err)
		return
	}

	keybindsFile := filepath.Join(qswitchCacheDir, "qswitch.conf")
	content := "bind=" + config.PanelKeybind + ", exec, qswitch panel"
	if err := os.WriteFile(keybindsFile, []byte(content), 0644); err != nil {
		fmt.Printf("Error creating keybinds file: %v\n", err)
		return
	}
	hyprlandFile := filepath.Join(os.Getenv("HOME"), ".config", "hypr", "hyprland.conf")

	// Check if already sourced
	hyprContent, err := os.ReadFile(hyprlandFile)
	if err == nil {
		sourceLine := "source=" + qswitchCacheDir + "/qswitch.conf"
		if strings.Contains(string(hyprContent), sourceLine) {
			fmt.Println("Setup completed (already sourced)")
			return
		}
	}

	f, err := os.OpenFile(hyprlandFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Println("Error opening hyprland.conf:", err)
		return
	}
	defer f.Close()
	f.WriteString("\nsource=" + qswitchCacheDir + "/qswitch.conf\n")
	fmt.Println("Setup completed")
}
