//
//  CsvManager.swift
//  MMR-Swift-Tutorial
//
//  Created by Almina on 2021/02/22.
//  Copyright © 2021 Almina. All rights reserved.
//

import Cocoa
import Foundation

class CsvManager: NSObject {
  
  private(set) var isRecording = false
  //  private var headerText = "timestamp,accX,accY,accZ,gyroX,gyroY,gyroZ"
  private var headerText = "timestamp,accX,accY,accZ"
  private var recordText = ""
  private var fileName = ""
  
  var format = DateFormatter()
  var isError = false
  var upperFreq: Int = 50
  var lowerFreq: Int = 50
  var failedCount = 0
  var samplingCount = 0
  
  var timestamp = Date()
  var textBuff = [String]()
  
  // public weak var svc:SensorViewController!
  
  override init() {
    format.dateFormat = "yyyyMMddHHmmssSSS"
  }
  
  func startRecording() {
    recordText = ""
    recordText += headerText + "\n"
    isRecording = true
    isError = false
    failedCount = 0
    samplingCount = 0
    timestamp = Date()
  }
  
  func stopRecording() { isRecording = false }
  
  func setSampleFrequency(setUpperFreq:String, setLowerFreq:String) {
    print("change sample frequency...")
    upperFreq = Int(setUpperFreq)!
    lowerFreq = Int(setLowerFreq)!
  }
  
  func addRecordText(addText:String) { recordText += addText + "\n" }
  
  func addRecordBuffer(addText:String) {
    if self.isRecording { textBuff.append(addText) }
    
    // store sampled data per 1sec
    let elapsedTime = NSDate().timeIntervalSince(timestamp)
    //    print(elapsedTime)
    if elapsedTime > 1 {
      self.addRecordTextArray(addTextArray: textBuff)
      textBuff.removeAll()
      timestamp = Date()
    }
  }
  
  func addRecordTextArray(addTextArray:[String]) {
    //      let sampleFreq = 50
    //    if addTextArray.count >= upperFreq {
    //      // sampling
    //      var index: Float = 0.0
    //      let period: Float = Float(addTextArray.count-1) / Float(upperFreq-1)
    //      for _ in 1...upperFreq {
    //        recordText += addTextArray[Int(index)] + "\n"
    //        index += period
    //      }
    //      samplingCount += upperFreq
    //    } else if addTextArray.count >= lowerFreq {
    //      // not sampling (record as raw)
    //      for i in 0...addTextArray.count-1 { recordText += addTextArray[i] + "\n" }
    //      samplingCount += addTextArray.count
    //    } else {
    //      // not recording
    //      isError = true
    //      failedCount += 1
    //      print("======")
    //      print("failed!: " + String(addTextArray.count))
    //      print(addTextArray[0])
    //      print(addTextArray[addTextArray.count-1])
    //    }
    
    if addTextArray.count >= upperFreq {
      // sampling
      var index: Float = 0.0
      let period: Float = Float(addTextArray.count-1) / Float(upperFreq-1)
      for _ in 1...upperFreq {
        recordText += addTextArray[Int(index)] + "\n"
        index += period
      }
      samplingCount += upperFreq
    } else {
      // not sampling (record as raw)
      for i in 0...addTextArray.count-1 { recordText += addTextArray[i] + "\n" }
      samplingCount += addTextArray.count
    }
  }
  
  func setHeaderText(setText: String) { headerText = setText }
  func setFileNameText(setText: String) { fileName = setText }
  
  func saveSensorDataToCsv() {
    // ドキュメントディレクトリの「パス」（String型）定義
    if let documentDirectoryFileURL = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last {
      format.dateFormat = "yyyy-MMdd-HHmmss"
      var targetTextFilePath = ""
      if (isError) {
        // if there is something error in recording data, change filename!
        targetTextFilePath = documentDirectoryFileURL + "/" + format.string(from: Date()) + "-" + fileName + "-error-" + "\(failedCount)" + ".csv"
      } else {
        // 書き込むファイルのパス
        targetTextFilePath = documentDirectoryFileURL + "/" + format.string(from: Date()) + "-" + fileName + ".csv"
      }
      
      do{
        try recordText.write(toFile: targetTextFilePath, atomically: false, encoding: String.Encoding.utf8)
        print("Success to Write CSV")
      }catch let error as NSError{
        print("Failure to Write CSV\n\(error)")
      }
    }
  }
}
