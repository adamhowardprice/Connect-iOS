import Quick
import Nimble

@testable import Connect

class PushNotificationHandlerDispatcherSpec: QuickSpec {
    override func spec() {
        describe("PushNotificationHandlerDispatcher") {
            var subject: PushNotificationHandlerDispatcher!
            var handlerA: FakeUserNotificationHandler!
            var handlerB: FakeUserNotificationHandler!

            beforeEach {
                handlerA = FakeUserNotificationHandler()
                handlerB = FakeUserNotificationHandler()

                subject = PushNotificationHandlerDispatcher(handlers: [handlerA, handlerB])
            }

            describe("dispatching push notifications") {
                it("forwards the push notification to all the configured handlers") {
                    let userInfo: NotificationUserInfo = ["wat": "yo"]

                    subject.handleRemoteNotification(userInfo)

                    expect(handlerA.lastReceivedUserInfo["wat"]).to(beIdenticalTo(userInfo["wat"]))
                    expect(handlerB.lastReceivedUserInfo["wat"]).to(beIdenticalTo(userInfo["wat"]))
                }
            }
        }
    }
}

