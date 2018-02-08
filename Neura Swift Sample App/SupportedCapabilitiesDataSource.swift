//
//  SupportedCapabilitiesDataSource.swift
//  Push Notifications Test
//
//  Created by Neura on 10/10/16.
//  Copyright © 2016 Neura. All rights reserved.
//

import Foundation
import UIKit
import NeuraSDK

class SupportedCapabilitiesDataSource: NSObject, UITableViewDataSource, DataSourceProtocol {
  internal func reloadData(_ callback: @escaping () -> ()) {
    self.list = []
    //Returns a list of all capabilities that Neura supports
    neuraSDK.getSupportedCapabilitiesList() { (capabilitiesResult) in
        if capabilitiesResult.error != nil {
            return
        }
        for capability in capabilitiesResult.capabilities {
            let name = capability.name
            self.list.append(name)
        }
        callback()
    }
  }

  //MARK: Properties
  let neuraSDK = NeuraSDK.shared
  var list = [String]()

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
