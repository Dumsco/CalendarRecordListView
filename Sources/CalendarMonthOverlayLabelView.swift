import UIKit

final class CalendarMonthOverlayLabelView: UICollectionReusableView {
    static let kind = "CalendarMonthOverlayLabelViewKind"
    static let identifier = "CalendarMonthOverlayLabelViewIdentifier"

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.textColor = calendarViewStyle.monthOverlayLabelTextColor
        label.font = calendarViewStyle.monthOverlayLabelFont
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.alpha = 0
    }

    func configure(with text: String) {
        label.text = text
        UIView.animate(withDuration: Const.animateDurationForMonthOverlayLabelAppear, animations: {
            self.label.alpha = 1
        })
    }
}
