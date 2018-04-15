import UIKit

final class CalendarMonthOverlayBackgroundView: UICollectionReusableView {
    static let kind = "CalendarMonthOverlayBackgroundViewKind"
    static let identifier = "CalendarMonthOverlayBackgroundViewIdentifier"

    private var topRowOffset: Int = 0
    private var bottomRowOffset: Int = 0

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(calendarViewStyle.monthOverLayBackgroundColor.cgColor)
        let cellHeight = Const.calendarCellHeight
        let cellWidth = rect.width / 7
        let numberOfRows = rect.height / cellHeight

        let topRowOffsetX = cellWidth * CGFloat(topRowOffset)
        let bottomRowFillWidth = rect.width - cellWidth * CGFloat(bottomRowOffset)

        context.fill(CGRect(x: topRowOffsetX, y: 0, width: rect.width - topRowOffsetX, height: cellHeight))
        context.fill(CGRect(x: 0, y: cellHeight, width: rect.width, height: cellHeight * (numberOfRows - 2)))
        context.fill(CGRect(x: 0, y: cellHeight * (numberOfRows - 1), width: bottomRowFillWidth, height: cellHeight))
        context.strokePath()
    }

    func configure(topRowOffset: Int, bottomRowOffset: Int) {
        backgroundColor = .clear
        self.topRowOffset = topRowOffset
        self.bottomRowOffset = bottomRowOffset
        setNeedsDisplay()
    }
}
