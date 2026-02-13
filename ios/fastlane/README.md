fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios testflight

```sh
[bundle exec] fastlane ios testflight
```

Upload to TestFlight

### ios upload_ipa

```sh
[bundle exec] fastlane ios upload_ipa
```

Upload IPA to TestFlight

### ios refresh_dsyms

```sh
[bundle exec] fastlane ios refresh_dsyms
```

Download dSYMs from App Store Connect and upload to Crashlytics

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
