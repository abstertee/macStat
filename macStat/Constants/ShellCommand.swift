//
//  ShellCommand.swift
//  macStat
//
//  Created by Abraham Tarverdi on 8/30/19.
//  Copyright © 2019 Tarverdi Ent. All rights reserved.
//

import Foundation
let shellcommand = ShellCommand()
class ShellCommand {
    
    //Function to run a terminal command and return the output as String
    func shell(_ command: String, _ args: String...) -> String {
        let task = Process()
        //task.launchPath = "/usr/bin/env"
        task.launchPath = command
        task.arguments = args
        let pipe = Pipe()
        task.standardOutput = pipe
        //task.launch()
        do {
            try task.run()
        } catch {
            return ("Error: \(error.localizedDescription)")
        }
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        
        return (output as String)
        //return task.terminationStatus
    }
    
    func shellHandler(command: String, args: Array<String>, completion: @escaping (String, String, Int32) -> Void) {
        let task = Process()
        task.launchPath = command
        task.arguments = args
        let outpipe = Pipe()
        let errpipe = Pipe()
        task.standardOutput = outpipe
        task.standardError = errpipe
        //task.launch()
        do {
            try task.run()
        } catch {
            completion("","Error: \(error.localizedDescription)", 1)
        }
        
        let data = outpipe.fileHandleForReading.readDataToEndOfFile()
        guard let output: String = String(data: data, encoding: .utf8) else {
            completion("","Error: Return Value Not Converted",1)
            return
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        guard let error: String = String(data: errdata, encoding: .utf8) else {
            completion("","Error: error data not converted.",1)
            return
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        completion(output, error, status)
    }
    
}

public struct Sysctl {
    /// Possible errors.
    public enum Error: Swift.Error {
        case unknown
        case malformedUTF8
        case invalidSize
        case posixError(POSIXErrorCode)
    }
    
    /// Access the raw data for an array of sysctl identifiers.
    public static func data(for keys: [Int32]) throws -> [Int8] {
        return try keys.withUnsafeBufferPointer() { keysPointer throws -> [Int8] in
            // Preflight the request to get the required data size
            var requiredSize = 0
            let preFlightResult = Darwin.sysctl(UnsafeMutablePointer<Int32>(mutating: keysPointer.baseAddress), UInt32(keys.count), nil, &requiredSize, nil, 0)
            if preFlightResult != 0 {
                throw POSIXErrorCode(rawValue: errno).map {
                    print($0.rawValue)
                    return Error.posixError($0)
                    } ?? Error.unknown
            }
            
            // Run the actual request with an appropriately sized array buffer
            let data = Array<Int8>(repeating: 0, count: requiredSize)
            let result = data.withUnsafeBufferPointer() { dataBuffer -> Int32 in
                return Darwin.sysctl(UnsafeMutablePointer<Int32>(mutating: keysPointer.baseAddress), UInt32(keys.count), UnsafeMutableRawPointer(mutating: dataBuffer.baseAddress), &requiredSize, nil, 0)
            }
            if result != 0 {
                throw POSIXErrorCode(rawValue: errno).map { Error.posixError($0) } ?? Error.unknown
            }
            
            return data
        }
    }
    
    /// Convert a sysctl name string like "hw.memsize" to the array of `sysctl` identifiers (e.g. [CTL_HW, HW_MEMSIZE])
    public static func keys(for name: String) throws -> [Int32] {
        var keysBufferSize = Int(CTL_MAXNAME)
        var keysBuffer = Array<Int32>(repeating: 0, count: keysBufferSize)
        try keysBuffer.withUnsafeMutableBufferPointer { (lbp: inout UnsafeMutableBufferPointer<Int32>) throws in
            try name.withCString { (nbp: UnsafePointer<Int8>) throws in
                guard sysctlnametomib(nbp, lbp.baseAddress, &keysBufferSize) == 0 else {
                    throw POSIXErrorCode(rawValue: errno).map { Error.posixError($0) } ?? Error.unknown
                }
            }
        }
        if keysBuffer.count > keysBufferSize {
            keysBuffer.removeSubrange(keysBufferSize..<keysBuffer.count)
        }
        return keysBuffer
    }
    
    /// Invoke `sysctl` with an array of identifers, interpreting the returned buffer as the specified type. This function will throw `Error.invalidSize` if the size of buffer returned from `sysctl` fails to match the size of `T`.
    public static func value<T>(ofType: T.Type, forKeys keys: [Int32]) throws -> T {
        let buffer = try data(for: keys)
        if buffer.count != MemoryLayout<T>.size {
            throw Error.invalidSize
        }
        return try buffer.withUnsafeBufferPointer() { bufferPtr throws -> T in
            guard let baseAddress = bufferPtr.baseAddress else { throw Error.unknown }
            return baseAddress.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
        }
    }
    
    /// Invoke `sysctl` with an array of identifers, interpreting the returned buffer as the specified type. This function will throw `Error.invalidSize` if the size of buffer returned from `sysctl` fails to match the size of `T`.
    public static func value<T>(ofType type: T.Type, forKeys keys: Int32...) throws -> T {
        return try value(ofType: type, forKeys: keys)
    }
    
    /// Invoke `sysctl` with the specified name, interpreting the returned buffer as the specified type. This function will throw `Error.invalidSize` if the size of buffer returned from `sysctl` fails to match the size of `T`.
    public static func value<T>(ofType type: T.Type, forName name: String) throws -> T {
        return try value(ofType: type, forKeys: keys(for: name))
    }
    
    /// Invoke `sysctl` with an array of identifers, interpreting the returned buffer as a `String`. This function will throw `Error.malformedUTF8` if the buffer returned from `sysctl` cannot be interpreted as a UTF8 buffer.
    public static func string(for keys: [Int32]) throws -> String {
        let optionalString = try data(for: keys).withUnsafeBufferPointer() { dataPointer -> String? in
            dataPointer.baseAddress.flatMap { String(validatingUTF8: $0) }
        }
        guard let s = optionalString else {
            throw Error.malformedUTF8
        }
        return s
    }
    
    /// Invoke `sysctl` with an array of identifers, interpreting the returned buffer as a `String`. This function will throw `Error.malformedUTF8` if the buffer returned from `sysctl` cannot be interpreted as a UTF8 buffer.
    public static func string(for keys: Int32...) throws -> String {
        return try string(for: keys)
    }
    
    /// Invoke `sysctl` with the specified name, interpreting the returned buffer as a `String`. This function will throw `Error.malformedUTF8` if the buffer returned from `sysctl` cannot be interpreted as a UTF8 buffer.
    public static func string(for name: String) throws -> String {
        return try string(for: keys(for: name))
    }
    
    /// e.g. "MyComputer.local" (from System Preferences -> Sharing -> Computer Name) or
    /// "My-Name-iPhone" (from Settings -> General -> About -> Name)
    public static var hostName: String { return try! Sysctl.string(for: [CTL_KERN, KERN_HOSTNAME]) }
    
    /// e.g. "x86_64" or "N71mAP"
    /// NOTE: this is *corrected* on iOS devices to fetch hw.model
    public static var machine: String {
        #if os(iOS) && !arch(x86_64) && !arch(i386)
        return try! Sysctl.string(for: [CTL_HW, HW_MODEL])
        #else
        return try! Sysctl.string(for: [CTL_HW, HW_MACHINE])
        #endif
    }
    
    /// e.g. "MacPro4,1" or "iPhone8,1"
    /// NOTE: this is *corrected* on iOS devices to fetch hw.machine
    public static var model: String {
        #if os(iOS) && !arch(x86_64) && !arch(i386)
        return try! Sysctl.string(for: [CTL_HW, HW_MACHINE])
        #else
        return try! Sysctl.string(for: [CTL_HW, HW_MODEL])
        #endif
    }
    
    /// e.g. "8" or "2"
    public static var activeCPUs: Int32 { return try! Sysctl.value(ofType: Int32.self, forKeys: [CTL_HW, HW_AVAILCPU]) }
    
    /// e.g. "15.3.0" or "15.0.0"
    public static var osRelease: String { return try! Sysctl.string(for: [CTL_KERN, KERN_OSRELEASE]) }
    
    /// e.g. "Darwin" or "Darwin"
    public static var osType: String { return try! Sysctl.string(for: [CTL_KERN, KERN_OSTYPE]) }
    
    /// e.g. "15D21" or "13D20"
    public static var osVersion: String { return try! Sysctl.string(for: [CTL_KERN, KERN_OSVERSION]) }
    
    /// e.g. "Darwin Kernel Version 15.3.0: Thu Dec 10 18:40:58 PST 2015; root:xnu-3248.30.4~1/RELEASE_X86_64" or
    /// "Darwin Kernel Version 15.0.0: Wed Dec  9 22:19:38 PST 2015; root:xnu-3248.31.3~2/RELEASE_ARM64_S8000"
    public static var version: String { return try! Sysctl.string(for: [CTL_KERN, KERN_VERSION]) }
    
    #if os(macOS)
    /// e.g. 199506 (not available on iOS)
    public static var osRev: Int32 { return try! Sysctl.value(ofType: Int32.self, forKeys: [CTL_KERN, KERN_OSREV]) }
    
    /// e.g. 2659000000 (not available on iOS)
    public static var cpuFreq: Int64 { return try! Sysctl.value(ofType: Int64.self, forName: "hw.cpufrequency") }
    
    /// e.g. 25769803776 (not available on iOS)
    public static var memSize: UInt64 { return try! Sysctl.value(ofType: UInt64.self, forKeys: [CTL_HW, HW_MEMSIZE]) }
    #endif
}

public struct CertQuery {
    
    public static func certificateDetails(commonName: String, oid: String, searchString: String) -> Bool {
        let keychainQuery: [String: Any] = [kSecClass as String: kSecClassCertificate,
                                            kSecAttrLabel as String: commonName,
                                            kSecReturnRef as String: kCFBooleanTrue as Any]
        
        var item: CFTypeRef?
        var certificate: SecCertificate?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            return false
            //return AppConstants.Alerts.StatusChecks.CertsCheck.missingCert
        }
        
        certificate = (item as! SecCertificate)
        var error: Unmanaged<CFError>?
        guard let certDict = SecCertificateCopyValues(certificate!, nil, &error) else {
            return false
            //return "\(String(describing: error?.takeRetainedValue()))"
        }
        
        let newDict = certDict as! [String:Any]
        
        guard let oidDict = newDict[oid] else {
            return false
            //return AppConstants.Alerts.StatusChecks.CertsCheck.wrongCert
        }
        
        outer: for (_, value) in (oidDict as! NSDictionary) {
            if !(value is NSArray) {
                continue
            }
            for item in (value as! [NSDictionary]) {
                if item is NSDictionary {
                    let exists = item.allValues.filter({ ($0 as! String).contains(searchString)})
                    if exists.isEmpty {
                        continue
                        //break outer
                    }
                    return true
                    //AppConstants.Alerts.StatusChecks.CertsCheck.foundCert
                    //print(exists)
                    //break outer
                }
            }
        }
        return false
    }
    
    public static func keychainQuery(commonName: String) -> Bool {
        let keychainQuery: [String: Any] = [kSecClass as String: kSecClassCertificate,
                                            kSecAttrLabel as String: commonName,
                                            kSecReturnRef as String: kCFBooleanTrue as Any]
        
        var item: CFTypeRef?
        var certificate: SecCertificate?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &item)
        guard status == errSecSuccess else {
            //logger.write(AppConstants.Alerts.StatusChecks.CertsCheck.missingCert)
            return false
        }
        return true
        //let newDict = certDict as! [String:Any]
        
    }
}
