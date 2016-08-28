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
