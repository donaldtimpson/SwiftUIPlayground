import SwiftUI

extension AttributedString {
    init(_ text: String, highlight: String, highlightColor: Color = .accentColor) {
        self.init(text)
        guard !highlight.isEmpty,
              let range = self.range(of: highlight, options: .caseInsensitive) else { return }
        self[range].foregroundColor = highlightColor
    }
}
