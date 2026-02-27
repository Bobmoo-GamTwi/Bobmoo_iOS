//
//  SearchViewModel.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/23/26.
//

import Foundation
import SwiftUI
import Observation

@MainActor
@Observable
final class SearchViewModel {
    private let service: SearchSchoolService
    private let settings: AppSettings

    var schools: [School] = []
    var query: String = ""
    var selectedSchoolId: Int?
    var errorMessage: String?

    var searchAmount: Int {
        schools.count
    }

    private var allSchools: [School] = []

    init(service: SearchSchoolService, settings: AppSettings) {
        self.service = service
        self.settings = settings
        
        // 뷰 진입 시 전체 학교 목록 로드
        Task {
            await loadAllSchools()
        }
    }

    func loadAllSchools() async {
        do {
            let response = try await service.fetchAllSchools()
            allSchools = response.data
            withAnimation(.easeInOut(duration: 0.25)) {
                schools = allSchools
            }
        } catch {
            errorMessage = error.localizedDescription
            print("[SearchViewModel] loadAllSchools failed: \(error)")
        }
    }


    func search(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedQuery.isEmpty {
            // 검색어가 비어있으면 전체 학교 목록 표시
            withAnimation(.easeInOut(duration: 0.25)) {
                schools = allSchools
            }
            return
        }

        errorMessage = nil

        // 로컬 필터링으로 검색
        withAnimation(.easeInOut(duration: 0.25)) {
            schools = allSchools.filter { school in
                school.displayName.localizedCaseInsensitiveContains(trimmedQuery)
            }
        }
    }

    func selectSchool(_ school: School) {
        selectedSchoolId = school.schoolId
        settings.selectedSchool = school.queryName
        settings.selectedSchoolColor = school.schoolColor
    }
}