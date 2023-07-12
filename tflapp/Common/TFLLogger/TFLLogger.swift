//
//  TFLLogger.swift
//  tflapp
//
//  Created by Frank Saar on 07/07/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import Foundation
import os.signpost

class TFLLogger {
    enum category : String {
        case network = "network"
        case api = "api"
        case refresh = "refresh"
        case timer = "timer"
        case location = "location"
        case rootViewController = "rootViewController"
        case arrivalInfoAggregator = "arrivalInfoAggregator"
        case stationList = "stationList"
        case busStop = "TFLCDBusStop"
        case map = "map"
        case databasegeneration
    }
    fileprivate init() { }
    
    static let subsystem : String = {
        let identifier = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? ""
        return identifier
    }()
    static let shared = TFLLogger()
    
    
    func signPostStart(osLog: OSLog, name: StaticString,identifier : String? = nil) {
        #if DEBUG
        log(.begin,osLog: osLog,name: name,identifier: identifier)
        #endif
    }

    func signPostEnd(osLog: OSLog, name: StaticString, identifier : String? = nil) {
        #if DEBUG
        log(.end,osLog: osLog,name: name,identifier: identifier)
        #endif
    }
    
    
    
    func event(osLog: OSLog, name: StaticString,identifier : String? = nil) {
        #if DEBUG
        log(.event,osLog: osLog,name: name,identifier: identifier)
        #endif
    }
}

fileprivate extension TFLLogger {
    
    func log(_ type: OSSignpostType,osLog: OSLog, name: StaticString, identifier : String? = nil) {
//        let typeString = type == .begin ? "begin" :  type == .end ? "end" : type == .event ? "event" : "unknwon"
//        print("\(typeString) :\(name)  \(identifier ?? "")")
        if let _ = identifier {
            let spid = OSSignpostID(log:osLog, object: identifier as AnyObject)
            os_signpost(type, log: osLog, name: name,signpostID: spid)
        }
        else {
            os_signpost(type, log: osLog, name: name)
        }
    }
}
