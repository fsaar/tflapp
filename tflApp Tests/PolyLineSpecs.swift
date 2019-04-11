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
                    
                    it ("should encode & decode 2 same coordinates correctly") {
                        let polyLine = PolyLine(precision: 5)
                        let list = [CLLocationCoordinate2D(latitude: 51.36292, longitude: 0.0913),
                                    CLLocationCoordinate2D(latitude: 51.36292, longitude: 0.0913)]
                        let encodedPolyLine =  polyLine.encode(coordinates: list)!
                        let list2 = polyLine.decode(polyLine:encodedPolyLine)
                        expect(list).to(equal(list2))
                    }
                    
                    it ("should encode & decode a real world example correctly") {
                        let polyLine = PolyLine(precision: 5)
                        let list = [
                                    CLLocationCoordinate2D(latitude: 51.37341, longitude: 0.08961),
                                    CLLocationCoordinate2D(latitude: 51.37187, longitude: 0.09138),
                                    CLLocationCoordinate2D(latitude: 51.37187, longitude: 0.09138),
                                    CLLocationCoordinate2D(latitude: 51.37183, longitude: 0.09137),
                                    CLLocationCoordinate2D(latitude: 51.37181, longitude: 0.09153),
                                    CLLocationCoordinate2D(latitude: 51.37179, longitude: 0.09188),
                                    CLLocationCoordinate2D(latitude: 51.37181, longitude: 0.0923),
                                    CLLocationCoordinate2D(latitude: 51.37184, longitude: 0.0926),
                                    CLLocationCoordinate2D(latitude: 51.3722, longitude: 0.09336),
                                    CLLocationCoordinate2D(latitude: 51.37263, longitude: 0.09419),
                                    CLLocationCoordinate2D(latitude: 51.37278, longitude: 0.09454),
                                    CLLocationCoordinate2D(latitude: 51.37312, longitude: 0.09558),
                                    CLLocationCoordinate2D(latitude: 51.3732, longitude: 0.09588),
                                    CLLocationCoordinate2D(latitude: 51.37325, longitude: 0.09623),
                                    CLLocationCoordinate2D(latitude: 51.37325, longitude: 0.09657),
                                    CLLocationCoordinate2D(latitude: 51.37323, longitude: 0.09714),
                                    CLLocationCoordinate2D(latitude: 51.37322, longitude: 0.09738),
                                    CLLocationCoordinate2D(latitude: 51.37323, longitude: 0.09738),
                                    CLLocationCoordinate2D(latitude: 51.37327, longitude: 0.09742),
                                    CLLocationCoordinate2D(latitude: 51.37329, longitude: 0.09747),
                                    CLLocationCoordinate2D(latitude: 51.3733, longitude: 0.0976),
                                    CLLocationCoordinate2D(latitude: 51.3733, longitude: 0.09761),
                                    CLLocationCoordinate2D(latitude: 51.37328, longitude: 0.09764),
                                    CLLocationCoordinate2D(latitude: 51.37326, longitude: 0.09767),
                                    CLLocationCoordinate2D(latitude: 51.37325, longitude: 0.09768),
                                    CLLocationCoordinate2D(latitude: 51.37322, longitude: 0.0977),
                                    CLLocationCoordinate2D(latitude: 51.37316, longitude: 0.09769),
                                    CLLocationCoordinate2D(latitude: 51.37311, longitude: 0.09761),
                                    CLLocationCoordinate2D(latitude: 51.3731, longitude: 0.09755),
                                    CLLocationCoordinate2D(latitude: 51.3731, longitude: 0.09752),
                                    CLLocationCoordinate2D(latitude: 51.3728, longitude: 0.09747),
                                    CLLocationCoordinate2D(latitude: 51.37152, longitude: 0.09703),
                                    CLLocationCoordinate2D(latitude: 51.37151, longitude: 0.09712),
                                    CLLocationCoordinate2D(latitude: 51.37152, longitude: 0.09703),
                                    CLLocationCoordinate2D(latitude: 51.37088, longitude: 0.09681),
                                    CLLocationCoordinate2D(latitude: 51.36986, longitude: 0.09648),
                                    CLLocationCoordinate2D(latitude: 51.3688, longitude: 0.09605),
                                    CLLocationCoordinate2D(latitude: 51.36797, longitude: 0.09567),
                                    CLLocationCoordinate2D(latitude: 51.36797, longitude: 0.09567),
                                    CLLocationCoordinate2D(latitude: 51.36778, longitude: 0.09559),
                                    CLLocationCoordinate2D(latitude: 51.36678, longitude: 0.09507),
                                    CLLocationCoordinate2D(latitude: 51.36654, longitude: 0.09493),
                                    CLLocationCoordinate2D(latitude: 51.36631, longitude: 0.09471),
                                    CLLocationCoordinate2D(latitude: 51.36538, longitude: 0.0938),
                                    CLLocationCoordinate2D(latitude: 51.36537, longitude: 0.09384),
                                    CLLocationCoordinate2D(latitude: 51.36536, longitude: 0.09385),
                                    CLLocationCoordinate2D(latitude: 51.36533, longitude: 0.09385),
                                    CLLocationCoordinate2D(latitude: 51.36531, longitude: 0.09382),
                                    CLLocationCoordinate2D(latitude: 51.3653, longitude: 0.09378),
                                    CLLocationCoordinate2D(latitude: 51.36531, longitude: 0.09376),
                                    CLLocationCoordinate2D(latitude: 51.36531, longitude: 0.09375),
                                    CLLocationCoordinate2D(latitude: 51.36519, longitude: 0.0936),
                                    CLLocationCoordinate2D(latitude: 51.36481, longitude: 0.0932),
                                    CLLocationCoordinate2D(latitude: 51.36481, longitude: 0.0932),
                                    CLLocationCoordinate2D(latitude: 51.36428, longitude: 0.09264),
                                    CLLocationCoordinate2D(latitude: 51.36425, longitude: 0.09261),
                                    CLLocationCoordinate2D(latitude: 51.36408, longitude: 0.09252),
                                    CLLocationCoordinate2D(latitude: 51.36406, longitude: 0.0926),
                                    CLLocationCoordinate2D(latitude: 51.36403, longitude: 0.09264),
                                    CLLocationCoordinate2D(latitude: 51.36397, longitude: 0.09267),
                                    CLLocationCoordinate2D(latitude: 51.36393, longitude: 0.09266),
                                    CLLocationCoordinate2D(latitude: 51.36388, longitude: 0.09256),
                                    CLLocationCoordinate2D(latitude: 51.36387, longitude: 0.09245),
                                    CLLocationCoordinate2D(latitude: 51.36378, longitude: 0.09226),
                                    CLLocationCoordinate2D(latitude: 51.36363, longitude: 0.09206),
                                    CLLocationCoordinate2D(latitude: 51.36339, longitude: 0.0918),
                                    CLLocationCoordinate2D(latitude: 51.36292, longitude: 0.0913),
                                    CLLocationCoordinate2D(latitude: 51.36292, longitude: 0.0913),
                                    CLLocationCoordinate2D(latitude: 51.36269, longitude: 0.09106),
                                    CLLocationCoordinate2D(latitude: 51.36152, longitude: 0.08989),
                                    CLLocationCoordinate2D(latitude: 51.36085, longitude: 0.08915),
                                    CLLocationCoordinate2D(latitude: 51.36085, longitude: 0.08915),
                                    CLLocationCoordinate2D(latitude: 51.36081, longitude: 0.0891),
                                    CLLocationCoordinate2D(latitude: 51.36071, longitude: 0.08898),
                                    CLLocationCoordinate2D(latitude: 51.36052, longitude: 0.08883),
                                    CLLocationCoordinate2D(latitude: 51.36026, longitude: 0.08868),
                                    CLLocationCoordinate2D(latitude: 51.36009, longitude: 0.08865),
                                    CLLocationCoordinate2D(latitude: 51.35878, longitude: 0.08878),
                                    CLLocationCoordinate2D(latitude: 51.35691, longitude: 0.08902),
                                    CLLocationCoordinate2D(latitude: 51.35642, longitude: 0.08911),
                                    CLLocationCoordinate2D(latitude: 51.35642, longitude: 0.08911),
                                    CLLocationCoordinate2D(latitude: 51.35633, longitude: 0.08912),
                                    CLLocationCoordinate2D(latitude: 51.35626, longitude: 0.08916),
                                    CLLocationCoordinate2D(latitude: 51.35596, longitude: 0.08926),
                                    CLLocationCoordinate2D(latitude: 51.35592, longitude: 0.08928),
                                    CLLocationCoordinate2D(latitude: 51.35591, longitude: 0.08931),
                                    CLLocationCoordinate2D(latitude: 51.35589, longitude: 0.08933),
                                    CLLocationCoordinate2D(latitude: 51.35587, longitude: 0.08933),
                                    CLLocationCoordinate2D(latitude: 51.35585, longitude: 0.08931),
                                    CLLocationCoordinate2D(latitude: 51.35583, longitude: 0.08925),
                                    CLLocationCoordinate2D(latitude: 51.35584, longitude: 0.0892),
                                    CLLocationCoordinate2D(latitude: 51.35586, longitude: 0.08918),
                                    CLLocationCoordinate2D(latitude: 51.35587, longitude: 0.08913),
                                    CLLocationCoordinate2D(latitude: 51.35587, longitude: 0.089),
                                    CLLocationCoordinate2D(latitude: 51.35591, longitude: 0.08885),
                                    CLLocationCoordinate2D(latitude: 51.35623, longitude: 0.08851),
                                    CLLocationCoordinate2D(latitude: 51.35627, longitude: 0.08845),
                                    CLLocationCoordinate2D(latitude: 51.35627, longitude: 0.08845),
                                    CLLocationCoordinate2D(latitude: 51.35639, longitude: 0.08828),
                                    CLLocationCoordinate2D(latitude: 51.35658, longitude: 0.08792),
                                    CLLocationCoordinate2D(latitude: 51.35675, longitude: 0.08751),
                                    CLLocationCoordinate2D(latitude: 51.35706, longitude: 0.08676),
                                    CLLocationCoordinate2D(latitude: 51.35717, longitude: 0.08662),
                                    CLLocationCoordinate2D(latitude: 51.35729, longitude: 0.08654),
                                    CLLocationCoordinate2D(latitude: 51.35743, longitude: 0.08649),
                                    CLLocationCoordinate2D(latitude: 51.35751, longitude: 0.0864),
                                    CLLocationCoordinate2D(latitude: 51.35753, longitude: 0.08634),
                                    CLLocationCoordinate2D(latitude: 51.35754, longitude: 0.0862),
                                    CLLocationCoordinate2D(latitude: 51.35751, longitude: 0.08621),
                                    CLLocationCoordinate2D(latitude: 51.35748, longitude: 0.0862),
                                    CLLocationCoordinate2D(latitude: 51.35743, longitude: 0.08617),
                                    CLLocationCoordinate2D(latitude: 51.35739, longitude: 0.08609),
                                    CLLocationCoordinate2D(latitude: 51.35738, longitude: 0.08601),
                                    CLLocationCoordinate2D(latitude: 51.3574, longitude: 0.08592),
                                    CLLocationCoordinate2D(latitude: 51.35743, longitude: 0.08585),
                                    CLLocationCoordinate2D(latitude: 51.35745, longitude: 0.08583),
                                    CLLocationCoordinate2D(latitude: 51.35755, longitude: 0.08542),
                                    CLLocationCoordinate2D(latitude: 51.35777, longitude: 0.08479),
                                    CLLocationCoordinate2D(latitude: 51.35777, longitude: 0.0847),
                                    CLLocationCoordinate2D(latitude: 51.3578, longitude: 0.08467),
                                    CLLocationCoordinate2D(latitude: 51.35782, longitude: 0.08467),
                                    CLLocationCoordinate2D(latitude: 51.35811, longitude: 0.08389),
                                    CLLocationCoordinate2D(latitude: 51.35828, longitude: 0.0834),
                                    CLLocationCoordinate2D(latitude: 51.35834, longitude: 0.083),
                                    CLLocationCoordinate2D(latitude: 51.3585, longitude: 0.08202),
                                    CLLocationCoordinate2D(latitude: 51.35933, longitude: 0.07566),
                                    CLLocationCoordinate2D(latitude: 51.35953, longitude: 0.07377),
                                    CLLocationCoordinate2D(latitude: 51.35961, longitude: 0.07288),
                                    CLLocationCoordinate2D(latitude: 51.35961, longitude: 0.07258),
                                    CLLocationCoordinate2D(latitude: 51.35959, longitude: 0.07227),
                                    CLLocationCoordinate2D(latitude: 51.35952, longitude: 0.07186),
                                    CLLocationCoordinate2D(latitude: 51.35952, longitude: 0.07186),
                                    CLLocationCoordinate2D(latitude: 51.35945, longitude: 0.07164),
                                    CLLocationCoordinate2D(latitude: 51.3593, longitude: 0.07107),
                                    CLLocationCoordinate2D(latitude: 51.3593, longitude: 0.07069),
                                    CLLocationCoordinate2D(latitude: 51.35936, longitude: 0.07025),
                                    CLLocationCoordinate2D(latitude: 51.35934, longitude: 0.07024),
                                    CLLocationCoordinate2D(latitude: 51.35936, longitude: 0.07025),
                                    CLLocationCoordinate2D(latitude: 51.3594, longitude: 0.07003),
                                    CLLocationCoordinate2D(latitude: 51.35946, longitude: 0.06955),
                                    CLLocationCoordinate2D(latitude: 51.35951, longitude: 0.06868),
                                    CLLocationCoordinate2D(latitude: 51.3595, longitude: 0.06836),
                                    CLLocationCoordinate2D(latitude: 51.35944, longitude: 0.06779),
                                    CLLocationCoordinate2D(latitude: 51.35929, longitude: 0.06692),
                                    CLLocationCoordinate2D(latitude: 51.35926, longitude: 0.06635),
                                    CLLocationCoordinate2D(latitude: 51.35929, longitude: 0.06612),
                                    CLLocationCoordinate2D(latitude: 51.35935, longitude: 0.06591),
                                    CLLocationCoordinate2D(latitude: 51.35949, longitude: 0.06563),
                                    CLLocationCoordinate2D(latitude: 51.35971, longitude: 0.06533),
                                    CLLocationCoordinate2D(latitude: 51.35982, longitude: 0.0652),
                                    CLLocationCoordinate2D(latitude: 51.36011, longitude: 0.06495),
                                    CLLocationCoordinate2D(latitude: 51.36027, longitude: 0.06477),
                                    CLLocationCoordinate2D(latitude: 51.36069, longitude: 0.06426),
                                    CLLocationCoordinate2D(latitude: 51.36075, longitude: 0.06397),
                                    CLLocationCoordinate2D(latitude: 51.36087, longitude: 0.06342),
                                    CLLocationCoordinate2D(latitude: 51.36116, longitude: 0.06234),
                                    CLLocationCoordinate2D(latitude: 51.36142, longitude: 0.06144),
                                    CLLocationCoordinate2D(latitude: 51.36167, longitude: 0.06062),
                                    CLLocationCoordinate2D(latitude: 51.36189, longitude: 0.06005),
                                    CLLocationCoordinate2D(latitude: 51.36245, longitude: 0.05902),
                                    CLLocationCoordinate2D(latitude: 51.36271, longitude: 0.05846),
                                    CLLocationCoordinate2D(latitude: 51.36271, longitude: 0.05846),
                                    CLLocationCoordinate2D(latitude: 51.36297, longitude: 0.05803),
                                    CLLocationCoordinate2D(latitude: 51.36378, longitude: 0.05683),
                                    CLLocationCoordinate2D(latitude: 51.36473, longitude: 0.05555),
                                    CLLocationCoordinate2D(latitude: 51.36497, longitude: 0.05524),
                                    CLLocationCoordinate2D(latitude: 51.36517, longitude: 0.05492),
                                    CLLocationCoordinate2D(latitude: 51.36522, longitude: 0.05476),
                                    CLLocationCoordinate2D(latitude: 51.36555, longitude: 0.05421),
                                    CLLocationCoordinate2D(latitude: 51.36559, longitude: 0.05414),
                                    CLLocationCoordinate2D(latitude: 51.36557, longitude: 0.05412),
                                    CLLocationCoordinate2D(latitude: 51.36559, longitude: 0.05412),
                                    CLLocationCoordinate2D(latitude: 51.36579, longitude: 0.05378),
                                    CLLocationCoordinate2D(latitude: 51.36611, longitude: 0.0531),
                                    CLLocationCoordinate2D(latitude: 51.36631, longitude: 0.05256),
                                    CLLocationCoordinate2D(latitude: 51.36628, longitude: 0.05252),
                                    CLLocationCoordinate2D(latitude: 51.36627, longitude: 0.0525),
                                    CLLocationCoordinate2D(latitude: 51.36631, longitude: 0.05226),
                                    CLLocationCoordinate2D(latitude: 51.36639, longitude: 0.05181),
                                    CLLocationCoordinate2D(latitude: 51.36648, longitude: 0.05126),
                                    CLLocationCoordinate2D(latitude: 51.36651, longitude: 0.05093),
                                    CLLocationCoordinate2D(latitude: 51.36664, longitude: 0.04949),
                                    CLLocationCoordinate2D(latitude: 51.3667, longitude: 0.04887),
                                    CLLocationCoordinate2D(latitude: 51.36678, longitude: 0.04839),
                                    CLLocationCoordinate2D(latitude: 51.36694, longitude: 0.04762),
                                    CLLocationCoordinate2D(latitude: 51.3672, longitude: 0.04649),
                                    CLLocationCoordinate2D(latitude: 51.36722, longitude: 0.04636),
                                    CLLocationCoordinate2D(latitude: 51.36723, longitude: 0.04634),
                                    CLLocationCoordinate2D(latitude: 51.36731, longitude: 0.04595),
                                    CLLocationCoordinate2D(latitude: 51.36734, longitude: 0.04577),
                                    CLLocationCoordinate2D(latitude: 51.36741, longitude: 0.04524),
                                    CLLocationCoordinate2D(latitude: 51.36742, longitude: 0.04481),
                                    CLLocationCoordinate2D(latitude: 51.36739, longitude: 0.0445),
                                    CLLocationCoordinate2D(latitude: 51.36732, longitude: 0.04388),
                                    CLLocationCoordinate2D(latitude: 51.3673, longitude: 0.04353),
                                    CLLocationCoordinate2D(latitude: 51.36726, longitude: 0.04288),
                                    CLLocationCoordinate2D(latitude: 51.36719, longitude: 0.0419),
                                    CLLocationCoordinate2D(latitude: 51.36717, longitude: 0.04041),
                                    CLLocationCoordinate2D(latitude: 51.36718, longitude: 0.04041),
                                    CLLocationCoordinate2D(latitude: 51.36717, longitude: 0.04043),
                                    CLLocationCoordinate2D(latitude: 51.3672, longitude: 0.03894),
                                    CLLocationCoordinate2D(latitude: 51.3672, longitude: 0.03894),
                                    CLLocationCoordinate2D(latitude: 51.36663, longitude: 0.03902),
                                    CLLocationCoordinate2D(latitude: 51.36533, longitude: 0.03902),
                                    CLLocationCoordinate2D(latitude: 51.36512, longitude: 0.03904),
                                    CLLocationCoordinate2D(latitude: 51.36512, longitude: 0.03904),
                                    CLLocationCoordinate2D(latitude: 51.36458, longitude: 0.03908),
                                    CLLocationCoordinate2D(latitude: 51.36378, longitude: 0.03909),
                                    CLLocationCoordinate2D(latitude: 51.363, longitude: 0.03908),
                                    CLLocationCoordinate2D(latitude: 51.36258, longitude: 0.03908),
                                    CLLocationCoordinate2D(latitude: 51.36258, longitude: 0.03908),
                                    CLLocationCoordinate2D(latitude: 51.36248, longitude: 0.03908),
                                    CLLocationCoordinate2D(latitude: 51.36208, longitude: 0.03911),
                                    CLLocationCoordinate2D(latitude: 51.36109, longitude: 0.03917),
                                    CLLocationCoordinate2D(latitude: 51.36091, longitude: 0.03916),
                                    CLLocationCoordinate2D(latitude: 51.36066, longitude: 0.03907),
                                    CLLocationCoordinate2D(latitude: 51.3605, longitude: 0.03897),
                                    CLLocationCoordinate2D(latitude: 51.36038, longitude: 0.03887),
                                    CLLocationCoordinate2D(latitude: 51.36033, longitude: 0.03884),
                                    CLLocationCoordinate2D(latitude: 51.36033, longitude: 0.03884),
                                    CLLocationCoordinate2D(latitude: 51.36014, longitude: 0.0387),
                                    CLLocationCoordinate2D(latitude: 51.35952, longitude: 0.03826),
                                    CLLocationCoordinate2D(latitude: 51.35879, longitude: 0.03778),
                                    CLLocationCoordinate2D(latitude: 51.35847, longitude: 0.03763),
                                    CLLocationCoordinate2D(latitude: 51.35817, longitude: 0.03756),
                                    CLLocationCoordinate2D(latitude: 51.35755, longitude: 0.03749),
                                    CLLocationCoordinate2D(latitude: 51.35731, longitude: 0.03737),
                                    CLLocationCoordinate2D(latitude: 51.35689, longitude: 0.03704),
                                    CLLocationCoordinate2D(latitude: 51.35676, longitude: 0.0369),
                                    CLLocationCoordinate2D(latitude: 51.35654, longitude: 0.0366),
                                    CLLocationCoordinate2D(latitude: 51.3559, longitude: 0.0356),
                                    CLLocationCoordinate2D(latitude: 51.35475, longitude: 0.03384),
                                    CLLocationCoordinate2D(latitude: 51.35472, longitude: 0.03379),
                                    CLLocationCoordinate2D(latitude: 51.35472, longitude: 0.03379),
                                    CLLocationCoordinate2D(latitude: 51.35445, longitude: 0.03338),
                                    CLLocationCoordinate2D(latitude: 51.35428, longitude: 0.03318),
                                    CLLocationCoordinate2D(latitude: 51.35426, longitude: 0.03317),
                                    CLLocationCoordinate2D(latitude: 51.35423, longitude: 0.03314),
                                    CLLocationCoordinate2D(latitude: 51.35418, longitude: 0.03303),
                                    CLLocationCoordinate2D(latitude: 51.35419, longitude: 0.03296),
                                    CLLocationCoordinate2D(latitude: 51.35407, longitude: 0.03275),
                                    CLLocationCoordinate2D(latitude: 51.35396, longitude: 0.03264),
                                    CLLocationCoordinate2D(latitude: 51.35385, longitude: 0.03251),
                                    CLLocationCoordinate2D(latitude: 51.35331, longitude: 0.0322),
                                    CLLocationCoordinate2D(latitude: 51.35299, longitude: 0.03199),
                                    CLLocationCoordinate2D(latitude: 51.35282, longitude: 0.03185),
                                    CLLocationCoordinate2D(latitude: 51.35238, longitude: 0.03146),
                                    CLLocationCoordinate2D(latitude: 51.35216, longitude: 0.03134),
                                    CLLocationCoordinate2D(latitude: 51.35207, longitude: 0.03131),
                                    CLLocationCoordinate2D(latitude: 51.35192, longitude: 0.03131),
                                    CLLocationCoordinate2D(latitude: 51.35175, longitude: 0.0314),
                                    CLLocationCoordinate2D(latitude: 51.35161, longitude: 0.03158),
                                    CLLocationCoordinate2D(latitude: 51.3513, longitude: 0.03226),
                                    CLLocationCoordinate2D(latitude: 51.35121, longitude: 0.03254),
                                    CLLocationCoordinate2D(latitude: 51.35112, longitude: 0.033),
                                    CLLocationCoordinate2D(latitude: 51.35093, longitude: 0.03417),
                                    CLLocationCoordinate2D(latitude: 51.35088, longitude: 0.03444),
                                    CLLocationCoordinate2D(latitude: 51.35075, longitude: 0.03493),
                                    CLLocationCoordinate2D(latitude: 51.35065, longitude: 0.03514),
                                    CLLocationCoordinate2D(latitude: 51.35052, longitude: 0.03527),
                                    CLLocationCoordinate2D(latitude: 51.34925, longitude: 0.03589),
                                    CLLocationCoordinate2D(latitude: 51.34846, longitude: 0.03626),
                                    CLLocationCoordinate2D(latitude: 51.34825, longitude: 0.03635),
                                    CLLocationCoordinate2D(latitude: 51.34801, longitude: 0.03644),
                                    CLLocationCoordinate2D(latitude: 51.3479, longitude: 0.03646),
                                    CLLocationCoordinate2D(latitude: 51.34777, longitude: 0.03648),
                                    CLLocationCoordinate2D(latitude: 51.34776, longitude: 0.03652),
                                    CLLocationCoordinate2D(latitude: 51.34774, longitude: 0.03656),
                                    CLLocationCoordinate2D(latitude: 51.34769, longitude: 0.03657),
                                    CLLocationCoordinate2D(latitude: 51.34766, longitude: 0.03653),
                                    CLLocationCoordinate2D(latitude: 51.34764, longitude: 0.03646),
                                    CLLocationCoordinate2D(latitude: 51.3472, longitude: 0.03617),
                                    CLLocationCoordinate2D(latitude: 51.34648, longitude: 0.03575),
                                    CLLocationCoordinate2D(latitude: 51.34648, longitude: 0.03575),
                                    CLLocationCoordinate2D(latitude: 51.34644, longitude: 0.03572),
                                    CLLocationCoordinate2D(latitude: 51.34616, longitude: 0.03555),
                                    CLLocationCoordinate2D(latitude: 51.34585, longitude: 0.03534),
                                    CLLocationCoordinate2D(latitude: 51.34567, longitude: 0.03516),
                                    CLLocationCoordinate2D(latitude: 51.3454, longitude: 0.03478),
                                    CLLocationCoordinate2D(latitude: 51.34463, longitude: 0.03367),
                                    CLLocationCoordinate2D(latitude: 51.34434, longitude: 0.03326),
                                    CLLocationCoordinate2D(latitude: 51.34381, longitude: 0.03261),
                                    CLLocationCoordinate2D(latitude: 51.34368, longitude: 0.03245),
                                    CLLocationCoordinate2D(latitude: 51.34368, longitude: 0.03245),
                                    CLLocationCoordinate2D(latitude: 51.34358, longitude: 0.03233),
                                    CLLocationCoordinate2D(latitude: 51.34307, longitude: 0.03168),
                                    CLLocationCoordinate2D(latitude: 51.34272, longitude: 0.03124),
                                    CLLocationCoordinate2D(latitude: 51.34231, longitude: 0.03076),
                                    CLLocationCoordinate2D(latitude: 51.34216, longitude: 0.03062),
                                    CLLocationCoordinate2D(latitude: 51.34191, longitude: 0.03046),
                                    CLLocationCoordinate2D(latitude: 51.34176, longitude: 0.03041),
                                    CLLocationCoordinate2D(latitude: 51.3415, longitude: 0.0304),
                                    CLLocationCoordinate2D(latitude: 51.34108, longitude: 0.03051),
                                    CLLocationCoordinate2D(latitude: 51.34064, longitude: 0.03066),
                                    CLLocationCoordinate2D(latitude: 51.34031, longitude: 0.0307),
                                    CLLocationCoordinate2D(latitude: 51.34004, longitude: 0.03069),
                                    CLLocationCoordinate2D(latitude: 51.33964, longitude: 0.03068),
                                    CLLocationCoordinate2D(latitude: 51.33964, longitude: 0.03068),
                                    CLLocationCoordinate2D(latitude: 51.3391, longitude: 0.03067),
                                    CLLocationCoordinate2D(latitude: 51.33848, longitude: 0.03066),
                                    CLLocationCoordinate2D(latitude: 51.33787, longitude: 0.03064),
                                    CLLocationCoordinate2D(latitude: 51.33717, longitude: 0.03055),
                                    CLLocationCoordinate2D(latitude: 51.33689, longitude: 0.03049),
                                    CLLocationCoordinate2D(latitude: 51.33632, longitude: 0.03031),
                                    CLLocationCoordinate2D(latitude: 51.33628, longitude: 0.03029),
                                    CLLocationCoordinate2D(latitude: 51.33628, longitude: 0.03029),
                                    CLLocationCoordinate2D(latitude: 51.33613, longitude: 0.03021),
                                    CLLocationCoordinate2D(latitude: 51.33589, longitude: 0.03009),
                                    CLLocationCoordinate2D(latitude: 51.33574, longitude: 0.02997),
                                    CLLocationCoordinate2D(latitude: 51.33563, longitude: 0.02984),
                                    CLLocationCoordinate2D(latitude: 51.3353, longitude: 0.02934),
                                    CLLocationCoordinate2D(latitude: 51.3351, longitude: 0.02899),
                                    CLLocationCoordinate2D(latitude: 51.33468, longitude: 0.02839),
                                    CLLocationCoordinate2D(latitude: 51.33407, longitude: 0.02786),
                                    CLLocationCoordinate2D(latitude: 51.33395, longitude: 0.02777),
                                    CLLocationCoordinate2D(latitude: 51.33378, longitude: 0.02769),
                                    CLLocationCoordinate2D(latitude: 51.33355, longitude: 0.02761),
                                    CLLocationCoordinate2D(latitude: 51.33259, longitude: 0.02744),
                                    CLLocationCoordinate2D(latitude: 51.33238, longitude: 0.02741),
                                    CLLocationCoordinate2D(latitude: 51.33238, longitude: 0.02741),
                                    CLLocationCoordinate2D(latitude: 51.33212, longitude: 0.02738),
                                    CLLocationCoordinate2D(latitude: 51.33132, longitude: 0.02722),
                                    CLLocationCoordinate2D(latitude: 51.33094, longitude: 0.02705),
                                    CLLocationCoordinate2D(latitude: 51.3301, longitude: 0.02669),
                                    CLLocationCoordinate2D(latitude: 51.32985, longitude: 0.02655),
                                    CLLocationCoordinate2D(latitude: 51.32972, longitude: 0.02645),
                                    CLLocationCoordinate2D(latitude: 51.32964, longitude: 0.02635),
                                    CLLocationCoordinate2D(latitude: 51.32947, longitude: 0.02606),
                                    CLLocationCoordinate2D(latitude: 51.32933, longitude: 0.0257),
                                    CLLocationCoordinate2D(latitude: 51.3293, longitude: 0.02554),
                                    CLLocationCoordinate2D(latitude: 51.32918, longitude: 0.02472),
                                    CLLocationCoordinate2D(latitude: 51.32918, longitude: 0.02471),
                                    CLLocationCoordinate2D(latitude: 51.32914, longitude: 0.02447),
                                    CLLocationCoordinate2D(latitude: 51.32912, longitude: 0.02428),
                                    CLLocationCoordinate2D(latitude: 51.32908, longitude: 0.02405),
                                    CLLocationCoordinate2D(latitude: 51.32902, longitude: 0.02391),
                                    CLLocationCoordinate2D(latitude: 51.32887, longitude: 0.02361),
                                    CLLocationCoordinate2D(latitude: 51.32873, longitude: 0.02343),
                                    CLLocationCoordinate2D(latitude: 51.32858, longitude: 0.02328),
                                    CLLocationCoordinate2D(latitude: 51.32831, longitude: 0.02312),
                                    CLLocationCoordinate2D(latitude: 51.32802, longitude: 0.02297),
                                    CLLocationCoordinate2D(latitude: 51.32771, longitude: 0.02282),
                                    CLLocationCoordinate2D(latitude: 51.32759, longitude: 0.02279),
                                    CLLocationCoordinate2D(latitude: 51.32731, longitude: 0.02273),
                                    CLLocationCoordinate2D(latitude: 51.327, longitude: 0.0227),
                                    CLLocationCoordinate2D(latitude: 51.32681, longitude: 0.0227),
                                    CLLocationCoordinate2D(latitude: 51.32662, longitude: 0.02273),
                                    CLLocationCoordinate2D(latitude: 51.32646, longitude: 0.02277),
                                    CLLocationCoordinate2D(latitude: 51.32627, longitude: 0.02286),
                                    CLLocationCoordinate2D(latitude: 51.32621, longitude: 0.02295),
                                    CLLocationCoordinate2D(latitude: 51.32608, longitude: 0.02301),
                                    CLLocationCoordinate2D(latitude: 51.32574, longitude: 0.02321),
                                    CLLocationCoordinate2D(latitude: 51.32547, longitude: 0.02358),
                                    CLLocationCoordinate2D(latitude: 51.32534, longitude: 0.02373),
                                    CLLocationCoordinate2D(latitude: 51.32534, longitude: 0.02373),
                                    CLLocationCoordinate2D(latitude: 51.32529, longitude: 0.02377),
                                    CLLocationCoordinate2D(latitude: 51.32419, longitude: 0.02539),
                                    CLLocationCoordinate2D(latitude: 51.32395, longitude: 0.02571),
                                    CLLocationCoordinate2D(latitude: 51.32355, longitude: 0.02618),
                                    CLLocationCoordinate2D(latitude: 51.32297, longitude: 0.02664),
                                    CLLocationCoordinate2D(latitude: 51.32272, longitude: 0.02688),
                                    CLLocationCoordinate2D(latitude: 51.32267, longitude: 0.02699),
                                    CLLocationCoordinate2D(latitude: 51.32247, longitude: 0.02721),
                                    CLLocationCoordinate2D(latitude: 51.32201, longitude: 0.02767),
                                    CLLocationCoordinate2D(latitude: 51.32201, longitude: 0.02767),
                                    CLLocationCoordinate2D(latitude: 51.3219, longitude: 0.02778),
                                    CLLocationCoordinate2D(latitude: 51.32164, longitude: 0.02807),
                                    CLLocationCoordinate2D(latitude: 51.32144, longitude: 0.02827),
                                    CLLocationCoordinate2D(latitude: 51.32116, longitude: 0.02848),
                                    CLLocationCoordinate2D(latitude: 51.32084, longitude: 0.02866),
                                    CLLocationCoordinate2D(latitude: 51.32045, longitude: 0.02888),
                                    CLLocationCoordinate2D(latitude: 51.32043, longitude: 0.02892),
                                    CLLocationCoordinate2D(latitude: 51.32038, longitude: 0.02897),
                                    CLLocationCoordinate2D(latitude: 51.32032, longitude: 0.02897),
                                    CLLocationCoordinate2D(latitude: 51.32029, longitude: 0.02895),
                                    CLLocationCoordinate2D(latitude: 51.32028, longitude: 0.02894),
                                    CLLocationCoordinate2D(latitude: 51.3202, longitude: 0.02896),
                                    CLLocationCoordinate2D(latitude: 51.32004, longitude: 0.02907),
                                    CLLocationCoordinate2D(latitude: 51.31973, longitude: 0.02932),
                                    CLLocationCoordinate2D(latitude: 51.31961, longitude: 0.02939),
                                    CLLocationCoordinate2D(latitude: 51.31908, longitude: 0.03018),
                                    CLLocationCoordinate2D(latitude: 51.31826, longitude: 0.03141),
                                    CLLocationCoordinate2D(latitude: 51.31791, longitude: 0.03196),
                                    CLLocationCoordinate2D(latitude: 51.3177, longitude: 0.03221),
                                    CLLocationCoordinate2D(latitude: 51.31752, longitude: 0.03237),
                                    CLLocationCoordinate2D(latitude: 51.31729, longitude: 0.03256),
                                    CLLocationCoordinate2D(latitude: 51.31699, longitude: 0.03273),
                                    CLLocationCoordinate2D(latitude: 51.31656, longitude: 0.03289),
                                    CLLocationCoordinate2D(latitude: 51.31656, longitude: 0.03289),
                                    CLLocationCoordinate2D(latitude: 51.31678, longitude: 0.03281),
                                    CLLocationCoordinate2D(latitude: 51.31682, longitude: 0.03307),
                                    CLLocationCoordinate2D(latitude: 51.31688, longitude: 0.03342),
                                    CLLocationCoordinate2D(latitude: 51.31704, longitude: 0.03484),
                                    CLLocationCoordinate2D(latitude: 51.31711, longitude: 0.0356),
                                    CLLocationCoordinate2D(latitude: 51.31711, longitude: 0.03598),
                                    CLLocationCoordinate2D(latitude: 51.31689, longitude: 0.03763),
                                    CLLocationCoordinate2D(latitude: 51.31675, longitude: 0.03845),
                                    CLLocationCoordinate2D(latitude: 51.31664, longitude: 0.03882),
                                    CLLocationCoordinate2D(latitude: 51.31652, longitude: 0.03918),
                                    CLLocationCoordinate2D(latitude: 51.31619, longitude: 0.03986),
                                    CLLocationCoordinate2D(latitude: 51.31619, longitude: 0.03986),
                                    CLLocationCoordinate2D(latitude: 51.31591, longitude: 0.0404),
                                    CLLocationCoordinate2D(latitude: 51.31566, longitude: 0.04097),
                                    CLLocationCoordinate2D(latitude: 51.3156, longitude: 0.04118),
                                    CLLocationCoordinate2D(latitude: 51.31556, longitude: 0.04142),
                                    CLLocationCoordinate2D(latitude: 51.31554, longitude: 0.04168),
                                    CLLocationCoordinate2D(latitude: 51.31558, longitude: 0.04311),
                                    CLLocationCoordinate2D(latitude: 51.31553, longitude: 0.04375),
                                    CLLocationCoordinate2D(latitude: 51.31577, longitude: 0.04387),
                                    CLLocationCoordinate2D(latitude: 51.31572, longitude: 0.04414),
                                    CLLocationCoordinate2D(latitude: 51.31565, longitude: 0.04448)
                        ]
                        let encodedPolyLine =  polyLine.encode(coordinates: list)!
                        let list2 = polyLine.decode(polyLine:encodedPolyLine)
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
