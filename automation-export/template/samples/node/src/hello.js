/**
 * Simple Hello World application for testing automation template.
 */

/**
 * Returns a greeting message.
 * @param {string} name - The name to greet
 * @returns {string} Greeting message
 */
function greet(name) {
  if (!name || name.trim() === '') {
    return 'Hello, World!';
  }
  return `Hello, ${name}!`;
}

/**
 * Main function to run the application.
 */
function main() {
  const args = process.argv.slice(2);

  if (args.length > 0) {
    console.log(greet(args[0]));
  } else {
    console.log(greet());
  }
}

// Export for testing
module.exports = { greet };

// Run main function if this file is executed directly
if (require.main === module) {
  main();
}
