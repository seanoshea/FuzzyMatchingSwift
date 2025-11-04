# Version 0.11.0

## Major Features
- **NEW: Swift Package Manager (SPM) Support** - Full SPM integration with Package.swift
  - Lower deployment targets for SPM: iOS 16+, macOS 13+, watchOS 9+, tvOS 16+
  - Enables support for iOS 16 and 17 users
  - Strict concurrency mode enabled in Package.swift
- **Swift 6 Modernization** - Full compatibility with Swift 6.2
  - Added Sendable conformance to FuzzyMatchOptions and FuzzyMatchingOptionsDefaultValues
  - Safe use in concurrent and actor contexts
  - Strict concurrency checking enabled

## Code Quality Improvements
- **Comprehensive Documentation** - Added DocC documentation throughout the codebase
  - All public APIs documented with detailed descriptions
  - Parameter and return value documentation
  - Algorithm explanations for internal methods
  - Rich IDE code completion support
- **Modern Swift Patterns**
  - Removed deprecated NSNotFound usage (replaced with Optional)
  - Updated Sequence protocol usage (Iterator.Element → Element)
  - Improved nil coalescing operators
  - Modern comparison result handling
  - Standardized access control modifiers

## CI/CD & Build System Enhancements
- **Expanded CI/CD Pipeline** - From 4 jobs to 8 comprehensive jobs
  - Added Xcode version matrix testing (15.3, 15.4)
  - Added iOS version matrix testing (17.5, 18.0, 18.2)
  - Full platform test coverage: iOS, macOS, tvOS, watchOS
  - Added SPM build verification in CI
  - Integrated Codecov for automatic coverage tracking
- **Enhanced SwiftLint Configuration**
  - Reduced disabled rules: 9 → 1 (with justification)
  - Added strict concurrency checking
  - Added documentation enforcement
  - Configured rule thresholds for better code quality
- **Code Coverage Integration**
  - Automatic coverage reporting to Codecov
  - Coverage artifacts preserved for analysis
  - Ready for coverage badges in README

## Documentation
- Created MODERNIZATION.md with detailed implementation guide
- Created REVIEW_RESULTS.md with comprehensive review results
- Updated inline code documentation throughout

## Backward Compatibility
- ✅ 100% backward compatible
- All public API signatures unchanged
- All existing code continues to work without modification
- No breaking changes

## Distribution Methods
- ✅ CocoaPods (unchanged)
- ✅ Carthage (unchanged)
- ✅ Swift Package Manager (NEW)

---

# Version 0.10.0

- Upgraded to Swift 6.2
- Updated minimum deployment targets:
  - iOS 18.2
  - macOS 15.2
  - watchOS 11.2
  - tvOS 18.2
- Updated Xcode to 16.2 in CI environment
- Migrated from CircleCI to GitHub Actions
- Fixed tvOS build destination in GitHub Actions workflow
- Updated Ruby requirement to 3.4.7

# Version 0.9.0

- Upgrading Swift and iOS/MacOS/watchOS and tvOS versions.
- Upgrading Ruby & CircleCI for the development & CI environments.

# Version 0.8.1

- Minor version incompatability issues.

# Version 0.8.0

- Upgrade to Xcode 11.3.1
- Bumping minimum iOS version to 13.2
- Bumping minimum tvOS version to 13.2
- Bumping minimum OSX version to 10.15
- Bumping minimum watchOS version to 6.2

# Version 0.7.0

- Upgrade to Xcode 9.1
- Bumping minimum iOS version to 11.1
- Bumping minimum tvOS version to 11.1
- Bumping minimum OSX version to 10.13
- Bumping minimum watchOS version to 4.1

# Version 0.6.0

- Swift 4 upgrade.
- Bumping minimum iOS version to 10.x
- Bumping minimum watchOS version to 4.x
- Bumping minimum tvOS version to 10.x

# Version 0.5.1

- Minor unit test change.

# Version 0.5.0

- Upgraded to Swift 3.0.
- Added a simple iOS sample application.
- Allowing for duplicates in `sortedByFuzzyMatchPattern`. Will always return an Array with the same size as the host Array.
- More unit testing.

# Version 0.4.0

- Improved accuracy in fuzzy matching.
- Corrected fuzzy matching thresholding in `sortedByFuzzyMatchPattern`
- Documentation and unit test improvements.

# Version 0.3.0

- Added confidence APIs.
- Codified parameter passing in FuzzyMatchOptions struct.
- Documentation and unit test improvements.

# Version 0.2.0

- Returning optionals instead of NSNotFound for fuzzy matching functions.
- tvOS, watchOS, mac targets added.
- Carthage support added.

# Version 0.1.0

- Initial FuzzyMatchingSwift Library Version
