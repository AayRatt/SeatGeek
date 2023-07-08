//
//  EventsView.swift
//  SeatGeek
//
//  Created by Aayush Rattan on 2023-07-05.
//

import SwiftUI
import MapKit

struct EventsView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @EnvironmentObject var authHelper:FirebaseAuthController
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @StateObject private var locationManager = LocationManager()
    @State private var annotations = [MKPointAnnotation]()
    
    func loadDataFromAPI() {
        print("Fetching Events from API")
        
        let websiteAddress = "https://api.seatgeek.com/2/events?lat=\(centerCoordinate.latitude)&lon=\(centerCoordinate.longitude)&client_id=MzQ3MjE5NjB8MTY4ODU3NjI3NC43NzAzNTYy"
        
        guard let apiURL = URL(string: websiteAddress) else {
            print("Cannot Convert API Address to URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: apiURL) { data, response, error in
            if let error = error {
                print("Network Error: \(error)")
                return
            }
            
            if let jsonData = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase // Use snake_case decoding
                    
                    let decodedResponse = try decoder.decode(EventResponse.self, from: jsonData)
                    
                    DispatchQueue.main.async {
                        print(decodedResponse)
                        // Set response here
                        var newAnnotations = [MKPointAnnotation]()
                        for event in decodedResponse.events {
                            let venue = event.venue
                            let name = venue.name
                            let location = venue.location
                            let latitude = location.lat
                            let longitude = location.lon
                            
                            if let lat = latitude, let lon = longitude {
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                annotation.title = name
                                
                                newAnnotations.append(annotation)
                            }
                            // Access the event's name, latitude, and longitude here
                            print("Event Name: \(name)")
                            print("Latitude: \(latitude)")
                            print("Longitude: \(longitude)")
                        }
                        annotations = newAnnotations
                    }
                } catch {
                    print("JSON Decoding Error: \(error)")
                }
            } else {
                print("Did not receive data from API")
            }
        }
        
        task.resume()
    }
    
    var body: some View {
        NavigationStack {
            MapView(centerCoordinate: $centerCoordinate, annotations: annotations)
//            Button("Sign Out") {
////                isLoggedIn = false
////                authHelper.signOut()
//            }
                       
                       Text("Latitude: \(centerCoordinate.latitude)")
                       Text("Longitude: \(centerCoordinate.longitude)")
            Button("Call API") {
                loadDataFromAPI()
            }
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}

struct MapView: UIViewRepresentable {
    @StateObject private var locationManager = LocationManager()
    @Binding var centerCoordinate: CLLocationCoordinate2D
    var annotations: [MKPointAnnotation]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        locationManager.requestLocation() // Request a single location update
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        // Update the map view here, if needed
//        view.removeAnnotation(view.annotations)
        view.addAnnotations(annotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            let coordinate = userLocation.coordinate
            parent.centerCoordinate = coordinate
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Access location coordinates: location.coordinate.latitude and location.coordinate.longitude
        print(location.coordinate.longitude)
        print(location.coordinate.latitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}


