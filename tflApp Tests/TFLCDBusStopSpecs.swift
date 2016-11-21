
import Quick
import Nimble
import CoreData

@testable import London_Bus

class TFLCDBusStopSpecs: QuickSpec {
    
    override func spec() {
        var context : NSManagedObjectContext!
        var dict : [String : Any]!
        
        beforeEach() {
            dict = [
                "$type": "Tfl.Api.Presentation.Entities.StopPoint, Tfl.Api.Presentation.Entities",
                "naptanId": "490G00011970",
                "modes": ["bus"],
                "icsCode": "1011970",
                "stopType": "NaptanPublicBusCoachTram",
                "stationNaptan": "490G00011970",
                "status": true,
                "id": "490G00011970",
                "commonName": "Second Avenue",
                "distance": 169.84508366433093,
                "placeType": "StopPoint",
                "additionalProperties": [],
                "lat": 51.506856,
                "lon": -0.248559
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

        pending ("should instantiate new model if model with identifier doesn't not exist") {
            
        }
        
        pending("should update existing model if there is already a model with same identifier") {
            
        }
        
        pending ("should instantiate model correctly") {
        }
        
        pending("should not have updated model if there was nothing to update") {
            
        }
    }
}
