import UIKit

var calendarViewStyle: CalendarRecordListViewStyle = .default

public class CalendarRecordListView<Record: RecordProtocol>: UIView {
    private let calendarViewLayout: CalendarViewLayout<Record>
    private let calendarView: UICollectionView
    private let calendarViewHeightConstraint: NSLayoutConstraint
    private let recordListView = UITableView(frame: .zero, style: .plain)
    private var weekDayLabels: [UILabel] = []

    public required init(style: CalendarRecordListViewStyle) {
        calendarViewStyle = style
        let calendarViewLayout = CalendarViewLayout<Record>(calendarCellHeight: Const.calendarCellHeight)
        let calendarView = UICollectionView(frame: .zero, collectionViewLayout: calendarViewLayout)
        self.calendarView = calendarView
        self.calendarViewLayout = calendarViewLayout
        calendarViewHeightConstraint = calendarView.heightAnchor.constraint(equalToConstant: 0)
        calendarViewHeightConstraint.isActive = true

        super.init(frame: .zero)

        let weekDayLabels: [UILabel] = (0 ..< 7).map { index in
            let label = UILabel()
            let isSunday = (index + Const.weekStartDay) % 7 == 1
            label.textColor = isSunday ? style.weekdayLabelTextColorSunday : style.weekdayLabelTextColorWeekdays
            label.font = style.weekdayLabelFont
            label.textAlignment = .center
            label.backgroundColor = style.weekdayLabelBackgroundColor
            return label
        }
        self.weekDayLabels = weekDayLabels
        let headerStackView = UIStackView(arrangedSubviews: weekDayLabels)
        headerStackView.axis = .horizontal
        headerStackView.distribution = .fillEqually

        addSubview(headerStackView)
        addSubview(calendarView)
        addSubview(recordListView)

        backgroundColor = .white
        calendarView.backgroundColor = .white
        calendarView.alwaysBounceVertical = true
        calendarView.showsVerticalScrollIndicator = false
        recordListView.backgroundColor = .white
        recordListView.separatorColor = style.recordListSeparatorColor
        recordListView.alwaysBounceVertical = true
        recordListView.showsVerticalScrollIndicator = false

        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        recordListView.translatesAutoresizingMaskIntoConstraints = false

        headerStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        headerStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        headerStackView.heightAnchor.constraint(equalToConstant: Const.weekdayHeaderViewHeight).isActive = true

        calendarView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor).isActive = true
        calendarView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        calendarView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        recordListView.topAnchor.constraint(equalTo: calendarView.bottomAnchor).isActive = true
        recordListView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        recordListView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        recordListView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        calendarView.register(CalendarMonthOverlayLabelView.self, forSupplementaryViewOfKind: CalendarMonthOverlayLabelView.kind, withReuseIdentifier: CalendarMonthOverlayLabelView.identifier)
        calendarView.register(CalendarMonthOverlayBackgroundView.self, forSupplementaryViewOfKind: CalendarMonthOverlayBackgroundView.kind, withReuseIdentifier: CalendarMonthOverlayBackgroundView.identifier)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    public override func layoutSubviews() {
        if calendarViewHeightConstraint.constant == 0 {
            calendarViewHeightConstraint.constant = CGFloat(Const.displayWeeksForDefault(for: bounds.height)) * Const.calendarCellHeight
        }
        super.layoutSubviews()
    }

    public func registerCalendarCell<T: UICollectionViewCell>(_ cellClass: T.Type, nib: UINib? = nil) {
        if let nib = nib {
            calendarView.register(nib, forCellWithReuseIdentifier: Const.calendarCellIdentifier)
        } else {
            calendarView.register(T.self, forCellWithReuseIdentifier: Const.calendarCellIdentifier)
        }
    }

    public func registerRecordListCell<T: UITableViewCell>(_ cellClass: T.Type, nib: UINib? = nil) {
        if let nib = nib {
            recordListView.register(nib, forCellReuseIdentifier: Const.recordListCellIdentifier)
        } else {
            recordListView.register(T.self, forCellReuseIdentifier: Const.recordListCellIdentifier)
        }
    }

    public var locale: Locale = .current {
        didSet {
            reloadData()
        }
    }

    public var timeZone: TimeZone = .current {
        didSet {
            reloadData()
        }
    }

    private var calendar: Calendar = .init(identifier: .gregorian)

    public weak var delegate: AnyCalendarRecordListViewDelegate<Record>? {
        didSet {
            reloadData()
        }
    }
    public weak var dataSource: AnyCalendarRecordListViewDataSource<Record>? {
        didSet {
            reloadData()
        }
    }
    private var adapter: CalendarRecordListViewAdapter<Record>?

    private func configureWeekdayLabels() {
        let formatter = DateFormatter()
        formatter.locale = locale
        if let weekDaySymbols = formatter.shortWeekdaySymbols {
            for (index, label) in weekDayLabels.enumerated() {
                label.text = weekDaySymbols[index]
            }
        }
    }

    public func reloadData() {
        calendar.locale = locale
        calendar.timeZone = timeZone
        configureWeekdayLabels()

        let adapter = CalendarRecordListViewAdapter(view: self, delegate: delegate, dataSource: dataSource, calendar: calendar)
        self.adapter = adapter
        calendarView.delegate = adapter
        calendarView.dataSource = adapter
        recordListView.delegate = adapter
        recordListView.dataSource = adapter
        calendarViewLayout.adapter = adapter
        calendarView.reloadData()
        recordListView.reloadData()
        calendarView.collectionViewLayout.invalidateLayout()
    }

    public func scrollCalendarToToday() {
        guard let adapter = adapter else { return }
        calendarView.layoutIfNeeded()
        let numberOfCalendarCells = adapter.numberOfCalendarCells()
        let indexPath = IndexPath(item: numberOfCalendarCells - 1, section: 0)
        calendarView.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }

    func shrink() {
        if !Const.shouldShrinkCalendar(for: bounds.height) { return }
        let shrinkedHeight = Const.calendarCellHeight * CGFloat(Const.displayWeeksForShrinked)
        if calendarViewHeightConstraint.constant == shrinkedHeight { return }

        calendarViewHeightConstraint.constant = shrinkedHeight
        let visibleItemIndexPaths = calendarView.indexPathsForVisibleItems
        UIView.animate(withDuration: Const.animateDurationForShrink, animations: {
            self.layoutIfNeeded()
        }, completion: { _ in
            if let indexPath = visibleItemIndexPaths.sorted().last {
                self.calendarView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
        })
    }

    func expand() {
        if !Const.shouldShrinkCalendar(for: bounds.height) { return }
        let expandedHeight = Const.calendarCellHeight * CGFloat(Const.displayWeeksForDefault(for: bounds.height))
        if calendarViewHeightConstraint.constant == expandedHeight { return }

        calendarViewHeightConstraint.constant = expandedHeight
        UIView.animate(withDuration: Const.animateDurationForExpand) {
            self.layoutIfNeeded()
        }
    }

    func scrollRecordListToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        recordListView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    func showMonthOverlayView() {
        calendarViewLayout.monthOverlayViewVisible = true
        calendarViewLayout.invalidateLayout()
    }

    func hideMonthOverlayView() {
        calendarViewLayout.monthOverlayViewVisible = false
        calendarViewLayout.invalidateLayout()
    }

    func adjustCalendarViewContentOffsetToCell() {
        let currentOffsetY = calendarView.contentOffset.y
        let decisionPoint = CGPoint(x: 0, y: currentOffsetY + Const.calendarCellHeight / 2)
        if let indexPath = calendarView.indexPathForItem(at: decisionPoint) {
            calendarView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }

    func scrollRecordList(to indexPath: IndexPath) {
        recordListView.scrollToRow(at: indexPath, at: .top, animated: false)
    }
}
