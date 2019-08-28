import Quick
import Nimble
import CoreLocation
import UIKit

@testable import BusStops
class TFLdateSpec: QuickSpec {
    
    override func spec() {
        
        describe("when asking for elapsed time") {
            it ("should return the right string if it happened in the future") {
                let date = Date(timeInterval: 15, since: Date())
                let dateString = date.relativePastDateStringFromNow()
                expect(dateString).to(beNil())
            }
            it ("should return the right string if it happened less than 30 seconds ago") {
                let date = Date.init(timeInterval: -15, since: Date())
                let dateString = date.relativePastDateStringFromNow()
                expect(dateString) == NSLocalizedString("DateStringConversion.just_now", comment: "")
            }
            it ("should return the right string if it happened more than 30 secs ago") {
                let date = Date.init(timeInterval: -35, since: Date())
                let dateString = date.relativePastDateStringFromNow()
                expect(dateString) == NSLocalizedString("DateStringConversion.about_30_secs_ago", comment: "")
            }
            it ("should return the right string if it happened more than 1 min ago") {
                let date = Date.init(timeInterval: -65, since: Date())
                let dateString = date.relativePastDateStringFromNow()
                expect(dateString) == NSLocalizedString("DateStringConversion.about_1_minute_ago", comment: "")
            }
            it ("should return the right string if it happened more than 15 mins ago") {
                let date = Date.init(timeInterval: -60*15-5, since: Date())
                let dateString = date.relativePastDateStringFromNow()
                expect(dateString) == "15 \(NSLocalizedString("DateStringConversion.about_minutes_ago", comment: ""))"
            }
            it ("should return the right string if it happened more than 1 hour ago") {
                let date = Date.init(timeInterval: -3600*1.5, since: Date())
                let dateString = date.relativePastDateStringFromNow()
                expect(dateString) == NSLocalizedString("DateStringConversion.about_1_hour_ago", comment: "")
            }
            it ("should return the right string if it happened more than 3 hours ago") {
                let date = Date.init(timeInterval: -3600*10, since: Date())
                let dateString = date.relativePastDateStringFromNow()
                expect(dateString) == "10 \(NSLocalizedString("DateStringConversion.about_hours_ago", comment: ""))"
            }
            it ("should return the right string if it happened more than 1 day ago") {
                let date = Date.init(timeInterval: -3600*25, since: Date())
                let dateString = date.relativePastDateStringFromNow()
                expect(dateString) == NSLocalizedString("DateStringConversion.yesterday", comment: "")
            }

            it ("should return the right string if it happened a few day ago") {
                let date = Date.init(timeInterval: -3600*72, since: Date())
                let dateString = date.relativePastDateStringFromNow()
                expect(dateString) ==  NSLocalizedString("DateStringConversion.days_ago", comment: "")
            }
            it ("should return the right string if it happened last week") {
                let date = Date.init(timeInterval: -3600*24*10, since: Date())
                let dateString = date.relativePastDateStringFromNow()
                expect(dateString) == NSLocalizedString("DateStringConversion.last_week", comment: "")
            }
            
            it ("should return the right string if it happened several weeks") {
                let date = Date.init(timeInterval: -3600*24*100, since: Date())
                let dateString = date.relativePastDateStringFromNow()
                expect(dateString) == NSLocalizedString("DateStringConversion.weeks_ago", comment: "")
            }
        }
    }
}

