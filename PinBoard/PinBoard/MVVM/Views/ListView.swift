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
        static let gridImageWidth: CGFloat = 16.0
        static let gridIndexTitleWidth: CGFloat = 42.0
        static let indexTitleWidth: CGFloat = 60.0
        static let nameTitleWidth: CGFloat = 200.0
        static let latitudeTitleWidth: CGFloat = 100.0
        static let longitudeTitleWidth: CGFloat = 100.0
        static let cellFontSize: CGFloat = 14.0
        static let headerFontSize: CGFloat = 16.0
        static let activeCellOpacity: Double = 0.3
        static let editButtonTrailingPadding: CGFloat = 16.0
        static let headerViewTitleFontSize: CGFloat = 20.0
        static let editTitleName: String = "Edit"
        static let menuTitleName: String = "Menu"
        static let indexTitleName: String = "Index"
        static let NameTitleName: String = "Name"
        static let latitudeTitleName: String = "Latitude"
        static let longitudeTitleName: String = "Longitude"
        static let toastMessage: String = "will show on map"
        static let editIconName: String = "line.3.horizontal"
        static let deleteIconName: String = "ellipsis"
        static let headerViewTitleName: String = "Locations"
        static let contentMenuLabelName: String = "Delete"
        static let contentMenuIconName: String = "trash"
        static let editButtonTitleEdit: String = "Edit"
        static let editButtonTitleDone: String = "Done"
        static let numberPrefixName: String = "No."
        static let editIconColor: Int = 0x000000
        static let indexTextColor: Int = 0x35C759
        static let longitudeTextColor: Int = 0xF95069
        static let latitudeTextColor: Int = 0x7732d3
    }
    
    // MARK: - Properties. Private
    
    @Environment(PinBoardViewModel.self) private var viewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StorageLocation.index) private var locations: [StorageLocation]
    @State private var targetedId: String? = nil
    @State private var isEditing: Bool = false
    @State private var isAnimation: Bool = false
    @State private var currentToast: Toast? = nil
    @State private var isShowingAlert = false
    @State private var alertMessage: Text = Text("")
    @AppStorage(GlobalConstants.selectedPaletteIndexKey) private var selectePaletteIndex: Int = 0
    private var selectedPalette: ColorGradient {
        ColorGradient.palette[selectePaletteIndex]
    }
    
    // MARK: - Main body
    
    var body: some View {
        VStack(spacing: .zero) {
            HeaderView(
                isEditing: $isEditing,
                isAnimation: $isAnimation,
                selectedPalette: selectedPalette
            )
            
            GridView(
                targetedId: $targetedId,
                isEditing: $isEditing,
                currentToast: $currentToast,
                isAnimation: $isAnimation,
                isShowingAlert: $isShowingAlert,
                alertMessage: $alertMessage,
                modelContext: modelContext,
                selectedPalette: selectedPalette,
                locations: locations
            )
        }
        .modifier(ScreenBackgroundModifier(currentToast: $currentToast))
        .modifier(AlertViewModifier(isShowingAlert: $isShowingAlert, alertMessage: $alertMessage))
    }
    
    // MARK: - Subviews
    
    private struct HeaderView: View {
        @Binding var isEditing: Bool
        @Binding var isAnimation: Bool
        let selectedPalette: ColorGradient
        
        var body: some View {
            ZStack {
                TextView()
                
                EditButtonView(isEditing: $isEditing, isAnimation: $isAnimation)
            }
            .padding(.top, 10.0)
            .padding(.bottom, 10.0)
            .frame(maxWidth: .infinity)
            .background(
                selectedPalette.gradient
                    .opacity(GlobalConstants.barGradientOpacity)
            )
        }
        
        private struct TextView: View {
            
            var body: some View {
                Text(Constants.headerViewTitleName)
                    .font(.custom(GlobalConstants.boldFont, size: Constants.headerViewTitleFontSize))
                    .foregroundStyle(.black)
            }
            
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
                        Text(isEditing ? Constants.editButtonTitleDone : Constants.editButtonTitleEdit)
                            .font(.custom(GlobalConstants.semiBoldFont, size: Constants.cellFontSize))
                    }
                }
                .padding(.trailing, Constants.editButtonTrailingPadding)
                .offset(y: 2.0)
            }
            
        }
        
    }
    
    
    private struct GridView: View {
        @Environment(PinBoardViewModel.self) private var viewModel
        @Binding var targetedId: String?
        @Binding var isEditing: Bool
        @Binding var currentToast: Toast?
        @Binding var isAnimation: Bool
        @Binding var isShowingAlert: Bool
        @Binding var alertMessage: Text
        let modelContext: ModelContext
        let selectedPalette: ColorGradient
        let locations: [StorageLocation]
        
        var body: some View {
            VStack(spacing: .zero) {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: .zero) {
                            HeaderView(isEditing: $isEditing)
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: .zero) {
                                    ForEach(locations) { location in
                                        let isDragging = targetedId == location.id
                                        
                                        let cell = CellView(
                                            isAnimation: $isAnimation,
                                            isEditing: $isEditing,
                                            currentToast: $currentToast,
                                            selectedPalette: selectedPalette,
                                            location: location,
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
        
        private struct HeaderView: View {
            @Binding var isEditing: Bool
            
            var body: some View {
                VStack(spacing: 8.0) {
                    Divider()
                    
                    Grid(horizontalSpacing: GlobalConstants.gridHorizontalSpacing) {
                        GridRow {
                            Text(isEditing ? Constants.editTitleName : Constants.menuTitleName)
                                .font(.custom(GlobalConstants.semiBoldFont, size: Constants.headerFontSize))
                                .frame(width: Constants.gridIndexTitleWidth)
                                .padding(.leading, Constants.editButtonTrailingPadding)
                                .verticalColumnDivider()
                            
                            Text(Constants.indexTitleName)
                                .font(.custom(GlobalConstants.semiBoldFont, size: Constants.headerFontSize))
                                .frame(width: Constants.indexTitleWidth, alignment: .leading)
                                .verticalColumnDivider()
                            
                            Text(Constants.NameTitleName)
                                .font(.custom(GlobalConstants.semiBoldFont, size: Constants.headerFontSize))
                                .frame(width: Constants.nameTitleWidth, alignment: .leading)
                                .verticalColumnDivider()
                            
                            Text(Constants.latitudeTitleName)
                                .font(.custom(GlobalConstants.semiBoldFont, size: Constants.headerFontSize))
                                .frame(width: Constants.latitudeTitleWidth, alignment: .leading)
                                .verticalColumnDivider()
                            
                            Text(Constants.longitudeTitleName)
                                .font(.custom(GlobalConstants.semiBoldFont, size: Constants.headerFontSize))
                                .frame(width: Constants.longitudeTitleWidth, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                }
                .background(Color(hex: GlobalConstants.separatorColor).opacity(GlobalConstants.barGradientOpacity))
                .frame(minWidth: Constants.gridWidth)
            }
        }
        
        private struct CellView: View {
            @Environment(PinBoardViewModel.self) private var viewModel
            @State private var isPressed = false
            @Binding var isAnimation: Bool
            @Binding var isEditing: Bool
            @Binding var currentToast: Toast?
            let selectedPalette: ColorGradient
            let location: StorageLocation
            let isDragging: Bool
            let onDelete: () -> Void
            
            var body: some View {
                Grid(horizontalSpacing: GlobalConstants.gridHorizontalSpacing) {
                    GridRow {
                        Menu(content: {
                            if !isEditing {
                                Button(role: .destructive) { onDelete() } label: {
                                    Label(Constants.contentMenuLabelName, systemImage: Constants.contentMenuIconName)
                                }
                            }
                        }) {
                            Image(systemName: isEditing
                                  ? Constants.editIconName
                                  : Constants.deleteIconName
                            )
                            .resizable()
                            .foregroundColor(Color(hex: Constants.editIconColor))
                            .scaledToFit()
                            .contentTransition(
                                .symbolEffect(
                                    .replace.magic(fallback: .downUp.wholeSymbol),
                                    options: .nonRepeating
                                )
                            )
                            .frame(width: Constants.gridImageWidth, height: Constants.gridImageWidth)
                        }
                        .frame(height: Constants.gridIndexTitleWidth)
                        .padding(.leading, Constants.editButtonTrailingPadding + Constants.gridIndexTitleWidth / 3.0)
                        
                        Text("\(Constants.numberPrefixName) \(location.index)")
                            .font(.custom(GlobalConstants.mediumFont, size: Constants.cellFontSize))
                            .foregroundColor(Color(hex:Constants.indexTextColor))
                            .frame(width: Constants.indexTitleWidth, alignment: .leading)
                            .padding(.leading, GlobalConstants.gridHorizontalSpacing / 2.6)
                        
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 1.0)
                .background(
                    location.index % 2 == 0
                    ? Color.gray.opacity(0.08)
                    : Color(.systemBackground)
                )
                .overlay {
                    if isPressed {
                        selectedPalette.gradient
                            .opacity(Constants.activeCellOpacity)
                    } else if isDragging {
                        Color(hex: GlobalConstants.separatorColor)
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
                            message: "\(location.name)\n \(Constants.toastMessage)",
                            duration: 2.0,
                            width: 300.0
                        )
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: isPressed)
            }
            
        }
        
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
                showErrorAlert(message: error.localizedDescription)
                
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
                showErrorAlert(message: error.localizedDescription)
            }
            
            targetedId = nil
            
            return true
        }
        
        private func showErrorAlert(message: String) {
            alertMessage = Text(message)
                .font(.custom(GlobalConstants.mediumFont, size: GlobalConstants.alertMessageFontSize))
            
            isShowingAlert = true
        }
    }
    
    // MARK: - Modifiers
    
    private struct ScreenBackgroundModifier: ViewModifier {
        @Binding var currentToast: Toast?
        
        func body(content: Content) -> some View {
            content
                .frame(maxHeight: .infinity, alignment: .top)
                .toast($currentToast)
        }
    }
    
    private struct AlertViewModifier: ViewModifier {
        @Binding var isShowingAlert: Bool
        @Binding var alertMessage: Text
        
        func body(content: Content) -> some View {
            content
                .overlay(alignment: .center) {
                    if isShowingAlert {
                        AlertView(
                            message: alertMessage,
                            onOk: {
                                isShowingAlert = false
                            }
                        )
                    }
                }
        }
    }
}
