import SwiftUI
import MapKit

struct EventsView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @EnvironmentObject var authHelper: FirebaseAuthController
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @StateObject private var locationManager = LocationManager()
    @State private var annotations = [MKPointAnnotation]()
    @State private var selectedEvent: Event?
    @State private var isShowingSearchAlert = false
    @State private var searchCity = ""

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
                                let annotation = EventAnnotation(event: event, onTap: { event in
                                    selectedEvent = event
                                })
                                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                annotation.title = name

                                newAnnotations.append(annotation)
                            }
                            // Access the event's name, latitude, and longitude here
//                            print("Event Name: \(name)")
//                            print("Latitude: \(latitude)")
//                            print("Longitude: \(longitude)")
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
    
    func searchCityAndLoadData() {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(searchCity) { placemarks, error in
                if let error = error {
                    print("Geocoding Error: \(error.localizedDescription)")
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    print("No placemark found for the provided city")
                    return
                }
                
                let coordinate = placemark.location?.coordinate
                if let coordinate = coordinate {
                    centerCoordinate = coordinate
                    loadDataFromAPI()
                }
            }
        }


    var body: some View {
        NavigationStack {
            MapView(centerCoordinate: $centerCoordinate, annotations: annotations, selectedEvent: $selectedEvent)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    loadDataFromAPI()
                                }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            //Search City Here
                            isShowingSearchAlert = true
                        }label: {
                            Label("City", systemImage: "magnifyingglass")
                        }
                    }
                }
                .sheet(item: $selectedEvent) { event in
                    EventDetailView(selectedEvent: event)
                }
                .alert("Search by City", isPresented: $isShowingSearchAlert) {
                    TextField("Enter City Name", text: $searchCity)
                    Button("Search", action: searchCityAndLoadData)
                    Button("Cancel", role: .cancel) {}
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
    var onTapAnnotation: ((Event) -> Void)? = nil
    @Binding var selectedEvent: Event?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        locationManager.requestLocation()
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.removeAnnotations(view.annotations)
        let eventAnnotations = annotations.map { $0 as MKAnnotation }
        view.addAnnotations(eventAnnotations)

        if let userLocation = view.userLocation.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 35000, longitudinalMeters: 35000)
            view.setRegion(region, animated: true)
        }
        updateMapRegion(view: view)
    }

    func updateMapRegion(view: MKMapView) {
            let region = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 35000, longitudinalMeters: 35000)
            view.setRegion(region, animated: true)
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

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let eventAnnotation = annotation as? EventAnnotation else {
                return nil
            }

            let identifier = "eventAnnotation"
            var annotationView: MKAnnotationView

            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                annotationView = dequeuedView
            } else {
                annotationView = MKPinAnnotationView(annotation: eventAnnotation, reuseIdentifier: identifier)
                annotationView.canShowCallout = true
                annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }

            return annotationView
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let annotation = view.annotation as? EventAnnotation {
                parent.selectedEvent = annotation.event
            }
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

class EventAnnotation: MKPointAnnotation {
    var event: Event
    var onTap: ((Event) -> Void)?

    init(event: Event, onTap: ((Event) -> Void)?) {
        self.event = event
        self.onTap = onTap
        super.init()

        self.coordinate = CLLocationCoordinate2D(latitude: event.venue.location.lat ?? 0, longitude: event.venue.location.lon ?? 0)
        self.title = event.venue.name
    }
}
