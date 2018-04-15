import UIKit

final class CalendarViewLayout<Record: RecordProtocol>: UICollectionViewLayout {
    var adapter: CalendarRecordListViewAdapter<Record>?
    private let calendarCellHeight: CGFloat

    init(calendarCellHeight: CGFloat) {
        self.calendarCellHeight = calendarCellHeight
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

    var monthOverlayViewVisible: Bool = false

    private var itemSize: CGSize = .zero
    private var cellAttributes: [UICollectionViewLayoutAttributes]?
    private var monthOverlayViewAttributes: [(startRow: Int, numberOfRows: Int, background: UICollectionViewLayoutAttributes, label: UICollectionViewLayoutAttributes)]?

    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView, let adapter = adapter else {
            return .zero
        }
        let width = collectionView.bounds.width
        let height = CGFloat(adapter.numberOfCalendarCells() / 7) * calendarCellHeight
        return CGSize(width: width, height: height)
    }

    override func prepare() {
        guard let collectionView = collectionView, let adapter = adapter else { return }
        let contentWidth = collectionView.bounds.width
        let itemSize = CGSize(width: contentWidth / 7, height: calendarCellHeight)
        self.itemSize = itemSize

        cellAttributes = (0 ..< adapter.numberOfCalendarCells()).map { index in
            let indexPath = IndexPath(item: index, section: 0)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let cellRow = CGFloat(index / 7)
            let x = round(CGFloat(index % 7) * itemSize.width)
            let y = cellRow * itemSize.height
            attribute.frame = CGRect(origin: CGPoint(x: x, y: y), size: itemSize)
            return attribute
        }

        var monthOverlayViewAttributes: [(startRow: Int, numberOfRows: Int, background: UICollectionViewLayoutAttributes, label: UICollectionViewLayoutAttributes)] = []
        for (indexPath, startRow, numberOfRows) in adapter.monthOverlayViewPositions() {
            let origin = CGPoint(x: 0, y: itemSize.height * CGFloat(startRow))
            let size = CGSize(width: contentWidth, height: itemSize.height * CGFloat(numberOfRows))
            let frame = CGRect(origin: origin, size: size)
            let attributeForBackground = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CalendarMonthOverlayLabelView.kind, with: indexPath)
            let attributeForLabel = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CalendarMonthOverlayBackgroundView.kind, with: indexPath)
            attributeForBackground.frame = frame
            attributeForBackground.zIndex = 2
            attributeForLabel.frame = frame
            attributeForLabel.zIndex = 1
            monthOverlayViewAttributes.append((startRow: startRow, numberOfRows: numberOfRows, background: attributeForBackground, label: attributeForLabel))
        }

        self.monthOverlayViewAttributes = monthOverlayViewAttributes
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let adapter = adapter,
            let cellAttributes = cellAttributes,
            let monthOverlayViewAttributes = monthOverlayViewAttributes else {
                return nil
        }
        var attributes: [UICollectionViewLayoutAttributes] = []

        let minY = max(rect.minY, 0)
        let topRow = Int(floor(minY / itemSize.height))
        let displayingRows = Int(ceil(rect.height / itemSize.height))
        let bottomRow = min(topRow + displayingRows, adapter.numberOfCalendarCells() / 7)

        if topRow > bottomRow {
            return nil
        }

        for index in topRow * 7 ..< bottomRow * 7 {
            attributes.append(cellAttributes[index])
        }

        if monthOverlayViewVisible {
            let displayRange = Range(topRow..<bottomRow)

            for monthOverlayView in monthOverlayViewAttributes {
                let overlayViewRange = Range(monthOverlayView.startRow..<(monthOverlayView.startRow + monthOverlayView.numberOfRows))
                if overlayViewRange.overlaps(displayRange) {
                    attributes.append(monthOverlayView.background)
                    attributes.append(monthOverlayView.label)
                }
            }
        }

        return attributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellAttributes?[indexPath.item]
    }
}
