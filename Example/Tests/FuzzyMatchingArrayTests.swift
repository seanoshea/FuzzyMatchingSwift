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

class FuzzyMatchingArrayTests: XCTestCase {

  func testMatchingStringsInArraysWithoutOptions() {
    let first = ["one", "two", "three"].sortedByFuzzyMatchPattern("on")
    let second = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"].sortedByFuzzyMatchPattern("on")
      
    XCTAssert(first[0] == "one")
    XCTAssert(first[1] == "two")
      
    XCTAssert(second[0] == "one")
    XCTAssert(second[1] == "two")
    XCTAssert(second[2] == "four")
    XCTAssert(second[3] == "seven")
    XCTAssert(second[4] == "nine")
    XCTAssert(second[5] == "ten")
  }
  
  func testMatchingStringsInArraysWithOptions() {
    let first = ["one", "two", "three"].sortedByFuzzyMatchPattern("on", loc: 0, distance: 1000.0)
    let second = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"].sortedByFuzzyMatchPattern("on", loc: 10, distance: 1.0)
    
    XCTAssert(first[0] == "one")
    XCTAssert(first[1] == "two")
    
    XCTAssert(second[0] == "two")
    XCTAssert(second[1] == "seven")
    XCTAssert(second[2] == "ten")
    XCTAssert(second[3] == "one")
    XCTAssert(second[4] == "three")
    XCTAssert(second[5] == "four")
    XCTAssert(second[6] == "five")
    XCTAssert(second[7] == "six")
    XCTAssert(second[8] == "eight")
    XCTAssert(second[9] == "nine")
  }
}
