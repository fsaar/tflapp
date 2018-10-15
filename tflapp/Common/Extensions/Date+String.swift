import Foundation

extension Date {
    func relativePastDateStringFromNow() -> String? {
        let day =  Double(3600 * 24)
        let week = day * 7
        let timeinterval = -self.timeIntervalSinceNow
        switch timeinterval {
        case ..<0:
            return nil
        case 0..<30:
            return  NSLocalizedString("DateStringConversion.just_now", comment: "")
        case 30..<60:
            return NSLocalizedString("DateStringConversion.about_30_secs_ago", comment: "")
        case 60..<3600:
            let minutes = Int(timeinterval/60)
            let dateString = minutes == 1 ? NSLocalizedString("DateStringConversion.about_1_minute_ago", comment: "") : "\(minutes) \(NSLocalizedString("DateStringConversion.about_minutes_ago", comment: ""))"
            return dateString
        case 3600..<(3600*24):
            let hours = Int(timeinterval/3600)
            let dateString = hours == 1 ? NSLocalizedString("DateStringConversion.about_1_hour_ago", comment: "") : "\(hours) \(NSLocalizedString("DateStringConversion.about_hours_ago", comment: ""))"
            return dateString
        case day..<(day*2):
            return NSLocalizedString("DateStringConversion.yesterday", comment: "")
        case (day*2)..<week:
            return NSLocalizedString("DateStringConversion.days_ago", comment: "")
        case week..<(week*2):
            return NSLocalizedString("DateStringConversion.last_week", comment: "")
        default:
            return NSLocalizedString("DateStringConversion.weeks_ago", comment: "")
        }
    }
}
