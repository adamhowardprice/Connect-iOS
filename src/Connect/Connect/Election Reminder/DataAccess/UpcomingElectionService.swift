import Foundation
import CBGPromise

enum UpcomingElectionServiceError: ErrorType {
    case FailedToFetchUpcomingElections(underlyingErrors: [ErrorType])
}

typealias UpcomingElectionPromise = Promise<UpcomingElection, UpcomingElectionRepositoryError>
typealias UpcomingElectionFuture = Future<UpcomingElection, UpcomingElectionRepositoryError>

protocol UpcomingElectionService {
    func fetchUpcomingElection(address: String) -> UpcomingElectionFuture
}