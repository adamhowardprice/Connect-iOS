import Foundation

enum UpcomingElectionRepositoryError: ErrorType {
    case InvalidJSON(jsonObject: AnyObject)
    case ErrorInJSONClient(error: JSONClientError)
}

protocol UpcomingElectionRepository {
    func fetchUpcomingElection(address: String) -> UpcomingElectionFuture
}