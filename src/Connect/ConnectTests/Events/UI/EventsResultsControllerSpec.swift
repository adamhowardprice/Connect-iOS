import Quick
import Nimble

@testable import Connect

class EventsResultsControllerSpec: QuickSpec {
    override func spec() {
        describe("EventsResultsController") {
            var subject: EventsResultsController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var eventsNearAddressUseCase: MockEventsNearAddressUseCase!
            var eventPresenter: FakeEventPresenter!
            var eventSectionHeaderPresenter: FakeEventSectionHeaderPresenter!
            var eventListTableViewCellStylist: FakeEventListTableViewCellStylist!
            var resultQueue: FakeOperationQueue!

            let theme = EventsResultsFakeTheme()

            beforeEach {
                nearbyEventsUseCase = MockNearbyEventsUseCase()
                eventsNearAddressUseCase = MockEventsNearAddressUseCase()
                eventPresenter = FakeEventPresenter()
                eventSectionHeaderPresenter = FakeEventSectionHeaderPresenter()
                eventListTableViewCellStylist = FakeEventListTableViewCellStylist()
                resultQueue = FakeOperationQueue()

                subject = EventsResultsController(
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    eventsNearAddressUseCase: eventsNearAddressUseCase,
                    eventPresenter: eventPresenter,
                    eventSectionHeaderPresenter: eventSectionHeaderPresenter,
                    eventListTableViewCellStylist: eventListTableViewCellStylist,
                    resultQueue: resultQueue,
                    theme: theme
                )
            }

            it("adds itself as an observer of the nearby events use case") {
                expect(nearbyEventsUseCase.observers.first as? EventsResultsController) === subject
            }

            it("adds itself as an observer of the events near address use case") {
                expect(eventsNearAddressUseCase.observers.first as? EventsResultsController) === subject
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

                    it("has a section per unique day in the search results, on the result queue") {
                        eventSearchResult.eventsByDay = [[eventA],[eventB]]
                        eventSearchResult.uniqueDays = [NSDate(), NSDate()]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 2

                        eventSearchResult.eventsByDay = [[eventA]]
                        eventSearchResult.uniqueDays = [NSDate()]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    it("uses the events section header presenter for the header title, on the result queue") {
                        let tableView = subject.tableView
                        let dateForSection = NSDate()

                        eventSearchResult.uniqueDays = [NSDate(), dateForSection]
                        eventSearchResult.eventsByDay = [[eventA], [eventB]]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        let header = subject.tableView.delegate?.tableView!(tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView

                        expect(header?.textLabel?.text) == "Section header"
                        expect(Int(eventSectionHeaderPresenter.lastPresentedDate.timeIntervalSinceReferenceDate)) == Int(dateForSection.timeIntervalSinceReferenceDate)
                    }

                    it("displays a cell per event in each day section, on the result queue") {
                        eventSearchResult.uniqueDays = [NSDate()]

                        eventSearchResult.eventsByDay = [events]
                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 2

                        eventSearchResult.eventsByDay = [[eventA]]
                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

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
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    it("returns nil for the header view") {
                        nearbyEventsUseCase.simulateFindingNoEvents()
                        resultQueue.lastReceivedBlock()

                        let header = subject.tableView.delegate?.tableView!(subject.tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView

                        expect(header).to(beNil())
                    }


                    it("displays zero cells") {
                        nearbyEventsUseCase.simulateFindingNoEvents()
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 0
                    }
                }

                context("when the use case notifies it that it failed when fetching events") {
                    beforeEach {
                        let eventSearchResult = FakeEventSearchResult(events: [])
                        eventSearchResult.eventsByDay = [[TestUtils.eventWithName("A")], [TestUtils.eventWithName("B")]]
                        eventSearchResult.uniqueDays = [NSDate(), NSDate()]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                    }

                    it("has one section") {
                        nearbyEventsUseCase.simulateFailingToFindEvents(.FindingLocationError(.PermissionsError))
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    it("returns nil for the header view") {
                        nearbyEventsUseCase.simulateFailingToFindEvents(.FindingLocationError(.PermissionsError))
                        resultQueue.lastReceivedBlock()

                        let header = subject.tableView.delegate?.tableView!(subject.tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView

                        expect(header).to(beNil())
                    }


                    it("displays zero cells") {
                        nearbyEventsUseCase.simulateFailingToFindEvents(.FindingLocationError(.PermissionsError))
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 0
                    }
                }
            }

            describe("as an events near address use case observer") {
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

                        eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 2

                        eventSearchResult.eventsByDay = [[eventA]]
                        eventSearchResult.uniqueDays = [NSDate()]

                        eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    it("uses the events section header presenter for the header title") {
                        let tableView = subject.tableView
                        let dateForSection = NSDate()

                        eventSearchResult.uniqueDays = [NSDate(), dateForSection]
                        eventSearchResult.eventsByDay = [[eventA], [eventB]]

                        eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        let header = subject.tableView.delegate?.tableView!(tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView

                        expect(header?.textLabel?.text) == "Section header"
                        expect(Int(eventSectionHeaderPresenter.lastPresentedDate.timeIntervalSinceReferenceDate)) == Int(dateForSection.timeIntervalSinceReferenceDate)
                    }

                    it("displays a cell per event in each day section") {
                        eventSearchResult.uniqueDays = [NSDate()]

                        eventSearchResult.eventsByDay = [events]
                        eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 2

                        eventSearchResult.eventsByDay = [[eventA]]
                        eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 1
                    }
                }

                context("when the use case notifies it that no events have been found") {
                    beforeEach {
                        let eventSearchResult = FakeEventSearchResult(events: [])
                        eventSearchResult.eventsByDay = [[TestUtils.eventWithName("A")], [TestUtils.eventWithName("B")]]
                        eventSearchResult.uniqueDays = [NSDate(), NSDate()]

                        eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()
                    }

                    it("has one section") {
                        eventsNearAddressUseCase.simulateFindingNoEvents()
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    it("returns nil for the header view") {
                        eventsNearAddressUseCase.simulateFindingNoEvents()
                        resultQueue.lastReceivedBlock()

                        let header = subject.tableView.delegate?.tableView!(subject.tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView

                        expect(header).to(beNil())
                    }


                    it("displays zero cells") {
                        eventsNearAddressUseCase.simulateFindingNoEvents()
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 0
                    }
                }

                context("when the use case notifies it that it failed when fetching events") {
                    beforeEach {
                        let eventSearchResult = FakeEventSearchResult(events: [])
                        eventSearchResult.eventsByDay = [[TestUtils.eventWithName("A")], [TestUtils.eventWithName("B")]]
                        eventSearchResult.uniqueDays = [NSDate(), NSDate()]

                        eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()
                    }

                    it("has one section") {
                        eventsNearAddressUseCase.simulateFailingToFindEvents(.FetchingEventsError(.InvalidJSONError(jsonObject: [])))
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    it("returns nil for the header view") {
                        eventsNearAddressUseCase.simulateFailingToFindEvents(.FetchingEventsError(.InvalidJSONError(jsonObject: [])))
                        resultQueue.lastReceivedBlock()

                        let header = subject.tableView.delegate?.tableView!(subject.tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView

                        expect(header).to(beNil())
                    }


                    it("displays zero cells") {
                        eventsNearAddressUseCase.simulateFailingToFindEvents(.FetchingEventsError(.InvalidJSONError(jsonObject: [])))
                        resultQueue.lastReceivedBlock()

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
