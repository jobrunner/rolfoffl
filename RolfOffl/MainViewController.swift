//
//  Created by Jo Brunner on 30.05.17.
//  Copyright © 2017 Jo Brunner. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let location = CLLocation(latitude:49.783180555556,
                                  longitude:9.9371583333333)
        
        if let plz = RegionService().service(request: Postleitzahl(location)) {
            print("PLZ ist: \(plz)")
        }
        else {
            print("PLZ konnte nicht ermittelt werden.")
        }
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
