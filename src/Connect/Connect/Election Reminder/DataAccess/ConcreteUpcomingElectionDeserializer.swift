import Foundation

class ConcreteUpcomingElectionDeserializer: UpcomingElectionDeserializer {
    private static let formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone.localTimeZone()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+ZZ:ZZ"
        return formatter
    }()

    func deserializeUpcomingElection(jsonDictionary: NSDictionary) -> UpcomingElection {
        print(jsonDictionary)

        let state = jsonDictionary["poll_state"] as? String
        let city = jsonDictionary["poll_city"] as? String
        let county = jsonDictionary["poll_county"] as? String
        let address = jsonDictionary["poll_address"] as? String
        let zip = jsonDictionary["poll_zip"] as? String
        let precinctCode = jsonDictionary["poll_precinctCode"] as? String
        let name = jsonDictionary["poll_name"] as? String
        let isPrimary = jsonDictionary["poll_is_primary"] as? Bool

        return UpcomingElection(
            state: state!,
            city: city!,
            county: county!,
            address: address!,
            zip: zip!,
            precinctCode: precinctCode!,
            isPrimary: isPrimary!,
            name: name!,
            startTime: NSDate(), // TODO: Use date formatter correctly
            endTime: NSDate()
        )
    }
}