//
//  ContentView.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/13/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        BobmooText("운영종료", style: .body_m_11)
            .foregroundStyle(.Bobmoo_White)
            .padding(.horizontal, 10)
            .padding(.vertical, 1.5)
            .background(.Bobmoo_Red)
            .clipShape(Capsule())
    }
}

#Preview {
    HomeView()
}
