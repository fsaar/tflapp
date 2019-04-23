//
//  String+Helper.swift
//  tflapp
//
//  Created by Frank Saar on 23/04/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import Foundation
import CommonCrypto

extension Data {
    func sha256() -> String? {
        let sha = self.withUnsafeBytes { (unsafeRawBufferPointer : UnsafeRawBufferPointer) -> String? in
            let unsafeBufferPointer = unsafeRawBufferPointer.bindMemory(to: UInt8.self)
            guard let unsafePointer = unsafeBufferPointer.baseAddress else {
                return nil
            }
            var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
            _ = CC_SHA256(unsafePointer, CC_LONG(self.count), &hash)
            return Data(bytes: hash).base64EncodedString()
        }
        return sha
    }
}
