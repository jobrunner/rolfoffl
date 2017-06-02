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
    
    func service(request: RegionRequest) -> String? {

        if let region = RegionDatabase() {
            
            do {
                let result = try region.execute(request.query, with: request.params)
                let item = result.first as? [String:String]
                
                return item?["value"]
            } catch _ as NSError {}
        }
        
        return nil
    }
}
