package main

import (
	"encoding/json"
	"fmt"
	"os"
)

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
  --itrustmyself         Bypass setup check (use with caution)
  --switch-keybinds      Switch only keybinds for a flavour`)
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

	if len(args) == 2 && args[0] == "--switch-keybinds" {
		flavour := args[1]
		if !isValidFlavour(flavour, config) {
			fmt.Println("Unknown flavour:", flavour)
			return
		}
		applyKeybinds(flavour, config)
		fmt.Println("Switched keybinds to", flavour)
		return
	}

	if len(args) > 0 && args[0] == "apply" {
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

