import Foundation

typealias PostleitzahlModel = [String:String?]

struct PostleitzahlViewModel {
    
    private var model: PostleitzahlModel
    
    init(model: PostleitzahlModel) {
        self.model = model
    }

    /** Creates a PostleitzahlViewModel instance with an empty model
     */
    static func createEmpty() -> PostleitzahlViewModel {
        return PostleitzahlViewModel(model: PostleitzahlModel())
    }
    
    /** Political locality. Can be the name of a city or town.
     */
    var ort: String {
        get {
            guard let ort = model["ort"] else { return "" }
            return ort!
        }
    }

    /** Zip code
     */
    var plz: String {
        get {
            guard let plz = model["plz"] else { return "" }
            return "PLZ: " + plz!
        }
    }

    /** Administrative area level 1. It's normaly the name of an country
     */
    var land: String {
        guard let land = model["land"] else { return "" }
        return land!
    }
    
    /** Administrative area level 2. It's normaly the name of a state.
     */
    var bundesland: String {
        guard let bundesland = model["bundesland"] else { return "" }
        return bundesland!
    }
    
    /** Combined land and bundesland
     */
    var landBundesland: String {
        return [land, bundesland].joined(separator: " ")
    }
    
    /** Administrative area level 2. It's normaly the name of a county.
     */
    var landkreis: String {
        guard let landkreis = model["landkreis"] else { return "" }
        return landkreis!
    }
}
