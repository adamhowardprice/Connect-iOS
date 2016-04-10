import Foundation

class ConcreteElectionReminderControllerProvider: ElectionReminderControllerProvider {
    private let theme: Theme
    private let upcomingElectionService: UpcomingElectionService

    init(theme: Theme, upcomingElectionService: UpcomingElectionService) {
        self.theme = theme
        self.upcomingElectionService = upcomingElectionService
    }

    func provideElectionReminderController() -> UIViewController {
        return ElectionReminderController(theme: self.theme,
                                          upcomingElectionService: self.upcomingElectionService)
    }
}
