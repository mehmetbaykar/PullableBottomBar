import UIKit

open class PullableBottomBar: UIViewController {

    open var snapPoints: [SnapPoint] = [.min, .max] {
        didSet { snapPoints.sort() }
    }

    private var pullableMinY: CGFloat {
        return snapPoints.first?.y ?? SnapPoint.min.y
    }

    private var pullableMaxY: CGFloat {
        return snapPoints.last?.y ?? SnapPoint.max.y
    }

    private let topBarStyle: TopBarStyle
    private let contentViewController: UIViewController?
    
    private var status = PullableBottomBarStatus.expand
    
    private var parentView: UIView?
    private weak var contentScrollView: UIScrollView?

    public init(content: UIViewController,
                topBarStyle: TopBarStyle = .default) {
        self.contentViewController = content
        self.topBarStyle = topBarStyle
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        contentViewController = nil
        topBarStyle = .default
        super.init(coder: aDecoder)
        setupTopBarTapGesture()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTopBarTapGesture()
    }

    private func setupViews() {
        view.backgroundColor = .clear
        view.layer.cornerRadius = 5
        view.clipsToBounds = true

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)

        let topBar = topBarStyle.view
        view.addSubview(topBar)
        topBar.center.x = view.center.x
        topBar.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        topBar.isMultipleTouchEnabled = false

        if let content = contentViewController {
            addContainerView(content)
            content.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                content.view.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 0),
                content.view.leftAnchor.constraint(equalTo: view.leftAnchor),
                content.view.rightAnchor.constraint(equalTo: view.rightAnchor)
                ])
            
            if #available(iOS 11.0, *) {
                content.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            } else {
                content.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            }
        }
        self.view.bringSubviewToFront(topBar)
        self.view.frame.origin.y = pullableMaxY
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let view = parentView else { return }
        self.view.frame.size.height = view.frame.height - pullableMinY
    }

    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        self.updatePositions()
    }
    
    open func updatePositions(){}

    private func setupTopBarTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTopBarTapped))
        self.topBarStyle.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTopBarTapped(){
        switch self.status{
        case .shrink: self.expand()
        case .expand: self.shrink()
        default:break
        }
        
    }
    open func show(on viewController: UIViewController,
                  view: UIView? = nil) {
        parentView = view ?? viewController.view
        viewController.addContainerView(self, view: view)
        self.view.autoresizingMask = [.flexibleWidth,
                                      .flexibleTopMargin,
                                      .flexibleHeight,
                                      .flexibleBottomMargin]
    }

    open func scroll(toY y: CGFloat, duration: Double = 0.75) {
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [], animations: {
            self.view.frame.origin.y = y
        }, completion: nil)
    }
    
    
    
    open func updateStatus(status:PullableBottomBarStatus){
        guard self.status != status else {return}
        
    }
    
    open func expand(){
        guard self.status == .shrink else {return}
        
        scroll(toY: pullableMinY)
        self.status = .expand
        self.contentViewController?.viewDidAppear(true)
    }
    
    open func shrink() {
       guard self.status == .expand else {return}
        
        scroll(toY: pullableMaxY)
        self.status = .shrink
        self.contentViewController?.viewDidDisappear(false)
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.contentScrollView = scrollView

        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }

    @objc private func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        defer { recognizer.setTranslation(.zero, in: view) }
        
        if let scrollView = contentScrollView {
            let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
            if velocity > 0 && scrollView.contentOffset.y > 0 {
                return
            }
        }
        
        let velocity = recognizer.velocity(in: view)
        
        if velocity.y > 1500 {
            self.shrink()
            return
        }else if velocity.y < -1500 {
            self.expand()
            return
        }

        let translation = recognizer.translation(in: view)
        let y = view.frame.minY

        view.frame.origin.y = min(max(y + translation.y, pullableMinY), pullableMaxY)

        if recognizer.state == .ended,
           !snapPoints.isEmpty {
            let targetY = nearestPoint(of: y)
            let distance = abs(y - targetY)
            let duration = max(min(distance / velocity.y, distance / (UIScreen.main.bounds.height / 3)), 0.3)

            scroll(toY: targetY, duration: Double(duration))
        }
    }
}

extension UIView{
    func makeDefault(){
        self.clipsToBounds = true
    }
}
