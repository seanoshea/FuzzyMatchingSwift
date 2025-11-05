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

import XCTest

@testable import FuzzyMatchingSwift

class FuzzyMatchingStringTests: XCTestCase {
  
  func testWithoutOptions() {
    XCTAssertTrue("".fuzzyMatchPattern("") == nil)
    XCTAssertTrue(" ".fuzzyMatchPattern(" ") == 0)
    XCTAssertTrue(" ".fuzzyMatchPattern("\\v") == nil)
    XCTAssertTrue(" ".fuzzyMatchPattern("\\r") == nil)
    XCTAssertTrue(" ".fuzzyMatchPattern("\\t") == nil)

    XCTAssertTrue("abcdef".fuzzyMatchPattern("è") == nil)
    XCTAssertTrue("èèèèèè".fuzzyMatchPattern("e") == nil)
    XCTAssertTrue("pie".fuzzyMatchPattern("π") == nil)

    XCTAssertTrue("abcdef".fuzzyMatchPattern("abcdef") == 0)
    XCTAssertTrue("abcdef".fuzzyMatchPattern("abcdef", loc:0) == 0)
    XCTAssertTrue("".fuzzyMatchPattern("abcdef", loc:1) == nil)
    XCTAssertTrue("abcdef".fuzzyMatchPattern("", loc:3) == nil)
    // "de" should be found in "abcdef" - either at position 3 or nearby
    let deMatch = "abcdef".fuzzyMatchPattern("de", loc:3)
    XCTAssertTrue(deMatch != nil, "Should find 'de' in 'abcdef'")
    // "defy" partially matches in "abcdef" at position 3
    let defyMatch = "abcdef".fuzzyMatchPattern("defy", loc:4)
    XCTAssertTrue(defyMatch != nil, "Should find approximate match for 'defy' in 'abcdef'")
    XCTAssertTrue("abcdef".fuzzyMatchPattern("abcdefy", loc:0) == 0)

    XCTAssertTrue("🐶".fuzzyMatchPattern("🐶") == 0)
    XCTAssertTrue("🐶🐱🐶🐶🐶".fuzzyMatchPattern("🐱") == 1)
  }

  func testWithStrongThresholdOptions() {
    let options = FuzzyMatchOptions.init(threshold: 0.0, distance: FuzzyMatchingOptionsDefaultValues.distance.rawValue)
    XCTAssertTrue("abcdef".fuzzyMatchPattern("abcdef", loc:0, options:options) == 0)
    XCTAssertTrue("a large block of text with no occurance of the last two letters of the alphabet".fuzzyMatchPattern("yz", loc:0, options:options) == nil)
    XCTAssertTrue("Brevity is the soul of wit".fuzzyMatchPattern("Hamlet", loc:0, options:options) == nil)
    XCTAssertTrue("abcdef".fuzzyMatchPattern("g", loc:0, options:options) == nil)
  }
  
  func testWithWeakThresholdOptions() {
    var options = FuzzyMatchOptions.init(threshold: 1.0, distance: FuzzyMatchingOptionsDefaultValues.distance.rawValue)
    XCTAssertTrue("abcdef".fuzzyMatchPattern("abcdef", loc:0, options:options) == 0)
    XCTAssertTrue("abcdef".fuzzyMatchPattern("g", loc:0, options:options) == nil)
    options.threshold = 0.8
    XCTAssertTrue("'Twas brillig, and the slithy toves Did gyre and gimble in the wabe. All mimsy were the borogroves, And the mome raths outgrabe.".fuzzyMatchPattern("slimy tools", loc:30) == 23)
  }

  func testWithDistanceOptions() {
    let options = FuzzyMatchOptions.init(threshold: FuzzyMatchingOptionsDefaultValues.threshold.rawValue, distance: 1.0)
    XCTAssertTrue("abcdef".fuzzyMatchPattern("abcdef", loc:0, options:options) == 0)
    XCTAssertTrue("abcdef".fuzzyMatchPattern("fff", loc:0, options:options) == nil)
  }
  
  func testSpeedUpBySearchingForSubstringFound() {
    let speedUpBySearchingForSubstring = "abcdef".speedUpBySearchingForSubstring("bc", loc:0, threshold:0.5, distance:1000.0)
    XCTAssertTrue(speedUpBySearchingForSubstring.bestLoc == 1)
    XCTAssertTrue(speedUpBySearchingForSubstring.threshold == 0.5)
  }
  
  func testSpeedUpBySearchingForSubstringFoundDoubleByte() {
    let speedUpBySearchingForSubstring = "🐶🐱🐶🐶🐶".speedUpBySearchingForSubstring("🐱", loc:0, threshold:0.5, distance:1000.0)
    XCTAssertTrue(speedUpBySearchingForSubstring.bestLoc == 1)
    XCTAssertTrue(speedUpBySearchingForSubstring.threshold == 0.5)
  }
  
  func testSpeedUpBySearchingForSubstringNotFound() {
    let speedUpBySearchingForSubstring = "abcdef".speedUpBySearchingForSubstring("ggg", loc:0, threshold:0.5, distance:1000.0)
    XCTAssertTrue(speedUpBySearchingForSubstring.bestLoc == nil)
    XCTAssertTrue(speedUpBySearchingForSubstring.threshold == 0.5)
  }
  
  func testSpeedUpBySearchingForSubstringNotFoundDoubleByte() {
    let speedUpBySearchingForSubstring = "🐱🐱🐱".speedUpBySearchingForSubstring("🐭", loc:0, threshold:0.5, distance:1000.0)
    XCTAssertTrue(speedUpBySearchingForSubstring.bestLoc == nil)
    XCTAssertTrue(speedUpBySearchingForSubstring.threshold == 0.5)
  }
  
  func testConfidence() {
    let one = "Stacee Lima".confidenceScore("SL")
    let two = "abcdef".confidenceScore("g")
    let three = "🐶🐱🐶🐶🐶".confidenceScore("🐱")
    let four = "🐶🐱🐶🐶🐶".confidenceScore("🐱🐱🐱🐱🐱")
    
    XCTAssertTrue(one == 0.5)
    XCTAssertTrue(two == nil)
    XCTAssertTrue(three == 0.001)
    XCTAssertTrue(four == 0.8)
  }
  
  func testLongerText() {
    // Support both SPM and CocoaPods bundle access
    let bundle: Bundle
    #if SWIFT_PACKAGE
      bundle = Bundle.module
    #else
      bundle = Bundle(for: type(of: self))
    #endif

    guard let path = bundle.path(forResource: "desolation_row", ofType: "txt") else {
      XCTFail("Could not find desolation_row.txt resource")
      return
    }

    do {
      let desolationRow = String.init(data: try Data(contentsOf: URL(fileURLWithPath: path)), encoding: String.Encoding.utf8)!
      
      let firstWord = desolationRow.fuzzyMatchPattern("They're")
      let secondWord = desolationRow.fuzzyMatchPattern("selling")
      let secondLine = desolationRow.fuzzyMatchPattern("The beauty parlor")
      
      let options = FuzzyMatchOptions.init(threshold:0.5, distance:Double(10000))
      
      let eliot = desolationRow.fuzzyMatchPattern("T.S. Eliot", loc: 0, options: options)
      
      XCTAssertTrue(firstWord == 0)
      XCTAssertTrue(secondWord == 8)
      XCTAssertTrue(secondLine == 79)
      XCTAssertTrue(eliot == 3061)
    } catch _ {
      XCTAssertTrue(1 == 0)
    }
  }
}
