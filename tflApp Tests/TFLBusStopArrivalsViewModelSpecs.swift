import Foundation
import Nimble
import UIKit
import Quick
import CoreData

@testable import London_Bus

class TFLBusStopArrivalsViewModelSpecs: QuickSpec {
    
    override func spec() {
        var distanceFormatter : LengthFormatter!
        var timeFormatter : DateFormatter!
        var managedObjectContext : NSManagedObjectContext!
        var busStopDict : [String : Any]!
        var busPredictions : [[String:Any]]!
        var busArrivalInfo : TFLBusStopArrivalsInfo!
        beforeEach {
           
            distanceFormatter = LengthFormatter()
            distanceFormatter.unitStyle = .short
            distanceFormatter.numberFormatter.roundingMode = .halfUp
            distanceFormatter.numberFormatter.maximumFractionDigits = 0
            
            timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            timeFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            timeFormatter.calendar = Calendar(identifier: .iso8601)
            
            busStopDict = [
                "$type": "Tfl.Api.Presentation.Entities.StopPoint, Tfl.Api.Presentation.Entities",
                "naptanId": "490003029W",
                "indicator": "->W",
                "stopLetter": "->W",
                "modes": ["bus"],
                "icsCode": "1003029",
                "stopType": "NaptanPublicBusCoachTram",
                "stationNaptan": "490G00003029",
                "status": true,
                "id": "490003029W",
                "commonName": "Abbey Road",
                "placeType": "StopPoint",
                "additionalProperties": [[
                    "$type": "Tfl.Api.Presentation.Entities.AdditionalProperties, Tfl.Api.Presentation.Entities",
                    "category": "Direction",
                    "key": "CompassPoint",
                    "sourceSystemKey": "Naptan490",
                    "value": "W"
                    ], [
                        "$type": "Tfl.Api.Presentation.Entities.AdditionalProperties, Tfl.Api.Presentation.Entities",
                        "category": "Direction",
                        "key": "Towards",
                        "sourceSystemKey": "CountDown",
                        "value": "Ealing Broadway"
                    ]],
                "children": [],
                "lat": 51.538675,
                "lon": -0.279163
            ]
            
            let models = NSManagedObjectModel.mergedModel(from: nil)!
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: models)
            let _ = try! coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            let busStopModel = TFLCDBusStop.busStop(with: busStopDict, and: managedObjectContext)
            
            let tempPredictions = [
                ["id": "1836802865",
                "vehicleId": "LTZ1218",
                "naptanId": "490011791K",
                "lineId": "38",
                "lineName": "38",
                "destinationName": "Victoria",
                "timestamp": "2016-11-16T15:59:35Z",
                "timeToStation": UInt(902),
                "timeToLive": "2016-11-16T16:15:07.51239Z"],
                ["id": "1836802866",
                 "vehicleId": "LTZ1218",
                 "naptanId": "490011791K",
                 "lineId": "39",
                 "lineName": "39",
                 "destinationName": "Victoria",
                 "timestamp": "2016-11-16T15:59:35Z",
                 "timeToStation": UInt(60),
                 "timeToLive": "2016-11-16T16:15:07.51239Z"],
                ["id": "1836802867",
                 "vehicleId": "LTZ1218",
                 "naptanId": "490011791K",
                 "lineId": "40",
                 "lineName": "40",
                 "destinationName": "Victoria",
                 "timestamp": "2016-11-16T15:59:35Z",
                 "timeToStation": UInt(1902),
                 "timeToLive": "2016-11-16T16:15:07.51239Z"],
                ["id": "1836802868",
                 "vehicleId": "LTZ1218",
                 "naptanId": "490011791K",
                 "lineId": "40",
                 "lineName": "40",
                 "destinationName": "Victoria",
                 "timestamp": "2016-11-16T15:59:35Z",
                 "timeToStation": UInt(902)]
            ]
            let timeStampFormatter = DateFormatter()
            timeStampFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSXXXXX"
            timeStampFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            timeStampFormatter.calendar = Calendar(identifier: .iso8601)
            var predictions : [[String:Any]] = []
            for dict in tempPredictions  {
                var newDict = dict
                timeStampFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSXXXXX"
                newDict["timestamp"] = timeStampFormatter.string(from: Date())
                timeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSXXX"
                newDict["timeToLive"] = timeStampFormatter.string(from: Date().addingTimeInterval(TimeInterval(60)))

                predictions +=  [newDict]
            }
            busPredictions =  predictions
            
            let model1 = TFLBusPrediction(with:busPredictions[0])
            let model2 = TFLBusPrediction(with:busPredictions[1])
            let model3 = TFLBusPrediction(with:busPredictions[2])
            busArrivalInfo = TFLBusStopArrivalsInfo(busStop: busStopModel!, busStopDistance: 300, arrivals: [model1!,model2!,model3!])
        }
        
        context("when testing TFLBusStopArrivalsViewModel") {
            it ("should not be nil") {
               let model = TFLBusStopArrivalsViewModel(with: busArrivalInfo)
                expect(model).notTo(beNil())
            }
            
            it ("should setup model correctly") {
                let model = TFLBusStopArrivalsViewModel(with: busArrivalInfo)
                expect(model.identifier) == "490003029W"
                expect(model.stationName) == "Abbey Road"
                expect(model.stationDetails) == "towards Ealing Broadway"
                expect(model.distance) == "300m"
            }
            
            it ("models should be the same if identifier are the same") {
                let model = TFLBusStopArrivalsViewModel(with: busArrivalInfo)
                let busStopDict =  ["naptanId": "490003029W","stopType": "NaptanPublicBusCoachTram"]
                let busStopModel = TFLCDBusStop.busStop(with: busStopDict, and: managedObjectContext)
                let busArrivalInfo = TFLBusStopArrivalsInfo(busStop: busStopModel!, busStopDistance: 0, arrivals: [])
                let model2 = TFLBusStopArrivalsViewModel(with: busArrivalInfo)
                expect(model) == model2
            }
            
            it ("should filter expired bus predictions") {
                let model = TFLBusStopArrivalsViewModel(with: busArrivalInfo)
                expect(model.arrivalTimes.count) == 3

            }
            
            it ("should sort bus predictions in increasing order") {
                let model = TFLBusStopArrivalsViewModel(with: busArrivalInfo)
                let (pred1,pred2,pred3) = (model.arrivalTimes[0],model.arrivalTimes[1],model.arrivalTimes[2])
                expect(TFLBusStopArrivalsViewModel.LinePredictionViewModel.compare(lhs: pred1, rhs: pred2)) == true
                expect(TFLBusStopArrivalsViewModel.LinePredictionViewModel.compare(lhs: pred2, rhs: pred3)) == true
            }
            

            
        }
        
        context("when testing TFLBusStopArrivalsViewModel.LinePredictionViewModel") {
            it ("should not be nil") {
                let prediction = TFLBusPrediction(with: busPredictions.first!)
                let model = TFLBusStopArrivalsViewModel.LinePredictionViewModel(with: prediction!,using: 0)
                expect(model).notTo(beNil())
            }
            
            it ("should setup model correctly (1st model)") {
                let prediction = TFLBusPrediction(with: busPredictions.first!)
                let model = TFLBusStopArrivalsViewModel.LinePredictionViewModel(with: prediction!,using: 0)!
                expect(model.line) == "38"
                expect(model.eta) == "15 mins"
                expect(model.identifier) == "1836802865"
                expect(model.timeToStation) == 902
            }
            
            it ("should setup model correctly (2nd model)") {
                let prediction = TFLBusPrediction(with: busPredictions.last!)
                let model = TFLBusStopArrivalsViewModel.LinePredictionViewModel(with: prediction!,using: 0)!
                expect(model.line) == "40"
                expect(model.eta) == "15 mins"
                expect(model.identifier) == "1836802868"
                expect(model.timeToStation) == 902
            }
            
            it("should set time to 'due' if less than 30 secs") {
                var dict = busPredictions.first!
                dict["timeToStation"] = UInt(29)
                let prediction = TFLBusPrediction(with: dict)
                let model = TFLBusStopArrivalsViewModel.LinePredictionViewModel(with: prediction!,using: 0)!
                expect(model.eta) == "due"
            }
            
            it("should set time to '1 min' if less than 90 secs") {
                var dict = busPredictions.first!
                dict["timeToStation"] = UInt(60)
                let prediction = TFLBusPrediction(with: dict)
                let model = TFLBusStopArrivalsViewModel.LinePredictionViewModel(with: prediction!,using: 0)!
                expect(model.eta) == "1 min"
            }
            
            it("should set time to '5 min' if less than 301 secs") {
                var dict = busPredictions.first!
                dict["timeToStation"] = UInt(300)
                let prediction = TFLBusPrediction(with: dict)
                let model = TFLBusStopArrivalsViewModel.LinePredictionViewModel(with: prediction!,using: 0)!
                expect(model.eta) == "5 mins"
            }
            
            it ("models should be the same if identifier are the same") {
                var dict1 = busPredictions.first!
                var dict2 = busPredictions.last!
                dict1["id"] = "1"
                dict2["id"] = "1"
                let prediction1 = TFLBusPrediction(with: dict1)
                let prediction2 = TFLBusPrediction(with: dict2)
                let model1 = TFLBusStopArrivalsViewModel.LinePredictionViewModel(with: prediction1!,using: 0)
                let model2 = TFLBusStopArrivalsViewModel.LinePredictionViewModel(with: prediction2!,using: 0)
                expect(model1) == model2
            }
            
            it ("should handle predictions with invalid ttl gracefully") {
                var dict = busPredictions.first!
                dict["timeToLive"] = nil
                let prediction = TFLBusPrediction(with: dict)
                expect({
                    let model = TFLBusStopArrivalsViewModel.LinePredictionViewModel(with: prediction!,using: 0)!
                    expect(model).to(beNil())
                }).notTo(raiseException())
            }
            
        }
    }
}
