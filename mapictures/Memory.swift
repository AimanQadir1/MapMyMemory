import Foundation
import UIKit
import CoreLocation

// Memory struct to store information about a memory
struct Memory: Identifiable {
    let id = UUID()
    var image: UIImage? // Make this optional
    var locationName: String
    var coordinate: CLLocationCoordinate2D
    var voiceNoteURL: URL? // URL to the recorded voice note
    var date: Date
}
