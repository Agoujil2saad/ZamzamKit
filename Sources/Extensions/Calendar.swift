//
//  Calendar.swift
//  ZamzamKit
//
//  Created by Basem Emara on 5/6/17.
//  Copyright © 2017 Zamzam. All rights reserved.
//

import Foundation

public extension Calendar {
    
    /// Normalize date calculations using Gregorian calendar with UTC timezone and POSIX.
    static let gregorianUTC: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.locale = .posix
        return calendar
    }()
}

public extension Calendar.Component {
    
    /// The set component units of date that includes year, month, day, hour, minute, and second
    static let full: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
}
