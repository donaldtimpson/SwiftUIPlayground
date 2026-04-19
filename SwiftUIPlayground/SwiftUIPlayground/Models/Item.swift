//
//  Item.swift
//  SwiftUIPlayground
//
//  Created by Donny Timpson - JC on 4/17/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var text: String
    var type: ItemType
    
    var displayTitle: String { "\(type.title): \(text)" }
    
    init(timestamp: Date, text: String, type: ItemType) {
        self.timestamp = timestamp
        self.text = text
        self.type = type
    }
}

enum ItemType: String, Codable, CaseIterable {
    case todo
    case note
    case event
    case task
    case assignment
    case project
    case reminder
    case goal
    case milestone
    case target
    case schedule
    case appointment

    var title: String {
        switch self {
        case .todo: return "To-Do"
        default: return rawValue.capitalized
        }
    }
}

extension ItemType: EnumTitleable {
    var titleText: String { title }
    var subtitleText: String? {
        switch self {
        case .todo:       return "A task to check off"
        case .note:       return "A free-form note"
        case .event:      return "A scheduled event"
        case .task:       return "An assigned task"
        case .assignment: return "Work assigned to someone"
        case .project:    return "A collection of tasks"
        default:          return "Something generic"
        }
    }
}
