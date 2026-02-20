//
//  BobmooButton.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/20/26.
//

import SwiftUI

struct BobmooButton: View {
    
    var label: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            BobmooText(label, style: .head_b_21)
                .foregroundColor(.bobmooWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(.bobmooGray3)
                )
        }
    }
}

#Preview {
    BobmooButton(label: "시작하기") {
        print("Hi")
    }
    .padding(.horizontal, 41)
}
