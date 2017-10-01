import Foundation

struct Formatter {

    private var cachedFormatter: NumberFormatter!

    lazy var geodeticDecimal: NumberFormatter = {
        
        if cachedFormatter == nil {
            cachedFormatter = NumberFormatter()
            cachedFormatter.locale = NSLocale.current
            cachedFormatter.numberStyle = .decimal
            cachedFormatter.alwaysShowsDecimalSeparator = false
            cachedFormatter.usesGroupingSeparator = false
            cachedFormatter.usesSignificantDigits = false;
            cachedFormatter.minimumFractionDigits = 6;
            cachedFormatter.maximumFractionDigits = 12;
        }

        return cachedFormatter
    }()
}
