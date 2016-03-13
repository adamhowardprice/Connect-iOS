import Quick
import Nimble

@testable import Connect

class EventsResultsControllerSpec: QuickSpec {
    override func spec() {
        describe("EventsResultsController") {
            var subject: EventsResultsController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var eventPresenter: FakeEventPresenter!
            var eventSectionHeaderPresenter: FakeEventSectionHeaderPresenter!
            var eventListTableViewCellStylist: FakeEventListTableViewCellStylist!
            let theme = EventsResultsFakeTheme()

            beforeEach {
                nearbyEventsUseCase = MockNearbyEventsUseCase()
                eventPresenter = FakeEventPresenter()
                eventSectionHeaderPresenter = FakeEventSectionHeaderPresenter()
                eventListTableViewCellStylist = FakeEventListTableViewCellStylist()
                subject = EventsResultsController(
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    eventPresenter: eventPresenter,
                    eventSectionHeaderPresenter: eventSectionHeaderPresenter,
                    eventListTableViewCellStylist: eventListTableViewCellStylist,
                    theme: theme
                )
            }

            it("adds itself as an observer of the nearby events use case") {
                expect(nearbyEventsUseCase.observers.first as? EventsResultsController) === subject
            }

            describe("when the view loads") {
                it("adds its views as subviews") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews.count) == 1
                    expect(subject.view.subviews).to(contain(subject.tableView))
                }
            }

            describe("as a nearby events use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                context("when the use case reports that events have been found") {
                    let eventA = TestUtils.eventWithName("Bigtime Bernie BBQ")
                    let eventB = TestUtils.eventWithName("Slammin' Sanders Salsa Serenade")
                    let events : Array<Event> = [eventA, eventB]
                    let eventSearchResult = FakeEventSearchResult(events: events)

                    it("has a section per unique day in the search results") {
                        eventSearchResult.eventsByDay = [[eventA],[eventB]]
                        eventSearchResult.uniqueDays = [NSDate(), NSDate()]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)

                        expect(subject.tableView.numberOfSections) == 2

                        eventSearchResult.eventsByDay = [[eventA]]
                        eventSearchResult.uniqueDays = [NSDate()]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    it("uses the events section header presenter for the header title") {
                        let tableView = subject.tableView
                        let dateForSection = NSDate()

                        eventSearchResult.uniqueDays = [NSDate(), dateForSection]
                        eventSearchResult.eventsByDay = [[eventA], [eventB]]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)

                        let header = subject.tableView.delegate?.tableView!(tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView

                        expect(header?.textLabel?.text) == "Section header"
                        expect(Int(eventSectionHeaderPresenter.lastPresentedDate.timeIntervalSinceReferenceDate)) == Int(dateForSection.timeIntervalSinceReferenceDate)
                    }

                    it("displays a cell per event in each day section") {
                        eventSearchResult.uniqueDays = [NSDate()]

                        eventSearchResult.eventsByDay = [events]
                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 2

                        eventSearchResult.eventsByDay = [[eventA]]
                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 1
                    }
                }

                context("when the use case notifies it that no events have been found") {
                    beforeEach {
                        let eventSearchResult = FakeEventSearchResult(events: [])
                        eventSearchResult.eventsByDay = [[TestUtils.eventWithName("A")], [TestUtils.eventWithName("B")]]
                        eventSearchResult.uniqueDays = [NSDate(), NSDate()]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                    }

                    it("has one section") {
                        nearbyEventsUseCase.simulateFindingNoEvents()

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    it("returns nil for the header view") {
                        nearbyEventsUseCase.simulateFindingNoEvents()
                        let header = subject.tableView.delegate?.tableView!(subject.tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView

                        expect(header).to(beNil())
                    }


                    it("displays zero cells") {
                        nearbyEventsUseCase.simulateFindingNoEvents()

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 0
                    }
                }

                context("when the use case notifies it that it failed when fetching events") {
                    beforeEach {
                        let eventSearchResult = FakeEventSearchResult(events: [])
                        eventSearchResult.eventsByDay = [[TestUtils.eventWithName("A")], [TestUtils.eventWithName("B")]]
                        eventSearchResult.uniqueDays = [NSDate(), NSDate()]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                    }

                    it("has one section") {
                        nearbyEventsUseCase.simulateFailingToFindEvents(.FindingLocationError(.PermissionsError))

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    it("returns nil for the header view") {
                        nearbyEventsUseCase.simulateFailingToFindEvents(.FindingLocationError(.PermissionsError))
                        let header = subject.tableView.delegate?.tableView!(subject.tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView

                        expect(header).to(beNil())
                    }


                    it("displays zero cells") {
                        nearbyEventsUseCase.simulateFailingToFindEvents(.FindingLocationError(.PermissionsError))

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 0
                    }
                }
            }
        }
    }
}

private class FakeEventSearchResult: EventSearchResult {
    var uniqueDays: [NSDate] = []
    var eventsByDay: [[Event]] = []

    override func uniqueDaysInLocalTimeZone() -> [NSDate] {
        return self.uniqueDays
    }

    override func eventsWithDayIndex(dayIndex: Int) -> [Event] {
        return self.eventsByDay[dayIndex]
    }
}

private class FakeEventSectionHeaderPresenter: EventSectionHeaderPresenter {
    var lastPresentedDate: NSDate!

    init() {
        super.init(currentWeekDateFormatter: FakeDateFormatter(),
            nonCurrentWeekDateFormatter: FakeDateFormatter(),
            dateProvider: FakeDateProvider())
    }

    override func headerForDate(date: NSDate) -> String {
        self.lastPresentedDate = date
        return "Section header"
    }
}

private class FakeEventListTableViewCellStylist: EventListTableViewCellStylist {
    var lastStyledCell: EventListTableViewCell!
    var lastReceivedEvent: Event!

    private func styleCell(cell: EventListTableViewCell, event: Event) {
        self.lastStyledCell = cell
        self.lastReceivedEvent = event
    }
}

private class EventsResultsFakeTheme : FakeTheme {
    private override func defaultTableSectionHeaderBackgroundColor() -> UIColor {
        return UIColor.darkGrayColor()
    }

    private override func defaultTableSectionHeaderTextColor() -> UIColor {
        return UIColor.lightGrayColor()
    }

    private override func defaultTableSectionHeaderFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(999)
    }
}
