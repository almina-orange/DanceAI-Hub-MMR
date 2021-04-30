//
//  ViewController.swift
//  MMR-Swift-Tutorial
//
//  Created by Almina on 2021/02/17.
//  Copyright © 2021 Almina. All rights reserved.
//

import Cocoa
import MetaWear
import MetaWearCpp

// MARK:
//   The following method may cause serious errors.
//   It is recommended to use another method.
var vc: ViewController!
var L_freqCounter = FrequencyCounter()
var R_freqCounter = FrequencyCounter()

var L_accTextBuff: String = "" {
  didSet { DispatchQueue.main.async { vc.charaLabel.stringValue = L_accTextBuff } }
}
var L_gyroTextBuff: String = "" {
  didSet { DispatchQueue.main.async { vc.charaLabel2.stringValue = L_gyroTextBuff } }
}
var R_accTextBuff: String = "" {
  didSet { DispatchQueue.main.async { vc.charaLabel3.stringValue = R_accTextBuff } }
}
var R_gyroTextBuff: String = "" {
  didSet { DispatchQueue.main.async { vc.charaLabel4.stringValue = R_gyroTextBuff } }
}

var L_raw_accRecordTextBuff: String = "" {
  didSet { DispatchQueue.main.async {
    if vc.L_raw_csvMng.isRecording { vc.L_raw_csvMng.addRecordText(addText: L_raw_accRecordTextBuff) }
  } }
}
var R_raw_accRecordTextBuff: String = "" {
  didSet { DispatchQueue.main.async {
    if vc.R_raw_csvMng.isRecording { vc.R_raw_csvMng.addRecordText(addText: R_raw_accRecordTextBuff) }
  } }
}
var L_accRecordTextBuff: String = "" {
  didSet { DispatchQueue.main.async{
    if vc.L_csvMng.isRecording { vc.L_csvMng.addRecordBuffer(addText: L_accRecordTextBuff) }
  } }
}
var R_accRecordTextBuff: String = "" {
  didSet { DispatchQueue.main.async {
    if vc.R_csvMng.isRecording { vc.R_csvMng.addRecordBuffer(addText: R_accRecordTextBuff) }
  } }
}

var L_freqTextBuff: String = "" {
  didSet {
    L_freqCounter.update()
    if L_freqCounter.isFreqValueUpdated {
      var freqTextBuff = "(L) BLE Frequency: "
      freqTextBuff += String(format: "%.2f", L_freqCounter.freq)
      freqTextBuff += "Hz"
      DispatchQueue.main.async { vc.L_FreqLabel.stringValue = freqTextBuff }
    }
  }
}
var R_freqTextBuff: String = "" {
  didSet {
    R_freqCounter.update()
    if R_freqCounter.isFreqValueUpdated {
      var freqTextBuff = "(R) BLE Frequency: "
      freqTextBuff += String(format: "%.2f", R_freqCounter.freq)
      freqTextBuff += "Hz"
      DispatchQueue.main.async { vc.R_FreqLabel.stringValue = freqTextBuff }
    }
  }
}

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
  @IBOutlet weak var tableView: NSTableView!
  
  @IBOutlet weak var recordButton: NSButton!
  @IBOutlet weak var charaLabel: NSTextField!
  @IBOutlet weak var charaLabel2: NSTextField!
  @IBOutlet weak var charaLabel3: NSTextField!
  @IBOutlet weak var charaLabel4: NSTextField!
  @IBOutlet weak var L_FreqLabel: NSTextField!
  @IBOutlet weak var R_FreqLabel: NSTextField!
  
  @IBOutlet weak var L_StreamPopUpButton: NSPopUpButton!
  @IBOutlet weak var R_StreamPopUpButton: NSPopUpButton!
  @IBOutlet weak var L_StreamButton: NSButton!
  @IBOutlet weak var R_StreamButton: NSButton!
  @IBOutlet weak var L_StreamStopButton: NSButton!
  @IBOutlet weak var R_StreamStopButton: NSButton!
  
  @IBOutlet weak var filenameTextField: NSTextField!
  
  var scannerModel: ScannerModel!
  //  var L_freqCounter = FrequencyCounter()
  //  var R_freqCounter = FrequencyCounter()
  
  var debug: Bool!
  //  var format = DateFormatter()
  
  let L_raw_csvMng = CsvManager()
  let R_raw_csvMng = CsvManager()
  let L_csvMng = CsvManager()
  let R_csvMng = CsvManager()
  
  // MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.debug = true
    //    self.format.dateFormat = "yyyy-MMdd-HHmmsss"
    
    tableView.target = self
    tableView.doubleAction = #selector(ViewController.tableViewDoubleClick(sender:))
    scannerModel = ScannerModel(delegate: self)
    
    vc = self
    
    L_StreamPopUpButton.removeAllItems()
    R_StreamPopUpButton.removeAllItems()
    
    //    self.L_raw_csvMng.setFileNameText(setText: "sample1-acc")
    //    self.R_raw_csvMng.setFileNameText(setText: "sample2-acc")
    self.L_raw_csvMng.setFileNameText(setText: "MMR-left-raw")
    self.R_raw_csvMng.setFileNameText(setText: "MMR-right-raw")
    self.L_csvMng.setFileNameText(setText: "MMR-left")
    self.R_csvMng.setFileNameText(setText: "MMR-right")
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    scannerModel.isScanning = true
  }
  
  override func viewWillDisappear() {
    super.viewWillDisappear()
    scannerModel.isScanning = false
  }
  
  
  // MARK: NSTableViewDelegate
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return scannerModel.items.count
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MetaWearCell"), owner: nil) as? NSTableCellView else {
      return nil
    }
    
    let device = scannerModel.items[row].device
    let uuid = cell.viewWithTag(1) as! NSTextField
    uuid.stringValue = device.peripheral.identifier.uuidString
    print(device.peripheral.identifier.uuidString)
    
    if let rssiNumber = device.averageRSSI() {
      let rssi = cell.viewWithTag(2) as! NSTextField
      rssi.stringValue = String(Int(rssiNumber.rounded()))
    }
    
    let connected = cell.viewWithTag(3) as! NSTextField
    if device.isConnectedAndSetup {
      connected.stringValue = "Connected!"
      connected.isHidden = false
      L_StreamPopUpButton.addItem(withTitle: device.peripheral.identifier.uuidString)
      R_StreamPopUpButton.addItem(withTitle: device.peripheral.identifier.uuidString)
    } else if scannerModel.items[row].isConnecting {
      connected.stringValue = "Connecting..."
      connected.isHidden = false
    } else {
      connected.isHidden = true
    }
    
    let name = cell.viewWithTag(4) as! NSTextField
    name.stringValue = device.name
    
    //        let signal = cell.viewWithTag(5) as! NSImageView
    //        if let movingAverage = device.averageRSSI() {
    //            if movingAverage < -80.0 {
    //                signal.image = #imageLiteral(resourceName: "wifi_d1")
    //            } else if movingAverage < -70.0 {
    //                signal.image = #imageLiteral(resourceName: "wifi_d2")
    //            } else if movingAverage < -60.0 {
    //                signal.image = #imageLiteral(resourceName: "wifi_d3")
    //            } else if movingAverage < -50.0 {
    //                signal.image = #imageLiteral(resourceName: "wifi_d4")
    //            } else if movingAverage < -40.0 {
    //                signal.image = #imageLiteral(resourceName: "wifi_d5")
    //            } else {
    //                signal.image = #imageLiteral(resourceName: "wifi_d6")
    //            }
    //        } else {
    //            signal.image = #imageLiteral(resourceName: "wifi_not_connected")
    //        }
    
    //    if debug { print("service: ") }
    //    if debug { print(device.peripheral.services) }
    //    if debug {
    //      if device.peripheral.services != nil {
    //        for service in device.peripheral.services! {
    //          print("/** service **/")
    //          print(service)
    //          for characteristic in service.characteristics! {
    //            print(characteristic)
    //          }
    //        }
    //      }
    //    }
    
    //    if debug {
    //      print("/** board **/")
    //      print(device.board!)
    //    }
    
    //    // MARK: (sample) Streaming Gyro
    //
    //    if debug {
    //      if device.peripheral.services != nil {
    //        mbl_mw_gyro_bmi160_set_range(device.board, MBL_MW_GYRO_BMI160_RANGE_125dps)
    //        mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BMI160_ODR_100Hz)
    //        mbl_mw_gyro_bmi160_write_config(device.board)
    //
    //        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(device.board)!
    ////        if device.peripheral.identifier.uuidString == "225B47EA-926D-428A-AAD9-6FF53F053578" {
    //        if device.peripheral.identifier.uuidString == "9193BC93-E1B9-4B6C-8A6F-5DC3EAD72845" {
    //          mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
    //            let gyroscope: MblMwCartesianFloat = obj!.pointee.valueAs()
    //            L_gyroTextBuff = "(L) [gyro]: " + String(obj!.pointee.epoch)
    //              + " / x: " + String(gyroscope.x)
    //              + " / y: " + String(gyroscope.y)
    //              + " / z: " + String(gyroscope.z)
    //          }
    //        } else {
    //          mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
    //            let gyroscope: MblMwCartesianFloat = obj!.pointee.valueAs()
    //            R_gyroTextBuff = "(R) [gyro]: " + String(obj!.pointee.epoch)
    //              + " / x: " + String(gyroscope.x)
    //              + " / y: " + String(gyroscope.y)
    //              + " / z: " + String(gyroscope.z)
    //          }
    //        }
    //        mbl_mw_gyro_bmi160_enable_rotation_sampling(device.board)
    //        mbl_mw_gyro_bmi160_start(device.board)
    //
    ////        streamingCleanup[signal] = {
    ////          mbl_mw_gyro_bmi160_stop(self.device.board)
    ////          mbl_mw_gyro_bmi160_disable_rotation_sampling(self.device.board)
    ////          mbl_mw_datasignal_unsubscribe(signal)
    ////        }
    //      }
    //    }
    //
    //    // MARK: (sample) Streaming Acceleration
    //    if debug {
    //      if device.peripheral.services != nil {
    //        print("/** debug **/")
    //        mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_2G)
    //        mbl_mw_acc_set_odr(device.board, 100.0)
    //        mbl_mw_acc_bosch_write_acceleration_config(device.board)
    //
    //        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
    //
    ////        if device.peripheral.identifier.uuidString == "225B47EA-926D-428A-AAD9-6FF53F053578" {
    //        if device.peripheral.identifier.uuidString == "9193BC93-E1B9-4B6C-8A6F-5DC3EAD72845" {
    //          mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
    //            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
    //            let format = DateFormatter()
    //            format.dateFormat = "MMddHHmmssSS"
    //            L_accTextBuff = "(L) " + "[acc]: " + String(obj!.pointee.epoch)
    //              + " / x: " + String(acceleration.x)
    //              + " / y: " + String(acceleration.y)
    //              + " / z: " + String(acceleration.z)
    //            let accRecordText: String = format.string(from: Date())
    //              + "," + String(acceleration.x)
    //              + "," + String(acceleration.y)
    //              + "," + String(acceleration.z)
    //            L_raw_accRecordTextBuff = accRecordText
    //            L_accRecordTextBuff = accRecordText
    //            L_freqTextBuff = "---"  // just trigger
    //          }
    //        } else {
    //          mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
    //            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
    //            let format = DateFormatter()
    //            format.dateFormat = "MMddHHmmssSS"
    //            R_accTextBuff = "(R) " + "[acc]: " + String(obj!.pointee.epoch)
    //              + " / x: " + String(acceleration.x)
    //              + " / y: " + String(acceleration.y)
    //              + " / z: " + String(acceleration.z)
    //            let accRecordText: String = format.string(from: Date())
    //              + "," + String(acceleration.x)
    //              + "," + String(acceleration.y)
    //              + "," + String(acceleration.z)
    //            R_raw_accRecordTextBuff = accRecordText
    //            R_accRecordTextBuff = accRecordText
    //            R_freqTextBuff = "---"  // just trigger
    //          }
    //        }
    //        mbl_mw_acc_enable_acceleration_sampling(device.board)
    //        mbl_mw_acc_start(device.board)
    //
    ////        streamingCleanup[signal] = {
    ////          mbl_mw_acc_stop(self.device.board)
    ////          mbl_mw_acc_disable_acceleration_sampling(self.device.board)
    ////          mbl_mw_datasignal_unsubscribe(signal)
    ////        }
    //      }
    //    }
    
    //    // MARK: (sample) Read Temperature???
    //    if debug && device.isConnectedAndSetup {
    //      let source = mbl_mw_multi_chnl_temp_get_source(device.board, UInt8(MBL_MW_TEMPERATURE_SOURCE_PRESET_THERM.rawValue))
    //      let selected = mbl_mw_multi_chnl_temp_get_temperature_data_signal(device.board, UInt8(MBL_MW_TEMPERATURE_SOURCE_PRESET_THERM.rawValue))!
    //      selected.read().continueOnSuccessWith(.mainThread) { obj in
    //        print(String(format: "%.1f°C", (obj.valueAs() as Float)))
    //      }
    //    }
    
    //    // MARK: (sample) Control LED???
    //    device.connectAndSetup().continueWith { t in
    //      var pattern = MblMwLedPattern()
    //      mbl_mw_led_load_preset_pattern(&pattern, MBL_MW_LED_PRESET_PULSE)
    //      mbl_mw_led_stop_and_clear(device.board)
    //      mbl_mw_led_write_pattern(device.board, &pattern, MBL_MW_LED_COLOR_GREEN)
    //      mbl_mw_led_play(device.board)
    //    }
    
    return cell
  }
  
  @objc func tableViewDoubleClick(sender: AnyObject) {
    let device = scannerModel.items[tableView.clickedRow].device
    guard !device.isConnectedAndSetup else {
      device.flashLED(color: .red, intensity: 1.0, _repeat: 3)
      mbl_mw_debug_disconnect(device.board)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        self.tableView.reloadData()
      }
      L_StreamPopUpButton.removeItem(withTitle: device.peripheral.identifier.uuidString)
      R_StreamPopUpButton.removeItem(withTitle: device.peripheral.identifier.uuidString)
      return
    }
    scannerModel.items[tableView.clickedRow].toggleConnect()
    tableView.reloadData()
  }
  
  @IBAction func L_streamButtonPressed(_ sender: NSButton) {
    var device = scannerModel.items[0].device
    for i in 0...scannerModel.items.count {
      device = scannerModel.items[i].device
      if L_StreamPopUpButton.titleOfSelectedItem == device.peripheral.identifier.uuidString { break }
    }
    
    // MARK: (sample) Streaming Gyro
    DispatchQueue.global().async {
      if device.peripheral.services != nil {
        mbl_mw_gyro_bmi160_set_range(device.board, MBL_MW_GYRO_BOSCH_RANGE_125dps)
//        mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BMI160_ODR_100Hz)
        mbl_mw_gyro_bmi160_write_config(device.board)
        
        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
          let gyroscope: MblMwCartesianFloat = obj!.pointee.valueAs()
          L_gyroTextBuff = "(L) [gyro]: " + String(obj!.pointee.epoch)
            + " / x: " + String(gyroscope.x)
            + " / y: " + String(gyroscope.y)
            + " / z: " + String(gyroscope.z)
        }
        mbl_mw_gyro_bmi160_enable_rotation_sampling(device.board)
        mbl_mw_gyro_bmi160_start(device.board)
      }
    }
    
    // MARK: (sample) Streaming Acceleration
    DispatchQueue.global().async {
      if device.peripheral.services != nil {
//        mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_2G)
//        mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_4G)
        mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_8G)
//        mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_16G)
      mbl_mw_acc_set_odr(device.board, 100.0)
      mbl_mw_acc_bosch_write_acceleration_config(device.board)
      
      let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
      
      mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
        let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
        let format = DateFormatter()
        format.dateFormat = "MMddHHmmssSS"
        L_accTextBuff = "(L) " + "[acc]: " + String(obj!.pointee.epoch)
          + " / x: " + String(acceleration.x)
          + " / y: " + String(acceleration.y)
          + " / z: " + String(acceleration.z)
        let accRecordText: String = String(Int(NSDate().timeIntervalSince1970 * 1000.0))
          + "," + String(acceleration.x)
          + "," + String(acceleration.y)
          + "," + String(acceleration.z)
//        let accRecordText: String = format.string(from: Date())
//          + "," + String(acceleration.x)
//          + "," + String(acceleration.y)
//          + "," + String(acceleration.z)
        L_raw_accRecordTextBuff = accRecordText
        L_accRecordTextBuff = accRecordText
        L_freqTextBuff = "---"  // just trigger
      }
      
      mbl_mw_acc_enable_acceleration_sampling(device.board)
      mbl_mw_acc_start(device.board)
    }
  }
}

@IBAction func R_streamButtonPressed(_ sender: NSButton) {
  var device = scannerModel.items[0].device
  for i in 0...scannerModel.items.count {
    device = scannerModel.items[i].device
    if R_StreamPopUpButton.titleOfSelectedItem == device.peripheral.identifier.uuidString { break }
  }
  
  // MARK: (sample) Streaming Gyro
  DispatchQueue.global().async {
    if device.peripheral.services != nil {
      mbl_mw_gyro_bmi160_set_range(device.board, MBL_MW_GYRO_BOSCH_RANGE_125dps)
//        mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BMI160_ODR_100Hz)
      mbl_mw_gyro_bmi160_write_config(device.board)
      
      let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(device.board)!
      mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
        let gyroscope: MblMwCartesianFloat = obj!.pointee.valueAs()
        R_gyroTextBuff = "(R) [gyro]: " + String(obj!.pointee.epoch)
          + " / x: " + String(gyroscope.x)
          + " / y: " + String(gyroscope.y)
          + " / z: " + String(gyroscope.z)
      }
      mbl_mw_gyro_bmi160_enable_rotation_sampling(device.board)
      mbl_mw_gyro_bmi160_start(device.board)
    }
  }
  
  // MARK: (sample) Streaming Acceleration
  DispatchQueue.global().async {
    if device.peripheral.services != nil {
//        mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_2G)
//        mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_4G)
        mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_8G)
//        mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_16G)
        mbl_mw_acc_set_odr(device.board, 100.0)
        mbl_mw_acc_bosch_write_acceleration_config(device.board)
        
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
          let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
          let format = DateFormatter()
          format.dateFormat = "MMddHHmmssSS"
          R_accTextBuff = "(R) " + "[acc]: " + String(obj!.pointee.epoch)
            + " / x: " + String(acceleration.x)
            + " / y: " + String(acceleration.y)
            + " / z: " + String(acceleration.z)
          let accRecordText: String = String(Int(NSDate().timeIntervalSince1970 * 1000.0))
            + "," + String(acceleration.x)
            + "," + String(acceleration.y)
            + "," + String(acceleration.z)
//          let accRecordText: String = format.string(from: Date())
//            + "," + String(acceleration.x)
//            + "," + String(acceleration.y)
//            + "," + String(acceleration.z)
          R_raw_accRecordTextBuff = accRecordText
          R_accRecordTextBuff = accRecordText
          R_freqTextBuff = "---"  // just trigger
        }
        
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
      }
    }
  }
  
  @IBAction func L_StreamStopButtonPressed(_ sender: NSButton) {
    var device = scannerModel.items[0].device
    for i in 0...scannerModel.items.count {
      device = scannerModel.items[i].device
      if L_StreamPopUpButton.titleOfSelectedItem == device.peripheral.identifier.uuidString { break }
    }
    mbl_mw_acc_stop(device.board)
    mbl_mw_acc_disable_acceleration_sampling(device.board)
    mbl_mw_gyro_bmi160_stop(device.board)
    mbl_mw_gyro_bmi160_disable_rotation_sampling(device.board)
  }
  
  @IBAction func R_StreamStopButtonPressed(_ sender: NSButton) {
    var device = scannerModel.items[0].device
    for i in 0...scannerModel.items.count {
      device = scannerModel.items[i].device
      if R_StreamPopUpButton.titleOfSelectedItem == device.peripheral.identifier.uuidString { break }
    }
    mbl_mw_acc_stop(device.board)
    mbl_mw_acc_disable_acceleration_sampling(device.board)
    mbl_mw_gyro_bmi160_stop(device.board)
    mbl_mw_gyro_bmi160_disable_rotation_sampling(device.board)
  }
  
  @IBAction func recordButtonPressed(_ sender: NSButton) {
    if L_raw_csvMng.isRecording {
      self.L_raw_csvMng.stopRecording()
      self.L_raw_csvMng.saveSensorDataToCsv()
      self.R_raw_csvMng.stopRecording()
      self.R_raw_csvMng.saveSensorDataToCsv()
      self.L_csvMng.stopRecording()
      self.L_csvMng.saveSensorDataToCsv()
      self.R_csvMng.stopRecording()
      self.R_csvMng.saveSensorDataToCsv()
      self.recordButton.title = "START"
    } else {
      self.L_raw_csvMng.setFileNameText(setText: "MMR-left-raw-" + filenameTextField.stringValue)
      self.R_raw_csvMng.setFileNameText(setText: "MMR-right-raw-" + filenameTextField.stringValue)
      self.L_csvMng.setFileNameText(setText: "MMR-left-" + filenameTextField.stringValue)
      self.R_csvMng.setFileNameText(setText: "MMR-right-" + filenameTextField.stringValue)
      self.L_raw_csvMng.startRecording()
      self.R_raw_csvMng.startRecording()
      self.L_csvMng.startRecording()
      self.R_csvMng.startRecording()
      self.recordButton.title = "STOP"
    }
  }
  
  //  @IBAction func accelerometerBMI160StartStreamPressed(_ sender: Any) {
  //    accelerometerBMI160StartStream.isEnabled = false
  //    accelerometerBMI160StopStream.isEnabled = true
  //    accelerometerBMI160StartLog.isEnabled = false
  //    accelerometerBMI160StopLog.isEnabled = false
  //    updateAccelerometerBMI160Settings()
  //    accelerometerBMI160Data.removeAll()
  //    let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
  //    mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
  //      let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
  //      let _self: DeviceDetailViewController = bridge(ptr: context!)
  //      DispatchQueue.main.async {
  //        _self.accelerometerBMI160Graph.addX(Double(acceleration.x), y: Double(acceleration.y), z: Double(acceleration.z))
  //      }
  //      // Add data to data array for saving
  //      _self.accelerometerBMI160Data.append((obj!.pointee.epoch, acceleration))
  //    }
  //    mbl_mw_acc_enable_acceleration_sampling(device.board)
  //    mbl_mw_acc_start(device.board)
  //
  //    streamingCleanup[signal] = {
  //      mbl_mw_acc_stop(self.device.board)
  //      mbl_mw_acc_disable_acceleration_sampling(self.device.board)
  //      mbl_mw_datasignal_unsubscribe(signal)
  //    }
  //  }
  //
  //  @IBAction func accelerometerBMI160StopStreamPressed(_ sender: Any) {
  //    accelerometerBMI160StartStream.isEnabled = true
  //    accelerometerBMI160StopStream.isEnabled = false
  //    accelerometerBMI160StartLog.isEnabled = true
  //    let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
  //    streamingCleanup.removeValue(forKey: signal)?()
  //  }
  //
  //  @IBAction func gyroBMI160StartStreamPressed(_ sender: Any) {
  //    gyroBMI160StartStream.isEnabled = false
  //    gyroBMI160StopStream.isEnabled = true
  //    gyroBMI160StartLog.isEnabled = false
  //    gyroBMI160StopLog.isEnabled = false
  //    updateGyroBMI160Settings()
  //    gyroBMI160Data.removeAll()
  //
  //    let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(device.board)!
  //    mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
  //      let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
  //      let _self: DeviceDetailViewController = bridge(ptr: context!)
  //      DispatchQueue.main.async {
  //        // TODO: Come up with a better graph interface, we need to scale value
  //        // to show up right
  //        _self.gyroBMI160Graph.addX(Double(acceleration.x * 0.008), y: Double(acceleration.y * 0.008), z: Double(acceleration.z * 0.008))
  //      }
  //      // Add data to data array for saving
  //      _self.gyroBMI160Data.append((obj!.pointee.epoch, acceleration))
  //    }
  //    mbl_mw_gyro_bmi160_enable_rotation_sampling(device.board)
  //    mbl_mw_gyro_bmi160_start(device.board)
  //
  //    streamingCleanup[signal] = {
  //      mbl_mw_gyro_bmi160_stop(self.device.board)
  //      mbl_mw_gyro_bmi160_disable_rotation_sampling(self.device.board)
  //      mbl_mw_datasignal_unsubscribe(signal)
  //    }
  //  }
  //
  //  @IBAction func gyroBMI160StopStreamPressed(_ sender: Any) {
  //    gyroBMI160StartStream.isEnabled = true
  //    gyroBMI160StopStream.isEnabled = false
  //    gyroBMI160StartLog.isEnabled = true
  //    let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(device.board)!
  //    streamingCleanup.removeValue(forKey: signal)?()
  //  }
}

extension ViewController: ScannerModelDelegate {
  func scannerModel(_ scannerModel: ScannerModel, didAddItemAt idx: Int) {
    //    if debug { print("Found!! - index: " + String(idx)) }
    tableView.reloadData()
  }
  
  func scannerModel(_ scannerModel: ScannerModel, confirmBlinkingItem item: ScannerModelItem, callback: @escaping (Bool) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      callback(true)
      self.tableView.reloadData()
    }
  }
  
  func scannerModel(_ scannerModel: ScannerModel, errorDidOccur error: Error) {
  }
}
