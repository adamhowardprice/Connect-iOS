import UIKit

class ElectionReminderController : UIViewController {

    private var theme: Theme

    init(theme: Theme) {
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("ElectionReminder_title", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        let closeBarButtonItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: #selector(ElectionReminderController.didTapCloseButton))
        navigationItem.leftBarButtonItem = closeBarButtonItem

        self.view.backgroundColor = theme.electionReminderBackgroundColor()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }


    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

}

// MARK: Actions

extension ElectionReminderController {
    func didTapCloseButton() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}