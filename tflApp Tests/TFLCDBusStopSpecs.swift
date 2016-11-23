    
import Quick
import Nimble
import CoreData

@testable import London_Bus

class TFLCDBusStopSpecs: QuickSpec {
    
    override func spec() {
        var context : NSManagedObjectContext!
        var dict : [String : Any]!
        var dict2 : [String : Any]!
        
        beforeEach() {
            dict = [
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
            dict2 = [
                "$type": "Tfl.Api.Presentation.Entities.StopPoint, Tfl.Api.Presentation.Entities",
                "naptanId": "490003029W",
                "indicator": "Stop H",
                "stopLetter": "H",
                "modes": ["bus"],
                "icsCode": "1011791",
                "stopType": "NaptanPublicBusCoachTram",
                "stationNaptan": "490G00011791",

                "lineGroup": [[
                "$type": "Tfl.Api.Presentation.Entities.LineGroup, Tfl.Api.Presentation.Entities",
                "naptanIdReference": "490015185H",
                "stationAtcoCode": "490G00011791",
                "lineIdentifier": ["14", "19", "38", "n19", "n38"]
                ]],
                "lineModeGroups": [[
                "$type": "Tfl.Api.Presentation.Entities.LineModeGroup, Tfl.Api.Presentation.Entities",
                "modeName": "bus",
                "lineIdentifier": ["14", "19", "38", "n19", "n38"]
                ]],
                "status": false,
                "id": "490015185H",
                "commonName": "Trocadero / Haymarket",
                "distance": 187.88846895852569,
                "placeType": "StopPoint",
                "additionalProperties": [],
                "children": [],
                "lat": 51.510515,
                "lon": -0.134197
                ]
            let models = NSManagedObjectModel.mergedModel(from: nil)!
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: models)
            let _ = try! coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator
        }
        
        it ("should instantiate model with valid dictionary") {
            
            let model = TFLCDBusStop.busStop(with: dict, and: context)
            expect(model).notTo(beNil())
        }
        
        it ("should not instantiate model if identifier is missing") {
            var newDict = dict
            newDict!["naptanId"] = nil
            let model = TFLCDBusStop.busStop(with: newDict!, and: context)
            expect(model).to(beNil())
        }
        
        it ("should not instantiate model if stoptype is missing") {
            var newDict = dict
            newDict!["stopType"] = nil
            let model = TFLCDBusStop.busStop(with: newDict!, and: context)
            expect(model).to(beNil())
        }

        it ("should not instantiate model if stoptype is NOT NaptanPublicBusCoachTram") {
            var newDict = dict
            newDict!["stopType"] = "NaptanOnstreetBusCoachStopPair"
            let model = TFLCDBusStop.busStop(with: newDict!, and: context)
            expect(model).to(beNil())
        }

        it ("should instantiate new model if model with identifier doesn't not exist") {
            _ = TFLCDBusStop.busStop(with: dict, and: context)
            var newDict = dict
            newDict!["naptanId"] = "490G00011972"
            _ = TFLCDBusStop.busStop(with: dict!, and: context)
            _  = TFLCDBusStop.busStop(with: newDict!, and: context)
            _ = try! context.save()
            let fetchRequest = NSFetchRequest<TFLCDBusStop>(entityName:"TFLCDBusStop")
            let count = try! context.count(for: fetchRequest)
            expect(count) == 2

        }
        it ("should update existing model with updated model if there is already a model with same identifier") {
            _ = TFLCDBusStop.busStop(with: dict!, and: context)
            let model  = TFLCDBusStop.busStop(with: dict2!, and: context)
            _ = try! context.save()
            let fetchRequest = NSFetchRequest<TFLCDBusStop>(entityName:"TFLCDBusStop")
            let count = try! context.count(for: fetchRequest)
            expect(count) == 1
            expect(model!.lat) == 51.510515
            expect(model!.long) == -0.134197
            expect(model!.identifier) == "490003029W"
            expect(model!.stopLetter) == "H"
            expect(model!.towards) == "Ealing Broadway"
            expect(model!.name) == "Trocadero / Haymarket"
            expect(model!.status) == false
            
        }
        
        it ("should instantiate model correctly") {
            let model = TFLCDBusStop.busStop(with: dict, and: context)
            expect(model!.lat) == 51.538675
            expect(model!.long) == -0.279163
            expect(model!.identifier) == "490003029W"
            expect(model!.stopLetter) == "->W"
            expect(model!.towards) == "Ealing Broadway"
            expect(model!.name) == "Abbey Road"
            expect(model!.status) == true
        }
        
        it("should not have updated model if there was nothing to update") {
            _ = TFLCDBusStop.busStop(with: dict!, and: context)
            _ = try! context.save()
            _  = TFLCDBusStop.busStop(with: dict!, and: context)
            expect(context.hasChanges) == false
            
        }
    }
}
