//
//  ContentView.swift
//  IOExplorer
//
//  Created by Svetoslav on 07.08.2023.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var plane: IORegistryPlane = .service
    @State private var showFilter = false
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            List(viewModel.mainEntry) { enrty in
                if enrty.childs.isEmpty {
                    NavigationItemView(name: enrty.name, haveDetails: !enrty.properties.isEmpty) {
                        PropertiesView(name: enrty.name, properties: enrty.properties)
                    }
                } else {
                    NavigationLink(value: enrty) {
                        NavigationItemView(name: enrty.name, haveDetails: !enrty.properties.isEmpty) {
                            PropertiesView(name: enrty.name, properties: enrty.properties)
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
            .refreshable {
                refreshData()
            }
            .navigationDestination(for: IORegistryEntry.self) { entry in
                if entry.childs.isEmpty {
                    PropertiesView(name: entry.name, properties: entry.properties)
                } else {
                    EntryView(entry: entry)
                }
            }
            .navigationTitle("IO Registry")
            .toolbar {
                HStack {
                    Menu(plane.ioKitPlane) {
                        ForEach(IORegistryPlane.allCases) { item in
                            Button(item.ioKitPlane) { plane = item }
                        }
                    }
                    .frame(minWidth: 100)
                    #if os(macOS)
                    TextField("Search", text: $searchText)
                        .frame(minWidth: 200)
                    #endif
                }
            }
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { newText in
            viewModel.search(for: newText)
        }
        .onChange(of: plane) { _ in
            refreshData()
        }
        .onAppear {
            refreshData()
        }
    }

    private func refreshData() {
        viewModel.getRegistry(for: plane)
    }

}

#Preview {
    MainView()
}
