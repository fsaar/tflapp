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

extension TFLRouteFormatter {
    init?(route : String) {
        let separator = "&harr;"
        let elements = route.components(separatedBy: separator)
        guard elements.count == 2,let from = elements.first,let to = elements.last else {
            return nil
        }
        self.init(from: String(from.trimmingCharacters(in: .whitespaces)), to: String(to.trimmingCharacters(in: .whitespaces)))
    }
}

protocol TFLCoreSpotLightDataProviderDataSource : class {
    func numberOfLinesForCoreSpotLightDataProvider(_ provider : TFLCoreSpotLightDataProvider) -> Int
    func lineForCoreSpotLightDataProvider(_ provider : TFLCoreSpotLightDataProvider,at index : Int) -> String
    func routesForCoreSpotLightDataProvider(_ provider : TFLCoreSpotLightDataProvider,for line : String) -> [String]
}



class TFLCoreSpotLightDataProvider {
    private weak var dataSource : TFLCoreSpotLightDataProviderDataSource?
    init(with dataSource : TFLCoreSpotLightDataProviderDataSource) {
        self.dataSource = dataSource
    }
    func searchableItems(on queue : OperationQueue = OperationQueue.main,
                         using completionBlock: @escaping (_ items : [CSSearchableItem]) -> Void )   {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let dataSource = self.dataSource else {
                completionBlock([])
                return
            }
            let count = dataSource.numberOfLinesForCoreSpotLightDataProvider(self)
            
            let items : [CSSearchableItem]  = (0 ..< count).compactMap { index in
                let identifier = dataSource.lineForCoreSpotLightDataProvider(self, at: index)
                let routes = dataSource.routesForCoreSpotLightDataProvider(self, for: identifier)
                let image = self.busPredictionViewBackgroundImage(line: identifier.uppercased())
                guard let attributeSet  = self.searchableItemAttributeSet(with: identifier,routes: routes,and: image) else {
                    return nil
                }
                let item = CSSearchableItem(uniqueIdentifier: identifier, domainIdentifier: "com.samedialabs.tflapp.lines", attributeSet: attributeSet)
                return item
            }
            queue.addOperation {
                completionBlock(items)
            }
        }
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
    
    func searchableItemAttributeSet(with identifier : String,routes : [String], and image : UIImage?) -> CSSearchableItemAttributeSet? {
        let attrs = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
        attrs.displayName = "Routes"
        attrs.thumbnailData = image?.pngData()
        let formatterList = routes.compactMap { TFLRouteFormatter(route: $0) }
        let stationNames = formatterList.shortRoutes.joined(separator: "\n")
        attrs.contentDescription = stationNames
        attrs.keywords = identifier.lowercased() == identifier.uppercased() ? [identifier] : [identifier.lowercased(),identifier.uppercased()]
        return attrs
    }
}
