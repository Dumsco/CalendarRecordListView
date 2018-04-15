import Foundation

struct Const {
    private init() {}
    static let weekStartDay: Int = 1 // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
    static let weekdayHeaderViewHeight: CGFloat = 30
    static let recordListHeaderViewHeight: CGFloat = 24.0
    static let calendarCellHeight: CGFloat = 60
    static let animateDurationForShrink: TimeInterval = 0.4
    static let animateDurationForExpand: TimeInterval = 0.5
    static let animateDurationForMonthOverlayLabelAppear: TimeInterval = 0.1
    static let displayWeeksForShrinked: Int = 2
    static let calendarCellIdentifier = "CalendarCellIdentifier"
    static let recordListCellIdentifier = "RecordListCellIdentifier"

    private static let thresholdHeightForShrink: CGFloat = 455
    static func displayWeeksForDefault(for height: CGFloat) -> Int {
        if height > thresholdHeightForShrink {
            return 5
        } else {
            return 3
        }
    }

    static func shouldShrinkCalendar(for height: CGFloat) -> Bool {
        return height > thresholdHeightForShrink
    }
}
