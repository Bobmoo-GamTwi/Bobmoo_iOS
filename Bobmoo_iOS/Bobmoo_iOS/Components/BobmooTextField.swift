//
//  BobmooTextField.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/14/26.
//

import SwiftUI

struct BobmooTextField: View {
    @Binding var query: String
    var onSearch: (String) -> Void = { _ in }

    private func submitSearch() {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        onSearch(trimmedQuery)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            TextField("검색어를 입력해주세요.", text: $query)
                .bobmooFont(.body_m_15)
                .submitLabel(.search)
                .onSubmit(submitSearch)
                .padding(.leading, 17)
            
            Spacer()

            Button(action: {
                submitSearch()
            }) {
                Image(.search)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 14)
        }
        .padding(.vertical, 11)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.bobmooGray1, lineWidth: 1.5)
        )
    }
}
