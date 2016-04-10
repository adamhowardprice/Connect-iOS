import Foundation

class ConcreteUpcomingElectionDeserializer: UpcomingElectionDeserializer {
    func deserializeUpcomingElection(jsonDictionary: NSDictionary) -> UpcomingElection {
        print(jsonDictionary)

        let state = jsonDictionary["poll_state"] as? String
        let city = jsonDictionary["poll_city"] as? String
        let county = jsonDictionary["poll_county"] as? String
        let address = jsonDictionary["poll_address"] as? String
        let zip = jsonDictionary["poll_zip"] as? String
        let precinctCode = jsonDictionary["poll_precinctCode"] as? String
        let isPrimary = jsonDictionary["poll_is_primary"] as? Bool

        return UpcomingElection(
            state: state!,
            city: city!,
            county: county!,
            address: address!,
            zip: zip!,
            precinctCode: precinctCode!,
            isPrimary: isPrimary!,
            startTime: NSDate(),
            endTime: NSDate())
    }
}