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

private let noneTitle = "None"

// MARK: - ViewModel

@Observable
final class EnumPickerViewModel<T: EnumTitleable> {
    private(set) var dataSource: [T?]
    var selected: T?
    let title: String
    let footer: String?
    let dismissOnSelection: Bool
    let doneTitle: String?
    let isSearchable: Bool
    private(set) var isDoneEnabled: Bool
    var completion: ((T?) -> Void)?

    init(
        title: String,
        selected: T?,
        showNone: Bool = false,
        dismissOnSelection: Bool = true,
        isSearchable: Bool = true,
        doneTitle: String? = nil,
        footer: String? = nil,
        completion: ((T?) -> Void)? = nil
    ) {
        self.title = title
        self.selected = selected
        self.dismissOnSelection = dismissOnSelection
        self.doneTitle = doneTitle
        self.footer = footer
        self.isSearchable = isSearchable
        self.completion = completion

        var items: [T?] = T.allCases.map { Optional($0) }
        if showNone { items.append(nil) }
        self.dataSource = items
        self.isDoneEnabled = selected != nil || showNone
    }

    func filtered(by searchText: String) -> [T?] {
        guard !searchText.isEmpty else { return dataSource }
        return dataSource.filter { item in
            let titleMatch = (item?.titleText ?? noneTitle).localizedCaseInsensitiveContains(searchText)
            let subtitleMatch = item?.subtitleText?.localizedCaseInsensitiveContains(searchText) ?? false
            return titleMatch || subtitleMatch
        }
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
    @State private var searchText = ""

    init(viewModel: EnumPickerViewModel<T>) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        let filtered = viewModel.filtered(by: searchText)

        Group {
            if viewModel.isSearchable {
                pickerList(filtered: filtered)
                    .searchable(text: $searchText, prompt: "Search")
            } else {
                pickerList(filtered: filtered)
            }
        }
        .navigationTitle(viewModel.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
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

    @ViewBuilder
    private func pickerList(filtered: [T?]) -> some View {
        List {
            Section {
                ForEach(filtered.indices, id: \.self) { index in
                    EnumPickerRow(
                        title: filtered[index]?.titleText ?? noneTitle,
                        subtitle: filtered[index]?.subtitleText,
                        isSelected: filtered[index] == viewModel.selected,
                        searchText: searchText
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.select(filtered[index])
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
        #if os(iOS)
        .listStyle(.insetGrouped)
        #else
        .listStyle(.inset)
        #endif
    }
}

// MARK: - Row

private struct EnumPickerRow: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let searchText: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HighlightedText(title, highlight: searchText)
                    .font(.body)
                if let subtitle {
                    HighlightedText(subtitle, highlight: searchText)
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
