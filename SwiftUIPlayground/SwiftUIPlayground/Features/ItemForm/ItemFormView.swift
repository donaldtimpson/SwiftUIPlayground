//
//  CreateItemView.swift
//  SwiftUIPlayground
//

import SwiftUI
import SwiftData

struct ItemFormView: View {
    @State private var viewModel: ItemFormViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    init(item: Item? = nil) {
        _viewModel = State(initialValue: ItemFormViewModel(item: item))
    }

    @State private var isConfirmingDelete = false

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            Form {
                Section {
                    TextField("Text", text: $viewModel.text)
                }
                Section {
                    NavigationLink {
                        EnumPickerView(viewModel: EnumPickerViewModel<ItemType>(
                            title: "Type",
                            selected: viewModel.type,
                            doneTitle: "Done",
                            footer: "Make your selection of the item that you want to select by selecting the item in the row.",
                            completion: { selected in
                                if let selected { viewModel.type = selected }
                            }
                        ))
                    } label: {
                        LabeledContent("Type", value: viewModel.type.titleText)
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Item" : "Create Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save(in: modelContext)
                        dismiss()
                    }
                    .disabled(viewModel.text.isEmpty)
                }
                if viewModel.isEditing {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Delete Item", role: .destructive) {
                            isConfirmingDelete = true
                        }
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                        .actionDialog(title: "Delete Item", message: "Are you sure that you want to delete this item? This action cannot be undone.", actionTitle: "Delete", actionRole: .destructive, isPresented: $isConfirmingDelete) {
                            viewModel.delete(from: modelContext)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview("Create") {
    ItemFormView()
        .modelContainer(for: Item.self, inMemory: true)
}

#Preview("Edit") {
    ItemFormView(item: Item(timestamp: .now, text: "Sample text", type: .todo))
        .modelContainer(for: Item.self, inMemory: true)
}
