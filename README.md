# FuzzyMatchingSwift

[![CI Status](https://circleci.com/gh/seanoshea/FuzzyMatchingSwift/tree/develop.svg?style=svg)](https://circleci.com/gh/seanoshea/FuzzyMatchingSwift/tree/develop)
[![Code Coverage](http://codecov.io/github/seanoshea/FuzzyMatchingSwift/coverage.svg?branch=develop)](http://codecov.io/github/seanoshea/FuzzyMatchingSwift?branch=develop)
[![Version](https://img.shields.io/cocoapods/v/FuzzyMatchingSwift.svg?style=flat)](http://cocoapods.org/pods/FuzzyMatchingSwift)
[![License](https://img.shields.io/cocoapods/l/FuzzyMatchingSwift.svg?style=flat)](http://cocoapods.org/pods/FuzzyMatchingSwift)
[![Platform](https://img.shields.io/cocoapods/p/FuzzyMatchingSwift.svg?style=flat)](http://cocoapods.org/pods/FuzzyMatchingSwift)

## Acknowledgements

The majority of the fuzzy matching logic included in this project is taken from Neil Fraser's [google-diff-match-patch](https://code.google.com/p/google-diff-match-patch/)

## Requirements

Supports iOS9 and above.

## Documentation

All documentation is maintained at [cocoadocs](http://cocoadocs.org/docsets/FuzzyMatchingSwift/)

## Usage

```swift
// strings
"abcdef".fuzzyMatchPattern("ab") // returns 0
"abcdef".fuzzyMatchPattern("z") // returns NSNotFound
// arrays
["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"].sortedByFuzzyMatchPattern("on") // returns ["one", "two", "four", "seven", "nine", "ten", "three", "five", "six", "eight"]
```

## Installation

FuzzyMatchingSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "FuzzyMatchingSwift"
```

## Author

seanoshea, oshea.ie@gmail.com. See the Acknowledgements section for the original basis for this code.

## License

FuzzyMatchingSwift is available under the Apache 2 license. See the LICENSE file for more info.

## Contributing

Contributions to the development of the app are always welcome. Some guidelines:
- If you **found a bug**, _and can provide steps to reliably reproduce it_, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

There's a simple well-intentioned [Code of Conduct](http://contributor-covenant.org/version/1/2/0/code_of_conduct.txt) for any community that might spring up around the development of the library too.
