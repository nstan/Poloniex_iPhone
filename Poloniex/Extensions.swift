//
//  Extensions.swift
//  Poloniex2
//
//  Created by Nikola Stan on 7/22/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//

import Foundation

public extension URLSession {

    func resumeAfter(_ delayIn_ms : Int,_ task: URLSessionDataTask)
    {
        var timeNow : DispatchTime = DispatchTime.now()
        while lastRequestTime>(timeNow - DispatchTimeInterval.seconds(minTimeBetweenRequest)) {
            timeNow = DispatchTime.now()
        }
        task.resume()
    }
}

public extension Double {
    func getDateStringFromUTC() -> String {
        let date = Date(timeIntervalSince1970: self)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: date)
        
    }
}

public extension Date {
    
    func getUTC() -> Double {
        
        let UTC = self.timeIntervalSince1970
        return UTC
    }
}
