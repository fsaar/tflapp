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
import CoreSpotlight
import CoreServices

class TFLCoreSpotLightDataProvider {
    
    func searchableItems() -> [CSSearchableItem] {
        let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
        let fetchRequest = NSFetchRequest<TFLCDLineInfo>(entityName: String(describing: TFLCDLineInfo.self))
        fetchRequest.fetchBatchSize = 100
        var items : [CSSearchableItem] = []
        context.performAndWait {
            
            if let lineInfos = try? context.fetch(fetchRequest) {
                items = lineInfos.compactMap { [weak self] lineInfo in
                    guard let identifier = lineInfo.identifier,let attributeSet  = self?.searchableItemAttributeSet(with: lineInfo)  else {
                        return nil
                    }
                    let item = CSSearchableItem(uniqueIdentifier: identifier, domainIdentifier: "com.samedialabs.tflapp.lines", attributeSet: attributeSet)
                    return item
                }
            }
        }
        return items
    }
    
}

// MARK: Private

private extension TFLCoreSpotLightDataProvider {
    func busPredictionViewBackgroundImage(line : String) -> UIImage {
        let bounds = CGRect(origin:.zero, size: CGSize(width: 50, height: 50))
        let busNumberRect = CGRect(x: 2, y: 15, width: 48, height: 20)
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(bounds: bounds,format: format)
        return renderer.image { context in
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: 5)
            let bgColor = UIColor.clear
            bgColor.setFill()
            path.fill()
            
            let busNumberRectPath = UIBezierPath(roundedRect: busNumberRect , cornerRadius: busNumberRect.size.height/2)
            UIColor.red.setFill()
            UIColor.white.setStroke()
            busNumberRectPath.fill()
            busNumberRectPath.stroke()
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs = [NSAttributedString.Key.font: UIFont.tflFontBusLineIdentifier(),NSAttributedString.Key.foregroundColor : UIColor.white,NSAttributedString.Key.paragraphStyle: paragraphStyle]
            let lineRect = busNumberRect.inset(by: UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0))
            line.draw(with: lineRect, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
    }
    
    func searchableItemAttributeSet(with lineInfo : TFLCDLineInfo ) -> CSSearchableItemAttributeSet? {
        var itemAttributeSet : CSSearchableItemAttributeSet? = nil
        lineInfo.managedObjectContext?.performAndWait {
            if let identifier = lineInfo.identifier   {
                let image = busPredictionViewBackgroundImage(line: identifier.uppercased())
                let attrs = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
                attrs.displayName = "Routes"
                attrs.thumbnailData = image.pngData()
                let separator = "&harr;"
                let routes : [String] =  lineInfo.routes?.compactMap { ($0 as? TFLCDLineRoute)?.name  } ?? []
                let formatterList : [TFLRouteFormatter] = routes.compactMap { route in
                    let elements = route.components(separatedBy: separator)
                    guard elements.count == 2,let from = elements.first,let to = elements.last else {
                        return nil
                    }
                    return TFLRouteFormatter(from: String(from.trimmingCharacters(in: .whitespaces)), to: String(to.trimmingCharacters(in: .whitespaces)))
                }
                
                let stationNames = formatterList.shortRoutes.joined(separator: "\n")
                print(stationNames)
                attrs.contentDescription = stationNames
                attrs.keywords = identifier == identifier.uppercased() ? [identifier.uppercased()] : [identifier.uppercased()]
                itemAttributeSet = attrs
            }
        }
        return itemAttributeSet
    }
}
