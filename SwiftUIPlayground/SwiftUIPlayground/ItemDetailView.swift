//
//  ItemDetailView.swift
//  SwiftUIPlayground
//

import SwiftUI
import SwiftData

struct ItemDetailView: View {
    let item: Item
    @State private var isEditing = false

    var body: some View {
        Form {
            Section {
                LabeledContent("Text", value: item.text)
            }
            Section {
                LabeledContent("Type", value: item.type.title)
                LabeledContent("Created", value: item.timestamp.formatted(date: .numeric, time: .standard))
            }
        }
        .navigationTitle("Item")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Edit") { isEditing = true }
            }
        }
        .sheet(isPresented: $isEditing) {
            ItemFormView(item: item)
        }
    }
}

#Preview {
    NavigationStack {
        ItemDetailView(item: Item(timestamp: .now, text: "Sample text", type: .todo))
    }
    .modelContainer(for: Item.self, inMemory: true)
}
