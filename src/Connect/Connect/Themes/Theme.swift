import UIKit


protocol Theme {
    // MARK: Global

    func defaultCurrentPageIndicatorTintColor() -> UIColor
    func defaultPageIndicatorTintColor() -> UIColor
    func defaultBackgroundColor() -> UIColor
    func contentBackgroundColor() -> UIColor
    func defaultSpinnerColor() -> UIColor
    func defaultButtonBackgroundColor() -> UIColor
    func defaultButtonTextColor() -> UIColor
    func defaultButtonDisabledTextColor() -> UIColor
    func defaultButtonFont() -> UIFont
    func defaultButtonBorderColor() -> UIColor
    func defaultDisclosureColor() -> UIColor
    func highlightDisclosureColor() -> UIColor
    func defaultTableSectionHeaderFont() -> UIFont
    func defaultTableSectionHeaderTextColor() -> UIColor
    func defaultTableSectionHeaderBackgroundColor() -> UIColor
    func defaultTableSeparatorColor() -> UIColor
    func defaultTableCellBackgroundColor() -> UIColor
    func defaultBodyTextLineHeight() -> CGFloat
    func fullWidthButtonBackgroundColor() -> UIColor
    func fullWidthRSVPButtonTextColor() -> UIColor
    func fullWidthRSVPButtonFont() -> UIFont

    // MARK: Tab Bar

    func tabBarTintColor() -> UIColor
    func tabBarActiveTextColor() -> UIColor
    func tabBarInactiveTextColor() -> UIColor
    func tabBarFont() -> UIFont

    // MARK: Navigation Bar

    func navigationBarBackgroundColor() -> UIColor
    func navigationBarTintColor() -> UIColor
    func navigationBarFont() -> UIFont
    func navigationBarTextColor() -> UIColor
    func navigationBarButtonFont() -> UIFont
    func navigationBarButtonTextColor() -> UIColor

    // MARK: News Feed

    func newsFeedBackgroundColor() -> UIColor
    func newsFeedTitleFont() -> UIFont
    func newsFeedTitleColor() -> UIColor
    func newsFeedExcerptFont() -> UIFont
    func newsFeedExcerptColor() -> UIColor
    func newsFeedDateFont() -> UIFont
    func newsFeedDateColor() -> UIColor
    func newsFeedVideoOverlayBackgroundColor() -> UIColor
    func newsFeedCellBorderColor() -> UIColor
    func newsFeedInfoButtonTintColor() -> UIColor

    // MARK: News Article detail screen

    func newsArticleDateFont() -> UIFont
    func newsArticleDateColor() -> UIColor
    func newsArticleTitleFont() -> UIFont
    func newsArticleTitleColor() -> UIColor
    func newsArticleBodyFont() -> UIFont
    func newsArticleBodyColor() -> UIColor

    // MARK: Video Article screen

    func videoDateFont() -> UIFont
    func videoDateColor() -> UIColor
    func videoTitleFont() -> UIFont
    func videoTitleColor() -> UIColor
    func videoDescriptionFont() -> UIFont
    func videoDescriptionColor() -> UIColor

    // MARK: Election Reminder screen

    func electionReminderBackgroundColor() -> UIColor
    func electionReminderEnterAddressLabelFont() -> UIFont
    func electionReminderYourPollingPlaceLabelFont() -> UIFont

    // MARK: Events screen

    func eventsListNameFont() -> UIFont
    func eventsListNameColor() -> UIColor
    func eventsListDateFont() -> UIFont
    func eventsListDateColor() -> UIColor
    func eventsSearchBarBackgroundColor() -> UIColor
    func eventsAddressTextColor() -> UIColor
    func eventsAddressPlaceholderTextColor() -> UIColor
    func eventsAddressBackgroundColor() -> UIColor
    func eventsAddressBorderColor() -> UIColor
    func eventsSearchBarFont() -> UIFont
    func eventsAddressCornerRadius() -> CGFloat
    func eventsAddressBorderWidth() -> CGFloat
    func eventsAddressTextOffset() -> CATransform3D
    func eventsInformationTextColor() -> UIColor
    func eventsNoResultsFont() -> UIFont
    func eventsCreateEventCTAFont() -> UIFont
    func eventsInstructionsFont() -> UIFont
    func eventsSubInstructionsFont() -> UIFont
    func eventsFilterLabelFont() -> UIFont
    func eventsFilterLabelTextColor() -> UIColor
    func eventsFilterButtonTextColor() -> UIColor
    func eventsErrorTextColor() -> UIColor
    func eventsErrorHeadingFont() -> UIFont
    func eventsErrorDetailFont() -> UIFont

    func eventSearchBarSearchBarTopPadding() -> CGFloat
    func eventSearchBarVerticalShift() -> CGFloat
    func eventSearchBarHorizontalPadding() -> CGFloat
    func eventSearchBarSearchBarHeight() -> CGFloat
    func eventSearchBarFilterLabelBottomPadding() -> CGFloat

    // MARK: Event screen

    func eventDirectionsButtonBackgroundColor() -> UIColor
    func eventDirectionsButtonTextColor() -> UIColor
    func eventDirectionsButtonFont() -> UIFont
    func eventNameFont() -> UIFont
    func eventNameColor() -> UIColor
    func eventStartDateFont() -> UIFont
    func eventStartDateColor() -> UIColor
    func eventAddressFont() -> UIFont
    func eventAddressColor() -> UIColor
    func eventDescriptionHeadingFont() -> UIFont
    func eventDescriptionHeadingColor() -> UIColor
    func eventDescriptionFont() -> UIFont
    func eventDescriptionColor() -> UIColor
    func eventBackgroundColor () -> UIColor

    // MARK: Settings

    func settingsTitleFont() -> UIFont
    func settingsTitleColor() -> UIColor
    func settingsAnalyticsFont() -> UIFont
    func settingsSwitchColor() -> UIColor

    // MARK: About

    func aboutButtonBackgroundColor() -> UIColor
    func aboutButtonTextColor() -> UIColor
    func aboutButtonFont() -> UIFont
    func aboutBodyTextFont() -> UIFont

    // MARK: Welcome

    func welcomeBackgroundColor() -> UIColor
    func welcomeHeaderFont() -> UIFont
    func welcomeMessageFont() -> UIFont
    func welcomeTextColor() -> UIColor
    func welcomeButtonBackgroundColor() -> UIColor
    func welcomeButtonTextColor() -> UIColor

    // MARK: Actions

    func actionsBackgroundColor() -> UIColor
    func actionsTitleFont() -> UIFont
    func actionsTitleTextColor() -> UIColor
    func actionsShortDescriptionFont() -> UIFont
    func actionsShortDescriptionTextColor() -> UIColor
    func actionsErrorMessageFont() -> UIFont
    func actionsErrorMessageTextColor() -> UIColor
    func actionsInfoButtonTintColor() -> UIColor
    func actionsShareButtonFont() -> UIFont
    func actionsShareButtonTextColor() -> UIColor

    // MARK: Action Alerts

    func markdownH1Font() -> UIFont
    func markdownH2Font() -> UIFont
    func markdownH3Font() -> UIFont
    func markdownH4Font() -> UIFont
    func markdownH5Font() -> UIFont
    func markdownH6Font() -> UIFont
    func markdownBodyFont() -> UIFont
    func markdownBodyTextColor() -> UIColor
    func markdownBodyLinkTextColor() -> UIColor
}
