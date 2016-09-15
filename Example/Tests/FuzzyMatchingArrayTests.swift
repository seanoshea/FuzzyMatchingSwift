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
    let fourth = ["one", "one", "two"]
      
    XCTAssert(first[0] == "one")
    XCTAssert(first[1] == "two")
    XCTAssert(first.count == 3)
      
    XCTAssert(second[0] == "one")
    XCTAssert(second[1] == "nine")
    XCTAssert(second[2] == "two")
    XCTAssert(second[3] == "four")
    XCTAssert(second[4] == "seven")
    XCTAssert(second[5] == "ten")
    XCTAssert(second.count == 10)
    
    XCTAssert(third[0] == "one")
    XCTAssert(third.count == 1)
    
    XCTAssert(fourth[0] == "one")
    XCTAssert(fourth[1] == "one")
    XCTAssert(fourth[2] == "two")
    XCTAssert(fourth.count == 3)
  }
  
  func testMatchingStringsInArraysWithOptions() {
    let first = ["one", "two", "three"].sortedByFuzzyMatchPattern("on", loc: 0, distance: 1000.0)
    let second = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"].sortedByFuzzyMatchPattern("on", loc: 0, distance: 1.0)
    let third = ["one", "two", "three"].sortedByFuzzyMatchPattern("on")
    
    XCTAssert(first[0] == "one")
    XCTAssert(first[1] == "two")
    
    XCTAssert(second[0] == "one")
    XCTAssert(second[1] == "nine")
    XCTAssert(second[2] == "two")
    XCTAssert(second[3] == "three")
    XCTAssert(second[4] == "four")
    XCTAssert(second[5] == "five")
    XCTAssert(second[6] == "six")
    XCTAssert(second[7] == "seven")
    XCTAssert(second[8] == "eight")
    XCTAssert(second[9] == "ten")
    
    XCTAssert(third == first)
  }
  
  func testLongArray() {
    let path = Bundle(for: type(of: self)).path(forResource: "desolation_row", ofType: "txt")!
    let desolationRow = String.init(data: try! Data(contentsOf: URL(fileURLWithPath: path)), encoding: String.Encoding.utf8)!
    let array = desolationRow.characters.split{$0 == " "}.map(String.init)

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
  }
  
  func testPerformance() {
    measureMetrics(type(of: self).defaultPerformanceMetrics(), automaticallyStartMeasuring:true, for:{
      let _ = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"].sortedByFuzzyMatchPattern("on", loc: 0, distance: 1000.0)
      self.stopMeasuring()
    });
  }
}
