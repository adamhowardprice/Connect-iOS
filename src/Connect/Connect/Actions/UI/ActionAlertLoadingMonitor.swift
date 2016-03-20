import UIKit

protocol ActionAlertLoadingMonitor {
    func waitUntilWebViewsHaveLoaded(webViews: [UIWebView], completionHandler: () -> ())
}

class StockActionAlertLoadingMonitor: ActionAlertLoadingMonitor {
    func waitUntilWebViewsHaveLoaded(webViews: [UIWebView], completionHandler: () -> ()) {
        checkForLoaded(webViews, completionHandler: completionHandler)
    }

    private func checkForLoaded(webViews: [UIWebView], completionHandler: () -> ()) {
        var webViewsLoaded = 0

        for webView in webViews {
            let resultString = webView.stringByEvaluatingJavaScriptFromString("document.documentElement.getElementsByTagName('iframe').length > 0 || document.documentElement.getElementsByTagName('script').length == 0")

            if resultString == "true" {
                webViewsLoaded += 1
            }
        }

        if webViewsLoaded == webViews.count {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2000000000), dispatch_get_main_queue(), {
                completionHandler()
            })
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200000000), dispatch_get_main_queue(), {
                self.checkForLoaded(webViews, completionHandler: completionHandler)
            })
        }
    }
}