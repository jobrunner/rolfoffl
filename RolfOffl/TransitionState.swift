import UIKit
import CoreLocation

enum TransitionState: Int {
    case ready
    case running
    case inactive

    init() {
        self = CLLocationManager.locationServicesEnabled() ? .ready : .inactive
    }

    mutating func next(withData: Bool) {
        switch self {
        case .inactive:
            self = CLLocationManager.locationServicesEnabled() ? .ready : .inactive
        case .ready:
            self = CLLocationManager.locationServicesEnabled() ? .running : .inactive
        case .running:
            self = CLLocationManager.locationServicesEnabled() ? .ready : .inactive
        }
    }

    func fireButtonText() -> String {
        switch self {
        case .running:
            return AppText.cancelButton.text
        default:
            return AppText.fireButton.text
        }
    }

    func fireButtonTextColor() -> UIColor {
        switch self {
        case .running:
            return AppColor.red.color
        case .ready:
            return AppColor.blue.color
        case .inactive:
            return AppColor.gray.color
        }
    }

    func fireButtonIsEnabled() -> Bool {
        switch self {
        case .running:
            return true
        case .ready:
            return true
        case .inactive:
            return false
        }
    }

    func animating(activityIndicator: UIActivityIndicatorView) {
        switch self {
        case .running:
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        case .ready:
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        case .inactive:
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }

    func updatingLocation(locationManager: CLLocationManager) {
        switch self {
        case .running:
            locationManager.startUpdatingLocation()
        case .ready:
            locationManager.stopUpdatingLocation()
        case .inactive:
            locationManager.stopUpdatingLocation()
        }
    }


    func visibility(view: UIView, withData: Bool) {
        switch self {
        case .running:
            view.alpha = withData ? 0.5 : 0.0
        case .ready:
            view.alpha = withData ? 1.0 : 0.0
        case .inactive:
            view.alpha = withData ? 0.5 : 0.0
        }
    }
}
