//
//  View+Conditional.swift
//  RWLDesignSystem
//
//  General-purpose view helpers shared by components
//

import SwiftUI

// MARK: - View Extension for Conditional Modifiers
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
