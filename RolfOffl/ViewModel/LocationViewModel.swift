import Foundation
import CoreLocation

struct LocationViewModel {
    
    let model: CLLocation?
    
    init(model: CLLocation?) {
        self.model = model
    }
    
    var hasData: Bool {
        get {
            return (model != nil)
        }
    }
    
    var coordinates: String {
        get {
            guard let model = model else {
                return "Koordinaten: keine vorhanden"
            }
            
            let latitude = NSNumber(value: model.coordinate.latitude)
            let longitude = NSNumber(value: model.coordinate.longitude)
            let formatter: NumberFormatter? = NumberFormatter()

            if let formatter = formatter {
                formatter.locale = NSLocale.current
                formatter.numberStyle = .decimal
                formatter.alwaysShowsDecimalSeparator = false
                formatter.usesGroupingSeparator = false
                formatter.usesSignificantDigits = false;
                formatter.minimumFractionDigits = 6;
                formatter.maximumFractionDigits = 6;
                formatter.positivePrefix = "+"
                formatter.negativePrefix = "-"
                formatter.minusSign = "-"
                formatter.plusSign = "+"
                return "Koordinaten: "
                    + formatter.string(from: latitude)!
                    + (formatter.decimalSeparator == "," ? ";" : ",")
                    + formatter.string(from: longitude)!
            }
            return ""
        }
    }
}
