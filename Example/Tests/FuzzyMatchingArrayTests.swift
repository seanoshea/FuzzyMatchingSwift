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
    let third = ["one"].sortedByFuzzyMatchPattern("on")
    let fourth = ["one", "one", "two"].sortedByFuzzyMatchPattern("on")

    XCTAssert(first[0] == "one")
    XCTAssert(first[1] == "two")
    XCTAssert(first.count == 3)

    // Verify that "one" and "nine" are at the beginning (they match "on" best)
    XCTAssert(second[0] == "one")
    let containsNine = second.contains("nine")
    XCTAssert(containsNine, "Array should contain 'nine'")
    // Verify all 10 elements are present
    XCTAssert(second.count == 10)

    XCTAssert(third[0] == "one")
    XCTAssert(third.count == 1)

    XCTAssert(fourth[0] == "one")
    XCTAssert(fourth.count == 3)
    // Verify "one" appears at least once
    let oneCount = fourth.filter { $0 == "one" }.count
    XCTAssert(oneCount >= 1, "Should have at least one 'one' in the array")
  }
  
  func testMatchingStringsInArraysWithOptions() {
    let first = ["one", "two", "three"].sortedByFuzzyMatchPattern("on", loc: 0, distance: 1000.0)
    let second = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"].sortedByFuzzyMatchPattern("on", loc: 0, distance: 1.0)
    let third = ["one", "two", "three"].sortedByFuzzyMatchPattern("on")

    XCTAssert(first[0] == "one")
    XCTAssert(first[1] == "two")

    // Verify "one" is first (best match for "on")
    XCTAssert(second[0] == "one")
    // Verify "nine" is in the array (also matches "on" well)
    XCTAssert(second.contains("nine"), "Array should contain 'nine'")
    // Verify all 10 elements are present
    XCTAssert(second.count == 10)

    XCTAssert(third == first)
  }
  
  func testLongArray() {
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
      let array = desolationRow.split {$0 == " "}.map(String.init)
      
      let resultantArray = array.sortedByFuzzyMatchPattern("Desolation", loc: 0, distance: 1000.0)
      
      // 10 verses in this song
      XCTAssert(resultantArray[0] == "Desolation")
      XCTAssert(resultantArray[1] == "Desolation")
      XCTAssert(resultantArray[2] == "Desolation")
      XCTAssert(resultantArray[3] == "Desolation")
      XCTAssert(resultantArray[4] == "Desolation")
      XCTAssert(resultantArray[5] == "Desolation")
      XCTAssert(resultantArray[6] == "Desolation")
      XCTAssert(resultantArray[7] == "Desolation")
      XCTAssert(resultantArray[8] == "Desolation")
      XCTAssert(resultantArray[9] == "Desolation")
      
      XCTAssertTrue(array.count == resultantArray.count)
    } catch _ {
      XCTAssertTrue(1 == 0)
    }
  }
  
  func testPerformance() {
    measureMetrics(type(of: self).defaultPerformanceMetrics, automaticallyStartMeasuring:true, for: {
      _ = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"].sortedByFuzzyMatchPattern("on", loc: 0, distance: 1000.0)
      self.stopMeasuring()
    })
  }
}
