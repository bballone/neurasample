//
//  SubscriptionsListViewController.swift
//  Push Notifications Test
//
//  Created by Neura on 7/13/16.
//  Copyright © 2016 Neura. All rights reserved.
//

import Foundation
import UIKit
import NeuraSDK

class SubscriptionsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    //MARK: Properties
    let neuraSDK = NeuraSDK.shared
    // Declare the permissions you'll want to request here. These can be found in the app wizard in the developer console at the bottom of the page.
    // They should correspond to the permissions group that you've declared in the authenticate with permissions function elsewhere (in the main view controller in this case)
    var eventNamesArray = [
        "userArrivedHome",
        "userArrivedHomeFromWork",
        "userLeftHome",
        "userArrivedHomeByWalking",
        "userArrivedHomeByRunning",
        "userIsOnTheWayHome",
        "userIsIdleAtHome",
        "userStartedWorkOut",
        "userFinishedRunning",
        "userFinishedWorkOut",
        "userLeftGym",
        "userFinishedWalking",
        "userArrivedToGym",
        "userIsIdleFor2Hours",
        "userStartedWalking",
        "userIsIdleFor1Hour",
        "userStartedRunningFromPlace",
        "userStartedTransitByWalking",
        "userStartedRunning",
        "userFinishedTransitByWalking"
    ]
    var subscriptions = [String: NSubscription]()
    let cellReuseIdentifier = "SuscriptionsListViewCell"
    
    //MARK: IBOutlets
    @IBOutlet weak var subscriptionsTableView: UITableView!
    
    //MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        subscriptionsTableView.delegate = self
        subscriptionsTableView.dataSource = self
        reloadAllData()
    }
    
    func reloadAllData() {
        self.subscriptions.removeAll()
        neuraSDK.getSubscriptionsList() { result in
            guard result.success else { return }
            for subscription in result.subscriptions {
                self.subscriptions[subscription.eventName] = subscription
            }
            self.subscriptionsTableView.reloadData()
        }
    }
    
    //MARK: Table view functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventNamesArray.count
    }
    
    //Create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SubscriptionsTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! SubscriptionsTableViewCell
        
        // Add a handler for value changes, if missing.
        if cell.subscribeSwitch.allTargets.count == 0 {
            cell.subscribeSwitch.addTarget(self, action: #selector(SubscriptionsListViewController.subscribeToEventSwitch(_:)), for: UIControlEvents.valueChanged)
        }
        
        // Configure the cell.
        let eventName = self.eventNamesArray[indexPath.item]
        cell.subscriptionName?.text = eventName
        
        if let _ = self.subscriptions[eventName] {
            cell.subscribeSwitch.isOn = true
        } else {
            cell.subscribeSwitch.isOn = false
        }
        
        return cell
    }
    
    @objc func subscribeToEventSwitch(_ subscribeSwitch: UISwitch) {
        let cell = subscribeSwitch.superview?.superview as! SubscriptionsTableViewCell
        let indexPath = self.subscriptionsTableView.indexPath(for: cell)
        let eventName = self.eventNamesArray[(indexPath?.row)!]
        
        if subscribeSwitch.isOn {
            //this function checks whether an event subscription is missing data in order to successfully subscribe
            if neuraSDK.isMissingData(forEvent: eventName) == true {
                let alertController = UIAlertController(title: "A related place node should be added, before you can subscribe to this event. Would you like to subscribe anyway?", message: nil, preferredStyle: .alert)
                let noAction = UIAlertAction(title: "I will wait", style: .default, handler: { _ in subscribeSwitch.setOn(false, animated: true)})
                alertController.addAction(noAction)
                let okAction = UIAlertAction(title: "Yes", style: .default, handler: {_ in self.subscribeToEvent(eventName)})
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                subscribeToEvent(eventName)
            }
        } else {
            removeSubscriptionWithEventName(eventName)
        }
    }

   

    func subscribeToEvent(_ eventName: String) {
        let identifier = "\(NeuraSDK.shared.neuraUserId()!)_\(eventName)"
        let nSubscription = NSubscription(evenName: eventName, forPushWithIdentifier: identifier)//NSubscription(eventName: eventName, webhookId: identifier)
        neuraSDK.add(nSubscription)  { result in
            if result.error != nil {
                let alertController = UIAlertController(title: "Error", message: result.errorString, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            self.reloadAllData()
        }
    }

    func removeSubscriptionWithEventName(_ eventName: String){
        let identifier = (eventName) + "_" + (NeuraSDK.shared.neuraUserId()!)
        let nSubscription = NSubscription(evenName: eventName, forPushWithIdentifier: identifier)
        neuraSDK.remove(nSubscription) { result in
            if result.error != nil {
                let alertController = UIAlertController(title: "Error", message: result.errorString, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            self.reloadAllData()
        }
    }
    
    //MARK: IBActions
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
