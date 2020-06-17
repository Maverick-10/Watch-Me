//
//  SharedPreference.swift
//  Watch Me
//
//  Created by bhuvan on 21/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class SharedPreference {
    
    fileprivate static let standard = UserDefaults.standard
    
    fileprivate static func value(forKey key: DefaultStorageKey) -> String {
        return standard.value(forKey: key.rawValue) as? String ?? ""
    }
    
    fileprivate static func set(_ value: String, forKey key: DefaultStorageKey) {
        standard.set(value, forKey: key.rawValue)
        standard.synchronize()
    }
    
    
    enum DefaultStorageKey: String, CaseIterable {
        case accessToken
        case sessionId
    }
    
    
    static var requestToken: String {
        get {
            return value(forKey: .accessToken)
        }
        set {
            set(newValue, forKey: .accessToken)
        }
    }
    
    
    static var sessionId: String {
        get {
            return value(forKey: .sessionId)
        }
        set {
            set(newValue, forKey: .sessionId)
        }
    }
    
    static func clearDefaults() {
        for key in DefaultStorageKey.allCases {
            standard.removeObject(forKey: key.rawValue)
        }
    }
}
