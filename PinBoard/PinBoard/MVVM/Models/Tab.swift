//
//  Tab.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 09.07.2025.
//
    
import Foundation

enum Tab: String, CaseIterable {
    case list
    case map
    case settings
    
    var title: String {
        switch self {
            case .list:
                return "List"
            case .map:
                return "Map"
            case .settings:
                return "Settings"
        }
    }
    
    var iconName: String {
        switch self {
            case .list:
                return "list.bullet"
            case .map:
                return "map"
            case .settings:
                return "gearshape"
        }
    }
}

struct AnimatedTab: Identifiable {
    var id: String = UUID().uuidString
    var tab: Tab
    var isAnimation: Bool?
    
    init(tab: Tab) {
        self.id = UUID().uuidString
        self.tab = tab
    }
}
