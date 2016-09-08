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

/**
 Allows client code to pass parameters to the `fuzzyMatchPattern` calls.
 */
public struct FuzzyMatchOptions {
  // defines how strict you want to be when fuzzy matching. A value of 1.0 equals to an exact match. A value of 0.1 indicates a very loose understanding of whether a match has been found.
  var threshold:Double = FuzzyMatchingOptionsDefaultValues.threshold.rawValue
  // defines where in the host String to look for the pattern
  var distance:Double = FuzzyMatchingOptionsDefaultValues.distance.rawValue
  
  /**
   Standard initializer.
   */
  public init() {
    
  }
  
  /**
   Initializer which defines `threshold` and `distance` parameters.
   
   - parameter threshold: The threshold value to set
   - parameter distance:  The distance value to set
   - returns: An instance of `FuzzyMatchOptions`
   */
  public init(threshold: Double, distance: Double) {
    self.threshold = threshold
    self.distance = distance
  }
}

/**
 Defines constants which are used if no `options` parameters are passed to `fuzzyMatchPattern` calls.
 */
public enum FuzzyMatchingOptionsDefaultValues : Double {
  case threshold = 0.5
  case distance = 1000.0
}

/**
 Allows for fuzzy matching to happen on all String elements in an Array.
 */
extension _ArrayType where Generator.Element == String {

  /**
   Iterates over all elements in the array and executes a fuzzy match using the `pattern` parameter.
   
   - parameter pattern: The pattern to search for.
   - parameter loc: The index in the element from which to search.
   - parameter distance: Determines how close the match must be to the fuzzy location. See `loc` parameter.
   - returns: An ordered set of Strings based on whichever element matches closest to the `pattern` parameter.
   */
  public func sortedByFuzzyMatchPattern(pattern:String, loc:Int? = 0, distance:Double? = 1000.0) -> [String] {
    var sortedArray = [String]()
    for element in 10.stride(to: 1, by: -1) {
      // stop if we've already found all there is to find
      if sortedArray.count == count { break }
      // otherwise, proceed to the rest of the values
      var options = FuzzyMatchOptions.init(threshold:Double(element / 10), distance:FuzzyMatchingOptionsDefaultValues.distance.rawValue)
      if let unwrappedDistance = distance {
        options.distance = unwrappedDistance
      }
      for value in self {
        if !sortedArray.contains(value) {
          if let _ = value.fuzzyMatchPattern(pattern, loc: loc, options: options) {
            sortedArray.append(value)
          }
        }
      }
    }
    // make sure that the array we return to the user has ALL elements which is in the initial array
    for value in self {
      if !sortedArray.contains(value) {
        sortedArray.append(value)
      }
    }
    return sortedArray
  }
}

/**
 Allows for fuzzy matching to happen on Strings
 */
extension String {

  /**
   Executes a fuzzy match on the String using the `pattern` parameter.
   
   - parameter pattern: The pattern to search for.
   - parameter loc: The index in the element from which to search.
   - parameter options: Dictates how the search is executed. See `FuzzyMatchingOptionsParams` and `FuzzyMatchingOptionsDefaultValues` for details.
   - returns: An Int indicating where the fuzzy matched pattern can be found in the String.
   */
  public func fuzzyMatchPattern(pattern:String, loc:Int? = 0, options:FuzzyMatchOptions? = nil) -> Int? {
    guard characters.count > 0 else { return nil }
    let generatedOptions = generateOptions(options)
    let location = max(0, min(loc ?? 0, characters.count))
    let threshold = generatedOptions.threshold
    let distance = generatedOptions.distance

    if caseInsensitiveCompare(pattern) == NSComparisonResult.OrderedSame {
      return 0
    } else if pattern.isEmpty {
      return nil
    } else {
      if (location + pattern.characters.count) < characters.count {
        let substring = self[self.startIndex.advancedBy(0)...self.startIndex.advancedBy(pattern.characters.count)]
        if pattern.caseInsensitiveCompare(substring) == NSComparisonResult.OrderedSame {
          return location
        } else {
          return matchBitapOfText(pattern, loc:location, threshold:threshold, distance:distance)
        }
      } else {
        return matchBitapOfText(pattern, loc:location, threshold:threshold, distance:distance)
      }
    }
  }

  func matchAlphabet(pattern:String) -> [String: Int] {
    var alphabet = [String: Int]()
    for char in pattern.characters {
      alphabet[String(char)] = 0
    }
    for (i, char) in pattern.characters.enumerate() {
      let stringRepresentationOfCharacter = String(char)
      let possibleEntry = alphabet[stringRepresentationOfCharacter]!
      let value = possibleEntry | (1 << (pattern.characters.count - i - 1))
      alphabet[stringRepresentationOfCharacter] = value
    }
    return alphabet
  }

  func bitapScoreForErrorCount(e:Int, x:Int, loc:Int, pattern:String, distance:Double) -> Double {
    let accuracy = e / pattern.characters.count
    let proximity = abs(loc - x)
    if distance == 0 {
      return Double(proximity == 0 ? accuracy : 1)
    } else {
      return Double(Double(accuracy) + (Double(proximity) / distance))
    }
  }

  func matchBitapOfText(pattern:String, loc:Int, threshold:Double, distance:Double) -> Int? {
    let alphabet = matchAlphabet(pattern)
    var scoreThreshold = threshold
    var bestLoc = NSNotFound
    var range: Range<String.Index> = startIndex..<startIndex.advancedBy(characters.count)
    
    if let possibleLiteralSearchRange = rangeOfString(pattern, options:NSStringCompareOptions.LiteralSearch, range:range, locale: NSLocale.currentLocale()) {
      bestLoc = startIndex.distanceTo(possibleLiteralSearchRange.startIndex)
      scoreThreshold = min(bitapScoreForErrorCount(0, x:bestLoc, loc:loc, pattern:pattern, distance:distance), scoreThreshold)
      range = startIndex..<startIndex.advancedBy(min(loc + pattern.characters.count, characters.count))
      if let possibleBackwardsSearchRange = rangeOfString(pattern, options:NSStringCompareOptions.BackwardsSearch, range:range, locale: NSLocale.currentLocale()) {
        bestLoc = startIndex.distanceTo(possibleBackwardsSearchRange.startIndex)
        scoreThreshold = min(bitapScoreForErrorCount(0, x:bestLoc, loc:loc, pattern:pattern, distance:distance), scoreThreshold)
      } else {
        bestLoc = NSNotFound
      }
    }
    
    let matchMask = 1 << (pattern.characters.count - 1)
    var binMin:Int
    var binMid:Int
    var binMax = pattern.characters.count + characters.count
    var rd:[Int?] = [Int?]()
    var lastRd:[Int?] = [Int?]()
    bestLoc = NSNotFound
    for (index, _) in pattern.characters.enumerate() {
      binMin = 0
      binMid = binMax
      while binMin < binMid {
        let score = bitapScoreForErrorCount(index, x:(loc + binMid), loc:loc, pattern:pattern, distance:distance)
        if score <= scoreThreshold {
          binMin = binMid
        } else {
          binMax = binMid
        }
        binMid = (binMax - binMin) / 2 + binMin
      }
      binMax = binMid
      var start = maxOfConstAndDiff(1, b:loc, c:binMid)
      let finish = min(loc + binMid, characters.count) + pattern.characters.count
      rd = [Int?](count:finish + 2, repeatedValue:0)
      rd[finish + 1] = (1 << index) - 1
      var j = finish
      for _ in j.stride(to: start - 1, by: -1) {
        var charMatch:Int
        if characters.count <= j - 1 {
          charMatch = 0
        } else {
          let character = String(self[startIndex.advancedBy(j - 1)])
          if characters.count <= j - 1 || alphabet[character] == nil {
            charMatch = 0
          } else {
            charMatch = alphabet[character]!
          }
        }
        if index == 0 {
          rd[j] = ((rd[j + 1]! << 1) | 1) & charMatch
        } else {
          rd[j] = (((rd[j + 1]! << 1) | 1) & charMatch) | (((lastRd[j + 1]! | lastRd[j]!) << 1) | 1) | lastRd[j + 1]!
        }
        if (rd[j]! & matchMask) != 0 {
          let score = bitapScoreForErrorCount(index, x:(j - 1), loc:loc, pattern:pattern, distance:distance)
          if score <= scoreThreshold {
            scoreThreshold = score
            bestLoc = j - 1
            if bestLoc > loc {
              start = maxOfConstAndDiff(1, b:2 * loc, c:bestLoc)
            } else {
              break
            }
          }
        }
        j = j - 1
      }
      if bitapScoreForErrorCount(index + 1, x:loc, loc:loc, pattern:pattern, distance:distance) > scoreThreshold {
        break
      }
      lastRd = rd
    }
    return bestLoc != NSNotFound ? bestLoc : nil
  }

  func generateOptions(options:FuzzyMatchOptions?) -> FuzzyMatchOptions {
    if let unwrappedOptions = options {
      return unwrappedOptions
    } else {
      return FuzzyMatchOptions.init()
    }
  }

  func maxOfConstAndDiff(a:Int, b:Int, c:Int) -> Int {
    return b <= c ? a : b - c + a
  }
}
