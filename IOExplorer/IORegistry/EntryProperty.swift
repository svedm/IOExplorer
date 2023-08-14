//
//  EntryProperty.swift
//  IOExplorer
//
//  Created by Svetoslav on 08.08.2023.
//

import Foundation

struct EntryProperty: Identifiable, Hashable {
    var id: String {
        name
    }

    var name: String
    var value: Value

    indirect enum Value: Hashable {
        case string(String)
        case data(Data)
        case array([Value])
        case property([EntryProperty])
        case unknown(Any)

        static func == (lhs: EntryProperty.Value, rhs: EntryProperty.Value) -> Bool {
            switch (lhs, rhs) {
                case (.string(let lValue), .string(let rValue)):
                    return lValue == rValue
                case (.data(let lValue), .data(let rValue)):
                    return lValue == rValue
                case (.array(let lValue), .array(let rValue)):
                    return lValue == rValue
                case (.property(let lValue), .property(let rValue)):
                    return lValue == rValue
                case (_, _):
                    return false
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
                case .string(let value):
                    hasher.combine(value)
                case .data(let value):
                    hasher.combine(value)
                case .array(let value):
                    hasher.combine(value)
                case .property(let value):
                    hasher.combine(value)
                case .unknown(let value as any Hashable):
                    hasher.combine(value)
                default:
                    break
            }
        }
    }
}
