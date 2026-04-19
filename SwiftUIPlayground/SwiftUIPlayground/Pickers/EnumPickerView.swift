import SwiftUI

// MARK: - Protocols

protocol Titleable: Equatable {
    var titleText: String { get }
    var subtitleText: String? { get }
}

extension Titleable {
    var subtitleText: String? { nil }
}

protocol EnumTitleable: CaseIterable, Titleable { }

// MARK: - ViewModel

@Observable
final class EnumPickerViewModel<T: EnumTitleable> {
    private(set) var dataSource: [T?]
    var selected: T?
    let title: String
    let footer: String?
    let dismissOnSelection: Bool
    let doneTitle: String?
    private(set) var isDoneEnabled: Bool
    var completion: ((T?) -> Void)?

    init(title: String, selected: T?, showNone: Bool = false, dismissOnSelection: Bool = true, doneTitle: String? = nil, footer: String? = nil, completion: ((T?) -> Void)? = nil) {
        self.title = title
        self.selected = selected
        self.dismissOnSelection = dismissOnSelection
        self.doneTitle = doneTitle
        self.footer = footer
        self.completion = completion

        var items: [T?] = T.allCases.map { Optional($0) }
        if showNone { items.append(nil) }
        self.dataSource = items
        self.isDoneEnabled = selected != nil || showNone
    }

    func select(_ item: T?) {
        selected = item
        isDoneEnabled = true
    }

    func fireCompletion() {
        completion?(selected)
    }
}

// MARK: - View

struct EnumPickerView<T: EnumTitleable>: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EnumPickerViewModel<T>

    init(viewModel: EnumPickerViewModel<T>) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                ForEach(viewModel.dataSource.indices, id: \.self) { index in
                    EnumPickerRow(
                        title: viewModel.dataSource[index]?.titleText ?? "None",
                        subtitle: viewModel.dataSource[index]?.subtitleText,
                        isSelected: viewModel.dataSource[index] == viewModel.selected
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.select(viewModel.dataSource[index])
                        if viewModel.dismissOnSelection && viewModel.doneTitle == nil {
                            dismiss()
                        }
                    }
                }
            } footer: {
                if let footer = viewModel.footer {
                    Text(footer)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let doneTitle = viewModel.doneTitle {
                ToolbarItem(placement: .confirmationAction) {
                    Button(doneTitle) {
                        viewModel.fireCompletion()
                        dismiss()
                    }
                    .disabled(!viewModel.isDoneEnabled)
                }
            }
        }
        .onDisappear {
            if viewModel.doneTitle == nil {
                viewModel.fireCompletion()
            }
        }
    }
}

// MARK: - Row

private struct EnumPickerRow: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
                    .fontWeight(.semibold)
            }
        }
        .frame(height: subtitle == nil ? 44 : 60)
    }
}
