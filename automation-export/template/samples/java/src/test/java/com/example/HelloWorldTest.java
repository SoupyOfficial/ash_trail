package com.example;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for HelloWorld class.
 */
class HelloWorldTest {

    private final HelloWorld helloWorld = new HelloWorld();

    @Test
    void testGreetWithName() {
        String result = helloWorld.greet("Alice");
        assertEquals("Hello, Alice!", result);
    }

    @Test
    void testGreetWithNull() {
        String result = helloWorld.greet(null);
        assertEquals("Hello, World!", result);
    }

    @Test
    void testGreetWithEmptyString() {
        String result = helloWorld.greet("");
        assertEquals("Hello, World!", result);
    }

    @Test
    void testGreetWithWhitespace() {
        String result = helloWorld.greet("   ");
        assertEquals("Hello, World!", result);
    }
}
