package main

import (
	"fmt"
	"os/exec"
	"regexp"
	"strings"
)

// Edit ataDisks and nvmeDisks to include the devices you
// want to have temps reported.
var ataDisks = []string{
	"ada0", "ada1", "ada2", "ada3", "ada4", "ada5",
	"ada6", "ada7", "ada8",
}

var nvmeDisks = []string{
	"nvme0",
}

var (
	atatempregex  = regexp.MustCompile(`(?i:Temperature)`)
	nvmetempregex = regexp.MustCompile(`^(?i:Temperature)`)
)

func getAtaTemp(disk string) string {
	d := fmt.Sprintf("/dev/%s", disk)
	out, err := exec.Command("/usr/local/sbin/smartctl", "-A", d).Output()
	if err != nil {
		return ""
	}
	lines := strings.Split(string(out), "\n")
	for _, line := range lines {
		if atatempregex.MatchString(line) {
			fields := strings.Fields(line)
			return fmt.Sprintf("%s %s\n", disk, fields[9])
		}
	}
	return ""
}

func getNvmeTemp(disk string) string {
	out, err := exec.Command("/sbin/nvmecontrol", "logpage", "-p", "2", disk).Output()
	if err != nil {
		return ""
	}
	lines := strings.Split(string(out), "\n")
	for _, line := range lines {
		if nvmetempregex.MatchString(line) {
			fields := strings.Fields(line)
			return fmt.Sprintf("%s %s\n", disk, strings.TrimSpace(fields[3]))
		}
	}
	return ""
}

func main() {
	for _, disk := range ataDisks {
		out := getAtaTemp(disk)
		if out != "" {
			fmt.Print(out)
		}
	}
	for _, disk := range nvmeDisks {
		out := getNvmeTemp(disk)
		if out != "" {
			fmt.Print(out)
		}
	}
}
