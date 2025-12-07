/*
Copyright © 2025 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"

	"qswitch/utils"

	"github.com/spf13/cobra"
)

// currentCmd represents the current command
var currentCmd = &cobra.Command{
	Use:   "current",
	Short: "Show current flavour",
	Long:  `Display the currently active flavour.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println(utils.ReadState())
	},
}

func init() {
	rootCmd.AddCommand(currentCmd)
}
