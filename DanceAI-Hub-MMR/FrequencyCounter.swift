//
//  FrequencyCounter.swift
//  MMR-Swift-Tutorial
//
//  Created by Almina on 2021/03/09.
//  Copyright © 2021 Almina. All rights reserved.
//

import Foundation

class FrequencyCounter: NSObject {
  var freq = 0 as Float
  var timestamp = Date()
  var counter = 0
  var difNumCounter = 0
  var isFreqValueUpdated = false
  
  func initValues(){
    freq = 0
    timestamp = Date()
    counter = 0
    difNumCounter = 0
  }
  
  func update(){
    isFreqValueUpdated = false
    counter += 1
    let elapsedTime = NSDate().timeIntervalSince(timestamp)
    if elapsedTime > 2{
      freq = Float(counter)/Float(elapsedTime)
      counter = 0
      difNumCounter = 0
      isFreqValueUpdated = true
      timestamp = Date()
    }
  }
}
