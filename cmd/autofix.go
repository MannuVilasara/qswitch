/*
Copyright © 2025 Manpreet Singh <mannuvilasara@gmail.com>
*/
package cmd

import (
	"qswitch/utils"

	"github.com/spf13/cobra"
)

// autofixCmd represents the autofix command
var autofixCmd = &cobra.Command{
	Use:   "autofix",
	Short: "Autofix known issues",
	Long: `This command attempts to automatically fix known issues 
that may arise during the usage of the application.`,
	Run: func(cmd *cobra.Command, args []string) {
		utils.ApplyAutofix()
	},
}

func init() {
	rootCmd.AddCommand(autofixCmd)
}
