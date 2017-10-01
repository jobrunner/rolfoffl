import UIKit
import CoreLocation

enum AppColor {

    case yellow
    case organge
    case blue
    case red
    case gray

    var color: UIColor {
        get {
            return self._color()
        }
    }

    private func _color() -> UIColor {
        switch self {
        case .yellow: return UIColor(red: 235.0 / 255.0, green: 211.0 / 255.0, blue: 0, alpha: 1)
        case .organge: return UIColor(red: 214.0 / 255.0, green: 127.0 / 255.0, blue: 24.0 / 255.0,alpha: 1)
        case .blue: return UIColor(red: 20.0 / 255.0, green: 52.0 / 255.0, blue: 120.0 / 255.0,alpha: 1)
        case .red: return UIColor(red: 224.0 / 255.0, green: 30.0 / 255.0, blue: 17.0 / 255.0, alpha: 1)
        case .gray: return UIColor.lightGray
        }
    }
}

enum AppText: String {

    case noDataInfo = "Ermittle die Postleitzahl an deinem aktuellen Standort. - Ohne Internetverbindung!"
    case lastDataInfo = "Deine letzte Abfrage war im Postleitzahlenbereich:"
    case dataInfo = "Du befindest dich im Postleitzahlenbereich:"
    case fireButton = "PLZ ermitteln"
    case cancelButton = "Abbruch"
    case notFound = "PLZ konnte nicht ermittelt werden"
    case outOfBoundary = "PLZ nicht gefunden. Befindest du dich in Deutschland?"
    case alertLocationServiceTitle = "Ortungsdienste"
    case alertLocationServiceMessage = "Für die Verwendung von RolfOffl musst Du die Ortungsdienste aktivieren und den Zugriff auf deinen Standort erlauben. Geh dazu in die Einstellungen."
    case alertLocationServiceButtonOk = "OK"
    case alertLacationServiceButtonCancel = "Abbrechen"
    case alertLacationServiceButtonSettings = "Einstellungen"

    var text: String {
        get {
            return rawValue
        }
    }
}

enum TransitionState: Int {
    case ready
    case running
    case inactive
    
    init() {
        self = CLLocationManager.locationServicesEnabled() ? .ready : .inactive
    }

    mutating func next(withData: Bool) {
        switch self {
        case .inactive:
            self = CLLocationManager.locationServicesEnabled() ? .ready : .inactive
        case .ready:
            self = CLLocationManager.locationServicesEnabled() ? .running : .inactive
        case .running:
            self = CLLocationManager.locationServicesEnabled() ? .ready : .inactive
        }
    }
    
    func fireButtonText() -> String {
        switch self {
        case .running:
            return AppText.cancelButton.text
        default:
            return AppText.fireButton.text
        }
    }

    func fireButtonTextColor() -> UIColor {
        switch self {
        case .running:
            return AppColor.red.color
        case .ready:
            return AppColor.blue.color
        case .inactive:
            return AppColor.gray.color
        }
    }

    func fireButtonIsEnabled() -> Bool {
        switch self {
        case .running:
            return true
        case .ready:
            return true
        case .inactive:
            return false
        }
    }

    func animating(activityIndicator: UIActivityIndicatorView) {
        switch self {
        case .running:
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        case .ready:
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        case .inactive:
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    func updatingLocation(locationManager: CLLocationManager) {
        switch self {
        case .running:
            locationManager.startUpdatingLocation()
        case .ready:
            locationManager.stopUpdatingLocation()
        case .inactive:
            locationManager.stopUpdatingLocation()
        }
    }
    
    func visibility(view: UIView, withData: Bool) {
        switch self {
        case .running:
            view.alpha = withData ? 0.5 : 0.0
        case .ready:
            view.alpha = withData ? 1.0 : 0.0
        case .inactive:
            view.alpha = withData ? 0.5 : 0.0
        }
    }
}

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.requestWhenInUseAuthorization()
        return lm
    }()
    
    lazy var toaster: Toaster = {
        return Toaster(view: self.view)
    }()

    var location: LocationViewModel!
    var results: [PostleitzahlViewModel]!
    var transitionState: TransitionState!
    var lastDataMode: Bool = true

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var fireButton: UIButton!
    @IBOutlet weak var plzTextView: UITextView!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var orteLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var landBundeslandLabel: UILabel!
    @IBOutlet weak var landkreisLabel: UILabel!


    @IBAction func fireButtonTouch(_ sender: UIButton) {
        
        transitionState.next(withData: location.hasData)
        updateUI()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        loadLastResults()
        transitionState = TransitionState()
        updateUI()
    }
    
    func updateUI() {

        if results.count > 0 {
            plzTextView.text = results.first!.plz
            landBundeslandLabel.text = results.first!.landBundesland
        }
        else {
            plzTextView.text = ""
            landBundeslandLabel.text = ""
        }

        coordinatesLabel.text = location.coordinates

        if location.hasData {
            if lastDataMode {
                infoLabel.text = AppText.lastDataInfo.text
            } else {
                infoLabel.text = AppText.dataInfo.text
            }
        }
        else {
            infoLabel.text = AppText.noDataInfo.text
        }

        fireButton.setTitle(transitionState.fireButtonText(), for: UIControlState.normal)
        fireButton.setTitleColor(transitionState.fireButtonTextColor(), for: .normal)
        fireButton.isEnabled = transitionState.fireButtonIsEnabled()
        transitionState.visibility(view: plzTextView, withData: location.hasData)
        transitionState.visibility(view: landBundeslandLabel, withData: location.hasData)
        transitionState.visibility(view: landkreisLabel, withData: location.hasData)
        transitionState.visibility(view: coordinatesLabel, withData: location.hasData)
        transitionState.visibility(view: orteLabel, withData: location.hasData)
        transitionState.visibility(view: tableView, withData: location.hasData)
        transitionState.animating(activityIndicator: activityIndicator)
        transitionState.updatingLocation(locationManager: locationManager)
        tableView.reloadData()
    }
    
    // MARK: - Helper
    
    func loadLastResults() {

        // get User defaults Data from last application run
        let lastResultsCache = LastResultsCache()
        
        self.location = LocationViewModel(model: lastResultsCache.location)
        
        if let lastResults = lastResultsCache.results {
            self.results = lastResults.map { model in
                return PostleitzahlViewModel(model: model)
            }
        }
        else {
            self.results = [PostleitzahlViewModel.createEmpty()]
        }
    }

    func alertUserToSettings() {

        func settingsHandler(_ action: UIAlertAction){
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
        }
        
        
        let alertController = UIAlertController(title: AppText.alertLocationServiceTitle.text,
                                                message: AppText.alertLocationServiceMessage.text,
                                                preferredStyle: .alert)
        
        let url = URL(string:UIApplicationOpenSettingsURLString)

        if UIApplication.shared.canOpenURL(url!) {

            let settingsAction = UIAlertAction(title: AppText.alertLacationServiceButtonSettings.text,
                                               style: .default,
                                               handler: settingsHandler)
            
            let cancelAction = UIAlertAction(title: AppText.alertLacationServiceButtonCancel.text,
                                             style: .cancel,
                                             handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
        }
        else {
            let okAction = UIAlertAction(title: AppText.alertLocationServiceButtonOk.text,
                                         style: .default,
                                         handler: nil)
            alertController.addAction(okAction)
        }
        
        
        present(alertController, animated: true, completion: nil)
    }

    
    // MAKRK: - TableView Delegates

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "plzregioncell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId,
                                                    for:indexPath) as! RegionTableViewCell
        
        cell.ortLabel.text = results[indexPath.row].ort
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        return results.count
    }
}


extension MainViewController: CLLocationManagerDelegate {
    
    // MARK: - CLocation Manager Delegates
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            transitionState = .ready
            updateUI()
        }
        else {
            transitionState = .inactive
            updateUI()
            
            alertUserToSettings()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        
        let location: CLLocation = locations.last! as CLLocation
        
        if fabs(location.horizontalAccuracy) > 100 {
            return
        }
        
        if fabs(location.verticalAccuracy) > 100 {
            return
        }
        
        manager.stopUpdatingLocation()
        
        if let items = RegionService().service(request: Postleitzahl(location)) {
            if items.count > 0 {
                self.results = items.map { item in
                    return PostleitzahlViewModel(model: item)
                }
                self.location = LocationViewModel(model: location)
                
                var lastResultsCache = LastResultsCache()
                lastResultsCache.location = location
                lastResultsCache.results = items
            }
            else {
                self.results = [PostleitzahlViewModel.createEmpty()]
                self.location = LocationViewModel(model: nil)
                toaster.trigger(message: AppText.outOfBoundary.text, style: .warning)
            }
            
            lastDataMode = false
            transitionState.next(withData: self.location.hasData)
            updateUI()
        }
        else {
            toaster.trigger(message: AppText.notFound.text, style: .warning)
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        
        let e = error as! CLError
        if e.code == .denied {
            alertUserToSettings()
        }
        else {
            print(e.errorUserInfo)
        }
    }

}
