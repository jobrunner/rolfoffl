//
//  Created by Jo Brunner on 02.06.17.
//  Copyright © 2017 Jo Brunner. All rights reserved.
//

import CoreLocation

class Postleitzahl: RegionRequest {
    
    let query: String
    let params: [BindParam]
    
    init(_ location: CLLocation) {
        query = "SELECT plz_attribute.plz AS plz, ort.name AS ort, landkreis.name AS landkreis, bundesland.name AS bundesland, \"Deutschland\" AS land FROM plz_attribute LEFT JOIN ort ON (plz_attribute.ort_id=ort.id) LEFT JOIN landkreis ON (plz_attribute.landkreis_id = landkreis.id) LEFT JOIN bundesland ON (plz_attribute.bundesland_id = bundesland.id) WHERE plz_attribute.plz = (SELECT plz FROM plz WHERE ST_Contains(geom, MakePoint(?1,?2)) = 1 AND ROWID IN (SELECT ROWID FROM SpatialIndex WHERE f_table_name = 'plz' AND search_frame = MakePoint(?1,?2))) GROUP BY land, bundesland, landkreis, ort;"
        params = [
            BindParam(type: kBindingTypeDouble,
                      value: location.coordinate.longitude),
            BindParam(type: kBindingTypeDouble,
                      value: location.coordinate.latitude)
        ]
    }
}
