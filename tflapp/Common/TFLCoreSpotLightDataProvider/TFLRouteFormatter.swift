//
//  TFLRouteFormatter.swift
//  tflapp
//
//  Created by Frank Saar on 10/11/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import Foundation

extension Array where Element == TFLRouteFormatter {
    
    private func withoutReturnRoutes(sequence : [Element] = []) -> [Element] {
        guard !self.isEmpty,let element = self.first else {
            return sequence
        }
        let set = Set(self)
        let includesReturn : TFLRouteFormatter.Direction = set.contains(element.returnRoute) ? .includingReturn : .oneWay
        let newElemet = TFLRouteFormatter(from: element.from, to: element.to, direction: includesReturn)
        let newSet = set.subtracting([element,element.returnRoute])
        let newSequence = sequence + [newElemet]
        return Array(newSet).withoutReturnRoutes(sequence: newSequence)
    }
    
    var shortRoutes : [String] {
        let routeDescriptions = withoutReturnRoutes().map{ $0.shortDescription }
        return routeDescriptions
    }
    
    var routes : [String] {
        let routeDescriptions = withoutReturnRoutes().map{ String(describing: $0) }
        return routeDescriptions
    }
    
}

struct TFLRouteFormatter {
    enum Direction {
        case oneWay
        case includingReturn
        
        var symbol : String {
            switch self {
            case .oneWay:
                return "→"
            case .includingReturn:
                return "↔"
            }
        }
    }
    
    private let shortList : [String : String] = {
        let englishLocaleIdentifier = Locale(identifier: "en").identifier
        let englishResourcePath = Bundle.main.path(forResource: "abbreviations", ofType: "plist", inDirectory: nil, forLocalization: englishLocaleIdentifier)
        guard let path = englishResourcePath else {
            return [:]
        }
        let dictionary = NSDictionary(contentsOfFile: path)
        return dictionary as? [String : String] ?? [:]
    }()
    var shortFrom : String { return shorten(name: from) }
    var shortTo : String { return shorten(name: to) }
    let from : String
    let to : String
    let direction : Direction
    init(from: String,to: String,direction : Direction = .oneWay) {
        self.from = from
        self.to = to
        self.direction = direction
    }
    
    var returnRoute : TFLRouteFormatter {
        return TFLRouteFormatter(from: to, to: from,direction:self.direction)
    }
}

// MARK: Private

extension TFLRouteFormatter  {
    
    private func shorten(name : String) -> String {
        let short = shortList.reduce(name) { from,shortEntry in
            let (key,value) = shortEntry
            return from.replacingOccurrences(of: "\\b\(key)\\b", with: value, options: .regularExpression, range: nil)
        }
        return short
    }
}

extension TFLRouteFormatter : CustomStringConvertible {
    var description: String {
        return "• \(from) \(direction.symbol) \(to)"
    }
    
    var shortDescription: String {
        return "• \(shortFrom) \(direction.symbol) \(shortTo)"
    }
}


// MARK: Hashable

extension TFLRouteFormatter : Hashable {
    static func ==(lhs : TFLRouteFormatter,rhs : TFLRouteFormatter) -> Bool {
        return lhs.from  == rhs.from && lhs.to == rhs.to
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(from)
        hasher.combine(to)
    }
}
