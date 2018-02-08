//
//  DataSourceProtocol.swift
//  Push Notifications Test
//
//  Created by Neura on 10/9/16.
//  Copyright © 2016 Neura. All rights reserved.
//

import Foundation
import UIKit

typealias FetchCallback = () -> ()

protocol DataSourceProtocol: UITableViewDataSource {
  var list: [String] {get set}
  func reloadData(_  callback: @escaping FetchCallback)
}
