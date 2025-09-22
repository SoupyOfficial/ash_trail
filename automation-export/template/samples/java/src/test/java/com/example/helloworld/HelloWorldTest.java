package com.example.helloworld;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests for HelloWorld class.
 */
class HelloWorldTest {

    @Test
    @DisplayName("Should return default greeting")
    void testHelloWorldDefault() {
        String result = HelloWorld.helloWorld();
        assertEquals("Hello, World!", result);
    }

    @Test
    @DisplayName("Should return custom name greeting")
    void testHelloWorldCustomName() {
        String result = HelloWorld.helloWorld("Java");
        assertEquals("Hello, Java!", result);
    }

    @Test
    @DisplayName("Should throw exception for null name")
    void testHelloWorldNullName() {
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class,
            () -> HelloWorld.helloWorld(null)
        );
        assertEquals("Name cannot be null", exception.getMessage());
    }

    @Test
    @DisplayName("Should throw exception for empty name")
    void testHelloWorldEmptyName() {
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class,
            () -> HelloWorld.helloWorld("")
        );
        assertEquals("Name cannot be empty", exception.getMessage());
    }

    @Test
    @DisplayName("Should throw exception for whitespace-only name")
    void testHelloWorldWhitespaceOnlyName() {
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class,
            () -> HelloWorld.helloWorld("   ")
        );
        assertEquals("Name cannot be empty", exception.getMessage());
    }

    @Nested
    @DisplayName("Integration Tests")
    class IntegrationTests {

        @Test
        @DisplayName("Should handle multiple greetings")
        void testMultipleGreetings() {
            String[] names = {"Alice", "Bob", "Charlie"};
            String[] expected = {"Hello, Alice!", "Hello, Bob!", "Hello, Charlie!"};

            for (int i = 0; i < names.length; i++) {
                String result = HelloWorld.helloWorld(names[i]);
                assertEquals(expected[i], result);
            }
        }

        @Test
        @DisplayName("Should handle unicode names")
        void testUnicodeNames() {
            String result1 = HelloWorld.helloWorld("世界");
            assertEquals("Hello, 世界!", result1);

            String result2 = HelloWorld.helloWorld("José");
            assertEquals("Hello, José!", result2);
        }
    }
}
