//
//  MapView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 08.07.2025.
//
    
import SwiftUI
import MapKit

struct MapView: View {
    @State private var camera = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.4501,
                                           longitude: 30.5234),
            span: MKCoordinateSpan(latitudeDelta: 0.05,
                                   longitudeDelta: 0.05)
        )
    )
    
    var body: some View {
        NavigationStack {
            Map(position: $camera) {}
                .ignoresSafeArea()
                .toolbar(.hidden, for: .navigationBar)
        }
    }
    
}
