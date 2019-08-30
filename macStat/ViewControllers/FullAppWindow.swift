//
//  FullAppWindow.swift
//  macStat
//
//  Created by Abraham Tarverdi on 8/30/19.
//  Copyright © 2019 Tarverdi Ent. All rights reserved.
//

import Foundation
import Cocoa


class FullAppWindow: NSViewController {
    
    
    // Status-Tab Spinners
    @IBOutlet weak var jamfSpinner: NSProgressIndicator!
    @IBOutlet weak var firewallSpinner: NSProgressIndicator!
    @IBOutlet weak var softupdateSpinner: NSProgressIndicator!
    @IBOutlet weak var certSpinner: NSProgressIndicator!
    @IBOutlet weak var ecclSpinner: NSProgressIndicator!
    @IBOutlet weak var fvSpinner: NSProgressIndicator!
    @IBOutlet weak var rootcertSpinner: NSProgressIndicator!
    @IBOutlet weak var configprofileSpinner: NSProgressIndicator!
    
    // Status-Tab  Status Icons - Green Check Mark or Red X Symbol
    @IBOutlet weak var fvStatusIcon: NSImageView!
    @IBOutlet weak var certStatusIcon: NSImageView!
    @IBOutlet weak var jamfStatusIcon: NSImageView!
    @IBOutlet weak var ecclStatusIcon: NSImageView!
    @IBOutlet weak var firewallStatusIcon: NSImageView!
    @IBOutlet weak var softupdateStatusIcon: NSImageView!
    @IBOutlet weak var rootcertStatusIcon: NSImageView!
    @IBOutlet weak var configprofileStatusIcon: NSImageView!
    
    // Status-Tab status Text
    @IBOutlet weak var fvStatus: NSTextField!
    @IBOutlet weak var ecclStatus: NSTextField!
    @IBOutlet weak var firewallStatus: NSTextField!
    @IBOutlet weak var jamfStatusText: NSTextField!
    @IBOutlet weak var certStatus: NSTextField!
    @IBOutlet weak var softwareupdateStatusText: NSTextField!
    @IBOutlet weak var rootcertStatusText: NSTextField!
    @IBOutlet weak var configprofileStatusText: NSTextField!
    @IBOutlet weak var appVersion: NSTextField!
    
    // Status-Tab  Icons
    @IBOutlet weak var fvImage: NSImageView!
    @IBOutlet weak var jamfImage: NSImageView!
    @IBOutlet weak var adImage: NSImageView!
    @IBOutlet weak var certImage: NSImageView!
    @IBOutlet weak var rootcertImage: NSImageView!
    
    // Info-Tab
    @IBOutlet weak var currentUser: NSTextField!
    @IBOutlet weak var computerName: NSTextField!
    @IBOutlet weak var adminRights: NSTextField!
    @IBOutlet weak var wifi: NSTextField!
    @IBOutlet weak var wifiIP: NSTextField!
    @IBOutlet weak var ethernetIP: NSTextField!
    @IBOutlet weak var apMac: NSTextField!
    @IBOutlet weak var info_tab: NSTabViewItem!
    @IBOutlet weak var status_tab: NSTabViewItem!
    @IBOutlet weak var gpvpnIP: NSTextField!
    @IBOutlet weak var dnsIP: NSTextField!
    @IBOutlet weak var sshMember: NSTextField!
    @IBOutlet weak var ramAvailable: NSTextField!
    @IBOutlet weak var hdAvailable: NSTextField!
    @IBOutlet weak var accountType: NSTextField!
    @IBOutlet weak var adBound: NSTextField!
    //@IBOutlet weak var helpButton: NSButton!
    @IBOutlet weak var refreshButton: NSButton!
    
    lazy var infoTabChecks: [InfoCheckable] = {
        return [CurrentUser(statusTextField: currentUser, name: "CurrentUser"), ComputerName(statusTextField: computerName, name: "ComputerName"), WiFiName(statusTextField: wifi, name: "SSID"), UserAdmin(statusTextField: adminRights, name: "Admin"), SshMembership(statusTextField: sshMember, name: "SshMember"), GetRam(statusTextField: ramAvailable, name: "RAM"), GetHD(statusTextField: hdAvailable, name: "HardDrive"), WiFiBssid(statusTextField: apMac, name: "BSSID"), AccountType(statusTextField: accountType, name: "AccountType"), AdBound(statusTextField: adBound, name: "AdBound")]
    }()
    
    lazy var networkChecks = {
        return [GetIPs(statustextfield: ethernetIP, interface: "Ethernet"), GetIPs(statustextfield: wifiIP, interface: "IEEE80211"), GetIPs(statustextfield: gpvpnIP, interface: "gpd0")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let version: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        appVersion.stringValue = version
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.popover.close()
        appDelegate.popover.accessibilityActivationPoint()
        refreshButton.isEnabled = true
        assignIbOutlets()
    }
    
    
    override func viewDidAppear() {
        //refreshView(self)
        runInBackground()
    }
    
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
    
    
    @IBAction func helpButtonPush(_ sender: Any) {
        logger.write("Help Button was pressed")
        if appSettings.dict[AppConstants.PlistKeys.documentationUrl] as? String == nil {
            logger.write("Documentation URL \(AppConstants.Alerts.PlistEntry.notExist)")
            //debugPrint("found NIL in appsettings")
        }
        else {
            let url = URL(string: (appSettings.dict[AppConstants.PlistKeys.documentationUrl] as? String)!)
            logger.write("Launching the default browser to \(url!)")
            NSWorkspace.shared.open(url!)
        }
        
    }
    
    // This function handles what happens when you click the refresh button.
    @IBAction func refreshView(_ sender: Any) {
        StatusReset()
        //refreshButton.isEnabled = false
        infoTabChecks_runInBackgroundQueue()
        networkObjectChecks()
        statusTabChecks_runInBackgroundGroup()
        //runInBackground()
        
    }
}



