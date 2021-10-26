import UIKit

// TODO: - Add Preferring One Gesture Over Another
extension PullableBottomBar: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        
        if let _ = gestureRecognizer as? UIPanGestureRecognizer,
           let _ = otherGestureRecognizer as? UITapGestureRecognizer{
            return false
        }else{
            return true
        }
    }
}
