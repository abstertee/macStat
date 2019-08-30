//
//  Timer.swift
//  macStat
//
//  Created by Abraham Tarverdi on 8/30/19.
//  Copyright © 2019 Tarverdi Ent. All rights reserved.
//

import Foundation

class GlobalTimer: NSObject {
    static let sharedTimer: GlobalTimer = {
        let timer = GlobalTimer()
        //debugPrint("TimerShared")
        return timer
    }()
    
    
    func getTimeValue() -> Double {
        
        guard let notificationSettings = appSettings.dict[AppConstants.PlistKeys.notificationSettings] else {
            logger.write("Timer set to 3600.0 seconds from app")
            return 3600.0 // 1 Hour default timer set
        }
        //debugPrint((notificationSettings as! [String:Any])[AppConstants.PlistKeys.notificationTimer] as? NSString)
        guard let notificationTimer = (notificationSettings as! [String:Any])[AppConstants.PlistKeys.notificationTimer] as? NSString else {
            logger.write("Timer set to 3600.0 seconds from app")
            return 3600.0 // 1 Hour default timer set
        }
        //debugPrint("Timer set to \(notificationTimer) seconds from plist.")
        logger.write("Timer set to \(notificationTimer) seconds from plist.")
        return notificationTimer.doubleValue
        
    }
    
    //let timerInt = TimeInterval(getTimeValue()) // 1 Hour until the next run
    var internalTimer: Timer?
    var jobs = [() -> Void]()
    
    func startTimer(andJob job: @escaping () -> Void) {
        if self.internalTimer != nil {
            debugPrint("Timer already intialized.")
            logger.write("Timer already initialized.")
            internalTimer?.invalidate()
        }
        jobs.append(job)
        
        self.internalTimer = Timer.scheduledTimer(timeInterval: getTimeValue() /*seconds*/, target: self, selector: #selector(fireTimerAction), userInfo: nil, repeats: true)
        internalTimer?.fire()
    }
    
    func stopTimer(){
        guard self.internalTimer != nil else {
            debugPrint("No timer active, start the timer before you stop it.")
            logger.write("No timer active, start the timer before you stop it.")
            return
        }
        jobs = [()->()]()
        self.internalTimer?.invalidate()
    }
    
    @objc func fireTimerAction(){
        debugPrint("Timer Set. Countdown from \(getTimeValue()) seconds.")
        logger.write("Timer Set. Countdown from \(getTimeValue()) seconds.")
        guard jobs.count > 0 else {return}
        for job in jobs {
            job()
        }
    }
    
}
