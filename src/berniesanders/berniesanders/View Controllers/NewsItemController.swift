import UIKit
import PureLayout

class NewsItemController: UIViewController {
    let newsItem: NewsItem
    let imageRepository: ImageRepository
    let dateFormatter: NSDateFormatter
    let analyticsService: AnalyticsService
    let urlOpener: URLOpener
    let urlAttributionPresenter: URLAttributionPresenter
    let theme: Theme

    private let containerView = UIView.newAutoLayoutView()
    private let scrollView = UIScrollView.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()
    let titleButton = UIButton.newAutoLayoutView()
    let bodyTextView = UITextView.newAutoLayoutView()
    let storyImageView = UIImageView.newAutoLayoutView()
    let attributionLabel = UILabel.newAutoLayoutView()
    let viewOriginalButton = UIButton.newAutoLayoutView()

    init(
        newsItem: NewsItem,
        imageRepository: ImageRepository,
        dateFormatter: NSDateFormatter,
        analyticsService: AnalyticsService,
        urlOpener: URLOpener,
        urlAttributionPresenter: URLAttributionPresenter,
        theme: Theme) {

        self.newsItem = newsItem
        self.imageRepository = imageRepository
        self.dateFormatter = dateFormatter
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.urlAttributionPresenter = urlAttributionPresenter
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        self.hidesBottomBarWhenPushed = true
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share")

        view.backgroundColor = self.theme.defaultBackgroundColor()

        view.addSubview(self.scrollView)
        scrollView.addSubview(self.containerView)
        containerView.addSubview(self.storyImageView)
        containerView.addSubview(self.dateLabel)
        containerView.addSubview(self.titleButton)
        containerView.addSubview(self.bodyTextView)
        containerView.addSubview(self.attributionLabel)
        containerView.addSubview(self.viewOriginalButton)

        dateLabel.text = self.dateFormatter.stringFromDate(self.newsItem.date)
        titleButton.setTitle(self.newsItem.title, forState: .Normal)
        titleButton.addTarget(self, action: "didTapViewOriginal", forControlEvents: .TouchUpInside)
        bodyTextView.text = self.newsItem.body

        attributionLabel.text = self.urlAttributionPresenter.attributionTextForURL(newsItem.URL)
        viewOriginalButton.setTitle(NSLocalizedString("NewsItem_viewOriginal", comment: ""), forState: .Normal)
        viewOriginalButton.addTarget(self, action: "didTapViewOriginal", forControlEvents: .TouchUpInside)

        setupConstraintsAndLayout()
        applyThemeToViews()

        if(self.newsItem.imageURL != nil) {
            self.imageRepository.fetchImageWithURL(self.newsItem.imageURL!).then({ (image) -> AnyObject! in
                self.storyImageView.image = image as? UIImage
                return image
                }, error: { (error) -> AnyObject! in
                    self.storyImageView.removeFromSuperview()
                    return error
            })
        } else {
            self.storyImageView.removeFromSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackCustomEventWithName("Tapped 'Back' on News Item", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.newsItem.URL.absoluteString])
    }

    // MARK: Actions

    func share() {
        self.analyticsService.trackCustomEventWithName("Tapped 'Share' on News Item", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.newsItem.URL.absoluteString])
        let activityVC = UIActivityViewController(activityItems: [newsItem.URL], applicationActivities: nil)

        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if(error != nil) {
                self.analyticsService.trackError(error!, context: "Failed to share News Item")
            } else {
                if(success == true) {
                    self.analyticsService.trackShareWithActivityType(activity!, contentName: self.newsItem.title, contentType: .NewsItem, id: self.newsItem.URL.absoluteString)
                } else {
                    self.analyticsService.trackCustomEventWithName("Cancelled share of News Item", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.newsItem.URL.absoluteString])
                }
            }
        }

        presentViewController(activityVC, animated: true, completion: nil)
    }

    func didTapViewOriginal() {
        analyticsService.trackCustomEventWithName("Tapped 'View Original' on News Item", customAttributes: [AnalyticsServiceConstants.contentIDKey: newsItem.URL.absoluteString])
        self.urlOpener.openURL(self.newsItem.URL)
    }

    // MARK: Private

    private func setupConstraintsAndLayout() {
        let screenBounds = UIScreen.mainScreen().bounds

        self.scrollView.contentSize.width = self.view.bounds.width
        self.scrollView.autoPinEdgesToSuperviewEdges()

        self.containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: ALEdge.Trailing)
        self.containerView.autoSetDimension(ALDimension.Width, toSize: screenBounds.width)

        self.storyImageView.contentMode = .ScaleAspectFill
        self.storyImageView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: ALEdge.Bottom)
        self.storyImageView.autoSetDimension(ALDimension.Height, toSize: screenBounds.height / 3, relation: NSLayoutRelation.LessThanOrEqual)

        NSLayoutConstraint.autoSetPriority(1000, forConstraints: { () -> Void in
            self.dateLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.storyImageView, withOffset: 8)
        })

        NSLayoutConstraint.autoSetPriority(500, forConstraints: { () -> Void in
            self.dateLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 8)
        })

        self.dateLabel.autoPinEdgeToSuperviewMargin(ALEdge.Leading)
        self.dateLabel.autoPinEdgeToSuperviewMargin(ALEdge.Trailing)
        self.dateLabel.autoSetDimension(ALDimension.Height, toSize: 20)

        let titleLabel = self.titleButton.titleLabel!
        titleLabel.numberOfLines = 3
        titleLabel.preferredMaxLayoutWidth = screenBounds.width - 8
        self.titleButton.contentHorizontalAlignment = .Left
        self.titleButton.autoPinEdgeToSuperviewMargin(.Leading)
        self.titleButton.autoPinEdgeToSuperviewMargin(.Trailing)
        self.titleButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.dateLabel)
        self.titleButton.autoSetDimension(.Height, toSize: 20, relation: NSLayoutRelation.GreaterThanOrEqual)

        self.bodyTextView.scrollEnabled = false
        self.bodyTextView.textContainerInset = UIEdgeInsetsZero
        self.bodyTextView.textContainer.lineFragmentPadding = 0;
        self.bodyTextView.editable = false

        self.bodyTextView.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.titleButton, withOffset: 16)
        self.bodyTextView.autoPinEdgeToSuperviewMargin(.Left)
        self.bodyTextView.autoPinEdgeToSuperviewMargin(.Right)

        self.attributionLabel.numberOfLines = 0
        self.attributionLabel.textAlignment = .Center
        self.attributionLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.bodyTextView, withOffset: 16)
        self.attributionLabel.autoPinEdgeToSuperviewMargin(.Left)
        self.attributionLabel.autoPinEdgeToSuperviewMargin(.Right)

        self.viewOriginalButton.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.attributionLabel, withOffset: 16)
        self.viewOriginalButton.autoPinEdgesToSuperviewMarginsExcludingEdge(.Top)
    }

    private func applyThemeToViews() {
        self.dateLabel.font = self.theme.newsItemDateFont()
        self.dateLabel.textColor = self.theme.newsItemDateColor()
        self.self.titleButton.titleLabel!.font = self.theme.newsItemTitleFont()
        self.titleButton.setTitleColor(self.theme.newsItemTitleColor(), forState: .Normal)
        self.bodyTextView.font = self.theme.newsItemBodyFont()
        self.bodyTextView.textColor = self.theme.newsItemBodyColor()
        self.attributionLabel.font = self.theme.attributionFont()
        self.attributionLabel.textColor = self.theme.attributionTextColor()
        self.viewOriginalButton.backgroundColor = self.theme.defaultButtonBackgroundColor()
        self.viewOriginalButton.setTitleColor(self.theme.defaultButtonTextColor(), forState: .Normal)
        self.viewOriginalButton.titleLabel!.font = self.theme.defaultButtonFont()
    }
}
