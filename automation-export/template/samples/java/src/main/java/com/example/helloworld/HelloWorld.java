package com.example.helloworld;

/**
 * Simple Hello World application for testing Java automation.
 */
public class HelloWorld {

    private static final String DEFAULT_NAME = "World";

    /**
     * Return a greeting message.
     *
     * @param name The name to greet (cannot be null or empty)
     * @return A greeting message string
     * @throws IllegalArgumentException if name is null or empty
     */
    public static String helloWorld(String name) {
        if (name == null) {
            throw new IllegalArgumentException("Name cannot be null");
        }
        if (name.trim().isEmpty()) {
            throw new IllegalArgumentException("Name cannot be empty");
        }

        return "Hello, " + name + "!";
    }

    /**
     * Return a greeting message with default name.
     *
     * @return A greeting message string
     */
    public static String helloWorld() {
        return helloWorld(DEFAULT_NAME);
    }

    /**
     * Main entry point.
     *
     * @param args Command line arguments (unused)
     */
    public static void main(String[] args) {
        System.out.println(helloWorld());
        System.out.println(helloWorld("Java"));
    }
}
