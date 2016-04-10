import Foundation

class UpcomingElection {
    let state: String
    let city: String
    let county: String
    let address: String
    let zip: String
    let precinctCode: String
    let isPrimary: Bool
    let startTime: NSDate
    let endTime: NSDate

    init(state: String,
         city: String,
         county: String,
         address: String,
         zip: String,
         precinctCode: String,
         isPrimary: Bool,
         startTime: NSDate,
         endTime: NSDate) {

        self.state = state
        self.city = city
        self.county = county
        self.address = address
        self.zip = zip
        self.precinctCode = precinctCode
        self.isPrimary = isPrimary
        self.startTime = startTime
        self.endTime = endTime
    }

    var isUpcoming: Bool {
        get {
            return !self.endTime.timeIntervalSinceNow.isSignMinus
        }
    }
}