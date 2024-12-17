import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @Binding var memories: [Memory]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: memories.filter { $0.coordinate != nil }) { memory in
            MapAnnotation(coordinate: memory.coordinate) {
                VStack {
                    if let image = memory.image {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    } else {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }

                    Text(memory.locationName)
                        .font(.caption)
                        .padding(4)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(5)
                        .shadow(radius: 2)
                }
            }
        }
        .onAppear {
            adjustRegionToFitAnnotations()
        }
    }

    /// Adjust the map region to fit all memory coordinates.
    private func adjustRegionToFitAnnotations() {
        let coordinates = memories.compactMap { $0.coordinate }
        guard !coordinates.isEmpty else { return }

        var minLat = coordinates.first!.latitude
        var maxLat = coordinates.first!.latitude
        var minLon = coordinates.first!.longitude
        var maxLon = coordinates.first!.longitude

        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }

        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.2, // Add padding
            longitudeDelta: (maxLon - minLon) * 1.2
        )
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        region = MKCoordinateRegion(center: center, span: span)
    }
}
