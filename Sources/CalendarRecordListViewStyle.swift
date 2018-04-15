import UIKit

public struct CalendarRecordListViewStyle {
    public var weekdayLabelFont: UIFont = .boldSystemFont(ofSize: 12.0)
    public var weekdayLabelTextColorSunday = UIColor(red: 220.0 / 255.0, green: 0.0 / 255.0, blue: 16.0 / 255.0, alpha: 1.0)
    public var weekdayLabelTextColorWeekdays = UIColor(red: 71.0 / 255.0, green: 71.0 / 255.0, blue: 71.0 / 255.0, alpha: 1.0)
    public var weekdayLabelBackgroundColor = UIColor(red: 248.0 / 255.0, green: 248.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
    public var recordListHeaderLabelFont: UIFont = .boldSystemFont(ofSize: 12.0)
    public var recordListHeaderLabelTextColor = UIColor(red: 71.0 / 255.0, green: 71.0 / 255.0, blue: 71.0 / 255.0, alpha: 1.0)
    public var recordListHeaderBackgroundColor = UIColor(red: 248.0 / 255.0, green: 248.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
    public var recordListSeparatorColor = UIColor(red: 215.0 / 255.0, green: 227.0 / 255.0, blue: 223.0 / 255.0, alpha: 1.0)
    public var monthOverlayLabelFont: UIFont = .boldSystemFont(ofSize: 18.0)
    public var monthOverlayLabelTextColor = UIColor(red: 71.0 / 255.0, green: 71.0 / 255.0, blue: 71.0 / 255.0, alpha: 1.0)
    public var monthOverLayBackgroundColor = UIColor.white.withAlphaComponent(0.6)

    public static let `default` = CalendarRecordListViewStyle()
}
