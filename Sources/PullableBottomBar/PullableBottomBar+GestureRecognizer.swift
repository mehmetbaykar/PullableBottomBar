import UIKit

extension PullableBottomBar: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        
        if let _ = gestureRecognizer as? UIPanGestureRecognizer,
           let _ = otherGestureRecognizer as? UITapGestureRecognizer{
            return false
        }else{
            
            guard let _ = gestureRecognizer as? UIPanGestureRecognizer,
                  let otherPanGesture = otherGestureRecognizer as? UIPanGestureRecognizer,
                  let scrollView = otherPanGesture.view as? UIScrollView
            else {
                return true
            }
            
            return scrollView.contentPosition == .custom ? false : true
        }
    }
}

private enum ScrollViewContentPosition{
    case top
    case bottom
    case custom
}

private extension UIScrollView{
    var contentPosition:ScrollViewContentPosition{
        guard (contentOffset.y > 0) else{
            return .top
        }
        
        guard (contentOffset.y < (contentSize.height - frame.size.height)) else{
            return .bottom
        }
        
        return .custom
    }
}

