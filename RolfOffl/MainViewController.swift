//
//  Created by Jo Brunner on 30.05.17.
//  Copyright © 2017 Jo Brunner. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    
    @IBOutlet weak var fireButton: UIButton!
    
    @IBOutlet weak var plzLabel: UILabel!

    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
}

// MARK: - IBActions

extension MainViewController {

    @IBAction func fireButtonTouch(_ sender: UIButton) {
    
        plzLabel.text = "Bestimme deine Position"

        // trigger Location Service with callback:
        
        let location = CLLocation(latitude:49.783180555556,
                                  longitude:9.9371583333333)
        
        if let plz = RegionService().service(request: Postleitzahl(location)) {
            
            plzLabel.text = plz
        }
        else {
            plzLabel.text = "PLZ nicht gefunden"
        }
    }

}
