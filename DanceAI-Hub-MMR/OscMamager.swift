//
//  OscMamager.swift
//  DanceAI-Hub-MMR
//
//  Created by Almina on 2021/04/30.
//  Copyright © 2021 Almina. All rights reserved.
//

import Foundation
import SwiftOSC

class OscManager {
  
  var client:OSCClient
  
  init() {
    client = OSCClient(address: "localhost", port: 8080)
  }
  
  func setIPAddress(IPAddress:String){
    print("change OSC connection IP Address...")
    client = OSCClient(address: IPAddress, port: 8080)
  }
  
  func sendFloatMessage(address:String, arguments:[String]){
    //        var message = OSCMessage(
    //            OSCAddressPattern("/"),
    //            100,
    //            5.0,
    //            "Hello World",
    //            Blob(),
    //            true,
    //            false,
    //            nil,
    //            impulse,
    //            Timetag(1)
    //        )
    //        let message = OSCMessage(OSCAddressPattern("/Hub"), "hello!")
    
    let message = OSCMessage(OSCAddressPattern(address))
    for arg in arguments {
      message.add(Float(arg))
    }
    client.send(message)
    //        print(message)
  }
  
  func sendStringMessage(address:String, arguments:[String]){
    let message = OSCMessage(OSCAddressPattern(address))
    for arg in arguments {
      message.add(arg)
    }
    client.send(message)
  }
}


