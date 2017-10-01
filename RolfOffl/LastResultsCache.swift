import Foundation
import CoreLocation


struct LastResultsCache {
    
    private let locationKey = "location"
    private let resultsKey = "results"

    var results: [PostleitzahlModel]? {
        get {
            guard let data = self.value(forKey: resultsKey) as? Data else {
                return nil
            }
            guard let results = NSKeyedUnarchiver.unarchiveObject(with: data) as? [PostleitzahlModel] else {
                return nil
            }
            return results
        }
        set {
            if let results = newValue {
                let data = NSKeyedArchiver.archivedData(withRootObject: results)
                self.set(data, forKey: resultsKey)
            } else {
                self.removeObject(forKey: resultsKey)
            }
        }
    }
    
    var location: CLLocation? {
        get {
            guard let data = self.value(forKey: locationKey) as? Data else {
                return nil
            }
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? CLLocation
        }
        set {
            if let location = newValue {
                let data = NSKeyedArchiver.archivedData(withRootObject: location)
                self.set(data, forKey: locationKey)
            } else {
                self.removeObject(forKey: locationKey)
            }
        }
    }
    
    fileprivate func value(forKey: String) -> Any? {
        
        return UserDefaults.standard.value(forKey: forKey)
    }
    
    fileprivate func set(_ data: Any?, forKey: String) {
        
        UserDefaults.standard.set(data, forKey: forKey)
    }
    
    fileprivate func removeObject(forKey: String) {
        
        UserDefaults.standard.removeObject(forKey: forKey)
    }
}


