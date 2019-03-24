//
//  PolyLine.swift
//  PolyLine
//
//  Created by Frank Saar on 18/02/2019.
//  Copyright © 2019 Samedialabs. All rights reserved.
//

import Foundation
import MapKit
import simd
//
//01 Take the initial signed value:
//-179.9832104

//02. Take the decimal value and multiply it by 1e5, rounding the result:
//-17998321

//03. Convert the decimal value to binary. Note that a negative value must be calculated using its two's complement by inverting the binary value and adding one to the result:
//00000001 00010010 10100001 11110001
//11111110 11101101 01011110 00001110
//11111110 11101101 01011110 00001111

//04. Left-shift the binary value one bit:
//11111101 11011010 10111100 00011110

//05. If the original decimal value is negative, invert this encoding:
//00000010 00100101 01000011 11100001

//06. Break the binary value out into 5-bit chunks (starting from the right hand side):
//00001 00010 01010 10000 11111 00001

//07. Place the 5-bit chunks into reverse order:
//00001 11111 10000 01010 00010 00001

//08. OR each value with 0x20 if another bit chunk follows:
//100001 111111 110000 101010 100010 000001

//09. Convert each value to decimal:
//33 63 48 42 34 1

//10. Add 63 to each value:
//96 126 111 105 97 64

//11. Convert each value to its ASCII equivalent:
//`~oia@


class PolyLine {
    fileprivate let fiveBitBlockLength = 5
    fileprivate let precisionMultiplicator : Double
    fileprivate let precision : Int
    init(precision : Int) {
        self.precision = precision
        self.precisionMultiplicator = pow(10.0, Double(precision))
    }
    
    func decode(polyLine : String) -> [CLLocationCoordinate2D] {
        guard !polyLine.isEmpty,let data = polyLine.data(using: .utf8) as Data? else {
            return []
        }
        guard case .none =  (data.first { $0 < 63 }) else {
            return []
        }
        let newData1 = data.map { $0 - 63 }
        let indices = newData1.enumerated().filter { ($0.1 & 0x20) == 0 }.map { $0.0 }
        let newData2 = newData1.map { ($0 & ~0x20) }
        let indexRanges = zip([-1] + indices,indices)
        let numberLists : [[UInt8]] = indexRanges.map { tuple in
            let (start,end) = tuple
            return Array(newData2[Int(start+1)...Int(end)])
        }
        
        let aggregatedList : [Int32] = numberLists.reduce([]) { results,list in
            let shiftedList = list.enumerated().map { Int32($0.1) << (fiveBitBlockLength * $0.0) }
            let result = shiftedList.reduce(0) { $0 | $1 }
            return results + [result]
        }
        let decodedList = aggregatedList.map { (result:$0 >> 1,isNegative:($0 & 1) == 1) }.map {  $0.isNegative ? -$0.result - 1 :  $0.result  }
        guard decodedList.count % 2 == 0 else {
            return []
        }
        
        let coords = undiff(decodedList)
        guard case .none = (coords.first { !CLLocationCoordinate2DIsValid($0) }) else {
            return []
        }
        return coords
    }
    
    func encode(coordinates : [CLLocationCoordinate2D]) -> String? {
        guard case .none = coordinates.first (where:{ !CLLocationCoordinate2DIsValid($0) }) else  {
            return nil
        }
        
        let diffedValues = diff(coordinates)
        
        let leftShiftedTwosComplementAdjusted = diffedValues.map { $0 < 0 ? ~($0 << 1) : $0 << 1 }
        let byteBlocks : [UInt8] = leftShiftedTwosComplementAdjusted.reduce([]) { list,value in
            let elements = (0...7).map { (value >> (fiveBitBlockLength * $0)) & 0x1f }.map { UInt8($0) }
            let index = elements.lastIndex { $0 != 0 }
            guard let lastIndex = index else {
                return list
            }
            let oredElements = elements[0..<lastIndex] .map { $0 | 0x20 } + [elements[lastIndex]]
            return list + oredElements
        }
        let offsetAdjusted = byteBlocks.map { $0 + 63 }
        let data = Data(bytes:offsetAdjusted)
        let encodedString = String(data: data, encoding: .utf8)
        return encodedString
    }
}

fileprivate extension PolyLine {
    func combine(_ list : [Int32],_ value : Int32) -> [Int32] {
        let lastElement = list.last ?? 0
        return list + [lastElement + value]
    }
    
    
    
    func multiplyByPrecisionMultiplicator(_ a : Double) -> Double {
        let defaultValue = Double(Int(a*precisionMultiplicator))
        guard defaultValue/precisionMultiplicator != a else {
            return defaultValue
        }
        guard let index = "\(a)".index(of: ".") else {
            return defaultValue
        }
        let aString  = "\(a)"
        let stringValue = aString[..<index]+aString[aString.index(after: index)...]+String(repeating: "0", count: precision)
        let newIndex = stringValue.index(index, offsetBy: precision)
        let newString = "\(stringValue[..<newIndex]).\(stringValue[newIndex...])"
        guard let doubleValue = Double(newString) else {
            return defaultValue
        }
        return doubleValue
    }
    
    func divideByPrecisionMultiplicator(_ a : Double) -> Double {
        let defaultValue = Double(a / precisionMultiplicator)
        guard multiplyByPrecisionMultiplicator(defaultValue) != a else {
            return defaultValue
        }
        let sgn = Double(sign(a))
        var aString = "\(abs(a))"
        if case .none = aString.index(of: ".")  {
            aString = "\(aString).0"
        }
        guard let pos = aString.index(of: ".") else {
            return defaultValue
        }
        let value = aString.split(separator: ".").joined(separator: "")
        var prefixedValue = "\(String(repeating: "0", count: precision))\(value)"
        prefixedValue.insert(".", at: pos)
        guard let doubleValue = Double(prefixedValue) else {
            return defaultValue
        }
        let signedDoubleValue =  doubleValue * sgn
        return signedDoubleValue
    }
    
    func diff(_ coordinates : [CLLocationCoordinate2D]) -> [Int32] {
        guard !coordinates.isEmpty else {
            return []
        }
       
        let latValues = coordinates.map { Int32(multiplyByPrecisionMultiplicator($0.latitude)) }
        let diffedLatValues = [latValues[0]] + zip(latValues.dropFirst(),latValues).map { $0.0 - $0.1 }
        
        let longValues = coordinates.map { Int32(multiplyByPrecisionMultiplicator($0.longitude)) }
        let diffedLongValues = [longValues[0]] + zip(longValues.dropFirst(),longValues).map { $0.0 - $0.1 }
        
        let diffedList = zip(diffedLatValues,diffedLongValues).reduce([]) { $0 + [$1.0,$1.1] }
        return diffedList
    }
    
    func undiff(_ values : [Int32]) -> [CLLocationCoordinate2D] {
        let decodedLats = values.evenElements.reduce([]) { combine($0,$1) }.map { divideByPrecisionMultiplicator(Double($0)) }
        let decodedLongs = values.oddElements.reduce([]) { combine($0,$1) }.map { divideByPrecisionMultiplicator(Double($0))  }
        let coords = zip(decodedLats,decodedLongs).map { CLLocationCoordinate2DMake($0.0, $0.1)}
        return coords
    }
}
