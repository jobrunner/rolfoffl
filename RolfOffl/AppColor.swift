import UIKit

enum AppColor {

    case yellow
    case organge
    case blue
    case red
    case gray

    var color: UIColor {
        get {
            return self._color()
        }
    }

    private func _color() -> UIColor {
        switch self {
        case .yellow: return UIColor(red: 235.0 / 255.0, green: 211.0 / 255.0, blue: 0, alpha: 1)
        case .organge: return UIColor(red: 214.0 / 255.0, green: 127.0 / 255.0, blue: 24.0 / 255.0,alpha: 1)
        case .blue: return UIColor(red: 20.0 / 255.0, green: 52.0 / 255.0, blue: 120.0 / 255.0,alpha: 1)
        case .red: return UIColor(red: 224.0 / 255.0, green: 30.0 / 255.0, blue: 17.0 / 255.0, alpha: 1)
        case .gray: return UIColor.lightGray
        }
    }
}
