//
//  InfoTabChecks.swift
//  macStat
//
//  Created by Abraham Tarverdi on 8/30/19.
//  Copyright © 2019 Tarverdi Ent. All rights reserved.
//

import Foundation
import SystemConfiguration
import CoreWLAN
import CoreLocation
import Cocoa

protocol InfoCheckable {
    var statusTextField: NSTextField { get set }
    var name: String { get set }
    func checkFunction()
    
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
struct CurrentUser : InfoCheckable {
    var statusTextField: NSTextField
    var name: String
    func checkFunction() {
        let username = NSUserName()
        //debugPrint("Result of Current user: \(username)")
        DispatchQueue.main.async {
            self.statusTextField.stringValue = username
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
struct ComputerName: InfoCheckable {
    
    var statusTextField: NSTextField
    var name: String
    
    func checkFunction() {
        let hostname = Host.current().localizedName ?? "No HostName"
        //debugPrint("Result of host user: \(hostname)")
        DispatchQueue.main.async {
            self.statusTextField.stringValue = hostname
        }
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
struct WiFiName: InfoCheckable {
    var statusTextField: NSTextField
    var name: String
    
    func checkFunction() {
        let ssidName = CWWiFiClient().interface(withName: nil)?.ssid() ?? "No WiFi Connection"
        //debugPrint("Result of Wifi: \(ssidName)")
        DispatchQueue.main.async {
            self.statusTextField.stringValue = ssidName
        }
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
struct WiFiBssid: InfoCheckable {
    var statusTextField: NSTextField
    var name: String
    
    func checkFunction() {
        //debugPrint("Getting BSSID Now")
        if CLLocationManager.locationServicesEnabled() == false {
            // Location Services are disabled so need to get BSSID the old fashion way.
            let output = shellcommand.shell("/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport", "-I").split(separator: "\n")
            var airportDictionary = [String:String]()
            for item in output {
                let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
                let fixed = trimmed.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
                airportDictionary[String(fixed[0])] = String(fixed[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            guard let bssid = airportDictionary["BSSID"] else {
                DispatchQueue.main.async {
                    self.statusTextField.stringValue = "Unknown"
                }
                return
            }
            DispatchQueue.main.async {
                self.statusTextField.stringValue = bssid
            }
            
        }
        
        let wifi = CWWiFiClient.shared()
        guard let interface = wifi.interface() else {
            DispatchQueue.main.async { self.statusTextField.stringValue = "No WiFi Card" }
            return
        }
        
        guard let bssid = interface.bssid() else {
            DispatchQueue.main.async { self.statusTextField.stringValue = "Unknown" }
            return
        }
        
        DispatchQueue.main.async { self.statusTextField.stringValue = bssid }
        
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
struct GetRam: InfoCheckable {
    var statusTextField: NSTextField
    var name: String
    
    func checkFunction()  {
        let totalRAM = ProcessInfo.processInfo.physicalMemory
        let ram = ByteCountFormatter.string(fromByteCount: Int64(totalRAM), countStyle: .memory)
        //debugPrint("Rsults from RAM: \(totalRAM) \(ram)")
        DispatchQueue.main.async { self.statusTextField.stringValue = ram }
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
struct GetHD: InfoCheckable {
    var statusTextField: NSTextField
    var name: String
    
    func checkFunction()  {
        do {
            let du = try FileManager.default.attributesOfFileSystem(forPath: "/")
            if let size = du[FileAttributeKey.systemFreeSize] as? Int64 {
                let fileSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
                logger.write("Hard drive space avaialble: \(fileSize)")
                if size <= 10 {
                    //debugPrint("Hard drive space is: \(fileSize)")
                    DispatchQueue.main.async { self.statusTextField.stringValue = "\(fileSize), LOW SPACE!" }
                } else {
                    //debugPrint("Hard drive space in else statement is: \(fileSize)")
                    DispatchQueue.main.async { self.statusTextField.stringValue = fileSize }
                }
            }
            //debugPrint(du)
            logger.write("Could not getHD as du was empty")
        }
        catch {
            //debugPrint(error)
            logger.write((error as? String)!)
            DispatchQueue.main.async { self.statusTextField.stringValue = "Check Failed" }
        }
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
struct UserAdmin: InfoCheckable {
    var statusTextField: NSTextField
    var name: String
    
    func checkFunction() {
        let adminGroupMembership = shellcommand.shell("/usr/bin/dscl", ".", "-read", "/Groups/admin", "GroupMembership")
        guard adminGroupMembership.contains(NSUserName()) else {
            logger.write("User is NOT an Admin")
            //debugPrint("User admin in guard statement: \(adminGroupMembership)")
            DispatchQueue.main.async { self.statusTextField.stringValue =  "User is NOT an Admin" }
            return
        }
        //debugPrint("User admin: \(adminGroupMembership)")
        DispatchQueue.main.async { self.statusTextField.stringValue = "User is an Admin" }
    }
    
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
struct SshMembership: InfoCheckable {
    var statusTextField: NSTextField
    var name: String
    
    func checkFunction() {
        //let sshMembers = shellcommand.shell("/usr/bin/dscl", ".", "-read", "/Groups/com.apple.access_ssh", "GroupMembership")
        shellcommand.shellHandler(command: "/usr/bin/dscl", args: [".", "-read", "/Groups/com.apple.access_ssh", "GroupMembership"], completion:{
            (output,error,status) in
            if status != 0 {
                logwriter.writeMessage("Failed to run dscl command.", messageType: .failure)
                DispatchQueue.main.async { self.statusTextField.stringValue = "Command Failed" }
                return
            }
            
            if output.isEmpty {
                logger.write("SSHMembers failed to find user \(NSUserName()) in group.")
                //debugPrint("SSH member is no")
                DispatchQueue.main.async { self.statusTextField.stringValue = "User Not in Group" }
                return
            }
            
            if output.contains(NSUserName()) {
                logger.write("SSHMembers ran and found user \(NSUserName()) in group.")
                //debugPrint("SSH member is yes")
                DispatchQueue.main.async { self.statusTextField.stringValue = "Yes" }
            }
            
        })
        
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
struct AccountType: InfoCheckable {
    var statusTextField: NSTextField
    var name: String
    
    func checkFunction() {
        //let output = shellcommand.shell("/usr/bin/dscl", ".", "read", "/Users/\(NSUserName())", "OriginalNodeName")
        shellcommand.shellHandler(command: "/usr/bin/dscl", args: [".", "read", "/Users/\(NSUserName())", "OriginalNodeName"], completion:{
            (output,error,status) in
            if output.isEmpty {
                DispatchQueue.main.async { self.statusTextField.stringValue = "Local Account" }
            } else {
                DispatchQueue.main.async { self.statusTextField.stringValue = "Mobile Account" }
            }
        })
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
struct AdBound: InfoCheckable {
    var statusTextField: NSTextField
    var name: String
    
    func checkFunction()  {
        let plistPath = "/tmp/dsconf.plist"
        _ = FileManager.default.createFile(atPath: plistPath, contents: shellcommand.shell("/usr/sbin/dsconfigad", "-show", "-xml").data(using: .utf8), attributes: nil)
        /*guard let outputplist = NSDictionary(contentsOfFile: plistPath) else {
         DispatchQueue.main.async { self.statusTextField.stringValue = "Not Bound" }
         return
         }*/
        let outputplist = readPropertyList(propertyListFile: plistPath)
        debugPrint(outputplist)
        if outputplist.isEmpty {
            DispatchQueue.main.async { self.statusTextField.stringValue = "Not Bound" }
            return
        }
        guard let array = outputplist["General Info"] else {
            DispatchQueue.main.async { self.statusTextField.stringValue = "Check Failed" }
            return
        }
        let arrayDict = array as! [String:AnyObject]
        debugPrint(arrayDict)
        do {
            try FileManager.default.removeItem(atPath: plistPath)
        } catch {
            debugPrint(error)
            DispatchQueue.main.async { self.statusTextField.stringValue = "Check Failed" }
        }
        guard let output = arrayDict["Computer Account"] else {
            DispatchQueue.main.async { self.statusTextField.stringValue = "Not Bound" }
            return
        }
        
        DispatchQueue.main.async { self.statusTextField.stringValue = output as! String }
        
    }
    
    private func readPropertyList(propertyListFile: String) -> [String: AnyObject] {
        var propertyListForamt =  PropertyListSerialization.PropertyListFormat.xml //Format of the Property List.
        var plistData: [String: AnyObject] = [:] //Our data
        let plistXML = FileManager.default.contents(atPath: propertyListFile)!
        do { //convert the data to a dictionary and handle errors.
            plistData = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListForamt) as! [String:AnyObject]
        } catch {
            debugPrint("Error reading plist: \(error), format: \(propertyListForamt)")
        }
        return plistData
    }
}



