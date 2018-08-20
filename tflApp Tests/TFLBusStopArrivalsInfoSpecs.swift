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
                var busPrediction1 : TFLBusPrediction!
                var busPrediction2 : TFLBusPrediction!
                var coord : CLLocationCoordinate2D!
                
                var busStationInfo : TFLBusStopArrivalsInfo.TFLContextFreeBusStopInfo!
                var location :  CLLocation!
                var info : TFLBusStopArrivalsInfo!
                beforeEach() {
                    busPrediction1 = TFLBusPrediction(identifier: "identifier1", timeToLive: Date(timeIntervalSinceNow: 50), timeStamp: Date(), busStopIdentifier: "busstop1", lineIdentifier: "line1", lineName: "lineName", destination: "destination", timeToStation: 40)
                    busPrediction2 = TFLBusPrediction(identifier: "identifier2", timeToLive: Date(timeIntervalSinceNow: 50), timeStamp: Date(), busStopIdentifier: "busstop2", lineIdentifier: "line2", lineName: "lineName2", destination: "destination2", timeToStation: 80)
                    coord = CLLocationCoordinate2D(latitude: 0.5, longitude: 0.5)
                    
                    busStationInfo = TFLBusStopArrivalsInfo.TFLContextFreeBusStopInfo(identifier: "id", stopLetter: "ST", towards: "destination", name: "name", coord: coord)
                    location =  CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                    info = TFLBusStopArrivalsInfo(busStop:busStationInfo , location: location, arrivals: [busPrediction1,busPrediction2])
                }
                
                it ("should encode TFLBusStopArrivalsInfo correctly") {
                   
                    let data = try! JSONEncoder().encode(info)
                    expect(data).notTo(beNil())
                }
                
                it ("should decode TFLBusStopArrivalsInfo correctly") {
                    
                    let data = try! JSONEncoder().encode(info)
                    let info2 = try! JSONDecoder().decode(TFLBusStopArrivalsInfo.self, from: data)
                    expect(info2).notTo(beNil())
                    let pred1 = info2.arrivals[0]
                    let pred2 = info2.arrivals[1]
                    expect(pred1.identifier) == busPrediction1.identifier
                    expect(pred2.identifier) == busPrediction2.identifier
                    
                    expect(pred1.timeToLive) == busPrediction1.timeToLive
                    expect(pred2.timeToLive) == busPrediction2.timeToLive
                    
                    expect(pred1.timeStamp) == busPrediction1.timeStamp
                    expect(pred2.timeStamp) == busPrediction2.timeStamp
                    
                    expect(pred1.busStopIdentifier) == busPrediction1.busStopIdentifier
                    expect(pred2.busStopIdentifier) == busPrediction2.busStopIdentifier
                    
                    expect(pred1.lineIdentifier) == busPrediction1.lineIdentifier
                    expect(pred2.lineIdentifier) == busPrediction2.lineIdentifier
                    
                    expect(pred1.lineName) == busPrediction1.lineName
                    expect(pred2.lineName) == busPrediction2.lineName
                    
                    expect(pred1.destination) == busPrediction1.destination
                    expect(pred2.destination) == busPrediction2.destination
                    
                    expect(pred1.timeToStation) == busPrediction1.timeToStation
                    expect(pred2.timeToStation) == busPrediction2.timeToStation
                    
                    expect(info2.busStop.coord.latitude) == info.busStop.coord.latitude
                    expect(info2.busStop.coord.longitude) == info.busStop.coord.longitude
                    expect(info2.busStop.identifier) == info.busStop.identifier
                    expect(info2.busStop.stopLetter) == info.busStop.stopLetter
                    expect(info2.busStop.towards) == info.busStop.towards
                    expect(info2.busStop.name) == info.busStop.name
                    
                    expect(info2.busStopDistance) == info.busStopDistance
                   

                }
               
            }
        }
    }
}
