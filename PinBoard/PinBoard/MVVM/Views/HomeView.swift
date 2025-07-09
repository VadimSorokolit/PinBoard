//
//  HomeView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 09.07.2025.
//
    
import SwiftUI

struct HomeView: View {
    @State var activeTab: Tab = .list
    @State var allTabs: [AnimatedTab] = Tab.allCases.map(AnimatedTab.init)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabContentView(activeTab: $activeTab)
            
            CustomTabBar(allTabs: $allTabs, activeTab: $activeTab)
        }
    }
    
    struct TabContentView: View {
        @Binding var activeTab: Tab
        
        var body: some View {
            TabView(selection: $activeTab) {
                NavigationStack {
                    switch activeTab {
                        case .list:
                            TableView()
                        case .map:
                            MapView()
                        case .settings:
                            SettingsView()
                    }
                }
            }
        }
        
    }
    
    struct CustomTabBar: View {
        @Binding var allTabs: [AnimatedTab]
        @Binding var activeTab: Tab
        
        var body: some View {
            HStack {
                ForEach($allTabs) { $animatedTab in
                    let tab = animatedTab.tab
                    
                    ImageWithTitle(animatedTab: animatedTab, tab: tab)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(activeTab == tab ? Color.primary : Color.gray.opacity(0.8))
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
            .background(.bar)
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
                        .font(.caption2)
                        .textScale(.secondary)
                    
                }
            }
            
        }
    }
}
