//
//  BobmooButton.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/14/26.
//

import SwiftUI

struct OperationPeriod {
    let startAt: Date
    let endAt: Date
}

enum OperationStatus {
    case before
    case active
    case ended
}

enum OperationStatusResolver {
    static func resolve(now: Date, period: OperationPeriod) -> OperationStatus {
        if now < period.startAt {
            return .before
        }

        if now <= period.endAt {
            return .active
        }

        return .ended
    }
}

struct BobmooLabel: View {
    private let status: OperationStatus

    init(status: OperationStatus) {
        self.status = status
    }

    // 시간계산을 염두한 설계
    init(period: OperationPeriod, now: Date = Date()) {
        let resolved = OperationStatusResolver.resolve(now: now, period: period)
        self.init(status: resolved)
    }

    var body: some View {
        BobmooText(title, style: .body_m_11)
            .padding(.horizontal, 10)
            .padding(.vertical, 1.5)
            .background(backgroundColor)
            .clipShape(Capsule())
            .foregroundStyle(.white)
    }

    private var title: String {
        switch status {
        case .before:
            return "운영전"
        case .active:
            return "운영중"
        case .ended:
            return "운영종료"
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .before:
            return .gray
        case .active:
            return .blue
        case .ended:
            return .red
        }
    }
}

#Preview {
    BobmooLabel(status: .active)
    BobmooLabel(status: .before)
    BobmooLabel(status: .ended)
}
