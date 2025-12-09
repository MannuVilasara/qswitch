// this file checks and applies autofix for known issues
package utils

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

var qswitchCacheDir = filepath.Join(os.Getenv("HOME"), ".cache", "qswitch")
var hyprlandFile = filepath.Join(os.Getenv("HOME"), ".config", "hypr", "hyprland.conf")
var qswitchDir = filepath.Join(os.Getenv("HOME"), ".config", "qswitch")
var sourceLine = "source=" + qswitchCacheDir + "/qswitch.conf"
var wrongSourceLines = []string{
	"source=" + qswitchDir + "/qswitch.conf",
	"source=" + "~/.config/qswitch/qswitch.conf",
	"source=" + "~/.cache/qswitch/qswitch.conf",
}

func dirExists(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}

// ApplyAutofix checks for known issues and applies fixes
func ApplyAutofix() {
	fmt.Println("Checking for autofixes...")
	_, err := os.Stat(hyprlandFile)
	hyprlandExists := err == nil
	qswitchCacheExists := dirExists(qswitchCacheDir)
	qswitchConfigExists := dirExists(qswitchDir)

	// Check if Hyprland config file exists
	if !hyprlandExists {
		fmt.Println(
			"Hyprland configuration file not found. Please ensure Hyprland is installed and configured correctly.",
		)
		return
	} else {
		fmt.Println("Hyprland configuration file found.")
	}

	// Check and create QSwitch cache directory if it doesn't exist
	if !qswitchCacheExists {
		fmt.Println("QSwitch cache directory not found. Creating it now...")
		err := os.MkdirAll(qswitchCacheDir, 0755)
		if err != nil {
			fmt.Printf("Failed to create QSwitch cache directory: %v\n", err)
			return
		} else {
			fmt.Println("QSwitch cache directory created successfully.")
		}
	} else {
		fmt.Println("QSwitch cache directory exists.")
	}

	if !qswitchConfigExists {
		fmt.Println("QSwitch configuration directory not found. Creating it now...")
		err := os.MkdirAll(qswitchDir, 0755)
		if err != nil {
			fmt.Printf("Failed to create QSwitch configuration directory: %v\n", err)
		} else {
			fmt.Println("QSwitch configuration directory created successfully.")
		}
	} else {
		fmt.Println("QSwitch configuration directory exists.")
	}

	hyprcontent, err := os.ReadFile(hyprlandFile)
	if err != nil {
		fmt.Printf("Error reading Hyprland configuration file: %v\n", err)
		return
	}

	if !strings.Contains(string(hyprcontent), sourceLine) {
		fmt.Println("QSwitch configuration not found in Hyprland config. Adding it now...")
		f, err := os.OpenFile(hyprlandFile, os.O_APPEND|os.O_WRONLY, 0644)
		if err != nil {
			fmt.Printf("Error opening Hyprland configuration file for appending: %v\n", err)
			return
		}
		defer f.Close()

		_, err = f.WriteString("\n" + sourceLine + "\n")
		if err != nil {
			fmt.Printf("Error writing to Hyprland configuration file: %v\n", err)
			return
		} else {
			fmt.Println("QSwitch configuration added to Hyprland config successfully.")
		}
	} else {
		fmt.Println("QSwitch configuration already present in Hyprland config.")
	}

	updatedContent := string(hyprcontent)
	for _, wrongLine := range wrongSourceLines {
		if strings.Contains(updatedContent, wrongLine) {
			fmt.Printf(
				"Incorrect QSwitch source line found in Hyprland config: %s. Removing it now...\n",
				wrongLine,
			)
			updatedContent = strings.ReplaceAll(updatedContent, wrongLine+"\n", "")
			updatedContent = strings.ReplaceAll(updatedContent, wrongLine, "")
		}
	}
	if updatedContent != string(hyprcontent) {
		err = os.WriteFile(hyprlandFile, []byte(updatedContent), 0644)
		if err != nil {
			fmt.Printf("Error updating Hyprland configuration file: %v\n", err)
			return
		} else {
			fmt.Println("Incorrect QSwitch source lines removed from Hyprland config successfully.")
		}
	} else {
		fmt.Println("No incorrect QSwitch source lines found in Hyprland config.")
	}

	fmt.Println("Autofix process completed.")
}
