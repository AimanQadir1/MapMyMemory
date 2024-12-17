import Foundation
import MapKit

class CitySearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchResults: [String] = []

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
    }

    func search(for query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        completer.queryFragment = query
        completer.resultTypes = .address
        completer.filterType = .locationsOnly
    }

    // MARK: - MKLocalSearchCompleterDelegate Methods

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Update search results when the completer has finished
        searchResults = completer.results.map { $0.title }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Handle any errors that occur
        print("Error with search completer: \(error.localizedDescription)")
    }
}
