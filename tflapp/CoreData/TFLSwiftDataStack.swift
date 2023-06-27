import Foundation
import SwiftData


class SwiftDataStack {
    static let shared = SwiftDataStack()
    let container : ModelContainer
    let types = [TFLBusStation.self]
    init() {
        do {
            let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent("stops.store")
            print(storeURL)
            let config = ModelConfiguration(schema: Schema(types),url:storeURL)
            let container =  try ModelContainer(for: types, config)
            self.container = container
        }
        catch let error {
            fatalError("Unable to initialise ModelContainer:\(error)")
        }
        
    }
}
