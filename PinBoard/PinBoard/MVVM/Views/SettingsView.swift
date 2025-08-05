//
//  SettingsView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 08.07.2025.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Properties. Private
    
    @AppStorage(GlobalConstants.selectedPinIndexKey) private var selectedPinIndex: Int = 0
    @AppStorage(GlobalConstants.addLocationKey) private var isAutoAddingLocation: Bool = false
    @Namespace private var pinBorderNameSpace
    private let pinGradients = PinGradient.all
    
    // MARK: - Main body
    
    var body: some View {
        VStack(spacing: 10.0) {
            Text("Settings")
                .font(.custom(GlobalConstants.boldFont, size: 30.0))
            
            NavigationStack {
                Form {
                    Section(header: Text("Pins")) {
                        HStack(spacing: 16.0) {
                            ForEach(pinGradients.indices, id: \.self) { idx in
                                let gradient = pinGradients[idx]
                                let isSelected = idx == selectedPinIndex
                                
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
                                        selectedPinIndex = idx
                                    }
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Locations")) {
                        Toggle("Add new location \n without approval", isOn: $isAutoAddingLocation)
                    }
                    
                    Section {
                        Button(action: {
                            print("Log out")
                        }) {
                            Text("Log out")
                                .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundStyle(.white)
                                .background(Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                        }
                        .listRowBackground(Color.clear) 
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 10.0)
    }
    
}
