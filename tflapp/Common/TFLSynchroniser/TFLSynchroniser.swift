//
//  TFLSynchroniser.swift
//  tflapp
//
//  Created by Frank Saar on 26/07/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import Foundation


class TFLSynchroniser {
    lazy var queue : OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        q.underlyingQueue = DispatchQueue.global()
        return q
    }()
    
    init(tag : String) {
        queue.name = tag
    }
    
    func synchronise(_ block : @escaping (_ synchroniseEnd : @escaping () -> ()) -> ()) {
        let group = DispatchGroup()
        let synchroniseEnd : () -> () = {
            group.leave()
        }
        queue.addOperation {
            group.enter()
            block(synchroniseEnd)
            group.wait()
        }
    }
}
