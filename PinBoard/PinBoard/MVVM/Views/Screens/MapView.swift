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
    
    // MARK: - Objects
    
    private struct Constants {
        static let bubbleViewTriangleIconName = "arrowtriangle.down.fill"
        static let alertPrefixTitleName: String = "Do you want to add location"
        static let alertSuffixTitleName: String = "?"
        static let storageConversionErrorMessage = "Error: Failed to convert location to storage model"
        static let loadLocationErrorMessage = "Could not load location"
        static let infoAlertMessage: String = "Long press on map to add new location"
    }
    
    // MARK: - Properites. Private
    
    @Environment(\.modelContext) private var modelContext
    @Environment(PinBoardViewModel.self) private var viewModel
    @Environment(AlertManager.self) private var alertManager
    @Query(sort: \StorageLocation.index) private var locations: [StorageLocation]
    @State private var camera = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    )
    @State private var locationManager = LocationService()
    @State private var hasCenteredOnUserLocation: Bool = false
    @State private var isLoading: Bool = false
    @State private var userCoordinate: CLLocationCoordinate2D? = nil
    @State private var newLocation: Location? = nil
    @State private var selectedLocationId: String? = nil
    @State private var isShownInfoAlert: Bool = false
    @State private var isFirstScreenBoot: Bool = false
    @AppStorage(GlobalConstants.selectedPaletteIndexKey) private var selectedPaletteIndex: Int = 0
    @AppStorage(GlobalConstants.addLocationKey) private var isAutoAddingLocation: Bool = false
    private var selectedPalette: ColorGradient {
        ColorGradient.palette[selectedPaletteIndex]
    }
    private var uniqueLocations: [StorageLocation] {
        let grouped = Dictionary(grouping: locations) { location in
            "\(location.latitude)-\(location.longitude)"
        }
        
        return grouped.compactMap { (key, locations) in
            locations.max { $0.index < $1.index }
        }
        .sorted { $0.index < $1.index }
    }
    
    // MARK: - Main body
    
    var body: some View {
        ZStack {
            PinView(camera: $camera, selectedLocationId: $selectedLocationId, selectedPalette: selectedPalette, userCoordinate: userCoordinate, uniqueLocations: uniqueLocations, onPressAt: { coordinate in
                handlePress(at: coordinate, isAutoAdding: isAutoAddingLocation)
            })
            
            VStack(spacing: .zero) {
                SpinnerView(isLoading: isLoading)
                
                Spacer()
            }
            .ignoresSafeArea(edges: .top)
        }
        .modifier(LoadViewModifier(
            viewModel: viewModel,
            camera: $camera,
            locationManager: $locationManager,
            userCoordinate: $userCoordinate,
            hasCenteredOnUserLocation: $hasCenteredOnUserLocation,
            newLocation: $newLocation,
            selectedLocationId: $selectedLocationId,
            isFirstScreenBoot: $isFirstScreenBoot,
            isShownInfoAlert: $isShownInfoAlert))
    }
    
    // MARK: - Subviews
    
    private struct PinView: View {
        @Binding var camera: MapCameraPosition
        @Binding var selectedLocationId: String?
        let selectedPalette: ColorGradient
        let userCoordinate: CLLocationCoordinate2D?
        let uniqueLocations: [StorageLocation]
        let onPressAt: (CLLocationCoordinate2D) -> Void
        
        var body: some View {
            MapReader { proxy in
                Map(position: $camera) {
                    if let userCoordinate {
                        Annotation("", coordinate: userCoordinate) {
                            UserLocationView(coordinate: userCoordinate)
                        }
                    }
                    
                    ForEach(uniqueLocations, id: \.id) { storage in
                        Annotation("", coordinate: CLLocationCoordinate2D(latitude: storage.latitude, longitude: storage.longitude)) {
                            CustomPinView(
                                selectedLocationId: $selectedLocationId,
                                locationId: storage.id,
                                index: storage.index,
                                title: storage.name,
                                selectedPinGradient: selectedPalette
                            )
                            .zIndex(Double(storage.index))
                        }
                    }
                }
                .ignoresSafeArea()
                .gesture(
                    LongPressGesture(minimumDuration: 1.0)
                        .onEnded { _ in
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                        .sequenced(before: DragGesture(minimumDistance: .zero))
                        .onEnded { value in
                            switch value {
                                case .second(true, let drag?):
                                    let location = drag.location
                                    
                                    if let coordinate = proxy.convert(location, from: .local) {
                                        onPressAt(coordinate)
                                    }
                                default:
                                    break
                            }
                        }
                )
            }
        }
        
    }
    
    private struct UserLocationView: View {
        let coordinate: CLLocationCoordinate2D
        
        var body: some View {
            Circle()
                .fill(Color.blue)
                .frame(width: 14.0, height: 14.0)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2.0)
                )
                .shadow(radius: 2.0)
        }
        
    }
    
    private struct SpinnerView: View {
        @State private var topInset: CGFloat = 0.0
        let isLoading: Bool
        
        var body: some View {
            GeometryReader { geo in
                HStack {
                    Spacer()
                    
                    if isLoading {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.5))
                                .frame(width: 40.0, height: 40.0)
                            
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        }
                    }
                }
                .padding(.trailing, 20.0)
                .padding(.top, topInset + 30.0)
                .padding(.bottom, 8.0)
                .background(.clear)
                .onAppear {
                    topInset = geo.safeAreaInsets.top
                }
            }
            .frame(height: (40.0 + topInset))
        }
        
    }
    
    struct CustomPinView: View {
        @Binding var selectedLocationId: String?
        let locationId: String
        let index: Int
        let title: String
        let selectedPinGradient: ColorGradient
        private let pinSize: CGFloat = 44.0
        private var isSelected: Bool {
            selectedLocationId == locationId
        }
        
        var body: some View {
            ZStack {
                PinView(
                    locationId: locationId,
                    index: index,
                    title: title,
                    selectedPinGradient: selectedPinGradient,
                    isSelected: isSelected
                )
                
                BubbleView(title: title, pinSize: pinSize)
                    .scaleEffect(isSelected ? 1.0 : 0.5, anchor: .center)
                    .opacity(isSelected ? 1.0 : 0.0)
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    selectedLocationId = isSelected ? nil : locationId
                }
            }
        }
        
        private struct PinView: View {
            let locationId: String
            let index: Int
            let title: String
            let selectedPinGradient: ColorGradient
            let isSelected: Bool
            private let pinSize: CGFloat = 44.0
            
            var body: some View {
                ZStack {
                    selectedPinGradient.gradient
                        .mask(
                            Image(GlobalConstants.pinImageName)
                                .resizable()
                                .scaledToFit()
                        )
                        .frame(width: pinSize, height: pinSize)
                    
                    ZStack {
                        Circle()
                            .foregroundStyle(Color.white)
                            .frame(width: pinSize / 2.6, height: pinSize / 2.6)
                        
                        Text("\(index)")
                            .font(.custom(GlobalConstants.mediumFont, size: 12.0))
                            .lineLimit(1)
                            .minimumScaleFactor(0.3)
                            .foregroundColor(.black)
                            .frame(maxWidth: pinSize / 2.7)
                    }
                    .offset(y: -8.0)
                }
            }
            
        }
        
        private struct BubbleView: View {
            let title: String
            let pinSize: CGFloat
            private let maxWidth: CGFloat = 160.0
            
            var body: some View {
                VStack(spacing: .zero) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal, 12.0)
                        .padding(.vertical, 4.0)
                        .frame(maxWidth: isShortText ? nil : maxWidth)
                        .fixedSize(horizontal: isShortText, vertical: true)
                        .background(
                            Capsule()
                                .shadow(radius: 2.0)
                        )
                    
                    Image(systemName: Constants.bubbleViewTriangleIconName)
                        .resizable()
                        .frame(width: 12.0, height: 8.0)
                }
                .foregroundStyle(.blue)
                .offset(y: -(pinSize))
            }
            
            private var isShortText: Bool {
                title.count < 30
            }
        }
    }
    
    // MARK: - Methods. Private
    
    private func handlePress(at coordinate: CLLocationCoordinate2D, isAutoAdding: Bool) {
        isLoading = true
        
        Task {
            defer { isLoading = false }
            
            if let location = await viewModel.loadLocation(for: coordinate.latitude, longitude: coordinate.longitude) {
                if isAutoAdding {
                    newLocation = location
                    handleAddLocation()
                } else {
                    let space = Text(" ")
                    
                    let prefix = Text(Constants.alertPrefixTitleName)
                        .font(.custom(GlobalConstants.mediumFont, size: GlobalConstants.alertMessageFontSize))
                    
                    let name = Text(location.name)
                        .font(.custom(GlobalConstants.boldFont, size: GlobalConstants.alertMessageFontSize))
                        .foregroundStyle(selectedPalette.gradient)
                    
                    let suffix = Text(Constants.alertSuffixTitleName)
                        .font(.custom(GlobalConstants.mediumFont, size: GlobalConstants.alertMessageFontSize))
                    
                    let message = prefix + space + name + suffix
                    
                    alertManager.showConfirmWith(message) {
                        newLocation = location
                        handleAddLocation()
                    } onCancel: {
                        newLocation = nil
                    }
                    
                }
            } else {
                alertManager.showInfoWith(Text(Constants.loadLocationErrorMessage))
            }
        }
    }
    
    private func handleAddLocation() {
        guard let storageLocation = newLocation?.asStorageModel else {
            alertManager.showInfoWith(Text(Constants.storageConversionErrorMessage))
            
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
            alertManager.showInfoWith(Text(error.localizedDescription))
        }
    }
    
    // MARK: - Modifiers
    
    private struct LoadViewModifier: ViewModifier {
        let viewModel: PinBoardViewModel
        @Environment(AlertManager.self) private var alertManager
        @Query(sort: \StorageLocation.index) private var locations: [StorageLocation]
        @Binding var camera: MapCameraPosition
        @Binding var locationManager: LocationService
        @Binding var userCoordinate: CLLocationCoordinate2D?
        @Binding var hasCenteredOnUserLocation: Bool
        @Binding var newLocation: Location?
        @Binding var selectedLocationId: String?
        @Binding var isFirstScreenBoot: Bool
        @Binding var isShownInfoAlert: Bool
        
        func body(content: Content) -> some View {
            content
                .toolbar(.hidden, for: .navigationBar)
                .onAppear {
                    if hasCenteredOnUserLocation == false {
                        Task {
                            let coordinate = await locationManager.requestLocation()
                            
                            withAnimation {
                                camera = .region(
                                    MKCoordinateRegion(
                                        center: coordinate,
                                        span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5)
                                    )
                                )
                            }
                            
                            userCoordinate = coordinate
                            hasCenteredOnUserLocation = true
                        }
                    }
                    if isShownInfoAlert == false, locations.isEmpty, isFirstScreenBoot {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            alertManager.showError(Text(Constants.infoAlertMessage)) {
                                isShownInfoAlert = true
                            }
                        }
                    }
                    // Need to fix Tab Bar animation
                    isFirstScreenBoot = true
                }
                .onDisappear() {
                    newLocation = nil
                    selectedLocationId = nil
                }
                .onChange(of: viewModel.selectedLocation) {
                    if let location = viewModel.selectedLocation {
                        withAnimation(.easeInOut) {
                            camera = .region(
                                MKCoordinateRegion(
                                    center: .init(latitude: location.latitude, longitude: location.longitude),
                                    span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5)
                                )
                            )
                        }
                    }
                }
        }
    }
}
