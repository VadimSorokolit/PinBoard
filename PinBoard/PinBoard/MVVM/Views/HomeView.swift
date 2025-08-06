//
//  HomeView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 09.07.2025.
//

import SwiftUI

struct HomeView: View {
    
    // MARK: - Properties. Private
    
    @State var activeTab: Tab = .list
    @State var allTabs: [AnimatedTab] = Tab.allCases.map(AnimatedTab.init)
    
    // MARK: - Main body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabContentView(activeTab: $activeTab)
            
            CustomTabBar(allTabs: $allTabs, activeTab: $activeTab)
        }
        .onAppear {
            Task {
                // Need to fix sharing view model state between tabs
                await showEachTab()
            }
        }
    }
    
    // Fix sharing view model state between tabs
    private func showEachTab() async {
        let tabs = Tab.allCases
        
        guard let startIndex = tabs.firstIndex(of: activeTab) else {
            return
        }
        
        for offset in 1...tabs.count {
            try? await Task.sleep(nanoseconds: 100_000_000)
            let next = tabs[(startIndex + offset) % tabs.count]
            await MainActor.run { activeTab = next }
        }
    }
    
    struct TabContentView: View {
        @Binding var activeTab: Tab
        
        var body: some View {
            TabView(selection: $activeTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    viewFor(tab)
                }
            }
        }
        
        private func viewFor(_ tab: Tab) -> some View {
            NavigationStack {
                switch tab {
                    case .list:
                        ListView()
                    case .map:
                        MapView()
                    case .settings:
                        SettingsView()
                }
            }
        }
    }
    
    struct CustomTabBar: View {
        @AppStorage(GlobalConstants.selectedPinIndexKey) private var selectedPinColorsIndex: Int = 0
        private var selectedPinGradient: PinGradient {
            PinGradient.all[selectedPinColorsIndex]
        }
        @Binding var allTabs: [AnimatedTab]
        @Binding var activeTab: Tab
        
        var body: some View {
            HStack {
                ForEach($allTabs) { $animatedTab in
                    let tab = animatedTab.tab
                    
                    ImageWithTitle(animatedTab: animatedTab, tab: tab)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(activeTab == tab ? Color.primary : Color.blue.opacity(0.8))
                        .padding(.top, 8.0)
                        .padding(.bottom, 6.0)
                        .containerShape(.rect)
                        .onTapGesture {
                            withAnimation(.bouncy, completionCriteria: .logicallyComplete, {
                                activeTab = tab
                                animatedTab.isAnimation = true
                            }, completion: {
                                var transiction = Transaction()
                                transiction.disablesAnimations = true
                                withTransaction(transiction) {
                                    animatedTab.isAnimation = false
                                }
                            })
                        }
                }
            }
            .frame(height: 50.0)
            .background(
                selectedPinGradient.gradient.opacity(GlobalConstants.barGradientOpacity)
                    .ignoresSafeArea(edges: .bottom)
            )
            .overlay(
                Rectangle()
                    .fill(Color(hex: GlobalConstants.separatorColor).opacity(GlobalConstants.barGradientOpacity))
                    .frame(height: 0.5),
                alignment: .top
            )
        }
        
        private struct ImageWithTitle: View {
            let animatedTab: AnimatedTab
            let tab: Tab
            
            var body: some View {
                VStack(spacing: 4.0) {
                    Image(systemName: tab.iconName)
                        .font(.title2)
                        .symbolEffect(.bounce.down.wholeSymbol, value: animatedTab.isAnimation)
                    
                    Text(tab.title)
                        .font(.custom(GlobalConstants.regularFont, size: 10.0))
                }
            }
            
        }
    }
    
}
