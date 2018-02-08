//
//  NotificationService.swift
//  Notifications
//
//  Created by Aviv Wolf on 15/10/2017.
//  Copyright © 2017 beauNeura. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var mutableContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        mutableContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        // Parse the payload with info about the event.
        guard
            let mutableContent = mutableContent,
            let data = request.content.userInfo["data"] as? [String:AnyObject],
            let pushType = data["pushType"] as? String,
            pushType == "neura_event",
            let pushData = data["pushData"] as? [String:AnyObject],
            let event = pushData["event"] as? [String:AnyObject],
            let eventId = event["neuraId"] as? String,
            let eventName = event["name"] as? String
        else {
                return
        }
        
        // Title
        mutableContent.title = "Neura Event!"
        
        // Subtitle with timestamp
        if let timestampNumber = event["timestamp"] as? NSNumber {
            let timestampString = self.formattedTimestampString(timestampNumber)
            mutableContent.subtitle = timestampString
        }
        
        // Body with event name and id
        mutableContent.body = "\(eventName) (\(eventId))"
        
        // Done
        contentHandler(mutableContent)
    }
    
    func formattedTimestampString(_ timestampNumber: NSNumber) -> String {
        let timestamp = timestampNumber.doubleValue
        let theDate = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.system
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss (z)"
        let timeString = formatter.string(from: theDate)
        return timeString;
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let mutableContent =  mutableContent {
            contentHandler(mutableContent)
        }
    }

}
