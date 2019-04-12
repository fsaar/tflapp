//
//  PolylineDict.swift
//  tflapp
//
//  Created by Frank Saar on 06/04/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import Foundation

class PolylineDict {
    fileprivate let queue : OperationQueue = {
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
        
        copyPolyLineDictIfNeedBe()
        if let fileName = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("PolylineDict.plist"),let dict = NSDictionary(contentsOf: fileName) {
            print("Loaded PolylineDict: \(dict.allKeys.count) entries !")
            for (key,value) in dict {
                if let (keyString,valueString) = (key,value) as? (String,String) {
                    self.innerDict[keyString] = valueString
                }
            }
        }
    }
    
    func save() {
        guard let fileName = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("PolylineDict.plist") else {
            return
        }
        let dict = NSDictionary(dictionary: innerDict)
        dict.write(to: fileName, atomically: true)
        print("saved! \(dict.allKeys.count) entries !")
    }    
}

fileprivate extension PolylineDict {
    func copyPolyLineDictIfNeedBe() {
        guard let sourceURL = Bundle.main.url(forResource: "PolylineDict", withExtension: "plist"),
            let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("PolylineDict.plist") else {
                return
        }
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            let date = "\(Date())".split(separator: " ").joined(separator: "")
            let newPath = "\(destinationURL.path)\(date)"
            try? FileManager.default.moveItem(atPath: destinationURL.path, toPath: newPath)
        }
        try? FileManager.default.copyItem(at: sourceURL, to: destinationURL)
    }
}
