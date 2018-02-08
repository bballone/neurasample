//
//  SimulateEventTableViewCell.swift
//  Neura Swift Sample App
//
//  Created by Neura on 31/01/2018.
//  Copyright © 2018 beauNeura. All rights reserved.
//

import Foundation
import UIKit
import NeuraSDK


class SimulateEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var eventName: UILabel!
    var eventNameForEnum:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sendBtn.layer.cornerRadius = 5.2
    }
    
    @IBAction func sendEventAction(_ sender: UIButton) {
        let eventName = NEvent.enum(forEventName: eventNameForEnum)
        NeuraSDK.shared.simulateEvent(eventName, callback: { result in
            let title =   result == nil || !result!.success  ? "Error" : "Approve"
            let message = result?.errorString != nil ? result!.errorString! : "Sucsess"
           
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                   
                    if var topController = UIApplication.shared.keyWindow?.rootViewController {
                        while let presentedViewController = topController.presentedViewController {
                            topController = presentedViewController
                        }
                        topController.present(alert, animated: true, completion: nil)
                    }
                })
        })
    }
}
