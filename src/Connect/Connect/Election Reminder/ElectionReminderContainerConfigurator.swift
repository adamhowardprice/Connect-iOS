import Swinject

// swiftlint:disable type_body_length
class ElectionReminderContainerConfigurator: ContainerConfigurator {
    static func configureContainer(container: Container) {
        configureDataAccess(container)
        configureUI(container)
    }

    private static func configureDataAccess(container: Container) {
        container.register(UpcomingElectionDeserializer.self) { resolver in
            return ConcreteUpcomingElectionDeserializer()
            }.inObjectScope(.Container)

        container.register(UpcomingElectionRepository.self) { resolver in
            return ConcreteUpcomingElectionRepository(
                urlProvider: resolver.resolve(URLProvider.self)!,
                jsonClient: resolver.resolve(JSONClient.self)!,
                upcomingElectionDeserializer: resolver.resolve(UpcomingElectionDeserializer.self)!)
        }.inObjectScope(.Container)

        container.register(UpcomingElectionService.self) { resolver in
            return ConcreteUpcomingElectionService(
                upcomingElectionRepository: resolver.resolve(UpcomingElectionRepository.self)!,
                workerQueue: resolver.resolve(NSOperationQueue.self, name: "work")!,
                resultQueue: resolver.resolve(NSOperationQueue.self, name: "main")!)
            }.inObjectScope(.Container)
    }

    private static func configureUI(container: Container) {
        container.register(ElectionReminderController.self) { resolver in
            return ElectionReminderController(
                theme: resolver.resolve(Theme.self)!,
                upcomingElectionService: resolver.resolve(UpcomingElectionService.self)!)
            }.inObjectScope(.Container)
    }
}
// swiftlint:enable type_body_length