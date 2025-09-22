package main

import (
	"fmt"
	"testing"
)

func TestHelloWorld(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
		wantErr  bool
		errType  error
	}{
		{
			name:     "default greeting",
			input:    "",
			expected: "Hello, World!",
			wantErr:  false,
		},
		{
			name:     "custom name",
			input:    "Go",
			expected: "Hello, Go!",
			wantErr:  false,
		},
		{
			name:     "unicode name",
			input:    "世界",
			expected: "Hello, 世界!",
			wantErr:  false,
		},
		{
			name:     "special characters",
			input:    "@user",
			expected: "Hello, @user!",
			wantErr:  false,
		},
		{
			name:    "whitespace only",
			input:   "   ",
			wantErr: true,
			errType: ErrNameEmpty,
		},
		{
			name:    "tabs only",
			input:   "\t\t",
			wantErr: true,
			errType: ErrNameEmpty,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result, err := HelloWorld(tt.input)

			if tt.wantErr {
				if err == nil {
					t.Errorf("HelloWorld() expected error but got none")
					return
				}
				if tt.errType != nil && err != tt.errType {
					t.Errorf("HelloWorld() error = %v, want %v", err, tt.errType)
				}
				return
			}

			if err != nil {
				t.Errorf("HelloWorld() unexpected error = %v", err)
				return
			}

			if result != tt.expected {
				t.Errorf("HelloWorld() = %v, want %v", result, tt.expected)
			}
		})
	}
}

func TestMustHelloWorld(t *testing.T) {
	t.Run("successful call", func(t *testing.T) {
		result := MustHelloWorld("Go")
		expected := "Hello, Go!"

		if result != expected {
			t.Errorf("MustHelloWorld() = %v, want %v", result, expected)
		}
	})

	t.Run("panic on error", func(t *testing.T) {
		defer func() {
			if r := recover(); r == nil {
				t.Errorf("MustHelloWorld() expected panic but got none")
			}
		}()

		MustHelloWorld("   ") // This should panic
	})
}

// Benchmark tests
func BenchmarkHelloWorld(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_, _ = HelloWorld("Benchmark")
	}
}

func BenchmarkMustHelloWorld(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_ = MustHelloWorld("Benchmark")
	}
}

// Example tests (will appear in godoc)
func ExampleHelloWorld() {
	greeting, err := HelloWorld("Go")
	if err != nil {
		panic(err)
	}
	fmt.Println(greeting)
	// Output: Hello, Go!
}

func ExampleHelloWorld_default() {
	greeting, err := HelloWorld("")
	if err != nil {
		panic(err)
	}
	fmt.Println(greeting)
	// Output: Hello, World!
}

func ExampleMustHelloWorld() {
	greeting := MustHelloWorld("Go")
	fmt.Println(greeting)
	// Output: Hello, Go!
}
