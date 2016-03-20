import UIKit

class ActionAlertCell: UICollectionViewCell {
    let scrollView = UIScrollView.newAutoLayoutView()
    let titleLabel = UILabel.newAutoLayoutView()
    let webviewContainer = UIView.newAutoLayoutView()

    private let containerView = UIView.newAutoLayoutView()
    private let spacerView = UIView.newAutoLayoutView()

    private var webviewContainerHeightConstraint: NSLayoutConstraint?
    var webViewHeight: CGFloat {
        set {
            webviewContainerHeightConstraint!.constant = newValue
        }

        get {
            return webviewContainerHeightConstraint!.constant
        }
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.numberOfLines = 3
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = true
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)

        contentView.addSubview(scrollView)

        scrollView.addSubview(titleLabel)
        scrollView.addSubview(webviewContainer)
        scrollView.addSubview(spacerView)

        setupConstraints()
    }

    private func setupConstraints() {
        scrollView.autoPinEdgeToSuperviewEdge(.Top)
        scrollView.autoPinEdgeToSuperviewEdge(.Bottom)
        scrollView.autoPinEdgeToSuperviewEdge(.Left)
        scrollView.autoPinEdgeToSuperviewEdge(.Right)

        titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 45)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 5)
        titleLabel.autoMatchDimension(.Width, toDimension: .Width, ofView: scrollView, withOffset: 5)

        webviewContainer.autoPinEdgeToSuperviewEdge(.Top, withInset: 135)
        webviewContainer.autoPinEdgeToSuperviewEdge(.Left)
        webviewContainer.autoMatchDimension(.Width, toDimension: .Width, ofView: scrollView)
        webviewContainerHeightConstraint = webviewContainer.autoSetDimension(.Height, toSize: 0)

        spacerView.autoPinEdge(.Top, toEdge: .Bottom, ofView: webviewContainer)
        spacerView.autoPinEdgeToSuperviewEdge(.Left)
        spacerView.autoMatchDimension(.Width, toDimension: .Width, ofView: scrollView)
        spacerView.autoPinEdgeToSuperviewEdge(.Bottom)
    }
}