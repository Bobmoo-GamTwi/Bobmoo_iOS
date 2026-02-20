//
//  BobmooCalendarButton.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/18/26.
//

import SwiftUI
import Observation

struct BobmooCalendarButton: View {
    @Bindable var vm: HomeViewModel

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        return formatter
    }()

    private var formattedDate: String {
        Self.dateFormatter.string(from: vm.currentDate)
    }
     
    var body: some View {
        Button(action: { vm.isCalendarPresented = true }) {
            HStack(spacing: 6) {
                BobmooText(formattedDate, style: .body_sb_12)
            }
            .foregroundStyle(.bobmooWhite)
            .frame(height: 22)
            .padding(.horizontal, 12)
            .background(.bobmooWhite.opacity(0.1))
            .clipShape(Capsule())
        }
        .sheet(isPresented: $vm.isCalendarPresented) {
            DatePicker(
                "날짜 선택",
                selection: $vm.currentDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding(16)
            .presentationDetents([.height(420)])
            .presentationDragIndicator(.visible)
        }
    }
}
