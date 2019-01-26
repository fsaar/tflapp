//
//  TFLCoreSpotLightDataProvider.swift
//  tflapp
//
//  Created by Frank Saar on 10/11/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//
import UIKit
import Foundation
import CoreData


class TFLLineInfoRouteDirectory : TFLCoreSpotLightDataProviderDataSource {
    private var lines : [String] = []
    private var routesDict : [String : [String]] = [:]
    init(with dict : [String : [String]]) {
        routesDict = dict
        lines = Array(routesDict.keys)
    }
    
    class func infoRouteDirectoryFromCoreData() ->  TFLLineInfoRouteDirectory {
        let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
        let fetchRequest = NSFetchRequest<TFLCDLineInfo>(entityName: String(describing: TFLCDLineInfo.self))
        fetchRequest.fetchBatchSize = 100
        var dict : [String : [String]] = [:]
        context.performAndWait {
            if let lineInfos = try? context.fetch(fetchRequest) {
                lineInfos.forEach { lineInfo in
                    if let identifier = lineInfo.identifier,
                        let routes : [String] =  lineInfo.routes?.compactMap ({ ($0 as? TFLCDLineRoute)?.name  }) {
                        dict[identifier] = routes
                    }
                }
            }
        }
        let infoRouteDirectory = TFLLineInfoRouteDirectory(with: dict)
        return infoRouteDirectory
    }
    
    func numberOfLinesForCoreSpotLightDataProvider(_ provider : TFLCoreSpotLightDataProvider) -> Int {
        return lines.count
    }
    func lineForCoreSpotLightDataProvider(_ provider : TFLCoreSpotLightDataProvider,at index : Int) -> String {
        return lines[index]
    }
    func routesForCoreSpotLightDataProvider(_ provider : TFLCoreSpotLightDataProvider,for line : String) -> [String] {
        return routesDict[line] ?? []
    }
}
