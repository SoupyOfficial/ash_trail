#!/usr/bin/env ruby
require 'xcodeproj'

project = Xcodeproj::Project.open('/Volumes/Jacob-SSD/Projects/ash_trail/ios/Runner.xcodeproj')
watch = project.targets.find { |t| t.name == 'Ash Trail Watch App' }

watch.build_configurations.each do |config|
  config.build_settings['SUPPORTED_PLATFORMS'] = 'watchos watchsimulator'
  config.build_settings['SUPPORTS_MACCATALYST'] = 'NO'
  config.build_settings['SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD'] = 'NO'
  # Ensure the SDK is explicitly watchos
  config.build_settings['SDKROOT'] = 'watchos'
  puts "Updated #{config.name}"
end

project.save
puts '✅ Watch target platform settings fixed'
