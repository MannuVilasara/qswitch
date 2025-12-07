/*
Copyright © 2025 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"
	"os"

	"qswitch/utils"

	"github.com/spf13/cobra"
)

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "qswitch",
	Short: "Switch between Quickshell flavours",
	Long: `qswitch is a CLI tool to switch between different Quickshell configurations (flavours).

Usage:
  qswitch                 Cycle to the next flavour
  qswitch apply <flavour> Switch to a specific flavour
  qswitch [command]       Run a specific command`,
	PersistentPreRun: func(cmd *cobra.Command, args []string) {
		bypass, _ := cmd.Flags().GetBool("itrustmyself")
		if !bypass {
			// Allow certain commands without setup
			switch cmd.Name() {
			case "help", "list", "current", "exp-setup":
				return
			}
			if utils.CheckFirstRun() {
				utils.ShowSetupMessage()
				os.Exit(0)
			}
		}
	},
	Run: func(cmd *cobra.Command, args []string) {
		if len(args) == 0 {
			config := utils.LoadConfig()
			utils.Cycle(config)
		} else {
			fmt.Println("Invalid usage. Use 'qswitch' to cycle or 'qswitch apply <flavour>' to switch.")
		}
	},
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func init() {
	// Here you will define your flags and configuration settings.
	// Cobra supports persistent flags, which, if defined here,
	// will be global for your application.

	rootCmd.PersistentFlags().Bool("itrustmyself", false, "Bypass setup check")

	// Cobra also supports local flags, which will only run
	// when this action is called directly.
	rootCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}


