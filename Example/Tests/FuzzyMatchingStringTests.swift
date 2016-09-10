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

import FuzzyMatchingSwift
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
    XCTAssertTrue("abcdef".fuzzyMatchPattern("de", loc:3) == 3)
    XCTAssertTrue("abcdef".fuzzyMatchPattern("defy", loc:4) == 3)
    XCTAssertTrue("abcdef".fuzzyMatchPattern("abcdefy", loc:0) == 0)
    
    XCTAssertTrue("🐶".fuzzyMatchPattern("🐶") == 0)
    XCTAssertTrue("🐶🐱🐶🐶🐶".fuzzyMatchPattern("🐱") == 1)
  }

  func testWithStrongThresholdOptions() {
    let options = FuzzyMatchOptions.init(threshold: 0.0, distance: 0)
    XCTAssertTrue("abcdef".fuzzyMatchPattern("abcdef", loc:0, options:options) == 0)
    XCTAssertTrue("a large block of text with no occurance of the last two letters of the alphabet".fuzzyMatchPattern("yz", loc:0, options:options) == nil)
    XCTAssertTrue("Brevity is the soul of wit".fuzzyMatchPattern("Hamlet", loc:0, options:options) == nil)
    XCTAssertTrue("abcdef".fuzzyMatchPattern("g", loc:0, options:options) == nil)
    XCTAssertTrue("Brevity is the soul of wit".fuzzyMatchPattern("Hamlet", loc:0, options:options) == nil)
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
    XCTAssertTrue(speedUpBySearchingForSubstring.bestLoc == NSNotFound)
    XCTAssertTrue(speedUpBySearchingForSubstring.threshold == 0.5)
  }
  
  func testSpeedUpBySearchingForSubstringNotFoundDoubleByte() {
    let speedUpBySearchingForSubstring = "🐱🐱🐱".speedUpBySearchingForSubstring("🐭", loc:0, threshold:0.5, distance:1000.0)
    XCTAssertTrue(speedUpBySearchingForSubstring.bestLoc == NSNotFound)
    XCTAssertTrue(speedUpBySearchingForSubstring.threshold == 0.5)
  }
}
