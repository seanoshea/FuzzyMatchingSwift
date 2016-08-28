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

class FuzzyMatchingStringTests: XCTestCase {

    func testWithoutOptions() {
      XCTAssertTrue("abcdef".fuzzyMatchPattern("abcdef", loc:0, options:nil) == 0)
      XCTAssertTrue("".fuzzyMatchPattern("abcdef", loc:1, options:nil) == NSNotFound)
      XCTAssertTrue("abcdef".fuzzyMatchPattern("", loc:3, options:nil) == NSNotFound)
      XCTAssertTrue("abcdef".fuzzyMatchPattern("de", loc:3, options:nil) == 3)
      XCTAssertTrue("abcdef".fuzzyMatchPattern("defy", loc:4, options:nil) == 4)
      XCTAssertTrue("abcdef".fuzzyMatchPattern("abcdefy", loc:0, options:nil) == 0)
      XCTAssertTrue("I am the very model of a modern major general.".fuzzyMatchPattern(" that berry ", loc:5, options:nil) == 5)
      XCTAssertTrue("'Twas brillig, and the slithy toves Did gyre and gimble in the wabe. All mimsy were the borogroves, And the mome raths outgrabe.".fuzzyMatchPattern("slimy tools", loc:30, options:nil) == 30)
    }

  func testWithThresholdOptions() {
    let options = [FuzzyMatchingOptionsParams.threshold.rawValue : 1.0]
    XCTAssertTrue("abcdef".fuzzyMatchPattern("abcdef", loc:0, options:options) == 0)
    XCTAssertTrue("abcdef".fuzzyMatchPattern("g", loc:0, options:options) == NSNotFound)
  }

  func testWithDistanceOptions() {
    let options = [FuzzyMatchingOptionsParams.distance.rawValue : 1.0]
    XCTAssertTrue("abcdef".fuzzyMatchPattern("abcdef", loc:0, options:options) == 0)
    XCTAssertTrue("abcdef".fuzzyMatchPattern("fff", loc:0, options:options) == NSNotFound)
  }
}
