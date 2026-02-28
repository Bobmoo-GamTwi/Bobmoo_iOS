//
//  SplashView.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/28/26.
//

import SwiftUI

struct SplashView: View {
    let homeViewModel: HomeViewModel
    let updateService: AppUpdateService
    let hasSelectedSchool: Bool
    let didFinish: (_ shouldGoHome: Bool, _ updateURL: URL?) -> Void

    @State private var didRun = false
    @State private var detectedUpdateURL: URL?

    init(
        homeViewModel: HomeViewModel,
        updateService: AppUpdateService = AppUpdateAPIService(),
        hasSelectedSchool: Bool,
        didFinish: @escaping (_ shouldGoHome: Bool, _ updateURL: URL?) -> Void
    ) {
        self.homeViewModel = homeViewModel
        self.updateService = updateService
        self.hasSelectedSchool = hasSelectedSchool
        self.didFinish = didFinish
    }

    var body: some View {
        ZStack {
            Color.bobmooWhite.ignoresSafeArea()

            VStack(spacing: 10) {
                Image(.iconBob)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 63, height: 57)

                BobmooText("밥묵자", style: .head_b_30)
                    .foregroundStyle(.bobmooBlack)
            }
        }
        .task {
            await startIfNeeded()
        }
    }

    private func startIfNeeded() async {
        guard !didRun else { return }
        didRun = true

        Task {
            await preloadIfNeeded()
        }

        Task {
            let updateURL = await fetchUpdateURL()
            await MainActor.run {
                detectedUpdateURL = updateURL
            }
        }

        try? await Task.sleep(nanoseconds: 1_200_000_000)
        didFinish(hasSelectedSchool, detectedUpdateURL)
    }

    private func preloadIfNeeded() async {
        if !homeViewModel.isPreloaded {
            await homeViewModel.preload()
        }
    }

    private func fetchUpdateURL() async -> URL? {
        if case .updateAvailable(let storeURL) = await updateService.checkForUpdate() {
            return storeURL
        }
        return nil
    }
}

#Preview("기본") {
    SplashView(
        homeViewModel: HomeViewModel(service: HomeMockMenuService(), settings: AppSettings()),
        hasSelectedSchool: false
    ) { _, _ in }
}

#Preview("업데이트 있음") {
    SplashView(
        homeViewModel: HomeViewModel(service: HomeMockMenuService(), settings: AppSettings()),
        updateService: AppUpdateMockService(
            result: .updateAvailable(storeURL: URL(string: "itms-apps://itunes.apple.com/app/id123456789")!)
        ),
        hasSelectedSchool: true
    ) { _, _ in }
}
