import Foundation
import SwiftData


class SwiftDataStack {
    enum Errors : Error {
        case initialisation
    }
    
    private static let dbFileName = "stops.store"
    private static let groupID =  "group.tflwidgetSharingData"

    let container : ModelContainer
    let types = [TFLBusStation.self]
    init() throws {
        let copyDB : () -> Void = {
            guard let toURL = Self.destinationURL,let fromURL = Self.sourceURL  else {
                return
            }
            
            if !FileManager.default.fileExists(atPath: toURL.path) {
                _ = try? FileManager.default.copyItem(at: fromURL, to: toURL)
            }
           
        }
        do {
            copyDB()
            guard let storeURL = Self.destinationURL else {
                throw Errors.initialisation
            }
            let config = ModelConfiguration(schema: Schema(types),url:storeURL)
            let container =  try ModelContainer(for: types, config)
            self.container = container
        }
        catch let error {
            fatalError("Unable to initialise ModelContainer:\(error)")
        }
        
    }
    
    static var destinationURL : URL? {
        guard let url = URL(string: Self.dbFileName) else {
            return nil
        }
        let dbFullFileName = url.path
                
        guard let destinationURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)?.appendingPathComponent(dbFullFileName) else {
            return nil
        }
        return destinationURL
    }
    
    static var sourceURL : URL? {
        guard let url = URL(string: Self.dbFileName) else {
            return nil
        }
        let path = url.deletingPathExtension().path
        let ext = url.pathExtension
        guard let sourceURL = Bundle.main.url(forResource: path, withExtension: ext) else {
                return nil
        }
        return sourceURL
    }
    
    
}
