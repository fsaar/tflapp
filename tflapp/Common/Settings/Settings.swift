//
//  Settings.swift
//  tflapp
//
//  Created by Frank Saar on 04/08/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import Foundation


@propertyWrapper struct Settings<T> {
    enum SettingsVariable : String {
        case appForegroundCounter
        case distance = "Distance"
    }
    fileprivate let key : SettingsVariable
    fileprivate let defaultValue : T
    init(key : SettingsVariable, defaultValue : T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue : T {
        get {
            let value = UserDefaults.standard.object(forKey: key.rawValue) as? T ?? defaultValue
            return value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key.rawValue)
        }
    }
}
