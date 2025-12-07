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

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// autofixCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// autofixCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
