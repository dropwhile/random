package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"os"
	"strings"

	"golang.org/x/crypto/bcrypt"
)

func usage() {
	fmt.Fprintf(os.Stderr, "usage: %s inputfile\n", os.Args[0])
	flag.PrintDefaults()
	os.Exit(2)
}

func main() {
	flag.Usage = usage
	flag.Parse()

	args := flag.Args()
	if len(args) < 1 {
		fmt.Println("Input file is missing")
		os.Exit(1)
	}

	file, err := os.Open(args[0])
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	creds := make(map[string][]byte)
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		fields := strings.Fields(scanner.Text())
		if len(fields) == 2 {
			creds[fields[0]] = []byte(fields[1])
		}
	}
	if err := scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, "reading standard input:", err)
	}

	username := os.Getenv("username")
	password := os.Getenv("password")
	pw, ok := creds[username]
	if !ok {
		// no user found, so set passwd and hashpw to something that will
		// always fail, but will still take the same bcrypt amount of time
		password = "nope"
		// "you shall not match"
		pw = []byte(`$2b$12$RbF4tpoJnz3fg9Kdz1JX/O3AyCj7lc.dhpGRCv6oDHvw.ZqnBQPbW`)
	}
	err = bcrypt.CompareHashAndPassword(pw, []byte(password))
	if err != nil {
		os.Exit(1)
	}
	os.Exit(0)
}
