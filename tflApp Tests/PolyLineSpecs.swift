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
                fit("should be able to decode polylinedict") {
                    let fileName = Bundle.main.url(forResource: "PolylineDict", withExtension: "plist")!
                    let dict  = NSDictionary(contentsOf: fileName)!
                    
                    let polyLine = PolyLine(precision: 5)
                    for (_,value) in dict {
                        let coords = polyLine.decode(polyLine: value as! String)
                        expect(coords).notTo(beEmpty())
                    }
                }
                
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
                        expect(total / 100) <= 0.0110
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
                    
                    it ("should encode & decode coordinates with small latitudes") {
                        let polyLine = PolyLine(precision: 5)
                        let list = [CLLocationCoordinate2D(latitude: 51.54289, longitude: -0.00007)]
                        let encodedPolyLine =  polyLine.encode(coordinates: list)!
                        let list2 = polyLine.decode(polyLine:encodedPolyLine)
                        expect(list).to(equal(list2))
                    }
                    
                  
                    
                    it ("should encode & decode a real world example correctly") {
                        let polyLine = PolyLine(precision: 5)
                        let list = [
                                CLLocationCoordinate2D(latitude: 51.5176, longitude: -0.106),
                                CLLocationCoordinate2D(latitude: 51.51754, longitude: -0.10604),
                                CLLocationCoordinate2D(latitude: 51.51752, longitude: -0.10596),
                                CLLocationCoordinate2D(latitude: 51.51741, longitude: -0.10559),
                                CLLocationCoordinate2D(latitude: 51.51722, longitude: -0.10496),
                                CLLocationCoordinate2D(latitude: 51.51711, longitude: -0.10444),
                                CLLocationCoordinate2D(latitude: 51.51701, longitude: -0.10417),
                                CLLocationCoordinate2D(latitude: 51.51686, longitude: -0.10372),
                                CLLocationCoordinate2D(latitude: 51.51686, longitude: -0.10372),
                                CLLocationCoordinate2D(latitude: 51.51674, longitude: -0.10338),
                                CLLocationCoordinate2D(latitude: 51.51666, longitude: -0.10324),
                                CLLocationCoordinate2D(latitude: 51.51663, longitude: -0.10312),
                                CLLocationCoordinate2D(latitude: 51.51635, longitude: -0.10221),
                                CLLocationCoordinate2D(latitude: 51.51624, longitude: -0.10194),
                                CLLocationCoordinate2D(latitude: 51.5161, longitude: -0.10147),
                                CLLocationCoordinate2D(latitude: 51.51577, longitude: -0.10021),
                                CLLocationCoordinate2D(latitude: 51.51565, longitude: -0.09974),
                                CLLocationCoordinate2D(latitude: 51.51565, longitude: -0.09974),
                                CLLocationCoordinate2D(latitude: 51.51562, longitude: -0.09964),
                                CLLocationCoordinate2D(latitude: 51.5156, longitude: -0.09941),
                                CLLocationCoordinate2D(latitude: 51.51559, longitude: -0.09923),
                                CLLocationCoordinate2D(latitude: 51.51564, longitude: -0.09871),
                                CLLocationCoordinate2D(latitude: 51.51567, longitude: -0.09864),
                                CLLocationCoordinate2D(latitude: 51.51575, longitude: -0.09863),
                                CLLocationCoordinate2D(latitude: 51.51595, longitude: -0.09861),
                                CLLocationCoordinate2D(latitude: 51.51609, longitude: -0.09842),
                                CLLocationCoordinate2D(latitude: 51.51613, longitude: -0.09829),
                                CLLocationCoordinate2D(latitude: 51.51609, longitude: -0.09749),
                                CLLocationCoordinate2D(latitude: 51.51605, longitude: -0.0973),
                                CLLocationCoordinate2D(latitude: 51.51602, longitude: -0.09725),
                                CLLocationCoordinate2D(latitude: 51.51593, longitude: -0.09717),
                                CLLocationCoordinate2D(latitude: 51.51576, longitude: -0.09708),
                                CLLocationCoordinate2D(latitude: 51.51557, longitude: -0.09713),
                                CLLocationCoordinate2D(latitude: 51.51542, longitude: -0.09716),
                                CLLocationCoordinate2D(latitude: 51.51527, longitude: -0.09717),
                                CLLocationCoordinate2D(latitude: 51.51504, longitude: -0.09719),
                                CLLocationCoordinate2D(latitude: 51.51494, longitude: -0.09712),
                                CLLocationCoordinate2D(latitude: 51.5148, longitude: -0.09695),
                                CLLocationCoordinate2D(latitude: 51.51473, longitude: -0.09687),
                                CLLocationCoordinate2D(latitude: 51.51466, longitude: -0.09684),
                                CLLocationCoordinate2D(latitude: 51.51461, longitude: -0.09681),
                                CLLocationCoordinate2D(latitude: 51.51436, longitude: -0.09686),
                                CLLocationCoordinate2D(latitude: 51.51421, longitude: -0.0968),
                                CLLocationCoordinate2D(latitude: 51.51399, longitude: -0.09656),
                                CLLocationCoordinate2D(latitude: 51.51383, longitude: -0.09644),
                                CLLocationCoordinate2D(latitude: 51.51368, longitude: -0.09637),
                                CLLocationCoordinate2D(latitude: 51.5135, longitude: -0.09633),
                                CLLocationCoordinate2D(latitude: 51.51346, longitude: -0.09634),
                                CLLocationCoordinate2D(latitude: 51.51346, longitude: -0.09621),
                                CLLocationCoordinate2D(latitude: 51.51346, longitude: -0.09628),
                                CLLocationCoordinate2D(latitude: 51.5135, longitude: -0.09628),
                                CLLocationCoordinate2D(latitude: 51.51359, longitude: -0.09628),
                                CLLocationCoordinate2D(latitude: 51.51376, longitude: -0.09634),
                                CLLocationCoordinate2D(latitude: 51.51381, longitude: -0.09637),
                                CLLocationCoordinate2D(latitude: 51.51383, longitude: -0.09631),
                                CLLocationCoordinate2D(latitude: 51.51382, longitude: -0.0961),
                                CLLocationCoordinate2D(latitude: 51.51388, longitude: -0.09559),
                                CLLocationCoordinate2D(latitude: 51.51399, longitude: -0.09548),
                                CLLocationCoordinate2D(latitude: 51.51423, longitude: -0.09538),
                                CLLocationCoordinate2D(latitude: 51.51429, longitude: -0.09536),
                                CLLocationCoordinate2D(latitude: 51.51431, longitude: -0.09554),
                                CLLocationCoordinate2D(latitude: 51.51432, longitude: -0.0956),
                                CLLocationCoordinate2D(latitude: 51.51439, longitude: -0.09557),
                                CLLocationCoordinate2D(latitude: 51.51441, longitude: -0.09564),
                                CLLocationCoordinate2D(latitude: 51.51443, longitude: -0.09565),
                                CLLocationCoordinate2D(latitude: 51.51438, longitude: -0.09568),
                                CLLocationCoordinate2D(latitude: 51.51435, longitude: -0.09552),
                                CLLocationCoordinate2D(latitude: 51.51429, longitude: -0.09508),
                                CLLocationCoordinate2D(latitude: 51.5142, longitude: -0.09461),
                                CLLocationCoordinate2D(latitude: 51.514, longitude: -0.09336),
                                CLLocationCoordinate2D(latitude: 51.51387, longitude: -0.09258),
                                CLLocationCoordinate2D(latitude: 51.51373, longitude: -0.09167),
                                CLLocationCoordinate2D(latitude: 51.5137, longitude: -0.09144),
                                CLLocationCoordinate2D(latitude: 51.5137, longitude: -0.09144),
                                CLLocationCoordinate2D(latitude: 51.51365, longitude: -0.09117),
                                CLLocationCoordinate2D(latitude: 51.51357, longitude: -0.09067),
                                CLLocationCoordinate2D(latitude: 51.51336, longitude: -0.08949),
                                CLLocationCoordinate2D(latitude: 51.51335, longitude: -0.08904),
                                CLLocationCoordinate2D(latitude: 51.51339, longitude: -0.08894),
                                CLLocationCoordinate2D(latitude: 51.51338, longitude: -0.08853),
                                CLLocationCoordinate2D(latitude: 51.51336, longitude: -0.08816),
                                CLLocationCoordinate2D(latitude: 51.51334, longitude: -0.08794),
                                CLLocationCoordinate2D(latitude: 51.51333, longitude: -0.0875),
                                CLLocationCoordinate2D(latitude: 51.51333, longitude: -0.08746),
                                CLLocationCoordinate2D(latitude: 51.51333, longitude: -0.08719),
                                CLLocationCoordinate2D(latitude: 51.51337, longitude: -0.08666),
                                CLLocationCoordinate2D(latitude: 51.5134, longitude: -0.08529),
                                CLLocationCoordinate2D(latitude: 51.51341, longitude: -0.08506),
                                CLLocationCoordinate2D(latitude: 51.51341, longitude: -0.08503),
                                CLLocationCoordinate2D(latitude: 51.51342, longitude: -0.0848),
                                CLLocationCoordinate2D(latitude: 51.51341, longitude: -0.08388),
                                CLLocationCoordinate2D(latitude: 51.51344, longitude: -0.08334),
                                CLLocationCoordinate2D(latitude: 51.51347, longitude: -0.0829),
                                CLLocationCoordinate2D(latitude: 51.51347, longitude: -0.08271),
                                CLLocationCoordinate2D(latitude: 51.51347, longitude: -0.0827),
                                CLLocationCoordinate2D(latitude: 51.51348, longitude: -0.08226),
                                CLLocationCoordinate2D(latitude: 51.51353, longitude: -0.08125),
                                CLLocationCoordinate2D(latitude: 51.51344, longitude: -0.08033),
                                CLLocationCoordinate2D(latitude: 51.51333, longitude: -0.07942),
                                CLLocationCoordinate2D(latitude: 51.51328, longitude: -0.07867),
                                CLLocationCoordinate2D(latitude: 51.51328, longitude: -0.07865),
                                CLLocationCoordinate2D(latitude: 51.51326, longitude: -0.07788),
                                CLLocationCoordinate2D(latitude: 51.51327, longitude: -0.07769),
                                CLLocationCoordinate2D(latitude: 51.51357, longitude: -0.07677),
                                CLLocationCoordinate2D(latitude: 51.51364, longitude: -0.07657),
                                CLLocationCoordinate2D(latitude: 51.51377, longitude: -0.07607),
                                CLLocationCoordinate2D(latitude: 51.51401, longitude: -0.07532),
                                CLLocationCoordinate2D(latitude: 51.51401, longitude: -0.07532),
                                CLLocationCoordinate2D(latitude: 51.51406, longitude: -0.0752),
                                CLLocationCoordinate2D(latitude: 51.51422, longitude: -0.07474),
                                CLLocationCoordinate2D(latitude: 51.51446, longitude: -0.0741),
                                CLLocationCoordinate2D(latitude: 51.51468, longitude: -0.07341),
                                CLLocationCoordinate2D(latitude: 51.51526, longitude: -0.07177),
                                CLLocationCoordinate2D(latitude: 51.51547, longitude: -0.07117),
                                CLLocationCoordinate2D(latitude: 51.51547, longitude: -0.07117),
                                CLLocationCoordinate2D(latitude: 51.51554, longitude: -0.07098),
                                CLLocationCoordinate2D(latitude: 51.51569, longitude: -0.07054),
                                CLLocationCoordinate2D(latitude: 51.51578, longitude: -0.07029),
                                CLLocationCoordinate2D(latitude: 51.51622, longitude: -0.06939),
                                CLLocationCoordinate2D(latitude: 51.51649, longitude: -0.0688),
                                CLLocationCoordinate2D(latitude: 51.51663, longitude: -0.0685),
                                CLLocationCoordinate2D(latitude: 51.51663, longitude: -0.0685),
                                CLLocationCoordinate2D(latitude: 51.51673, longitude: -0.06829),
                                CLLocationCoordinate2D(latitude: 51.51685, longitude: -0.06801),
                                CLLocationCoordinate2D(latitude: 51.51711, longitude: -0.06741),
                                CLLocationCoordinate2D(latitude: 51.51729, longitude: -0.06697),
                                CLLocationCoordinate2D(latitude: 51.51737, longitude: -0.0667),
                                CLLocationCoordinate2D(latitude: 51.51789, longitude: -0.06505),
                                CLLocationCoordinate2D(latitude: 51.51805, longitude: -0.06446),
                                CLLocationCoordinate2D(latitude: 51.51805, longitude: -0.06446),
                                CLLocationCoordinate2D(latitude: 51.51818, longitude: -0.06398),
                                CLLocationCoordinate2D(latitude: 51.51834, longitude: -0.06324),
                                CLLocationCoordinate2D(latitude: 51.51847, longitude: -0.06293),
                                CLLocationCoordinate2D(latitude: 51.51877, longitude: -0.06151),
                                CLLocationCoordinate2D(latitude: 51.51918, longitude: -0.05966),
                                CLLocationCoordinate2D(latitude: 51.51929, longitude: -0.05922),
                                CLLocationCoordinate2D(latitude: 51.51937, longitude: -0.05882),
                                CLLocationCoordinate2D(latitude: 51.51937, longitude: -0.05882),
                                CLLocationCoordinate2D(latitude: 51.51941, longitude: -0.05863),
                                CLLocationCoordinate2D(latitude: 51.51954, longitude: -0.05803),
                                CLLocationCoordinate2D(latitude: 51.51962, longitude: -0.05763),
                                CLLocationCoordinate2D(latitude: 51.51982, longitude: -0.05674),
                                CLLocationCoordinate2D(latitude: 51.51994, longitude: -0.05618),
                                CLLocationCoordinate2D(latitude: 51.51998, longitude: -0.05582),
                                CLLocationCoordinate2D(latitude: 51.51999, longitude: -0.05551),
                                CLLocationCoordinate2D(latitude: 51.5201, longitude: -0.05498),
                                CLLocationCoordinate2D(latitude: 51.5202, longitude: -0.05444),
                                CLLocationCoordinate2D(latitude: 51.52023, longitude: -0.05425),
                                CLLocationCoordinate2D(latitude: 51.52023, longitude: -0.05425),
                                CLLocationCoordinate2D(latitude: 51.5203, longitude: -0.05387),
                                CLLocationCoordinate2D(latitude: 51.52045, longitude: -0.05309),
                                CLLocationCoordinate2D(latitude: 51.52072, longitude: -0.05167),
                                CLLocationCoordinate2D(latitude: 51.52085, longitude: -0.05107),
                                CLLocationCoordinate2D(latitude: 51.52085, longitude: -0.05107),
                                CLLocationCoordinate2D(latitude: 51.52088, longitude: -0.0509),
                                CLLocationCoordinate2D(latitude: 51.52106, longitude: -0.05005),
                                CLLocationCoordinate2D(latitude: 51.52123, longitude: -0.04928),
                                CLLocationCoordinate2D(latitude: 51.52158, longitude: -0.04761),
                                CLLocationCoordinate2D(latitude: 51.52164, longitude: -0.04729),
                                CLLocationCoordinate2D(latitude: 51.52171, longitude: -0.04693),
                                CLLocationCoordinate2D(latitude: 51.52171, longitude: -0.04693),
                                CLLocationCoordinate2D(latitude: 51.52172, longitude: -0.04686),
                                CLLocationCoordinate2D(latitude: 51.52189, longitude: -0.04606),
                                CLLocationCoordinate2D(latitude: 51.52209, longitude: -0.04498),
                                CLLocationCoordinate2D(latitude: 51.52216, longitude: -0.04462),
                                CLLocationCoordinate2D(latitude: 51.52216, longitude: -0.04462),
                                CLLocationCoordinate2D(latitude: 51.52217, longitude: -0.04454),
                                CLLocationCoordinate2D(latitude: 51.52222, longitude: -0.0442),
                                CLLocationCoordinate2D(latitude: 51.5223, longitude: -0.04305),
                                CLLocationCoordinate2D(latitude: 51.52234, longitude: -0.04273),
                                CLLocationCoordinate2D(latitude: 51.52253, longitude: -0.04169),
                                CLLocationCoordinate2D(latitude: 51.52265, longitude: -0.0411),
                                CLLocationCoordinate2D(latitude: 51.5227, longitude: -0.04091),
                                CLLocationCoordinate2D(latitude: 51.52274, longitude: -0.04077),
                                CLLocationCoordinate2D(latitude: 51.52274, longitude: -0.04077),
                                CLLocationCoordinate2D(latitude: 51.52276, longitude: -0.0407),
                                CLLocationCoordinate2D(latitude: 51.52286, longitude: -0.0404),
                                CLLocationCoordinate2D(latitude: 51.52307, longitude: -0.03972),
                                CLLocationCoordinate2D(latitude: 51.52321, longitude: -0.03928),
                                CLLocationCoordinate2D(latitude: 51.52335, longitude: -0.03889),
                                CLLocationCoordinate2D(latitude: 51.52347, longitude: -0.03863),
                                CLLocationCoordinate2D(latitude: 51.52394, longitude: -0.03773),
                                CLLocationCoordinate2D(latitude: 51.52413, longitude: -0.03733),
                                CLLocationCoordinate2D(latitude: 51.52427, longitude: -0.03698),
                                CLLocationCoordinate2D(latitude: 51.52427, longitude: -0.03698),
                                CLLocationCoordinate2D(latitude: 51.52434, longitude: -0.0368),
                                CLLocationCoordinate2D(latitude: 51.52462, longitude: -0.03605),
                                CLLocationCoordinate2D(latitude: 51.52465, longitude: -0.03595),
                                CLLocationCoordinate2D(latitude: 51.52469, longitude: -0.03594),
                                CLLocationCoordinate2D(latitude: 51.52471, longitude: -0.03591),
                                CLLocationCoordinate2D(latitude: 51.52481, longitude: -0.03565),
                                CLLocationCoordinate2D(latitude: 51.52506, longitude: -0.03489),
                                CLLocationCoordinate2D(latitude: 51.52522, longitude: -0.03435),
                                CLLocationCoordinate2D(latitude: 51.52534, longitude: -0.03387),
                                CLLocationCoordinate2D(latitude: 51.52534, longitude: -0.03387),
                                CLLocationCoordinate2D(latitude: 51.52539, longitude: -0.03365),
                                CLLocationCoordinate2D(latitude: 51.52553, longitude: -0.03306),
                                CLLocationCoordinate2D(latitude: 51.52619, longitude: -0.02995),
                                CLLocationCoordinate2D(latitude: 51.52636, longitude: -0.02916),
                                CLLocationCoordinate2D(latitude: 51.52636, longitude: -0.02916),
                                CLLocationCoordinate2D(latitude: 51.52644, longitude: -0.02878),
                                CLLocationCoordinate2D(latitude: 51.52657, longitude: -0.02821),
                                CLLocationCoordinate2D(latitude: 51.52663, longitude: -0.02788),
                                CLLocationCoordinate2D(latitude: 51.52665, longitude: -0.02777),
                                CLLocationCoordinate2D(latitude: 51.52663, longitude: -0.02769),
                                CLLocationCoordinate2D(latitude: 51.52701, longitude: -0.026),
                                CLLocationCoordinate2D(latitude: 51.52702, longitude: -0.026),
                                CLLocationCoordinate2D(latitude: 51.52702, longitude: -0.026),
                                CLLocationCoordinate2D(latitude: 51.52715, longitude: -0.02535),
                                CLLocationCoordinate2D(latitude: 51.5272, longitude: -0.02518),
                                CLLocationCoordinate2D(latitude: 51.52723, longitude: -0.02513),
                                CLLocationCoordinate2D(latitude: 51.52726, longitude: -0.02505),
                                CLLocationCoordinate2D(latitude: 51.52744, longitude: -0.02413),
                                CLLocationCoordinate2D(latitude: 51.52742, longitude: -0.02398),
                                CLLocationCoordinate2D(latitude: 51.52762, longitude: -0.02293),
                                CLLocationCoordinate2D(latitude: 51.52785, longitude: -0.02165),
                                CLLocationCoordinate2D(latitude: 51.52802, longitude: -0.02054),
                                CLLocationCoordinate2D(latitude: 51.52815, longitude: -0.02059),
                                CLLocationCoordinate2D(latitude: 51.52815, longitude: -0.02059),
                                CLLocationCoordinate2D(latitude: 51.52895, longitude: -0.01685),
                                CLLocationCoordinate2D(latitude: 51.52895, longitude: -0.01685),
                                CLLocationCoordinate2D(latitude: 51.53128, longitude: -0.01117),
                                CLLocationCoordinate2D(latitude: 51.53128, longitude: -0.01117),
                                CLLocationCoordinate2D(latitude: 51.53468, longitude: -0.00647),
                                CLLocationCoordinate2D(latitude: 51.53468, longitude: -0.00647),
                                CLLocationCoordinate2D(latitude: 51.53466, longitude: -0.00638),
                                CLLocationCoordinate2D(latitude: 51.53509, longitude: -0.00589),
                                CLLocationCoordinate2D(latitude: 51.53528, longitude: -0.00568),
                                CLLocationCoordinate2D(latitude: 51.53556, longitude: -0.00534),
                                CLLocationCoordinate2D(latitude: 51.53625, longitude: -0.0044),
                                CLLocationCoordinate2D(latitude: 51.53669, longitude: -0.00379),
                                CLLocationCoordinate2D(latitude: 51.53689, longitude: -0.00352),
                                CLLocationCoordinate2D(latitude: 51.53689, longitude: -0.00352),
                                CLLocationCoordinate2D(latitude: 51.53695, longitude: -0.00345),
                                CLLocationCoordinate2D(latitude: 51.53793, longitude: -0.00217),
                                CLLocationCoordinate2D(latitude: 51.53853, longitude: -0.00143),
                                CLLocationCoordinate2D(latitude: 51.53903, longitude: -0.00083),
                                CLLocationCoordinate2D(latitude: 51.53941, longitude: -0.00043),
                                CLLocationCoordinate2D(latitude: 51.53954, longitude: -0.00054),
                                CLLocationCoordinate2D(latitude: 51.5399, longitude: -0.00082),
                                CLLocationCoordinate2D(latitude: 51.54035, longitude: -0.00128),
                                CLLocationCoordinate2D(latitude: 51.54035, longitude: -0.00136),
                                CLLocationCoordinate2D(latitude: 51.54034, longitude: -0.00154),
                                CLLocationCoordinate2D(latitude: 51.54035, longitude: -0.00188),
                                CLLocationCoordinate2D(latitude: 51.5404, longitude: -0.00212),
                                CLLocationCoordinate2D(latitude: 51.54051, longitude: -0.00208),
                                CLLocationCoordinate2D(latitude: 51.54052, longitude: -0.0021),
                                CLLocationCoordinate2D(latitude: 51.54055, longitude: -0.00215),
                                CLLocationCoordinate2D(latitude: 51.54065, longitude: -0.00225),
                                CLLocationCoordinate2D(latitude: 51.54091, longitude: -0.00235),
                                CLLocationCoordinate2D(latitude: 51.54088, longitude: -0.00258),
                                CLLocationCoordinate2D(latitude: 51.54094, longitude: -0.00256),
                                CLLocationCoordinate2D(latitude: 51.54104, longitude: -0.00267),
                                CLLocationCoordinate2D(latitude: 51.54114, longitude: -0.00269),
                                CLLocationCoordinate2D(latitude: 51.54125, longitude: -0.00268),
                                CLLocationCoordinate2D(latitude: 51.54132, longitude: -0.00267),
                                CLLocationCoordinate2D(latitude: 51.54133, longitude: -0.00264),
                                CLLocationCoordinate2D(latitude: 51.54163, longitude: -0.00189),
                                CLLocationCoordinate2D(latitude: 51.54166, longitude: -0.00174),
                                CLLocationCoordinate2D(latitude: 51.54174, longitude: -0.00174),
                                CLLocationCoordinate2D(latitude: 51.54196, longitude: -0.00169),
                                CLLocationCoordinate2D(latitude: 51.54207, longitude: -0.00165),
                                CLLocationCoordinate2D(latitude: 51.54222, longitude: -0.00157),
                                CLLocationCoordinate2D(latitude: 51.54238, longitude: -0.00142),
                                CLLocationCoordinate2D(latitude: 51.54248, longitude: -0.00126),
                                CLLocationCoordinate2D(latitude: 51.54264, longitude: -0.00088),
                                CLLocationCoordinate2D(latitude: 51.54272, longitude: -0.00062),
                                CLLocationCoordinate2D(latitude: 51.54285, longitude: -0.00004),
                                CLLocationCoordinate2D(latitude: 51.54304, longitude: 0.00078),
                                CLLocationCoordinate2D(latitude: 51.54337, longitude: 0.00197),
                                CLLocationCoordinate2D(latitude: 51.54347, longitude: 0.00231),
                                CLLocationCoordinate2D(latitude: 51.54345, longitude: 0.00232),
                                CLLocationCoordinate2D(latitude: 51.54351, longitude: 0.00229),
                                CLLocationCoordinate2D(latitude: 51.54338, longitude: 0.00181),
                                CLLocationCoordinate2D(latitude: 51.54315, longitude: 0.001),
                                CLLocationCoordinate2D(latitude: 51.54289, longitude: -0.00007),
                                CLLocationCoordinate2D(latitude: 51.54276, longitude: -0.00065),
                                CLLocationCoordinate2D(latitude: 51.54266, longitude: -0.00098),
                                CLLocationCoordinate2D(latitude: 51.54247, longitude: -0.00139),
                                CLLocationCoordinate2D(latitude: 51.54233, longitude: -0.00157),
                                CLLocationCoordinate2D(latitude: 51.54214, longitude: -0.0017),
                                CLLocationCoordinate2D(latitude: 51.54202, longitude: -0.00174),
                                CLLocationCoordinate2D(latitude: 51.54183, longitude: -0.0018),
                                CLLocationCoordinate2D(latitude: 51.54166, longitude: -0.00181),
                                CLLocationCoordinate2D(latitude: 51.54137, longitude: -0.00177),
                                CLLocationCoordinate2D(latitude: 51.54114, longitude: -0.00169),
                                CLLocationCoordinate2D(latitude: 51.54104, longitude: -0.00165),
                                CLLocationCoordinate2D(latitude: 51.54105, longitude: -0.00163),
                                CLLocationCoordinate2D(latitude: 51.5405, longitude: -0.00138),
                                CLLocationCoordinate2D(latitude: 51.5397, longitude: -0.00068),
                                CLLocationCoordinate2D(latitude: 51.5396, longitude: -0.0002),
                                CLLocationCoordinate2D(latitude: 51.5403, longitude: 0.00064),
                                CLLocationCoordinate2D(latitude: 51.541, longitude: 0.00201),
                                CLLocationCoordinate2D(latitude: 51.5409, longitude: 0.00233),
                                CLLocationCoordinate2D(latitude: 51.5406, longitude: 0.00265),
                                CLLocationCoordinate2D(latitude: 51.54041, longitude: 0.0027),
                                CLLocationCoordinate2D(latitude: 51.54043, longitude: 0.00279),
                                CLLocationCoordinate2D(latitude: 51.54052, longitude: 0.00276),
                                CLLocationCoordinate2D(latitude: 51.54066, longitude: 0.00269),
                                CLLocationCoordinate2D(latitude: 51.54082, longitude: 0.00253),
                                CLLocationCoordinate2D(latitude: 51.54105, longitude: 0.0023),
                                CLLocationCoordinate2D(latitude: 51.54116, longitude: 0.00217),
                                CLLocationCoordinate2D(latitude: 51.54105, longitude: 0.00195),
                                CLLocationCoordinate2D(latitude: 51.54079, longitude: 0.00141),
                                CLLocationCoordinate2D(latitude: 51.54073, longitude: 0.0013),
                                CLLocationCoordinate2D(latitude: 51.54074, longitude: 0.00126),
                                CLLocationCoordinate2D(latitude: 51.54077, longitude: 0.00122),
                                CLLocationCoordinate2D(latitude: 51.54084, longitude: 0.00115),
                                CLLocationCoordinate2D(latitude: 51.54081, longitude: 0.00108),
                                CLLocationCoordinate2D(latitude: 51.54075, longitude: 0.00105),
                                CLLocationCoordinate2D(latitude: 51.54064, longitude: 0.00124),
                                CLLocationCoordinate2D(latitude: 51.54083, longitude: 0.00162),
                                CLLocationCoordinate2D(latitude: 51.54121, longitude: 0.00242),
                                CLLocationCoordinate2D(latitude: 51.54166, longitude: 0.00335),
                                CLLocationCoordinate2D(latitude: 51.54187, longitude: 0.00385),
                                CLLocationCoordinate2D(latitude: 51.54201, longitude: 0.00428),
                                CLLocationCoordinate2D(latitude: 51.54211, longitude: 0.00482),
                                CLLocationCoordinate2D(latitude: 51.54212, longitude: 0.0049),
                                CLLocationCoordinate2D(latitude: 51.54212, longitude: 0.0049),
                                CLLocationCoordinate2D(latitude: 51.54214, longitude: 0.00503),
                                CLLocationCoordinate2D(latitude: 51.54218, longitude: 0.00532),
                                CLLocationCoordinate2D(latitude: 51.54223, longitude: 0.00604),
                                CLLocationCoordinate2D(latitude: 51.54242, longitude: 0.00784),
                                CLLocationCoordinate2D(latitude: 51.5425, longitude: 0.00826),
                                CLLocationCoordinate2D(latitude: 51.54261, longitude: 0.00867),
                                CLLocationCoordinate2D(latitude: 51.54262, longitude: 0.00868),
                                CLLocationCoordinate2D(latitude: 51.54269, longitude: 0.00892),
                                CLLocationCoordinate2D(latitude: 51.543, longitude: 0.01002),
                                CLLocationCoordinate2D(latitude: 51.54353, longitude: 0.01193),
                                CLLocationCoordinate2D(latitude: 51.54398, longitude: 0.01365),
                                CLLocationCoordinate2D(latitude: 51.54418, longitude: 0.01446),
                                CLLocationCoordinate2D(latitude: 51.54438, longitude: 0.01524),
                                CLLocationCoordinate2D(latitude: 51.54438, longitude: 0.01524),
                                CLLocationCoordinate2D(latitude: 51.54449, longitude: 0.01565),
                                CLLocationCoordinate2D(latitude: 51.54468, longitude: 0.0164),
                                CLLocationCoordinate2D(latitude: 51.54515, longitude: 0.01819),
                                CLLocationCoordinate2D(latitude: 51.54553, longitude: 0.01957),
                                CLLocationCoordinate2D(latitude: 51.54574, longitude: 0.02045),
                                CLLocationCoordinate2D(latitude: 51.54579, longitude: 0.02069),
                                CLLocationCoordinate2D(latitude: 51.54579, longitude: 0.02069),
                                CLLocationCoordinate2D(latitude: 51.54588, longitude: 0.02114),
                                CLLocationCoordinate2D(latitude: 51.54611, longitude: 0.0223),
                                CLLocationCoordinate2D(latitude: 51.54627, longitude: 0.02332),
                                CLLocationCoordinate2D(latitude: 51.5464, longitude: 0.02445),
                                CLLocationCoordinate2D(latitude: 51.5464, longitude: 0.02445),
                                CLLocationCoordinate2D(latitude: 51.54646, longitude: 0.02498),
                                CLLocationCoordinate2D(latitude: 51.54654, longitude: 0.0258),
                                CLLocationCoordinate2D(latitude: 51.54658, longitude: 0.02669),
                                CLLocationCoordinate2D(latitude: 51.54671, longitude: 0.02838),
                                CLLocationCoordinate2D(latitude: 51.54688, longitude: 0.03051),
                                CLLocationCoordinate2D(latitude: 51.54702, longitude: 0.03171),
                                CLLocationCoordinate2D(latitude: 51.54705, longitude: 0.03195),
                                CLLocationCoordinate2D(latitude: 51.54705, longitude: 0.03195),
                                CLLocationCoordinate2D(latitude: 51.54707, longitude: 0.03209),
                                CLLocationCoordinate2D(latitude: 51.54734, longitude: 0.03426),
                                CLLocationCoordinate2D(latitude: 51.54758, longitude: 0.03588),
                                CLLocationCoordinate2D(latitude: 51.54764, longitude: 0.0362),
                                CLLocationCoordinate2D(latitude: 51.54771, longitude: 0.03663),
                                CLLocationCoordinate2D(latitude: 51.54772, longitude: 0.03665),
                                CLLocationCoordinate2D(latitude: 51.54779, longitude: 0.03705),
                                CLLocationCoordinate2D(latitude: 51.54817, longitude: 0.0392),
                                CLLocationCoordinate2D(latitude: 51.5483, longitude: 0.03987),
                                CLLocationCoordinate2D(latitude: 51.5483, longitude: 0.03987),
                                CLLocationCoordinate2D(latitude: 51.54834, longitude: 0.04009),
                                CLLocationCoordinate2D(latitude: 51.5485, longitude: 0.04085),
                                CLLocationCoordinate2D(latitude: 51.54878, longitude: 0.04198),
                                CLLocationCoordinate2D(latitude: 51.54909, longitude: 0.04305),
                                CLLocationCoordinate2D(latitude: 51.54915, longitude: 0.04324),
                                CLLocationCoordinate2D(latitude: 51.54915, longitude: 0.04324),
                                CLLocationCoordinate2D(latitude: 51.54925, longitude: 0.04355),
                                CLLocationCoordinate2D(latitude: 51.5493, longitude: 0.04373),
                                CLLocationCoordinate2D(latitude: 51.54941, longitude: 0.04408),
                                CLLocationCoordinate2D(latitude: 51.54993, longitude: 0.04568),
                                CLLocationCoordinate2D(latitude: 51.55017, longitude: 0.04634),
                                CLLocationCoordinate2D(latitude: 51.55037, longitude: 0.04679),
                                CLLocationCoordinate2D(latitude: 51.55037, longitude: 0.04679),
                                CLLocationCoordinate2D(latitude: 51.5504, longitude: 0.04686),
                                CLLocationCoordinate2D(latitude: 51.55046, longitude: 0.04701),
                                CLLocationCoordinate2D(latitude: 51.5507, longitude: 0.04754),
                                CLLocationCoordinate2D(latitude: 51.55095, longitude: 0.04809),
                                CLLocationCoordinate2D(latitude: 51.55117, longitude: 0.04864),
                                CLLocationCoordinate2D(latitude: 51.55161, longitude: 0.04998),
                                CLLocationCoordinate2D(latitude: 51.55168, longitude: 0.05021),
                                CLLocationCoordinate2D(latitude: 51.55183, longitude: 0.05072),
                                CLLocationCoordinate2D(latitude: 51.55188, longitude: 0.05068),
                                CLLocationCoordinate2D(latitude: 51.55188, longitude: 0.05066),
                                CLLocationCoordinate2D(latitude: 51.55187, longitude: 0.05067),
                                CLLocationCoordinate2D(latitude: 51.55243, longitude: 0.05246),
                                CLLocationCoordinate2D(latitude: 51.55256, longitude: 0.05282),
                                CLLocationCoordinate2D(latitude: 51.55265, longitude: 0.05303),
                                CLLocationCoordinate2D(latitude: 51.5526, longitude: 0.05308),
                                CLLocationCoordinate2D(latitude: 51.55264, longitude: 0.05316),
                                CLLocationCoordinate2D(latitude: 51.55286, longitude: 0.05375),
                                CLLocationCoordinate2D(latitude: 51.5533, longitude: 0.05492),
                                CLLocationCoordinate2D(latitude: 51.55355, longitude: 0.05563),
                                CLLocationCoordinate2D(latitude: 51.55359, longitude: 0.05575),
                                CLLocationCoordinate2D(latitude: 51.55359, longitude: 0.05575),
                                CLLocationCoordinate2D(latitude: 51.55365, longitude: 0.05592),
                                CLLocationCoordinate2D(latitude: 51.5539, longitude: 0.05668),
                                CLLocationCoordinate2D(latitude: 51.55413, longitude: 0.05744),
                                CLLocationCoordinate2D(latitude: 51.55475, longitude: 0.05974),
                                CLLocationCoordinate2D(latitude: 51.55507, longitude: 0.06068),
                                CLLocationCoordinate2D(latitude: 51.55507, longitude: 0.06068),
                                CLLocationCoordinate2D(latitude: 51.5551, longitude: 0.06076),
                                CLLocationCoordinate2D(latitude: 51.55523, longitude: 0.06119),
                                CLLocationCoordinate2D(latitude: 51.55555, longitude: 0.06232),
                                CLLocationCoordinate2D(latitude: 51.55571, longitude: 0.06301),
                                CLLocationCoordinate2D(latitude: 51.55575, longitude: 0.06319),
                                CLLocationCoordinate2D(latitude: 51.55583, longitude: 0.06335),
                                CLLocationCoordinate2D(latitude: 51.55593, longitude: 0.06377),
                                CLLocationCoordinate2D(latitude: 51.55594, longitude: 0.06381),
                                CLLocationCoordinate2D(latitude: 51.55599, longitude: 0.064),
                                CLLocationCoordinate2D(latitude: 51.55625, longitude: 0.06487),
                                CLLocationCoordinate2D(latitude: 51.55668, longitude: 0.06579),
                                CLLocationCoordinate2D(latitude: 51.55702, longitude: 0.0664),
                                CLLocationCoordinate2D(latitude: 51.55708, longitude: 0.06659),
                                CLLocationCoordinate2D(latitude: 51.55748, longitude: 0.06737),
                                CLLocationCoordinate2D(latitude: 51.55766, longitude: 0.06773),
                                CLLocationCoordinate2D(latitude: 51.55791, longitude: 0.06845),
                                CLLocationCoordinate2D(latitude: 51.5581, longitude: 0.069),
                                CLLocationCoordinate2D(latitude: 51.5581, longitude: 0.069),
                                CLLocationCoordinate2D(latitude: 51.55816, longitude: 0.06917),
                                CLLocationCoordinate2D(latitude: 51.55833, longitude: 0.06971),
                                CLLocationCoordinate2D(latitude: 51.55832, longitude: 0.06999),
                                CLLocationCoordinate2D(latitude: 51.5583, longitude: 0.07004),
                                CLLocationCoordinate2D(latitude: 51.55826, longitude: 0.07014),
                                CLLocationCoordinate2D(latitude: 51.55768, longitude: 0.07013),
                                CLLocationCoordinate2D(latitude: 51.55768, longitude: 0.07013),
                                CLLocationCoordinate2D(latitude: 51.55763, longitude: 0.07013),
                                CLLocationCoordinate2D(latitude: 51.55744, longitude: 0.07019),
                                CLLocationCoordinate2D(latitude: 51.55734, longitude: 0.07022),
                                CLLocationCoordinate2D(latitude: 51.55715, longitude: 0.07035),
                                CLLocationCoordinate2D(latitude: 51.55691, longitude: 0.07056),
                                CLLocationCoordinate2D(latitude: 51.55675, longitude: 0.07074),
                                CLLocationCoordinate2D(latitude: 51.55659, longitude: 0.07129),
                                CLLocationCoordinate2D(latitude: 51.55662, longitude: 0.0714),
                                CLLocationCoordinate2D(latitude: 51.55661, longitude: 0.07152),
                                CLLocationCoordinate2D(latitude: 51.5566, longitude: 0.07155),
                                CLLocationCoordinate2D(latitude: 51.55668, longitude: 0.07186),
                                CLLocationCoordinate2D(latitude: 51.5572, longitude: 0.07372),
                                CLLocationCoordinate2D(latitude: 51.55764, longitude: 0.07353),
                                CLLocationCoordinate2D(latitude: 51.55774, longitude: 0.07362),
                                CLLocationCoordinate2D(latitude: 51.55813, longitude: 0.07441),
                                CLLocationCoordinate2D(latitude: 51.55813, longitude: 0.07441),
                                CLLocationCoordinate2D(latitude: 51.55818, longitude: 0.07452),
                                CLLocationCoordinate2D(latitude: 51.55824, longitude: 0.07468),
                                CLLocationCoordinate2D(latitude: 51.55828, longitude: 0.07487),
                                CLLocationCoordinate2D(latitude: 51.55841, longitude: 0.07559),
                                CLLocationCoordinate2D(latitude: 51.55844, longitude: 0.07568),
                                CLLocationCoordinate2D(latitude: 51.55857, longitude: 0.07586),
                                CLLocationCoordinate2D(latitude: 51.55866, longitude: 0.07591),
                                CLLocationCoordinate2D(latitude: 51.55868, longitude: 0.07592),
                                CLLocationCoordinate2D(latitude: 51.55873, longitude: 0.07602),
                                CLLocationCoordinate2D(latitude: 51.55893, longitude: 0.07588),
                                CLLocationCoordinate2D(latitude: 51.55937, longitude: 0.07564),
                                CLLocationCoordinate2D(latitude: 51.55942, longitude: 0.07563),
                                CLLocationCoordinate2D(latitude: 51.55946, longitude: 0.07565),
                                CLLocationCoordinate2D(latitude: 51.5595, longitude: 0.07571),
                                CLLocationCoordinate2D(latitude: 51.55954, longitude: 0.07593),
                                CLLocationCoordinate2D(latitude: 51.5596, longitude: 0.0759)
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
