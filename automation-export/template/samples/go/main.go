package main

import (
	"errors"
	"fmt"
	"strings"
)

var (
	// ErrNameEmpty is returned when the name is empty or whitespace-only
	ErrNameEmpty = errors.New("name cannot be empty")
	// ErrNameInvalid is returned when the name is not a string or is nil
	ErrNameInvalid = errors.New("name must be a valid string")
)

// HelloWorld returns a greeting message for the given name.
// If name is empty, it returns an error.
// If name is not provided or empty string, it defaults to "World".
func HelloWorld(name string) (string, error) {
	// Handle empty/whitespace-only names
	if strings.TrimSpace(name) == "" && name != "" {
		return "", ErrNameEmpty
	}

	// Default to "World" if empty string is provided
	if name == "" {
		name = "World"
	}

	return fmt.Sprintf("Hello, %s!", name), nil
}

// MustHelloWorld is like HelloWorld but panics on error.
// This is useful for cases where you're certain the input is valid.
func MustHelloWorld(name string) string {
	result, err := HelloWorld(name)
	if err != nil {
		panic(fmt.Sprintf("MustHelloWorld failed: %v", err))
	}
	return result
}

func main() {
	// Example usage
	greeting1, err := HelloWorld("")
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}
	fmt.Println(greeting1)

	greeting2, err := HelloWorld("Go")
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}
	fmt.Println(greeting2)
}
