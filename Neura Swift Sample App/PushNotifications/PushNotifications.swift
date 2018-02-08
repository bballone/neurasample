//
//  PushNotifications.swift
//  Neura Swift Sample App
//
//  Created by Neura on 08/08/2017.
//  Copyright © 2017 beauNeura. All rights reserved.
//
import UIKit
import NeuraSDK

let kStoredDeviceToken = "stored device token"

class PushNotifications: NSObject {
    
    class func requestPermissionForPushNotifications() {
        let app = UIApplication.shared
        let settings = UIUserNotificationSettings(types: [.alert,.badge,.sound],
                                                  categories: nil)
        app.registerUserNotificationSettings(settings)
        app.registerForRemoteNotifications()
    }
    
    class func register(deviceToken: Data) {
        UserDefaults.standard.set(deviceToken, forKey: kStoredDeviceToken)
        NeuraSDKPushNotification.registerDeviceToken(deviceToken)
    }
    
    class func storedDeviceToken() -> Data? {
        let deviceToken = UserDefaults.standard.value(forKey: kStoredDeviceToken) as? Data
        return deviceToken;
    }
}
