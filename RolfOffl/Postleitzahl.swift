//
//  Created by Jo Brunner on 02.06.17.
//  Copyright © 2017 Jo Brunner. All rights reserved.
//

import CoreLocation

class Postleitzahl: RegionRequest {
    
    let query: String
    let params: [BindParam]
    
    init(_ location: CLLocation) {

        query = "SELECT note as value FROM plz WHERE ST_Contains(Geometry, ST_Point(?,?))";

        params = [
            BindParam(type: kBindingTypeDouble,
                      value: location.coordinate.longitude),
            BindParam(type: kBindingTypeDouble,
                      value: location.coordinate.latitude)
        ]
    }
}
