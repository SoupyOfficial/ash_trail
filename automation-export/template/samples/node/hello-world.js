/**
 * Simple Hello World application for testing Node.js automation.
 */

/**
 * Return a greeting message.
 *
 * @param {string} [name='World'] - The name to greet
 * @returns {string} A greeting message string
 * @throws {TypeError} When name is not a string
 * @throws {Error} When name is empty
 */
function helloWorld(name = 'World') {
  if (typeof name !== 'string') {
    throw new TypeError('Name must be a string');
  }

  if (name.trim() === '') {
    throw new Error('Name cannot be empty');
  }

  return `Hello, ${name}!`;
}

/**
 * Main entry point.
 */
function main() {
  console.log(helloWorld());
  console.log(helloWorld('Node.js'));
}

// Run main if this module is executed directly
if (require.main === module) {
  main();
}

module.exports = { helloWorld, main };
