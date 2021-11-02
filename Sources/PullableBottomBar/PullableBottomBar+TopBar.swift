import UIKit

extension PullableBottomBar {
    public enum TopBarStyle {
        case `default`
        case custom(AnimatableHeaderView)
    }
}

extension PullableBottomBar.TopBarStyle {
    public var view: AnimatableHeaderView {
        switch self {
        case .default:
            let view = AnimatableHeaderView(frame: .init(x: 0, y: 5, width: UIScreen.main
                                            .bounds.width, height: 50))
            view.backgroundColor = .white
            view.layer.cornerRadius = 5
            return view
        case .custom(let view):
            return view
        }
    }
}
