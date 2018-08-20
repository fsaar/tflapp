//
//  QuickSpec+Helper.swift
//  tflApp Tests
//
//  Created by Frank Saar on 17/07/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import Quick
import Nimble



extension QuickSpec {
    func dataWithJSONFile(_ jsonFileName: String) -> Data  {
        let url = Bundle(for: type(of:self)).url(forResource: jsonFileName, withExtension: "json")
        return try! Data(contentsOf: url!)
    }
}
