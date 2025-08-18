//
//  SettingsView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 08.07.2025.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Objects
    
    private struct Constants {
        static let headerViewTitleName: String = "Settings"
        static let logOutButtonTitleName: String = "Log out"
        static let locationsHeaderTitleName: String = "Locations"
        static let pinsHeaderTitleName: String = "Pins"
        static let locationsSectionText: String = "Add new location\nwithout approval"
        static let locationsSectionTextSpacing: CGFloat = 8.0
        static let logOutButtonBottomSpacing: CGFloat = 30.0
        static let logOutButtonColorOpacity: Double = 0.6
        static let logOutButtonFontSize: CGFloat = 16.0
        static let headerViewTitleColor: Int = 0x000000
    }
    
    // MARK: - Properties. Private
    
    @Environment(PinBoardViewModel.self) private var viewModel
    @AppStorage(GlobalConstants.selectedPaletteIndexKey) private var selectedPaletteIndex: Int = 0
    @AppStorage(GlobalConstants.addLocationKey) private var isAutoAddingLocation: Bool = false
    private var selectedPalette: ColorGradient {
        ColorGradient.palette[selectedPaletteIndex]
    }
    
    // MARK: - Main body
    
    var body: some View {
        ZStack {
            VStack(spacing: .zero) {
                HeaderView(selectedPalette: selectedPalette)
                
                SectionsView(
                    isAutoAddingLocation: $isAutoAddingLocation,
                    selectedPaletteIndex: $selectedPaletteIndex,
                    selectedPalette: selectedPalette)
            }
            
            LogOutButtonView()
        }
    }
    
    // MARK: - Subviews
    
    private struct HeaderView: View {
        let selectedPalette: ColorGradient
        
        var body: some View {
            Text(Constants.headerViewTitleName)
                .font(.custom(GlobalConstants.boldFont, size: 20.0))
                .foregroundStyle(Color(hex: Constants.headerViewTitleColor))
                .padding(.top, 10.0)
                .padding(.bottom, 10.0)
                .frame(maxWidth: .infinity)
                .background(
                    selectedPalette.gradient
                        .opacity(GlobalConstants.barGradientOpacity)
                )
                .overlay(alignment: .bottom) {
                    Divider()
                        .background(Color(hex: GlobalConstants.separatorColor))
                        .opacity(GlobalConstants.barGradientOpacity)
                        .frame(height: 0.5)
                }
        }
        
    }
    
    private struct SectionsView: View {
        @Binding var isAutoAddingLocation: Bool
        @Binding var selectedPaletteIndex: Int
        let selectedPalette: ColorGradient
        
        var body: some View {
            NavigationStack {
                VStack(spacing: .zero) {
                    Form {
                        Section(header: Text(Constants.pinsHeaderTitleName)) {
                            let pinContainerSize: CGFloat = 33.0
                            let spacing: CGFloat = 16.0
                            let step = pinContainerSize + spacing
                            
                            ZStack(alignment: .leading) {
                                HStack(spacing: spacing) {
                                    ForEach(Array(ColorGradient.palette.indices), id: \.self) { idx in
                                        let palette = ColorGradient.palette[idx]
                                        palette.gradient
                                            .mask(Image(GlobalConstants.pinImageName)
                                                .resizable()
                                                .scaledToFit())
                                            .frame(width: 24.0, height: 24.0)
                                            .frame(width: pinContainerSize, height: pinContainerSize)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 1.0)) {
                                                    selectedPaletteIndex = idx
                                                }
                                            }
                                    }
                                }
                                
                                RoundedRectangle(cornerRadius: 6.0)
                                    .stroke(selectedPalette.gradient, lineWidth: 3.0)
                                    .frame(width: pinContainerSize, height: pinContainerSize)
                                    .offset(x: CGFloat(selectedPaletteIndex) * step)
                                    .animation(.spring(response: 0.4, dampingFraction: 1.0), value: selectedPaletteIndex)
                            }
                        }
                        
                        Section(header: Text(Constants.locationsHeaderTitleName)) {
                            Toggle(isOn: $isAutoAddingLocation) {
                                Text(Constants.locationsSectionText)
                                    .lineSpacing(Constants.locationsSectionTextSpacing)
                            }
                        }
                    }
                    .listSectionSpacing(.compact)
                }
            }
        }
        
    }
    
    private struct LogOutButtonView: View {
        @Environment(PinBoardViewModel.self) private var viewModel
        
        var body: some View {
            VStack {
                Spacer()
                
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        viewModel.logout()
                    }
                }) {
                    Text(Constants.logOutButtonTitleName)
                        .font(.custom(GlobalConstants.semiBoldFont, size: Constants.logOutButtonFontSize))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.black).opacity(Constants.logOutButtonColorOpacity)
                        .padding(.bottom, Constants.logOutButtonBottomSpacing)
                }
            }
        }
        
    }
}
