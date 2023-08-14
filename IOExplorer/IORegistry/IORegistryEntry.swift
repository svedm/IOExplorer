//
//  IORegistryEntry.swift
//  IOExplorer
//
//  Created by Svetoslav on 08.08.2023.
//

import Foundation

struct IORegistryEntry: Identifiable, Hashable {
    let id: Int
    let name: String
    let className: String?
    let path: String?
    let kernelRetainCount: Int
    let properties: [EntryProperty]

    let childs: [IORegistryEntry]

    var badge: Int {
        childs.isEmpty ? properties.count : childs.count
    }

    var displayName: String {
        guard
            let path,
            let comonents = URLComponents(string: path)
        else { return name }

        return comonents.path.split(separator: "/").last.map(String.init) ?? name
    }
}
