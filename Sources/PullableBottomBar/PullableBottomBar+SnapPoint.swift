import UIKit

extension PullableBottomBar {
    
    public enum SnapPoint {
        case min
        case max
        case custom(y: CGFloat)

        var y: CGFloat {
            switch self {
            case .min:
                return UIApplication.shared.safeAreaTop
            case .max:
                return UIScreen.main.bounds.height -
                    UIApplication.shared.safeAreaBottom - 50 // in order to swipe properly
            case .custom(let y):
                return y
            }
        }
    }
}

extension PullableBottomBar.SnapPoint: Comparable {
    public static func == (lhs: PullableBottomBar.SnapPoint, rhs: PullableBottomBar.SnapPoint) -> Bool {
        switch (lhs, rhs) {
        case (.min, .min): return true
        case (.max, .max): return true
        case (.custom(let y1), .custom(let y2)): return y1 == y2
        default: return false
        }
    }

    public static func < (lhs: PullableBottomBar.SnapPoint, rhs: PullableBottomBar.SnapPoint) -> Bool {
        switch (lhs, rhs) {
        case (.min, _): return true
        case (.max, _): return false
        case (_, .min): return false
        case (_, .max): return true
        case (.custom(let y1), .custom(let y2)): return y1 < y2
        }
    }
}
