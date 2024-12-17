import SwiftUI
import CoreLocation
import MapKit


@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
struct HomeView: View {
    @StateObject private var citySearchVM = CitySearchViewModel()
    @State private var showingImagePicker = false
    @State private var showingDetailsPrompt = false
    @State private var selectedImage: UIImage? = nil
    @State private var cityName: String = ""
    @State private var memories: [Memory] = []
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Geotag Memories")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                Button(action: {
                    showingImagePicker = true
                }) {
                    Text("Add New Memory")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                TextField("Search for a city", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: searchText) { query in
                        citySearchVM.search(for: query)
                    }

                List(citySearchVM.searchResults, id: \.self) { city in
                    Button(action: {
                        cityName = city
                        searchText = ""
                    }) {
                        Text(city)
                    }
                }

                List(memories) { memory in
                    if memory.locationName == cityName || cityName.isEmpty {
                        HStack {
                            // Handle optional image properly
                            if let image = memory.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                            } else {
                                // Fallback UI when the image is nil
                                Image(systemName: "photo.fill")  // A placeholder icon
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                                    .cornerRadius(8)
                            }

                            VStack(alignment: .leading) {
                                Text(memory.locationName)
                                    .font(.headline)
                                Text(memory.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                            }
                        }
                    }
                }

                Spacer()

                // Map Button
                NavigationLink(destination: MapView(memories: $memories)) {
                    Text("View Memories on Map")
                        .font(.title2)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    if let image = image {
                        selectedImage = image
                        showingDetailsPrompt = true
                    }
                }
            }
            .sheet(isPresented: $showingDetailsPrompt) {
                VStack {
                    Text("Add Memory Details")
                        .font(.headline)
                        .padding()

                    Text("City: \(cityName)")
                        .font(.subheadline)
                        .padding()

                    Button(action: {
                        if let image = selectedImage {
                            saveMemory(image: image, locationName: cityName)
                            showingDetailsPrompt = false
                        }
                    }) {
                        Text("Save Memory")
                            .font(.title2)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding()
            }
        }
    }

    private func saveMemory(image: UIImage, locationName: String) {
        getCoordinates(for: locationName) { coordinate in
            if let coordinate = coordinate {
                let newMemory = Memory(
                    image: image,
                    locationName: locationName,
                    coordinate: coordinate, // Use the fetched coordinate
                    voiceNoteURL: nil,
                    date: Date()
                )
                memories.append(newMemory)
            } else {
                print("Failed to get coordinates for \(locationName)")
            }
        }
    }

    private func getCoordinates(for cityName: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { (placemarks, error) in
            if let placemark = placemarks?.first {
                let coordinate = placemark.location?.coordinate
                completion(coordinate)
            } else {
                completion(nil)
            }
        }
    }
}
