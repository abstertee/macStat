//
//  AppConstants.swift
//  macStat
//
//  Created by Abraham Tarverdi on 8/30/19.
//  Copyright © 2019 Tarverdi Ent. All rights reserved.
//

import Foundation

struct AppConstants {
    
    struct Preferences {
        
        static var version:String {
            return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        }
        
    }
    struct AppFiles {
        static let ApplicationDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .systemDomainMask)[0].appendingPathComponent("MacStat")
        static let SettingsFile = ApplicationDirectory.appendingPathComponent("Settings.plist")
        static let SettingsFileDoesNotExist = "Settings File did not exist and no arguments were passed to specify where the file is at.  Prompting user and exiting."
        static let ApplicationLog = ApplicationDirectory.appendingPathComponent("macstat.log")
    }
    
    struct NotificationText {
        static let Title = "MacStat App"
        static let SubTitle = "Out of Compliance"
        static let HasActionButton = false
        static let OtherButtonTitle = "Close"
        static let ActionButtonTitle = "Show"
        
    }
    
    struct Alerts {
        struct AppDelegate {
            static let noArgs = "No arguments are passed."
        }
        struct PlistEntry {
            static let notExist = "Entry does not exist in the Settings file."
        }
        struct Timer {
            static let stop = "Stopping Status Checks Timer..."
            static let start = "Starting Status Checks..."
        }
        
        struct StatusChecks {
            struct CertChain {
                static let missingThisCert = "Missing the following root certificate: "
                static let allGood = "Certificate chain is installed."
                static let missingRoot = "The system is missing Root Certificate(s):"
            }
            struct CertsCheck {
                static let missingCert = "Missing User Certificate in user's login.keychain"
                static let foundCert = "User Certificate found in user's login.keychain"
                static let wrongCert = "Found User certificate NOT issued by Endpoint Management Tool."
            }
            struct FileVault {
                static let enabled = "FileVault is Enabled."
                static let disabled = "FileVault is Disabled."
            }
            struct JamfCheck {
                static let missingMdmProfile = "System is missing the MDM Enrollment Profile.  Please re-enroll the system."
                static let noConnection = "There is no connectivity to the JSS. Check your internet connection."
                static let allGood = "JAMF Installed & System Enrolled."
                static let missingAgent = "JAMF agent Not Installed. Please re-install Jamf agent."
            }
            struct EnterpriseConnect {
                static let eccl = "/Applications/Enterprise Connect.app/Contents/SharedSupport/eccl"
                static let missingEC = "Could not find Enterprise Connect"
                static let connectionFailed = "Enterprise Connect can't connect to network."
                static let userNotSignedIn = "User is not signed in to Enterprise Connect."
                static let passwordNotInSync = "User password not in sync with Domain account."
                static let allGood = "User password in sync and will need to be changed in "
            }
            struct Profiles {
                static let missingWiFiProfile = "User does not have the wifi profile installed"
                static let missingCertProfile = "User does not have the user cert profile installed"
                static let missingAll = "User Cert Profile and WiFi 802.1x Profile both exist for this user."
            }
            
            struct OsUpdates {
                static let shortCheck = "Running short check."
                static let noUpdates = "No pending updates"
                static let noInternetConnection = "No internet connection available to check with Apple."
                
            }
        }
        
    }
    
    struct PlistKeys {
        static let documentationUrl = "documentationUrl"
        static let mdmprofileUUID = "mdmprofileUUID"
        static let logopath = "logopath"
        static let userWifiProfileUuid = "userWifiProfileUuid"
        static let userCertificate = "userCertificate"
        static let certChain = "certChain"
        static let notificationSettings = "notificationSettings"
        static let notificationTimer = "notificationTimer"
        static let notificationOn = "notificationOn"
    }
}
