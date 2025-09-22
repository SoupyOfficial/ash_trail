const { greet } = require('../src/hello');

describe('HelloWorld', () => {
  test('should greet with name', () => {
    const result = greet('Alice');
    expect(result).toBe('Hello, Alice!');
  });

  test('should greet world when name is null', () => {
    const result = greet(null);
    expect(result).toBe('Hello, World!');
  });

  test('should greet world when name is undefined', () => {
    const result = greet(undefined);
    expect(result).toBe('Hello, World!');
  });

  test('should greet world when name is empty string', () => {
    const result = greet('');
    expect(result).toBe('Hello, World!');
  });

  test('should greet world when name is whitespace', () => {
    const result = greet('   ');
    expect(result).toBe('Hello, World!');
  });
});
