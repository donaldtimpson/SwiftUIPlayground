//
//  OkDialogue.swift
//  SwiftUIPlayground
//
//  Created by Donny Timpson - JC on 4/17/26.
//

import SwiftUI

struct OkDialog: ViewModifier {
    var title: String?
    var message: String
    var isPresented: Binding<Bool>
    
    func body(content: Content) -> some View {
        content.actionDialog(title: title, message: message, actionTitle: "OK", isPresented: isPresented, action: { })
    }
}

struct ContinueDialog: ViewModifier {
    var title: String?
    var message: String
    var isPresented: Binding<Bool>
    var action: () -> Void
    
    func body(content: Content) -> some View {
        content.actionDialog(title: title, message: message, actionTitle: "Continue", isPresented: isPresented, action: action)
    }
}

struct ActionDialog: ViewModifier {
    var title: String?
    var message: String
    var actionTitle: String
    var actionRole: ButtonRole
    var cancelTitle: String
    var isPresented: Binding<Bool>
    var action: () -> Void
    var cancel: () -> Void
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog(title ?? "", isPresented: isPresented, titleVisibility: title == nil ? .hidden : .visible) {
                Button(actionTitle, role: actionRole, action: action)
                Button(cancelTitle, role: .close, action: cancel)
            } message: {
                Text(message)
            }
    }
}

extension View {
    func okDialog(title: String?, message: String, isPresented: Binding<Bool>) -> some View {
        modifier(OkDialog(title: title, message: message, isPresented: isPresented))
    }
    
    func continueDialog(title: String?, message: String, isPresented: Binding<Bool>, action: @escaping () -> Void) -> some View {
        modifier(ContinueDialog(title: title, message: message, isPresented: isPresented, action: action))
    }
    
    func actionDialog(title: String?, message: String, actionTitle: String, actionRole: ButtonRole = .cancel, cancelTitle: String = "Cancel", isPresented: Binding<Bool>, cancel: @escaping (() -> Void) = { }, action: @escaping () -> Void) -> some View {
        modifier(ActionDialog(title: title, message: message, actionTitle: actionTitle, actionRole: actionRole, cancelTitle: cancelTitle, isPresented: isPresented, action: action, cancel: cancel))
    }
}
