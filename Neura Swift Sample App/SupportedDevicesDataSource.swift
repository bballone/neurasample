//
//  SupportedDevicesDataSource.swift
//  Push Notifications Test
//
//  Created by Neura on 10/10/16.
//  Copyright © 2016 Neura. All rights reserved.
//

import Foundation
import UIKit
import NeuraSDK

class SupportedDevicesDataSource: NSObject, UITableViewDataSource, DataSourceProtocol {
  //MARK: Properties
  let neuraSDK = NeuraSDK.shared
  var list = [String]()
  var status = [Bool]()
  
  internal func reloadData(_ callback: @escaping () -> ()) {
    self.list = []
    //Returns a list of all devices that Neura supports
    neuraSDK.getSupportedDevicesList() { (devicesResult) in
        if devicesResult.error != nil {
            return
        }
        for device in devicesResult.devices {
            self.list.append(device.name)
        }
        callback()
    }
  }
  
  //MARK: Table View Functions
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return list.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DeviceOperationsTableViewCell
    cell.name.text = list[(indexPath as IndexPath).row]
    return cell
  }
}
