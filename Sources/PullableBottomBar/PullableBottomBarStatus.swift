import UIKit

public enum PullableBottomBarStatus:Equatable{
    case expand
    case custom(y:CGFloat)
    case shrink
}
