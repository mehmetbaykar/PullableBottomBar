import UIKit

open class PullableBottomBar: UIViewController {
    
    open var backgroundColor:UIColor = .clear
    
    open var roundTopBar = true
    
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
    
    private var position = PullableBottomBarStatus.shrink
    
    private var parentView: UIView?
    private weak var contentScrollView: UIScrollView?
    
    deinit{
        self.parentView = nil
        self.contentScrollView = nil
        print("\(Self.description()) has been deinited")
    }
    public init(content: UIViewController,
                topBarStyle: TopBarStyle = .default,
                position:PullableBottomBarStatus = .shrink) {
        self.contentViewController = content
        self.topBarStyle = topBarStyle
        self.position = position
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.contentViewController = nil
        self.topBarStyle = .default
        super.init(coder: aDecoder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        setupBackgroundView()
        setupTapBar()
        setupTopBarTapGesture()
        setupContainerView()
    }
    
    private func setupBackgroundView(){
        view.backgroundColor = self.backgroundColor
        view.clipsToBounds = true
        view.frame.origin.y = self.position == .expand ? pullableMinY : pullableMaxY
        setupPanGesture()
    }
    
    
    private func setupTapBar(){
        let topBar = topBarStyle.view
        view.addSubview(topBar)
        topBar.center.x = view.center.x
        topBar.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin,.flexibleWidth]
        topBar.isMultipleTouchEnabled = false
    }
    
    private func setupContainerView(){
        if let content = contentViewController {
            addContainerView(content)
            content.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                content.view.topAnchor.constraint(equalTo: self.topBarStyle.view.bottomAnchor),
                content.view.leftAnchor.constraint(equalTo: view.leftAnchor),
                content.view.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
            
            if #available(iOS 11.0, *) {
                content.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            } else {
                content.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            }
        }
        self.view.bringSubviewToFront(topBarStyle.view)
        
    }
    private func setupTopBarTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTopBarTapped))
        self.topBarStyle.view.addGestureRecognizer(tapGesture)
    }
    
    private func setupPanGesture(){
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc private func didTopBarTapped(){
        switch self.position{
        case .shrink: self.expand()
        case .expand: self.shrink()
        default:break
    
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let view = parentView else { return }
        self.view.frame.size.height = view.frame.height - pullableMinY
        if roundTopBar{ topBarStyle.view.roundCorners([.topLeft,.topRight], radius: 20) }
        
    }
    
    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        self.updatePositions()
    }
    
    open func updatePositions(){}
    
    open func show(on viewController: UIViewController,
                   view: UIView? = nil) {
        parentView = view ?? viewController.view
        viewController.addContainerView(self, view: view)
        self.view.autoresizingMask = [.flexibleWidth,
                                      .flexibleTopMargin,
                                      .flexibleHeight,
                                      .flexibleBottomMargin]
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.contentScrollView = scrollView
        
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
}

extension PullableBottomBar{
    
    open func scroll(toY y: CGFloat,
                     duration: Double = 0.75,
                     completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: {
            self.view.frame.origin.y = y
        }, completion: completion)
    }
    
    open func expand(){
        scroll(toY: pullableMinY, duration: 0.75)
        self.position = .expand
    }
    
    open func shrink(){
        scroll(toY: pullableMaxY, duration: 0.75)
        self.position = .shrink
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
            let duration = max(min(distance / velocity.y, distance / (UIScreen.main.bounds.height / 3)), 0.35)
            scroll(toY: targetY, duration: Double(duration))
        }
    }
}
