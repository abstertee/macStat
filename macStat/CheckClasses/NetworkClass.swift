//
//  NetworkClass.swift
//  macStat
//
//  Created by Abraham Tarverdi on 8/30/19.
//  Copyright © 2019 Tarverdi Ent. All rights reserved.
//

import Foundation
import SystemConfiguration
import CoreWLAN
import Cocoa

class Reachability {
    
    class func isConnectedToNetwork(_ completion: @escaping (Bool) -> ()){
        
        var Status:Bool = false
        let url = URL(string: "https://google.com/")!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "HEAD"
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 500
        let session = URLSession.shared
        
        session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                logger.write("httpResponse.statusCode \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    Status = true
                }
            }
            completion(Status)
            
        }).resume()
        
        //return Status
    }
}


struct GetIPs {
    var statustextfield: NSTextField?
    var interface: String
    
    func checkFunction(interface: String) -> (String) {
        let text = "No IP Found"
        var addresses = [String:String]()
        var interfaces = [String:String]()
        var ints = [String]()
        // Get all adapters on device
        for (name,addr,_) in NetworkInterfaces().getNetworkData() {
            addresses[name] = addr
            //print(name, addr)
            if name != interface {
                //logger.write("Could not find \(interface) in IP list, Skipping...")
                continue
            }
            logger.write("Found this interface \(interface) in IP list.")
            return addr
        }
        
        // Get all system ints on device
        for (intType,intName) in NetworkInterfaces().getNetworkAdapters() {
            //print(intType, intName)
            interfaces[intType] = intName
        }
        
        if !interfaces.values.contains(interface) {
            //print("Could not find name for \(interface)")
            if addresses.values.contains(interface) {
                return addresses[interface]!
            } else { return text }
        }
        
        for (n,t) in interfaces {
            //print(n + "-" + t)
            if t != interface {
                continue
            }
            ints.append(n)
            //print(ints)
            if addresses.keys.contains(n) {
                return addresses[n]!
            }
        }
        return text
    }
}

struct NetworkInterfaces {
    
    func getNetworkData() -> [(int: String, addr: String, mac: String)] {
        
        var addresses = [(int: String, addr: String, mac: String)]()
        var nameToMac = [ String: String ]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        //print(getifaddrs(&ifaddr))
        guard let firstAddr = ifaddr else { return [] }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            if let addr = ptr.pointee.ifa_addr {
                let name = String(cString: ptr.pointee.ifa_name)
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    switch Int32(addr.pointee.sa_family) {
                    case AF_LINK:
                        // Get MAC address from sockaddr_dl structure and store in nameToMac dictionary:
                        addr.withMemoryRebound(to: sockaddr_dl.self, capacity: 1) { dl in
                            dl.withMemoryRebound(to: Int8.self, capacity: 8 + Int(dl.pointee.sdl_nlen + dl.pointee.sdl_alen)) {
                                let lladdr = UnsafeBufferPointer(start: $0 + 8 + Int(dl.pointee.sdl_nlen),
                                                                 count: Int(dl.pointee.sdl_alen))
                                if lladdr.count == 6 {
                                    nameToMac[name] = lladdr.map { String(format:"%02hhx", $0)}.joined(separator: ":")
                                }
                            }
                        }
                    case AF_INET:
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(addr, socklen_t(addr.pointee.sa_len),
                                        &hostname, socklen_t(hostname.count),
                                        nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            let address = String(cString: hostname)
                            addresses.append( (int: name, addr: address, mac : "") )
                        }
                    default:
                        break
                    }
                }
            }
        }
        
        freeifaddrs(ifaddr)
        
        // Now add the mac address to the tuples:
        for (i, addr) in addresses.enumerated() {
            if let mac = nameToMac[addr.int] {
                addresses[i] = (int: addr.int, addr: addr.addr, mac: mac)
            }
        }
        
        return addresses
    }
    
    func getNetworkAdapters() -> [(name : String, type: String)] {
        
        var addresses = [(name : String, type: String)]()
        for interface in SCNetworkInterfaceCopyAll() as NSArray {
            if let name = SCNetworkInterfaceGetBSDName(interface as! SCNetworkInterface),
                let type = SCNetworkInterfaceGetInterfaceType(interface as! SCNetworkInterface) {
                addresses.append((name: name as String, type: type as String))
            }
        }
        //print(addresses)
        return addresses
    }
    
}

struct GetDNS {
    var statustext: NSTextField?
    var ipAddress: String?
    
    init(statustext: NSTextField? = nil) {
        self.statustext = statustext
        self.ipAddress = checkFunction()
        self.statustext?.stringValue = ipAddress!
    }
    
    
    private func checkFunction() -> (String) {
        var text:String = ""
        let command = shellcommand.shell("/usr/sbin/networksetup", "-listallnetworkservices")
        var networkServices = command.split(separator: "\n")
        networkServices.remove(at: 0)
        for item in networkServices {
            let result = shellcommand.shell("/usr/sbin/networksetup", "-getdnsservers", String(item))
            if result.contains("There aren't any DNS Servers set on") {
                continue
            } else {
                //print(result)
                text = result.components(separatedBy: "\n")[0]
                break
            }
        }
        
        if text.isEmpty {
            let seperators = CharacterSet(charactersIn: "\n ")
            var dnsResults = shellcommand.shell("/usr/bin/grep", "nameserver", "/etc/resolv.conf").components(separatedBy: seperators)
            let index = dnsResults.index(of: "")
            dnsResults.remove(at: index!)
            dnsResults = dnsResults.filter { $0 != "nameserver" }
            text = dnsResults.joined(separator: ", ")
        }
        if text.isEmpty {
            text = "No DNS Servers Set"
        }
        return text
    }
}

