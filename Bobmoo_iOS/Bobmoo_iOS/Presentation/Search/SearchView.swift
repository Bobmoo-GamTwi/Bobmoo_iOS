//
//  SearchView.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/20/26.
//

import SwiftUI

struct SearchView: View {
    @Bindable var viewModel: SearchViewModel
    var didComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SearchHeaderView(query: $viewModel.query, onSearch: viewModel.search)

            SearchResultView(
                schools: viewModel.schools,
                searchAmount: viewModel.searchAmount,
                selectedSchoolId: viewModel.selectedSchoolId,
                onSelect: { school in
                    viewModel.selectSchool(school)
                }
            )

            Spacer()

            BobmooButton(label: "선택완료") {
                didComplete()
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bobmooGray4.ignoresSafeArea())
        .alert("오류", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("확인") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

struct SearchHeaderView: View {
    @Binding var query: String
    var onSearch: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BobmooText("학교찾기", style: .head_b_30)
                .padding(.top, 25)
                .padding(.leading, 26)

            BobmooTextField(query: $query, onSearch: onSearch)
                .padding(.top, 14)
                .padding(.horizontal, 17)
        }

    }
}

struct SearchResultView: View {
    let schools: [School]
    let searchAmount: Int
    let selectedSchoolId: Int?
    let onSelect: (School) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BobmooText("검색 결과 \(searchAmount)", style: .body_b_15)
                .padding(.leading, 18)
                .padding(.top, 18)

            ForEach(schools) { school in
                Button {
                    onSelect(school)
                } label: {
                    HStack(spacing: 0) {
                        BobmooText(school.displayName, style: .body_b_15)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .trailing) {
                        if selectedSchoolId == school.schoolId {
                            Image(.check)
                                .padding(.trailing, 18)
                        }
                    }
                    .padding(.leading, 21)
                    .padding(.trailing, 18)
                    .padding(.top, 26)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())

                Divider()
                    .padding(.top, 22)
                    .padding(.horizontal, 18)
                    .foregroundStyle(.bobmooGray5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
    SearchView(viewModel: SearchViewModel(service: SearchAPISchoolService(), settings: AppSettings())) {}
}
