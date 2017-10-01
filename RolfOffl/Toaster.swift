import UIKit

enum ToasterStyle {

    case warning
    case info
    var color: CGColor {
        get {
            switch self {
            case .warning:
                return UIColor.red.cgColor
            case .info:
                return UIColor(red: 224.0 / 255.0, green: 110.0 / 255.0, blue: 22.0 / 255.0,alpha: 1).cgColor
            }
        }
    }

    var fontColor: UIColor {
        get {
            return UIColor.white
        }
    }
    var font: UIFont {
        get {
            return UIFont.systemFont(ofSize: 17.0)
        }
    }
}


class Toaster: NSObject {

    let showToasterSeconds: TimeInterval = 8.0
    let containerView: UIView

    var message: String?
    var style: ToasterStyle?
    var timer: Timer!

    lazy var label: UILabel = {
    
        let l = UILabel()

        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        
        return l
    }()
    
    lazy var toasterView: UIView = {
        
        let toasterView = UIView()
        
        toasterView.alpha = 1.0
        toasterView.translatesAutoresizingMaskIntoConstraints = false
        toasterView.contentMode = .scaleAspectFill
        toasterView.alpha = 0.0
        
        self.containerView.addSubview(toasterView)
        toasterView.addSubview(self.label)
        
        let toasterViewTopConstraint = NSLayoutConstraint(item: toasterView,
                                                          attribute: .top,
                                                          relatedBy: .equal,
                                                          toItem: self.containerView,
                                                          attribute: .top,
                                                          multiplier: 1.0,
                                                          constant: 0.0)
        
        let toasterViewLeadingConstraint = NSLayoutConstraint(item: toasterView,
                                                              attribute: .leading,
                                                              relatedBy: .equal,
                                                              toItem: self.containerView,
                                                              attribute: .leading,
                                                              multiplier: 1.0,
                                                              constant: 0.0)
        
        let toasterViewTrailingConstraint = NSLayoutConstraint(item: toasterView,
                                                               attribute: .trailing,
                                                               relatedBy: .equal,
                                                               toItem: self.containerView,
                                                               attribute: .trailing,
                                                               multiplier: 1.0,
                                                               constant: 0.0)
        
        self.containerView.addConstraint(toasterViewTopConstraint)
        self.containerView.addConstraint(toasterViewLeadingConstraint)
        self.containerView.addConstraint(toasterViewTrailingConstraint)
        
        let labelTopConstraint = NSLayoutConstraint(item: self.label,
                                                    attribute: .top,
                                                    relatedBy: .equal,
                                                    toItem: toasterView,
                                                    attribute: .top,
                                                    multiplier: 1.0,
                                                    constant: 30.0)
        let labelLeadingConstraint = NSLayoutConstraint(item: self.label,
                                                        attribute: .leading,
                                                        relatedBy: .equal,
                                                        toItem: toasterView,
                                                        attribute: .leading,
                                                        multiplier: 1.0,
                                                        constant: 17.0)
        let labelTrailingConstraint = NSLayoutConstraint(item: self.label,
                                                         attribute: .trailing,
                                                         relatedBy: .equal,
                                                         toItem: toasterView,
                                                         attribute: .trailing,
                                                         multiplier: 1.0,
                                                         constant: -16.0)
        let labelBottomConstaint = NSLayoutConstraint(item: self.label,
                                                      attribute: .bottom,
                                                      relatedBy: .equal,
                                                      toItem: toasterView,
                                                      attribute: .bottom,
                                                      multiplier: 1.0,
                                                      constant: -20.0)
        
        toasterView.addConstraint(labelTopConstraint)
        toasterView.addConstraint(labelLeadingConstraint)
        toasterView.addConstraint(labelTrailingConstraint)
        toasterView.addConstraint(labelBottomConstaint)
    
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                         action: #selector(actionClose(_:)))
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self,
                                                              action: #selector(actionClose(_:)))
        swipeGestureRecognizer.direction = .up

        toasterView.addGestureRecognizer(tapGestureRecognizer)
        toasterView.addGestureRecognizer(swipeGestureRecognizer)
        
        return toasterView
    }()

    init(view: UIView) {
        
        self.containerView = view
    }
    
    func trigger(message: String, style: ToasterStyle = .warning) {
        
        toasterView.layer.backgroundColor = style.color
        label.textColor = style.fontColor
        label.font = style.font
        label.text = message
        
        toasterView.fadeIn()
        
        timer = Timer.scheduledTimer(timeInterval: showToasterSeconds,
                                     target: self,
                                     selector: #selector(destroyToaster),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    @objc func destroyToaster() {
        
        toasterView.fadeOut()
    }
    
    @objc func actionClose(_ tap: UITapGestureRecognizer) {

        timer.invalidate()
        toasterView.fadeOut(withDuration: 0.3)
    }
    
}
