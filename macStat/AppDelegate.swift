//
//  AppDelegate.swift
//  macStat
//
//  Created by Abraham Tarverdi on 8/30/19.
//  Copyright © 2019 Tarverdi Ent. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    var timer = Timer()
    var eventMonitor: EventMonitor?
    let popover = NSPopover()
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        //debugPrint("CommandLine Arguments: \(CommandLine.arguments)")
        appIconChange(status: "macStatIcon")
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
        popover.contentViewController = StatusViewController.freshController(controllerName: "StatusViewController")
        appSetup()
        statusTabChecks_Queue()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func appIconChange(status: String) {
        let button = statusItem.button
        button?.image = NSImage(named: NSImage.Name(status))
        button?.action = #selector(togglePopover(_:))
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        
        if let button = statusItem.button {
            
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            eventMonitor?.start()
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        logger.write("Popover menu item was closed by: \(sender ?? "")")
        eventMonitor?.stop()
    }
    
    @objc func statusTabChecks_Queue() {
        let taskQueue = DispatchQueue(label: "AppDelegate-RunChecks", qos: .background)
        taskQueue.async {
            for (checkName, checkObject) in checkObjectsDict {
                logger.write("Throwing \(checkName) in the background.")
                do {
                    _ = try checkObject.checkFunction()
                } catch let error {
                    logger.write("ERROR: failed to run check function for \(checkName), \(error.localizedDescription)")
                }
                
                DispatchQueue.main.async {
                    debugPrint("Done with \(checkName)")
                    logger.write("Done with \(checkName)")
                    debugPrint("\(checkObject.success) for \(checkName)")
                    if checkObject.success == false {
                        _ = NotificationBanner(text: "\(checkObject.statusText)")
                    }
                }
            }
            
        }
        
    }
    
    func appSetup() {
        logger.write(" ")
        logger.write("======================== Starting MacStat \(AppConstants.Preferences.version) ==========================")
        // Settings File does not exist
        logger.write("Number of arguments passed: \(CommandLine.argc)")
        if appSettings.fileExists == false && CommandLine.argc < 4 {
            logger.write(AppConstants.AppFiles.SettingsFileDoesNotExist)
            logger.write(AppConstants.Alerts.AppDelegate.noArgs)
            //debugPrint(AppConstants.Alerts.AppDelegate.noArgs)
            let alert = NSAlert()
            alert.messageText = "ERROR!"
            alert.informativeText = "A critical settings file was not found.\n\nCould not find the file at " + AppConstants.AppFiles.SettingsFile.path // Edit as Required
            alert.alertStyle = NSAlert.Style.critical
            alert.addButton(withTitle: "Ok")
            alert.runModal()
            exit(100)
        }
        //print("Arguments are passed.")
    }


}

