//
//  Array+Helper.swift
//  tflapp
//
//  Created by Frank Saar on 24/02/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import Foundation

extension Array {
    var evenElements : [Element] {
        return self.enumerated().filter { ($0.0 % 2) == 0 }.map { $0.1 }
    }
    var oddElements : [Element] {
        return self.enumerated().filter { ($0.0 % 2) == 1 }.map { $0.1 }
    }
}
