/*
Copyright (c) 2016 Sean O'Shea

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

public enum FuzzyMatchingOptionsParams : String {
  case threshold = "threshold"
  case distance = "distance"
}

public enum FuzzyMatchingOptionsDefaultValues : Double {
  case threshold = 0.5
  case distance = 1000.0
}

extension _ArrayType where Generator.Element == String {
  
  public func sortedByFuzzyMatchPattern(pattern:String) -> [String] {
    var sortedArray = [String]()
    for element in 10.stride(to: 1, by: -1) {
      // stop if we've already found all there is to find
      if sortedArray.count == self.count { break }
      // otherwise, proceed to the rest of the values
      let threshold:Double = Double(element / 10)
      let options = [FuzzyMatchingOptionsParams.threshold.rawValue : threshold]
      for value in self {
        if !sortedArray.contains(value) {
          if value.fuzzyMatchPattern(pattern, loc: 0, options: options) != NSNotFound {
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

extension String {

  public func fuzzyMatchPattern(pattern:String) -> Int {
    return self.fuzzyMatchPattern(pattern, loc: 0, options: nil)
  }

  public func fuzzyMatchPattern(pattern:String, loc:Int, options:[String: Double]?) -> Int {
    guard self.characters.count > 0 else { return NSNotFound }
    let generatedOptions = self.generateOptions(options)
    let location = max(0, min(loc, self.characters.count))
    let threshold = generatedOptions[FuzzyMatchingOptionsParams.threshold.rawValue]!
    let distance = generatedOptions[FuzzyMatchingOptionsParams.distance.rawValue]!

    if self.caseInsensitiveCompare(pattern) == NSComparisonResult.OrderedSame {
      return 0
    } else if pattern.isEmpty {
      return NSNotFound
    } else {
      if (location + pattern.characters.count) < self.characters.count {
        let substring = (self as NSString).substringWithRange(NSMakeRange(location, pattern.characters.count))
        if pattern.caseInsensitiveCompare(substring) == NSComparisonResult.OrderedSame {
          return location
        } else {
          return self.matchBitapOfText(pattern, loc:location, threshold:threshold, distance:distance)
        }
      } else {
        return self.matchBitapOfText(pattern, loc:location, threshold:threshold, distance:distance)
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

  func matchBitapOfText(pattern:String, loc:Int, threshold:Double, distance:Double) -> Int {
    let alphabet = self.matchAlphabet(pattern)
    var scoreThreshold = threshold

    var bestLoc = (self as NSString).rangeOfString(pattern, options:NSStringCompareOptions.LiteralSearch, range:NSMakeRange(0, self.characters.count - 0), locale: NSLocale.currentLocale()).location
    if bestLoc != NSNotFound {
      scoreThreshold = min(self.bitapScoreForErrorCount(0, x:bestLoc, loc:loc, pattern:pattern, distance:distance), scoreThreshold)
      let searchRangeLoc = min(loc + pattern.characters.count, self.characters.count)
      let searchRange = NSMakeRange(0, searchRangeLoc)
      bestLoc = (self as NSString).rangeOfString(pattern, options:NSStringCompareOptions.BackwardsSearch, range:searchRange, locale:NSLocale.currentLocale()).location
      if bestLoc != NSNotFound {
        scoreThreshold = min(self.bitapScoreForErrorCount(0, x:bestLoc, loc:loc, pattern:pattern, distance:distance), scoreThreshold)
      }
    }
    let matchMask = 1 << (pattern.characters.count - 1)
    var binMin:Int
    var binMid:Int
    var binMax = pattern.characters.count + self.characters.count
    var rd:[Int?] = [Int?]()
    var lastRd:[Int?] = [Int?]()
    bestLoc = NSNotFound
    for (index, _) in pattern.characters.enumerate() {
      binMin = 0
      binMid = binMax
      while (binMin < binMid) {
        let score = self.bitapScoreForErrorCount(index, x:(loc + binMid), loc:loc, pattern:pattern, distance:distance)
        if (score <= scoreThreshold) {
          binMin = binMid
        } else {
          binMax = binMid
        }
        binMid = (binMax - binMin) / 2 + binMin
      }
      binMax = binMid
      var start = self.maxOfConstAndDiff(1, b:loc, c:binMid)
      let finish = min(loc + binMid, self.characters.count) + pattern.characters.count
      rd = [Int?](count:finish + 2, repeatedValue:0)
      rd[finish + 1] = (1 << index) - 1
      for (var j = finish; j >= start; j = j - 1) {
        var charMatch:Int
        if self.characters.count <= j - 1 {
          charMatch = 0
        } else {
          let character = String(self[self.startIndex.advancedBy(j - 1)])
          if (self.characters.count <= j - 1 || alphabet[character] == nil) {
            charMatch = 0
          } else {
            charMatch = alphabet[character]!
          }
        }
        if (index == 0) {
          rd[j] = ((rd[j + 1]! << 1) | 1) & charMatch
        } else {
          rd[j] = (((rd[j + 1]! << 1) | 1) & charMatch) | (((lastRd[j + 1]! | lastRd[j]!) << 1) | 1) | lastRd[j + 1]!
        }
        if ((rd[j]! & matchMask) != 0) {
          let score = self.bitapScoreForErrorCount(index, x:(j - 1), loc:loc, pattern:pattern, distance:distance)
          if (score <= scoreThreshold) {
            scoreThreshold = score
            bestLoc = j - 1
            if (bestLoc > loc) {
              start = self.maxOfConstAndDiff(1, b:2 * loc, c:bestLoc)
            } else {
              break
            }
          }
        }
      }
      if self.bitapScoreForErrorCount(index + 1, x:loc, loc:loc, pattern:pattern, distance:distance) > scoreThreshold {
        break
      }
      lastRd = rd
    }
    return bestLoc
  }

  func generateOptions(options:[String:Double]?) -> [String: Double] {
    var generatedOptions = self.defaultOptions()
    if let unwrappedOptions = options {
      if let threshold = unwrappedOptions[FuzzyMatchingOptionsParams.threshold.rawValue] {
        generatedOptions[FuzzyMatchingOptionsParams.threshold.rawValue] = threshold
      }
      if let distance = unwrappedOptions[FuzzyMatchingOptionsParams.distance.rawValue] {
        generatedOptions[FuzzyMatchingOptionsParams.distance.rawValue] = distance
      }
    }
    return generatedOptions
  }

  func defaultOptions() -> [String: Double] {
    return [
      FuzzyMatchingOptionsParams.threshold.rawValue : FuzzyMatchingOptionsDefaultValues.threshold.rawValue,
      FuzzyMatchingOptionsParams.distance.rawValue : FuzzyMatchingOptionsDefaultValues.distance.rawValue
    ]
  }

  func maxOfConstAndDiff(a:Int, b:Int, c:Int) -> Int {
    return b <= c ? a : b - c + a
  }
}
