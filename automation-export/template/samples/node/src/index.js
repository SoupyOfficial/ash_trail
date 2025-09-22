const { greet } = require('./hello');

/**
 * Entry point of the application.
 */
function main() {
  const args = process.argv.slice(2);

  if (args.length > 0) {
    console.log(greet(args[0]));
  } else {
    console.log(greet());
  }
}

if (require.main === module) {
  main();
}
