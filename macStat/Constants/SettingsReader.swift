//
//  SettingsReader.swift
//  macStat
//
//  Created by Abraham Tarverdi on 8/30/19.
//  Copyright © 2019 Tarverdi Ent. All rights reserved.
//

import Foundation
/*  Swift Object that contains the Settings file information.
 
 */
//var appSettings = Plist()
let appSettings = Plist()
class Plist {
    var fileExists: Bool?
    var dict: [String:Any] = [:]
    
    private var settingsFilePath: String {
        return AppConstants.AppFiles.SettingsFile.path
    }
    
    init() {
        self.fileExists = doesPlistExist()
        if let filePathExists = fileExists {
            if filePathExists {
                self.dict = readPropertyList()
            }
        }
    }
    
    private func doesPlistExist() -> Bool {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: settingsFilePath) {
            return true
        } else {
            return false
        }
    }
    
    private func readPropertyList() -> [String: AnyObject] {
        var propertyListForamt =  PropertyListSerialization.PropertyListFormat.xml //Format of the Property List.
        var plistData: [String: AnyObject] = [:] //Our data
        let plistXML = FileManager.default.contents(atPath: settingsFilePath)!
        do { //convert the data to a dictionary and handle errors.
            plistData = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListForamt) as! [String:AnyObject]
        } catch {
            print("Error reading plist: \(error), format: \(propertyListForamt)")
        }
        return plistData
    }
}
