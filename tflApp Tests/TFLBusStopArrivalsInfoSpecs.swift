import Foundation
import Nimble
import UIKit
import Quick
import CoreData
import MapKit

@testable import London_Bus


class TFLBusStopArrivalsInfoSpecs: QuickSpec {
    
    override func spec() {
        
        beforeEach {
            
        }
        context("when dealing with TFLContextFreeBusStopInfo") {
            describe("and codable protocol") {
                it ("should encode TFLContextFreeBusStopInfo correctly") {
                    let coord = CLLocationCoordinate2D(latitude: 0.5, longitude: 0.5)
                    let info = TFLBusStopArrivalsInfo.TFLContextFreeBusStopInfo(identifier: "id1", stopLetter: "stop1", towards: "towards1", name: "name1", coord:coord)
                    let data = try! JSONEncoder().encode(info)
                    let info2 = try! JSONDecoder().decode(TFLBusStopArrivalsInfo.TFLContextFreeBusStopInfo.self, from: data)
                    expect(info2.identifier) == "id1"
                    expect(info2.stopLetter) == "stop1"
                    expect(info2.towards) == "towards1"
                    expect(info2.name) == "name1"
                    expect(info2.coord.latitude) == coord.latitude
                    expect(info2.coord.longitude) == coord.longitude
                }
                it ("should handle optional towards correctly") {
                    let coord = CLLocationCoordinate2D(latitude: 0.5, longitude: 0.5)
                    let info = TFLBusStopArrivalsInfo.TFLContextFreeBusStopInfo(identifier: "id1", stopLetter: "stop1", towards: nil, name: "name1", coord:coord)
                    let data = try! JSONEncoder().encode(info)
                    let info2 = try! JSONDecoder().decode(TFLBusStopArrivalsInfo.TFLContextFreeBusStopInfo.self, from: data)
                    expect(info2.identifier) == "id1"
                    expect(info2.stopLetter) == "stop1"
                    expect(info2.towards).to(beNil())
                    expect(info2.name) == "name1"
                    expect(info2.coord.latitude) == coord.latitude
                    expect(info2.coord.longitude) == coord.longitude
                }
                it ("should handle optional stopLetter correctly") {
                    let coord = CLLocationCoordinate2D(latitude: 0.5, longitude: 0.5)
                    let info = TFLBusStopArrivalsInfo.TFLContextFreeBusStopInfo(identifier: "id1", stopLetter: nil, towards: nil, name: "name1", coord:coord)
                    let data = try! JSONEncoder().encode(info)
                    let info2 = try! JSONDecoder().decode(TFLBusStopArrivalsInfo.TFLContextFreeBusStopInfo.self, from: data)
                    expect(info2.identifier) == "id1"
                    expect(info2.stopLetter).to(beNil())
                    expect(info2.towards).to(beNil())
                    expect(info2.name) == "name1"
                    expect(info2.coord.latitude) == coord.latitude
                    expect(info2.coord.longitude) == coord.longitude
                }
            }
        }
        
        
        context("when dealing with TFLBusStopArrivalsInfo") {
            describe("and codable protocol") {
                pending ("should encode TFLBusStopArrivalsInfo correctly") {
                    
                }
               
            }
        }
    }
}
