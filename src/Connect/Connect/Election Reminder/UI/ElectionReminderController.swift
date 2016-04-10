import UIKit
import MapKit

class ElectionReminderController : UIViewController, UITextFieldDelegate, MKMapViewDelegate {

    let theme: Theme
    let upcomingElectionService: UpcomingElectionService

    private let topSectionSpacer = UIView.newAutoLayoutView()
    private let bottomSectionSpacer = UIView.newAutoLayoutView()
    private let enterYourAddressLabel: UILabel = UILabel.newAutoLayoutView()
    private let enterYourAddressField: UITextField = UITextField.newAutoLayoutView()
    private let mapView = MKMapView()

    private var election : UpcomingElection? {
        didSet {
            print(election?.state)
            mapView.hidden = (election == nil)
        }
    }

    init(theme: Theme, upcomingElectionService: UpcomingElectionService) {
        self.theme = theme
        self.upcomingElectionService = upcomingElectionService
        self.election = nil

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

        setupViews()
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

    func setupViews() {
        enterYourAddressLabel.text = NSLocalizedString("ElectionReminder_enterAddressLabelText", comment: "")
        enterYourAddressLabel.numberOfLines = 3
        enterYourAddressLabel.textAlignment = .Center

        enterYourAddressField.placeholder = NSLocalizedString("ElectionReminder_enterAddressLabelPlaceholder", comment: "")
        enterYourAddressField.textAlignment = .Center
        enterYourAddressField.borderStyle = .Bezel
        enterYourAddressField.delegate = self

        mapView.delegate = self
        mapView.hidden = true
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
        view.addSubview(mapView)
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

        mapView.autoPinEdge(.Top, toEdge: .Bottom, ofView: enterYourAddressField, withOffset: 15)
        mapView.autoPinEdgeToSuperviewEdge(.Left, withInset: 20, relation: .Equal)
        mapView.autoPinEdgeToSuperviewEdge(.Right, withInset: 20, relation: .Equal)
        mapView.autoSetDimension(.Height, toSize: 200)

        bottomSectionSpacer.autoPinEdge(.Top, toEdge: .Bottom, ofView: mapView, withOffset: 15)
        bottomSectionSpacer.autoPinEdgeToSuperviewEdge(.Left)
        bottomSectionSpacer.autoPinEdgeToSuperviewEdge(.Right)
        bottomSectionSpacer.autoSetDimension(.Height, toSize: view.bounds.height / 10)
    }

    // MARK: UITextFieldDelegate

    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text?.characters.count == 0) {
            return
        }

        upcomingElectionService.fetchUpcomingElection(textField.text!).then { upcomingElection in
            self.election = upcomingElection
        }
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