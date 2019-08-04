//
//  Settings.swift
//  tflapp
//
//  Created by Frank Saar on 04/08/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import Foundation


@propertyWrapper struct Settings<T> {
    fileprivate let key : String
    fileprivate let defaultValue : T
    init(key : String, defaultValue : T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue : T {
        let value = UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        return value
    }
}
