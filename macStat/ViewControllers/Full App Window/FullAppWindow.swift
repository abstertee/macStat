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
    @IBOutlet weak var pwExpires: NSTextField!
    
    
    lazy var infoTabChecks: [InfoCheckable] = {
        return [CurrentUser(statusTextField: currentUser, name: "CurrentUser"), ComputerName(statusTextField: computerName, name: "ComputerName"), WiFiName(statusTextField: wifi, name: "SSID"), UserAdmin(statusTextField: adminRights, name: "Admin"), SshMembership(statusTextField: sshMember, name: "SshMember"), GetRam(statusTextField: ramAvailable, name: "RAM"), GetHD(statusTextField: hdAvailable, name: "HardDrive"), WiFiBssid(statusTextField: apMac, name: "BSSID"), AccountType(statusTextField: accountType, name: "AccountType"), AdBound(statusTextField: adBound, name: "AdBound"),DaysPwExpire(statusTextField: pwExpires, name: "PasswordExpire")]
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



