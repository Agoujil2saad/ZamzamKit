//
//  NSDateFormatter.swift
//  ZamzamKit
//
//  Created by Basem Emara on 2/17/16.
//  Copyright © 2016 Zamzam. All rights reserved.
//

import Foundation

public extension DateFormatter {
    
    /// Create a date formatter.
    ///
    /// - Parameters:
    ///   - dateFormat: The date format string used by the receiver.
    ///   - timeZone: The time zone for the receiver.
    ///   - calendar: The calendar for the receiver.
    convenience init(dateFormat: String, timeZone: TimeZone? = nil, calendar: Calendar? = nil) {
        self.init()
        
        self.dateFormat = dateFormat
        
        if let timeZone = timeZone {
            self.timeZone = timeZone
        }
        
        if let calendar = calendar {
            self.calendar = calendar
        }
    }
    
    /// Create a date formatter.
    ///
    /// - Parameters:
    ///   - dateStyle: The date style of the receiver.
    ///   - timeStyle: The time style of the receiver.
    ///   - timeZone: The time zone for the receiver.
    ///   - calendar: The calendar for the receiver.
    convenience init(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style? = nil, timeZone: TimeZone? = nil, calendar: Calendar? = nil) {
        self.init()
        
        self.dateStyle = dateStyle
        
        if let timeStyle = timeStyle {
            self.timeStyle = timeStyle
        }
        
        if let timeZone = timeZone {
            self.timeZone = timeZone
        }
        
        if let calendar = calendar {
            self.calendar = calendar
        }
    }
}
