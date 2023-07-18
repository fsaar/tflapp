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
        guard let toURL = Self.destinationURL,let fromURL = Self.sourceURL  else {
            throw Errors.initialisation
        }
       
        if !FileManager.default.fileExists(atPath: toURL.path) {
            _ = try? FileManager.default.copyItem(at: fromURL, to: toURL)
        }
        
        let config = ModelConfiguration(schema: Schema(types),url:toURL)
        let container =  try ModelContainer(for: types, config)
        self.container = container
        
    }
    
    static var destinationURL : URL? {
        guard let destinationURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)?.appendingPathComponent(Self.dbFileName) else {
            return nil
        }
        return destinationURL
    }
    
    static var sourceURL : URL? {
        let path = (Self.dbFileName as NSString).deletingPathExtension
        let ext = (Self.dbFileName as NSString).pathExtension
        guard let sourceURL = Bundle.main.url(forResource: path, withExtension: ext) else {
                return nil
        }
        return sourceURL
    }
    
    
}
