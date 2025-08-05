//
//  ListView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 07.07.2025.
//
 
import Foundation
import SwiftUI
import SwiftData

struct ListView: View {
    
    // MARK: - Objects
    
    private struct Constants {
        static let gridWidth: CGFloat = 400.0
        static let gridImageWidth: CGFloat = 24.0
        static let gridIndexTitleWidth: CGFloat = 60.0
        static let indexTitleWidth: CGFloat = 60.0
        static let nameTitleWidth: CGFloat = 200.0
        static let latitudeTitleWidth: CGFloat = 100.0
        static let longitudeTitleWidth: CGFloat = 100.0
        static let cellHorizontalPadding: CGFloat = 20.0
        static let cellFontSize: CGFloat = 14.0
        static let headerFontSize: CGFloat = 16.0
        static let iconEditName: String = "line.3.horizontal"
        static let iconDeleteName: String = "ellipsis"
        static let indexTextColor: Int = 0x35C759
        static let longitudeTextColor: Int = 0xF95069
        static let latitudeTextColor: Int = 0x7732d3
        static let activeCellOpacity: Double = 0.3
    }
    
    // MARK: - Properties. Private
    
    @Environment(PinBoardViewModel.self) private var viewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StorageLocation.index) private var locations: [StorageLocation]
    @State private var targetedId: String? = nil
    @State private var isEditing: Bool = false
    @State private var isAnimation: Bool = false
    @State private var currentToast: Toast? = nil
    @AppStorage(GlobalConstants.selectedPinIndexKey) private var selectedPinColorsIndex: Int = 0
    @AppStorage(GlobalConstants.colorKey) private var headerColorHex: Int = 0x0000FF
    private var selectedPinGradient: PinGradient {
        PinGradient.all[selectedPinColorsIndex]
    }
    
    // MARK: - Main body
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(selectedPinGradient.gradient).opacity(GlobalConstants.barGradientOpacity)
                .ignoresSafeArea(.all, edges: .top)
                .frame(height: 100.0)
                .edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 0.0) {
                Text("Locations")
                    .font(.custom(GlobalConstants.boldFont, size: 20.0))
                    .foregroundStyle(.black)
                    .padding(.top, 10.0)
                
                GridView(
                    targetedId: $targetedId,
                    isEditing: $isEditing,
                    currentToast: $currentToast,
                    isAnimation: $isAnimation,
                    modelContext: modelContext,
                    selectedPinGradient:selectedPinGradient,
                    locations: locations,
                    headerColorHex: headerColorHex
                )
            }
            .toast($currentToast)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
    
    private struct GridView: View {
        @Environment(PinBoardViewModel.self) private var viewModel
        @Binding var targetedId: String?
        @Binding var isEditing: Bool
        @Binding var currentToast: Toast?
        @Binding var isAnimation: Bool
        let modelContext: ModelContext
        let selectedPinGradient: PinGradient
        let locations: [StorageLocation]
        let headerColorHex: Int
        
        var body: some View {
            
            VStack(spacing: 0.0) {
                EditButtonView(isEditing: $isEditing, isAnimation: $isAnimation)
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0.0) {
                            HeaderView(isEditing: $isEditing, headerColorHex: headerColorHex)
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 0.0) {
                                    ForEach(locations) { location in
                                        let isDragging = targetedId == location.id
                                        
                                        let cell = CellView(
                                            isAnimation: $isAnimation,
                                            isEditing: $isEditing,
                                            currentToast: $currentToast,
                                            selectedPinGradient: selectedPinGradient,
                                            location: location,
                                            headerColorHex: headerColorHex,
                                            isDragging: isDragging,
                                            onDelete: {
                                                deleteLocation(location)
                                            }
                                        )
                                        
                                        cell
                                            .overlay(
                                                isEditing ?
                                                Color.clear
                                                    .contentShape(Rectangle())
                                                    .draggable(location.id)
                                                    .dropDestination(for: String.self) { droppedIds, _ in
                                                        handleDrop(droppedIds: droppedIds, to: location)
                                                    } isTargeted: { isOver in
                                                        targetedId = isOver ? location.id : nil
                                                    }
                                                : nil
                                            )
                                            .animation(.easeInOut, value: locations)
                                    }
                                }
                            }
                            .padding(.bottom, 8.0)
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.black.opacity(0.15), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                .frame(height: 8.0),
                                alignment: .bottom
                            )
                        }
                    }
                    .onAppear {
                        if let last = locations.last?.id {
                            proxy.scrollTo(last, anchor: .bottom)
                        }
                    }
                }
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.3), .clear]),
                        startPoint: .trailing,
                        endPoint: .leading
                    )
                    .frame(width: 8.0),
                    alignment: .trailing
                )
            }
            .frame(maxWidth: .infinity)
        }
        
        private struct EditButtonView: View {
            @Binding var isEditing: Bool
            @Binding var isAnimation: Bool
            
            var body: some View {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "Done" : "Edit")
                            .font(.custom(GlobalConstants.semiBoldFont, size: Constants.cellFontSize))
                    }
                }
                .padding(.top, 12.0)
                .padding(.bottom, 11.0)
                .padding(.trailing, 16.0)
            }
            
        }
        
        private struct HeaderView: View {
            @Binding var isEditing: Bool
            let headerColorHex: Int
            
            var body: some View {
                VStack(spacing: 8.0) {
                    Divider()
                    
                    Grid(horizontalSpacing: GlobalConstants.gridHorizontalSpacing) {
                        GridRow {
                            Text(isEditing ? "Edit" : "Menu")
                                .font(.custom(GlobalConstants.semiBoldFont, size: Constants.headerFontSize))
                                .frame(width: Constants.gridIndexTitleWidth, alignment: .center)
                                .verticalColumnDivider()
                            
                            Text("Index")
                                .font(.custom(GlobalConstants.semiBoldFont, size: Constants.headerFontSize))
                                .frame(width: Constants.indexTitleWidth, alignment: .leading)
                                .verticalColumnDivider()
                            
                            Text("Name")
                                .font(.custom(GlobalConstants.semiBoldFont, size: Constants.headerFontSize))
                                .frame(width: Constants.nameTitleWidth, alignment: .leading)
                                .verticalColumnDivider()
                            
                            Text("Latitude")
                                .font(.custom(GlobalConstants.semiBoldFont, size: Constants.headerFontSize))
                                .frame(width: Constants.latitudeTitleWidth, alignment: .leading)
                                .verticalColumnDivider()
                            Text("Longitude")
                                .font(.custom(GlobalConstants.semiBoldFont, size: Constants.headerFontSize))
                                .frame(width: Constants.longitudeTitleWidth, alignment: .leading)
                        }
                    }
                    
                    Divider()
                }
                .background(Color(hex: headerColorHex).opacity(0.1))
                .frame(minWidth: Constants.gridWidth)
            }
        }
        
        private struct CellView: View {
            @Environment(PinBoardViewModel.self) private var viewModel
            @State private var isPressed = false
            @Binding var isAnimation: Bool
            @Binding var isEditing: Bool
            @Binding var currentToast: Toast?
            let selectedPinGradient: PinGradient
            let location: StorageLocation
            let headerColorHex: Int
            let isDragging: Bool
            let onDelete: () -> Void
            
            var body: some View {
                Grid(horizontalSpacing: GlobalConstants.gridHorizontalSpacing) {
                    GridRow {
                        Menu(content: {
                            if !isEditing {
                                Button(role: .destructive) { onDelete() } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }) {
                            Image(systemName: isEditing
                                  ? Constants.iconEditName
                                  : Constants.iconDeleteName
                            )
                            .resizable()
                            .foregroundColor(Color(hex: 0x000000))
                            .scaledToFit()
                            .contentTransition(
                                .symbolEffect(
                                    .replace.magic(fallback: .downUp.wholeSymbol),
                                    options: .nonRepeating
                                )
                            )
                            .frame(width: Constants.gridImageWidth, height: Constants.gridImageWidth)
                        }
                        .frame(width: Constants.indexTitleWidth, height: Constants.gridIndexTitleWidth, alignment: .center)
                        
                        Text("No. \(location.index)")
                            .font(.custom(GlobalConstants.mediumFont, size: Constants.cellFontSize))
                            .foregroundColor(Color(hex:Constants.indexTextColor))
                            .frame(width: Constants.indexTitleWidth, alignment: .leading)
                        
                        Text(location.name)
                            .font(.custom(GlobalConstants.mediumFont, size: Constants.cellFontSize))
                            .lineLimit(3)
                            .frame(width: Constants.nameTitleWidth, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("\(location.latitude)")
                            .font(.custom(GlobalConstants.mediumFont, size: Constants.cellFontSize))
                            .foregroundColor(Color(hex: Constants.latitudeTextColor))
                            .frame(width: Constants.latitudeTitleWidth, alignment: .leading)
                        
                        Text("\(location.longitude)")
                            .font(.custom(GlobalConstants.mediumFont, size: Constants.cellFontSize))
                            .foregroundColor(Color(hex: Constants.longitudeTextColor))
                            .frame(width: Constants.longitudeTitleWidth, alignment: .leading)
                    }
                }
                .frame(minWidth: Constants.gridWidth)
                .padding(.horizontal, Constants.cellHorizontalPadding)
                .padding(.vertical, 1.0)
                .background(
                    location.index % 2 == 0
                    ? Color.gray.opacity(0.08)
                    : Color(.systemBackground)
                )
                .overlay {
                    if isPressed {
                        selectedPinGradient.gradient
                            .opacity(Constants.activeCellOpacity)
                    } else if isDragging {
                        Color(hex: headerColorHex)
                            .opacity(0.1)
                    } else {
                        EmptyView()
                    }
                }
                .cornerRadius(8.0)
                .shadow(color: .black.opacity(0.05), radius: 2.0, x: 0.0, y: 1.0)
                .onTapGesture {
                    isPressed = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        isPressed = false
                        viewModel.selectedLocation = location
                        currentToast = Toast(
                            message: "\(location.name)\n will show on map",
                            duration: 2.0,
                            width: 300.0
                        )
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: isPressed)
            }
            
        }
        
        // MARK: - Methods. Private
        
        private func deleteLocation(_ location: StorageLocation) {
            withAnimation(.easeInOut) {
                modelContext.delete(location)
                
                let deletedIndex = location.index
                
                for loc in locations where loc.index > deletedIndex {
                    loc.index -= 1
                }
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error: \(error)")
            }
        }
        
        private func handleDrop(droppedIds: [String], to location: StorageLocation) -> Bool {
            guard
                let droppedId = droppedIds.first,
                let from = locations.firstIndex(where: { $0.id == droppedId }),
                let to   = locations.firstIndex(of: location),
                from != to
            else {
                targetedId = nil
                return false
            }
            
            var copy = locations
            copy.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            
            for (i, loc) in copy.enumerated() {
                loc.index = i + 1
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error:", error)
            }
            
            targetedId = nil
            
            return true
        }
    }
    
}
