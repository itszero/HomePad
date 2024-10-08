#!/bin/sh
codesign -vvv --force --options runtime -s 'Apple Development: <redacted>' ./Carthage/Build/MobileVLCKit.xcframework
codesign -vvv --force --options runtime -s 'Apple Development: <redacted>' ./Carthage/Build/MobileVLCKit.xcframework/ios-arm64_armv7_armv7s/MobileVLCKit.framework
codesign -vvv --force --options runtime -s 'Apple Development: <redacted>' ./Carthage/Build/MobileVLCKit.xcframework/ios-arm64_i386_x86_64-simulator/MobileVLCKit.framework
