import UIKit

final class CalendarRecordListViewAdapter<Record: RecordProtocol>: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    private class RecordListHeaderView: UIView {
        init(text: String) {
            super.init(frame: .zero)
            backgroundColor = calendarViewStyle.recordListHeaderBackgroundColor

            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = text
            label.textColor = calendarViewStyle.recordListHeaderLabelTextColor
            label.font = calendarViewStyle.recordListHeaderLabelFont

            addSubview(label)
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError()
        }
    }

    private weak var view: CalendarRecordListView<Record>!
    private let delegate: AnyCalendarRecordListViewDelegate<Record>?
    private let dataSource: AnyCalendarRecordListViewDataSource<Record>?
    private let calendar: Calendar
    private let recordListHeaderDateFormatter: DateFormatter

    init(view: CalendarRecordListView<Record>, delegate: AnyCalendarRecordListViewDelegate<Record>?, dataSource: AnyCalendarRecordListViewDataSource<Record>?, calendar: Calendar) {
        self.view = view
        self.delegate = delegate
        self.dataSource = dataSource
        self.calendar = calendar

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateStyle = .full
        formatter.locale = calendar.locale
        recordListHeaderDateFormatter = formatter

        super.init()
        prepareDataSource()
    }

    // MARK: - Helpers

    private var displayDays: (first: Date, last: Date)?
    private var uniqueDays: [Date]?

    private func today() -> Date {
        return calendar.startOfDay(for: Date())
    }

    private func weekStartDay(of day: Date) -> Date {
        let week = calendar.component(.weekday, from: day)
        let offset = (7 + Const.weekStartDay - week) % 7
        guard let weekStartDay = calendar.date(byAdding: .weekday, value: offset, to: day) else {
            fatalError("failed to calculate date")
        }
        return calendar.startOfDay(for: weekStartDay)
    }

    private func weekendDay(of day: Date) -> Date {
        let week = calendar.component(.weekday, from: day)
        guard let weekendDay = calendar.date(byAdding: .weekday, value: 7 - week, to: day) else {
            fatalError("failed to calculate date")
        }
        return calendar.startOfDay(for: weekendDay)
    }

    private func prepareDataSource() {
        guard let dataSource = dataSource else {
            self.displayDays = nil
            self.uniqueDays = nil
            return
        }

        var uniqueDays = dataSource.calendarRecordListView(view, uniqueDaysOfRecordFor: calendar)
        if !uniqueDays.contains(today()) {
            uniqueDays.insert(today(), at: 0)
        }
        self.uniqueDays = uniqueDays

        let recordRange = dataSource.calendarRecordListView(view, recordRangeFor: calendar)
        let lastDate = weekendDay(of: today())

        let firstMeasureWeekStartDay = weekStartDay(of: recordRange.first)

        let thisWeekStartDay = weekStartDay(of: today())
        let offsetToDefaultStartDay = -(7 * (Const.displayWeeksForDefault(for: view.bounds.height) - 1))
        guard let startDayOfDefaultDisplayRange = calendar.date(byAdding: .day, value: offsetToDefaultStartDay, to: thisWeekStartDay) else {
            fatalError("failed to calculate date")
        }

        let firstDate = (startDayOfDefaultDisplayRange as NSDate).earlierDate(firstMeasureWeekStartDay)

        displayDays = (first: firstDate, last: lastDate)
    }

    func numberOfCalendarCells() -> Int {
        guard let displayDays = displayDays else { return 0 }
        let component = (calendar as NSCalendar).components(.day, from: displayDays.first, to: displayDays.last, options: [])
        guard let days = component.day else {
            assertionFailure("should not be nil")
            return 0
        }
        return days + 1
    }

    func monthOverlayViewPositions() -> [(indexPath: IndexPath, startRow: Int, numberOfRow: Int)] {
        guard let displayDays = displayDays else { return [] }

        var positions: [(indexPath: IndexPath, startRow: Int, numberOfRow: Int)] = []
        var currentRowOfCell = 0
        var currentIndexOfCell = 0
        var currentDate = displayDays.first

        while currentDate.compare(displayDays.last) != .orderedDescending {
            guard let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)?.count,
                let weeksInMonth = calendar.range(of: .weekOfMonth, in: .month, for: currentDate)?.count else {
                    fatalError("failed to get range of days or weeks")
            }
            let currentDay = calendar.component(.day, from: currentDate)
            let remainDaysInCurrentMonth = daysInMonth - currentDay + 1
            let currentWeek = calendar.component(.weekOfMonth, from: currentDate)
            let remainWeeksInCurrentMonth = weeksInMonth - currentWeek + 1

            let indexPath = IndexPath(item: currentIndexOfCell, section: 0)
            let position = (indexPath: indexPath, startRow: currentRowOfCell, numberOfRow: remainWeeksInCurrentMonth)
            positions.append(position)

            guard let firstDayOfNextMonth = calendar.date(byAdding: .day, value: remainDaysInCurrentMonth, to: currentDate) else {
                fatalError("failed to calculate date")
            }

            // increment to the first week of the next month
            let weekdayOfFirstDayOfNextMonth = calendar.component(.weekday, from: firstDayOfNextMonth)
            let weeksToNextMonth = (weekdayOfFirstDayOfNextMonth == 1) ? remainWeeksInCurrentMonth : remainWeeksInCurrentMonth - 1

            currentRowOfCell += weeksToNextMonth

            // increment to the first day of the next month
            currentIndexOfCell += remainDaysInCurrentMonth
            currentDate = firstDayOfNextMonth
        }

        return positions
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        view.scrollRecordListToTop()
        return false
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView is UITableView {
            view.shrink()
        } else if scrollView is UICollectionView {
            view.expand()
            view.showMonthOverlayView()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView is UICollectionView && decelerate == false {
            view.adjustCalendarViewContentOffsetToCell()
            view.hideMonthOverlayView()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView is UICollectionView {
            view.adjustCalendarViewContentOffsetToCell()
            view.hideMonthOverlayView()
        }
    }

    // MARK: - RecordListView (UITableView)

    private func recordOfRecordListCell(of indexPath: IndexPath) -> Record? {
        guard let dataSource = dataSource, let uniqueDays = uniqueDays else { return nil }
        let dayOfCell = uniqueDays[indexPath.section]
        let records = dataSource.calendarRecordListView(view, recordsOf: calendar.startOfDay(for: dayOfCell), for: calendar)
        let recordOfCell: Record? = (records.count == 0) ? nil : records[indexPath.row]
        return recordOfCell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return uniqueDays?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = dataSource, let uniqueDays = uniqueDays else { return 0 }
        let dayOfCell = uniqueDays[section]
        let records = dataSource.calendarRecordListView(view, recordsOf: calendar.startOfDay(for: dayOfCell), for: calendar)

        if section == 0 {
            // today section
            return (records.count == 0) ? 1 : records.count
        } else {
            return records.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let recordOfCell = recordOfRecordListCell(of: indexPath)
        return dataSource?.calendarRecordListView(view, heightForRecordListCellOf: recordOfCell) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataSource = dataSource, let uniqueDays = uniqueDays else {
            fatalError("shoule not be called when dataSource is nil")
        }
        let dayOfCell = uniqueDays[indexPath.section]
        let records = dataSource.calendarRecordListView(view, recordsOf: calendar.startOfDay(for: dayOfCell), for: calendar)
        let recordOfCell: Record? = (records.count == 0) ? nil : records[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.recordListCellIdentifier, for: indexPath)
        return dataSource.calendarRecordListView(view, configureRecordListCell: cell, with: recordOfCell, day: dayOfCell, calendar: calendar)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Const.recordListHeaderViewHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let uniqueDays = uniqueDays else { return nil }
        let text = recordListHeaderDateFormatter.string(from: uniqueDays[section])
        return RecordListHeaderView(text: text)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recordOfCell = recordOfRecordListCell(of: indexPath)
        delegate?.calendarRecordListView(view, didSelectRecordListCellOf: recordOfCell, for: calendar)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - CalendarView (UICollectionView)

    private func dayOfCalendarCell(of indexPath: IndexPath) -> Date {
        guard let displayDays = displayDays else {
            fatalError("should not be called before calculating displayDays")
        }

        guard let date = calendar.date(byAdding: .day, value: indexPath.item, to: displayDays.first) else {
            fatalError("failed to date culculation")
        }

        return calendar.startOfDay(for: date)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCalendarCells()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = dataSource else {
            fatalError("shoule not be called when dataSource is nil")
        }
        let dayOfCell = dayOfCalendarCell(of: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.calendarCellIdentifier, for: indexPath)
        let recordsForDay = dataSource.calendarRecordListView(view, recordsOf: dayOfCell, for: calendar)
        return dataSource.calendarRecordListView(view, configureCalendarCell: cell, with: recordsForDay, day: dayOfCell, calendar: calendar)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let dayOfCell = dayOfCalendarCell(of: indexPath)
        let year = calendar.component(.year, from: dayOfCell)
        let month = calendar.component(.month, from: dayOfCell)
        let weekday = calendar.component(.weekday, from: dayOfCell)
        let day = calendar.component(.day, from: dayOfCell)

        switch kind {
        case CalendarMonthOverlayLabelView.kind:
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CalendarMonthOverlayLabelView.identifier, for: indexPath) as? CalendarMonthOverlayLabelView else {
                fatalError("failed to dequeue reusable view of month overlay label view")
            }
            let label: String
            if calendar.locale?.languageCode == "ja" {
                label = "\(year)年 \(month)月"
            } else {
                let formatter = DateFormatter()
                formatter.locale = calendar.locale
                let monthSymbol = formatter.monthSymbols[month - 1]
                label = "\(monthSymbol) \(year)"
            }
            view.configure(with: label)
            return view
        case CalendarMonthOverlayBackgroundView.kind:
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CalendarMonthOverlayBackgroundView.identifier, for: indexPath) as? CalendarMonthOverlayBackgroundView else {
                fatalError("failed to dequeue reusable view of month overlay background view")
            }
            let topRowWeekday = (7 + weekday - Const.weekStartDay) % 7
            guard let daysInMonth = calendar.range(of: .day, in: .month, for: dayOfCell)?.count else {
                fatalError("failed to get range of days in month")
            }
            let remainDaysInMonth = daysInMonth - day + 1
            let bottomRowWeekday = 7 - (topRowWeekday + remainDaysInMonth) % 7
            let bottomRowOffset = (bottomRowWeekday == 7) ? 0 : bottomRowWeekday
            view.configure(topRowOffset: topRowWeekday, bottomRowOffset: bottomRowOffset)
            return view
        default:
            fatalError("kind not registered")
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dayOfCell = dayOfCalendarCell(of: indexPath)
        delegate?.calendarRecordListView(view, didSelectCalendarCellOf: dayOfCell, for: calendar)
        collectionView.deselectItem(at: indexPath, animated: true)
        if let uniqueDays = uniqueDays {
            if let section = uniqueDays.index(where: { self.calendar.startOfDay(for: $0) == dayOfCell }) {
                let indexPath = IndexPath(row: 0, section: section)
                view.scrollRecordList(to: indexPath)
            }
        }
    }
}
