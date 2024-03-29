import Foundation
import Nimble
import UIKit
import Quick
import CoreData
import MapKit

@testable import BusStops

fileprivate class CollectionViewDataSource : NSObject,UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return  UICollectionViewCell()
    }

}

fileprivate class TestAnimatedLabel : TFLAnimatedLabel {
    var textSet = false
    
    override func setText(_ newText: String?, animated: Bool) {
        textSet = true
        super.setText(newText, animated: animated)
    }
    
}

class TFLBusPredictionViewCellSpecs: QuickSpec {
   
    override func spec() {
        var cell : TFLBusPredictionViewCell!
        var timeStampFormatter : DateFormatter!
        var distanceFormatter : LengthFormatter!
        var busStopDict : [String:Any]!
        var busPredicationModels : [TFLBusPrediction]!
        var managedObjectContext : NSManagedObjectContext!
        var timeFormatter :  DateFormatter!
        var referenceDate : Date!
        var decoder : JSONDecoder!
        var location : CLLocation!
        beforeEach {
            location = CLLocation(latitude: 51.514028153209, longitude: -0.15301535236356)
            timeStampFormatter = DateFormatter()
            timeStampFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            timeStampFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            timeStampFormatter.calendar = Calendar(identifier: .iso8601)
            

            distanceFormatter = LengthFormatter()
            distanceFormatter.unitStyle = .short
            distanceFormatter.numberFormatter.roundingMode = .halfUp
            distanceFormatter.numberFormatter.maximumFractionDigits = 0
            
            timeFormatter = DateFormatter()
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
                "lat": 51.538675,
                "lon": -0.279163
            ]
            
            let models = NSManagedObjectModel.mergedModel(from: nil)!
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: models)
            let _ = try! coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            
            let dict1 : [String:Any] =
                ["id": "1836802865",
                 "vehicleId": "LTZ1218",
                 "towards": "",
                 "naptanId": "490011791K",
                 "lineId": "38",
                 "lineName": "38",
                 "destinationName": "Victoria",
                 "timestamp": "2016-11-16T15:59:35.1741351Z",
                 "timeToStation": UInt(902),
                 "timeToLive": "2016-11-16T16:15:07Z"]
            let dict2 : [String:Any] =
                ["id": "1836802866",
                 "vehicleId": "LTZ1218",
                 "towards": "",
                 "naptanId": "490011791K",
                 "lineId": "39",
                 "lineName": "39",
                 "destinationName": "Victoria",
                 "timestamp": "2016-11-16T15:59:35.1741351Z",
                 "timeToStation": UInt(60),
                 "timeToLive": "2016-11-16T16:15:07Z"]
            let dict3 : [String:Any] =
                ["id": "1836802867",
                 "vehicleId": "LTZ1218",
                 "towards": "",
                 "naptanId": "490011791K",
                 "lineId": "40",
                 "lineName": "40",
                 "destinationName": "Victoria",
                 "timestamp": "2016-11-16T15:59:35.1741351Z",
                 "timeToStation": UInt(1902),
                 "timeToLive": "2016-11-16T16:15:07Z"]
            let dict4 : [String:Any] =
                ["id": "1836802868",
                 "vehicleId": "LTZ1218",
                 "towards": "",
                 "naptanId": "490011791K",
                 "lineId": "40",
                 "lineName": "40",
                 "destinationName": "Victoria",
                 "timestamp": "2016-11-16T15:59:35.1741351Z",
                 "timeToStation": UInt(902)]
            
            let tempPredictions = [dict1,dict2,dict3,dict4]
            referenceDate  = timeFormatter.date(from: "2016-11-16T16:15:01Z")

            var predictions : [[String:Any]] = []
            for dict in tempPredictions  {
                var newDict = dict
                newDict["timestamp"] = DateFormatter.iso8601Full.string(from: referenceDate)
                timeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                newDict["timeToLive"] = timeStampFormatter.string(from: referenceDate.addingTimeInterval(TimeInterval(1500)))
                
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
            let busStationArrivalCell = controller.tableView.dequeueReusableCell(withIdentifier: String(describing: TFLBusStationArrivalsCell.self), for: IndexPath(row: 0, section: 0)) as!  TFLBusStationArrivalsCell
            let collectionView = busStationArrivalCell.predictionView
            let dataSource = CollectionViewDataSource()
            collectionView?.dataSource = dataSource
            cell = collectionView!.dequeueReusableCell(withReuseIdentifier: String(describing: TFLBusPredictionViewCell.self), for: IndexPath(item:0, section:0)) as? TFLBusPredictionViewCell
        }
        
        it ("should NOT be nil") {
            expect(cell).notTo(beNil())
        }
        
        it("should configure cell correctly (test1)") {
            var completionBlockCalled = false
            TFLCDBusStop.busStop(with: busStopDict, and: managedObjectContext) { busStop in
                let busArrivalInfo = TFLBusStopArrivalsInfo(busStop: busStop!, location: location, arrivals: busPredicationModels)
                
                
                let  model =   TFLBusStopArrivalsViewModel(with: busArrivalInfo,using: referenceDate.addingTimeInterval(10))
                
                cell.configure(with: model.arrivalTimes.first!, using: { })
                expect(cell.line.text) == "39"
                expect(cell.arrivalTime.text) == "1 min"
                completionBlockCalled = true
            }
            expect(completionBlockCalled).toEventually(beTrue(),timeout:20)
        }
        it("should configure cell correctly (test2)") {
            var completionBlockCalled = false
            TFLCDBusStop.busStop(with: busStopDict, and: managedObjectContext) { busStop in
                
                let busArrivalInfo = TFLBusStopArrivalsInfo(busStop: busStop!, location: location, arrivals: busPredicationModels)
                
                let  model =   TFLBusStopArrivalsViewModel(with: busArrivalInfo,using: referenceDate.addingTimeInterval(120))
                
                cell.configure(with: model.arrivalTimes.last!, using: { })
                expect(cell.line.text) == "40"
                expect(cell.arrivalTime.text) == "29 mins"
                 completionBlockCalled = true
            }
            expect(completionBlockCalled).toEventually(beTrue(),timeout:20)
        }
        
        it("should set arrivaltime if its not an update") {
            let testLabel = TestAnimatedLabel()
            cell.arrivalTime = testLabel
            
            var completionBlockCalled = false
            TFLCDBusStop.busStop(with: busStopDict, and: managedObjectContext) { busStop in
                
                
                let busArrivalInfo = TFLBusStopArrivalsInfo(busStop: busStop!,location: location, arrivals: busPredicationModels)
                
                let  model =   TFLBusStopArrivalsViewModel(with: busArrivalInfo,using: referenceDate.addingTimeInterval(120))
                
                cell.configure(with: model.arrivalTimes.last!,as: false, using: { })
                expect(testLabel.textSet) == true
                 completionBlockCalled = true
            }
            expect(completionBlockCalled).toEventually(beTrue(),timeout:20)
        }
        
        it("should NOT set arrivaltime if its not an update and nothing's changed") {
            let testLabel = TestAnimatedLabel()
            cell.arrivalTime = testLabel
            
            var completionBlockCalled = false
            TFLCDBusStop.busStop(with: busStopDict, and: managedObjectContext) { busStop in
                
                let busArrivalInfo = TFLBusStopArrivalsInfo(busStop: busStop!, location: location, arrivals: busPredicationModels)
                
                let  model =   TFLBusStopArrivalsViewModel(with: busArrivalInfo,using: referenceDate.addingTimeInterval(120))
                
                cell.configure(with: model.arrivalTimes.last!,as: false, using: { })
                testLabel.textSet = false
                cell.configure(with: model.arrivalTimes.last!,as: true, using: { })
                expect(testLabel.textSet) == false
                 completionBlockCalled = true
            }
            expect(completionBlockCalled).toEventually(beTrue(),timeout:20)
        }

        it("should set arrivaltime if its an update but arrivaltime changed") {
            let testLabel = TestAnimatedLabel()
            cell.arrivalTime = testLabel
            
            var completionBlockCalled = false
            TFLCDBusStop.busStop(with: busStopDict, and: managedObjectContext) { busStop in
                let busArrivalInfo = TFLBusStopArrivalsInfo(busStop: busStop!, location: location, arrivals: busPredicationModels)
                
                let  model =   TFLBusStopArrivalsViewModel(with: busArrivalInfo,using: referenceDate.addingTimeInterval(120))
                
                cell.configure(with: model.arrivalTimes.last!,as: false, using: { })
                testLabel.textSet = false
                let  model2 =   TFLBusStopArrivalsViewModel(with: busArrivalInfo,using: referenceDate.addingTimeInterval(180))
                cell.configure(with: model2.arrivalTimes.last!,as: true, using: { })
                expect(testLabel.textSet) == true
                completionBlockCalled = true
            }
            expect(completionBlockCalled).toEventually(beTrue(),timeout:20)
        }
        

        
        it("should have only one global background image") {
           expect(TFLBusPredictionViewCell.busPredictionViewBackgroundImage) === TFLBusPredictionViewCell.busPredictionViewBackgroundImage
        }

    }
}
