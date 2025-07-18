//
//  MapView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 08.07.2025.
//

import SwiftUI
import SwiftData
import MapKit

struct MapView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PinBoardViewModel.self) private var viewModel
    @Query(sort: \StorageLocation.index) var locations: [StorageLocation]
    @State private var camera = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    )
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var newLocation: Location? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapReader { proxy in
                    Map(position: $camera) {
                        let sorted = locations.sorted { a, b in
                            
                            a.index < b.index
                        }
                        
                        ForEach(sorted) { storage in
                            Marker(
                                "\(storage.index)",
                                coordinate: CLLocationCoordinate2D(
                                    latitude: storage.latitude,
                                    longitude: storage.longitude
                                )
                            )
                            .tint(.green)
                        }
                    }
                    .ignoresSafeArea()
                    .gesture(
                        LongPressGesture(minimumDuration: 1.0)
                            .sequenced(before: DragGesture(minimumDistance: 0))
                            .onEnded { value in
                                switch value {
                                    case .second(true, let drag?):
                                        let location = drag.location
                                        if let coordinate = proxy.convert(location, from: .local) {
                                            handleLongPress(at: coordinate)
                                        }
                                    default:
                                        break
                                }
                            }
                    )
                }
                .ignoresSafeArea()
            }
            .toolbar(.hidden, for: .navigationBar)
            .alert("Add new location", isPresented: $showAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Add", role: .none) {
                    handleAddLocation()
                }
            } message: {
                Text(alertMessage)
            }
        }
        .onChange(of: viewModel.isLoading) {
            //            if let location = viewModel.selectedLocation {
            //                print(location.longitude)
            //                withAnimation(.easeInOut) {
            //                    camera = .region(
            //                        MKCoordinateRegion(
            //                            center: CLLocationCoordinate2D(latitude: location.latitude,
            //                                                           longitude: location.longitude),
            //                            span: MKCoordinateSpan(latitudeDelta: 0.05,
            //                                                   longitudeDelta: 0.05)
            //                        )
            //                    )
            //                }
            //            }
        }
    }
    
    // MARK: - Methods. Private
    
    private func handleLongPress(at coordinate: CLLocationCoordinate2D) {
        Task {
            if let location = await viewModel.loadLocation(for: coordinate.latitude, longitude: coordinate.longitude) {
                alertMessage = "Do you want to add location \"\(location.name)\"?"
                newLocation = location
                showAlert = true
            } else {
                alertMessage = "Location not found."
                showAlert = true
            }
        }
    }
    
    private func handleAddLocation() {
        guard let storageLocation = newLocation?.asStorageModel else {
            print("Error: Failed to convert location to storage model")
            return
        }
        
        let newStorageLocation = StorageLocation(
            index: locations.count + 1,
            name: storageLocation.name,
            longitude: storageLocation.longitude,
            latitude: storageLocation.latitude
        )
        
        modelContext.insert(newStorageLocation)
        
        do {
            try modelContext.save()
            
            newLocation = nil
        } catch {
            print("Failed to save location:", error)
        }
        
    }
}
//import SwiftUI
//import SwiftData
//import MapKit
//
//struct MapView: View {
//    @Query(sort: \StorageLocation.index) private var locations: [StorageLocation]
//    @State private var region = MKCoordinateRegion(
//        center: .init(latitude: 50.4501, longitude: 30.5234),
//        span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
//    )
//
//    var body: some View {
//        Map(
//            coordinateRegion: $region,
//            annotationItems: sortedLocations
//        ) { location in
//            MapAnnotation(
//                coordinate: .init(
//                    latitude: location.latitude,
//                    longitude: location.longitude
//                )
//            ) {
//                ZStack {
//                    Circle()
//                        .fill(Color.green)
//                        .frame(width: 32, height: 32)
//                        .shadow(radius: 2)
//                    Text("\(location.index)")
//                        .font(.system(size: 14, weight: .bold))
//                        .foregroundColor(.white)
//                }
//            }
//        }
//        .ignoresSafeArea()
//    }
//
//    private var sortedLocations: [StorageLocation] {
//        locations.sorted { $0.index < $1.index }
//    }
//}
