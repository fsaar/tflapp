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
        case coredata = "coredata"
        case timer = "timer"
        case location = "location"
    }
    
    static let subsystem : String = {
        let identifier = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? ""
        return identifier
    }()
    static let shared = TFLLogger()
    
    
    func signPostStart(osLog: OSLog, name: StaticString,identifier : String? = nil) {
        log(.begin,osLog: osLog,name: name,identifier: identifier)
    }

    func signPostEnd(osLog: OSLog, name: StaticString, identifier : String? = nil) {
        log(.end,osLog: osLog,name: name,identifier: identifier)
    }
    
    func event(osLog: OSLog, name: StaticString,identifier : String? = nil) {
        log(.event,osLog: osLog,name: name,identifier: identifier)
    }
}

fileprivate extension TFLLogger {
    
    func log(_ type: OSSignpostType,osLog: OSLog, name: StaticString, identifier : String? = nil) {
        if let _ = identifier {
            let spid = OSSignpostID(log:osLog, object: identifier as AnyObject)
            os_signpost(type, log: osLog, name: name,signpostID: spid)
        }
        else {
            let spid = OSSignpostID(log:osLog)
            os_signpost(type, log: osLog, name: name, signpostID: spid)
        }
    }
}
