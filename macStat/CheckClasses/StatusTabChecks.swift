//
//  StatusTabChecks.swift
//  macStat
//
//  Created by Abraham Tarverdi on 8/30/19.
//  Copyright © 2019 Tarverdi Ent. All rights reserved.
//

import Foundation
import Cocoa

protocol StatusCheckable {
    var name: String { get }
    var imageView: NSImageView? { get set }
    var spinner: NSProgressIndicator? { get set }
    var statusLabel: NSTextField? { get set }
    var success: Bool { get set }
    var statusText: String {get set}
    var checkComplete: Bool { get set }
    func checkFunction()
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
class FirewallCheck: StatusCheckable {
    var name: String = "Firewall"
    var imageView: NSImageView?
    var spinner: NSProgressIndicator?
    var statusLabel: NSTextField?
    var success: Bool = false
    var statusText: String = "Checking..."
    var checkComplete: Bool = false
    
    public func checkFunction() {
        let command = "/usr/bin/defaults"
        shellcommand.shellHandler(command: command, args: ["read", "/Library/Preferences/com.apple.alf.plist", "globalstate"], completion: {
            (output,error,status) in
            self.success = !output.contains("0")
            //self.imageView?.image = self.success! ? #imageLiteral(resourceName: "good"):#imageLiteral(resourceName: "bad")
            self.statusText = "Firewall is " + (self.success ? "enabled" : "disabled")
            self.checkComplete = true
            self.checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
        })
    }
    
    private func checksCompletedUpdateUi(statusText: String,spinner: Bool,image: Bool, imageHidden: Bool) {
        DispatchQueue.main.async {
            //debugPrint("PasswordSync Checks Completed")
            self.statusLabel?.stringValue = statusText
            self.spinner?.stopAnimation(self)
            self.spinner?.isHidden = spinner
            self.imageView?.image = image ? #imageLiteral(resourceName: "good"):#imageLiteral(resourceName: "bad")
            self.imageView?.isHidden = imageHidden
        }
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
class CertsCheck: StatusCheckable {
    var name: String = "Certs"
    var imageView: NSImageView?
    var spinner: NSProgressIndicator?
    var statusLabel: NSTextField?
    var success: Bool = false
    var statusText: String = "Checking..."
    var checkComplete: Bool = false
    
    // Check for Certificate starts here
    func checkFunction() {
        let userName = NSUserName()
        
        if CertQuery.keychainQuery(commonName: userName) == false {
            logwriter.writeMessage(AppConstants.Alerts.StatusChecks.CertsCheck.missingCert, messageType: .failure)
            self.statusText = AppConstants.Alerts.StatusChecks.CertsCheck.missingCert
            self.checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
        }
        
        if CertQuery.certificateDetails(commonName: userName, oid: "2.5.29.17", searchString: "SCEP") == false {
            logwriter.writeMessage(AppConstants.Alerts.StatusChecks.CertsCheck.wrongCert, messageType: .failure)
            self.statusText = AppConstants.Alerts.StatusChecks.CertsCheck.wrongCert
            self.checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
        }
        self.success = true
        logwriter.writeMessage(AppConstants.Alerts.StatusChecks.CertsCheck.foundCert, messageType: .success)
        self.statusText = AppConstants.Alerts.StatusChecks.CertsCheck.foundCert
        self.checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
        
    }
    
    private func checksCompletedUpdateUi(statusText: String,spinner: Bool,image: Bool, imageHidden: Bool) {
        self.checkComplete = true
        DispatchQueue.main.async {
            //debugPrint("PasswordSync Checks Completed")
            self.statusLabel?.stringValue = statusText
            self.spinner?.stopAnimation(self)
            self.spinner?.isHidden = spinner
            self.imageView?.image = image ? #imageLiteral(resourceName: "good"):#imageLiteral(resourceName: "bad")
            self.imageView?.isHidden = imageHidden
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
class FileVaultCheck: StatusCheckable {
    var name: String = "Filevault"
    var imageView: NSImageView?
    var spinner: NSProgressIndicator?
    var statusLabel: NSTextField?
    var success: Bool = false
    var statusText: String = "Checking..."
    var checkComplete: Bool = false
    
    
    func checkFunction() {
        let command = "/usr/bin/fdesetup"
        shellcommand.shellHandler(command: command, args: ["status"], completion: {
            (output,error,status) in
            self.success = output.contains("On")
            if self.success {
                self.statusText = AppConstants.Alerts.StatusChecks.FileVault.enabled
            } else {
                self.statusText = AppConstants.Alerts.StatusChecks.FileVault.disabled
            }
            logger.write(self.statusText)
            self.checkComplete = true
            self.checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
        })
    }
    
    private func checksCompletedUpdateUi(statusText: String,spinner: Bool,image: Bool, imageHidden: Bool) {
        DispatchQueue.main.async {
            //debugPrint("PasswordSync Checks Completed")
            self.statusLabel?.stringValue = statusText
            self.spinner?.stopAnimation(self)
            self.spinner?.isHidden = spinner
            self.imageView?.image = image ? #imageLiteral(resourceName: "good"):#imageLiteral(resourceName: "bad")
            self.imageView?.isHidden = imageHidden
        }
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
class JamfCheck: StatusCheckable {
    var name: String = "Jamf"
    var imageView: NSImageView?
    var spinner: NSProgressIndicator?
    var statusLabel: NSTextField?
    var success: Bool = false
    var statusText: String = "Checking..."
    var checkComplete: Bool = false
    
    
    func checkFunction() {
        self.success = true
        self.statusText = AppConstants.Alerts.StatusChecks.JamfCheck.allGood
        
        // Check  if Jamf binaries are installed
        if FileManager.default.fileExists(atPath: "/usr/local/bin/jamf") == false {
            self.success = false
            self.imageView?.image = self.success ? #imageLiteral(resourceName: "good"):#imageLiteral(resourceName: "bad")
            self.statusText = AppConstants.Alerts.StatusChecks.JamfCheck.missingAgent
            self.checkComplete = true
            return
        }
        
        // Check if MDM profile is installed
        let mdmCheck = "/usr/bin/profiles"
        
        shellcommand.shellHandler(command: mdmCheck, args: ["-C"], completion: {
            (output,error,status) in
            self.checkComplete = true
            //var mdmProfileUuid: String = "00000000-0000-0000-0000-000000000000"
            guard let mdmProfileUuid = appSettings.dict[AppConstants.PlistKeys.mdmprofileUUID] as? String else {
                return
            }
            logger.write(mdmProfileUuid)
            if (output.lowercased().range(of: mdmProfileUuid.lowercased()) == nil) {
                self.success = false
                self.statusText = AppConstants.Alerts.StatusChecks.JamfCheck.missingMdmProfile
                self.checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
                return
            }
        })
        // Check if Connectivity exists
        let command = "/usr/local/bin/jamf"
        shellcommand.shellHandler(command: command, args: ["checkJSSConnection", "-retry", "2"], completion: {
            (output,error,status) in
            self.checkComplete = true
            if (output.lowercased().range(of: "available") == nil) {
                self.success = false
                self.statusText = AppConstants.Alerts.StatusChecks.JamfCheck.noConnection
                self.checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
                return
            }
            
        })
        self.checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
    }
    private func checksCompletedUpdateUi(statusText: String,spinner: Bool,image: Bool, imageHidden: Bool) {
        DispatchQueue.main.async {
            //debugPrint("PasswordSync Checks Completed")
            self.statusLabel?.stringValue = statusText
            self.spinner?.stopAnimation(self)
            self.spinner?.isHidden = spinner
            self.imageView?.image = image ? #imageLiteral(resourceName: "good"):#imageLiteral(resourceName: "bad")
            self.imageView?.isHidden = imageHidden
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
class PasswordSync: StatusCheckable {
    var name: String = "PasswordSync"
    var imageView: NSImageView?
    var spinner: NSProgressIndicator?
    var statusLabel: NSTextField?
    var success: Bool = false
    var statusText: String = "Checking..."
    var checkComplete: Bool = false
    
    
    // Check if Enterprise Connect is in sync
    func checkFunction() {
        //let eccl = "/Applications/Enterprise Connect.app/Contents/SharedSupport/eccl"
        if FileManager.default.fileExists(atPath: AppConstants.Alerts.StatusChecks.EnterpriseConnect.eccl) == false {
            self.success = false
            self.imageView?.image = self.success ? #imageLiteral(resourceName: "good"):#imageLiteral(resourceName: "bad")
            self.statusText = AppConstants.Alerts.StatusChecks.EnterpriseConnect.missingEC
            self.checkComplete = true
            return
        }
        
        //  If Enterprise Connect can't connect to a work network
        let result = shellcommand.shell(AppConstants.Alerts.StatusChecks.EnterpriseConnect.eccl, "-p", "connectionStatus")
        //debugPrint(result)
        let connectionStatus = Bool(shellcommand.shell(AppConstants.Alerts.StatusChecks.EnterpriseConnect.eccl, "-p", "connectionStatus").split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines))
        if connectionStatus == false {
            self.success = false
            self.statusText = AppConstants.Alerts.StatusChecks.EnterpriseConnect.connectionFailed
            self.checkComplete = true
            checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
            return
        }

        
        
        let signedInStatus = Bool(shellcommand.shell(AppConstants.Alerts.StatusChecks.EnterpriseConnect.eccl, "-p", "signedInStatus").split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines))
        // If user is not signed in to EC
        if signedInStatus == false {
            self.success = false
            self.statusText = AppConstants.Alerts.StatusChecks.EnterpriseConnect.userNotSignedIn
            self.checkComplete = true
            checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
            return
        }
        
        let pwExpireDate = Int((Double(shellcommand.shell(AppConstants.Alerts.StatusChecks.EnterpriseConnect.eccl, "-p", "adPasswordDaysUntilExpiration").split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines))?.rounded(.toNearestOrAwayFromZero))!)
        let pwInSync = Bool(shellcommand.shell(AppConstants.Alerts.StatusChecks.EnterpriseConnect.eccl, "-P").split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines))
        // If user's password is not in sync
        if pwInSync! == false {
            self.success = false
            self.statusText = AppConstants.Alerts.StatusChecks.EnterpriseConnect.passwordNotInSync
            self.checkComplete = true
            checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
            return
        }
        
        self.success = true
        //self.imageView?.image = self.success! ? #imageLiteral(resourceName: "good"):#imageLiteral(resourceName: "bad")
        self.statusText = "\(AppConstants.Alerts.StatusChecks.EnterpriseConnect.allGood) \(pwExpireDate) days."
        self.checkComplete = true
        checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
        
    }
    
    private func checksCompletedUpdateUi(statusText: String,spinner: Bool,image: Bool, imageHidden: Bool) {
        DispatchQueue.main.async {
            //debugPrint("PasswordSync Checks Completed")
            self.statusLabel?.stringValue = statusText
            self.spinner?.stopAnimation(self)
            self.spinner?.isHidden = spinner
            self.imageView?.image = image ? #imageLiteral(resourceName: "good"):#imageLiteral(resourceName: "bad")
            self.imageView?.isHidden = imageHidden
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
class ProfilesCheck: StatusCheckable {
    var name: String = "Profiles"
    var imageView: NSImageView?
    var spinner: NSProgressIndicator?
    var statusLabel: NSTextField?
    var success: Bool = false
    var statusText: String = "Checking..."
    var checkComplete: Bool = false
    
    
    // Check if WiFi config Profile exists
    func checkFunction() {
        guard let wifiUUID = appSettings.dict[AppConstants.PlistKeys.userWifiProfileUuid] as? String else {
            return
        }
        guard let usercertUUID = appSettings.dict[AppConstants.PlistKeys.userCertificate] as? String else {
            return
        }
        
        logger.write("UUIDs from Settings file: \(wifiUUID) AND \(usercertUUID)")
        // If the settings file is missing this value it will return bad
        if wifiUUID.isEmpty || usercertUUID.isEmpty {
            self.success = false
            self.statusText = AppConstants.AppFiles.SettingsFileDoesNotExist
            self.checkComplete = true
            return
        }
        
        let results = shellcommand.shell("/usr/bin/profiles","-L")
        //debugPrint(output.components(separatedBy: "profileIdentifier: "))
        if results.contains(wifiUUID) == false{
            logger.write(AppConstants.Alerts.StatusChecks.Profiles.missingWiFiProfile)
            self.success = false
            self.statusText = AppConstants.Alerts.StatusChecks.Profiles.missingWiFiProfile
        } else if results.contains(usercertUUID) == false {
            logger.write(AppConstants.Alerts.StatusChecks.Profiles.missingCertProfile)
            //debugPrint("User does not have the user cert profile installed")
            self.success = false
            self.statusText = AppConstants.Alerts.StatusChecks.Profiles.missingCertProfile
        } else {
            self.success = true
            self.statusText = AppConstants.Alerts.StatusChecks.Profiles.missingAll
        }
        self.checkComplete = true
        checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
    }
    
    private func checksCompletedUpdateUi(statusText: String,spinner: Bool,image: Bool, imageHidden: Bool) {
        DispatchQueue.main.async {
            //debugPrint("PasswordSync Checks Completed")
            self.statusLabel?.stringValue = statusText
            self.spinner?.stopAnimation(self)
            self.spinner?.isHidden = spinner
            self.imageView?.image = image ? #imageLiteral(resourceName: "good"):#imageLiteral(resourceName: "bad")
            self.imageView?.isHidden = imageHidden
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////

class CertChainCheck: StatusCheckable {
    var name: String = "CertChain"
    var imageView: NSImageView?
    var spinner: NSProgressIndicator?
    var statusLabel: NSTextField?
    var success: Bool = false
    var statusText: String = "Checking..."
    var checkComplete: Bool = false
    
    
    // Check if Certificate Chain exists
    func checkFunction() {
        guard let certArray = appSettings.dict[AppConstants.PlistKeys.certChain] as? [String] else {
            self.success = false
            self.statusText = AppConstants.AppFiles.SettingsFileDoesNotExist
            return
        }
        //debugPrint("Here are the certs: \(certArray)")
        var rootcertsDict = [String: Bool]()
        var returnText = [String]()
        // Check if settings file contains the cert chain array of cert names
        if appSettings.dict[AppConstants.PlistKeys.certChain] as? NSArray? == nil{
            self.success = false
            self.statusText = AppConstants.AppFiles.SettingsFileDoesNotExist
        }
        
        for item in certArray {
            logger.write("Running check for root cert: \(item)" )
            if CertQuery.keychainQuery(commonName: item) {
                rootcertsDict.updateValue(true, forKey: item)
            } else {
                rootcertsDict.updateValue(false, forKey: item)
                logger.write("\(AppConstants.Alerts.StatusChecks.CertChain.missingThisCert) \(item)")
                returnText.append(item)
            }
        }
        
        self.success = returnText.isEmpty
        if returnText.isEmpty {
            self.statusText = AppConstants.Alerts.StatusChecks.CertChain.allGood
        } else {
            let returnString = returnText.joined(separator: ", ")
            self.statusText = "\(AppConstants.Alerts.StatusChecks.CertChain.missingRoot) \(returnString)"
        }
        checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
    }
    private func checksCompletedUpdateUi(statusText: String,spinner: Bool,image: Bool, imageHidden: Bool) {
        self.checkComplete = true
        DispatchQueue.main.async {
            //debugPrint("PasswordSync Checks Completed")
            self.statusLabel?.stringValue = statusText
            self.spinner?.stopAnimation(self)
            self.spinner?.isHidden = spinner
            self.imageView?.image = image ? #imageLiteral(resourceName: "good"):#imageLiteral(resourceName: "bad")
            self.imageView?.isHidden = imageHidden
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
class UpdatesCheck: StatusCheckable {
    var name: String = "Updates"
    var imageView: NSImageView?
    var spinner: NSProgressIndicator?
    var statusLabel: NSTextField?
    var success: Bool = false
    var statusText: String = "Checking..."
    var shortCheck: Bool
    var checkComplete: Bool = false
    
    init(){
        self.shortCheck = false
        //checkFunction()
        
    }
    
    func checkFunction() {
        //let results = shellcommand.shell("softwareupdate", "-l")
        let args = ["-l"]
        let command = "/usr/sbin/softwareupdate"
        if self.shortCheck {
            let args = ["-l","--no-scan"]
        }
        
        Reachability.isConnectedToNetwork({
            internetConnected in
            if internetConnected == false {
                //debugPrint("Running short check")
                logger.write(AppConstants.Alerts.StatusChecks.OsUpdates.noInternetConnection)
                self.statusText = AppConstants.Alerts.StatusChecks.OsUpdates.noInternetConnection
                self.checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
                return
                //let args = ["-l","--no-scan"]
            }
        })
        
        shellcommand.shellHandler(command: command, args: args, completion: {
            (output,error,status) in
            //print(output)
            self.success = true
            
            if output.contains("No new software available.") {
                self.success = true
                //debugPrint("Found No New Software \(self.success)")
                self.statusText = AppConstants.Alerts.StatusChecks.OsUpdates.noUpdates
            }
            if output.isEmpty {
                self.success = true
                //debugPrint("2nd timeFound No New Software \(self.success)")
                self.statusText = AppConstants.Alerts.StatusChecks.OsUpdates.noUpdates
            }
            
            let availableUpdates: String = {
                var updates = [String]()
                for line in output.components(separatedBy: "\n") {
                    if line.contains("*") {
                        updates.append(line)
                    }
                }
                if updates.joined(separator: ", ").isEmpty {
                    return AppConstants.Alerts.StatusChecks.OsUpdates.noUpdates
                } else {
                    self.success = false
                }
                return updates.joined(separator: ", ")
            }()
            self.checkComplete = true
            self.statusText = availableUpdates
            self.checksCompletedUpdateUi(statusText: self.statusText, spinner: true, image: self.success, imageHidden: false)
            
        })
    }
    private func checksCompletedUpdateUi(statusText: String,spinner: Bool,image: Bool, imageHidden: Bool) {
        DispatchQueue.main.async {
            //debugPrint("PasswordSync Checks Completed")
            self.statusLabel?.stringValue = statusText
            self.spinner?.stopAnimation(self)
            self.spinner?.isHidden = spinner
            self.imageView?.image = image ? #imageLiteral(resourceName: "good"):#imageLiteral(resourceName: "bad")
            self.imageView?.isHidden = imageHidden
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////

var firewallcheck = FirewallCheck()
var certscheck = CertsCheck()
var filevaultcheck = FileVaultCheck()
var jamfcheck = JamfCheck()
var passwordsync = PasswordSync()
var profilescheck = ProfilesCheck()
var certchaincheck = CertChainCheck()
var updatescheck = UpdatesCheck()

var checkObjectsDict: [String:StatusCheckable] = {
    
    return[firewallcheck.name:firewallcheck, certscheck.name:certscheck, filevaultcheck.name:filevaultcheck, jamfcheck.name:jamfcheck, passwordsync.name:passwordsync, profilescheck.name:profilescheck, certchaincheck.name:certchaincheck, updatescheck.name:updatescheck]
}()

