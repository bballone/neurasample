//
//  SendEventViewController.swift
//  Neura Swift Sample App
//
//  Created by Neura on 31/01/2018.
//  Copyright © 2018 beauNeura. All rights reserved.
//

import Foundation
import UIKit
import NeuraSDK

class SendEventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var eventsTableView: UITableView!
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var eventNames = Array<String>()
   
   
    override func viewDidLoad() {
        super.viewDidLoad()
        NeuraSDK.shared.getEventsList(callback: { result in
           
            result.eventDefinitions.forEach { item in
                self.eventNames.append(item.name)
            }
            self.eventsTableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SimulateEventTableViewCell = self.eventsTableView.dequeueReusableCell(withIdentifier: "SimulateEventCell") as! SimulateEventTableViewCell
        let eventName = self.eventNames[indexPath.item]
        let enumEventName =  NEvent.enum(forEventName: eventName)
       
        cell.sendBtn.isHidden = enumEventName == .undefined
        cell.eventName.text = eventName
        cell.eventNameForEnum = eventName
        return cell
    }
}
