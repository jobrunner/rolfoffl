//
//  Created by Jo Brunner on 31.05.17.
//  Copyright © 2017 Jo Brunner. All rights reserved.
//

import CoreLocation

protocol RegionRequest {

    var query: String { get }
    var params: [BindParam] { get }
}

class RegionService: NSObject {
    
    func service(request: RegionRequest) -> [[String:String?]]? {
        if let region = RegionDatabase() {
            do {
                let spatialiteResults = try region.execute(request.query, with: request.params)
                return spatialiteResults as? [[String : String?]]
            } catch _ as NSError {}
        }
        
        return nil
    }
}
