import Quick
import Nimble

@testable import Movement

class ActionsControllerSpec: QuickSpec {
    override func spec() {
        sharedExamples("a controller that sets up the table view with the default rows correctly") { (sharedExampleContext: SharedExampleContext) in
            var subject: ActionsController!
            var tableView: UITableView!
            var actionsTableViewCellPresenter: FakeActionsTableViewCellPresenter!
            var actionAlerts: [ActionAlert]!

            beforeEach {
                subject = sharedExampleContext()["subject"] as! ActionsController
                tableView = sharedExampleContext()["tableView"] as! UITableView
                actionsTableViewCellPresenter = sharedExampleContext()["actionsTableViewCellPresenter"] as! FakeActionsTableViewCellPresenter
                let wrapper =  sharedExampleContext()["actionAlerts"] as! ActionAlertsWrapper
                actionAlerts = wrapper.actionAlerts
            }

            it("shows the table view, and stops the loading spinner") {
                expect(tableView.hidden).to(equal(false));
                expect(subject.loadingIndicatorView.isAnimating()).to(equal(false))
            }

            describe("the table view contents") {
                var expectedNumberOfSections: Int!
                var sectionOffset: Int!
                var urlOpener: FakeURLOpener!
                var analyticsService: FakeAnalyticsService!

                beforeEach {
                    expectedNumberOfSections = sharedExampleContext()["numberOfSections"] as! Int
                    sectionOffset = expectedNumberOfSections == 2 ? 0 : 1

                    subject = sharedExampleContext()["subject"] as! ActionsController
                    urlOpener = sharedExampleContext()["urlOpener"] as! FakeURLOpener
                    analyticsService = sharedExampleContext()["analyticsService"] as! FakeAnalyticsService
                }

                it("has the correct number of sections") {
                    expect(tableView.numberOfSections).to(equal(expectedNumberOfSections))
                }

                it("styles the section headers with the theme") {
                    let sectionHeader = UITableViewHeaderFooterView()

                    for i in 0...(expectedNumberOfSections - 1) {
                        tableView.delegate!.tableView!(tableView, willDisplayHeaderView: sectionHeader, forSection: i)

                        expect(sectionHeader.contentView.backgroundColor).to(equal(UIColor.darkGrayColor()))
                        expect(sectionHeader.textLabel!.textColor).to(equal(UIColor.lightGrayColor()))
                        expect(sectionHeader.textLabel!.font).to(equal(UIFont.italicSystemFontOfSize(999)))
                    }
                }

                describe("the fundraising section") {
                    var fundraisingSectionIndex: Int!

                    beforeEach {
                        fundraisingSectionIndex = 0 + sectionOffset
                    }

                    it("has a section for fundraising") {
                        let title = tableView.dataSource?.tableView!(tableView, titleForHeaderInSection: fundraisingSectionIndex)
                        expect(title).to(equal("FUNDRAISE"))
                    }

                    it("has the correct number of rows") {
                        expect(tableView.dataSource!.tableView(tableView, numberOfRowsInSection: fundraisingSectionIndex)).to(equal(2))
                    }

                    describe("the donation row") {
                        var cell: UITableViewCell!
                        var indexPath: NSIndexPath!

                        beforeEach {
                            indexPath = NSIndexPath(forRow: 0, inSection: fundraisingSectionIndex)
                            cell = tableView.dataSource!.tableView(tableView, cellForRowAtIndexPath: indexPath)
                        }

                        it("uses the cell presenter to present the cell") {
                            expect(actionsTableViewCellPresenter.lastActionActionAlerts).to(equal(actionAlerts))
                            expect(actionsTableViewCellPresenter.lastActionTableView).to(beIdenticalTo(tableView))
                            expect(actionsTableViewCellPresenter.lastActionIndexPath).to(equal(indexPath))

                            expect(cell).to(beIdenticalTo(actionsTableViewCellPresenter.lastReturnedActionTableViewCell))
                        }

                        describe("tapping on the donate row") {
                            it("opens the donate page in safari") {
                                tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: indexPath)

                                expect(urlOpener.lastOpenedURL).to(equal(NSURL(string: "https://example.com/donate")!))
                            }

                            it("should log a content view with the analytics service") {
                                tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: indexPath)

                                expect(analyticsService.lastContentViewName).to(equal("Donate Form"))
                                expect(analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Actions))
                                expect(analyticsService.lastContentViewID).to(equal("Donate Form"))
                            }
                        }
                    }

                    describe("the sharing the donation page row") {
                        var cell: UITableViewCell!
                        var indexPath: NSIndexPath!

                        beforeEach {
                            indexPath = NSIndexPath(forRow: 1, inSection: fundraisingSectionIndex)
                            cell = tableView.dataSource!.tableView(tableView, cellForRowAtIndexPath: indexPath)
                        }

                        it("uses the cell presenter to present the cell") {
                            expect(actionsTableViewCellPresenter.lastActionActionAlerts).to(equal(actionAlerts))
                            expect(actionsTableViewCellPresenter.lastActionTableView).to(beIdenticalTo(tableView))
                            expect(actionsTableViewCellPresenter.lastActionIndexPath).to(equal(indexPath))

                            expect(cell).to(beIdenticalTo(actionsTableViewCellPresenter.lastReturnedActionTableViewCell))
                        }

                        describe("tapping on the sharing the donation page row") {
                            beforeEach {
                                tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: indexPath)
                            }

                            it("should present an activity view controller for donation page") {
                                let activityViewControler = subject.presentedViewController as! UIActivityViewController
                                let activityItems = activityViewControler.activityItems()

                                expect(activityItems.count).to(equal(1))
                                expect(activityItems.first as? NSURL).to(equal(NSURL(string: "https://example.com/donate")!))
                            }

                            it("logs that the user tapped share") {
                                expect(analyticsService.lastCustomEventName).to(equal("Began Share"))
                                let expectedAttributes = [
                                    AnalyticsServiceConstants.contentIDKey: NSURL(string: "https://example.com/donate")!.absoluteString,
                                    AnalyticsServiceConstants.contentNameKey: "Donate Form",
                                    AnalyticsServiceConstants.contentTypeKey: "Actions"
                                ]

                                expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                            }

                            context("and the user completes the share succesfully") {
                                it("tracks the share via the analytics service") {
                                    let activityViewControler = subject.presentedViewController as! UIActivityViewController
                                    activityViewControler.completionWithItemsHandler!("Some activity", true, nil, nil)

                                    expect(analyticsService.lastShareActivityType).to(equal("Some activity"))
                                    expect(analyticsService.lastShareContentName).to(equal("Donate Form"))
                                    expect(analyticsService.lastShareContentType!).to(equal(AnalyticsServiceContentType.Actions))
                                    expect(analyticsService.lastShareID).to(equal(NSURL(string: "https://example.com/donate")!.absoluteString))
                                }
                            }

                            context("and the user cancels the share") {
                                it("tracks the share cancellation via the analytics service") {
                                    let activityViewControler = subject.presentedViewController as! UIActivityViewController
                                    activityViewControler.completionWithItemsHandler!(nil, false, nil, nil)

                                    expect(analyticsService.lastCustomEventName).to(equal("Cancelled Share"))
                                    let expectedAttributes = [
                                        AnalyticsServiceConstants.contentIDKey: NSURL(string: "https://example.com/donate")!.absoluteString,
                                        AnalyticsServiceConstants.contentNameKey: "Donate Form",
                                        AnalyticsServiceConstants.contentTypeKey: "Actions"
                                    ]
                                    expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                                }
                            }

                            context("and there is an error when sharing") {
                                it("tracks the error via the analytics service") {
                                    let expectedError = NSError(domain: "a", code: 0, userInfo: nil)
                                    let activityViewControler = subject.presentedViewController as! UIActivityViewController
                                    activityViewControler.completionWithItemsHandler!("asdf", true, nil, expectedError)

                                    expect(analyticsService.lastError as NSError).to(beIdenticalTo(expectedError))
                                    expect(analyticsService.lastErrorContext).to(equal("Failed to share Donate Form"))
                                }
                            }
                        }
                    }
                }

                describe("the organizing section") {
                    var organizingSectionIndex: Int!

                    beforeEach {
                        organizingSectionIndex = 1 + sectionOffset
                    }

                    it("has a section for organizing") {
                        let title = tableView.dataSource?.tableView!(tableView, titleForHeaderInSection: organizingSectionIndex)
                        expect(title).to(equal("ORGANIZE"))
                    }

                    it("has the correct number of rows") {
                        expect(tableView.dataSource!.tableView(tableView, numberOfRowsInSection: organizingSectionIndex)).to(equal(1))
                    }

                    describe("host an event row") {
                        var cell: UITableViewCell!
                        var indexPath: NSIndexPath!

                        beforeEach {
                            indexPath = NSIndexPath(forRow: 0, inSection: organizingSectionIndex)
                            cell = tableView.dataSource!.tableView(tableView, cellForRowAtIndexPath: indexPath)
                        }

                        it("uses the cell presenter to present the cell") {
                            expect(actionsTableViewCellPresenter.lastActionActionAlerts).to(equal(actionAlerts))
                            expect(actionsTableViewCellPresenter.lastActionTableView).to(beIdenticalTo(tableView))
                            expect(actionsTableViewCellPresenter.lastActionIndexPath).to(equal(indexPath))

                            expect(cell).to(beIdenticalTo(actionsTableViewCellPresenter.lastReturnedActionTableViewCell))
                        }

                        describe("tapping on the host an event row") {
                            it("opens the host event page in safari") {
                                tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: indexPath)

                                expect(urlOpener.lastOpenedURL).to(equal(NSURL(string: "https://example.com/host")!))
                            }

                            it("should log a content view with the analytics service") {
                                tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: indexPath)

                                expect(analyticsService.lastContentViewName).to(equal("Host Event Form"))
                                expect(analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Actions))
                                expect(analyticsService.lastContentViewID).to(equal("Host Event Form"))
                            }
                        }
                    }
                }
            }
        }

        describe("ActionsController") {
            var subject: ActionsController!
            var urlProvider: URLProvider!
            var urlOpener: FakeURLOpener!
            var actionAlertService: FakeActionAlertService!
            var actionAlertControllerProvider: FakeActionAlertControllerProvider!
            var actionsTableViewCellPresenter: FakeActionsTableViewCellPresenter!
            var analyticsService: FakeAnalyticsService!
            var tabBarItemStylist: FakeTabBarItemStylist!
            var theme: Theme!

            var sharedContext: Dictionary<String, AnyObject>!
            var navigationController: UINavigationController!

            beforeEach {
                urlProvider = ActionsControllerFakeURLProvider()
                urlOpener = FakeURLOpener()
                actionAlertService = FakeActionAlertService()
                actionAlertControllerProvider = FakeActionAlertControllerProvider()
                actionsTableViewCellPresenter = FakeActionsTableViewCellPresenter()
                analyticsService = FakeAnalyticsService()
                tabBarItemStylist = FakeTabBarItemStylist()

                theme = ActionsControllerFakeTheme()

                subject = ActionsController(
                    urlProvider: urlProvider,
                    urlOpener: urlOpener,
                    actionAlertService: actionAlertService,
                    actionAlertControllerProvider: actionAlertControllerProvider,
                    actionsTableViewCellPresenter: actionsTableViewCellPresenter,
                    analyticsService: analyticsService,
                    tabBarItemStylist: tabBarItemStylist,
                    theme: theme)

                sharedContext = [
                    "subject": subject,
                    "urlOpener": urlOpener,
                    "analyticsService": analyticsService,
                    "actionsTableViewCellPresenter": actionsTableViewCellPresenter,
                    "theme": theme as! ActionsControllerFakeTheme
                ]

                navigationController = UINavigationController(rootViewController: subject)
                expect(subject.view).toNot(beNil())
            }

            context("when the view appears") {
                beforeEach {
                    subject.viewWillAppear(false)
                }

                it("has the correct title") {
                    expect(subject.title).to(equal("Actions"))
                }

                it("uses the tab bar item stylist to style its tab bar item") {
                    expect(tabBarItemStylist.lastReceivedTabBarItem).to(beIdenticalTo(subject.tabBarItem))

                    expect(tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "actionsTabBarIconInactive")))
                    expect(tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "actionsTabBarIcon")))
                }

                it("has a table view styled with the theme") {
                    expect(subject.view.subviews.count).to(equal(2))

                    let tableView = subject.view.subviews.first!
                    expect(tableView).to(beAnInstanceOf(UITableView.self))
                    expect(tableView.backgroundColor).to(equal(UIColor.orangeColor()))
                }

                it("initially hides the table view, and shows the loading spinner") {
                    let tableView = subject.view.subviews.first! as! UITableView
                    expect(tableView.hidden).to(equal(true));
                    expect(subject.view.subviews).to(contain(subject.loadingIndicatorView))
                    expect(subject.loadingIndicatorView.isAnimating()).to(equal(true))
                }

                it("sets the spinner up to hide when stopped") {
                    expect(subject.loadingIndicatorView.hidesWhenStopped).to(equal(true))
                }

                it("styles the spinner with the theme") {
                    expect(subject.loadingIndicatorView.color).to(equal(UIColor.greenColor()))
                }

                it("makes a request to the action alert service") {
                    expect(actionAlertService.fetchActionAlertsCalled).to(beTrue())
                }

                describe("when the request to the action alert service succeeds") {
                    context("and the service resolves its promise with more than zero action alerts") {
                        var tableView: UITableView!
                        let firstActionAlert = TestUtils.actionAlert("FTB!")
                        let secondActionAlert = TestUtils.actionAlert("Aha!")

                        beforeEach {
                            let actionAlerts = [ firstActionAlert, secondActionAlert ]

                            actionAlertService.lastReturnedActionAlertsPromise.resolve(actionAlerts)

                            tableView = subject.view.subviews.first! as! UITableView

                            sharedContext["tableView"] = tableView
                            sharedContext["numberOfSections"] = 3
                            sharedContext["actionAlerts"] = ActionAlertsWrapper(actionAlerts: actionAlerts)
                        }

                        it("has a section for campaign actions") {
                            let title = tableView.dataSource?.tableView!(tableView, titleForHeaderInSection: 0)
                            expect(title).to(equal("CAMPAIGN ACTION ALERTS"))
                        }

                        it("has a row per action alert, provided by the presenter") {
                            expect(tableView.numberOfRowsInSection(0)).to(equal(2))

                            let firstCell = tableView.dataSource!.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                            expect(actionsTableViewCellPresenter.lastActionAlert).to(equal(firstActionAlert))
                            expect(actionsTableViewCellPresenter.lastActionAlertTableView).to(beIdenticalTo(tableView))
                            expect(firstCell).to(beIdenticalTo(actionsTableViewCellPresenter.lastReturnedActionAlertTableViewCell))


                            let secondCell = tableView.dataSource!.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                            expect(actionsTableViewCellPresenter.lastActionAlert).to(equal(secondActionAlert))
                            expect(actionsTableViewCellPresenter.lastActionAlertTableView).to(beIdenticalTo(tableView))
                            expect(secondCell).to(beIdenticalTo(actionsTableViewCellPresenter.lastReturnedActionAlertTableViewCell))
                        }

                        describe("tapping on an action alert row") {
                            it("asks the action alert controller provider for a controller") {
                                tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

                                expect(actionAlertControllerProvider.lastActionAlertReceived).to(equal(firstActionAlert))
                            }

                            it("pushes the controller from the action alert controller provider onto the nav stack") {
                                expect(navigationController.topViewController).to(beIdenticalTo(subject))

                                tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

                                expect(navigationController.topViewController).to(beIdenticalTo(actionAlertControllerProvider.returnedController))
                            }
                        }

                        itBehavesLike("a controller that sets up the table view with the default rows correctly") {
                            sharedContext
                        }
                    }

                    context("and the service resolves its promise with zero action alerts") {
                        beforeEach {
                            actionAlertService.lastReturnedActionAlertsPromise.resolve([])
                            sharedContext["tableView"] = subject.view.subviews.first! as! UITableView
                            sharedContext["numberOfSections"] = 2
                            sharedContext["actionAlerts"] = ActionAlertsWrapper(actionAlerts: [])
                        }

                        itBehavesLike("a controller that sets up the table view with the default rows correctly") {
                            sharedContext
                        }
                    }
                }

                describe("when the request to the action alert service fails") {
                    beforeEach {
                        actionAlertService.lastReturnedActionAlertsPromise.reject(.InvalidJSON(jsonObject: "wat"))
                        sharedContext["tableView"] = subject.view.subviews.first! as! UITableView
                        sharedContext["numberOfSections"] = 2
                        sharedContext["actionAlerts"] = ActionAlertsWrapper(actionAlerts: [])
                    }

                    itBehavesLike("a controller that sets up the table view with the default rows correctly") {
                        sharedContext
                    }
                }
            }
        }
    }
}


private class ActionsControllerFakeURLProvider: FakeURLProvider {
    override func donateFormURL() -> NSURL {
        return NSURL(string: "https://example.com/donate")!
    }

    private override func hostEventFormURL() -> NSURL {
        return NSURL(string: "https://example.com/host")!
    }
}

private class ActionsControllerFakeTheme: FakeTheme {
    override func defaultBackgroundColor() -> UIColor { return UIColor.orangeColor() }
    override func defaultTableSectionHeaderBackgroundColor() -> UIColor { return UIColor.darkGrayColor() }
    override func defaultTableSectionHeaderTextColor() -> UIColor { return UIColor.lightGrayColor() }
    override func defaultTableSectionHeaderFont() -> UIFont { return UIFont.italicSystemFontOfSize(999) }
    override func defaultTableCellBackgroundColor() -> UIColor { return UIColor.yellowColor() }
    override func defaultSpinnerColor() -> UIColor { return UIColor.greenColor() }
}

private class FakeActionsTableViewCellPresenter: ActionsTableViewCellPresenter {
    var lastActionAlert: ActionAlert!
    var lastActionAlertTableView: UITableView!
    var lastReturnedActionAlertTableViewCell: UITableViewCell!
    func presentActionAlertTableViewCell(actionAlert: ActionAlert, tableView: UITableView) -> UITableViewCell {
        lastActionAlert = actionAlert
        lastActionAlertTableView = tableView
        lastReturnedActionAlertTableViewCell = UITableViewCell()
        return lastReturnedActionAlertTableViewCell
    }

    var lastActionActionAlerts: [ActionAlert]!
    var lastActionIndexPath: NSIndexPath!
    var lastActionTableView: UITableView!
    var lastReturnedActionTableViewCell: UITableViewCell!
    func presentActionTableViewCell(actionAlerts: [ActionAlert], indexPath: NSIndexPath, tableView: UITableView) -> UITableViewCell {
        lastActionActionAlerts = actionAlerts
        lastActionIndexPath = indexPath
        lastActionTableView = tableView
        lastReturnedActionTableViewCell = UITableViewCell()
        return lastReturnedActionTableViewCell
    }
}

private class ActionAlertsWrapper {
    let actionAlerts: [ActionAlert]
    init(actionAlerts: [ActionAlert]) {
        self.actionAlerts = actionAlerts
    }
}
