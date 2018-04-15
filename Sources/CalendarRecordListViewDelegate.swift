import Foundation
import UIKit

public protocol CalendarRecordListViewDelegate: class {
    associatedtype Record: RecordProtocol
    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, didSelectCalendarCellOf day: Date, for calendar: Calendar)
    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, didSelectRecordListCellOf record: Record?, for calendar: Calendar)
}

public class AnyCalendarRecordListViewDelegate<Record: RecordProtocol> {
    private let _didSelectCalendarCellOfDay: (_ calendarRecordListView: CalendarRecordListView<Record>, _ day: Date, _ calendar: Calendar) -> ()
    private let _didSelectRecordListCellOfRecord: (_ calendarRecordListView: CalendarRecordListView<Record>, _ record: Record?, _ calendar: Calendar) -> ()

    required public init<T: CalendarRecordListViewDelegate>(_ delegate: T) where T.Record == Record {
        _didSelectCalendarCellOfDay = delegate.calendarRecordListView(_:didSelectCalendarCellOf:for:)
        _didSelectRecordListCellOfRecord = delegate.calendarRecordListView(_:didSelectRecordListCellOf:for:)
    }

    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, didSelectCalendarCellOf day: Date, for calendar: Calendar) {
        _didSelectCalendarCellOfDay(calendarRecordListView, day, calendar)
    }

    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, didSelectRecordListCellOf record: Record?, for calendar: Calendar) {
        _didSelectRecordListCellOfRecord(calendarRecordListView, record, calendar)
    }
}
