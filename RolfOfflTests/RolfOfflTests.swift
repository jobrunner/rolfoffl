import XCTest
import CoreLocation
@testable import RolfOffl

class RolfOfflTests: XCTestCase {
    
    // Hausen im Landkreis Neuwied, Germany
    let testLocation = CLLocation(latitude: CLLocationDegrees(50.551948),
                                  longitude: CLLocationDegrees(7.385075))

    override func setUp() {

        super.setUp()
    }
    
    override func tearDown() {

        super.tearDown()
    }
    
    func testStandardIntegration() {

        guard let items = RegionService().service(request: Postleitzahl(testLocation)) else {
            return XCTAssert(false, "Integration test on standard location is brocken")
        }

        XCTAssertTrue(items.count > 0)
        XCTAssertEqual(items.count, 8);
        print(items)
        let shouldLand = "Deutschland"
        let shouldBundesland = "Rheinland-Pfalz"
        let shouldLandkreis = "Landkreis Neuwied"
        let orte: Set<String> = [
            "Bad Hönningen",
            "Breitscheid",
            "Dattenberg",
            "Hausen (Wied)",
            "Hümmerich",
            "Kasbach-Ohlenberg",
            "Leubsdorf",
            "Roßbach"
        ]
        
        items.forEach { result in
            if let land = result["land"] {
                XCTAssertEqual(land, shouldLand)
            }
            else {
                XCTAssert(false, "land is not properly set")
            }

            if let bundesland = result["bundesland"] {
                XCTAssertEqual(bundesland, shouldBundesland)
            }
            else {
                XCTAssert(false, "bundesland is not properly set")
            }

            if let landkreis = result["landkreis"] {
                XCTAssertEqual(landkreis, shouldLandkreis)
            }
            else {
                XCTAssert(false, "landkreis is not properly set")
            }

            if let ort = result["ort"] {
                XCTAssert(orte.contains(ort!), "False ort")
            }
            else {
                XCTAssert(false, "Ort is not properly set")
            }
        }
    }
    
    func testPerformanceStandard() {

        self.measure {
            _ = RegionService().service(request: Postleitzahl(testLocation))
        }
    }
    
}
