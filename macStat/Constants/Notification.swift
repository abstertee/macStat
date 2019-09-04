//
//  Notification.swift
//  macStat
//
//  Created by Abraham Tarverdi on 8/30/19.
//  Copyright © 2019 Tarverdi Ent. All rights reserved.
//

import Foundation
import Cocoa

class NotificationBanner: NSObject {
    
    init(text: String) {
        super.init()
        // Create a user notification object and set it's properties.
        let notification = NSUserNotification()
        let bundleIdentifier = Bundle.main.bundleIdentifier!
        //print(bundleIdentifier)
        if text.isEmpty {
            return
        }
        
        // Text elements.
        notification.title = AppConstants.NotificationText.Title
        notification.subtitle = AppConstants.NotificationText.SubTitle
        notification.informativeText = text //"A system setting is out of compliance."
        
        // Button elements
        notification.hasActionButton = AppConstants.NotificationText.HasActionButton
        notification.otherButtonTitle = AppConstants.NotificationText.OtherButtonTitle
        notification.actionButtonTitle = AppConstants.NotificationText.ActionButtonTitle
        
        notification.userInfo = ["sender": bundleIdentifier]
        
        // Image elements
        let fm = FileManager.default
        let iconPathString = fm.urls(for: .libraryDirectory, in: .localDomainMask)[0].appendingPathComponent((appSettings.dict[AppConstants.PlistKeys.logopath] as? String)!).path
        //let iconPathString = fm.urls(for: .libraryDirectory, in: .localDomainMask)[0].appendingPathComponent("Application Support/JAMF/bin/workday_w.png").path
        notification.setValue(NSImage(byReferencing: URL(fileURLWithPath: iconPathString)), forKey: "_identityImage")
        
        //notification.contentImage = NSImage(named: NSImage.Name("bad"))
        
        // Delivery sound
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.deliveryDate = Date(timeIntervalSinceNow: 5)
        let nc = NSUserNotificationCenter.default
        nc.scheduleNotification(notification)
        
    }
    
}
