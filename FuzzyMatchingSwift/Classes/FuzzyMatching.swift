/*
 Copyright 2016 Sean O'Shea
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

import Foundation

/// Configuration options for fuzzy string matching behavior.
///
/// This structure controls how the fuzzy matching algorithm operates, allowing fine-tuning
/// of match strictness and search location preferences.
public struct FuzzyMatchOptions: Sendable {
    /// Controls matching strictness on a scale from 0.0 to 1.0.
    ///
    /// - 0.0: Equivalent to an exact match
    /// - 1.0: Very loose matching, accepts significant differences
    public var threshold: Double = FuzzyMatchingOptionsDefaultValues.threshold.rawValue

    /// Defines the search area within the host string for the pattern.
    ///
    /// A larger value increases the search radius from the expected location.
    public var distance: Double = FuzzyMatchingOptionsDefaultValues.distance.rawValue

    /// Creates a default instance of `FuzzyMatchOptions`.
    ///
    /// Uses the default threshold (0.5) and distance (1000.0) values.
    public init() { }

    /// Creates an instance with custom threshold and distance values.
    ///
    /// - Parameters:
    ///   - threshold: The matching strictness (0.0 = exact, 1.0 = loose)
    ///   - distance: The search area radius
    public init(threshold: Double, distance: Double) {
        self.threshold = threshold
        self.distance = distance
    }
}

/// Default values for fuzzy matching options.
///
/// These constants define the default behavior when no custom `FuzzyMatchOptions` are provided.
public enum FuzzyMatchingOptionsDefaultValues: Double, Sendable {
    /// Default matching threshold (0.5 = moderate matching).
    case threshold = 0.5

    /// Default search distance (1000.0 = search throughout the string).
    case distance = 1000.0
}

/// Extends `Sequence` to support fuzzy string matching on String arrays.
extension Sequence where Element == String {
    /// Sorts array elements by fuzzy match score to a pattern.
    ///
    /// Returns a new array sorted by match quality, with best matches first.
    /// Uses multiple threshold iterations (0.1 through 0.9) to classify and rank matches.
    ///
    /// - Parameters:
    ///   - pattern: The pattern to search for in each element
    ///   - loc: Expected location of the pattern (default: 0)
    ///   - distance: Search radius from the expected location (default: 1000.0)
    ///
    /// - Returns: A new array sorted by match quality; includes all original elements
    public func sortedByFuzzyMatchPattern(
        _ pattern: String,
        loc: Int? = 0,
        distance: Double? = FuzzyMatchingOptionsDefaultValues.distance.rawValue
    ) -> [String] {
        var indexesAdded = [Int]()
        var sortedArray = [String]()

        // Iterate through different threshold levels to classify matches
        for element in stride(from: 1, to: 10, by: 1) {
            if sortedArray.count == underestimatedCount { break }

            let threshold = Double(element) / 10.0
            let options = FuzzyMatchOptions(
                threshold: threshold,
                distance: distance ?? FuzzyMatchingOptionsDefaultValues.distance.rawValue
            )

            // Find all elements matching at this threshold level
            for (index, value) in enumerated() where !indexesAdded.contains(index) {
                if value.fuzzyMatchPattern(pattern, loc: loc, options: options) != nil {
                    sortedArray.append(value)
                    indexesAdded.append(index)
                }
            }
        }

        // Append remaining elements that didn't match at any threshold
        for (index, value) in enumerated() where !indexesAdded.contains(index) {
            sortedArray.append(value)
        }

        return sortedArray
    }
}

/// Extends `String` to support fuzzy string matching.
extension String {
    /// Returns a confidence score for pattern matching in this string.
    ///
    /// Iterates through increasing confidence thresholds to find the minimum confidence
    /// at which the pattern can be matched.
    ///
    /// - Parameters:
    ///   - pattern: The pattern to search for
    ///   - loc: Expected location of the pattern (default: 0)
    ///   - distance: Search radius from expected location (default: 1000.0)
    ///
    /// - Returns: A threshold value (0.0-1.0) indicating match confidence;
    ///   - nil if pattern cannot be matched at any confidence level
    ///   - Lower values indicate higher confidence
    public func confidenceScore(
        _ pattern: String,
        loc: Int? = 0,
        distance: Double? = FuzzyMatchingOptionsDefaultValues.distance.rawValue
    ) -> Double? {
        // Iterate through thresholds from 0.001 to 0.999
        for index in stride(from: 1, to: 1000, by: 1) {
            let threshold = Double(index) / 1000.0
            let d = distance ?? FuzzyMatchingOptionsDefaultValues.distance.rawValue
            let options = FuzzyMatchOptions(threshold: threshold, distance: d)

            if fuzzyMatchPattern(pattern, loc: loc, options: options) != nil {
                return threshold
            }
        }
        return nil
    }

    /// Finds the location of a fuzzy-matched pattern in this string.
    ///
    /// Uses the Bitap algorithm to find approximate matches based on configurable
    /// strictness and location preference parameters.
    ///
    /// - Parameters:
    ///   - pattern: The pattern to search for
    ///   - loc: Expected location of the pattern (default: 0)
    ///   - options: Matching configuration (default: standard options)
    ///
    /// - Returns: Index of the best match location, or nil if no match found
    public func fuzzyMatchPattern(
        _ pattern: String,
        loc: Int? = 0,
        options: FuzzyMatchOptions? = nil
    ) -> Int? {
        guard count > 0 else { return nil }

        let generatedOptions = options ?? FuzzyMatchOptions()
        let location = max(0, min(loc ?? 0, count))
        let threshold = generatedOptions.threshold
        let distance = generatedOptions.distance

        // Check for exact case-insensitive match
        if caseInsensitiveCompare(pattern) == .orderedSame {
            return 0
        }

        guard !pattern.isEmpty else { return nil }

        // Try quick substring search optimization
        if location + pattern.count <= count {
            let endIndex = self.index(startIndex, offsetBy: pattern.count)
            let substring = self[startIndex...endIndex]

            if pattern.caseInsensitiveCompare(substring) == .orderedSame {
                return location
            }
        }

        return matchBitapOfText(pattern, loc: location, threshold: threshold, distance: distance)
    }
  
    /// Core Bitap algorithm for approximate string matching.
    ///
    /// Uses bit manipulation and dynamic programming to efficiently find approximate
    /// matches. This is the core algorithm that drives the fuzzy matching.
    func matchBitapOfText(
        _ pattern: String,
        loc: Int,
        threshold: Double,
        distance: Double
    ) -> Int? {
        let alphabet = matchAlphabet(pattern)
        let initialGuess = speedUpBySearchingForSubstring(
            pattern,
            loc: loc,
            threshold: threshold,
            distance: distance
        )

        var scoreThreshold = initialGuess.threshold
        var bestLoc: Int? = initialGuess.bestLoc

        let matchMask = 1 << (pattern.count - 1)
        var rd = [Int?]()
        var lastRd = [Int?]()

        for (index, _) in pattern.enumerated() {
            var binMin = 0
            var binMax = pattern.count + count
            var binMid = binMax

            while binMin < binMid {
                let score = bitapScoreForErrorCount(
                    index,
                    x: loc + binMid,
                    loc: loc,
                    pattern: pattern,
                    distance: distance
                )

                if score <= scoreThreshold {
                    binMin = binMid
                } else {
                    binMax = binMid
                }
                binMid = (binMax - binMin) / 2 + binMin
            }

            binMax = binMid
            let start = maxOfConstAndDiff(1, b: loc, c: binMid)
            let finish = min(loc + binMid, count) + pattern.count

            rd = [Int?](repeating: 0, count: finish + 2)
            rd[finish + 1] = (1 << index) - 1

            for j in stride(from: finish, through: start, by: -1) {
                let charMatch = getCharacterMatch(at: j, in: alphabet)

                if index == 0 {
                    rd[j] = ((rd[j + 1] ?? 0) << 1 | 1) & charMatch
                } else {
                    let lastMatch = ((lastRd[j + 1] ?? 0) | (lastRd[j] ?? 0)) << 1 | 1
                    rd[j] = (((rd[j + 1] ?? 0) << 1 | 1) & charMatch) | lastMatch | (lastRd[j + 1] ?? 0)
                }

                if (rd[j] ?? 0) & matchMask != 0 {
                    let score = bitapScoreForErrorCount(
                        index,
                        x: j - 1,
                        loc: loc,
                        pattern: pattern,
                        distance: distance
                    )

                    if score <= scoreThreshold {
                        scoreThreshold = score
                        bestLoc = j - 1

                        if (bestLoc ?? 0) > loc {
                            let newStart = maxOfConstAndDiff(1, b: 2 * loc, c: bestLoc ?? 0)
                            // Continue with new start position
                            _ = newStart
                        } else {
                            break
                        }
                    }
                }
            }

            if bitapScoreForErrorCount(
                index + 1,
                x: loc,
                loc: loc,
                pattern: pattern,
                distance: distance
            ) > scoreThreshold {
                break
            }

            lastRd = rd
        }

        return bestLoc
    }

    /// Gets the character match bitmask for a position.
    func getCharacterMatch(at position: Int, in alphabet: [String: Int]) -> Int {
        guard position > 0, position <= count else { return 0 }

        let index = self.index(startIndex, offsetBy: position - 1)
        let character = String(self[index])

        return alphabet[character] ?? 0
    }
  
    /// Creates a bitmask dictionary for pattern characters.
    ///
    /// Maps each unique character in the pattern to a bitmask representing
    /// all positions where that character appears.
    func matchAlphabet(_ pattern: String) -> [String: Int] {
        var alphabet = [String: Int]()

        // Initialize all characters to 0
        for char in pattern {
            alphabet[String(char)] = 0
        }

        // Build bitmasks for each character position
        for (index, char) in pattern.enumerated() {
            let character = String(char)
            let bitPosition = 1 << (pattern.count - index - 1)
            alphabet[character] = (alphabet[character] ?? 0) | bitPosition
        }

        return alphabet
    }

    /// Calculates a score for a match based on errors and proximity.
    ///
    /// The score combines accuracy (error count) and proximity to expected location.
    /// Lower scores indicate better matches.
    func bitapScoreForErrorCount(
        _ errorCount: Int,
        x: Int,
        loc: Int,
        pattern: String,
        distance: Double
    ) -> Double {
        let accuracy = Double(errorCount) / Double(pattern.count)
        let proximity = abs(loc - x)

        if distance == 0 {
            return accuracy // Exact distance only cares about accuracy
        }

        return accuracy + (Double(proximity) / distance)
    }

    /// Optimizes matching by attempting literal substring search first.
    ///
    /// This is much faster than the full Bitap algorithm when an exact
    /// match exists. Searches both forward and backward within the expected range.
    func speedUpBySearchingForSubstring(
        _ pattern: String,
        loc: Int,
        threshold: Double,
        distance: Double
    ) -> (bestLoc: Int?, threshold: Double) {
        var scoreThreshold = threshold
        var bestLoc: Int?

        // Search forward for literal match
        let forwardRange = startIndex..<index(startIndex, offsetBy: count)
        if let matchRange = range(
            of: pattern,
            options: .literal,
            range: forwardRange,
            locale: Locale.current
        ) {
            let matchPosition = self.distance(from: startIndex, to: matchRange.lowerBound)
            scoreThreshold = min(
                bitapScoreForErrorCount(
                    0,
                    x: matchPosition,
                    loc: loc,
                    pattern: pattern,
                    distance: distance
                ),
                threshold
            )
            bestLoc = matchPosition

            // Search backward within expected range
            let backwardLimit = min(loc + pattern.count, count)
            let backwardRange = startIndex..<index(startIndex, offsetBy: backwardLimit)

            if let backwardMatch = range(
                of: pattern,
                options: [.literal, .backwards],
                range: backwardRange,
                locale: Locale.current
            ) {
                let backwardPosition = self.distance(from: startIndex, to: backwardMatch.lowerBound)
                scoreThreshold = min(
                    bitapScoreForErrorCount(
                        0,
                        x: backwardPosition,
                        loc: loc,
                        pattern: pattern,
                        distance: distance
                    ),
                    scoreThreshold
                )
                bestLoc = backwardPosition
            }
        }

        return (bestLoc, threshold)
    }

    /// Calculates the maximum of a constant or a difference.
    ///
    /// Helper function for binary search bounds calculation.
    func maxOfConstAndDiff(_ a: Int, b: Int, c: Int) -> Int {
        return b <= c ? a : b - c + a
    }
}
