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
        static let lccationsHeaderTitleName: String = "Locations"
        static let pinsHeaderTitleName: String = "Pins"
        static let locationsSectionText: String = "Add new location\nwithout approval"
        static let locationsSectionTextSpacing: CGFloat = 8.0
    }
   
    // MARK: - Properties. Private
    
    @AppStorage(GlobalConstants.selectedPinIndexKey) private var selectedPinColorsIndex: Int = 0
    @AppStorage(GlobalConstants.addLocationKey) private var isAutoAddingLocation: Bool = false
    @Namespace private var pinBorderNameSpace
    private let pinGradients = PinGradient.all
    private var selectedPinGradient: PinGradient {
        PinGradient.all[selectedPinColorsIndex]
    }
    
    // MARK: - Main body
    
    var body: some View {
        ZStack {
            VStack(spacing: 0.0) {
                HeaderView(selectedPinGradient: selectedPinGradient)
                
                NavigationStack {
                    VStack(spacing: 0.0) {
                        Form {
                            Section(header: Text(Constants.pinsHeaderTitleName)) {
                                HStack(spacing: 16.0) {
                                    ForEach(pinGradients.indices, id: \.self) { idx in
                                        let gradient = pinGradients[idx]
                                        let isSelected = idx == selectedPinColorsIndex
                                        
                                        ZStack {
                                            if isSelected {
                                                RoundedRectangle(cornerRadius: 6.0)
                                                    .stroke(gradient.gradient, lineWidth: 3.0)
                                                    .frame(width: 30.0, height: 30.0)
                                                    .matchedGeometryEffect(id: "border", in: pinBorderNameSpace)
                                            }
                                            
                                            gradient.gradient
                                                .mask(
                                                    Image(GlobalConstants.pinImageName)
                                                        .resizable()
                                                        .scaledToFit()
                                                )
                                                .frame(width: 24.0, height: 24.0)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                                selectedPinColorsIndex = idx
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Section(header: Text(Constants.lccationsHeaderTitleName)) {
                                Toggle(isOn: $isAutoAddingLocation) {
                                    Text(Constants.locationsSectionText)
                                        .lineSpacing(Constants.locationsSectionTextSpacing)
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            
            LogOutButtonView()
        }
    }
    
    private struct HeaderView: View {
        let selectedPinGradient: PinGradient
        
        var body: some View {
            Text(Constants.headerViewTitleName)
                .font(.custom(GlobalConstants.boldFont, size: 20.0))
                .foregroundStyle(.black)
                .padding(.top, 10.0)
                .frame(maxWidth: .infinity)
                .background(selectedPinGradient.gradient.opacity(GlobalConstants.barGradientOpacity))
            
            Rectangle()
                .fill(selectedPinGradient.gradient)
                .opacity(GlobalConstants.barGradientOpacity)
                .frame(height: 10.0)
                .overlay(
                    Rectangle()
                        .fill(Color(hex: GlobalConstants.separatorColor).opacity(GlobalConstants.barGradientOpacity))
                        .frame(height: 0.5),
                    alignment: .bottom
                )
        }
        
    }
    
    private struct LogOutButtonView: View {
        @Environment(PinBoardViewModel.self) private var viewModel
        
        var body: some View {
            VStack {
                Spacer()
                
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.logout()
                    }
                }) {
                    Text(Constants.logOutButtonTitleName)
                        .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.black)
                        .padding(.bottom, 40.0)
                }
            }
        }
        
    }
}

