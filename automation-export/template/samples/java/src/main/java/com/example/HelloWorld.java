package com.example;

/**
 * Simple Hello World application for testing automation template.
 */
public class HelloWorld {

    /**
     * Returns a greeting message.
     *
     * @param name the name to greet
     * @return greeting message
     */
    public String greet(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "Hello, World!";
        }
        return "Hello, " + name + "!";
    }

    /**
     * Main method to run the application.
     *
     * @param args command line arguments
     */
    public static void main(String[] args) {
        HelloWorld app = new HelloWorld();

        if (args.length > 0) {
            System.out.println(app.greet(args[0]));
        } else {
            System.out.println(app.greet(null));
        }
    }
}
