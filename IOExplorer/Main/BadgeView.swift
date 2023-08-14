//
//  BadgeView.swift
//  IOExplorer
//
//  Created by Svetoslav on 14.08.2023.
//

import SwiftUI

struct BadgeView: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.caption2)
            .foregroundStyle(.white)
            .padding(.init(top: 2, leading: 4, bottom: 2, trailing: 4))
            .background(Color("Tag"))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    BadgeView("1112")
}
