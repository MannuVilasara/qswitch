/*
Copyright © 2025 Manpreet Singh <mannuvilasara@gmail.com>
*/
package cmd

import (
	"fmt"

	"qswitch/utils"

	"github.com/spf13/cobra"
)

// applyCmd represents the apply command
var applyCmd = &cobra.Command{
	Use:   "apply [flavour]",
	Short: "Switch to or apply a flavour",
	Long:  `Switch to a specific flavour or apply the current flavour's configuration.`,
	Run: func(cmd *cobra.Command, args []string) {
		config := utils.LoadConfig()
		currentFlag, _ := cmd.Flags().GetBool("current")
		if currentFlag {
			currentFlavour := utils.ReadState()
			if utils.IsValidFlavour(currentFlavour, config) {
				utils.ApplyFlavour(currentFlavour, config)
				fmt.Println("Applied current flavour:", currentFlavour)
			} else {
				fmt.Println("No valid current flavour set.")
			}
			return
		}
		if len(args) != 1 {
			fmt.Println("Invalid usage. Use 'qswitch apply <flavour>' or 'qswitch apply --current'.")
			return
		}
		flavour := args[0]
		if !utils.IsValidFlavour(flavour, config) {
			fmt.Println("Unknown flavour:", flavour)
			fmt.Println("Run 'qswitch --help' to list flavours.")
			return
		}
		// Check if the flavour is installed
		if !utils.IsFlavourInstalled(flavour) {
			fmt.Println("Flavour not installed:", flavour)
			fmt.Println("Install it to /etc/xdg/quickshell/" + flavour + " first.")
			return
		}
		// Check if the flavour is already running
		current := utils.ReadState()
		if current == flavour {
			fmt.Println("Already running:", flavour)
			return
		}
		utils.WriteState(flavour)
		utils.ApplyFlavour(flavour, config)
		fmt.Println("Switched to", flavour)
	},
}

func init() {
	rootCmd.AddCommand(applyCmd)
	applyCmd.Flags().Bool("current", false, "Apply the current flavour")
}
