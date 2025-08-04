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
    
    // MARK: - Properites
    
    @Environment(\.modelContext) private var modelContext
    @Environment(PinBoardViewModel.self) private var viewModel
    @Query(sort: \StorageLocation.index) private var locations: [StorageLocation]
    @State private var camera = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    )
    @State private var isShowingAlert = false
    @State private var isLoading = false
    @State private var isSingleButtonAlert = true
    @State private var alertMessage: Text = Text("")
    @State private var newLocation: Location? = nil
    @State private var selectedLocationId: String? = nil
    @AppStorage(GlobalConstants.selectedPinIndexKey) private var selectedPinColorsIndex: Int = 0
    @AppStorage(GlobalConstants.addLocationKey) private var isAutoAddingLocation: Bool = false
    private var selectedPinGradient: PinGradient {
        PinGradient.all[selectedPinColorsIndex]
    }
    
    // MARK: - Main View
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapReader { proxy in
                    Map(position: $camera) {
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
        private var isSelected: Bool { selectedLocationId == locationId }
        private let pinSize: CGFloat = 44.0
        private let bubbleHeight: CGFloat = 40.0
        
        
        var body: some View {
            ZStack(alignment: .center) {
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
                if isSelected {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 12.0)
                        .padding(.vertical, 8.0)
                        .frame(maxWidth: 200.0, minHeight: bubbleHeight, maxHeight: bubbleHeight)
                        .background(
                            Capsule()
                                .fill(Color.blue)
                                .shadow(radius: 2.0)
                        )
                        .offset(y: -(pinSize / 2.0 + bubbleHeight / 2.0) - 2.0)
                        .transition(
                            .scale(scale: 0.1, anchor: .center)
                            .combined(with: .opacity)
                        )
                }
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
                    
                    alertMessage = prefix + space + name + space + suffix
                    newLocation = location
                    
                    isSingleButtonAlert = false
                    isShowingAlert = true
                }
            } else {
                alertMessage = Text("Could not load location")
                    .font(.custom(GlobalConstants.mediumFont, size: 16.0))
                
                isSingleButtonAlert = true
                isShowingAlert = true
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
