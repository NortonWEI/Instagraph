//
//  Timestamp.swift
//  Instagraph
//
//  Created by Dafu Ai on 16/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Foundation

class Timestamp {
    // Convert Int timestamp to Date
    static func timestampIntToDate(_ timestamp: Int) -> Date {
        return Date(timeIntervalSince1970: Double(timestamp))
    }
    
    // Convert Date timestamp to Int
    static func timestampDateToInt(_ timestamp: Date) -> Int {
        return Int(timestamp.timeIntervalSince1970)
    }
    
    // Convert historic date time to readable string (... ago)
    static func historicDateToReadable(dateFrom: Date) -> String {
        let difference = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: dateFrom, to: Date())
        let formattedString: String
        
        if difference.hour! == 0 {
            formattedString = String(format: "%ld minutes ago", difference.minute!)
        } else if difference.day! == 0 {
            formattedString = String(format: "%ld hours ago", difference.hour!)
        } else if difference.month! == 0 {
            formattedString = String(format: "%ld days ago", difference.day!)
        } else if difference.year! == 0 {
            formattedString = String(format: "%ld days ago", difference.month!)
        } else {
            formattedString = String(format: "%ld years ago", difference.year!)
        }
        
        return formattedString
    }
}
