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
            
            busPredictions = [
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
                 "timeToStation": UInt(902),
                 "timeToLive": "2016-11-16T16:15:07.51239Z"],
                ["id": "1836802867",
                 "vehicleId": "LTZ1218",
                 "naptanId": "490011791K",
                 "lineId": "40",
                 "lineName": "40",
                 "destinationName": "Victoria",
                 "timestamp": "2016-11-16T15:59:35Z",
                 "timeToStation": UInt(902),
                 "timeToLive": "2016-11-16T16:15:07.51239Z"]
            ]
            let model1 = TFLBusPrediction(with:busPredictions[0])
            let model2 = TFLBusPrediction(with:busPredictions[1])
            let model3 = TFLBusPrediction(with:busPredictions[2])
            busArrivalInfo = TFLBusStopArrivalsInfo(busStop: busStopModel!, busStopDistance: 300, arrivals: [model1!,model2!,model3!])
        }
        
        context("when testing TFLBusStopArrivalsViewModel") {
            fit ("should not be nil") {
               let model = TFLBusStopArrivalsViewModel(with: busArrivalInfo, distanceFormatter: distanceFormatter, and: timeFormatter)
                expect(model).notTo(beNil())
            }
            
            pending ("should setup model correctly") {
                
            }
            
            pending ("models should be the same if identifier are the same") {
                
            }
            
            pending ("should filter expired bus predictions") {
                
            }
            
            pending ("should sort bus predictions in increasing order") {
                
            }
            

            
        }
        
        context("when testing TFLBusStopArrivalsViewModel.LinePredictionViewModel") {
            pending ("should not be nil") {
                
            }
            
            pending ("should setup model correctly") {
                
            }
            
            pending("should set time to 'due' if less than 30 secs") {
                
            }
            
            pending("should set time to '1 min' if less than 90 secs") {
                
            }
            
            pending("should set time to '5 min' if less than 305 secs") {
                
            }
            
            pending ("should setup bus predictions correctly") {
                
            }
            
            pending ("models should be the same if identifier are the same") {
                
            }
            
        }
    }
}
