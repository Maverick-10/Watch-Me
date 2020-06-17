//
//  Date.swift
//  Watch Me
//
//  Created by bhuvan on 23/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

extension Date {
    
    static func date(fromString string: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd" //2020-01-15
        return df.date(from: string)
    }
    
    func toDateString() -> String {
        return dateString(format: "dd MMMM yyyy")
    }
    
    func toYearString() -> String {
        return dateString(format: "yyyy")
    }
    
    private func dateString(format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
    
}
