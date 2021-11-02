import UIKit

public enum PullableBottomBarPosition:Equatable{
    case expand
    case custom(y:CGFloat)
    case shrink
}
