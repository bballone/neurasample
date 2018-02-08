//
//  PickerViewController.swift
//  Push Notifications Test
//
//  Created by Neura on 10/10/16.
//  Copyright © 2016 Neura. All rights reserved.
//

import Foundation
import UIKit
import NeuraSDK

//MARK: Picker Delegate Protocol
protocol PickerDelegate: class {
  func selectedCapability(_ capability: NCapability)
}

class PickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
  //MARK: Properties
  let neuraSDK = NeuraSDK.shared
  var capabilities = [NCapability]()
  weak var delegate: PickerDelegate? = nil
  @IBOutlet weak var capabilityPicker: UIPickerView!
  
  //MARK: Lifecycle Functions
  override func viewDidLoad() {
    super.viewDidLoad()
    capabilityPicker.dataSource = self
    capabilityPicker.delegate = self
    self.getData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.hide()
  }
  
  func getData() {
    //Gets all of Neura's supported capabilities.
    
    neuraSDK.getSupportedCapabilitiesList() {capabilitiesResult in
        if capabilitiesResult.error != nil {
            return
        }
        self.capabilities = capabilitiesResult.capabilities
        self.capabilityPicker.reloadAllComponents()  
    }
  }
  
  //MARK: Picker Functions
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return capabilities.count;
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return capabilities[row].displayName
  }
  
  func show() {
    self.view.superview?.alpha = 1
  }
  
  func hide() {
    self.view.superview?.alpha = 0
  }
  
  //MARK: IBAction Functions
  @IBAction func checkTouched(_ sender: AnyObject) {
    let selectedCapability = self.capabilities[self.capabilityPicker.selectedRow(inComponent: 0)]
    self.delegate?.selectedCapability(selectedCapability)
    self.hide()
  }
  
  @IBAction func cancelTouched(_ sender: AnyObject) {
    self.hide()
  }
}
