//
//  FullApp+Extension.swift
//  macStat
//
//  Created by Abraham Tarverdi on 9/4/19.
//  Copyright © 2019 Tarverdi Ent. All rights reserved.
//

import Foundation
import Cocoa

extension FullAppWindow {
    
    func assignIbOutlets() {
        
        for var item in checkObjectsDict {
            //debugPrint("Assigning iboutlets to: \(item.value.name)")
            switch item.key {
            case "Firewall":
                assignProperties(object: item.value, icon: firewallStatusIcon, spinner: firewallSpinner, status: firewallStatus)
            case "Certs":
                assignProperties(object: item.value, icon: certStatusIcon, spinner: certSpinner, status: certStatus)
            case "Updates":
                assignProperties(object: item.value, icon: softupdateStatusIcon, spinner: softupdateSpinner, status: softwareupdateStatusText)
            case "CertChain":
                assignProperties(object: item.value, icon: rootcertStatusIcon, spinner: rootcertSpinner, status: rootcertStatusText)
            case "Profiles":
                assignProperties(object: item.value, icon: configprofileStatusIcon, spinner: configprofileSpinner, status: configprofileStatusText)
            case "PasswordSync":
                assignProperties(object: item.value, icon: ecclStatusIcon, spinner: ecclSpinner, status: ecclStatus)
            case "Jamf":
                assignProperties(object: item.value, icon: jamfStatusIcon, spinner: jamfSpinner, status: jamfStatusText)
            case "Filevault":
                assignProperties(object: item.value, icon: fvStatusIcon, spinner: fvSpinner, status: fvStatus)
            default:
                logger.write("Could not find object: \(item.key)")
            }
            item.value.spinner?.startAnimation(self)
            item.value.spinner?.isHidden = false
            item.value.imageView?.image = #imageLiteral(resourceName: "warning")
            item.value.imageView?.isHidden = false
            item.value.statusLabel?.stringValue = "Checking..."
            
            
            // Prep all UI elements to a running state
            item.value.statusLabel?.stringValue = item.value.statusText
            
            if item.value.checkComplete {
                item.value.imageView?.image = item.value.success ? #imageLiteral(resourceName: "good"):#imageLiteral(resourceName: "bad")
                item.value.spinner?.isHidden = true
                item.value.spinner?.stopAnimation(self)
            } else {
                item.value.imageView?.image = #imageLiteral(resourceName: "warning")
            }
            
        }
    }
    
    func assignProperties(object: StatusCheckable, icon: NSImageView, spinner: NSProgressIndicator, status: NSTextField) {
        var object = object
        object.imageView = icon
        object.spinner = spinner
        object.statusLabel = status
    }
    
    func restartTimer() {
        //debugPrint("Stopping Status Checks Timer...")
        logger.write(AppConstants.Alerts.Timer.stop)
        GlobalTimer.sharedTimer.stopTimer()
        //debugPrint("Restarting Status Checks...")
        logger.write(AppConstants.Alerts.Timer.start)
        GlobalTimer.sharedTimer.startTimer(andJob: AppDelegate().statusTabChecks_Queue)
        
    }
    
    func StatusReset() {
        refreshButton.isEnabled = false
        // Clear check text to Checking
        for item in infoTabChecks {
            item.statusTextField.stringValue = "Checking..."
        }
        
        // Turn on Spinner and set text to Checking
        //for item in objectDict {
        for var item in checkObjectsDict {
            item.value.imageView?.image = #imageLiteral(resourceName: "warning")
            item.value.spinner?.startAnimation(self)
            item.value.spinner?.isHidden = false
            item.value.imageView?.image = nil
            item.value.statusLabel?.stringValue = "Checking..."
            item.value.checkComplete = false
        }
        
        //for item in networkInterFaces_Dict {
        for item in networkChecks {
            item.statustextfield?.stringValue = "Checking..."
            //item.statustextfield!.stringValue = "Checking..."
        }
        
    }
    
    
    func runInBackground() {
        infoTabChecks_runInBackgroundQueue()
        networkObjectChecks()
        //statusTabChecks_runInBackgroundGroup()
        //restartTimer()
    }
    
    func statusTabChecks_runInBackgroundGroup() {
        let group = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "FullAppWindow-StatusChecks")
        dispatchQueue.async {
            checkObjectsDict.forEach { (checkName, checkObject) in
                group.enter()
                logger.write("Throwing \(checkName) in the background.")
                checkObject.checkFunction()
                /*do {
                 try checkObject.checkFunction()
                 } catch let error {
                 logger.write("ERROR: failed to run check function for \(checkName), \(error.localizedDescription)")
                 }*/
                group.leave()
                
            }
        }
        
        group.notify(queue: dispatchQueue, execute: {
            DispatchQueue.main.async {
                self.refreshButton.isEnabled = true
            }
            
            
        })
        
        
    }
    
    func infoTabChecks_runInBackgroundQueue() {
        //let taskQueue = DispatchQueue.global(qos: .background)
        let taskQueue = DispatchQueue.init(label: "InfoTab-Checks", qos: .background)
        
        taskQueue.async {
            for item in self.infoTabChecks {
                logger.write("Running \(item.name)")
                item.checkFunction()
                DispatchQueue.main.async(execute: {
                    //item.statusTextField.stringValue = item.checkFunction()
                    
                    logger.write("Results for \(item.name) = \(item.statusTextField.stringValue)")
                    //debugPrint(item.statusTextField.stringValue)
                    
                })
            }
            
        }
    }
    
    func networkObjectChecks() {
        // debugPrint("Running Network Object Checks")
        for item in networkChecks {
            //debugPrint("Running network check for: \(item.interface)")
            let results = item.checkFunction(interface: item.interface)
            item.statustextfield?.stringValue = results
        }
        
        // Initialize and assign DNS to the iboutlet
        _ = GetDNS(statustext: dnsIP)
        
    }
}
