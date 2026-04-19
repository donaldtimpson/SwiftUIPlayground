//
//  CreateItemViewModel.swift
//  SwiftUIPlayground
//

import Foundation
import SwiftData
import Observation

@Observable
final class ItemFormViewModel {
    var text: String
    var type: ItemType
    private let item: Item?

    var isEditing: Bool { item != nil }

    init(item: Item? = nil) {
        self.text = item?.text ?? ""
        self.type = item?.type ?? .todo
        self.item = item
    }

    func save(in context: ModelContext) {
        if let item {
            item.text = text
            item.type = type
        } else {
            context.insert(Item(timestamp: Date(), text: text, type: type))
        }
    }

    func delete(from context: ModelContext) {
        guard let item else { return }
        context.delete(item)
    }
}
