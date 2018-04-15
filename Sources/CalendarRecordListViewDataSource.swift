import Foundation
import UIKit

public protocol CalendarRecordListViewDataSource: class {
    associatedtype Record: RecordProtocol
    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, recordRangeFor calendar: Calendar) -> (first: Date, last: Date)
    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, uniqueDaysOfRecordFor calendar: Calendar) -> [Date]
    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, recordsOf day: Date, for calendar: Calendar) -> [Record]
    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, heightForRecordListCellOf record: Record?) -> CGFloat
    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, configureCalendarCell cell: UICollectionViewCell, with records: [Record], day: Date, calendar: Calendar) -> UICollectionViewCell
    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, configureRecordListCell cell: UITableViewCell, with record: Record?, day: Date, calendar: Calendar) -> UITableViewCell
}

public class AnyCalendarRecordListViewDataSource<Record: RecordProtocol> {
    private let _recordRange: (_ calendarRecordListView: CalendarRecordListView<Record>, _ calendar: Calendar) -> (first: Date, last: Date)
    private let _uniqueDaysOfRecord: (_ calendarRecordListView: CalendarRecordListView<Record>, _ calendar: Calendar) -> [Date]
    private let _record: (_ calendarRecordListView: CalendarRecordListView<Record>, _ day: Date, _ calendar: Calendar) -> [Record]
    private let _heightForRecordListCell: (_ calendarRecordListView: CalendarRecordListView<Record>, _ record: Record?) -> CGFloat
    private let _configureCalendarCell: (_ calendarRecordListView: CalendarRecordListView<Record>, _ cell: UICollectionViewCell, _ records: [Record], _ day: Date, _ calendar: Calendar) -> UICollectionViewCell
    private let _configureRecordListCell: (_ calendarRecordListView: CalendarRecordListView<Record>, _ cell: UITableViewCell, _ record: Record?, _ day: Date, _ calendar: Calendar) -> UITableViewCell

    required public init<T: CalendarRecordListViewDataSource>(_ dataSource: T) where T.Record == Record {
        _recordRange = dataSource.calendarRecordListView(_:recordRangeFor:)
        _uniqueDaysOfRecord = dataSource.calendarRecordListView(_:uniqueDaysOfRecordFor:)
        _record = dataSource.calendarRecordListView(_:recordsOf:for:)
        _heightForRecordListCell = dataSource.calendarRecordListView(_:heightForRecordListCellOf:)
        _configureCalendarCell = dataSource.calendarRecordListView(_:configureCalendarCell:with:day:calendar:)
        _configureRecordListCell = dataSource.calendarRecordListView(_:configureRecordListCell:with:day:calendar:)
    }

    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, recordRangeFor calendar: Calendar) -> (first: Date, last: Date) {
        return _recordRange(calendarRecordListView, calendar)
    }

    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, uniqueDaysOfRecordFor calendar: Calendar) -> [Date] {
        return _uniqueDaysOfRecord(calendarRecordListView, calendar)
    }

    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, recordsOf day: Date, for calendar: Calendar) -> [Record] {
        return _record(calendarRecordListView, day, calendar)
    }

    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, heightForRecordListCellOf record: Record?) -> CGFloat {
        return _heightForRecordListCell(calendarRecordListView, record)
    }

    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, configureCalendarCell cell: UICollectionViewCell, with records: [Record], day: Date, calendar: Calendar) -> UICollectionViewCell {
        return _configureCalendarCell(calendarRecordListView, cell, records, day, calendar)
    }

    func calendarRecordListView(_ calendarRecordListView: CalendarRecordListView<Record>, configureRecordListCell cell: UITableViewCell, with record: Record?, day: Date, calendar: Calendar) -> UITableViewCell {
        return _configureRecordListCell(calendarRecordListView, cell, record, day, calendar)
    }
}
