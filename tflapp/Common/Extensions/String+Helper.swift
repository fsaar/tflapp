//
//  String+Helper.swift
//  tflapp
//
//  Created by Frank Saar on 23/04/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    func sha256() -> String? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        return data.sha256()
    }
}
