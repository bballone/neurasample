//
//  DeviceOperationsViewController.swift
//  Push Notifications Test
//
//  Created by Neura on 7/15/16.
//  Copyright © 2016 Neura. All rights reserved.
//

import Foundation
import UIKit
import NeuraSDK

class DeviceOperationsViewController: UIViewController, PickerDelegate {
    
    //MARK: Properties
    let neuraSDK = NeuraSDK.shared
    enum buttonTouched {
        case getAllCapabilities
        case getAllDevices
    }
    weak var pickerVC: PickerViewController?
    var sendingButton:buttonTouched = buttonTouched.getAllDevices
    
    //MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "deviceOperationsList" {
            let listViewController = segue.destination as! DeviceOperationsListViewController
            
            switch self.sendingButton {
            case .getAllCapabilities:
                listViewController.dataSource = SupportedCapabilitiesDataSource()
                listViewController.titleText = "All Capabilities"
            case .getAllDevices:
                listViewController.dataSource = SupportedDevicesDataSource()
                listViewController.titleText = "All Devices"
            }
        } else if segue.identifier == "pickerSegue" {
            self.pickerVC = segue.destination as? PickerViewController
            pickerVC!.delegate = self
        }
    }
    
    //MARK: Capability Action Functions
    func selectedCapability(_ capability: NCapability) {
        /*
         hasDeviceWithCapability checks if the user has a registered device with the capability you pass it.
         In this case, the function is called as a delegate from the PickerViewController file
         */
        neuraSDK.hasDevice(with: capability) { (result) in
            if result.error != nil {
                return
            }
            var alertController: UIAlertController
            if result.hasDevice == false {
                alertController = UIAlertController(title: "No device with \(capability.displayName) capability", message: nil, preferredStyle: .alert)
            } else {
                alertController = UIAlertController(title: "There is a device with \(capability.displayName) capability", message: nil, preferredStyle: .alert)
            }
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    //MARK: Add Device Functions
    /*
     addDeviceWithCapability allows you to add a device with an optional specified capability
     or name.
     */
    func addDeviceCapability() {
        /*
         For this example, we use stepCount as the capability, but in your app you can
         replace this param with whatever ability you want. Take a look at the list in
         "Get all capabilities" to see all of your options
         */
        neuraSDK.addDevice(withCapabilityNamed: "stepCount") { (result) in
            if result.error != nil {
                self.errorAddingDevice()
            }
        }
    }
    
    func addDeviceName() {
        /*
         Here we specify the deviceName and not the deviceCapability. Take a look at the
         "Get all devices list" for a full list of devices
         */
        neuraSDK.addDeviceNamed("Fitbit Charge") { (response) in
            if response.error != nil {
                self.errorAddingDevice()
            }
        }
    }
    
    func errorAddingDevice() {
        let alertController = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: IBAction Functions
    @IBAction func backButtonTouched(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getAllCapabilities(_ sender: AnyObject) {
        self.sendingButton = buttonTouched.getAllCapabilities
        self.performSegue(withIdentifier: "deviceOperationsList", sender: self)
    }
    
    @IBAction func checkUsersCapabilities(_ sender: AnyObject) {
        pickerVC?.show()
    }
    
    @IBAction func getAllDevicesTouched(_ sender: AnyObject) {
        self.sendingButton = buttonTouched.getAllDevices
        self.performSegue(withIdentifier: "deviceOperationsList", sender: self)
    }
    
    @IBAction func addADeviceTouched(_ sender: AnyObject) {
        let addDeviceActionSheet = UIAlertController(title: "Pick an option", message: nil, preferredStyle: .actionSheet)
        let byCapability = UIAlertAction(title: "Add by capability", style: .default, handler: {action in self.addDeviceCapability()})
        let byName = UIAlertAction(title: "Add by device name", style: .default, handler: {action in self.addDeviceName()})
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        addDeviceActionSheet.addAction(byCapability)
        addDeviceActionSheet.addAction(byName)
        addDeviceActionSheet.addAction(cancel)
        
        self.present(addDeviceActionSheet, animated: true, completion: nil)
    }
}
