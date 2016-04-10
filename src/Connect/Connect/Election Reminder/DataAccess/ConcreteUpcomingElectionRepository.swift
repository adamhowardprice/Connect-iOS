import Foundation
import CBGPromise

class ConcreteUpcomingElectionRepository: UpcomingElectionRepository {
    private let urlProvider: URLProvider
    private let jsonClient: JSONClient
    private let upcomingElectionDeserializer: UpcomingElectionDeserializer

    init(
        urlProvider: URLProvider,
        jsonClient: JSONClient,
        upcomingElectionDeserializer: UpcomingElectionDeserializer) {
        self.urlProvider = urlProvider
        self.jsonClient = jsonClient
        self.upcomingElectionDeserializer = upcomingElectionDeserializer
    }

    func fetchUpcomingElection(address: String) -> UpcomingElectionFuture {
        let promise = UpcomingElectionPromise()

        let upcomingElectionJSONFuture = self.jsonClient.JSONPromiseWithURL(urlProvider.electionURL(address), method: "GET", bodyDictionary: nil)

        upcomingElectionJSONFuture.then({ deserializedObject in
            guard let jsonDictionary = deserializedObject as? NSDictionary
                else {
                let incorrectObjectTypeError = UpcomingElectionRepositoryError.InvalidJSON(jsonObject: deserializedObject)
                promise.reject(incorrectObjectTypeError)
                return
            }

            let parsedUpcomingElection = self.upcomingElectionDeserializer.deserializeUpcomingElection(jsonDictionary)

            promise.resolve(parsedUpcomingElection as UpcomingElection)
        })

        upcomingElectionJSONFuture.error { receivedError in
            let error = UpcomingElectionRepositoryError.ErrorInJSONClient(error: receivedError)
            promise.reject(error)
        }

        return promise.future
    }
}