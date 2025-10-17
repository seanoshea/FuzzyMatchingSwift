# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FuzzyMatchingSwift is a Swift library that provides fuzzy string matching capabilities based on Neil Fraser's google-diff-match-patch algorithm. It extends String and Array types with fuzzy matching functionality.

## Development Commands

### Building and Testing

```bash
# Install dependencies (requires CocoaPods)
cd Example && bundle exec pod install

# Run tests on iOS simulator
xcodebuild -workspace ./Example/FuzzyMatchingSwift.xcworkspace \
  -scheme FuzzyMatchingSwift-Example \
  -destination "platform=iOS Simulator,OS=18.0,name=iPhone 16 Pro Max" \
  clean test

# Build iOS framework
xcodebuild -workspace ./Example/FuzzyMatchingSwift.xcworkspace \
  -scheme FuzzyMatchingSwift-iOS \
  CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" \
  clean build

# Build macOS framework
xcodebuild -workspace ./Example/FuzzyMatchingSwift.xcworkspace \
  -scheme FuzzyMatchingSwift-macOS \
  clean build

# Build watchOS framework
xcodebuild -workspace ./Example/FuzzyMatchingSwift.xcworkspace \
  -scheme FuzzyMatchingSwift-watchOS \
  -destination "generic/platform=watchOS" \
  CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" \
  clean build

# Build tvOS framework
xcodebuild -workspace ./Example/FuzzyMatchingSwift.xcworkspace \
  -scheme FuzzyMatchingSwift-tvOS \
  -destination "platform=tvOS Simulator,name=Apple TV" \
  clean build

# Run a specific test class
xcodebuild -workspace ./Example/FuzzyMatchingSwift.xcworkspace \
  -scheme FuzzyMatchingSwift-Example \
  -destination "platform=iOS Simulator,OS=18.0,name=iPhone 16 Pro Max" \
  -only-testing:FuzzyMatchingSwift_Tests/FuzzyMatchingStringTests \
  test

# Run a specific test method
xcodebuild -workspace ./Example/FuzzyMatchingSwift.xcworkspace \
  -scheme FuzzyMatchingSwift-Example \
  -destination "platform=iOS Simulator,OS=18.0,name=iPhone 16 Pro Max" \
  -only-testing:FuzzyMatchingSwift_Tests/FuzzyMatchingStringTests/testWithoutOptions \
  test
```

### Linting

```bash
# Run SwiftLint
swiftlint lint --config .swiftlint.yml
```

### CocoaPods

```bash
# Validate podspec
bundle exec pod lib lint --quick
```

## Code Architecture

### Core Algorithm (FuzzyMatching.swift)

The library implements a Bitap algorithm for fuzzy string matching with the following components:

**FuzzyMatchOptions**: Configuration struct controlling matching behavior
- `threshold` (0.0-1.0): Strictness of matching (0.0 = exact match, 1.0 = very loose)
- `distance`: Defines search area within the host string

**String Extensions**:
- `fuzzyMatchPattern(_:loc:options:)`: Returns index where pattern is found (or nil)
- `confidenceScore(_:loc:distance:)`: Returns confidence level (0.001 = high confidence, 0.999 = low confidence)
- `matchBitapOfText(_:loc:threshold:distance:)`: Core Bitap algorithm implementation
- `matchAlphabet(_:)`: Creates bitmask dictionary for pattern characters
- `speedUpBySearchingForSubstring(_:loc:threshold:distance:)`: Optimization using literal search first

**Array Extensions** (where Element == String):
- `sortedByFuzzyMatchPattern(_:loc:distance:)`: Returns new sorted array based on fuzzy match scores (iterates through thresholds 0.1-0.9)

### Algorithm Flow

1. Quick checks: exact match, empty pattern
2. Optimization: attempt literal substring search first (`speedUpBySearchingForSubstring`)
3. If literal search fails, use Bitap algorithm (`matchBitapOfText`)
4. Bitap uses character alphabet and bit masking to find approximate matches
5. Scoring based on both accuracy (edit distance) and proximity to expected location

### Project Structure

- `FuzzyMatchingSwift/Classes/FuzzyMatching.swift`: Core implementation (single file library)
- `Example/FuzzyMatchingSwift_Example/`: Demo iOS app
- `Example/Tests/`: XCTest suite
  - `FuzzyMatchingStringTests.swift`: Tests for String extensions
  - `FuzzyMatchingArrayTests.swift`: Tests for Array extensions

### Platform Support

- iOS >= 18.2
- macOS >= 15.2
- watchOS >= 11.2
- tvOS >= 18.2
- Swift 6.2

### Distribution

The library is distributed via:
- CocoaPods (podspec: FuzzyMatchingSwift.podspec)
- Carthage compatible
- Single source file makes manual integration trivial

### SwiftLint Configuration

The project uses SwiftLint with many rules disabled (.swiftlint.yml excludes line_length, variable_name, trailing_whitespace, colon, function_body_length, type_name, cyclomatic_complexity, function_parameter_count, shorthand_operator).
