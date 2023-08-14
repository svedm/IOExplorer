//
//  MainViewModel.swift
//  IOExplorer
//
//  Created by Svetoslav on 14.08.2023.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    @Published var mainEntry: [IORegistryEntry] = []

    private let registry = IORegistry()
    private var plane: IORegistryPlane = .service
    private var allEntries: [IORegistryEntry] = []

    func getRegistry(for plane: IORegistryPlane) {
        self.plane = plane
        mainEntry = [registry.enumerateEntries(for: plane)]
        allEntries = mainEntry
    }

    func search(for query: String) {
        guard !query.isEmpty else {
            return getRegistry(for: plane)
        }
        var result: [IORegistryEntry] = []

        for item in allEntries {
            result.append(contentsOf: lookUp(in: item, for: query))
        }

        mainEntry = result
    }

    private func lookUp(in enrtry: IORegistryEntry, for query: String) -> [IORegistryEntry] {
        if enrtry.displayName.lowercased().contains(query.lowercased()) {
            return [enrtry]
        }

        var result: [IORegistryEntry] = []
        for child in enrtry.childs {
            result.append(contentsOf: lookUp(in: child, for: query))
        }

        return result
    }
}
