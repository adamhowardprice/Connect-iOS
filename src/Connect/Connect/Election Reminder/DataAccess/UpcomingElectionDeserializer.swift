import Foundation

protocol UpcomingElectionDeserializer {
    func deserializeUpcomingElection(jsonDictionary: NSDictionary) -> UpcomingElection
}

