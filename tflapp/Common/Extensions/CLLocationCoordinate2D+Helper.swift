import CoreLocation
import MapKit

extension String {
    var decodePolyline : [CLLocationCoordinate2D] {
        let polyLine = PolyLine(precision: 5)
        return polyLine.decode(polyLine: self)
    }
}

extension Array where Element == CLLocationCoordinate2D {
    
    #if DATABASEGENERATION
    var hasLoop : Bool {
        return !loopRanges.isEmpty
    }
    var loopRanges :  [ClosedRange<Int>] {
        let threshold = Double(3)
        var ranges : [ClosedRange<Int>] = []
        for tuple in self.enumerated() {
            let isInRange = ranges.reduce(false) { $0 || $1 ~= tuple.0 }
            let startIndex = tuple.0 + 1
            guard !isInRange,startIndex < self.endIndex else {
                continue
            }

            let location = tuple.1.location
            let subList = (self[startIndex..<self.endIndex]).enumerated().map { ($0.0 + startIndex,$0.1) }
            let distances : [(index:Int,distance:Double)] = subList.map { tuple2 in
                let location2 = tuple2.1.location
                let distance = location.distance(from: location2)
                return (tuple2.0,distance)
            }
            // is there a node j that has a distance of less than threshold meters to node i with i<j and j - i > 2
            // if so remember nodes in range i+1...j-1 fro removal. // Restrict length of removed loops to 5
            let filtered : ClosedRange<Int>?  = distances.compactMap { tuple2 in
                guard (tuple2.distance < threshold),3... ~= (tuple2.index - tuple.0)  else {
                    return nil
                }
                let startIndex = self.index(after: tuple.0)
                let endIndex = self.index(before: tuple2.index)
                return startIndex...endIndex
            }.last
            if let lastFilteredRaneg = filtered {
                ranges += [lastFilteredRaneg]
            }
           
        }
        return ranges
    }
    
    func removeLoops() -> [CLLocationCoordinate2D] {
        var coordinates = Array(self)
        let ranges = coordinates.loopRanges
        for range in ranges.reversed() {
            coordinates.removeSubrange(range)
        }
        return coordinates
    }
    
    func routeSections(n: Int) -> [CountableClosedRange<Int>] {
        let limits = stride(from:0,to:n-1,by:1).map { ($0,Swift.min($0 + 1, n-1)) }
                                                    .filter { $0.0 != $0.1 }
        let ranges = limits.map { $0.0...$0.1 }
        return ranges
        
    }
    
    func URLsForRouteSections(_ sections : [CountableClosedRange<Int>]) -> [URL] {
        let urls : [URL] = sections.map { range in
            let sublist = Array(self[range])
            let (start,end) = (sublist[0],sublist[1])
            // https://developers.google.com/maps/documentation/directions/intro
            // https://console.cloud.google.com/apis/credentials/
            // https://console.cloud.google.com/billing/
            let GOOGLE_ROUTES_API_KEY = "PASTE_YOUR_GOOGLE_ROUTES_API_KEY_HERE"
            let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(start.latitude),\(start.longitude)&destination=\(end.latitude),\(end.longitude)&mode=transit&transit_mode=bus&key=\(GOOGLE_ROUTES_API_KEY)")!
            return url
        }
        return urls
    }

    func googleHiresRoutes(with session : URLSession ,completionBlock : @escaping ([CLLocationCoordinate2D]) -> Void) {
        let sections = routeSections(n: self.count)
        let urls = URLsForRouteSections(sections)
        var list : [(Int,[CLLocationCoordinate2D])] = []
        let polyLine = PolyLine(precision: 5)
        let group = DispatchGroup()
        urls.enumerated().forEach { index,url in
            group.enter()
            let task = session.dataTask(with: url) { data, _, _ in
                if let data = data,let routesInfo = try? JSONDecoder().decode(GoogleRouteInfo.self, from: data)  {
                    let coordinates = polyLine.decode(polyLine: routesInfo.polyline)
                    if !coordinates.isEmpty {
                        list += [(index,coordinates)]
                    }
                    else {
                        print("- no polyline -")
                        let range = sections[index]
                        let sublist = Array(self[range])
                        let coordinates = [sublist[0],sublist[1]]
                        list += [(index,coordinates)]
                    }
                }
                else if let data = data,let dataString = String(data: data, encoding: .utf8) {
                    print("- no GoogleRouteInfo JSON -")
                    print(dataString)
                }
                group.leave()
            }
            task.resume()
        }
        group.notify(queue: .main) {
            guard list.count == self.count - 1 else {
                print("- hires route failed -")
                completionBlock([])
                return
            }
            let sortedList = list.sorted { $0.0 < $1.0 }.map { $0.1 }
            let coords = sortedList.reduce([]) { $0 + $1  }
            completionBlock(coords)
        }
    }
    func save() {
        let tempCoords :  [[String : Double] ] = self.map { ["latitude" : $0.latitude,"longitude": $0.longitude] }
        guard let jsonData = try? JSONEncoder().encode(tempCoords) else {
            return
        }
        let fileURL = FileManager.default.urls(for: .documentDirectory,in: .userDomainMask).last!.appendingPathComponent("coordinates\(Date()).json")

        try? jsonData.write(to: fileURL)

    }
    #endif
}

extension CLLocationCoordinate2D : Equatable {
    public static func ==(lhs : CLLocationCoordinate2D,rhs : CLLocationCoordinate2D) -> Bool {
        return (lhs.latitude == rhs.latitude) && (lhs.longitude == rhs.longitude)
    }
}

extension CLLocationCoordinate2D {
    var isValid : Bool {
        let isNonNull = (self.latitude != 0) && (self.longitude != 0)
        let isValid = CLLocationCoordinate2DIsValid(self)
        return isNonNull && isValid
    }
    
    static func +(lhs : CLLocationCoordinate2D,rhs : CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(lhs.latitude+rhs.latitude, lhs.longitude+rhs.longitude)
    }
    
    var location : CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
}
