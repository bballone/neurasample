//
//  DeviceOperationsListViewController.swift
//  Push Notifications Test
//
//  Created by Neura on 10/9/16.
//  Copyright © 2016 Neura. All rights reserved.
//

import Foundation
import UIKit

class DeviceOperationsListViewController: UIViewController, UITableViewDelegate {

  //MARK: Properties
  @IBOutlet weak var tableTitle: UILabel!
  @IBOutlet weak var tableView: UITableView!
  var dataSource: DataSourceProtocol?
  var titleText: String?
  
  //MARK: Lifecycle Functions
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableTitle.text = self.titleText
    self.tableView.dataSource = self.dataSource
    self.dataSource?.reloadData({
      self.tableView.reloadData()
    })
  }
  
  //MARK: IBAction Functions
  @IBAction func backButtonTouched(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: nil)
  }
}
