//
//  PolylineDict.swift
//  tflapp
//
//  Created by Frank Saar on 06/04/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import Foundation

class PolylineDict {
    let queue : OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()
    
    subscript(key : String) -> String? {
        get {
            let group = DispatchGroup()
            group.enter()
            var value : String?
            queue.addOperation {
                value = self.innerDict[key]
                group.leave()
            }
            group.wait()
            return value
        }
        set {
            guard let value = newValue,!value.isEmpty else {
                return
            }
            queue.addOperation {
                self.innerDict[key] = value
                self.save()
            }
        }
    }
    
    var innerDict : [String:String] = [:]
    
    init() {
        if let fileName = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("PolylineDict"),let dict = NSDictionary(contentsOf: fileName) {
            print("Loaded PolylineDict: \(dict.allKeys.count) entries !")
            for (key,value) in dict {
                if let (keyString,valueString) = (key,value) as? (String,String) {
                    self.innerDict[keyString] = valueString
                }
            }
        }
    }
    
    func save() {
        guard let fileName = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("PolylineDict") else {
            return
        }
        let dict = NSDictionary(dictionary: innerDict)
        dict.write(to: fileName, atomically: true)
        print("saved! \(dict.allKeys.count) entries !")
    }    
}
