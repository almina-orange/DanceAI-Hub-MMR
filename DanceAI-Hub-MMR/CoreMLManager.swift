//
//  CoreMLManager.swift
//  DanceAI-Hub-MMR
//
//  Created by Almina on 2021/04/30.
//  Copyright © 2021 Almina. All rights reserved.
//

import Foundation
import CoreML

class CoreMLManager {
  
  public weak var vc:ViewController!
  
  var r_datas = [String]()
  var l_datas = [String]()
  var timestamp = Date()
  
  let sampleFreq: Int = 50
  let inputDataLength = 50 * 6
  var compAccArray = [Double]()
  var compAccStringArray = [String]()
  var outputLabelString = ""
  var classLabel = ""
  var predictionCount = 0
  var isDetecting = true
  
  init() {
    
  }
  
  func reset() {
    timestamp = Date()
    predictionCount = 0
    classLabel = ""
    
    r_datas.removeAll()
    l_datas.removeAll()
    compAccArray.removeAll()
    compAccStringArray.removeAll()
  }
  
  func update() {
    let elapsedTime = NSDate().timeIntervalSince(timestamp)
    if elapsedTime > 1 {
      //      vc.format.dateFormat = "MM-dd HH:mm:ssSS"
      //      print(vc.format.string(from: timestamp) + ": predict")
      self.predict()
      timestamp = Date()
    }
  }
  
  func pushRightData(addData: String) { r_datas.append(addData) }
  func pushLeftData(addData: String) { l_datas.append(addData) }
  
  func predict() {
    // CoreML prediction
    if (r_datas.count >= 50 && l_datas.count >= 50) {
      parseInputArray(rTextArray: r_datas, lTextArray: l_datas)
      filterInputArray()
      
      //      // [tmp] send all prediction
      //      getCoremlOutputIndex(index: 0)
      //      sendModelOutputIndex(index: "step")
      //      getCoremlOutputIndex(index: 1)
      //      sendModelOutputIndex(index: "move1")
      //      getCoremlOutputIndex(index: 2)
      //      sendModelOutputIndex(index: "move2")
      //      getCoremlOutputIndex(index: 3)
      //      sendModelOutputIndex(index: "move3")
      
      getCoremlOutput()
      
      displayModelOutput()
      sendModelOutput()
      
      //      print(compAccStringArray[0])
      //      print(outputLabelString)
      
      //      recordCoremlInput()
      //      recordCoremlOutput()
      
      r_datas.removeAll()
      l_datas.removeAll()
      compAccArray.removeAll()
      compAccStringArray.removeAll()
    }
  }
  
  func displayModelOutput(){
    let text = String(format: "%3d", predictionCount) + ": " + classLabel + "\n"
    vc.modelOutputLabel.stringValue = text
  }
  
  func sendModelOutput(){
    oscManager.sendStringMessage(address: "/Hub/detect/label", arguments: [classLabel])
    oscManager.sendFloatMessage(address: "/Hub/detect/prob", arguments: outputLabelString.components(separatedBy: ","))
    print(classLabel)
    print(outputLabelString)
  }
  
  func sendModelOutputIndex(index: String){
    //    vc.oscManager.sendStringMessage(address: "/Hub/detect/\(index)/label", arguments: [classLabel])
    //    vc.oscManager.sendFloatMessage(address: "/Hub/detect/\(index)/prob", arguments: outputLabelString.components(separatedBy: ","))
  }
  
  // [tmp] for
  //  func getCoremlOutputIndex(index: Int){
  //    // store sensor data in array for CoreML model
  //    let dataNum = NSNumber(value: inputDataLength)
  //    let mlarray = try! MLMultiArray(shape: [dataNum], dataType: MLMultiArrayDataType.double )
  //
  //    for (index, data) in compAccArray.enumerated(){
  //      mlarray[index] = data as NSNumber
  //    }
  //
  //    // input data to CoreML model
  //    if (index == 0) {
  //      let model = model_arduino_both()
  //      guard let output = try? model.prediction(input:
  //        model_arduino_bothInput(input1: mlarray)) else {
  //          fatalError("Unexpected runtime error.")
  //      }
  //      classLabel = output.classLabel
  //
  //      var addText = ""
  //      vc.format.dateFormat = "MMddHHmmssSS"
  //      addText += vc.format.string(from: Date()) + ","
  //      addText += String(output.output1["TopRock"]!) + ","
  //      addText += String(output.output1["SalsaRock"]!) + ","
  //      addText += String(output.output1["IndianStep"]!) + ","
  //      addText += String(output.output1["SixStep"]!) + ","
  //      addText += String(output.output1["FourStep"]!) + ","
  //      addText += String(output.output1["ThreeStep"]!) + ","
  //      addText += String(output.output1["TwoStep"]!) + ","
  //      addText += String(output.output1["CC"]!) + ","
  //      addText += String(output.output1["Stop"]!)
  //      outputLabelString = addText
  //    } else if (index == 1) {
  //      let model = model_arduino_both_hirasawa()
  //      guard let output = try? model.prediction(input:
  //        model_arduino_both_hirasawaInput(input1: mlarray)) else {
  //          fatalError("Unexpected runtime error.")
  //      }
  //      classLabel = output.classLabel
  //
  //      var addText = ""
  //      vc.format.dateFormat = "MMddHHmmssSS"
  //      addText += vc.format.string(from: Date()) + ","
  //      addText += String(output.output1["original1"]!) + ","
  //      addText += String(output.output1["original2"]!) + ","
  //      addText += String(output.output1["original3"]!) + ","
  //      addText += String(output.output1["Stop"]!)
  //      outputLabelString = addText
  //    } else if (index == 2) {
  //      let model = model_arduino_both_shimizu()
  //      guard let output = try? model.prediction(input:
  //        model_arduino_both_shimizuInput(input1: mlarray)) else {
  //          fatalError("Unexpected runtime error.")
  //      }
  //      classLabel = output.classLabel
  //
  //      var addText = ""
  //      vc.format.dateFormat = "MMddHHmmssSS"
  //      addText += vc.format.string(from: Date()) + ","
  //      addText += String(output.output1["original1"]!) + ","
  //      addText += String(output.output1["original2"]!) + ","
  //      addText += String(output.output1["original3"]!) + ","
  //      addText += String(output.output1["Stop"]!)
  //      outputLabelString = addText
  //    } else if (index == 3) {
  //      let model = model_arduino_both_silent()
  //      guard let output = try? model.prediction(input:
  //        model_arduino_both_silentInput(input1: mlarray)) else {
  //          fatalError("Unexpected runtime error.")
  //      }
  //      classLabel = output.classLabel
  //
  //      var addText = ""
  //      vc.format.dateFormat = "MMddHHmmssSS"
  //      addText += vc.format.string(from: Date()) + ","
  //      addText += String(output.output1["original1"]!) + ","
  //      addText += String(output.output1["original2"]!) + ","
  //      addText += String(output.output1["original3"]!) + ","
  //      addText += String(output.output1["Stop"]!)
  //      outputLabelString = addText
  //    }
  //  }
  
  func getCoremlOutput(){
    // store sensor data in array for CoreML model
    let dataNum = NSNumber(value: inputDataLength)
    let mlarray = try! MLMultiArray(shape: [dataNum], dataType: MLMultiArrayDataType.double )
    
    for (index, data) in compAccArray.enumerated(){
      mlarray[index] = data as NSNumber
    }
    
    //    let model = model_arduino_both()
    //    guard let output = try? model.prediction(input:
    //      model_arduino_bothInput(input1: mlarray)) else {
    //        fatalError("Unexpected runtime error.")
    //    }
    //    let model = model_arduino_both_hirasawa_v2()
    //    guard let output = try? model.prediction(input:
    //      model_arduino_both_hirasawa_v2Input(input1: mlarray)) else {
    //        fatalError("Unexpected runtime error.")
    //    }
    //    let model = model_arduino_both_shimizu_v2()
    //    guard let output = try? model.prediction(input:
    //      model_arduino_both_hirasawa_v2Input(input1: mlarray)) else {
    //        fatalError("Unexpected runtime error.")
    //    }
    //    let model = model_arduino_both_silent_v2()
    //    guard let output = try? model.prediction(input:
    //      model_arduino_both_hirasawa_v2Input(input1: mlarray)) else {
    //        fatalError("Unexpected runtime error.")
    //    }
    //    let model = model_arduino_both_all_v2()
    //    guard let output = try? model.prediction(input:
    //      model_arduino_both_all_v2Input(input1: mlarray)) else {
    //        fatalError("Unexpected runtime error.")
    //    }
    
    if (vc.modelSelectPopUpButton.titleOfSelectedItem! == "step detection") {
      let model = model_arduino_both()
      guard let output = try? model.prediction(input:
        model_arduino_bothInput(input1: mlarray)) else {
          fatalError("Unexpected runtime error.")
      }
      classLabel = output.classLabel
      
      var addText = ""
      addText  = String(Int(NSDate().timeIntervalSince1970 * 1000.0)) + ","
      addText += String(output.output1["TopRock"]!) + ","
      addText += String(output.output1["SalsaRock"]!) + ","
      addText += String(output.output1["IndianStep"]!) + ","
      addText += String(output.output1["SixStep"]!) + ","
      addText += String(output.output1["FourStep"]!) + ","
      addText += String(output.output1["ThreeStep"]!) + ","
      addText += String(output.output1["TwoStep"]!) + ","
      addText += String(output.output1["CC"]!) + ","
      addText += String(output.output1["Stop"]!)
      outputLabelString = addText
    //    } else if (vc.ModelSelectPopUpButton.titleOfSelectedItem! == "move classification: hirasawa") {
    //      let model = model_arduino_both_hirasawa_v2()
    //      guard let output = try? model.prediction(input:
    //        model_arduino_both_hirasawa_v2Input(input1: mlarray)) else {
    //          fatalError("Unexpected runtime error.")
    //      }
    //      classLabel = output.classLabel
    //    } else if (vc.ModelSelectPopUpButton.titleOfSelectedItem! == "move classification: shimizu") {
    //      let model = model_arduino_both_shimizu_v2()
    //      guard let output = try? model.prediction(input:
    //        model_arduino_both_shimizu_v2Input(input1: mlarray)) else {
    //          fatalError("Unexpected runtime error.")
    //      }
    //      classLabel = output.classLabel
    //    } else if (vc.ModelSelectPopUpButton.titleOfSelectedItem! == "move classification: silent") {
    //      let model = model_arduino_both_silent_v2()
    //      guard let output = try? model.prediction(input:
    //        model_arduino_both_silent_v2Input(input1: mlarray)) else {
    //          fatalError("Unexpected runtime error.")
    //      }
    //      classLabel = output.classLabel
    //    } else if (vc.ModelSelectPopUpButton.titleOfSelectedItem! == "move classification: all") {
    //      let model = model_arduino_both_all_v2()
    //      guard let output = try? model.prediction(input:
    //        model_arduino_both_all_v2Input(input1: mlarray)) else {
    //          fatalError("Unexpected runtime error.")
    //      }
    //      classLabel = output.classLabel
    } else {
      let model = model_arduino_both()
      guard let output = try? model.prediction(input:
        model_arduino_bothInput(input1: mlarray)) else {
          fatalError("Unexpected runtime error.")
      }
      classLabel = output.classLabel
    }
    predictionCount += 1
  }
  
  func recordCoremlInput(){
    //    vc.coreML_input_csvManager.addRecordTextArray(addTextArray: compAccStringArray)
  }
  
  func recordCoremlOutput(){
    //    vc.coreML_output_csvManager.addRecordText(addText: outputLabelString)
  }
  
  func parseInputArray(rTextArray:[String], lTextArray:[String]){
    var rAccArray = [Double]()
    var lAccArray = [Double]()
    var index: Float
    var period: Float
    
    // sampling right acc datas
    index = 0.0
    period = Float(rTextArray.count-1) / Float(sampleFreq-1)
    for _ in 1...sampleFreq {
      let arr:[String] = rTextArray[Int(index)].components(separatedBy: ",")
      rAccArray.append(Double(arr[1])!)  // acc x
      rAccArray.append(Double(arr[2])!)  // acc y
      rAccArray.append(Double(arr[3])!)  // acc z
      index += period
    }
    
    // sampling left acc datas
    index = 0.0
    period = Float(lTextArray.count-1) / Float(sampleFreq-1)
    for _ in 1...sampleFreq {
      let arr:[String] = lTextArray[Int(index)].components(separatedBy: ",")
      lAccArray.append(Double(arr[1])!)  // acc x
      lAccArray.append(Double(arr[2])!)  // acc y
      lAccArray.append(Double(arr[3])!)  // acc z
      index += period
    }
    
    // merge acc datas
    for ii in 0...sampleFreq-1 {
      compAccArray.append(lAccArray[ii*3+0])
      compAccArray.append(lAccArray[ii*3+1])
      compAccArray.append(lAccArray[ii*3+2])
      compAccArray.append(rAccArray[ii*3+0])
      compAccArray.append(rAccArray[ii*3+1])
      compAccArray.append(rAccArray[ii*3+2])
      
      //      var addText = ""
      //      vc.format.dateFormat = "MMddHHmmssSS"
      //      addText += vc.format.string(from: Date()) + ","
      //      addText += String(lAccArray[ii*3+0]) + ","
      //      addText += String(lAccArray[ii*3+1]) + ","
      //      addText += String(lAccArray[ii*3+2]) + ","
      //      addText += String(rAccArray[ii*3+0]) + ","
      //      addText += String(rAccArray[ii*3+1]) + ","
      //      addText += String(rAccArray[ii*3+2])
      //      compAccStringArray.append(addText)
    }
  }
  
  func filterInputArray(){
    var diff: Double = 0.0
    for ii in 0...(compAccArray.count-6)-1 { diff += fabs(compAccArray[ii+6] - compAccArray[ii]) }
    
    // considered to stopped if displacement of acceleration is less than threshold
    if (diff < vc.stopThresholdSlider.doubleValue) {
      for ii in 0...compAccArray.count/6-1 {
        compAccArray[ii*6+0] =  0.0
        compAccArray[ii*6+1] =  1.0
        compAccArray[ii*6+2] =  0.0
        compAccArray[ii*6+3] =  0.0
        compAccArray[ii*6+4] = -1.0
        compAccArray[ii*6+5] =  0.0
      }
    }
  }
}


