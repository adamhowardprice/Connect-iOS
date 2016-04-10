class ConcreteUpcomingElectionService: UpcomingElectionService {
    let upcomingElectionRepository: UpcomingElectionRepository
    let workerQueue: NSOperationQueue
    let resultQueue: NSOperationQueue

    init(upcomingElectionRepository: UpcomingElectionRepository, workerQueue: NSOperationQueue, resultQueue: NSOperationQueue) {
        self.upcomingElectionRepository = upcomingElectionRepository
        self.workerQueue = workerQueue
        self.resultQueue = resultQueue
    }

    func fetchUpcomingElection(address: String) -> UpcomingElectionFuture {
        let promise = UpcomingElectionPromise()

        workerQueue.addOperationWithBlock {
            let upcomingElectionFuture = self.upcomingElectionRepository.fetchUpcomingElection(address)

            upcomingElectionFuture.then { upcomingElection in
                self.resultQueue.addOperationWithBlock { promise.resolve(upcomingElection) }
                }.error { error in
                    self.resultQueue.addOperationWithBlock { promise.reject(error) }
                }
        }

        return promise.future
    }
}