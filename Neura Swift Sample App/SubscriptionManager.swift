//
//  SubscriptionManager.swift
//  Neura Swift Sample App
//
//  Created by Neura on 05/02/2018.
//  Copyright © 2018 beauNeura. All rights reserved.
//

import Foundation
import NeuraSDK


class SubscriptionsManager {
    
    let requiredSubscriptions: Set<String> = [
        EventName.eventArrivedHome.rawValue,
//        EventName.eventLeftHome.rawValue,
        EventName.eventArrivedToWork.rawValue,
//        EventName.eventLeftWork.rawValue,
//        EventName.eventStartedDriving.rawValue,
//        EventName.eventFinishedDriving.rawValue,
//        EventName.eventStartedSleeping.rawValue,
//        EventName.eventGotUp.rawValue,
//        EventName.eventStartedWalking.rawValue,
//        EventName.eventWokeUp.rawValue,
//        EventName.eventFinishedWalking.rawValue
    ]
    
    var missingSubscriptions: Set<String> = []
    var alreadySubscribedToAll = false
    var currentlyWorking = false
    var checkAgainLater = false
    
    var lastTimeChecked: Date? = nil
    
    func checkSubscriptions() {
        weak var wSelf = self
        
        guard currentlyWorking == false else {
            self.checkAgainLater = true
            return
        }
        
        self.currentlyWorking = true
        NeuraSDK.shared.getSubscriptionsList(callback: { result in
            
            if !result.success {
                self.epicFail()
                return
            }
            
             wSelf?.lastTimeChecked = Date()
            self.missingSubscriptions.removeAll()
            for subscription in self.requiredSubscriptions {
                self.missingSubscriptions.insert(subscription)
            }

            result.subscriptions.forEach { item in
                let userId = NeuraSDK.shared.neuraUserId() != nil ? NeuraSDK.shared.neuraUserId()! : ""
                let identifier = item.eventName + "_" + userId
                
                if self.requiredSubscriptions.contains(item.eventName) {
                    if item.identifier == identifier {
                        print("Already subscribed to:" + item.eventName)
                        self.missingSubscriptions.remove(item.eventName)
                    } else {
                        NeuraSDK.shared.remove(item, callback: { result in})
                    }
                }
            }
            
            wSelf?.subscribeToMissingSubscriptions()
        })
    }
    
    func subscribeToMissingSubscriptions(){
        guard self.missingSubscriptions.count > 0 else {
            self.currentlyWorking = false
            return
        }
        
        guard let eventName = self.missingSubscriptions.popFirst() else { return }
        weak var wSelf = self
        let webhookId = "usaawebhook"
        let userId = NeuraSDK.shared.neuraUserId() != nil ? NeuraSDK.shared.neuraUserId()! : ""
        let identifier = eventName + "_" + userId
        let sub = NSubscription(eventName: eventName, identifier: identifier, webhookId: webhookId, method: NSubscriptionMethod.webhook)
        
        NeuraSDK.shared.add(sub, callback: { response in
            if response.error == nil {
                print("Subscribed to:" + eventName)
            } else  {
                print("Failed subscription to " + eventName + " " + response.error!.description())
            }
            wSelf?.subscribeToMissingSubscriptions()
        })
    }
    
    func epicFail() {
        self.currentlyWorking = false
        self.checkAgainLater = false
    }
}


enum EventName : String {
    
    case eventArrivedHome       = "userArrivedHome"
    case eventLeftHome          = "userLeftHome"
    
    case eventArrivedToWork     = "userArrivedToWork"
    case eventLeftWork          = "userLeftWork"
    
    case eventStartedDriving    = "userStartedDriving"
    case eventFinishedDriving   = "userFinishedDriving"
    
    case eventStartedRunning    = "userStartedRunning"
    case eventFinishedRunning   = "userFinishedRunning"
    
    case eventStartedWalking    = "userStartedWalking"
    case eventFinishedWalking   = "userFinishedWalking"
    
    case eventStartedSleeping   = "userStartedSleeping"
    case eventWokeUp            = "userWokeUp" // Currently not reported on iOS
    case eventGotUp             = "userGotUp"
    case eventArrivedPlace      = "userArrivedPlace"
    case eventLeftPlace         = "userLeftPlace"
}
