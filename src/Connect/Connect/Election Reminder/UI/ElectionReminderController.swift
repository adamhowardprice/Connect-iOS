import UIKit

class ElectionReminderController : UIViewController, UITextFieldDelegate {

    let theme: Theme

    private let topSectionSpacer = UIView.newAutoLayoutView()
    private let bottomSectionSpacer = UIView.newAutoLayoutView()
    private let enterYourAddressLabel: UILabel = UILabel.newAutoLayoutView()
    private let enterYourAddressField: UITextField = UITextField.newAutoLayoutView()

    init(theme: Theme) {
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        edgesForExtendedLayout = .None

        title = NSLocalizedString("ElectionReminder_title", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        let closeBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("ElectionReminder_navBarCloseButtonTitle", comment: ""),
            style: .Plain,
            target: self,
            action: #selector(ElectionReminderController.didTapCloseButton))
        navigationItem.leftBarButtonItem = closeBarButtonItem

        setupLabels()
        applyTheme()
        addSubviews()
        setupConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }


    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        enterYourAddressLabel.preferredMaxLayoutWidth = enterYourAddressLabel.bounds.width
        view.layoutIfNeeded()
    }

    // MARK: Private

    func setupLabels() {
        enterYourAddressLabel.text = NSLocalizedString("ElectionReminder_enterAddressLabelText", comment: "")
        enterYourAddressLabel.numberOfLines = 3
        enterYourAddressLabel.textAlignment = .Center

        enterYourAddressField.placeholder = NSLocalizedString("ElectionReminder_enterAddressLabelPlaceholder", comment: "")
        enterYourAddressField.textAlignment = .Center
        enterYourAddressField.borderStyle = .Bezel
        enterYourAddressField.delegate = self
    }

    func applyTheme() {
        view.backgroundColor = theme.electionReminderBackgroundColor()
        topSectionSpacer.backgroundColor = theme.electionReminderBackgroundColor()
        bottomSectionSpacer.backgroundColor = theme.electionReminderBackgroundColor()
        enterYourAddressLabel.backgroundColor = theme.electionReminderBackgroundColor()
        enterYourAddressLabel.font = theme.electionReminderEnterAddressLabelFont()
    }

    func addSubviews() {
        view.addSubview(topSectionSpacer)
        view.addSubview(bottomSectionSpacer)
        view.addSubview(enterYourAddressLabel)
        view.addSubview(enterYourAddressField)
    }

    func setupConstraints() {
        topSectionSpacer.autoPinEdgeToSuperviewEdge(.Top)
        topSectionSpacer.autoPinEdgeToSuperviewEdge(.Left)
        topSectionSpacer.autoPinEdgeToSuperviewEdge(.Right)
        topSectionSpacer.autoSetDimension(.Height, toSize: 15)

        enterYourAddressLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: topSectionSpacer)
        enterYourAddressLabel.autoPinEdgeToSuperviewEdge(.Left)
        enterYourAddressLabel.autoPinEdgeToSuperviewEdge(.Right)
        let addressLabelHeight = enterYourAddressLabel.sizeThatFits(CGSizeMake(view.bounds.width, CGFloat.max)).height
        enterYourAddressLabel.autoSetDimension(.Height, toSize: addressLabelHeight)

        enterYourAddressField.autoPinEdge(.Top, toEdge: .Bottom, ofView: enterYourAddressLabel, withOffset: 15)
        enterYourAddressField.autoPinEdgeToSuperviewEdge(.Left, withInset: 40, relation: .Equal)
        enterYourAddressField.autoPinEdgeToSuperviewEdge(.Right, withInset: 40, relation: .Equal)
        enterYourAddressField.autoSetDimension(.Width, toSize: view.bounds.width - 80)
        enterYourAddressField.autoSetDimension(.Height, toSize: 50)

        bottomSectionSpacer.autoPinEdge(.Top, toEdge: .Bottom, ofView: enterYourAddressField, withOffset: 15)
        bottomSectionSpacer.autoPinEdgeToSuperviewEdge(.Left)
        bottomSectionSpacer.autoPinEdgeToSuperviewEdge(.Right)
        bottomSectionSpacer.autoSetDimension(.Height, toSize: view.bounds.height / 10)
    }

    // MARK: UITextFieldDelegate

    func textFieldDidEndEditing(textField: UITextField) {
        print("Finish")
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

// MARK: Actions

extension ElectionReminderController {
    func didTapCloseButton() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}