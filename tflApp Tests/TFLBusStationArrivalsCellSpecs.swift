import Foundation
import Nimble
import UIKit
import Quick
import CoreData
import MapKit
@testable import BusStops


extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

class TFLBusStationArrivalsCellSpecs: QuickSpec {
   
    
    override func spec() {
        var cell : TFLBusStationArrivalsCell!
        var timeStampFormatter : DateFormatter!
        var distanceFormatter : LengthFormatter!
        var busStopDict : [String:Any]!
        var busPredicationModels : [TFLBusPrediction]!
        var managedObjectContext : NSManagedObjectContext!
        var referenceDate : Date!
        var decoder : JSONDecoder!
        var location : CLLocation!
        beforeEach {
            location = CLLocation(latitude: 51.514028, longitude: -0.1530)
            
            timeStampFormatter = DateFormatter()
            timeStampFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            timeStampFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            timeStampFormatter.calendar = Calendar(identifier: .iso8601)
            

            distanceFormatter = LengthFormatter()
            distanceFormatter.unitStyle = .short
            distanceFormatter.numberFormatter.roundingMode = .halfUp
            distanceFormatter.numberFormatter.maximumFractionDigits = 0
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
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
                "lat": 51.5386,
                "lon": -0.2791
            ]
            
            let models = NSManagedObjectModel.mergedModel(from: nil)!
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: models)
            let _ = try! coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            
            let dict1 : [String:Any] =
                ["id": "1836802865",
                 "vehicleId": "LTZ1218",
                 "naptanId": "490011791K",
                 "lineId": "38",
                 "lineName": "38",
                 "destinationName": "Victoria",
                 "timestamp": "2016-11-16T15:59:35.1741351Z",
                 "timeToStation": UInt(902),
                 "timeToLive": "2016-11-16T16:15:07Z",
                 "towards": ""]
            let dict2 : [String:Any] =
                ["id": "1836802866",
                 "vehicleId": "LTZ1218",
                 "naptanId": "490011791K",
                 "lineId": "39",
                 "lineName": "39",
                 "destinationName": "Victoria",
                 "timestamp": "2016-11-16T15:59:35.1741351Z",
                 "timeToStation": UInt(60),
                 "timeToLive": "2016-11-16T16:15:07Z",
                 "towards": ""]
            let dict3 : [String:Any] =
                ["id": "1836802867",
                 "vehicleId": "LTZ1218",
                 "naptanId": "490011791K",
                 "lineId": "40",
                 "lineName": "40",
                 "destinationName": "Victoria",
                 "timestamp": "2016-11-16T15:59:35.1741351Z",
                 "timeToStation": UInt(1902),
                 "timeToLive": "2016-11-16T16:15:07Z",
                 "towards": ""]
            let dict4 : [String:Any] =
                ["id": "1836802868",
                 "vehicleId": "LTZ1218",
                 "naptanId": "490011791K",
                 "lineId": "40",
                 "lineName": "40",
                 "destinationName": "Victoria",
                 "timestamp": "2016-11-16T15:59:35.1741351Z",
                 "timeToStation": UInt(902),
                 "timeToLive": "2016-11-16T16:15:07Z",
                 "towards": ""]
            let tempPredictions = [dict1,dict2,dict3,dict4]
            referenceDate  = timeFormatter.date(from: "2016-11-16T16:15:01Z")
            
            var predictions : [[String:Any]] = []
            for dict in tempPredictions  {
                var newDict = dict
                newDict["timestamp"] = DateFormatter.iso8601Full.string(from: referenceDate)
                timeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                newDict["timeToLive"] = timeStampFormatter.string(from: Date().addingTimeInterval(TimeInterval(60)))
                
                predictions +=  [newDict]
            }
            
            let data1 = try! JSONSerialization.data(withJSONObject: predictions[0], options: [])
            let data2 = try! JSONSerialization.data(withJSONObject: predictions[1], options: [])
            let data3 = try! JSONSerialization.data(withJSONObject: predictions[2], options: [])

            decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let model1 = try! decoder.decode(TFLBusPrediction.self,from: data1)
            let model2 = try! decoder.decode(TFLBusPrediction.self,from: data2)
            let model3 = try! decoder.decode(TFLBusPrediction.self,from: data3)
            busPredicationModels = [model1,model2,model3]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "TFLNearbyBusStationsController") as! TFLNearbyBusStationsController
            _ = controller.view
            cell = (controller.tableView.dequeueReusableCell(withIdentifier: String(describing: TFLBusStationArrivalsCell.self), for: IndexPath(row: 0, section: 0)) as!  TFLBusStationArrivalsCell)
        }
        
        it ("should NOT be nil") {
            expect(cell).notTo(beNil())
        }
        
        it("should configure cell correctly") {
            var completionBlockCalled = false
            TFLCDBusStop.busStop(with: busStopDict, and: managedObjectContext) { busStop in
                let busArrivalInfo = TFLBusStopArrivalsInfo(busStop: busStop!, location: location, arrivals: busPredicationModels)
                let  model =   TFLBusStopArrivalsViewModel(with: busArrivalInfo)
                
                cell.configure(with: model)
                expect(cell.stationName.text) == "Abbey Road"
                expect(cell.stationDetails.text) == "towards Ealing Broadway"
                completionBlockCalled = true
            }
            expect(completionBlockCalled).toEventually(beTrue(),timeout:20)
            expect(cell.predictionView.predictions.count).toEventually(equal(3),timeout: 5)
        }
    }
}
