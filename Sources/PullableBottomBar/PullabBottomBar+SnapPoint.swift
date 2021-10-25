import Foundation

extension PullabBottomBar {
    public enum SnapPoint {
        case min
        case max
        case custom(y: CGFloat)

        var y: CGFloat {
            switch self {
            case .min:
                return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
            case .max:
                return UIScreen.main.bounds.height - {
                    UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
                }()
            case .custom(let y):
                return y
            }
        }
    }

    func nearestPoint(of pointY: CGFloat) -> CGFloat {
        var result: (y: CGFloat, distance: CGFloat) = (0, .greatestFiniteMagnitude)
        for snapPoint in snapPoints {
            let y = snapPoint.y
            let distance = abs(y - pointY)
            if result.distance > distance {
                result = (y: y, distance: distance)
            }
        }
        return result.y
    }
}

extension PullabBottomBar.SnapPoint: Comparable {
    public static func == (lhs: PullabBottomBar.SnapPoint, rhs: PullabBottomBar.SnapPoint) -> Bool {
        switch (lhs, rhs) {
        case (.min, .min): return true
        case (.max, .max): return true
        case (.custom(let y1), .custom(let y2)): return y1 == y2
        default: return false
        }
    }

    public static func < (lhs: PullabBottomBar.SnapPoint, rhs: PullabBottomBar.SnapPoint) -> Bool {
        switch (lhs, rhs) {
        case (.min, _): return true
        case (.max, _): return false
        case (_, .min): return false
        case (_, .max): return true
        case (.custom(let y1), .custom(let y2)): return y1 < y2
        }
    }
}
