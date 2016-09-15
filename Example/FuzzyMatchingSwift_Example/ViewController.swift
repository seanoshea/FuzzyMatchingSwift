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

import UIKit

import FuzzyMatchingSwift

class ViewController: UIViewController {
  
  @IBOutlet weak var fuzzySampleText:UITextView!
  @IBOutlet weak var fuzzyPattern:UITextField!
  @IBOutlet weak var fuzzyLocation:UITextField!
  @IBOutlet weak var fuzzyDistance:UITextField!
  @IBOutlet weak var fuzzyThreshold:UITextField!
  @IBOutlet weak var fuzzyMatchResult:UILabel!
  
  @IBAction func fuzzyMatchButtonTappedWithSender(sender: UIButton) {
    let threshold = Double(self.fuzzyThreshold.text!)!
    let distance = Double(self.fuzzyDistance.text!)!
    let sampleText = self.fuzzySampleText.text!
    let pattern = self.fuzzyPattern.text!
    let location = Int(self.fuzzyLocation.text!)!
    let options = FuzzyMatchOptions.init(threshold: threshold, distance: distance)
    
    if let result = sampleText.fuzzyMatchPattern(pattern, loc:location, options:options) {
      self.fuzzyMatchResult.text = "Found at \(result)"
    } else {
      self.fuzzyMatchResult.text = "Not Found"
    }
  }
}
