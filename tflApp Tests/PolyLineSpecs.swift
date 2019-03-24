//
//  PolyLineSpecs.swift
//  PolyLineTests
//
//  Created by Frank Saar on 18/02/2019.
//  Copyright © 2019 Samedialabs. All rights reserved.
//

import Foundation
import Nimble
import UIKit
import Quick
import MapKit

@testable import London_Bus

extension CLLocationCoordinate2D {
    public static func ==(lhs : CLLocationCoordinate2D,rhs : CLLocationCoordinate2D) -> Bool {
        return (lhs.latitude == rhs.latitude) && (lhs.longitude == rhs.longitude)
    }
    
    var isValid : Bool {
        let isNonNull = (self.latitude != 0) && (self.longitude != 0)
        let isValid = CLLocationCoordinate2DIsValid(self)
        return isNonNull && isValid
    }
    
    static func +(lhs : CLLocationCoordinate2D,rhs : CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(lhs.latitude+rhs.latitude, lhs.longitude+rhs.longitude)
    }
    
    var location : CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
}


class PolyLineSpecs: QuickSpec {
    
    override func spec() {
        it("can be instantiated") {
            let polyLine = PolyLine(precision: 5)
            expect(polyLine).notTo(beNil())
        }
        
        context("when decoding") {
            it("should handle bogus values gracefully") {
                let polyLine = PolyLine(precision: 5)
                let coords = polyLine.decode(polyLine: "Test")
                expect(coords).to(beEmpty())
            }
            
            it("should handle an empty value gracefully") {
                let polyLine = PolyLine(precision: 5)
                let coords = polyLine.decode(polyLine: "")
                expect(coords).to(beEmpty())
            }
            
            
            describe("when decoding") {
                it("should return empty list for any invalid string") {
                    let polyLine = PolyLine(precision: 5)
                    let coords = polyLine.decode(polyLine: "--------")
                    expect(coords).to(beEmpty())
                }
                
                context("given a precision of 5") {
                    it ("should decode given string correctly") {
                        let polyLine = PolyLine(precision: 5)
                        let coords = polyLine.decode(polyLine: "_p~iF~ps|U_ulLnnqC_mqNvxq`@")
                        expect(coords.count) == 3
                        let refCoords1 = CLLocationCoordinate2D(latitude: 38.5, longitude: -120.2)
                        let refCoords2 = CLLocationCoordinate2D(latitude: 40.7, longitude: -120.95)
                        let refCoords3 = CLLocationCoordinate2D(latitude: 43.252, longitude: -126.453)
                        expect(refCoords1 == coords[0]) == true
                        expect(refCoords2 == coords[1]) == true
                        expect(refCoords3 == coords[2]) == true
                    }
                    
                    it ("should return the original inputvalue when encoding") {
                        let refCoords1 = CLLocationCoordinate2D(latitude: 38.5, longitude: -120.2)
                        let refCoords2 = CLLocationCoordinate2D(latitude: 40.7, longitude: -120.95)
                        let refCoords3 = CLLocationCoordinate2D(latitude: 43.252, longitude: -126.453)
                        let list = [refCoords1,refCoords2,refCoords3]

                        let polyLine = PolyLine(precision: 5)
                        let list2 = polyLine.decode(polyLine: polyLine.encode(coordinates: list)!)
                        expect(list).to(equal(list2))
                    }
                    
                    it ("should decode under a certain threshold") {
                        let polyLine = PolyLine(precision: 5)
                        
                        let encodedPolyline = """
                                                gkkyHp{u@pBWN{HF{D@e@PBJAp@EfBKzFe@rOSxAKb@oArEy@~BOl@}@dEs@fD_@jBu@vDoBtKy@rE_AxEGXGXwAlGeBjH[jA_AdDq@|BcAfEg@nCPJGKCLCj@Bk@BMFJQKCZChADhFDpANvAPnAb@xBZlAJVDRV`@B@JVLj@Fl@^Ap@F|@B\\NCCBOB@LRjD`@fF^xETnCf@fGDf@Fn@n@pGvA|NH|@ZhBKDH|@Z|D^pEHx@Fr@PrBJPL~ANbBHvB@HHfANpBp@~Hr@dHZbDBTBVNlBX|DJpA@^C`AEfDDh@@d@RhDbAhJb@rDLfABNpAHn@BBD@JCFE@CzM\\AfAnBBdAv@~IXvCFv@FDn@HtEG`BGbAMhAEzA_@vFm@pKIrACn@CtBbEA^NGpCWjIOlDGxB[pDa@hDY~DG|AEzBEd@QjC_@pEu@~HIbAQxB}@xJObAa@xCOnAi@vFCpB@h@Bz@ZpEDZJGGDC@j@`E\\fDBtBAdAWnDKxAEj@Gv@Cx@A`AQrB[nDYxBKzAAfA@lIHIHIj@ArBKvBg@`F_AbGAFUnAKt@Ej@WbCSdCO|BWtDEp@AFQxBc@|EUbCUzDG~@Cj@UzDAl@I`ASvAc@pCWdACFQn@uCbIaArD_AzE]hBG\\K`BD`B@|ACz@Iv@ZL
                                                """
    
                        let total : Double = (1...100).reduce(0) { sum,_ in
                            let start = Date()
                            _ = polyLine.decode(polyLine: encodedPolyline)
                            let timeNeeded = Date().timeIntervalSince(start)
                            return sum + timeNeeded
                        }
                        expect(total / 100) <= 0.0120
                    }
                    
                    it ("should decode polyline correctly") {
                        let polyLine = PolyLine(precision: 5)
                        let encodedPolyLine = "_meyH~ms@N|@BCrByA[w@gDkGIIGCKHS`@sAxB}CnEkAlAy@l@k@^iAr@PlA@Zj@YA_@@WBg@EuDsAQGMMCQ@Su@Y_Bk@AN@OaC}@g@UwD"
                        let list = polyLine.decode(polyLine: encodedPolyLine)
                        expect(list).notTo(beEmpty())
                        let encodedPolyLine2 =  polyLine.encode(coordinates: list)!
                        expect(encodedPolyLine2) == encodedPolyLine
                        let list2 = polyLine.decode(polyLine:encodedPolyLine2)
                        expect(list).to(equal(list2))
                    }
                    
                    it ("should encode & decode correctly") {
                        let polyLine = PolyLine(precision: 5)
                        let list = [CLLocationCoordinate2D(latitude: 51.48228, longitude: -0.26779 )]
                         let encodedPolyLine2 =  polyLine.encode(coordinates: list)!
                        expect(encodedPolyLine2) == "gcfyHths@"
                        let list2 = polyLine.decode(polyLine:encodedPolyLine2)
                        expect(list).to(equal(list2))
                    }
                }
                
                context("given a precision of 6") {
                    it ("should decode given string correctly") {
                        let polyLine = PolyLine(precision: 6)
                        let coords = polyLine.decode(polyLine: "_p~iF~ps|U_ulLnnqC_mqNvxq`@")
                        expect(coords.count) == 3
                        let refCoords1 = CLLocationCoordinate2D(latitude: 3.85, longitude: -12.02)
                        let refCoords2 = CLLocationCoordinate2D(latitude: 4.07, longitude: -12.095)
                        let refCoords3 = CLLocationCoordinate2D(latitude: 4.3252, longitude: -12.6453)
                        expect(refCoords1 == coords[0]) == true
                        expect(refCoords2 == coords[1]) == true
                        expect(refCoords3 == coords[2]) == true
                    }
                    
                    it ("should return the original inputvalue when encoding") {
                        let refCoords1 = CLLocationCoordinate2D(latitude: 3.85, longitude: -12.02)
                        let refCoords2 = CLLocationCoordinate2D(latitude: 4.07, longitude: -12.095)
                        let refCoords3 = CLLocationCoordinate2D(latitude: 4.3252, longitude: -12.6453)
                        let list = [refCoords1,refCoords2,refCoords3]
                        
                        let polyLine = PolyLine(precision: 6)
                        let list2 = polyLine.decode(polyLine:polyLine.encode(coordinates: list)!)
                        expect(list).to(equal(list2))
                    }
                }
            }
           
            
            describe("when encoding") {
                it("should return nil if list has invalid coordinates") {
                    let refCoords1 = CLLocationCoordinate2D(latitude: 38.5, longitude: -120.2)
                    let refCoords2 = CLLocationCoordinate2D(latitude: 40.7, longitude: -120.95)
                    let refCoords3 = kCLLocationCoordinate2DInvalid
                    let list = [refCoords1,refCoords2,refCoords3]
                    let polyLine = PolyLine(precision: 5)
                    let encodedString = polyLine.encode(coordinates: list)
                    expect(encodedString).to(beNil())

                }
                context("given a precision of 5") {
                    it ("should encode given coordinates correctly") {
                        let refCoords1 = CLLocationCoordinate2D(latitude: 38.5, longitude: -120.2)
                        let refCoords2 = CLLocationCoordinate2D(latitude: 40.7, longitude: -120.95)
                        let refCoords3 = CLLocationCoordinate2D(latitude: 43.252, longitude: -126.453)
                        let list = [refCoords1,refCoords2,refCoords3]
                        let polyLine = PolyLine(precision: 5)
                        let encodedString = polyLine.encode(coordinates: list)
                        expect(encodedString) == "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
                    }
                    
                    it ("should return the original inputvalue when decoding") {
                        let polyLine = PolyLine(precision: 5)
                        let value = "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
                        expect(polyLine.encode(coordinates: polyLine.decode(polyLine: value))) == value
                    }
                }
                
                context("given a precision of 6") {
                    it ("should encode given coordinates correctly") {
                        let refCoords1 = CLLocationCoordinate2D(latitude: 3.85, longitude: -12.02)
                        let refCoords2 = CLLocationCoordinate2D(latitude: 4.07, longitude: -12.095)
                        let refCoords3 = CLLocationCoordinate2D(latitude: 4.3252, longitude: -12.6453)
                        let list = [refCoords1,refCoords2,refCoords3]
                        let polyLine = PolyLine(precision: 6)
                        let encodedString = polyLine.encode(coordinates: list)
                        expect(encodedString) == "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
                    }
                    
                    it ("should return the original inputvalue when decoding") {
                        let polyLine = PolyLine(precision: 6)
                        let value = "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
                        expect(polyLine.encode(coordinates: polyLine.decode(polyLine: value))) == value
                    }
                }
            }
        }
    }
    
}
