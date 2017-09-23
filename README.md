# FuzzyMatchingSwift

[![CI Status](https://circleci.com/gh/seanoshea/FuzzyMatchingSwift/tree/develop.svg?style=svg)](https://circleci.com/gh/seanoshea/FuzzyMatchingSwift/tree/develop)
[![Code Coverage](http://codecov.io/github/seanoshea/FuzzyMatchingSwift/coverage.svg?branch=develop)](http://codecov.io/github/seanoshea/FuzzyMatchingSwift?branch=develop)
[![Version](https://img.shields.io/cocoapods/v/FuzzyMatchingSwift.svg?style=flat)](http://cocoapods.org/pods/FuzzyMatchingSwift)
[![License](https://img.shields.io/cocoapods/l/FuzzyMatchingSwift.svg?style=flat)](http://cocoapods.org/pods/FuzzyMatchingSwift)
[![Platform](https://img.shields.io/cocoapods/p/FuzzyMatchingSwift.svg?style=flat)](http://cocoapods.org/pods/FuzzyMatchingSwift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Swift 4.0.x](https://img.shields.io/badge/Swift-4.0.x-orange.svg)
[![PRs Welcome](https://img.shields.io/badge/prs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

## Acknowledgements

The majority of the fuzzy matching logic included in this project is taken from [Neil Fraser's](https://neil.fraser.name/) [google-diff-match-patch](https://code.google.com/p/google-diff-match-patch/)

## Usage

### Matching on Strings
`FuzzyMatchOptions` can be passed to any of these methods to alter how the strict or loose the fuzzy matching algorithm operates.
- `threshold` in `FuzzyMatchOptions` defines how strict you want to be when fuzzy matching. A value of 0.0 is equivalent to an exact match. A value of 1.0 indicates a very loose understanding of whether a match has been found.
- `distance` in `FuzzyMatchOptions` defines where in the host String to look for the pattern.
```swift
"abcdef".fuzzyMatchPattern("ab") // returns 0
"abcdef".fuzzyMatchPattern("z") // returns nil
"🐶🐱🐶🐶🐶".fuzzyMatchPattern("🐱") // returns 1
```

### Matching on Arrays of Strings
Returns a new instance of an Array which is sorted by the closest fuzzy match. Does not sort the host Array in place. Will always return the same number of elements that are found in the host Array.
```swift
["one", "two", "three"].sortedByFuzzyMatchPattern("on")
// returns ["one", "two", "three"]
["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"].sortedByFuzzyMatchPattern("on")
// returns ["one", "nine", "two", "four", "seven", "ten", "three", "five", "six", "eight"]
["one", "one", "two"].sortedByFuzzyMatchPattern("on")
// returns ["one", "one", "two"]
```

### Providing a confidence level
A confidence level allows client code to understand how likely the fuzzy searching algorithm is to find a pattern within a host String. `confidenceScore` returns a Double which indicates how confident we are that the pattern can be found in the host String. A low value (0.001) indicates that the pattern is likely to be found. A high value (0.999) indicates that the pattern is not likely to be found.
```swift
"Stacee Lima".confidenceScore("SL") // returns 0.5
"abcdef".confidenceScore("g") // returns nil
"🐶🐱🐶🐶🐶".confidenceScore("🐱") // returns 0.001
"🐶🐱🐶🐶🐶".confidenceScore("🐱🐱🐱🐱🐱") // returns 0.8
```

## Documentation

All documentation is maintained at [Cocoadocs](http://cocoadocs.org/docsets/FuzzyMatchingSwift/)

## Requirements

* iOS >= 10.0
* MacOS >= 10.10
* watchOS >= 4.0
* tvOS >= 10.0

## Installation

### CocoaPods

FuzzyMatchingSwift is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "FuzzyMatchingSwift"
```

### Carthage

FuzzyMatchingSwift is available via [Carthage](https://github.com/Carthage/Carthage). To install, just add this entry to your Cartfile:

```ruby
github "seanoshea/FuzzyMatchingSwift"
```

Once you've altered your Cartfile, simply run `carthage update`. Check out the instructions in [Carthage's README](https://github.com/Carthage/Carthage) for up to date installation instructions.

## SwiftLint

[SwiftLint](https://github.com/realm/SwiftLint) can be run on the codebase with:

```bash
swiftlint lint --config .swiftlint.yml
```

## Author

seanoshea, oshea.ie@gmail.com. See the Acknowledgements section for the original basis for this code.

## License

FuzzyMatchingSwift is available under the Apache 2 license. See the LICENSE file for more info.

## Contributing

See the [Contributing Instructions](CONTRIBUTING.MD) for details.
