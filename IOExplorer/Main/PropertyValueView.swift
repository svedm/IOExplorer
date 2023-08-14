//
//  PropertyValueView.swift
//  IOExplorer
//
//  Created by Svetoslav on 14.08.2023.
//

import SwiftUI

struct PropertyValueView: View {
    let property: EntryProperty

    var body: some View {
        switch property.value {
            case .string(let string):
                Text(string)
                    .contextMenu(ContextMenu(menuItems: {
                        Button("Copy name") {
                            #if os(iOS)
                            UIPasteboard.general.string = property.name
                            #elseif os(macOS)
                            NSPasteboard.general.setString(string, forType: .string)
                            #endif
                        }
                        Button("Copy value") {
                            #if os(iOS)
                            UIPasteboard.general.string = property.name
                            #elseif os(macOS)
                            NSPasteboard.general.setString(string, forType: .string)
                            #endif
                        }
                    }))
            case .data(let data):
                if let string = String(data: data, encoding: .utf8) {
                    Text(string)
                } else {
                    Text(data.map { String(format: "%02hhx", $0) }.joined(separator: "\t"))
                }
            case .array(let array):
                NavigationLink(
                    property.name,
                    value: array.map({ EntryProperty(name: property.name, value: $0) })
                )
                #if os(macOS)
                .badge(array.count)
                #endif
            case .property(let prop):
                NavigationLink(property.name, value: prop)
                #if os(macOS)
                .badge(prop.count)
                #endif
            case .unknown:
                Text("Unknown")
        }
    }
}
