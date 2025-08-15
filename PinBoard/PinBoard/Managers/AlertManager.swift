//
//  AlertManager.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 15.08.2025.
//

import Foundation
import SwiftUI

@Observable
class AlertManager {
    
    // Properties. Public
    
    var isPresented = false
    var message: Text = Text("")
    var layout: AlertView.Layout = .informational
    var onConfirm: () -> Void = {}
    var onCancel: (() -> Void)? = nil
    
    // Methods. Public
    
    func showInfoWith(_ message: Text,
                   onOK: @escaping () -> Void = {}
    ) {
        self.message = message
        self.layout = .informational
        self.onConfirm = {
            onOK()
            self.isPresented = false
        }
        self.onCancel = nil
        self.isPresented = true
    }

    func showError(_ message: Text,
                   onOK: @escaping () -> Void = {}
    ) {
        self.message = message
        self.layout = .informational
        self.onConfirm = {
            onOK()
            self.isPresented = false
        }
        self.onCancel = nil
        self.isPresented = true
    }
    
    func showConfirmWith(_ message: Text,
                 onConfirm: @escaping () -> Void,
                 onCancel: @escaping () -> Void) {
        self.message = message
        self.layout = .confirmation
        self.onConfirm = {
            onConfirm()
            self.isPresented = false
        }
        self.onCancel = {
            onCancel()
            self.isPresented = false }
        self.isPresented = true
    }
    
    func hide() {
        self.isPresented = false
    }
    
}
