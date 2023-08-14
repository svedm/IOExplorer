//
//  EntryView.swift
//  IOExplorer
//
//  Created by Svetoslav on 14.08.2023.
//

import SwiftUI

struct EntryView: View {
    @State var entry: IORegistryEntry

    var body: some View {
        if !entry.childs.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                if let path = entry.path {
                    HStack {
                        Text(path)
                    }
                    .padding(.horizontal)
                }
                List(entry.childs) { child in
                    NavigationLink(value: child) {
                        NavigationItemView(
                            name: child.displayName,
                            subtitle: child.className.map { "Class: \($0)" },
                            subtitle2: "Retain: \(child.kernelRetainCount)",
                            haveDetails: !child.properties.isEmpty
                        ) {
                            PropertiesView(name: child.displayName, properties: child.properties)
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            .navigationTitle(entry.displayName)
        } else {
            PropertiesView(name: entry.displayName, properties: entry.properties)
        }
    }
}
