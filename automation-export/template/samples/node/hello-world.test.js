/**
 * Tests for hello-world module.
 */

const { helloWorld } = require('./hello-world');

describe('helloWorld', () => {
  test('should return default greeting', () => {
    const result = helloWorld();
    expect(result).toBe('Hello, World!');
  });

  test('should return custom name greeting', () => {
    const result = helloWorld('Node.js');
    expect(result).toBe('Hello, Node.js!');
  });

  test('should throw TypeError for non-string name', () => {
    expect(() => helloWorld(123)).toThrow(TypeError);
    expect(() => helloWorld(123)).toThrow('Name must be a string');

    expect(() => helloWorld(null)).toThrow(TypeError);
    expect(() => helloWorld(undefined)).toThrow(TypeError);
  });

  test('should throw Error for empty name', () => {
    expect(() => helloWorld('')).toThrow(Error);
    expect(() => helloWorld('')).toThrow('Name cannot be empty');

    expect(() => helloWorld('   ')).toThrow(Error);
    expect(() => helloWorld('   ')).toThrow('Name cannot be empty');
  });

  describe('Integration Tests', () => {
    test('should handle multiple greetings', () => {
      const names = ['Alice', 'Bob', 'Charlie'];
      const results = names.map(name => helloWorld(name));
      const expected = ['Hello, Alice!', 'Hello, Bob!', 'Hello, Charlie!'];

      expect(results).toEqual(expected);
    });

    test('should handle unicode names', () => {
      const result1 = helloWorld('世界');
      expect(result1).toBe('Hello, 世界!');

      const result2 = helloWorld('José');
      expect(result2).toBe('Hello, José!');
    });

    test('should handle special characters', () => {
      const specialNames = ['@user', '#hashtag', '$money', '%percent'];

      specialNames.forEach(name => {
        const result = helloWorld(name);
        expect(result).toBe(`Hello, ${name}!`);
        expect(result).toMatch(/^Hello, .+!$/);
      });
    });
  });
});
