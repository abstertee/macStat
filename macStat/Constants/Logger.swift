//
//  Logger.swift
//  macStat
//
//  Created by Abraham Tarverdi on 8/30/19.
//  Copyright © 2019 Tarverdi Ent. All rights reserved.
//

import Foundation
let logger = Log()
struct Log {
    
    private var fileExists: Bool = false
    private var logFile: URL = AppConstants.AppFiles.ApplicationLog
    
    init() {
        checkLogFile()
    }
    
    private mutating func checkLogFile() {
        let fm = FileManager.default
        //logFile = AppConstants.AppFiles.ApplicationLog
        // Check if Path exists and create if not
        if fm.fileExists(atPath: self.logFile.path) {
            self.fileExists = true
            return
        } else {
            do {
                debugPrint("File did not exist \(fm.fileExists(atPath: self.logFile.path))")
                try fm.createFile(atPath: logFile.path, contents: nil, attributes: nil)
            }
            catch let error as NSError {
                debugPrint("Could not create the logging file: \(error)")
                self.fileExists = false
                return
            }
        }
    }
    
    
    func write(_ entry: String) {
        
        // Setup the timestamp stuff
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeStamp = formatter.string(from: now)
        
        if self.fileExists {
            var dump = ""
            dump = try! String(contentsOfFile: (logFile.path), encoding: String.Encoding.utf8)
            do {
                if let fileHandle = try? FileHandle(forWritingTo: self.logFile) {
                    fileHandle.seekToEndOfFile()
                    // Write to the file
                    fileHandle.write(timeStamp.data(using: .utf8)! + " ".data(using: .utf8)! + entry.data(using: .utf8)! + "\n".data(using: .utf8)!)
                } else {
                    try? "\(dump)\n\(timeStamp) \(entry)".write(to: logFile, atomically: true, encoding: String.Encoding.utf8)
                }
            }
            catch let error as NSError {
                print("Failed writing to log file: \(String(describing: logFile.path)), Error: " + error.localizedDescription)
            }
        }
    }
    
}

enum OutputType {
    case failure
    case success
}
var logwriter = LogWriter()
class LogWriter {
    func writeMessage(_ message: String, messageType: OutputType = .success) {
        switch messageType {
        case .success:
            logger.write(message)
        case .failure:
            logger.write(message)
        }
    }
}


