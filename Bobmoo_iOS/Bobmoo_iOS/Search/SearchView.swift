//
//  SearchView.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/20/26.
//

import SwiftUI

struct SearchView: View {
    @State var query: String = ""
    @State var searchAmount: Int = 2
     
    var body: some View {
        VStack(spacing: 0) {
            SearchHeaderView(query: $query)
            
            SearchResultView(searchAmount: $searchAmount)
                        
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bobmooGray4.ignoresSafeArea())
    }
}

struct SearchHeaderView: View {
    @Binding var query: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BobmooText("학교찾기", style: .head_b_30)
                .padding(.top, 25)
                .padding(.leading, 26)
            
            BobmooTextField(query: $query) { _ in }
                .padding(.top, 14)
                .padding(.horizontal, 17)
        }

    }
}

struct SearchResultView: View {
    @Binding var searchAmount: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                BobmooText("검색 결과 \(searchAmount)", style: .body_b_15)
                    .padding(.leading, 18)
                    .padding(.top, 18)
                
                Spacer()
            }
            
        }
        .padding(.bottom, 18)
        .background(
            Rectangle()
                .cornerRadius(15)
                .foregroundStyle(.bobmooWhite)
        )
        .padding(.horizontal, 20)
        .padding(.top, 22)
    }
}

#Preview {
    SearchView()
}
