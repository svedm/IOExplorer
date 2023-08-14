//
//  NavigationItemView.swift
//  IOExplorer
//
//  Created by Svetoslav on 14.08.2023.
//

import SwiftUI

struct NavigationItemView<SheetView: View>: View {
    let name: String
    let subtitle: String?
    let subtitle2: String?
    let haveDetails: Bool
    @ViewBuilder var sheetView: () -> SheetView

    @State private var showSheet = false

    init(
        name: String,
        subtitle: String? = nil,
        subtitle2: String? = nil,
        haveDetails: Bool,
        sheetView: @escaping () -> SheetView
    ) {
        self.name = name
        self.subtitle = subtitle
        self.subtitle2 = subtitle2
        self.haveDetails = haveDetails
        self.sheetView = sheetView
        self.showSheet = showSheet
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(name)
                    Spacer()
                        .allowsHitTesting(false)
                        .disabled(true)
                }
                if let subtitle {
                    HStack {
                        BadgeView(subtitle)
                        if let subtitle2 {
                            BadgeView(subtitle2)
                        }
                    }
                }
            #if os(macOS)
            Divider()
            #endif
            }
            Spacer()
            if haveDetails {
                Image(systemName: "info.circle")
                    .renderingMode(.template)
                    .foregroundStyle(.blue)
                    .onTapGesture {
                        showSheet.toggle()
                    }
                    .padding(.trailing)
            }
            #if os(macOS)
            Image(systemName: "chevron.right")
            #endif
        }
        .contentShape(Rectangle())
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                sheetView()
            }
            .presentationDetents([.medium, .large])
        }
    }
}
