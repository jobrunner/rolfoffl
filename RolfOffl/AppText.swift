import Foundation

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
