import UIKit
import CoreLocation

final class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
            landkreisLabel.text = results.first!.landkreis
        }
        else {
            plzTextView.text = ""
            landBundeslandLabel.text = ""
            landkreisLabel.text = ""
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

        fireButton.setTitle(transitionState.fireButtonText(), for: UIControl.State.normal)
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
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        }
        
        
        let alertController = UIAlertController(title: AppText.alertLocationServiceTitle.text,
                                                message: AppText.alertLocationServiceMessage.text,
                                                preferredStyle: .alert)
        
        let url = URL(string:UIApplication.openSettingsURLString)

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
