import UIKit
import MapKit

class ElectionReminderController : UIViewController, UITextFieldDelegate, MKMapViewDelegate {

    let theme: Theme
    let upcomingElectionService: UpcomingElectionService

    private let topSectionSpacer = UIView.newAutoLayoutView()
    private let enterYourAddressLabel: UILabel = UILabel.newAutoLayoutView()
    private let enterYourAddressField: UITextField = UITextField.newAutoLayoutView()
    private let yourPollingPlaceLabel: UILabel = UILabel.newAutoLayoutView()
    private let notifButton: UIButton = UIButton.newAutoLayoutView()
    private let mapView = MKMapView()
    private let geocoder = CLGeocoder()
    private var userAddress : String

    private var election : UpcomingElection? {
        didSet {
            print(election?.state)
            updateMap()
        }
    }

    init(theme: Theme, upcomingElectionService: UpcomingElectionService) {
        self.theme = theme
        self.upcomingElectionService = upcomingElectionService
        self.election = nil
        self.userAddress = ""

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

        yourPollingPlaceLabel.numberOfLines = 0
        yourPollingPlaceLabel.textAlignment = .Center

        notifButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        notifButton.addTarget(self, action: #selector(ElectionReminderController.didTapNotifButton), forControlEvents: .TouchUpInside)

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
        enterYourAddressLabel.backgroundColor = theme.electionReminderBackgroundColor()
        enterYourAddressLabel.font = theme.electionReminderEnterAddressLabelFont()
        yourPollingPlaceLabel.font = theme.electionReminderYourPollingPlaceLabelFont()
    }

    func addSubviews() {
        view.addSubview(topSectionSpacer)
        view.addSubview(enterYourAddressLabel)
        view.addSubview(enterYourAddressField)
        view.addSubview(yourPollingPlaceLabel)
        view.addSubview(notifButton)
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

        yourPollingPlaceLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: mapView, withOffset: 15)
        yourPollingPlaceLabel.autoPinEdgeToSuperviewEdge(.Left)
        yourPollingPlaceLabel.autoPinEdgeToSuperviewEdge(.Right)
        yourPollingPlaceLabel.autoSetDimension(.Height, toSize: 50)

        notifButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: yourPollingPlaceLabel, withOffset: 15)
        notifButton.autoPinEdgeToSuperviewEdge(.Left)
        notifButton.autoPinEdgeToSuperviewEdge(.Right)
        notifButton.autoSetDimension(.Height, toSize: 60)
    }

    private func updateMap() {

        mapView.hidden = (election == nil)

        if let electionAddressString: String = String(format: "%@ %@ %@", election!.address, election!.city, election!.state) {
            geocoder.geocodeAddressString(electionAddressString) { elecPlacemarks, elecError in
                if (elecError != nil) {
                    return
                }

                if let place = (elecPlacemarks?.first)! as CLPlacemark? {

                    let addressPlacemark = MKPlacemark(coordinate: place.location!.coordinate, addressDictionary: nil)

                    self.mapView.addAnnotation(addressPlacemark)
                    let region = MKCoordinateRegionMake(place.location!.coordinate, MKCoordinateSpanMake(0.005, 0.005))
                    self.mapView.setRegion(region, animated: true)
                }
            }

            yourPollingPlaceLabel.text = String(format: "Your Polling Place is: %@\n%@", election!.name, electionAddressString)
            notifButton.hidden = false
            notifButton.setTitle("Set A Reminder To Vote!", forState: .Normal)
            view.layoutIfNeeded()
        }
    }

    // MARK: UITextFieldDelegate

    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text?.characters.count == 0) {
            return
        }

        userAddress = textField.text!

        upcomingElectionService.fetchUpcomingElection(userAddress).then { upcomingElection in
            self.election = upcomingElection
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    // MARK: MKMapViewDelegate

    func mapViewDidFinishLoadingMap(mapView: MKMapView) {

    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinColor = .Purple
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}

// MARK: Actions

extension ElectionReminderController {
    func didTapCloseButton() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func didTapNotifButton() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "NotifSet")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}