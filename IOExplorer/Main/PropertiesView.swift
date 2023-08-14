//
//  PropertiesView.swift
//  IOExplorer
//
//  Created by Svetoslav on 14.08.2023.
//

import SwiftUI

struct PropertiesView: View {
    let name: String
    let properties: [EntryProperty]

    var body: some View {
        List(properties, id: \.name) { item in
            VStack(alignment: .leading, spacing: 12) {
                Text(item.name)
                    .font(.caption2)
                    .foregroundStyle(.gray)
                PropertyValueView(property: item)
                #if os(macOS)
                Divider()
                #endif
            }
        }
        .listRowSeparator(.hidden)
        .navigationDestination(for: [EntryProperty].self) { propperties in
            PropertiesView(name: name, properties: propperties)
        }
        .navigationTitle("\(name) Properties")
    }
}
