import Foundation
import Nimble
import UIKit
import Quick
import CoreData

@testable import London_Bus

class TFLBusPredictionViewCellSpecs: QuickSpec {
    
    override func spec() {
        var cell : TFLBusStationArrivalsCell!
        var timeStampFormatter : DateFormatter!
        var distanceFormatter : LengthFormatter!
        var busStopDict : [String:Any]!
        var busPredicationModels : [TFLBusPrediction]!
        var managedObjectContext : NSManagedObjectContext!
        beforeEach {
            
            timeStampFormatter = DateFormatter()
            timeStampFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSXXXXX"
            timeStampFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            timeStampFormatter.calendar = Calendar(identifier: .iso8601)
            

            distanceFormatter = LengthFormatter()
            distanceFormatter.unitStyle = .short
            distanceFormatter.numberFormatter.roundingMode = .halfUp
            distanceFormatter.numberFormatter.maximumFractionDigits = 0
            
            let timeFormatter = DateFormatter()
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
            
            var predictions : [[String:Any]] = []
            for dict in tempPredictions  {
                var newDict = dict
                timeStampFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSXXXXX"
                newDict["timestamp"] = timeStampFormatter.string(from: Date())
                timeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSXXX"
                newDict["timeToLive"] = timeStampFormatter.string(from: Date().addingTimeInterval(TimeInterval(60)))
                
                predictions +=  [newDict]
            }

            
            let model1 = TFLBusPrediction(with:predictions[0])
            let model2 = TFLBusPrediction(with:predictions[1])
            let model3 = TFLBusPrediction(with:predictions[2])
            busPredicationModels = [model1!,model2!,model3!]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "TFLNearbyBusStationsController") as! TFLNearbyBusStationsController
            cell = controller.tableView.dequeueReusableCell(withIdentifier: String(describing: TFLBusStationArrivalsCell.self), for: IndexPath(row: 0, section: 0)) as!  TFLBusStationArrivalsCell
        }
        
        it ("should NOT be nil") {
            expect(cell).notTo(beNil())
        }
        
        it("should configure cell correctly") {
            let busStop = TFLCDBusStop.busStop(with: busStopDict, and: managedObjectContext)

            let busArrivalInfo = TFLBusStopArrivalsInfo(busStop: busStop!, busStopDistance: 300, arrivals: busPredicationModels)

            let  model =   TFLBusStopArrivalsViewModel(with: busArrivalInfo, distanceFormatter:distanceFormatter , and: timeStampFormatter)

            cell.configure(with: model)
            expect(cell.stationName.text) == "Abbey Road"
            expect(cell.stationDetails.text) == "towards Ealing Broadway"
            expect(cell.distanceLabel.text) == "300m"
            expect(cell.predictionView.predictions.count) == 3
            expect(cell.noDataErrorLabel.text) == NSLocalizedString("TFLBusStationArrivalsCell.noDataError", comment: "")
        }
        
        it("should hide noDataErrorLabel if arrivalTimes is  empty") {
            let busStop = TFLCDBusStop.busStop(with: busStopDict, and: managedObjectContext)
            let busArrivalInfo = TFLBusStopArrivalsInfo(busStop: busStop!, busStopDistance: 300, arrivals: [])
            
            let  model =   TFLBusStopArrivalsViewModel(with: busArrivalInfo, distanceFormatter:distanceFormatter , and: timeStampFormatter)
            
            cell.configure(with: model)
            expect(cell.noDataErrorLabel.isHidden) == false
        }
        
        it("should hide noDataErrorLabel if arrivalTimes is empty") {
            let busStop = TFLCDBusStop.busStop(with: busStopDict, and: managedObjectContext)
            
            let busArrivalInfo = TFLBusStopArrivalsInfo(busStop: busStop!, busStopDistance: 300, arrivals: busPredicationModels)
            
            let  model =   TFLBusStopArrivalsViewModel(with: busArrivalInfo, distanceFormatter:distanceFormatter , and: timeStampFormatter)
            
            cell.configure(with: model)
            expect(cell.noDataErrorLabel.isHidden) == true
        }

    }
}
