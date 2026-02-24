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

    init(service: SearchSchoolService, settings: AppSettings) {
        self.service = service
        self.settings = settings
    }

    func fetchSchools() async {
        do {
            let response = try await service.fetchSchools()
            withAnimation(.easeInOut(duration: 0.25)) {
                schools = response.data
            }
        } catch {
            errorMessage = error.localizedDescription
            print("[SearchViewModel] fetchSchools failed: \(error)")
        }
    }

    func selectSchool(_ school: School) {
        selectedSchoolId = school.schoolId
        settings.selectedSchool = school.schoolName
        settings.selectedSchoolColor = school.schoolColor
    }
}
