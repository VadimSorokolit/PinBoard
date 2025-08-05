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
    
    // MARK: - Properites. Private
    
    @Environment(\.modelContext) private var modelContext
    @Environment(PinBoardViewModel.self) private var viewModel
    @Query(sort: \StorageLocation.index) private var locations: [StorageLocation]
    @State private var camera = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    )
    @State private var locationManager = LocationService()
    @State private var hasCenteredOnUserLocation = false
    @State private var isShowingAlert = false
    @State private var isLoading = false
    @State private var isSingleButtonAlert = false
    @State private var userCoordinate: CLLocationCoordinate2D? = nil
    @State private var alertMessage: Text = Text("")
    @State private var newLocation: Location? = nil
    @State private var selectedLocationId: String? = nil
    @AppStorage(GlobalConstants.selectedPinIndexKey) private var selectedPinColorsIndex: Int = 0
    @AppStorage(GlobalConstants.addLocationKey) private var isAutoAddingLocation: Bool = false
    private var selectedPinGradient: PinGradient {
        PinGradient.all[selectedPinColorsIndex]
    }
    
    // MARK: - Main body
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapReader { proxy in
                    Map(position: $camera) {
                        if let userCoordinate {
                            Annotation("", coordinate: userCoordinate) {
                                VStack(spacing: 4) {
                                    Text("Start location")
                                        .font(.custom(GlobalConstants.boldFont, size: 12.0))
                                        .foregroundColor(.blue)
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
                        }
                        let sorted = locations.sorted { a, b in
                            a.index < b.index
                        }
                        
                        ForEach(sorted) { storage in
                            let maxIndex = locations
                                .filter { $0.latitude == storage.latitude && $0.longitude == storage.longitude }
                                .map(\.index)
                                .max() ?? storage.index
                            Annotation("", coordinate: CLLocationCoordinate2D(latitude: storage.latitude, longitude: storage.longitude)) {
                                
                                CustomPinView(selectedLocationId: $selectedLocationId, locationId: storage.id, index: maxIndex, title: storage.name, selectedPinGradient: selectedPinGradient)
                                    .zIndex(Double(maxIndex))
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
                            .sequenced(before: DragGesture(minimumDistance: 0.0))
                            .onEnded { value in
                                switch value {
                                    case .second(true, let drag?):
                                        let location = drag.location
                                        
                                        if let coordinate = proxy.convert(location, from: .local) {
                                            handlePress(at: coordinate, isAutoAdding: isAutoAddingLocation)
                                        }
                                    default:
                                        break
                                }
                            }
                    )
                }
                
                VStack(spacing: 0.0) {
                    SpinnerView(isLoading: isLoading)
                    
                    Spacer()
                }
                .ignoresSafeArea(edges: .top)
            }
            .toolbar(.hidden, for: .navigationBar)
            .overlay(alignment: .center) {
                if isShowingAlert {
                    AlertView(
                        message: alertMessage,
                        confirmTitle: isSingleButtonAlert ? "OK" : "Add",
                        cancelTitle: isSingleButtonAlert ? nil : "Cancel",
                        onConfirm: {
                            if isSingleButtonAlert == false {
                                handleAddLocation()
                            }
                            isShowingAlert = false
                            isSingleButtonAlert = false
                        },
                        onCancel: isSingleButtonAlert ? nil : {
                            isShowingAlert = false
                            isSingleButtonAlert = false
                        }
                    )
                }
            }
        }
        .task {
            guard !hasCenteredOnUserLocation else { return }
            
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
        .onDisappear {
            selectedLocationId = nil
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
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.blue)
                    }
                }
                .padding(.horizontal, 16.0)
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
        let selectedPinGradient: PinGradient
        private let pinSize: CGFloat = 44.0
        @State private var showBubble: Bool = false
        private var isSelected: Bool {
            selectedLocationId == locationId
        }

        var body: some View {
            ZStack {
                PinView(selectedLocationId: $selectedLocationId, locationId: locationId, index: index, title: title, selectedPinGradient: selectedPinGradient, isSelected: isSelected)
                
                if showBubble {
                    BubbleView(title: title, pinSize: pinSize)
                        .opacity(isSelected ? 1 : 0)
                        .transition(.scale(scale: 0.1, anchor: .center).combined(with: .opacity))
                }
            }
            .onChange(of: isSelected) { oldValue, newValue in
                withAnimation(.spring()) {
                    showBubble = newValue
                }
            }
        }

        private struct PinView: View {
            @Binding var selectedLocationId: String?
            let locationId: String
            let index: Int
            let title: String
            let selectedPinGradient: PinGradient
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
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedLocationId = isSelected ? nil : locationId
                    }
                }
            }
            
        }
        
        private struct BubbleView: View {
            let title: String
            let pinSize: CGFloat
            private let bubbleHeight: CGFloat = 25.0
            
            var body: some View {
                VStack(spacing: 0.0) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 12.0)
                        .padding(.vertical, 4.0)
                        .frame(maxWidth: 200.0, maxHeight: bubbleHeight)
                        .background(
                            Capsule()
                                .shadow(radius: 2.0)
                        )
                    Image(systemName: "arrowtriangle.down.fill")
                        .resizable()
                        .frame(width: 12.0, height: 8.0)
                }
                .foregroundStyle(.blue)
                .offset(y: -(pinSize / 2.0 + bubbleHeight / 2.0) - 8.0)
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
                    
                    let prefix = Text("Do you want to add location")
                        .font(.custom(GlobalConstants.mediumFont, size: 16.0))
                    
                    let name = Text(location.name)
                        .font(.custom(GlobalConstants.boldFont, size: 16.0))
                        .foregroundStyle(selectedPinGradient.gradient)
                    
                    let suffix = Text("?")
                        .font(.custom(GlobalConstants.mediumFont, size: 16.0))
                    
                    alertMessage = prefix + space + name + suffix
                    newLocation = location
                    
                    isSingleButtonAlert = false
                    isShowingAlert = true
                }
            } else {
                showErrorAlert(message: "Could not load location")
            }
        }
    }
    
    private func handleAddLocation() {
        guard let storageLocation = newLocation?.asStorageModel else {
            showErrorAlert(message: "Error: Failed to convert location to storage model")
            
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
            showErrorAlert(message: error.localizedDescription)
        }
    }
    
    private func showErrorAlert(message: String) {
        alertMessage = Text(message)
            .font(.custom(GlobalConstants.mediumFont, size: 16.0))
        
        isSingleButtonAlert = true
        isShowingAlert = true
    }
    
}
