import SwiftUI

struct HighlightedText: View {
    private let attributed: AttributedString

    init(_ text: String, highlight: String, highlightColor: Color = .accentColor) {
        var attributed = AttributedString(text)
        if !highlight.isEmpty, let range = attributed.range(of: highlight, options: .caseInsensitive) {
            attributed[range].foregroundColor = highlightColor
        }
        self.attributed = attributed
    }

    var body: some View {
        Text(attributed)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        HighlightedText("Project", highlight: "oject")
        HighlightedText("Assignment", highlight: "sign")
            .foregroundStyle(.secondary)
            .font(.subheadline)
        HighlightedText("No match here", highlight: "xyz")
        HighlightedText("Custom color", highlight: "color", highlightColor: .red)
    }
    .padding()
}
